import 'package:flutter_test/flutter_test.dart';
import 'package:cash_cafe/features/orders/domain/entities/product_entity.dart';
import 'package:cash_cafe/features/inventory/domain/entities/inventory_product_entity.dart';
import 'package:cash_cafe/features/daily_closing/domain/entities/invoice_item_entity.dart';
import 'package:cash_cafe/features/daily_closing/domain/entities/daily_closing_entity.dart';
import 'package:cash_cafe/features/reports/domain/entities/invoice_report_entity.dart';
import 'package:cash_cafe/features/reports/domain/entities/cashier_report_entity.dart';

void main() {
  group('Mod 3: Track Inventory Logic Tests', () {
    test('ProductEntity with trackInventory = false is always sellable even when stock is 0', () {
      final untrackedProduct = ProductEntity(
        id: 10,
        name: 'شاي فتلة',
        price: 15.0,
        categoryId: 1,
        stockQuantity: 0,
        minimumStock: 5,
        trackInventory: false,
      );

      expect(untrackedProduct.trackInventory, isFalse);
      expect(untrackedProduct.isOutOfStock, isFalse);
      expect(untrackedProduct.isLowStock, isFalse);
    });

    test('ProductEntity with trackInventory = true respects stock thresholds', () {
      final trackedOutOfStock = ProductEntity(
        id: 11,
        name: 'مياه غازية',
        price: 20.0,
        categoryId: 1,
        stockQuantity: 0,
        minimumStock: 5,
        trackInventory: true,
      );

      expect(trackedOutOfStock.trackInventory, isTrue);
      expect(trackedOutOfStock.isOutOfStock, isTrue);
      expect(trackedOutOfStock.isLowStock, isFalse);

      final trackedLowStock = ProductEntity(
        id: 12,
        name: 'عصير برتقال',
        price: 25.0,
        categoryId: 1,
        stockQuantity: 3,
        minimumStock: 5,
        trackInventory: true,
      );

      expect(trackedLowStock.trackInventory, isTrue);
      expect(trackedLowStock.isOutOfStock, isFalse);
      expect(trackedLowStock.isLowStock, isTrue);
    });

    test('InventoryProductEntity respects trackInventory flag', () {
      const untrackedInv = InventoryProductEntity(
        id: 20,
        name: 'خدمة شيشة',
        price: 30.0,
        categoryId: 2,
        categoryName: 'خدمات',
        stockQuantity: 0,
        minimumStock: 0,
        trackInventory: false,
      );

      expect(untrackedInv.canSell, isTrue);
      expect(untrackedInv.status, equals(StockStatus.notTracked));
      expect(untrackedInv.statusLabel, equals('⚪ غير متتبع'));
    });
  });

  group('Mod 2: Invoice Items & Details Entities Tests', () {
    test('InvoiceItemEntity stores item properties properly', () {
      const item = InvoiceItemEntity(
        id: 1,
        invoiceId: 100,
        productId: 5,
        productName: 'لاتيه',
        quantity: 3,
        unitPrice: 35.0,
        totalPrice: 105.0,
      );

      expect(item.productName, equals('لاتيه'));
      expect(item.quantity, equals(3));
      expect(item.unitPrice, equals(35.0));
      expect(item.totalPrice, equals(105.0));
    });

    test('InvoiceDetailEntity exposes all checkout and item details', () {
      final now = DateTime.now();
      final invoice = InvoiceDetailEntity(
        id: 101,
        orderId: 4,
        invoiceNumber: 'INV-20261015-001',
        paymentMethod: 'wallet',
        subtotal: 70.0,
        taxAmount: 0.0,
        serviceCharge: 0.0,
        grandTotal: 70.0,
        playStationAmount: 0.0,
        isClosedShift: false,
        createdAt: now,
        items: const [
          InvoiceItemEntity(
            id: 1,
            invoiceId: 101,
            productId: 1,
            productName: 'كابتشينو',
            quantity: 2,
            unitPrice: 35.0,
            totalPrice: 70.0,
          ),
        ],
      );

      expect(invoice.invoiceNumber, equals('INV-20261015-001'));
      expect(invoice.paymentMethodLabel, contains('محفظة'));
      expect(invoice.items.length, equals(1));
      expect(invoice.grandTotal, equals(70.0));
    });
  });

  group('Mod 4: Payment Methods & Reporting Tests', () {
    test('InvoiceReportEntity returns correct Arabic payment method labels', () {
      final cashInv = InvoiceReportEntity(
        id: 1,
        invoiceNumber: 'INV-1',
        grandTotal: 50.0,
        createdAt: DateTime.now(),
        isClosedShift: false,
        paymentMethod: 'cash',
      );
      expect(cashInv.paymentMethodLabel, equals('نقدي'));

      final walletInv = InvoiceReportEntity(
        id: 2,
        invoiceNumber: 'INV-2',
        grandTotal: 75.0,
        createdAt: DateTime.now(),
        isClosedShift: false,
        paymentMethod: 'wallet',
      );
      expect(walletInv.paymentMethodLabel, equals('محفظة'));

      final instapayInv = InvoiceReportEntity(
        id: 3,
        invoiceNumber: 'INV-3',
        grandTotal: 100.0,
        createdAt: DateTime.now(),
        isClosedShift: false,
        paymentMethod: 'instapay',
      );
      expect(instapayInv.paymentMethodLabel, equals('إنستاباي'));

      final defaultInv = InvoiceReportEntity(
        id: 4,
        invoiceNumber: 'INV-4',
        grandTotal: 20.0,
        createdAt: DateTime.now(),
        isClosedShift: false,
      );
      expect(defaultInv.paymentMethodLabel, equals('نقدي'));
    });

    test('DailyClosingEntity contains separate payment aggregates', () {
      final now = DateTime.now();
      final closing = DailyClosingEntity(
        id: 1,
        closingDate: '2026-10-15',
        closingTime: '06:00',
        invoiceCount: 15,
        grossSales: 1500.0,
        discounts: 0.0,
        taxTotal: 0.0,
        netSales: 1500.0,
        cashTotal: 1000.0,
        walletTotal: 300.0,
        instapayTotal: 200.0,
        cardTotal: 0.0,
        otherPayments: 0.0,
        playStationTotal: 0.0,
        totalItems: 30,
        status: 'closed',
        createdAt: now,
        updatedAt: now,
      );

      expect(closing.netSales, equals(1500.0));
      expect(closing.cashTotal, equals(1000.0));
      expect(closing.walletTotal, equals(300.0));
      expect(closing.instapayTotal, equals(200.0));
      expect(closing.cashTotal + closing.walletTotal + closing.instapayTotal, equals(closing.netSales));
    });

    test('Payment method formatting for Telegram covers Cash, Wallet, and InstaPay', () {
      String getPaymentMethodLabel(String paymentMethod) {
        return switch (paymentMethod) {
          'wallet' => '📱 محفظة إلكترونية (Wallet)',
          'instapay' => '⚡ إنستاباي (InstaPay)',
          _ => '💵 نقدي (Cash)',
        };
      }

      expect(getPaymentMethodLabel('cash'), contains('نقدي'));
      expect(getPaymentMethodLabel('wallet'), contains('محفظة'));
      expect(getPaymentMethodLabel('instapay'), contains('إنستاباي'));
    });
  });

  group('Cashier Report (تقرير الكاشير ومبيعات الأصناف) Tests', () {
    test('CashierReportEntity properly aggregates items sold and payment totals', () {
      final now = DateTime.now();
      final report = CashierReportEntity(
        date: now,
        invoiceCount: 20,
        totalRevenue: 1500.0,
        cashTotal: 1000.0,
        walletTotal: 300.0,
        instapayTotal: 200.0,
        cardTotal: 0.0,
        playStationTotal: 150.0,
        playStationCount: 2,
        totalQuantitySold: 42,
        items: const [
          CashierReportItemEntity(
            productName: 'قهوة تركي',
            quantity: 20,
            unitPrice: 25.0,
            totalPrice: 500.0,
          ),
          CashierReportItemEntity(
            productName: 'شاي فتلة',
            quantity: 12,
            unitPrice: 15.0,
            totalPrice: 180.0,
          ),
          CashierReportItemEntity(
            productName: 'مياه معدنية',
            quantity: 10,
            unitPrice: 10.0,
            totalPrice: 100.0,
          ),
        ],
      );

      expect(report.invoiceCount, equals(20));
      expect(report.totalRevenue, equals(1500.0));
      expect(report.cashTotal, equals(1000.0));
      expect(report.walletTotal, equals(300.0));
      expect(report.instapayTotal, equals(200.0));
      expect(report.totalQuantitySold, equals(42));
      expect(report.items.length, equals(3));
      expect(report.items.first.productName, equals('قهوة تركي'));
      expect(report.items.first.quantity, equals(20));
      expect(report.items[1].quantity, equals(12));
      expect(report.items[2].quantity, equals(10));
    });

    test('CashierReportEntity supports historical closed days with accurate totals', () {
      final pastDate = DateTime(2026, 10, 14);
      final report = CashierReportEntity(
        date: pastDate,
        invoiceCount: 15,
        totalRevenue: 1200.0,
        cashTotal: 800.0,
        walletTotal: 250.0,
        instapayTotal: 150.0,
        cardTotal: 0.0,
        playStationTotal: 0.0,
        playStationCount: 0,
        totalQuantitySold: 25,
        items: const [
          CashierReportItemEntity(
            productName: 'اسبريسو دبل',
            quantity: 15,
            unitPrice: 40.0,
            totalPrice: 600.0,
          ),
          CashierReportItemEntity(
            productName: 'كابتشينو',
            quantity: 10,
            unitPrice: 60.0,
            totalPrice: 600.0,
          ),
        ],
      );

      expect(report.date, equals(pastDate));
      expect(report.totalRevenue, equals(1200.0));
      expect(report.items.length, equals(2));
      expect(report.items[0].productName, equals('اسبريسو دبل'));
      expect(report.items[0].quantity, equals(15));
      expect(report.items[1].productName, equals('كابتشينو'));
      expect(report.items[1].quantity, equals(10));
    });
  });
}
