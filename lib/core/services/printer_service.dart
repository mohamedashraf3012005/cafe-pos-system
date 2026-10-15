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

  // 80mm thermal roll (e.g. Xprinter XP-Q807K) — 4mm horizontal padding for safe printable area
  static const double _paperWidthMm = 80.0;
  static const double _hMarginMm = 4.0;
  static const double _vMarginMm = 2.0;

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
  // CUSTOMER RECEIPT (Full Invoice)
  // ─────────────────────────────────────────────────────────────────────────

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
          return pw.Padding(
            padding: pw.EdgeInsets.zero,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                _decorativeLine(),
                pw.SizedBox(height: 3),
                pw.Center(
                  child: pw.Text('بريسكا كافيه',
                      style: pw.TextStyle(font: boldFont, fontSize: 14)),
                ),
                pw.SizedBox(height: 1),
                pw.Center(
                  child: pw.Text('Briska Cafe',
                      style: pw.TextStyle(font: baseFont, fontSize: 8)),
                ),
                pw.SizedBox(height: 3),
                _decorativeLine(),
                pw.SizedBox(height: 3),

                _infoRow('نوع الطلب',
                    order.orderType == 'takeaway' ? 'تيك أواي' : 'داخلي', baseFont),
                if (order.orderType != 'takeaway')
                  _infoRow('الطاولة', '${tableNumber ?? order.tableId}', baseFont),
                _infoRow('رقم الطلب', '#$orderNumber', baseFont),
                _infoRow('طريقة الدفع', _paymentMethodLabel(paymentMethod), baseFont),
                _infoRow('التاريخ', _formatDate(now), baseFont),
                _infoRow('الوقت', _formatTime(now), baseFont),

                pw.SizedBox(height: 3),
                _thickDivider(),
                pw.SizedBox(height: 2),

                // Table header
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 2),
                  child: pw.Row(
                    children: [
                      pw.Expanded(
                        flex: 5,
                        child: pw.Text('الصنف',
                            style: pw.TextStyle(font: boldFont, fontSize: 8.5)),
                      ),
                      pw.SizedBox(
                        width: 28,
                        child: pw.Text('الكمية',
                            style: pw.TextStyle(font: boldFont, fontSize: 8.5),
                            textAlign: pw.TextAlign.center),
                      ),
                      pw.SizedBox(
                        width: 44,
                        child: pw.Text('السعر',
                            style: pw.TextStyle(font: boldFont, fontSize: 8.5),
                            textAlign: pw.TextAlign.left),
                      ),
                    ],
                  ),
                ),
                _thinDivider(),
                pw.SizedBox(height: 2),

                // Items
                ...order.items.map((item) => pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Expanded(
                            flex: 5,
                            child: pw.Text(
                              item.productName,
                              style: pw.TextStyle(font: baseFont, fontSize: 8.5),
                              softWrap: true,
                            ),
                          ),
                          pw.SizedBox(
                            width: 28,
                            child: pw.Text(
                              '${item.quantity}',
                              style: pw.TextStyle(font: baseFont, fontSize: 8.5),
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                          pw.SizedBox(
                            width: 44,
                            child: pw.Text(
                              item.totalPrice.toStringAsFixed(2),
                              style: pw.TextStyle(font: baseFont, fontSize: 8.5),
                              textAlign: pw.TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                    )),

                // PlayStation item if present
                if (order.playStationCost > 0)
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Expanded(
                          flex: 5,
                          child: pw.Text(
                            order.playStationDescription ?? 'جلسة بلايستيشن',
                            style: pw.TextStyle(font: baseFont, fontSize: 8.5),
                            softWrap: true,
                          ),
                        ),
                        pw.SizedBox(
                          width: 28,
                          child: pw.Text(
                            '1',
                            style: pw.TextStyle(font: baseFont, fontSize: 8.5),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.SizedBox(
                          width: 44,
                          child: pw.Text(
                            order.playStationCost.toStringAsFixed(2),
                            style: pw.TextStyle(font: baseFont, fontSize: 8.5),
                            textAlign: pw.TextAlign.left,
                          ),
                        ),
                      ],
                    ),
                  ),

                pw.SizedBox(height: 2),
                _thickDivider(),
                pw.SizedBox(height: 3),

                _amountRow('المجموع الفرعي', order.subtotal, baseFont),
                if (serviceChargeRate > 0)
                  _amountRow(
                      'خدمة ${(serviceChargeRate * 100).toStringAsFixed(0)}%',
                      serviceCharge,
                      baseFont),
                if (taxRate > 0)
                  _amountRow(
                      'ضريبة ${(taxRate * 100).toStringAsFixed(0)}%',
                      tax,
                      baseFont),

                pw.SizedBox(height: 3),
                _thinDivider(),
                pw.SizedBox(height: 3),

                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                      vertical: 4, horizontal: 6),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.black, width: 1.2),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('الإجمالي',
                          style:
                              pw.TextStyle(font: boldFont, fontSize: 11)),
                      pw.Text('${grandTotal.toStringAsFixed(2)} ج.م',
                          style:
                              pw.TextStyle(font: boldFont, fontSize: 12)),
                    ],
                  ),
                ),

                pw.SizedBox(height: 5),
                _decorativeLine(),
                pw.SizedBox(height: 3),
                pw.Center(
                    child: pw.Text('شكراً لزيارتكم',
                        style:
                            pw.TextStyle(font: boldFont, fontSize: 9))),
                pw.SizedBox(height: 1),
                pw.Center(
                    child: pw.Text('نتمنى لكم يوماً سعيداً',
                        style:
                            pw.TextStyle(font: baseFont, fontSize: 8))),
                pw.SizedBox(height: 3),
                _decorativeLine(),
                pw.SizedBox(height: 4),
              ],
            ),
          );
        },
      ),
    );

    await _sendToPrinter(doc, 'Receipt_Order_$orderNumber');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // HISTORICAL RECEIPT REPRINT (Modification 2 & 4)
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> printHistoricalReceipt(InvoiceDetailEntity invoice) async {
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
          return pw.Padding(
            padding: pw.EdgeInsets.zero,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                _decorativeLine(),
                pw.SizedBox(height: 3),
                pw.Center(
                  child: pw.Text('بريسكا كافيه',
                      style: pw.TextStyle(font: boldFont, fontSize: 14)),
                ),
                pw.SizedBox(height: 1),
                pw.Center(
                  child: pw.Text('Briska Cafe',
                      style: pw.TextStyle(font: baseFont, fontSize: 8)),
                ),
                pw.SizedBox(height: 2),
                pw.Center(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.black, width: 0.8),
                    ),
                    child: pw.Text('— إعادة طباعة فاتورة —',
                        style: pw.TextStyle(font: boldFont, fontSize: 8)),
                  ),
                ),
                pw.SizedBox(height: 3),
                _decorativeLine(),
                pw.SizedBox(height: 3),

                _infoRow('رقم الفاتورة', invoice.invoiceNumber, baseFont),
                _infoRow('طريقة الدفع', invoice.paymentMethodLabel, baseFont),
                _infoRow('التاريخ', _formatDate(invoice.createdAt), baseFont),
                _infoRow('الوقت', _formatTime(invoice.createdAt), baseFont),

                pw.SizedBox(height: 3),
                _thickDivider(),
                pw.SizedBox(height: 2),

                // Table header
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 2),
                  child: pw.Row(
                    children: [
                      pw.Expanded(
                        flex: 5,
                        child: pw.Text('الصنف',
                            style: pw.TextStyle(font: boldFont, fontSize: 8.5)),
                      ),
                      pw.SizedBox(
                        width: 28,
                        child: pw.Text('الكمية',
                            style: pw.TextStyle(font: boldFont, fontSize: 8.5),
                            textAlign: pw.TextAlign.center),
                      ),
                      pw.SizedBox(
                        width: 44,
                        child: pw.Text('السعر',
                            style: pw.TextStyle(font: boldFont, fontSize: 8.5),
                            textAlign: pw.TextAlign.left),
                      ),
                    ],
                  ),
                ),
                _thinDivider(),
                pw.SizedBox(height: 2),

                // Items list or graceful fallback for old invoices
                if (invoice.items.isNotEmpty)
                  ...invoice.items.map((item) => pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
                        child: pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Expanded(
                              flex: 5,
                              child: pw.Text(
                                item.productName,
                                style: pw.TextStyle(font: baseFont, fontSize: 8.5),
                                softWrap: true,
                              ),
                            ),
                            pw.SizedBox(
                              width: 28,
                              child: pw.Text(
                                '${item.quantity}',
                                style: pw.TextStyle(font: baseFont, fontSize: 8.5),
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                            pw.SizedBox(
                              width: 44,
                              child: pw.Text(
                                item.totalPrice.toStringAsFixed(2),
                                style: pw.TextStyle(font: baseFont, fontSize: 8.5),
                                textAlign: pw.TextAlign.left,
                              ),
                            ),
                          ],
                        ),
                      ))
                else
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 6),
                    child: pw.Center(
                      child: pw.Text(
                        '(تفاصيل الأصناف غير متوفرة لهذه الفاتورة القديمة)',
                        style: pw.TextStyle(font: baseFont, fontSize: 8, color: PdfColors.grey700),
                      ),
                    ),
                  ),

                // PlayStation item if recorded
                if (invoice.playStationAmount > 0)
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
                    child: pw.Row(
                      children: [
                        pw.Expanded(
                          flex: 5,
                          child: pw.Text('جلسة بلايستيشن',
                              style: pw.TextStyle(font: baseFont, fontSize: 8.5)),
                        ),
                        pw.SizedBox(
                          width: 28,
                          child: pw.Text('1',
                              style: pw.TextStyle(font: baseFont, fontSize: 8.5),
                              textAlign: pw.TextAlign.center),
                        ),
                        pw.SizedBox(
                          width: 44,
                          child: pw.Text(
                            invoice.playStationAmount.toStringAsFixed(2),
                            style: pw.TextStyle(font: baseFont, fontSize: 8.5),
                            textAlign: pw.TextAlign.left,
                          ),
                        ),
                      ],
                    ),
                  ),

                pw.SizedBox(height: 2),
                _thickDivider(),
                pw.SizedBox(height: 3),

                _amountRow('المجموع الفرعي', invoice.subtotal, baseFont),
                if (invoice.serviceCharge > 0)
                  _amountRow('خدمة', invoice.serviceCharge, baseFont),
                if (invoice.taxAmount > 0)
                  _amountRow('ضريبة', invoice.taxAmount, baseFont),

                pw.SizedBox(height: 3),
                _thinDivider(),
                pw.SizedBox(height: 3),

                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                      vertical: 4, horizontal: 6),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.black, width: 1.2),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('الإجمالي',
                          style:
                              pw.TextStyle(font: boldFont, fontSize: 11)),
                      pw.Text('${invoice.grandTotal.toStringAsFixed(2)} ج.م',
                          style:
                              pw.TextStyle(font: boldFont, fontSize: 12)),
                    ],
                  ),
                ),

                pw.SizedBox(height: 5),
                _decorativeLine(),
                pw.SizedBox(height: 3),
                pw.Center(
                    child: pw.Text('شكراً لزيارتكم',
                        style:
                            pw.TextStyle(font: boldFont, fontSize: 9))),
                pw.SizedBox(height: 1),
                pw.Center(
                    child: pw.Text('نتمنى لكم يوماً سعيداً',
                        style:
                            pw.TextStyle(font: baseFont, fontSize: 8))),
                pw.SizedBox(height: 3),
                _decorativeLine(),
                pw.SizedBox(height: 4),
              ],
            ),
          );
        },
      ),
    );

    await _sendToPrinter(doc, 'Reprint_${invoice.invoiceNumber}');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Task 3: KITCHEN RECEIPT — NO prices, just items + table + time
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> printKitchenReceipt(
    List<OrderItemEntity> items,
    int? tableNumber,
    String orderType,
  ) async {
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
              _thickDivider(),
              pw.SizedBox(height: 3),
              pw.Center(
                child: pw.Text(
                  '*** تذكرة المطبخ ***',
                  style: pw.TextStyle(font: boldFont, fontSize: 13),
                ),
              ),
              pw.SizedBox(height: 3),
              _thickDivider(),
              pw.SizedBox(height: 4),

              _infoRow(
                'نوع الطلب',
                orderType == 'takeaway' ? 'تيك أواي' : 'داخلي',
                boldFont,
              ),
              if (orderType != 'takeaway' && tableNumber != null)
                _infoRow('رقم الطاولة', '$tableNumber', boldFont),
              _infoRow('الوقت', _formatTime(now), baseFont),
              _infoRow('التاريخ', _formatDate(now), baseFont),

              pw.SizedBox(height: 4),
              _thinDivider(),
              pw.SizedBox(height: 3),

              // Column headers
              pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Text('الصنف',
                        style: pw.TextStyle(font: boldFont, fontSize: 9)),
                  ),
                  pw.SizedBox(
                    width: 36,
                    child: pw.Text('الكمية',
                        style: pw.TextStyle(font: boldFont, fontSize: 9),
                        textAlign: pw.TextAlign.center),
                  ),
                ],
              ),
              _thinDivider(),
              pw.SizedBox(height: 2),

              // Items — NO prices
              ...items.map((item) => pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 2),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Expanded(
                          child: pw.Text(
                            item.productName,
                            style: pw.TextStyle(font: baseFont, fontSize: 10),
                            softWrap: true,
                          ),
                        ),
                        pw.SizedBox(
                          width: 36,
                          child: pw.Text(
                            'x${item.quantity}',
                            style: pw.TextStyle(font: boldFont, fontSize: 10),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  )),

              pw.SizedBox(height: 4),
              _thickDivider(),
              pw.SizedBox(height: 2),
              pw.Center(
                child: pw.Text(
                  '— نهاية التذكرة —',
                  style: pw.TextStyle(font: baseFont, fontSize: 8),
                ),
              ),
              pw.SizedBox(height: 4),
            ],
          );
        },
      ),
    );

    await _sendToPrinter(doc, 'Kitchen_${_formatTime(now).replaceAll(':', '')}');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CASHIER SHIFT REPORT (80mm Thermal Receipt)
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> printCashierReport(CashierReportEntity report) async {
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
          return pw.Padding(
            padding: pw.EdgeInsets.zero,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                _decorativeLine(),
                pw.SizedBox(height: 3),
                pw.Center(
                  child: pw.Text('بريسكا كافيه',
                      style: pw.TextStyle(font: boldFont, fontSize: 14)),
                ),
                pw.SizedBox(height: 1),
                pw.Center(
                  child: pw.Text('تقرير مبيعات الكاشير',
                      style: pw.TextStyle(font: boldFont, fontSize: 12)),
                ),
                pw.SizedBox(height: 3),
                _decorativeLine(),
                pw.SizedBox(height: 4),

                _infoRow('التاريخ:', _formatDate(report.date), baseFont),
                _infoRow('وقت الطباعة:', _formatTime(now), baseFont),
                _infoRow('عدد الفواتير:', '${report.invoiceCount} فاتورة', baseFont),
                pw.SizedBox(height: 4),
                _thickDivider(),
                pw.SizedBox(height: 4),

                pw.Text('ملخص طرق الدفع:',
                    style: pw.TextStyle(font: boldFont, fontSize: 10)),
                pw.SizedBox(height: 2),
                _amountRow('💵 نقدي (Cash):', report.cashTotal, baseFont),
                _amountRow('📱 محفظة (Wallet):', report.walletTotal, baseFont),
                _amountRow('⚡ إنستاباي (InstaPay):', report.instapayTotal, baseFont),
                if (report.cardTotal > 0)
                  _amountRow('💳 بطاقة (Card):', report.cardTotal, baseFont),
                pw.SizedBox(height: 3),
                _thinDivider(),
                pw.SizedBox(height: 3),
                _amountRow('إجمالي المبيعات:', report.totalRevenue, boldFont),
                pw.SizedBox(height: 4),
                _thickDivider(),
                pw.SizedBox(height: 4),

                pw.Text('تفاصيل الأصناف المباعة (${report.totalQuantitySold} قطعة):',
                    style: pw.TextStyle(font: boldFont, fontSize: 10)),
                pw.SizedBox(height: 3),

                // Table Header
                pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 5,
                      child: pw.Text('الصنف',
                          style: pw.TextStyle(font: boldFont, fontSize: 9)),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text('الكمية',
                          style: pw.TextStyle(font: boldFont, fontSize: 9),
                          textAlign: pw.TextAlign.center),
                    ),
                    pw.Expanded(
                      flex: 3,
                      child: pw.Text('الإجمالي',
                          style: pw.TextStyle(font: boldFont, fontSize: 9),
                          textAlign: pw.TextAlign.left),
                    ),
                  ],
                ),
                pw.SizedBox(height: 2),
                _thinDivider(),
                pw.SizedBox(height: 2),

                // Items list
                if (report.items.isEmpty)
                  pw.Center(
                    child: pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 4),
                      child: pw.Text('لا توجد مبيعات أصناف مسجلة',
                          style: pw.TextStyle(font: baseFont, fontSize: 9)),
                    ),
                  )
                else
                  ...report.items.map((item) {
                    return pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Expanded(
                            flex: 5,
                            child: pw.Text(
                              item.productName,
                              style: pw.TextStyle(font: baseFont, fontSize: 9),
                              softWrap: true,
                            ),
                          ),
                          pw.Expanded(
                            flex: 2,
                            child: pw.Text(
                              '${item.quantity}',
                              style: pw.TextStyle(font: baseFont, fontSize: 9),
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                          pw.Expanded(
                            flex: 3,
                            child: pw.Text(
                              item.totalPrice.toStringAsFixed(2),
                              style: pw.TextStyle(font: baseFont, fontSize: 9),
                              textAlign: pw.TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                // PlayStation Summary if any
                if (report.playStationTotal > 0) ...[
                  pw.SizedBox(height: 3),
                  _thinDivider(),
                  pw.SizedBox(height: 3),
                  _amountRow('🎮 دخل البلايستيشن (${report.playStationCount} جلسة):',
                      report.playStationTotal, baseFont),
                ],

                pw.SizedBox(height: 6),
                _decorativeLine(),
                pw.SizedBox(height: 3),
                pw.Center(
                  child: pw.Text('نظام كاشير بريسكا كافيه',
                      style: pw.TextStyle(font: baseFont, fontSize: 8)),
                ),
                pw.SizedBox(height: 8),
              ],
            ),
          );
        },
      ),
    );

    await _sendToPrinter(doc, 'CashierReport_${_formatTime(now).replaceAll(':', '')}');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Helper Widgets
  // ─────────────────────────────────────────────────────────────────────────

  pw.Widget _decorativeLine() {
    return pw.Center(
      child: pw.Text(
        '═' * 38,
        style: pw.TextStyle(fontSize: 7),
        maxLines: 1,
        overflow: pw.TextOverflow.clip,
      ),
    );
  }

  pw.Widget _thickDivider() =>
      pw.Container(height: 1.5, color: PdfColors.black);

  pw.Widget _thinDivider() =>
      pw.Container(height: 0.5, color: PdfColors.black);

  pw.Widget _infoRow(String label, String value, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(font: font, fontSize: 9)),
          pw.Text(value, style: pw.TextStyle(font: font, fontSize: 9)),
        ],
      ),
    );
  }

  pw.Widget _amountRow(String label, double amount, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(font: font, fontSize: 10)),
          pw.Text('${amount.toStringAsFixed(2)} ج.م',
              style: pw.TextStyle(font: font, fontSize: 10)),
        ],
      ),
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
