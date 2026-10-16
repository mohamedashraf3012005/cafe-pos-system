import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../features/orders/domain/entities/order_entity.dart';
import '../../features/daily_closing/domain/entities/invoice_item_entity.dart';
import '../../features/reports/domain/entities/cashier_report_entity.dart';

class PrinterService {
  // Cache the selected printer once per session
  Printer? _selectedPrinter;

  // Cache Arabic fonts
  pw.Font? _cachedArabicFont;
  pw.Font? _cachedArabicBoldFont;

  // 80mm thermal roll with ultra-safe margins:
  // Standard 80mm paper roll has a printable width of 64mm-72mm depending on the printer mechanism.
  // Setting _hMarginMm to 12.0mm leaves a safe empty 12mm on both left and right sides.
  // The content is strictly centered within 56mm (158.7 pt), guaranteeing zero cutoff on any POS printer.
  static const double _paperWidthMm = 80.0;
  static const double _hMarginMm = 12.0;
  static const double _vMarginMm = 3.0;

  static final PdfPageFormat _receiptFormat = PdfPageFormat(
    _paperWidthMm * PdfPageFormat.mm,
    double.infinity,
    marginLeft: _hMarginMm * PdfPageFormat.mm,
    marginRight: _hMarginMm * PdfPageFormat.mm,
    marginTop: _vMarginMm * PdfPageFormat.mm,
    marginBottom: _vMarginMm * PdfPageFormat.mm,
  );

  /// Auto-detect the default system printer.
  Future<bool> selectPrinter() async {
    try {
      final printers = await Printing.listPrinters();
      if (printers.isNotEmpty) {
        final defaultPrinter =
            printers.where((p) => p.isDefault).firstOrNull;
        if (defaultPrinter != null) {
          _selectedPrinter = defaultPrinter;
          return true;
        }
        _selectedPrinter = printers.first;
        return true;
      }
    } catch (_) {}
    return false;
  }

  String? get selectedPrinterName => _selectedPrinter?.name;

  /// Load & cache Arabic fonts from local assets (no internet required)
  Future<void> _loadFonts() async {
    if (_cachedArabicFont != null && _cachedArabicBoldFont != null) return;
    try {
      final regularData = await rootBundle.load('assets/fonts/Cairo-Regular.ttf');
      final boldData = await rootBundle.load('assets/fonts/Cairo-Bold.ttf');
      _cachedArabicFont = pw.Font.ttf(regularData);
      _cachedArabicBoldFont = pw.Font.ttf(boldData);
    } catch (e) {
      _cachedArabicFont = pw.Font.helvetica();
      _cachedArabicBoldFont = pw.Font.helveticaBold();
    }
  }

  /// Sends the built document to the printer.
  Future<void> _sendToPrinter(pw.Document doc, String jobName) async {
    if (_selectedPrinter == null) {
      final picked = await selectPrinter();
      if (!picked) {
        throw Exception(
            'لا توجد طابعة متصلة. تأكد من توصيل الطابعة وتعيينها كطابعة افتراضية في إعدادات ويندوز.');
      }
    }

    final result = await Printing.directPrintPdf(
      printer: _selectedPrinter!,
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: jobName,
      format: _receiptFormat,
    );

    if (!result) {
      _selectedPrinter = null;
      throw Exception('فشل الطباعة. سيتم إعادة اختيار الطابعة في المرة القادمة.');
    }
  }

