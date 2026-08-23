enum StockStatus {
  inStock,    // متوفر
  lowStock,   // مخزون منخفض
  outOfStock, // نفد المخزون
}

class InventoryProductEntity {
  final int id;
  final String name;
  final double price;
  final int categoryId;
  final String categoryName;
  final int stockQuantity;
  final int minimumStock;

  const InventoryProductEntity({
    required this.id,
    required this.name,
    required this.price,
    required this.categoryId,
    required this.categoryName,
    required this.stockQuantity,
    required this.minimumStock,
  });

  StockStatus get status {
    if (stockQuantity <= 0) return StockStatus.outOfStock;
    if (stockQuantity <= minimumStock) return StockStatus.lowStock;
    return StockStatus.inStock;
  }

  String get statusLabel {
    switch (status) {
      case StockStatus.outOfStock:
        return '🔴 نفد المخزون';
      case StockStatus.lowStock:
        return '⚠️ مخزون منخفض';
      case StockStatus.inStock:
        return '🟢 متوفر';
    }
  }

  bool get canSell => stockQuantity > 0;
}