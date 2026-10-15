import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../../orders/domain/entities/category_entity.dart';
import '../../../orders/domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final AppDatabase db;

  ProductRepositoryImpl(this.db);

  @override
  Future<List<CategoryEntity>> getCategories() async {
    final rows = await db.select(db.categories).get();
    return rows.map((c) => CategoryEntity(id: c.id, name: c.name)).toList();
  }

  @override
  Future<List<ProductEntity>> getProducts() async {
    final rows = await db.select(db.products).get();
    return rows
        .map((p) => ProductEntity(
              id: p.id,
              name: p.name,
              price: p.price,
              categoryId: p.categoryId,
              hasAddons: p.hasAddons,
              stockQuantity: p.stockQuantity,
              minimumStock: p.minimumStock,
              trackInventory: p.trackInventory,
            ))
        .toList();
  }

  @override
  Future<void> addProduct(String name, double price, int categoryId, {bool trackInventory = true}) async {
    await db.into(db.products).insert(
          ProductsCompanion.insert(
            name: name,
            price: price,
            categoryId: categoryId,
            trackInventory: Value(trackInventory),
          ),
        );
  }

  @override
  Future<void> updateProduct(int id, String name, double price, int categoryId, {bool? trackInventory}) async {
    await (db.update(db.products)..where((p) => p.id.equals(id))).write(
      ProductsCompanion(
        name: Value(name),
        price: Value(price),
        categoryId: Value(categoryId),
        trackInventory: trackInventory != null ? Value(trackInventory) : const Value.absent(),
      ),
    );
  }

  @override
  Future<void> deleteProduct(int id) async {
    // Delete any order items referencing this product first
    await (db.delete(db.orderItems)..where((i) => i.productId.equals(id))).go();
    // Then delete the product
    await (db.delete(db.products)..where((p) => p.id.equals(id))).go();
  }

  @override
  Future<void> addCategory(String name) async {
    await db.into(db.categories).insert(
          CategoriesCompanion.insert(name: name),
        );
  }

  @override
  Future<void> updateCategory(int id, String name) async {
    await (db.update(db.categories)..where((c) => c.id.equals(id))).write(
      CategoriesCompanion(name: Value(name)),
    );
  }

  @override
  Future<void> deleteCategory(int id) async {
    // Check if category has products
    final productsInCategory = await (db.select(db.products)
          ..where((p) => p.categoryId.equals(id)))
        .get();

    if (productsInCategory.isNotEmpty) {
      throw Exception('لا يمكن حذف هذه الفئة لأنها تحتوي على منتجات');
    }

    await (db.delete(db.categories)..where((c) => c.id.equals(id))).go();
  }
}
