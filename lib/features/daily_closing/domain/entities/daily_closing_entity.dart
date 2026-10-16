/// Immutable snapshot of a shift's financials captured at closing time.
class DailyClosingEntity {
  final int id;
  final String closingDate; // yyyy-MM-dd
  final String closingTime; // HH:mm
  final int invoiceCount;
  final double grossSales;
  final double discounts;
  final double taxTotal;
  final double netSales;
  final double cashTotal;
  final double walletTotal;
  final double instapayTotal;
  final double cardTotal;
  final double otherPayments;
  final double playStationTotal;
  final double expensesTotal;
  final int totalItems;
  final String status; // 'open' | 'closed'
  final DateTime createdAt;
  final DateTime updatedAt;

  double get netCashAfterExpenses => cashTotal - expensesTotal;
  double get netRevenueAfterExpenses => netSales - expensesTotal;

  const DailyClosingEntity({
    required this.id,
    required this.closingDate,
    required this.closingTime,
    required this.invoiceCount,
    required this.grossSales,
    required this.discounts,
    required this.taxTotal,
    required this.netSales,
    required this.cashTotal,
    this.walletTotal = 0.0,
    this.instapayTotal = 0.0,
    required this.cardTotal,
    required this.otherPayments,
    this.playStationTotal = 0.0,
    this.expensesTotal = 0.0,
    required this.totalItems,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isClosed => status == 'closed';
}
