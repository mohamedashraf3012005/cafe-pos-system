import '../../../orders/domain/entities/category_entity.dart';
import '../../../orders/domain/entities/product_entity.dart';

abstract class ProductRepository {
  Future<List<CategoryEntity>> getCategories();
  Future<List<ProductEntity>> getProducts();
  Future<void> addProduct(String name, double price, int categoryId, {bool trackInventory = true});
  Future<void> updateProduct(int id, String name, double price, int categoryId, {bool? trackInventory});
  Future<void> deleteProduct(int id);
  Future<void> addCategory(String name);
  Future<void> updateCategory(int id, String name);
  Future<void> deleteCategory(int id);
}
