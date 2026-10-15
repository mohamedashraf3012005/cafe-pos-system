import 'package:drift/drift.dart';
import 'package:cash_cafe/core/database/app_database.dart';
import 'package:cash_cafe/features/inventory/domain/entities/inventory_movement_entity.dart';
import 'package:cash_cafe/features/inventory/domain/entities/inventory_product_entity.dart';
import 'package:cash_cafe/features/inventory/domain/repositories/inventory_repository.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  final AppDatabase db;

  InventoryRepositoryImpl(this.db);

  @override
  Future<List<InventoryProductEntity>> getInventoryProducts() async {
    final query = db.select(db.products).join([
      innerJoin(db.categories, db.categories.id.equalsExp(db.products.categoryId)),
    ])..orderBy([OrderingTerm.asc(db.products.name)]);

    final rows = await query.get();
    return rows.map((row) {
      final p = row.readTable(db.products);
      final c = row.readTable(db.categories);
      return InventoryProductEntity(
        id: p.id,
        name: p.name,
        price: p.price,
        categoryId: p.categoryId,
        categoryName: c.name,
        stockQuantity: p.stockQuantity,
        minimumStock: p.minimumStock,
        trackInventory: p.trackInventory,
      );
    }).toList();
  }

  @override
  Future<InventoryProductEntity?> getInventoryProductById(int productId) async {
    final query = db.select(db.products).join([
      innerJoin(db.categories, db.categories.id.equalsExp(db.products.categoryId)),
    ])..where(db.products.id.equals(productId));

    final row = await query.getSingleOrNull();
    if (row == null) return null;

    final p = row.readTable(db.products);
    final c = row.readTable(db.categories);
    return InventoryProductEntity(
      id: p.id,
      name: p.name,
      price: p.price,
      categoryId: p.categoryId,
      categoryName: c.name,
      stockQuantity: p.stockQuantity,
      minimumStock: p.minimumStock,
      trackInventory: p.trackInventory,
    );
  }

  @override
  Future<void> addStock({
    required int productId,
    required int quantity,
    String? reason,
  }) async {
    if (quantity <= 0) throw Exception('الكمية المضافة يجب أن تكون أكبر من الصفر');

    return db.transaction(() async {
      final product = await (db.select(db.products)..where((p) => p.id.equals(productId))).getSingle();
      final prevStock = product.stockQuantity;
      final newStock = prevStock + quantity;

      await (db.update(db.products)..where((p) => p.id.equals(productId))).write(
        ProductsCompanion(stockQuantity: Value(newStock)),
      );

      await db.into(db.inventoryMovements).insert(
            InventoryMovementsCompanion.insert(
              productId: productId,
              quantity: quantity,
              movementType: 'stock_in',
              previousQuantity: prevStock,
              newQuantity: newStock,
              reason: Value(reason ?? 'إضافة كمية للمخزون'),
              createdAt: Value(DateTime.now()),
            ),
          );
    });
  }

  @override
  Future<void> removeStock({
    required int productId,
    required int quantity,
    required String reason,
  }) async {
    if (quantity <= 0) throw Exception('الكمية المسحوبة يجب أن تكون أكبر من الصفر');

    return db.transaction(() async {
      final product = await (db.select(db.products)..where((p) => p.id.equals(productId))).getSingle();
      final prevStock = product.stockQuantity;

      if (prevStock < quantity) {
        throw Exception('الكمية المتوفرة في المخزون ($prevStock) أقل من الكمية المطلوبة سحبها ($quantity)');
      }

      final newStock = prevStock - quantity;

      await (db.update(db.products)..where((p) => p.id.equals(productId))).write(
        ProductsCompanion(stockQuantity: Value(newStock)),
      );

      await db.into(db.inventoryMovements).insert(
            InventoryMovementsCompanion.insert(
              productId: productId,
              quantity: quantity,
              movementType: 'manual_remove',
              previousQuantity: prevStock,
              newQuantity: newStock,
              reason: Value(reason),
              createdAt: Value(DateTime.now()),
            ),
          );
    });
  }

  @override
  Future<void> adjustStock({
    required int productId,
    required int newQuantity,
    String? reason,
  }) async {
    if (newQuantity < 0) throw Exception('لا يمكن أن يكون المخزون سالباً');

    return db.transaction(() async {
      final product = await (db.select(db.products)..where((p) => p.id.equals(productId))).getSingle();
      final prevStock = product.stockQuantity;
      final diff = (newQuantity - prevStock).abs();

      await (db.update(db.products)..where((p) => p.id.equals(productId))).write(
        ProductsCompanion(stockQuantity: Value(newQuantity)),
      );

      await db.into(db.inventoryMovements).insert(
            InventoryMovementsCompanion.insert(
              productId: productId,
              quantity: diff,
              movementType: 'adjustment',
              previousQuantity: prevStock,
              newQuantity: newQuantity,
              reason: Value(reason ?? 'تعديل يدوي للمخزون'),
              createdAt: Value(DateTime.now()),
            ),
          );
    });
  }

  @override
  Future<void> updateMinimumStock({
    required int productId,
    required int minimumStock,
  }) async {
    if (minimumStock < 0) throw Exception('الحد الأدنى لا يمكن أن يكون سالباً');

    await (db.update(db.products)..where((p) => p.id.equals(productId))).write(
      ProductsCompanion(minimumStock: Value(minimumStock)),
    );
  }

  @override
  Future<void> deductStockForSale({
    required int productId,
    required int quantity,
  }) async {
    final product = await (db.select(db.products)..where((p) => p.id.equals(productId))).getSingle();
    final prevStock = product.stockQuantity;

    if (prevStock < quantity) {
      throw Exception('الكمية غير متوفرة في المخزون للمنتج "${product.name}". المتاح حاليًا: $prevStock');
    }

    final newStock = prevStock - quantity;

    await (db.update(db.products)..where((p) => p.id.equals(productId))).write(
      ProductsCompanion(stockQuantity: Value(newStock)),
    );

    await db.into(db.inventoryMovements).insert(
          InventoryMovementsCompanion.insert(
            productId: productId,
            quantity: quantity,
            movementType: 'sale',
            previousQuantity: prevStock,
            newQuantity: newStock,
            reason: const Value('مبيعات فاتورة'),
            createdAt: Value(DateTime.now()),
          ),
        );
  }

  @override
  Future<void> returnStock({
    required int productId,
    required int quantity,
    String? reason,
  }) async {
    if (quantity <= 0) return;

    return db.transaction(() async {
      final product = await (db.select(db.products)..where((p) => p.id.equals(productId))).getSingle();
      final prevStock = product.stockQuantity;
      final newStock = prevStock + quantity;

      await (db.update(db.products)..where((p) => p.id.equals(productId))).write(
        ProductsCompanion(stockQuantity: Value(newStock)),
      );

      await db.into(db.inventoryMovements).insert(
            InventoryMovementsCompanion.insert(
              productId: productId,
              quantity: quantity,
              movementType: 'return',
              previousQuantity: prevStock,
              newQuantity: newStock,
              reason: Value(reason ?? 'مرتجع مبيعات'),
              createdAt: Value(DateTime.now()),
            ),
          );
    });
  }

  @override
  Future<List<InventoryMovementEntity>> getMovements({
    int? productId,
    DateTime? from,
    DateTime? to,
    String? movementType,
    int limit = 100,
  }) async {
    final query = db.select(db.inventoryMovements).join([
      innerJoin(db.products, db.products.id.equalsExp(db.inventoryMovements.productId)),
    ]);

    if (productId != null) {
      query.where(db.inventoryMovements.productId.equals(productId));
    }
    if (from != null) {
      query.where(db.inventoryMovements.createdAt.isBiggerOrEqualValue(from));
    }
    if (to != null) {
      query.where(db.inventoryMovements.createdAt.isSmallerOrEqualValue(to));
    }
    if (movementType != null) {
      query.where(db.inventoryMovements.movementType.equals(movementType));
    }

    query
      ..orderBy([OrderingTerm.desc(db.inventoryMovements.createdAt)])
      ..limit(limit);

    final rows = await query.get();
    return rows.map((row) {
      final m = row.readTable(db.inventoryMovements);
      final p = row.readTable(db.products);
      return InventoryMovementEntity(
        id: m.id,
        productId: m.productId,
        productName: p.name,
        quantity: m.quantity,
        movementType: m.movementType,
        previousQuantity: m.previousQuantity,
        newQuantity: m.newQuantity,
        reason: m.reason,
        createdAt: m.createdAt,
      );
    }).toList();
  }

  @override
  Future<Map<String, dynamic>> getInventorySummary() async {
    final products = await getInventoryProducts();
    final movements = await getMovements(limit: 1000);

    final totalProducts = products.length;
    final inStock = products.where((p) => p.status == StockStatus.inStock).length;
    final lowStock = products.where((p) => p.status == StockStatus.lowStock).length;
    final outOfStock = products.where((p) => p.status == StockStatus.outOfStock).length;

    int totalSold = 0;
    int totalAdded = 0;
    int totalRemoved = 0;

    for (final m in movements) {
      if (m.movementType == 'sale') totalSold += m.quantity;
      if (m.movementType == 'stock_in') totalAdded += m.quantity;
      if (m.movementType == 'manual_remove') totalRemoved += m.quantity;
    }

    return {
      'totalProducts': totalProducts,
      'inStock': inStock,
      'lowStock': lowStock,
      'outOfStock': outOfStock,
      'totalSold': totalSold,
      'totalAdded': totalAdded,
      'totalRemoved': totalRemoved,
    };
  }
}