class InvoiceItemEntity {
  final int id;
  final int invoiceId;
  final int? productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  const InvoiceItemEntity({
    required this.id,
    required this.invoiceId,
    this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });
}

class InvoiceDetailEntity {
  final int id;
  final int orderId;
  final String invoiceNumber;
  final double subtotal;
  final double taxAmount;
  final double serviceCharge;
  final double grandTotal;
  final String paymentMethod;
  final double playStationAmount;
  final bool isClosedShift;
  final DateTime createdAt;
  final List<InvoiceItemEntity> items;

  const InvoiceDetailEntity({
    required this.id,
    required this.orderId,
    required this.invoiceNumber,
    required this.subtotal,
    required this.taxAmount,
    required this.serviceCharge,
    required this.grandTotal,
    required this.paymentMethod,
    this.playStationAmount = 0.0,
    required this.isClosedShift,
    required this.createdAt,
    required this.items,
  });

  String get paymentMethodLabel {
    switch (paymentMethod) {
      case 'wallet':
        return 'محفظة إلكترونية (Wallet)';
      case 'instapay':
        return 'إنستاباي (InstaPay)';
      case 'card':
        return 'بطاقة (Card)';
      case 'cash':
      default:
        return 'نقدي (Cash)';
    }
  }
}
