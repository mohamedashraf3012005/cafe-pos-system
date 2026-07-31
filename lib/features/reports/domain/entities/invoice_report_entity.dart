class InvoiceReportEntity {
  final int id;
  final String invoiceNumber;
  final double grandTotal;
  final DateTime createdAt;
  final bool isClosedShift;

  const InvoiceReportEntity({
    required this.id,
    required this.invoiceNumber,
    required this.grandTotal,
    required this.createdAt,
    required this.isClosedShift,
  });
}
