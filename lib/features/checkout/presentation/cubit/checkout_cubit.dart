import 'package:drift/drift.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/services/order_number_service.dart';
import '../../../../core/services/printer_service.dart';
import '../../../../core/services/telegram_settings_service.dart';
import '../../../../core/services/whatsapp_queue_processor.dart';
import '../../../../core/services/whatsapp_settings_service.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../../orders/domain/repositories/order_repository.dart';
import '../../../tables/domain/repositories/table_repository.dart';
import '../../../whatsapp/domain/repositories/whatsapp_repository.dart';

abstract class CheckoutState extends Equatable {
  const CheckoutState();
  @override
  List<Object?> get props => [];
}

class CheckoutInitial extends CheckoutState {}

class CheckoutLoading extends CheckoutState {}

class CheckoutSuccess extends CheckoutState {
  final bool isOnline;
  final bool messageQueued;
  final String invoiceNumber;

  const CheckoutSuccess({
    required this.isOnline,
    required this.messageQueued,
    required this.invoiceNumber,
  });

  @override
  List<Object?> get props => [isOnline, messageQueued, invoiceNumber];
}

class CheckoutError extends CheckoutState {
  final String message;
  const CheckoutError(this.message);
  @override
  List<Object?> get props => [message];
}

class CheckoutCubit extends Cubit<CheckoutState> {
  final PrinterService printerService;
  final TableRepository tableRepository;
  final OrderRepository orderRepository;
  final OrderNumberService orderNumberService;
  final AppDatabase db;
  final WhatsAppRepository whatsappRepository;
  final WhatsAppSettingsService settingsService;
  final TelegramSettingsService? telegramSettingsService;
  final ConnectivityService connectivityService;
  final WhatsAppQueueProcessor queueProcessor;

  CheckoutCubit({
    required this.printerService,
    required this.tableRepository,
    required this.orderRepository,
    required this.orderNumberService,
    required this.db,
    required this.whatsappRepository,
    required this.settingsService,
    this.telegramSettingsService,
    required this.connectivityService,
    required this.queueProcessor,
  }) : super(CheckoutInitial());

