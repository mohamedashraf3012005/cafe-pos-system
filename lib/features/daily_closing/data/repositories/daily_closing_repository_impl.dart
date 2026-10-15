import 'package:drift/drift.dart';
import 'package:intl/intl.dart';
import '../../../../core/database/app_database.dart';
import '../../../whatsapp/domain/repositories/whatsapp_repository.dart';
import '../../domain/entities/daily_closing_entity.dart';
import '../../domain/entities/invoice_item_entity.dart';
import '../../domain/repositories/daily_closing_repository.dart';

class DailyClosingRepositoryImpl implements DailyClosingRepository {
  final AppDatabase db;
  final WhatsAppRepository whatsappRepository;

  DailyClosingRepositoryImpl({
    required this.db,
    required this.whatsappRepository,
  });

  DailyClosingEntity _toEntity(DailyClosing row) {
    return DailyClosingEntity(
      id: row.id,
      closingDate: row.closingDate,
      closingTime: row.closingTime,
      invoiceCount: row.invoiceCount,
      grossSales: row.grossSales,
      discounts: row.discounts,
      taxTotal: row.taxTotal,
      netSales: row.netSales,
      cashTotal: row.cashTotal,
      walletTotal: row.walletTotal,
      instapayTotal: row.instapayTotal,
      cardTotal: row.cardTotal,
      otherPayments: row.otherPayments,
      playStationTotal: row.playStationTotal,
      totalItems: row.totalItems,
      status: row.status,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  @override
  Future<DailyClosingEntity?> getClosingForDate(String dateStr) async {
    final row = await (db.select(db.dailyClosings)
          ..where((d) => d.closingDate.equals(dateStr))
          ..limit(1))
        .getSingleOrNull();
    return row != null ? _toEntity(row) : null;
  }

  @override
  Future<DailyClosingEntity> performDailyClosing({
    required String recipientPhone,
    required bool enqueueWhatsApp,
  }) async {
    final now = DateTime.now();
    final dateStr = DateFormat('yyyy-MM-dd').format(now);
    final timeStr = DateFormat('HH:mm').format(now);

    // Rule 29: Check if today is already closed
    final existing = await getClosingForDate(dateStr);
    if (existing != null && existing.isClosed) {
      throw Exception('تم تقفيل هذا اليوم بالفعل ($dateStr).');
    }

    return db.transaction(() async {
      // 1. Fetch all open shift invoices
      final openInvoices = await (db.select(db.invoices)
            ..where((inv) => inv.isClosedShift.equals(false)))
          .get();

      final invoiceCount = openInvoices.length;
      double grossSales = 0.0;
      double taxTotal = 0.0;
      double discounts = 0.0;
      double cashTotal = 0.0;
      double walletTotal = 0.0;
      double instapayTotal = 0.0;
      double cardTotal = 0.0;
      double otherPayments = 0.0;
      double playStationTotal = 0.0;

      final orderIds = <int>[];
      for (final inv in openInvoices) {
        grossSales += inv.subtotal;
        taxTotal += inv.taxAmount;
        playStationTotal += inv.playStationAmount;
        orderIds.add(inv.orderId);

        if (inv.paymentMethod == 'cash') {
          cashTotal += inv.grandTotal;
        } else if (inv.paymentMethod == 'wallet') {
          walletTotal += inv.grandTotal;
        } else if (inv.paymentMethod == 'instapay') {
          instapayTotal += inv.grandTotal;
        } else if (inv.paymentMethod == 'card') {
          cardTotal += inv.grandTotal;
        } else {
          otherPayments += inv.grandTotal;
        }
      }

      final netSales = grossSales + taxTotal - discounts;

      // Calculate total item count for open invoices
      int totalItems = 0;
      if (orderIds.isNotEmpty) {
        final itemsResult = await (db.select(db.orderItems)
              ..where((item) => item.orderId.isIn(orderIds)))
            .get();
        for (final item in itemsResult) {
          totalItems += item.quantity;
        }
      }

      // 2. Insert Daily Closing Snapshot record
      final closingId = await db.into(db.dailyClosings).insert(
            DailyClosingsCompanion.insert(
              closingDate: dateStr,
              closingTime: timeStr,
              invoiceCount: Value(invoiceCount),
              grossSales: Value(grossSales),
              discounts: Value(discounts),
              taxTotal: Value(taxTotal),
              netSales: Value(netSales),
              cashTotal: Value(cashTotal),
              walletTotal: Value(walletTotal),
              instapayTotal: Value(instapayTotal),
              cardTotal: Value(cardTotal),
              otherPayments: Value(otherPayments),
              playStationTotal: Value(playStationTotal),
              totalItems: Value(totalItems),
              status: const Value('closed'),
              createdAt: Value(now),
              updatedAt: Value(now),
            ),
          );

      // 3. Mark all open shift invoices as closed
      await (db.update(db.invoices)
            ..where((inv) => inv.isClosedShift.equals(false)))
          .write(const InvoicesCompanion(isClosedShift: Value(true)));

      final createdRow = await (db.select(db.dailyClosings)
            ..where((d) => d.id.equals(closingId)))
          .getSingle();

      final entity = _toEntity(createdRow);

      // 4. Create WhatsApp Queue item if enabled (Requirement 30)
      if (enqueueWhatsApp) {
        final waMessageText = _formatDailyClosingMessage(entity);
        await whatsappRepository.enqueueDailyClosing(
          dailyClosingId: entity.id,
          recipientPhone: recipientPhone,
          messagePayload: waMessageText,
        );
      }

      return entity;
    });
  }

  @override
  Future<List<DailyClosingEntity>> getClosingHistory({int limit = 50}) async {
    final rows = await (db.select(db.dailyClosings)
          ..orderBy([(d) => OrderingTerm.desc(d.createdAt)])
          ..limit(limit))
        .get();
    return rows.map(_toEntity).toList();
  }

  @override
  Future<DailyClosingEntity?> getClosingById(int id) async {
    final row = await (db.select(db.dailyClosings)
          ..where((d) => d.id.equals(id)))
        .getSingleOrNull();
    return row != null ? _toEntity(row) : null;
  }

  @override
  Future<List<InvoiceDetailEntity>> getInvoicesForClosingDate(String dateStr) async {
    final parts = dateStr.split('-');
    if (parts.length != 3) return [];
    final year = int.tryParse(parts[0]) ?? 2026;
    final month = int.tryParse(parts[1]) ?? 1;
    final day = int.tryParse(parts[2]) ?? 1;
    final startOfDay = DateTime(year, month, day);
    final endOfDay = DateTime(year, month, day, 23, 59, 59, 999);

    final invoices = await (db.select(db.invoices)
          ..where((inv) =>
              inv.createdAt.isBiggerOrEqualValue(startOfDay) &
              inv.createdAt.isSmallerOrEqualValue(endOfDay))
          ..orderBy([(inv) => OrderingTerm.desc(inv.createdAt)]))
        .get();

    final results = <InvoiceDetailEntity>[];
    for (final inv in invoices) {
      final details = await getInvoiceDetails(inv.id);
      if (details != null) {
        results.add(details);
      }
    }
    return results;
  }

  @override
  Future<InvoiceDetailEntity?> getInvoiceDetails(int invoiceId) async {
    final inv = await (db.select(db.invoices)..where((i) => i.id.equals(invoiceId))).getSingleOrNull();
    if (inv == null) return null;

    final savedItems = await (db.select(db.invoiceItems)..where((i) => i.invoiceId.equals(invoiceId))).get();

    List<InvoiceItemEntity> items;
    if (savedItems.isNotEmpty) {
      items = savedItems.map((item) => InvoiceItemEntity(
        id: item.id,
        invoiceId: item.invoiceId,
        productId: item.productId,
        productName: item.productName,
        quantity: item.quantity,
        unitPrice: item.unitPrice,
        totalPrice: item.totalPrice,
      )).toList();
    } else {
      // Graceful fallback for older invoices created prior to v7 update
      try {
        final query = db.select(db.orderItems).join([
          innerJoin(db.products, db.products.id.equalsExp(db.orderItems.productId)),
        ])..where(db.orderItems.orderId.equals(inv.orderId));

        final rows = await query.get();
        items = rows.map((row) {
          final orderItem = row.readTable(db.orderItems);
          final product = row.readTable(db.products);
          return InvoiceItemEntity(
            id: orderItem.id,
            invoiceId: invoiceId,
            productId: orderItem.productId,
            productName: product.name,
            quantity: orderItem.quantity,
            unitPrice: orderItem.unitPrice,
            totalPrice: orderItem.totalPrice,
          );
        }).toList();
      } catch (_) {
        items = [];
      }
    }

    return InvoiceDetailEntity(
      id: inv.id,
      orderId: inv.orderId,
      invoiceNumber: inv.invoiceNumber,
      subtotal: inv.subtotal,
      taxAmount: inv.taxAmount,
      serviceCharge: inv.serviceCharge,
      grandTotal: inv.grandTotal,
      paymentMethod: inv.paymentMethod,
      playStationAmount: inv.playStationAmount,
      isClosedShift: inv.isClosedShift,
      createdAt: inv.createdAt,
      items: items,
    );
  }

  String _formatDailyClosingMessage(DailyClosingEntity c) {
    return '''
<b>📊 تقفيل حساب اليوم - Cafe POS</b>

<b>📅 التاريخ:</b> ${c.closingDate}
<b>⏰ وقت التقفيل:</b> ${c.closingTime}

<b>عدد الفواتير:</b> ${c.invoiceCount}
<b>عدد القطع المباعة:</b> ${c.totalItems} قطعة

────────────────
<b>إجمالي المبيعات:</b> ${c.grossSales.toStringAsFixed(2)} ج.م
${c.playStationTotal > 0 ? '<b>🎮 مبيعات البلايستيشن:</b> ${c.playStationTotal.toStringAsFixed(2)} ج.م\n' : ''}<b>الخصومات:</b> ${c.discounts.toStringAsFixed(2)} ج.م
<b>الضرائب:</b> ${c.taxTotal.toStringAsFixed(2)} ج.م
<b>صافي المبيعات:</b> <u>${c.netSales.toStringAsFixed(2)} ج.م</u>

<b>تفاصيل طرق الدفع:</b>
💵 <b>النقدي (Cash):</b> ${c.cashTotal.toStringAsFixed(2)} ج.م
${c.walletTotal > 0 ? '📱 <b>محفظة إلكترونية (Wallet):</b> ${c.walletTotal.toStringAsFixed(2)} ج.م\n' : ''}${c.instapayTotal > 0 ? '⚡ <b>إنستاباي (InstaPay):</b> ${c.instapayTotal.toStringAsFixed(2)} ج.م\n' : ''}${c.cardTotal > 0 ? '💳 <b>بطاقة (Card):</b> ${c.cardTotal.toStringAsFixed(2)} ج.م\n' : ''}${c.otherPayments > 0 ? '🔹 <b>طرق أخرى:</b> ${c.otherPayments.toStringAsFixed(2)} ج.م\n' : ''}────────────────
<b>حالة اليوم:</b> تم إغلاق حساب اليوم بنجاح ✅
''';
  }
}
