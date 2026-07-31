import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../features/orders/domain/entities/order_entity.dart';

class PrinterService {
  // Cache the selected printer so the user picks it once per session
  Printer? _selectedPrinter;

  // Cache the Arabic font so we don't re-download it
  pw.Font? _cachedArabicFont;
  pw.Font? _cachedArabicBoldFont;

  /// 80mm thermal receipt paper format with minimal margins
  static const PdfPageFormat _receiptFormat = PdfPageFormat(
    80 * PdfPageFormat.mm,
    double.infinity,
    marginLeft: 3 * PdfPageFormat.mm,
    marginRight: 3 * PdfPageFormat.mm,
    marginTop: 2 * PdfPageFormat.mm,
    marginBottom: 2 * PdfPageFormat.mm,
  );

  /// Auto-detect the default system printer.
  Future<bool> selectPrinter() async {
    try {
      final printers = await Printing.listPrinters();
      if (printers.isNotEmpty) {
        final defaultPrinter = printers.where((p) => p.isDefault).firstOrNull;
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

  /// Get the name of the currently selected printer
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

  Future<void> printReceipt(
    OrderEntity order,
    double serviceChargeRate,
    double taxRate,
    double serviceCharge,
    double tax,
    double grandTotal,
    int? tableNumber,
    int orderNumber,
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
              // ╔══════════════════════════════════════╗
              // ║            HEADER SECTION            ║
              // ╚══════════════════════════════════════╝
              _decorativeLine(),
              pw.SizedBox(height: 6),
              pw.Center(
                child: pw.Text(
                  'بريسكا كافيه',
                  style: pw.TextStyle(font: boldFont, fontSize: 20),
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Center(
                child: pw.Text(
                  'Briska Cafe',
                  style: pw.TextStyle(font: baseFont, fontSize: 9),
                ),
              ),
              pw.SizedBox(height: 6),
              _decorativeLine(),

              pw.SizedBox(height: 6),

              // ── Order Info ────────────────────────
              _infoRow(
                'نوع الطلب',
                order.orderType == 'takeaway' ? 'تيك أواي' : 'داخلي',
                baseFont,
              ),
              if (order.orderType != 'takeaway')
                _infoRow(
                  'الطاولة',
                  '${tableNumber ?? order.tableId}',
                  baseFont,
                ),
              _infoRow(
                'رقم الطلب',
                '#$orderNumber',
                baseFont,
              ),
              _infoRow(
                'التاريخ',
                _formatDate(now),
                baseFont,
              ),
              _infoRow(
                'الوقت',
                _formatTime(now),
                baseFont,
              ),

              pw.SizedBox(height: 4),

              // ╔══════════════════════════════════════╗
              // ║            ITEMS SECTION             ║
              // ╚══════════════════════════════════════╝
              _thickDivider(),
              pw.SizedBox(height: 2),

              // Table header
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 2),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 5,
                      child: pw.Text('الصنف', style: pw.TextStyle(font: boldFont, fontSize: 9)),
                    ),
                    pw.SizedBox(
                      width: 30,
                      child: pw.Text('الكمية', style: pw.TextStyle(font: boldFont, fontSize: 9), textAlign: pw.TextAlign.center),
                    ),
                    pw.SizedBox(
                      width: 55,
                      child: pw.Text('السعر', style: pw.TextStyle(font: boldFont, fontSize: 9), textAlign: pw.TextAlign.left),
                    ),
                  ],
                ),
              ),
              _thinDivider(),

              // Items list
              ...order.items.map((item) => pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 2.5),
                    child: pw.Row(
                      children: [
                        pw.Expanded(
                          flex: 5,
                          child: pw.Text(
                            item.productName,
                            style: pw.TextStyle(font: baseFont, fontSize: 10),
                          ),
                        ),
                        pw.SizedBox(
                          width: 30,
                          child: pw.Text(
                            '${item.quantity}',
                            style: pw.TextStyle(font: baseFont, fontSize: 10),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.SizedBox(
                          width: 55,
                          child: pw.Text(
                            item.totalPrice.toStringAsFixed(2),
                            style: pw.TextStyle(font: baseFont, fontSize: 10),
                            textAlign: pw.TextAlign.left,
                          ),
                        ),
                      ],
                    ),
                  )),

              pw.SizedBox(height: 2),
              _thickDivider(),
              pw.SizedBox(height: 4),

              // ╔══════════════════════════════════════╗
              // ║           TOTALS SECTION             ║
              // ╚══════════════════════════════════════╝
              _amountRow('المجموع الفرعي', order.subtotal, baseFont),

              if (serviceChargeRate > 0)
                _amountRow(
                  'خدمة ${(serviceChargeRate * 100).toStringAsFixed(0)}%',
                  serviceCharge,
                  baseFont,
                ),

              if (taxRate > 0)
                _amountRow(
                  'ضريبة ${(taxRate * 100).toStringAsFixed(0)}%',
                  tax,
                  baseFont,
                ),

              pw.SizedBox(height: 4),
              _thinDivider(),
              pw.SizedBox(height: 4),

              // Grand total — highlighted with border
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.black, width: 1.5),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'الإجمالي',
                      style: pw.TextStyle(font: boldFont, fontSize: 14),
                    ),
                    pw.Text(
                      '${grandTotal.toStringAsFixed(2)} ج.م',
                      style: pw.TextStyle(font: boldFont, fontSize: 16),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 10),

              // ╔══════════════════════════════════════╗
              // ║           FOOTER SECTION             ║
              // ╚══════════════════════════════════════╝
              _decorativeLine(),
              pw.SizedBox(height: 6),
              pw.Center(
                child: pw.Text(
                  'شكراً لزيارتكم',
                  style: pw.TextStyle(font: boldFont, fontSize: 12),
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Center(
                child: pw.Text(
                  'نتمنى لكم يوماً سعيداً',
                  style: pw.TextStyle(font: baseFont, fontSize: 10),
                ),
              ),
              pw.SizedBox(height: 6),
              _decorativeLine(),
              pw.SizedBox(height: 8),
            ],
          );
        },
      ),
    );

    // ═══════════════ Direct Print ═══════════════
    if (_selectedPrinter == null) {
      final picked = await selectPrinter();
      if (!picked) {
        throw Exception('لا توجد طابعة متصلة. تأكد من توصيل الطابعة وتعيينها كطابعة افتراضية في إعدادات ويندوز.');
      }
    }

    final result = await Printing.directPrintPdf(
      printer: _selectedPrinter!,
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: 'Receipt_Order_$orderNumber',
      format: _receiptFormat,
    );

    if (!result) {
      _selectedPrinter = null;
      throw Exception('فشل الطباعة. سيتم إعادة اختيار الطابعة في المرة القادمة.');
    }
  }

  // ══════════════════════════════════════════════════════════════
  //  Helper Widgets
  // ══════════════════════════════════════════════════════════════

  /// Decorative line for header & footer
  pw.Widget _decorativeLine() {
    return pw.Center(
      child: pw.Text(
        '═' * 42,
        style: pw.TextStyle(fontSize: 7),
        maxLines: 1,
        overflow: pw.TextOverflow.clip,
      ),
    );
  }

  /// Thick divider line
  pw.Widget _thickDivider() {
    return pw.Container(
      height: 1.5,
      color: PdfColors.black,
    );
  }

  /// Thin divider line
  pw.Widget _thinDivider() {
    return pw.Container(
      height: 0.5,
      color: PdfColors.black,
    );
  }

  /// Info row (label : value) for order details section
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

  /// Amount row for totals section
  pw.Widget _amountRow(String label, double amount, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(font: font, fontSize: 10)),
          pw.Text('${amount.toStringAsFixed(2)} ج.م', style: pw.TextStyle(font: font, fontSize: 10)),
        ],
      ),
    );
  }

  /// Format date
  String _formatDate(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year.toString();
    return '$y/$m/$d';
  }

  /// Format time
  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$h:$min';
  }
}
