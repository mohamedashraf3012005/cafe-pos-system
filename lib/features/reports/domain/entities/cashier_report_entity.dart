class CashierReportItemEntity {
  final String productName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  const CashierReportItemEntity({
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });
}

class CashierExpenseItemEntity {
  final int? id;
  final String reason;
  final double amount;
  final DateTime createdAt;

  const CashierExpenseItemEntity({
    this.id,
    required this.reason,
    required this.amount,
    required this.createdAt,
  });
}

class CashierReportEntity {
  final DateTime date;
  final int? shiftClosingId;
  final String? shiftTime;
  final bool isOpenShift;
  final int invoiceCount;
  final double totalRevenue;
  final double cashTotal;
  final double walletTotal;
  final double instapayTotal;
  final double cardTotal;
  final double playStationTotal;
  final int playStationCount;
  final int totalQuantitySold;
  final List<CashierReportItemEntity> items;
  final double expensesTotal;
  final List<CashierExpenseItemEntity> expenses;

  double get netCashAfterExpenses => cashTotal - expensesTotal;
  double get netRevenueAfterExpenses => totalRevenue - expensesTotal;

  const CashierReportEntity({
    required this.date,
    this.shiftClosingId,
    this.shiftTime,
    this.isOpenShift = false,
    required this.invoiceCount,
    required this.totalRevenue,
    required this.cashTotal,
    required this.walletTotal,
    required this.instapayTotal,
    this.cardTotal = 0.0,
    required this.playStationTotal,
    required this.playStationCount,
    required this.totalQuantitySold,
    required this.items,
    this.expensesTotal = 0.0,
    this.expenses = const [],
  });
}
