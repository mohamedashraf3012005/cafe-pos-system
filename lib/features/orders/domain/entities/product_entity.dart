class ProductEntity {
  final int id;
  final String name;
  final double price;
  final int categoryId;
  final bool hasAddons;
  final int stockQuantity;
  final int minimumStock;

  ProductEntity({
    required this.id,
    required this.name,
    required this.price,
    required this.categoryId,
    this.hasAddons = false,
    this.stockQuantity = 0,
    this.minimumStock = 0,
  });

  bool get isOutOfStock => stockQuantity <= 0;
  bool get isLowStock => stockQuantity > 0 && stockQuantity <= minimumStock;
}
