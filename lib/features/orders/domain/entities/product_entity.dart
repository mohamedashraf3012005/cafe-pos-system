class ProductEntity {
  final int id;
  final String name;
  final double price;
  final int categoryId;
  final bool hasAddons;
  final int stockQuantity;
  final int minimumStock;
  final bool trackInventory;

  ProductEntity({
    required this.id,
    required this.name,
    required this.price,
    required this.categoryId,
    this.hasAddons = false,
    this.stockQuantity = 0,
    this.minimumStock = 0,
    this.trackInventory = true,
  });

  bool get isOutOfStock => trackInventory && stockQuantity <= 0;
  bool get isLowStock => trackInventory && stockQuantity > 0 && stockQuantity <= minimumStock;
}
