import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/services/printer_service.dart';
import '../../../../core/services/order_number_service.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../../tables/domain/repositories/table_repository.dart';
import '../../../orders/domain/repositories/order_repository.dart';

abstract class CheckoutState extends Equatable {
  const CheckoutState();
  @override
  List<Object> get props => [];
}

class CheckoutInitial extends CheckoutState {}

class CheckoutLoading extends CheckoutState {}

class CheckoutSuccess extends CheckoutState {}

class CheckoutError extends CheckoutState {
  final String message;
  const CheckoutError(this.message);
  @override
  List<Object> get props => [message];
}

class CheckoutCubit extends Cubit<CheckoutState> {
  final PrinterService printerService;
  final TableRepository tableRepository;
  final OrderRepository orderRepository;
  final OrderNumberService orderNumberService;
  final AppDatabase db; // Task 6: needed to save invoice record

  CheckoutCubit({
    required this.printerService,
    required this.tableRepository,
    required this.orderRepository,
    required this.orderNumberService,
    required this.db,
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
  }) async {
    emit(CheckoutLoading());
    try {
      // 1. Get daily order number
      final orderNumber = orderNumberService.getNextOrderNumber();
      final invoiceNumber = 'INV-$orderNumber-${DateTime.now().millisecondsSinceEpoch}';

      // 2. Print receipt only if requested
      if (shouldPrint) {
        await printerService.printReceipt(
            order, serviceChargeRate, taxRate, serviceCharge, tax, grandTotal, tableNumber, orderNumber);
      }

      // 3. Save Invoice to DB (Task 6: isClosedShift defaults to false)
      await db.into(db.invoices).insert(
            InvoicesCompanion.insert(
              orderId: order.id,
              invoiceNumber: invoiceNumber,
              subtotal: order.subtotal,
              taxAmount: tax,
              serviceCharge: serviceCharge,
              grandTotal: grandTotal,
              // isClosedShift defaults to false per table schema
            ),
          );

      // 4. Free the table
      if (order.tableId != null) {
        await tableRepository.updateTableStatus(order.tableId!, 'free');
      }

      // 5. Mark order as completed
      await orderRepository.updateOrderStatus(order.id, 'completed');

      emit(CheckoutSuccess());
    } catch (e) {
      emit(CheckoutError(e.toString()));
    }
  }
}

