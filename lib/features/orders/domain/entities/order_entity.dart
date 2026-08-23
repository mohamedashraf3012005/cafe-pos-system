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
  final double playStationCost;
  final String? playStationDescription;
  final int? playStationSessionId;

  double get itemsSubtotal => items.fold(0.0, (sum, item) => sum + item.totalPrice);
  double get subtotal => itemsSubtotal + playStationCost;

  OrderEntity({
    required this.id,
    this.tableId,
    required this.status,
    this.orderType = 'dine_in',
    required this.items,
    this.playStationCost = 0.0,
    this.playStationDescription,
    this.playStationSessionId,
  });

  OrderEntity copyWith({
    int? id,
    int? tableId,
    String? status,
    String? orderType,
    List<OrderItemEntity>? items,
    double? playStationCost,
    String? playStationDescription,
    int? playStationSessionId,
  }) {
    return OrderEntity(
      id: id ?? this.id,
      tableId: tableId ?? this.tableId,
      status: status ?? this.status,
      orderType: orderType ?? this.orderType,
      items: items ?? this.items,
      playStationCost: playStationCost ?? this.playStationCost,
      playStationDescription: playStationDescription ?? this.playStationDescription,
      playStationSessionId: playStationSessionId ?? this.playStationSessionId,
    );
  }
}
