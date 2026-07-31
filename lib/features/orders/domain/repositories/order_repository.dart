import '../entities/category_entity.dart';
import '../entities/product_entity.dart';
import '../entities/order_entity.dart';

abstract class OrderRepository {
  Future<List<CategoryEntity>> getCategories();
  Future<List<ProductEntity>> getProducts();
  Future<OrderEntity?> getActiveOrderForTable(int? tableId, {String orderType = 'dine_in'});
  Future<void> addItemToOrder(int? tableId, ProductEntity product, int quantity, {String orderType = 'dine_in'});
  Future<void> updateOrderItemQuantity(int orderItemId, int quantity);
  Future<void> removeItemFromOrder(int orderItemId);
  Future<void> updateOrderStatus(int orderId, String status);
  // Task 4: cancel all active orders for a table and free it
  Future<void> cancelTableOrder(int tableId);
}
