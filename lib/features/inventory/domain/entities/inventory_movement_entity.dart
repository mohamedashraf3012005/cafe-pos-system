class InventoryMovementEntity {
  final int id;
  final int productId;
  final String productName;
  final int quantity;
  /// 'stock_in' | 'sale' | 'manual_remove' | 'adjustment' | 'return'
  final String movementType;
  final int previousQuantity;
  final int newQuantity;
  final String? reason;
  final DateTime createdAt;

  const InventoryMovementEntity({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.movementType,
    required this.previousQuantity,
    required this.newQuantity,
    this.reason,
    required this.createdAt,
  });

  String get movementTypeLabel {
    switch (movementType) {
      case 'stock_in':
        return '📥 إضافة مخزون';
      case 'sale':
        return '🛒 مبيعات';
      case 'manual_remove':
        return '📤 سحب يدوي';
      case 'adjustment':
        return '⚙️ تعديل يدوي';
      case 'return':
        return '🔄 مرتجع';
      default:
        return movementType;
    }
  }
}