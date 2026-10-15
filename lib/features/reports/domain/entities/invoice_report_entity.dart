class InvoiceReportEntity {
  final int id;
  final String invoiceNumber;
  final double grandTotal;
  final DateTime createdAt;
  final bool isClosedShift;
  final String paymentMethod;

  const InvoiceReportEntity({
    required this.id,
    required this.invoiceNumber,
    required this.grandTotal,
    required this.createdAt,
    required this.isClosedShift,
    this.paymentMethod = 'cash',
  });

  String get paymentMethodLabel {
    switch (paymentMethod) {
      case 'wallet':
        return 'محفظة';
      case 'instapay':
        return 'إنستاباي';
      case 'card':
        return 'بطاقة';
      case 'cash':
      default:
        return 'نقدي';
    }
  }
}
