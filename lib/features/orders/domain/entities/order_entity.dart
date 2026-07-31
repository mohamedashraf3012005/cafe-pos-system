class OrderItemEntity {
  final int id;
  final int productId;
  final String productName;
  final double unitPrice;
  int quantity;
  double get totalPrice => unitPrice * quantity;

  OrderItemEntity({
    required this.id,
    required this.productId,
    required this.productName,
    required this.unitPrice,
    this.quantity = 1,
  });
}

class OrderEntity {
  final int id;
  final int? tableId;
  final String status;
  final String orderType;
  final List<OrderItemEntity> items;

  double get subtotal => items.fold(0, (sum, item) => sum + item.totalPrice);

  OrderEntity({
    required this.id,
    this.tableId,
    required this.status,
    this.orderType = 'dine_in',
    required this.items,
  });
}