  String _paymentMethodLabel(String method) {
    switch (method.toLowerCase()) {
      case 'wallet':
        return 'محفظة إلكترونية';
      case 'instapay':
        return 'إنستاباي';
      case 'card':
        return 'بطاقة';
      case 'cash':
      default:
        return 'نقدي';
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 1. CUSTOMER RECEIPT (فاتورة العميل)
  // ─────────────────────────────────────────────────────────────────────────

  Future<pw.Document> buildReceiptDocument(
    OrderEntity order,
    double serviceChargeRate,
    double taxRate,
    double serviceCharge,
    double tax,
    double grandTotal,
    int? tableNumber,
    int orderNumber, {
    String paymentMethod = 'cash',
  }) async {
    await _loadFonts();
    final baseFont = _cachedArabicFont!;
    final boldFont = _cachedArabicBoldFont!;
    final now = DateTime.now();

    final isTakeaway = order.orderType == 'takeaway';
    final orderTypeBadge = isTakeaway
        ? 'طلب سفري (تيك أواي)'
        : 'طلب صالة (طاولة ${tableNumber ?? order.tableId})';

    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: _receiptFormat,
        textDirection: pw.TextDirection.rtl,
        theme: pw.ThemeData.withFont(base: baseFont, bold: boldFont),
        build: (pw.Context ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // Header
              _buildHeader(
                baseFont: baseFont,
                boldFont: boldFont,
                badgeTitle: 'فاتورة ضيافة',
                subtitleBadge: orderTypeBadge,
                orderNumberBadge: 'طلب #$orderNumber',
              ),
              pw.SizedBox(height: 2),

              // Metadata info
              _infoRow('التاريخ:', _formatDate(now), baseFont),
              _infoRow('الوقت:', _formatTime(now), baseFont),
              _infoRow('طريقة الدفع:', _paymentMethodLabel(paymentMethod), baseFont, isBold: true, boldFont: boldFont),
              pw.SizedBox(height: 2),

              // Items Table Header
              _tableHeader(boldFont, priceLabel: 'الإجمالي'),
              pw.SizedBox(height: 1),

              // Items
              ...order.items.map((item) => _tableRow(
                    name: item.productName,
                    quantity: item.quantity,
                    price: item.totalPrice,
                    baseFont: baseFont,
                    boldFont: boldFont,
                  )),

              // PlayStation item if present
              if (order.playStationCost > 0)
                _tableRow(
                  name: order.playStationDescription ?? 'جلسة بلايستيشن',
                  quantity: 1,
                  price: order.playStationCost,
                  baseFont: baseFont,
                  boldFont: boldFont,
                ),

              pw.SizedBox(height: 2),
              _dashedDivider(),
              pw.SizedBox(height: 1),

              // Financial breakdown
              _amountRow('المجموع الفرعي:', order.subtotal, baseFont),
              if (serviceChargeRate > 0)
                _amountRow(
                  'خدمة ${(serviceChargeRate * 100).toStringAsFixed(0)}%:',
                  serviceCharge,
                  baseFont,
                ),
              if (taxRate > 0)
                _amountRow(
                  'ضريبة ${(taxRate * 100).toStringAsFixed(0)}%:',
                  tax,
                  baseFont,
                ),

              // Grand Total Box
              _grandTotalBox('الإجمالي النهائي', grandTotal, boldFont),

              // Footer
              _buildFooter(baseFont, boldFont),
            ],
          );
        },
      ),
    );

    return doc;
  }

  Future<void> printReceipt(
    OrderEntity order,
    double serviceChargeRate,
    double taxRate,
    double serviceCharge,
    double tax,
    double grandTotal,
    int? tableNumber,
    int orderNumber, {
    String paymentMethod = 'cash',
  }) async {
    final doc = await buildReceiptDocument(
      order,
      serviceChargeRate,
      taxRate,
      serviceCharge,
      tax,
      grandTotal,
      tableNumber,
      orderNumber,
      paymentMethod: paymentMethod,
    );
    await _sendToPrinter(doc, 'Receipt_Order_$orderNumber');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 2. HISTORICAL RECEIPT REPRINT (إعادة طباعة فاتورة)
  // ─────────────────────────────────────────────────────────────────────────

  Future<pw.Document> buildHistoricalReceiptDocument(InvoiceDetailEntity invoice) async {
    await _loadFonts();
    final baseFont = _cachedArabicFont!;
    final boldFont = _cachedArabicBoldFont!;

    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: _receiptFormat,
        textDirection: pw.TextDirection.rtl,
        theme: pw.ThemeData.withFont(base: baseFont, bold: boldFont),
        build: (pw.Context ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              _buildHeader(
                baseFont: baseFont,
                boldFont: boldFont,
                badgeTitle: '— إعادة طباعة فاتورة —',
                orderNumberBadge: 'فاتورة #${invoice.invoiceNumber}',
              ),
              pw.SizedBox(height: 2),

              _infoRow('التاريخ:', _formatDate(invoice.createdAt), baseFont),
              _infoRow('الوقت:', _formatTime(invoice.createdAt), baseFont),
              _infoRow('طريقة الدفع:', invoice.paymentMethodLabel, baseFont, isBold: true, boldFont: boldFont),
              pw.SizedBox(height: 2),

              _tableHeader(boldFont, priceLabel: 'الإجمالي'),
              pw.SizedBox(height: 1),

              if (invoice.items.isNotEmpty)
                ...invoice.items.map((item) => _tableRow(
                      name: item.productName,
                      quantity: item.quantity,
                      price: item.totalPrice,
                      baseFont: baseFont,
                      boldFont: boldFont,
                    ))
              else
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 4),
                  child: pw.Center(
                    child: pw.Text(
                      '(تفاصيل الأصناف غير متوفرة لهذه الفاتورة)',
                      style: pw.TextStyle(font: baseFont, fontSize: 6.5, color: PdfColors.grey700),
                    ),
                  ),
                ),

              if (invoice.playStationAmount > 0)
                _tableRow(
                  name: 'جلسة بلايستيشن',
                  quantity: 1,
                  price: invoice.playStationAmount,
                  baseFont: baseFont,
                  boldFont: boldFont,
                ),

              pw.SizedBox(height: 2),
              _dashedDivider(),
              pw.SizedBox(height: 1),

              _amountRow('المجموع الفرعي:', invoice.subtotal, baseFont),
              if (invoice.serviceCharge > 0)
                _amountRow('خدمة:', invoice.serviceCharge, baseFont),
              if (invoice.taxAmount > 0)
                _amountRow('ضريبة:', invoice.taxAmount, baseFont),

              _grandTotalBox('الإجمالي النهائي', invoice.grandTotal, boldFont),

              _buildFooter(baseFont, boldFont, note: 'نسخة مطبوعة من السجل'),
            ],
          );
        },
      ),
    );

    return doc;
  }

  Future<void> printHistoricalReceipt(InvoiceDetailEntity invoice) async {
    final doc = await buildHistoricalReceiptDocument(invoice);
    await _sendToPrinter(doc, 'Reprint_${invoice.invoiceNumber}');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 3. KITCHEN RECEIPT (بون تشغيل المطبخ / البار)
  // ─────────────────────────────────────────────────────────────────────────

  Future<pw.Document> buildKitchenReceiptDocument(
    List<OrderItemEntity> items,
    int? tableNumber,
    String orderType,
  ) async {
    await _loadFonts();
    final baseFont = _cachedArabicFont!;
    final boldFont = _cachedArabicBoldFont!;
    final now = DateTime.now();

    final isTakeaway = orderType == 'takeaway';
    final targetBadge = isTakeaway
        ? 'طلب سفري (تيك أواي)'
        : 'طلب صالة (طاولة $tableNumber)';

    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: _receiptFormat,
        textDirection: pw.TextDirection.rtl,
        theme: pw.ThemeData.withFont(base: baseFont, bold: boldFont),
        build: (pw.Context ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              _thickDivider(),
              pw.SizedBox(height: 1.5),
              pw.Center(
                child: pw.Text(
                  '*** بون المطبخ والبار ***',
                  style: pw.TextStyle(font: boldFont, fontSize: 10),
                ),
              ),
              pw.SizedBox(height: 2),

              // Highlighted Order Location
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(vertical: 2.5, horizontal: 4),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.black, width: 0.8),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
                ),
                child: pw.Center(
                  child: pw.Text(
                    targetBadge,
                    style: pw.TextStyle(font: boldFont, fontSize: 8.5),
                  ),
                ),
              ),
              pw.SizedBox(height: 2),

              _infoRow('الوقت:', _formatTime(now), baseFont),
              _infoRow('التاريخ:', _formatDate(now), baseFont),
              pw.SizedBox(height: 2),

              // Column Headers (No Prices)
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(vertical: 2),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    top: pw.BorderSide(color: PdfColors.black, width: 0.6),
                    bottom: pw.BorderSide(color: PdfColors.black, width: 0.6),
                  ),
                ),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        'الصنف المطلوب',
                        style: pw.TextStyle(font: boldFont, fontSize: 7.5),
                      ),
                    ),
                    pw.SizedBox(
                      width: 28,
                      child: pw.Text(
                        'العدد',
                        style: pw.TextStyle(font: boldFont, fontSize: 7.5),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 1),

              // Items
              ...items.map((item) => pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Expanded(
                          child: pw.Text(
                            item.productName,
                            style: pw.TextStyle(font: baseFont, fontSize: 7.5),
                            softWrap: true,
                          ),
                        ),
                        pw.SizedBox(
                          width: 28,
                          child: pw.Text(
                            'x${item.quantity}',
                            style: pw.TextStyle(font: boldFont, fontSize: 8.5),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  )),

              pw.SizedBox(height: 3),
              _thickDivider(),
              pw.SizedBox(height: 2),
              pw.Center(
                child: pw.Text(
                  '— نهاية التذكرة —',
                  style: pw.TextStyle(font: baseFont, fontSize: 6.5),
                ),
              ),
              pw.SizedBox(height: 10),
            ],
          );
        },
      ),
    );

    return doc;
  }

  Future<void> printKitchenReceipt(
    List<OrderItemEntity> items,
    int? tableNumber,
    String orderType,
  ) async {
    final doc = await buildKitchenReceiptDocument(items, tableNumber, orderType);
    final now = DateTime.now();
    await _sendToPrinter(doc, 'Kitchen_${_formatTime(now).replaceAll(':', '')}');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 4. CASHIER SHIFT REPORT (تقرير مبيعات الكاشير)
  // ─────────────────────────────────────────────────────────────────────────

  Future<pw.Document> buildCashierReportDocument(CashierReportEntity report) async {
    await _loadFonts();
    final baseFont = _cachedArabicFont!;
    final boldFont = _cachedArabicBoldFont!;
    final now = DateTime.now();

    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: _receiptFormat,
        textDirection: pw.TextDirection.rtl,
        theme: pw.ThemeData.withFont(base: baseFont, bold: boldFont),
        build: (pw.Context ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              _buildHeader(
                baseFont: baseFont,
                boldFont: boldFont,
                badgeTitle: 'تقرير تقفيل الوردية',
                subtitleBadge: '${report.invoiceCount} فاتورة مسجلة',
              ),
              pw.SizedBox(height: 2),

              _infoRow('تاريخ الوردية:', _formatDate(report.date), baseFont),
              _infoRow('وقت التقرير:', _formatTime(now), baseFont),
              _infoRow('إجمالي القطع المباعة:', '${report.totalQuantitySold} قطعة', baseFont, isBold: true, boldFont: boldFont),
              pw.SizedBox(height: 2),

              // Payment Methods Summary Box
              _dashedDivider(),
              pw.SizedBox(height: 1),
              pw.Text(
                'ملخص طرق الدفع:',
                style: pw.TextStyle(font: boldFont, fontSize: 7.5),
              ),
              pw.SizedBox(height: 1.5),
              _amountRow('نقدي (Cash):', report.cashTotal, baseFont),
              _amountRow('محفظة (Wallet):', report.walletTotal, baseFont),
              _amountRow('إنستاباي (InstaPay):', report.instapayTotal, baseFont),
              if (report.cardTotal > 0)
                _amountRow('بطاقة (Card):', report.cardTotal, baseFont),

              // Expenses section if any
              if (report.expensesTotal > 0) ...[
                pw.SizedBox(height: 2),
                _dashedDivider(),
                pw.SizedBox(height: 1),
                pw.Text(
                  'مصروفات الوردية (${report.expenses.length} مصروف):',
                  style: pw.TextStyle(font: boldFont, fontSize: 7.5),
                ),
                pw.SizedBox(height: 1.5),
                ...report.expenses.map((exp) => pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 0.8),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Expanded(
                            child: pw.Text('• ${exp.reason}', style: pw.TextStyle(font: baseFont, fontSize: 7.0)),
                          ),
                          pw.Text('-${exp.amount.toStringAsFixed(2)} ج.م', style: pw.TextStyle(font: boldFont, fontSize: 7.0)),
                        ],
                      ),
                    )),
                pw.SizedBox(height: 1),
                _amountRow('إجمالي المصروفات:', report.expensesTotal, boldFont, isBold: true),
              ],

              pw.SizedBox(height: 2),
              _grandTotalBox('إجمالي مبيعات الوردية', report.totalRevenue, boldFont),
              if (report.expensesTotal > 0) ...[
                pw.SizedBox(height: 1.5),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2.5),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey200,
                    border: pw.Border.all(color: PdfColors.black, width: 0.8),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('صافي النقدية بالدرج:', style: pw.TextStyle(font: boldFont, fontSize: 7.5)),
                      pw.Text('${report.netCashAfterExpenses.toStringAsFixed(2)} ج.م', style: pw.TextStyle(font: boldFont, fontSize: 8.5)),
                    ],
                  ),
                ),
              ],
              pw.SizedBox(height: 2),

              // Sold Items Breakdown
              _doubleDivider(),
              pw.SizedBox(height: 1.5),
              pw.Text(
                'تفاصيل الأصناف المباعة (${report.totalQuantitySold} قطعة):',
                style: pw.TextStyle(font: boldFont, fontSize: 7.5),
              ),
              pw.SizedBox(height: 2),

              _tableHeader(boldFont, priceLabel: 'الإجمالي'),
              pw.SizedBox(height: 1),

              if (report.items.isEmpty)
                pw.Center(
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 4),
                    child: pw.Text(
                      'لا توجد مبيعات أصناف مسجلة',
                      style: pw.TextStyle(font: baseFont, fontSize: 7.0),
                    ),
                  ),
                )
              else
                ...report.items.map((item) => _tableRow(
                      name: item.productName,
                      quantity: item.quantity,
                      price: item.totalPrice,
                      baseFont: baseFont,
                      boldFont: boldFont,
                    )),

              // PlayStation Summary if any
              if (report.playStationTotal > 0) ...[
                pw.SizedBox(height: 2),
                _dashedDivider(),
                pw.SizedBox(height: 1),
                _amountRow(
                  'دخل البلايستيشن (${report.playStationCount} جلسة):',
                  report.playStationTotal,
                  baseFont,
                  isBold: true,
                  boldFont: boldFont,
                ),
              ],

              _buildFooter(baseFont, boldFont, note: 'تقرير إغلاق الوردية الرسمي'),
            ],
          );
        },
      ),
    );

    return doc;
  }

  Future<void> printCashierReport(CashierReportEntity report) async {
    final doc = await buildCashierReportDocument(report);
    final now = DateTime.now();
    await _sendToPrinter(doc, 'CashierReport_${_formatTime(now).replaceAll(':', '')}');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Helper Visual Components
  // ─────────────────────────────────────────────────────────────────────────

  pw.Widget _doubleDivider() {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2.0),
      child: pw.Column(
        children: [
          pw.Container(height: 0.8, color: PdfColors.black),
          pw.SizedBox(height: 1.0),
          pw.Container(height: 0.4, color: PdfColors.black),
        ],
      ),
    );
  }

  pw.Widget _dashedDivider() {
    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 2.0),
      child: pw.Divider(
        thickness: 0.6,
        color: PdfColors.black,
        borderStyle: pw.BorderStyle.dashed,
      ),
    );
  }

  pw.Widget _thickDivider() =>
      pw.Container(margin: const pw.EdgeInsets.symmetric(vertical: 2), height: 1.0, color: PdfColors.black);

  pw.Widget _buildHeader({
    required pw.Font baseFont,
    required pw.Font boldFont,
    required String badgeTitle,
    String? subtitleBadge,
    String? orderNumberBadge,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        _doubleDivider(),
        pw.SizedBox(height: 1.5),
        pw.Text(
          'بريسكا كافيه',
          style: pw.TextStyle(font: boldFont, fontSize: 11.0, letterSpacing: 0.3),
        ),
        pw.SizedBox(height: 0.5),
        pw.Text(
          'BRISKA CAFE',
          style: pw.TextStyle(font: baseFont, fontSize: 6.5, letterSpacing: 0.8),
        ),
        pw.SizedBox(height: 2),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.black, width: 0.7),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
          ),
          child: pw.Text(
            badgeTitle,
            style: pw.TextStyle(font: boldFont, fontSize: 7.5),
            textAlign: pw.TextAlign.center,
          ),
        ),
        if (subtitleBadge != null || orderNumberBadge != null) ...[
          pw.SizedBox(height: 2),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              if (orderNumberBadge != null)
                pw.Text(
                  orderNumberBadge,
                  style: pw.TextStyle(font: boldFont, fontSize: 7.5),
                ),
              if (subtitleBadge != null && orderNumberBadge != null)
                pw.Text('  •  ', style: pw.TextStyle(font: baseFont, fontSize: 6.5)),
              if (subtitleBadge != null)
                pw.Text(
                  subtitleBadge,
                  style: pw.TextStyle(font: boldFont, fontSize: 7.0),
                ),
            ],
          ),
        ],
        pw.SizedBox(height: 1.5),
        _doubleDivider(),
      ],
    );
  }

  pw.Widget _infoRow(
    String label,
    String value,
    pw.Font font, {
    bool isBold = false,
    pw.Font? boldFont,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1.0),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(font: font, fontSize: 7.0)),
          pw.Text(
            value,
            style: pw.TextStyle(
              font: isBold && boldFont != null ? boldFont : font,
              fontSize: 7.0,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _amountRow(
    String label,
    double amount,
    pw.Font font, {
    bool isBold = false,
    pw.Font? boldFont,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1.0),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              font: isBold && boldFont != null ? boldFont : font,
              fontSize: 7.0,
            ),
          ),
          pw.Text(
            '${amount.toStringAsFixed(2)} ج.م',
            style: pw.TextStyle(
              font: isBold && boldFont != null ? boldFont : font,
              fontSize: 7.0,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _tableHeader(pw.Font boldFont, {String priceLabel = 'الإجمالي'}) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 2.0),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: PdfColors.black, width: 0.6),
          bottom: pw.BorderSide(color: PdfColors.black, width: 0.6),
        ),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(
            flex: 5,
            child: pw.Text(
              'الصنف',
              style: pw.TextStyle(font: boldFont, fontSize: 7.5),
            ),
          ),
          pw.SizedBox(
            width: 24,
            child: pw.Text(
              'الكمية',
              style: pw.TextStyle(font: boldFont, fontSize: 7.5),
              textAlign: pw.TextAlign.center,
            ),
          ),
          pw.SizedBox(
            width: 38,
            child: pw.Text(
              priceLabel,
              style: pw.TextStyle(font: boldFont, fontSize: 7.5),
              textAlign: pw.TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _tableRow({
    required String name,
    required dynamic quantity,
    required double price,
    required pw.Font baseFont,
    required pw.Font boldFont,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1.2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            flex: 5,
            child: pw.Text(
              name,
              style: pw.TextStyle(font: baseFont, fontSize: 7.0),
              softWrap: true,
            ),
          ),
          pw.SizedBox(
            width: 24,
            child: pw.Text(
              '$quantity',
              style: pw.TextStyle(font: boldFont, fontSize: 7.0),
              textAlign: pw.TextAlign.center,
            ),
          ),
          pw.SizedBox(
            width: 38,
            child: pw.Text(
              price.toStringAsFixed(2),
              style: pw.TextStyle(font: baseFont, fontSize: 7.0),
              textAlign: pw.TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _grandTotalBox(String label, double grandTotal, pw.Font boldFont) {
    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 2.5),
      padding: const pw.EdgeInsets.symmetric(vertical: 3.0, horizontal: 5.0),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 0.9),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(font: boldFont, fontSize: 8.0),
          ),
          pw.Text(
            '${grandTotal.toStringAsFixed(2)} ج.م',
            style: pw.TextStyle(font: boldFont, fontSize: 9.0),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildFooter(
    pw.Font baseFont,
    pw.Font boldFont, {
    String note = 'شكراً لزيارتكم • نتمنى لكم يوماً سعيداً',
  }) {
    return pw.Column(
      children: [
        _dashedDivider(),
        pw.SizedBox(height: 1.5),
        pw.Center(
          child: pw.Text(
            note,
            style: pw.TextStyle(font: boldFont, fontSize: 6.5),
            textAlign: pw.TextAlign.center,
          ),
        ),
        pw.SizedBox(height: 1),
        pw.Center(
          child: pw.Text(
            'نظام كاشير بريسكا كافيه',
            style: pw.TextStyle(font: baseFont, fontSize: 5.8),
            textAlign: pw.TextAlign.center,
          ),
        ),
        pw.SizedBox(height: 8), // Paper cut clearance
      ],
    );
  }

  String _formatDate(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    return '${dt.year}/$m/$d';
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$h:$min';
  }
}
