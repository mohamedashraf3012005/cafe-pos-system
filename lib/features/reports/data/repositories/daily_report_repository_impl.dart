import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/invoice_report_entity.dart';
import '../../domain/entities/cashier_report_entity.dart';
import '../../domain/repositories/daily_report_repository.dart';

class DailyReportRepositoryImpl implements DailyReportRepository {
  final AppDatabase db;

  DailyReportRepositoryImpl(this.db);

  @override
  Future<List<InvoiceReportEntity>> getOpenShiftInvoices() async {
    final rows = await (db.select(db.invoices)
          ..where((inv) => inv.isClosedShift.equals(false))
          ..orderBy([(inv) => OrderingTerm.desc(inv.createdAt)]))
        .get();

    return rows
        .map((inv) => InvoiceReportEntity(
              id: inv.id,
              invoiceNumber: inv.invoiceNumber,
              grandTotal: inv.grandTotal,
              createdAt: inv.createdAt,
              isClosedShift: inv.isClosedShift,
              paymentMethod: inv.paymentMethod,
            ))
        .toList();
  }

  @override
  Future<void> closeShift() async {
    await (db.update(db.invoices)
          ..where((inv) => inv.isClosedShift.equals(false)))
        .write(const InvoicesCompanion(isClosedShift: Value(true)));
  }

  @override
  Future<CashierReportEntity> getCashierReport({DateTime? date, String? dateStr}) async {
    final DateTime targetDate;
    final bool isHistorical = date != null || dateStr != null;

    if (date != null) {
      targetDate = date;
    } else if (dateStr != null) {
      final parts = dateStr.split('-');
      if (parts.length == 3) {
        final y = int.tryParse(parts[0]) ?? 2026;
        final m = int.tryParse(parts[1]) ?? 1;
        final d = int.tryParse(parts[2]) ?? 1;
        targetDate = DateTime(y, m, d);
      } else {
        targetDate = DateTime.tryParse(dateStr) ?? DateTime.now();
      }
    } else {
      targetDate = DateTime.now();
    }

    final List<Invoice> targetInvoices;
    if (isHistorical) {
      final startOfDay = DateTime(targetDate.year, targetDate.month, targetDate.day);
      final endOfDay = DateTime(targetDate.year, targetDate.month, targetDate.day, 23, 59, 59, 999);

      targetInvoices = await (db.select(db.invoices)
            ..where((inv) =>
                inv.createdAt.isBiggerOrEqualValue(startOfDay) &
                inv.createdAt.isSmallerOrEqualValue(endOfDay))
            ..orderBy([(inv) => OrderingTerm.asc(inv.createdAt)]))
          .get();
    } else {
      targetInvoices = await (db.select(db.invoices)
            ..where((inv) => inv.isClosedShift.equals(false))
            ..orderBy([(inv) => OrderingTerm.asc(inv.createdAt)]))
          .get();
    }

    if (targetInvoices.isEmpty) {
      // Check if a daily closing record exists for this date
      final targetDateFormatted = '${targetDate.year}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')}';
      final closingRow = await (db.select(db.dailyClosings)
            ..where((d) => d.closingDate.equals(targetDateFormatted)))
          .getSingleOrNull();

      if (closingRow != null) {
        return CashierReportEntity(
          date: targetDate,
          invoiceCount: closingRow.invoiceCount,
          totalRevenue: closingRow.netSales,
          cashTotal: closingRow.cashTotal,
          walletTotal: closingRow.walletTotal,
          instapayTotal: closingRow.instapayTotal,
          cardTotal: closingRow.cardTotal,
          playStationTotal: closingRow.playStationTotal,
          playStationCount: 0,
          totalQuantitySold: closingRow.totalItems,
          items: const [],
        );
      }

