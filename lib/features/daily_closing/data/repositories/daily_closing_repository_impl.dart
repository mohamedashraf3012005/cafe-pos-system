import 'package:drift/drift.dart';
import 'package:intl/intl.dart';
import '../../../../core/database/app_database.dart';
import '../../../whatsapp/domain/repositories/whatsapp_repository.dart';
import '../../domain/entities/daily_closing_entity.dart';
import '../../domain/entities/invoice_item_entity.dart';
import '../../domain/entities/expense_item_entity.dart';
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
      expensesTotal: row.expensesTotal,
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
          ..orderBy([(d) => OrderingTerm.desc(d.createdAt)])
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

    return db.transaction(() async {
      // 1. Fetch all open shift invoices
      final openInvoices = await (db.select(db.invoices)
            ..where((inv) => inv.isClosedShift.equals(false)))
          .get();

      // 2. Fetch all open shift expenses
      final openExpenses = await (db.select(db.expenses)
            ..where((e) => e.isClosedShift.equals(false)))
          .get();

      if (openInvoices.isEmpty && openExpenses.isEmpty) {
        throw Exception('لا توجد معاملات أو مبيعات أو مصروفات مفتوحة لتقفيل هذه الوردية.');
      }

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

      // Calculate total expenses for this shift
      double expensesTotal = 0.0;
      for (final exp in openExpenses) {
        expensesTotal += exp.amount;
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

      // 3. Insert Shift Closing Snapshot record
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
              expensesTotal: Value(expensesTotal),
              totalItems: Value(totalItems),
              status: const Value('closed'),
              createdAt: Value(now),
              updatedAt: Value(now),
            ),
          );

      // 4. Mark all open shift invoices as closed
      await (db.update(db.invoices)
            ..where((inv) => inv.isClosedShift.equals(false)))
          .write(const InvoicesCompanion(isClosedShift: Value(true)));

      // 5. Mark all open shift expenses as closed and link to this closing
      await (db.update(db.expenses)
            ..where((e) => e.isClosedShift.equals(false)))
          .write(ExpensesCompanion(
            isClosedShift: const Value(true),
            shiftClosingId: Value(closingId),
          ));

      final createdRow = await (db.select(db.dailyClosings)
            ..where((d) => d.id.equals(closingId)))
          .getSingle();

      final entity = _toEntity(createdRow);

      // 6. Create WhatsApp Queue item if enabled
      if (enqueueWhatsApp) {
        final waMessageText = _formatDailyClosingMessage(entity, openExpenses);
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
  Future<void> addExpense(double amount, String reason) async {
    if (amount <= 0) {
      throw Exception('يجب أن يكون مبلغ المصروف أكبر من صفر.');
    }
    if (reason.trim().isEmpty) {
      throw Exception('يرجى كتابة سبب أو ملاحظة المصروف.');
    }
    await db.into(db.expenses).insert(
          ExpensesCompanion.insert(
            amount: amount,
            reason: reason.trim(),
            createdAt: Value(DateTime.now()),
            isClosedShift: const Value(false),
          ),
        );
  }

  @override
  Future<List<ExpenseItemEntity>> getOpenShiftExpenses() async {
    final rows = await (db.select(db.expenses)
          ..where((e) => e.isClosedShift.equals(false))
          ..orderBy([(e) => OrderingTerm.desc(e.createdAt)]))
        .get();

    return rows
        .map((r) => ExpenseItemEntity(
              id: r.id,
              amount: r.amount,
              reason: r.reason,
              createdAt: r.createdAt,
              isClosedShift: r.isClosedShift,
              shiftClosingId: r.shiftClosingId,
            ))
        .toList();
  }

  @override
  Future<void> deleteExpense(int expenseId) async {
    await (db.delete(db.expenses)..where((e) => e.id.equals(expenseId))).go();
  }

  @override
  Future<List<ExpenseItemEntity>> getExpensesForClosing(int closingId) async {
    final rows = await (db.select(db.expenses)
          ..where((e) => e.shiftClosingId.equals(closingId))
          ..orderBy([(e) => OrderingTerm.asc(e.createdAt)]))
        .get();

    return rows
        .map((r) => ExpenseItemEntity(
              id: r.id,
              amount: r.amount,
              reason: r.reason,
              createdAt: r.createdAt,
              isClosedShift: r.isClosedShift,
              shiftClosingId: r.shiftClosingId,
            ))
        .toList();
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

    final y = int.tryParse(parts[0]) ?? 2026;
    final m = int.tryParse(parts[1]) ?? 1;
    final d = int.tryParse(parts[2]) ?? 1;

    final startOfDay = DateTime(y, m, d);
    final endOfDay = DateTime(y, m, d, 23, 59, 59, 999);

    final invoices = await (db.select(db.invoices)
          ..where((inv) =>
              inv.createdAt.isBiggerOrEqualValue(startOfDay) &
              inv.createdAt.isSmallerOrEqualValue(endOfDay))
          ..orderBy([(inv) => OrderingTerm.desc(inv.createdAt)]))
        .get();

    final result = <InvoiceDetailEntity>[];
    for (final inv in invoices) {
      final items = await _fetchInvoiceItems(inv.id, inv.orderId);
      result.add(InvoiceDetailEntity(
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
      ));
    }

    return result;
  }

  Future<List<InvoiceItemEntity>> _fetchInvoiceItems(int invoiceId, int orderId) async {
    final savedItems = await (db.select(db.invoiceItems)
          ..where((item) => item.invoiceId.equals(invoiceId)))
        .get();

    if (savedItems.isNotEmpty) {
      return savedItems
          .map((item) => InvoiceItemEntity(
                id: item.id,
                invoiceId: item.invoiceId,
                productId: item.productId,
                productName: item.productName,
                quantity: item.quantity,
                unitPrice: item.unitPrice,
                totalPrice: item.totalPrice,
              ))
          .toList();
    }

    final orderItems = await (db.select(db.orderItems)
          ..where((item) => item.orderId.equals(orderId)))
        .get();

    return orderItems
        .map((item) => InvoiceItemEntity(
              id: item.id,
              invoiceId: invoiceId,
              productId: item.productId,
              productName: item.productName,
              quantity: item.quantity,
              unitPrice: item.unitPrice,
              totalPrice: item.unitPrice * item.quantity,
            ))
        .toList();
  }

  @override
  Future<InvoiceDetailEntity?> getInvoiceDetails(int invoiceId) async {
    final inv = await (db.select(db.invoices)
          ..where((i) => i.id.equals(invoiceId)))
        .getSingleOrNull();

    if (inv == null) return null;

    final items = await _fetchInvoiceItems(inv.id, inv.orderId);

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

  String _formatDailyClosingMessage(DailyClosingEntity c, [List<Expense> expenses = const []]) {
    final buffer = StringBuffer();
    buffer.writeln('<b>📊 تقفيل الوردية - بريسكا كافيه</b>');
    buffer.writeln();
    buffer.writeln('<b>📅 التاريخ:</b> ${c.closingDate}');
    buffer.writeln('<b>⏰ وقت التقفيل:</b> ${c.closingTime}');
    buffer.writeln();
    buffer.writeln('<b>عدد الفواتير:</b> ${c.invoiceCount}');
    buffer.writeln('<b>عدد القطع المباعة:</b> ${c.totalItems} قطعة');
    buffer.writeln('────────────────');
    buffer.writeln('<b>إجمالي المبيعات:</b> ${c.grossSales.toStringAsFixed(2)} ج.م');
    if (c.playStationTotal > 0) {
      buffer.writeln('<b>🎮 مبيعات البلايستيشن:</b> ${c.playStationTotal.toStringAsFixed(2)} ج.م');
    }
    buffer.writeln('<b>الخصومات:</b> ${c.discounts.toStringAsFixed(2)} ج.م');
    buffer.writeln('<b>الضرائب:</b> ${c.taxTotal.toStringAsFixed(2)} ج.م');
    buffer.writeln('<b>صافي المبيعات:</b> <u>${c.netSales.toStringAsFixed(2)} ج.م</u>');
    buffer.writeln();
    buffer.writeln('<b>تفاصيل طرق الدفع:</b>');
    buffer.writeln('💵 <b>النقدي (Cash):</b> ${c.cashTotal.toStringAsFixed(2)} ج.م');
    if (c.walletTotal > 0) {
      buffer.writeln('📱 <b>محفظة (Wallet):</b> ${c.walletTotal.toStringAsFixed(2)} ج.م');
    }
    if (c.instapayTotal > 0) {
      buffer.writeln('⚡ <b>إنستاباي (InstaPay):</b> ${c.instapayTotal.toStringAsFixed(2)} ج.م');
    }
    if (c.cardTotal > 0) {
      buffer.writeln('💳 <b>بطاقة (Card):</b> ${c.cardTotal.toStringAsFixed(2)} ج.م');
    }
    if (c.otherPayments > 0) {
      buffer.writeln('🔹 <b>طرق أخرى:</b> ${c.otherPayments.toStringAsFixed(2)} ج.م');
    }

    if (c.expensesTotal > 0) {
      buffer.writeln('────────────────');
      buffer.writeln('💸 <b>إجمالي المصروفات:</b> ${c.expensesTotal.toStringAsFixed(2)} ج.م');
      if (expenses.isNotEmpty) {
        for (final exp in expenses) {
          buffer.writeln('  • ${exp.reason}: ${exp.amount.toStringAsFixed(2)} ج.م');
        }
      }
    }

    buffer.writeln('────────────────');
    buffer.writeln('💰 <b>صافي النقدية بالدرج:</b> <u>${c.netCashAfterExpenses.toStringAsFixed(2)} ج.م</u>');
    buffer.writeln('<b>حالة الوردية:</b> تم تقفيل الوردية بنجاح ✅');

    return buffer.toString();
  }
}
