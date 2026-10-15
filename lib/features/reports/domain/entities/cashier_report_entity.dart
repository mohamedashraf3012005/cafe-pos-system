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

class CashierReportEntity {
  final DateTime date;
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

  const CashierReportEntity({
    required this.date,
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
  });
}