  Future<void> processCheckout(
    OrderEntity order,
    double serviceChargeRate,
    double taxRate,
    double serviceCharge,
    double tax,
    double grandTotal,
    int? tableNumber, {
    bool shouldPrint = true,
    String paymentMethod = 'cash',
  }) async {
    emit(CheckoutLoading());
    try {
      final orderNumber = orderNumberService.getNextOrderNumber();
      final now = DateTime.now();
      final invoiceNumber = 'INV-$orderNumber-${now.millisecondsSinceEpoch}';

      // 1. Print receipt locally if requested
      if (shouldPrint) {
        await printerService.printReceipt(
          order,
          serviceChargeRate,
          taxRate,
          serviceCharge,
          tax,
          grandTotal,
          tableNumber,
          orderNumber,
          paymentMethod: paymentMethod,
        );
      }

      final isOnline = connectivityService.isOnline;
      bool messageQueued = false;

      // 2. Perform Local Transaction: Stock check -> Deduct stock -> Save invoice -> Complete order
      await db.transaction(() async {
        // Step A: Stock Check - verify items that track inventory are in stock
        for (final item in order.items) {
          final prod = await (db.select(db.products)..where((p) => p.id.equals(item.productId))).getSingle();
          if (prod.trackInventory && prod.stockQuantity < item.quantity) {
            throw Exception('الكمية غير متوفرة في المخزون للمنتج "${prod.name}". المتاح حاليًا: ${prod.stockQuantity}');
          }
        }

        // Step B: Ensure Order ID exists in DB (for PlayStation-only orders)
        int actualOrderId = order.id;
        if (actualOrderId == 0) {
          actualOrderId = await db.into(db.orders).insert(
                OrdersCompanion.insert(
                  tableId: Value(order.tableId),
                  status: const Value('completed'),
                  orderType: Value(order.orderType),
                  subtotal: Value(order.subtotal),
                  createdAt: Value(now),
                ),
              );
        }

        // Step C: Save Invoice
        final invoiceId = await db.into(db.invoices).insert(
              InvoicesCompanion.insert(
                orderId: actualOrderId,
                invoiceNumber: invoiceNumber,
                subtotal: order.subtotal,
                taxAmount: tax,
                serviceCharge: serviceCharge,
                grandTotal: grandTotal,
                paymentMethod: Value(paymentMethod),
                playStationAmount: Value(order.playStationCost),
                isClosedShift: const Value(false),
                createdAt: Value(now),
              ),
            );

        // Step C2: Save InvoiceItems snapshots for historical view and reprint (Mod 2)
        for (final item in order.items) {
          await db.into(db.invoiceItems).insert(
                InvoiceItemsCompanion.insert(
                  invoiceId: invoiceId,
                  productId: Value(item.productId),
                  productName: item.productName,
                  quantity: Value(item.quantity),
                  unitPrice: item.unitPrice,
                  totalPrice: item.totalPrice,
                ),
              );
        }

        // Step D: Deduct Stock and create Inventory Movements for each tracked item
        for (final item in order.items) {
          final prod = await (db.select(db.products)..where((p) => p.id.equals(item.productId))).getSingle();
          if (!prod.trackInventory) continue; // Skip products not tracked in inventory (Mod 3)

          final prevStock = prod.stockQuantity;
          final newStock = prevStock - item.quantity;

          await (db.update(db.products)..where((p) => p.id.equals(item.productId))).write(
            ProductsCompanion(stockQuantity: Value(newStock)),
          );

          await db.into(db.inventoryMovements).insert(
                InventoryMovementsCompanion.insert(
                  productId: item.productId,
                  quantity: item.quantity,
                  movementType: 'sale',
                  previousQuantity: prevStock,
                  newQuantity: newStock,
                  reason: Value('مبيعات فاتورة #$invoiceNumber'),
                  createdAt: Value(now),
                ),
              );
        }

        // Step E: If PlayStation session was used, ensure it is closed and saved
        if (order.playStationSessionId != null) {
          await (db.update(db.playStationSessions)..where((s) => s.id.equals(order.playStationSessionId!))).write(
            PlayStationSessionsCompanion(
              status: const Value('completed'),
              calculatedAmount: Value(order.playStationCost),
              endTime: Value(now),
            ),
          );
        }

        // Step F: Free the table
        if (order.tableId != null) {
          await tableRepository.updateTableStatus(order.tableId!, 'free');
        }

        // Step G: Mark order completed
        if (actualOrderId != 0) {
          await orderRepository.updateOrderStatus(actualOrderId, 'completed');
        }

        // Step H: Create Outbox Queue Item inside local transaction for Telegram & WhatsApp
        final paymentMethodLabel = switch (paymentMethod) {
          'wallet' => '📱 محفظة إلكترونية (Wallet)',
          'instapay' => '⚡ إنستاباي (InstaPay)',
          _ => '💵 نقدي (Cash)',
        };

        final payload = _formatInvoiceTelegramMessage(
          invoiceNumber: invoiceNumber,
          date: DateFormat('yyyy/MM/dd').format(now),
          time: DateFormat('HH:mm').format(now),
          items: order.items,
          playStationCost: order.playStationCost,
          playStationDescription: order.playStationDescription,
          subtotal: order.subtotal,
          tax: tax,
          serviceCharge: serviceCharge,
          total: grandTotal,
          paymentMethod: paymentMethodLabel,
        );

        await whatsappRepository.enqueueInvoice(
          invoiceId: invoiceId,
          recipientPhone: settingsService.recipientPhone,
          messagePayload: payload,
        );
        messageQueued = true;
      });

      // 3. Trigger Queue processor (asynchronous/background)
      if (messageQueued) {
        queueProcessor.processQueue();
      }

      emit(CheckoutSuccess(
        isOnline: isOnline,
        messageQueued: messageQueued,
        invoiceNumber: invoiceNumber,
      ));
    } catch (e) {
      emit(CheckoutError('خطأ أثناء حفظ الفاتورة: ${e.toString().replaceAll("Exception: ", "")}'));
    }
  }

  String _formatInvoiceTelegramMessage({
    required String invoiceNumber,
    required String date,
    required String time,
    required List<OrderItemEntity> items,
    double playStationCost = 0.0,
    String? playStationDescription,
    required double subtotal,
    required double tax,
    required double serviceCharge,
    required double total,
    required String paymentMethod,
  }) {
    final itemsBuffer = StringBuffer();
    for (final item in items) {
      itemsBuffer.writeln('• ${item.productName} × ${item.quantity} = ${item.totalPrice.toStringAsFixed(2)} ج.م');
    }
    if (playStationCost > 0) {
      itemsBuffer.writeln('• 🎮 ${playStationDescription ?? "بلايستيشن"} = ${playStationCost.toStringAsFixed(2)} ج.م');
    }

    return '''
<b>☕ فاتورة جديدة - Cafe POS</b>

<b>رقم الفاتورة:</b> #$invoiceNumber

<b>التاريخ:</b> $date
<b>الوقت:</b> $time

<b>الطلبات:</b>
${itemsBuffer.toString().trim()}

────────────────

<b>المجموع الفرعي:</b> ${subtotal.toStringAsFixed(2)} ج.م
${serviceCharge > 0 ? '<b>الخدمة:</b> ${serviceCharge.toStringAsFixed(2)} ج.م\n' : ''}${tax > 0 ? '<b>الضريبة:</b> ${tax.toStringAsFixed(2)} ج.م\n' : ''}<b>الإجمالي النهائي:</b> <u>${total.toStringAsFixed(2)} ج.م</u>

<b>طريقة الدفع:</b> $paymentMethod

شكرًا لاستخدام Cafe POS ❤️
''';
  }
}
