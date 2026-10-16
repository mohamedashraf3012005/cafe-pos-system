import 'package:flutter_test/flutter_test.dart';
import 'package:cash_cafe/core/services/printer_service.dart';
import 'package:cash_cafe/features/orders/domain/entities/order_entity.dart';
import 'package:cash_cafe/features/daily_closing/domain/entities/invoice_item_entity.dart';
import 'package:cash_cafe/features/reports/domain/entities/cashier_report_entity.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PrinterService printerService;

  setUp(() {
    printerService = PrinterService();
  });

  test('PrinterService builds customer receipt document successfully', () async {
    final order = OrderEntity(
      id: 1,
      orderType: 'dine_in',
      tableId: 5,
      status: 'completed',
      items: [
        OrderItemEntity(
          id: 1,
          productId: 101,
          productName: 'قهوة تركي',
          unitPrice: 20.0,
          quantity: 2,
        ),
        OrderItemEntity(
          id: 2,
          productId: 102,
          productName: 'شاي أخضر بالنعناع',
          unitPrice: 15.0,
          quantity: 1,
        ),
      ],
    );

    final doc = await printerService.buildReceiptDocument(
      order,
      0.0, // serviceChargeRate
      0.0, // taxRate
      0.0, // serviceCharge
      0.0, // tax
      55.0, // grandTotal
      5, // tableNumber
      101, // orderNumber
      paymentMethod: 'cash',
    );

    expect(doc, isNotNull);
    final bytes = await doc.save();
    expect(bytes.isNotEmpty, isTrue);
  });

  test('PrinterService builds cashier shift report document successfully', () async {
    final report = CashierReportEntity(
      date: DateTime.now(),
      invoiceCount: 15,
      cashTotal: 850.0,
      walletTotal: 250.0,
      instapayTotal: 400.0,
      cardTotal: 0.0,
      totalRevenue: 1500.0,
      totalQuantitySold: 42,
      items: [
        CashierReportItemEntity(
          productName: 'قهوة تركي',
          quantity: 27,
          unitPrice: 20.0,
          totalPrice: 540.0,
        ),
        CashierReportItemEntity(
          productName: 'شاي بالحليب',
          quantity: 15,
          unitPrice: 15.0,
          totalPrice: 225.0,
        ),
      ],
      playStationTotal: 120.0,
      playStationCount: 2,
    );

    final doc = await printerService.buildCashierReportDocument(report);
    expect(doc, isNotNull);
    final bytes = await doc.save();
    expect(bytes.isNotEmpty, isTrue);
  });

  test('PrinterService builds kitchen receipt document successfully', () async {
    final items = [
      OrderItemEntity(
        id: 1,
        productId: 1,
        productName: 'قهوة تركي',
        unitPrice: 20.0,
        quantity: 2,
      ),
    ];

    final doc = await printerService.buildKitchenReceiptDocument(
      items,
      3,
      'dine_in',
    );
    expect(doc, isNotNull);
    final bytes = await doc.save();
    expect(bytes.isNotEmpty, isTrue);
  });

  test('PrinterService builds historical receipt reprint document successfully', () async {
    final invoice = InvoiceDetailEntity(
      id: 1,
      orderId: 10,
      invoiceNumber: 'INV-2026-001',
      subtotal: 75.0,
      taxAmount: 0.0,
      serviceCharge: 0.0,
      grandTotal: 75.0,
      paymentMethod: 'cash',
      isClosedShift: false,
      createdAt: DateTime.now(),
      playStationAmount: 0.0,
      items: [
        InvoiceItemEntity(
          id: 1,
          invoiceId: 1,
          productId: 10,
          productName: 'موكا مثلج',
          unitPrice: 35.0,
          quantity: 2,
          totalPrice: 70.0,
        ),
      ],
    );

    final doc = await printerService.buildHistoricalReceiptDocument(invoice);
    expect(doc, isNotNull);
    final bytes = await doc.save();
    expect(bytes.isNotEmpty, isTrue);
  });
}
