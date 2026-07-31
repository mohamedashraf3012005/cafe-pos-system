class ProductEntity {
  final int id;
  final String name;
  final double price;
  final int categoryId;
  final bool hasAddons;

  ProductEntity({
    required this.id,
    required this.name,
    required this.price,
    required this.categoryId,
    this.hasAddons = false,
  });
}
