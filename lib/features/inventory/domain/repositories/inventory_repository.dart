import '../entities/inventory_product_entity.dart';
import '../entities/inventory_movement_entity.dart';

abstract class InventoryRepository {
  /// Get all inventory products with category names
  Future<List<InventoryProductEntity>> getInventoryProducts();

  /// Get inventory product by ID
  Future<InventoryProductEntity?> getInventoryProductById(int productId);

  /// Add stock quantity to a product
  Future<void> addStock({
    required int productId,
    required int quantity,
    String? reason,
  });

  /// Remove stock quantity manually (e.g. damaged, internal use, lost)
  Future<void> removeStock({
    required int productId,
    required int quantity,
    required String reason,
  });

  /// Adjust stock quantity to an exact new value
  Future<void> adjustStock({
    required int productId,
    required int newQuantity,
    String? reason,
  });

  /// Update minimum stock threshold
  Future<void> updateMinimumStock({
    required int productId,
    required int minimumStock,
  });

  /// Deduct stock for sale inside transaction
  Future<void> deductStockForSale({
    required int productId,
    required int quantity,
  });

  /// Return stock for returned product
  Future<void> returnStock({
    required int productId,
    required int quantity,
    String? reason,
  });

  /// Get movement history for all products or a specific product
  Future<List<InventoryMovementEntity>> getMovements({
    int? productId,
    DateTime? from,
    DateTime? to,
    String? movementType,
    int limit = 100,
  });

  /// Get inventory report summary
  Future<Map<String, dynamic>> getInventorySummary();
}