      return CashierReportEntity(
        date: targetDate,
        invoiceCount: 0,
        totalRevenue: 0.0,
        cashTotal: 0.0,
        walletTotal: 0.0,
        instapayTotal: 0.0,
        cardTotal: 0.0,
        playStationTotal: 0.0,
        playStationCount: 0,
        totalQuantitySold: 0,
        items: const [],
      );
    }

    double totalRevenue = 0.0;
    double cashTotal = 0.0;
    double walletTotal = 0.0;
    double instapayTotal = 0.0;
    double cardTotal = 0.0;
    double playStationTotal = 0.0;
    int playStationCount = 0;

    final invoiceIds = <int>[];

    for (final inv in targetInvoices) {
      totalRevenue += inv.grandTotal;
      invoiceIds.add(inv.id);

      if (inv.playStationAmount > 0) {
        playStationTotal += inv.playStationAmount;
        playStationCount++;
      }

      final method = inv.paymentMethod.toLowerCase();
      if (method == 'wallet') {
        walletTotal += inv.grandTotal;
      } else if (method == 'instapay') {
        instapayTotal += inv.grandTotal;
      } else if (method == 'card') {
        cardTotal += inv.grandTotal;
      } else {
        cashTotal += inv.grandTotal;
      }
    }

    // Query InvoiceItems
    final savedItems = await (db.select(db.invoiceItems)
          ..where((item) => item.invoiceId.isIn(invoiceIds)))
        .get();

    // Map to aggregate by product name: productName -> {quantity, totalAmount, unitPrice}
    final Map<String, _ItemAggregator> aggregatedItems = {};

    for (final item in savedItems) {
      final name = item.productName;
      if (!aggregatedItems.containsKey(name)) {
        aggregatedItems[name] = _ItemAggregator(
          productName: name,
          quantity: item.quantity,
          unitPrice: item.unitPrice,
          totalPrice: item.totalPrice,
        );
      } else {
        final existing = aggregatedItems[name]!;
        existing.quantity += item.quantity;
        existing.totalPrice += item.totalPrice;
      }
    }

    // For any invoices that didn't have InvoiceItems (e.g. legacy), fetch from orderItems joined with products
    final coveredInvoiceIds = savedItems.map((e) => e.invoiceId).toSet();
    final uncoveredInvoices = targetInvoices.where((inv) => !coveredInvoiceIds.contains(inv.id)).toList();

    if (uncoveredInvoices.isNotEmpty) {
      final uncoveredOrderIds = uncoveredInvoices.map((inv) => inv.orderId).toList();
      try {
        final query = db.select(db.orderItems).join([
          innerJoin(db.products, db.products.id.equalsExp(db.orderItems.productId)),
        ])..where(db.orderItems.orderId.isIn(uncoveredOrderIds));

        final rows = await query.get();
        for (final row in rows) {
          final orderItem = row.readTable(db.orderItems);
          final product = row.readTable(db.products);
          final name = product.name;

          if (!aggregatedItems.containsKey(name)) {
            aggregatedItems[name] = _ItemAggregator(
              productName: name,
              quantity: orderItem.quantity,
              unitPrice: orderItem.unitPrice,
              totalPrice: orderItem.totalPrice,
            );
          } else {
            final existing = aggregatedItems[name]!;
            existing.quantity += orderItem.quantity;
            existing.totalPrice += orderItem.totalPrice;
          }
        }
      } catch (_) {}
    }

    // Convert to list of CashierReportItemEntity sorted descending by quantity
    final reportItems = aggregatedItems.values.map((agg) => CashierReportItemEntity(
      productName: agg.productName,
      quantity: agg.quantity,
      unitPrice: agg.quantity > 0 ? agg.totalPrice / agg.quantity : agg.unitPrice,
      totalPrice: agg.totalPrice,
    )).toList()
      ..sort((a, b) => b.quantity.compareTo(a.quantity));

    final totalQuantity = reportItems.fold<int>(0, (sum, i) => sum + i.quantity);

    return CashierReportEntity(
      date: targetDate,
      invoiceCount: targetInvoices.length,
      totalRevenue: totalRevenue,
      cashTotal: cashTotal,
      walletTotal: walletTotal,
      instapayTotal: instapayTotal,
      cardTotal: cardTotal,
      playStationTotal: playStationTotal,
      playStationCount: playStationCount,
      totalQuantitySold: totalQuantity,
      items: reportItems,
    );
  }
}

class _ItemAggregator {
  final String productName;
  int quantity;
  double unitPrice;
  double totalPrice;

  _ItemAggregator({
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });
}

