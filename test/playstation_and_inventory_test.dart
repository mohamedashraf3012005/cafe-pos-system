import 'package:flutter_test/flutter_test.dart';
import 'package:cash_cafe/features/playstation/domain/entities/playstation_session_entity.dart';
import 'package:cash_cafe/features/inventory/domain/entities/inventory_product_entity.dart';
import 'package:cash_cafe/features/inventory/domain/entities/inventory_movement_entity.dart';
import 'package:cash_cafe/features/orders/domain/entities/order_entity.dart';

void main() {
  group('PlayStation Timer & Calculation Tests', () {
    test('Calculates cost accurately based on minutes elapsed', () {
      final startTime = DateTime.now().subtract(const Duration(minutes: 90)); // 1.5 hours
      final endTime = DateTime.now();

      final session = PlayStationSessionEntity(
        id: 1,
        tableId: 2,
        deviceId: 1,
        deviceName: 'PlayStation 5',
        startTime: startTime,
        endTime: endTime,
        hourlyRate: 50.0, // 50 EGP per hour
        calculatedAmount: 0.0,
        status: 'completed',
        createdAt: startTime,
      );

      // 1.5 hours * 50 EGP/hr = 75.0 EGP
      expect(session.currentCost, closeTo(75.0, 0.01));
      expect(session.humanDuration, equals('1 ساعة و30 دقيقة'));
      expect(session.isCompleted, isTrue);
      expect(session.isActive, isFalse);
    });

    test('30 minutes session cost calculation', () {
      final startTime = DateTime.now().subtract(const Duration(minutes: 30));
      final endTime = DateTime.now();

      final session = PlayStationSessionEntity(
        id: 2,
        tableId: 1,
        deviceId: 1,
        deviceName: 'PlayStation 4',
        startTime: startTime,
        endTime: endTime,
        hourlyRate: 40.0, // 40 EGP per hour
        calculatedAmount: 0.0,
        status: 'completed',
        createdAt: startTime,
      );

      // 0.5 hours * 40 EGP = 20 EGP
      expect(session.currentCost, closeTo(20.0, 0.01));
      expect(session.humanDuration, equals('30 دقيقة'));
    });
  });

  group('Inventory Domain Logic Tests', () {
    test('StockStatus correctly identifies inStock, lowStock, and outOfStock', () {
      const inStockProduct = InventoryProductEntity(
        id: 1,
        name: 'Cola',
        price: 20.0,
        categoryId: 1,
        categoryName: 'Drinks',
        stockQuantity: 15,
        minimumStock: 5,
      );
      expect(inStockProduct.status, equals(StockStatus.inStock));
      expect(inStockProduct.canSell, isTrue);

      const lowStockProduct = InventoryProductEntity(
        id: 2,
        name: 'Water',
        price: 10.0,
        categoryId: 1,
        categoryName: 'Drinks',
        stockQuantity: 4,
        minimumStock: 5,
      );
      expect(lowStockProduct.status, equals(StockStatus.lowStock));
      expect(lowStockProduct.canSell, isTrue);

      const outOfStockProduct = InventoryProductEntity(
        id: 3,
        name: 'Red Bull',
        price: 50.0,
        categoryId: 1,
        categoryName: 'Drinks',
        stockQuantity: 0,
        minimumStock: 5,
      );
      expect(outOfStockProduct.status, equals(StockStatus.outOfStock));
      expect(outOfStockProduct.canSell, isFalse);
    });

    test('Inventory movement types formatted correctly', () {
      final movement = InventoryMovementEntity(
        id: 1,
        productId: 1,
        productName: 'Cola',
        quantity: 5,
        movementType: 'stock_in',
        previousQuantity: 10,
        newQuantity: 15,
        reason: 'شراء جديد',
        createdAt: DateTime.now(),
      );

      expect(movement.movementTypeLabel, contains('إضافة'));
    });
  });

  group('Order & PlayStation Integration Tests', () {
    test('OrderEntity subtotal includes drinks items + PlayStation cost', () {
      final order = OrderEntity(
        id: 1,
        tableId: 3,
        status: 'active',
        items: [
          OrderItemEntity(id: 1, productId: 1, productName: 'Espresso', unitPrice: 25.0, quantity: 2), // 50
          OrderItemEntity(id: 2, productId: 2, productName: 'Water', unitPrice: 10.0, quantity: 1),    // 10
        ],
        playStationCost: 75.0,
        playStationDescription: 'PlayStation 5 (1 ساعة و30 دقيقة)',
      );

      expect(order.itemsSubtotal, equals(60.0));
      expect(order.playStationCost, equals(75.0));
      expect(order.subtotal, equals(135.0));
    });
  });
}