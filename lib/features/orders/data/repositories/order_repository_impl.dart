import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/order_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  final AppDatabase db;

  OrderRepositoryImpl(this.db);

  @override
  Future<List<CategoryEntity>> getCategories() async {
    final driftCategories = await db.select(db.categories).get();
    return driftCategories
        .map((c) => CategoryEntity(id: c.id, name: c.name))
        .toList();
  }

  @override
  Future<List<ProductEntity>> getProducts() async {
    final driftProducts = await db.select(db.products).get();
    return driftProducts
        .map((p) => ProductEntity(
              id: p.id,
              name: p.name,
              price: p.price,
              categoryId: p.categoryId,
              hasAddons: p.hasAddons,
              stockQuantity: p.stockQuantity,
              minimumStock: p.minimumStock,
            ))
        .toList();
  }

  @override
  Future<OrderEntity?> getActiveOrderForTable(int? tableId,
      {String orderType = 'dine_in'}) async {
    final orderQuery = db.select(db.orders)
      ..where((o) => o.status.equals('active'))
      ..where((o) => o.orderType.equals(orderType));

    if (tableId != null) {
      orderQuery.where((o) => o.tableId.equals(tableId));
    } else {
      orderQuery.where((o) => o.tableId.isNull());
    }

    orderQuery.limit(1);
    final order = await orderQuery.getSingleOrNull();
    if (order == null) return null;

    final itemsQuery = db.select(db.orderItems).join([
      innerJoin(db.products, db.products.id.equalsExp(db.orderItems.productId)),
    ])
      ..where(db.orderItems.orderId.equals(order.id));

    final itemsResult = await itemsQuery.get();

    final orderItems = itemsResult.map((row) {
      final item = row.readTable(db.orderItems);
      final product = row.readTable(db.products);
      return OrderItemEntity(
        id: item.id,
        productId: item.productId,
        productName: product.name,
        unitPrice: item.unitPrice,
        quantity: item.quantity,
      );
    }).toList();

    return OrderEntity(
      id: order.id,
      tableId: order.tableId,
      status: order.status,
      orderType: order.orderType,
      items: orderItems,
    );
  }

  @override
  Future<void> addItemToOrder(int? tableId, ProductEntity product, int quantity,
      {String orderType = 'dine_in'}) async {
    return db.transaction(() async {
      final orderQuery = db.select(db.orders)
        ..where((o) => o.status.equals('active'))
        ..where((o) => o.orderType.equals(orderType));

      if (tableId != null) {
        orderQuery.where((o) => o.tableId.equals(tableId));
      } else {
        orderQuery.where((o) => o.tableId.isNull());
      }

      orderQuery.limit(1);
      var order = await orderQuery.getSingleOrNull();

      if (order == null) {
        if (tableId != null) {
          await (db.update(db.systemTables)
                ..where((t) => t.id.equals(tableId)))
              .write(const SystemTablesCompanion(status: Value('busy')));
        }

        final newOrderId = await db.into(db.orders).insert(
              OrdersCompanion.insert(
                tableId: Value(tableId),
                status: const Value('active'),
                orderType: Value(orderType),
              ),
            );
        final newOrderQuery = db.select(db.orders)
          ..where((o) => o.id.equals(newOrderId));
        order = await newOrderQuery.getSingle();
      }

      final itemQuery = db.select(db.orderItems)
        ..where((i) => i.orderId.equals(order!.id))
        ..where((i) => i.productId.equals(product.id))
        ..limit(1);

      final existingItem = await itemQuery.getSingleOrNull();

      if (existingItem != null) {
        final newQuantity = existingItem.quantity + quantity;
        await (db.update(db.orderItems)
              ..where((i) => i.id.equals(existingItem.id)))
            .write(OrderItemsCompanion(
          quantity: Value(newQuantity),
          totalPrice: Value(newQuantity * existingItem.unitPrice),
        ));
      } else {
        await db.into(db.orderItems).insert(
              OrderItemsCompanion.insert(
                orderId: order.id,
                productId: product.id,
                quantity: Value(quantity),
                unitPrice: product.price,
                totalPrice: product.price * quantity,
              ),
            );
      }

      await _updateOrderSubtotal(order.id);
    });
  }

  @override
  Future<void> updateOrderItemQuantity(int orderItemId, int newQuantity) async {
    return db.transaction(() async {
      final item = await (db.select(db.orderItems)
            ..where((i) => i.id.equals(orderItemId)))
          .getSingle();

      if (newQuantity <= 0) {
        await removeItemFromOrder(orderItemId);
      } else {
        await (db.update(db.orderItems)
              ..where((i) => i.id.equals(orderItemId)))
            .write(OrderItemsCompanion(
          quantity: Value(newQuantity),
          totalPrice: Value(newQuantity * item.unitPrice),
        ));
        await _updateOrderSubtotal(item.orderId);
      }
    });
  }

  @override
  Future<void> removeItemFromOrder(int orderItemId) async {
    return db.transaction(() async {
      final item = await (db.select(db.orderItems)
            ..where((i) => i.id.equals(orderItemId)))
          .getSingle();
      await (db.delete(db.orderItems)
            ..where((i) => i.id.equals(orderItemId)))
          .go();
      await _updateOrderSubtotal(item.orderId);
    });
  }

  @override
  Future<void> updateOrderStatus(int orderId, String status) async {
    await (db.update(db.orders)..where((o) => o.id.equals(orderId)))
        .write(OrdersCompanion(status: Value(status)));
  }

  // Task 4: Cancel ALL active orders/items for a table, then free the table
  @override
  Future<void> cancelTableOrder(int tableId) async {
    return db.transaction(() async {
      // Find all active orders for this table
      final activeOrders = await (db.select(db.orders)
            ..where((o) => o.tableId.equals(tableId))
            ..where((o) => o.status.equals('active')))
          .get();

      for (final order in activeOrders) {
        // Delete all items in this order
        await (db.delete(db.orderItems)
              ..where((i) => i.orderId.equals(order.id)))
            .go();
        // Mark order as cancelled
        await (db.update(db.orders)..where((o) => o.id.equals(order.id)))
            .write(const OrdersCompanion(status: Value('cancelled')));
      }

      // Free the table
      await (db.update(db.systemTables)
            ..where((t) => t.id.equals(tableId)))
          .write(const SystemTablesCompanion(status: Value('free')));
    });
  }

  Future<void> _updateOrderSubtotal(int orderId) async {
    final subtotalResult = await db.customSelect(
      'SELECT SUM(total_price) as sum FROM order_items WHERE order_id = ?',
      variables: [Variable.withInt(orderId)],
    ).getSingle();

    final subtotal = subtotalResult.read<double?>('sum') ?? 0.0;

    await (db.update(db.orders)..where((o) => o.id.equals(orderId)))
        .write(OrdersCompanion(subtotal: Value(subtotal)));
  }
}
