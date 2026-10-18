import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../services/printer_service.dart';
import '../services/telegram_settings_service.dart';
import '../../features/telegram/data/datasources/telegram_remote_datasource.dart';
import '../../injection_container.dart' as di;
import '../../features/reports/domain/entities/cashier_report_entity.dart';

Future<void> showCashierReportDialog(BuildContext context, CashierReportEntity report) {
  return showDialog(
    context: context,
    builder: (ctx) => _CashierReportDialogContent(report: report),
  );
}

class _CashierReportDialogContent extends StatefulWidget {
  final CashierReportEntity report;

  const _CashierReportDialogContent({required this.report});

  @override
  State<_CashierReportDialogContent> createState() => _CashierReportDialogContentState();
}

class _CashierReportDialogContentState extends State<_CashierReportDialogContent> {
  bool _isProcessing = false;

  String _formatCashierReportTelegram(CashierReportEntity r) {
    final dateStr = DateFormat('yyyy/MM/dd').format(r.date);
    final timeStr = DateFormat('HH:mm').format(DateTime.now());

    final itemsBuf = StringBuffer();
    if (r.items.isEmpty) {
      itemsBuf.writeln('<i>لا توجد مبيعات أصناف مسجلة</i>');
    } else {
      for (final item in r.items) {
        itemsBuf.writeln('• ${item.productName} × ${item.quantity} = ${item.totalPrice.toStringAsFixed(2)} ج.م');
      }
    }

    final headerTitle = r.isOpenShift
        ? '<b>📊 تقرير كاشير الوردية الحالية (مفتوحة) - Cafe POS</b>'
        : '<b>📊 تقرير كاشير وردية (${r.shiftTime ?? timeStr}) - Cafe POS</b>';

    final shiftBadge = r.isOpenShift
        ? '🟢 <b>حالة الوردية:</b> الوردية الحالية (قيد العمل)'
        : '🔒 <b>الوردية:</b> وردية مغلقة #${r.shiftClosingId ?? ''} (وقت التقفيل: ${r.shiftTime ?? timeStr})';

    final expBuf = StringBuffer();
    if (r.expenses.isNotEmpty) {
      expBuf.writeln('────────────────');
      expBuf.writeln('<b>💸 مصروفات الوردية:</b> -${r.expensesTotal.toStringAsFixed(2)} ج.م');
      for (final exp in r.expenses) {
        expBuf.writeln('• ${exp.reason}: ${exp.amount.toStringAsFixed(2)} ج.م');
      }
      expBuf.writeln('💵 <b>صافي النقدية بالدرج:</b> <u>${r.netCashAfterExpenses.toStringAsFixed(2)} ج.م</u>');
    }

    return '''
$headerTitle

$shiftBadge
<b>📅 تاريخ الوردية:</b> $dateStr
<b>⏰ وقت استخراج التقرير:</b> $timeStr
<b>عدد الفواتير:</b> ${r.invoiceCount} فاتورة
<b>إجمالي القطع المباعة:</b> ${r.totalQuantitySold} قطعة

────────────────
<b>💰 إجمالي المبيعات:</b> <u>${r.totalRevenue.toStringAsFixed(2)} ج.م</u>

<b>تفاصيل طرق الدفع:</b>
💵 <b>النقدي (Cash):</b> ${r.cashTotal.toStringAsFixed(2)} ج.م
📱 <b>محفظة (Wallet):</b> ${r.walletTotal.toStringAsFixed(2)} ج.م
⚡ <b>إنستاباي (InstaPay):</b> ${r.instapayTotal.toStringAsFixed(2)} ج.م
${r.cardTotal > 0 ? '💳 <b>بطاقة (Card):</b> ${r.cardTotal.toStringAsFixed(2)} ج.م\n' : ''}${expBuf.toString()}────────────────
<b>الأصناف المباعة:</b>
${itemsBuf.toString().trim()}
${r.playStationTotal > 0 ? '\n🎮 <b>جلسات بلايستيشن:</b> ${r.playStationCount} جلسة = ${r.playStationTotal.toStringAsFixed(2)} ج.م' : ''}
────────────────
تم إنشاء التقرير بواسطة نظام الكاشير ❤️
''';
  }

  Future<bool> _sendToTelegram(CashierReportEntity report) async {
    final settings = di.sl<TelegramSettingsService>();
    if (!settings.isConfigured) return false;

    final payload = _formatCashierReportTelegram(report);
    final tgDataSource = di.sl<TelegramRemoteDataSource>();
    await tgDataSource.sendMessage(message: payload);
    return true;
  }

  Future<void> _handlePrint() async {
    setState(() => _isProcessing = true);
    bool printSuccess = false;
    bool tgSuccess = false;
    String? printError;
    String? tgError;

    // 1. Print report to thermal printer
    try {
      final printerService = di.sl<PrinterService>();
      await printerService.printCashierReport(widget.report);
      printSuccess = true;
    } catch (e) {
      printError = e.toString().replaceAll("Exception: ", "");
    }

    // 2. Automatically send to Telegram as well
    try {
      tgSuccess = await _sendToTelegram(widget.report);
    } catch (e) {
      tgError = e.toString().replaceAll("Exception: ", "");
    }

    if (!mounted) return;
    setState(() => _isProcessing = false);

    if (printSuccess) {
      String message = 'تمت طباعة تقرير الكاشير بنجاح 🖨️';
      if (tgSuccess) {
        message += '\nتم إرسال التقرير إلى Telegram بنجاح ✓';
      } else if (tgError != null) {
        message += '\n⚠️ تعذر الإرسال إلى Telegram: $tgError';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.tableFree,
          duration: const Duration(seconds: 4),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ أثناء الطباعة: $printError'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _handleSendTelegramOnly() async {
    setState(() => _isProcessing = true);
    try {
      final success = await _sendToTelegram(widget.report);
      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إرسال تقرير الكاشير إلى Telegram بنجاح ✓'),
            backgroundColor: AppColors.tableFree,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('يرجى ضبط مفاتيح Telegram Bot أولاً في إعدادات التطبيق.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ أثناء الإرسال لـ Telegram: ${e.toString().replaceAll("Exception: ", "")}'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final report = widget.report;
    final formattedDate = DateFormat('yyyy/MM/dd – HH:mm', 'ar').format(report.date);

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 680,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.90,
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Dialog Header ───────────────────────────────────────────────
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(38),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.assessment_rounded, color: AppColors.primary, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.isOpenShift
                            ? 'تقرير كاشير الوردية الحالية (مفتوحة)'
                            : 'تقرير كاشير الوردية #${report.shiftClosingId ?? ''} (${report.shiftTime ?? formattedDate})',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: report.isOpenShift ? AppColors.tableFree.withAlpha(40) : AppColors.secondary.withAlpha(40),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: report.isOpenShift ? AppColors.tableFree.withAlpha(120) : AppColors.secondary.withAlpha(120),
                              ),
                            ),
                            child: Text(
                              report.isOpenShift
                                  ? '🟢 وردية مفتوحة'
                                  : '🔒 وردية مغلقة #${report.shiftClosingId ?? ''}',
                              style: TextStyle(
                                color: report.isOpenShift ? AppColors.tableFree : AppColors.secondary,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            report.isOpenShift
                                ? 'استخراج: $formattedDate'
                                : 'تاريخ: ${DateFormat('yyyy/MM/dd').format(report.date)} • وقت التقفيل: ${report.shiftTime ?? ''}',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Financial Totals Summary Row ────────────────────────────────
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildHeaderStat('إجمالي المبيعات', '${report.totalRevenue.toStringAsFixed(2)} ج.م', AppColors.secondary, isLarge: true),
                      Container(width: 1, height: 36, color: Colors.white12),
                      _buildHeaderStat('عدد الفواتير', '${report.invoiceCount} فاتورة', Colors.white),
                      Container(width: 1, height: 36, color: Colors.white12),
                      _buildHeaderStat('إجمالي القطع المباعة', '${report.totalQuantitySold} قطعة', AppColors.tableFree),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(color: Colors.white12, height: 1),
                  const SizedBox(height: 10),
                  // Payment Methods Breakdown
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildPaymentBreakdownItem('💵 نقدي (Cash)', report.cashTotal, AppColors.tableFree),
                      Container(width: 1, height: 26, color: Colors.white12),
                      _buildPaymentBreakdownItem('📱 محفظة (Wallet)', report.walletTotal, Colors.deepPurpleAccent),
                      Container(width: 1, height: 26, color: Colors.white12),
                      _buildPaymentBreakdownItem('⚡ إنستاباي (InstaPay)', report.instapayTotal, Colors.amber),
                    ],
                  ),
                  if (report.expensesTotal > 0) ...[
                    const SizedBox(height: 10),
                    const Divider(color: Colors.white12, height: 1),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildPaymentBreakdownItem('💸 مصروفات الوردية', report.expensesTotal, Colors.redAccent),
                        Container(width: 1, height: 26, color: Colors.white12),
                        _buildPaymentBreakdownItem('💵 صافي النقدية بالدرج', report.netCashAfterExpenses, AppColors.tableFree),
                        Container(width: 1, height: 26, color: Colors.white12),
                        _buildPaymentBreakdownItem('💰 صافي الإيراد', report.netRevenueAfterExpenses, AppColors.secondary),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ── Expenses Breakdown Box (if any) ────────────────────────────
            if (report.expenses.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.amber.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.amber.withAlpha(80)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.money_off, color: Colors.amber, size: 18),
                        const SizedBox(width: 8),
                        const Text(
                          'مصروفات الوردية المسجلة:',
                          style: TextStyle(color: Colors.amber, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        Text(
                          '${report.expenses.length} مصروف = -${report.expensesTotal.toStringAsFixed(2)} ج.م',
                          style: const TextStyle(color: Colors.amber, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ...report.expenses.map((exp) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              Text('• ${exp.reason}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                              const Spacer(),
                              Text('-${exp.amount.toStringAsFixed(2)} ج.م', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // ── PlayStation Summary (if used) ───────────────────────────────
            if (report.playStationTotal > 0) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blueAccent.withAlpha(77)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.sports_esports, color: Colors.lightBlueAccent, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'جلسات البلايستيشن: ${report.playStationCount} جلسة',
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                    const Spacer(),
                    Text(
                      '${report.playStationTotal.toStringAsFixed(2)} ج.م',
                      style: const TextStyle(color: AppColors.secondary, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // ── Table Title ─────────────────────────────────────────────────
            Row(
              children: [
                const Icon(Icons.format_list_numbered_rtl_rounded, color: AppColors.primary, size: 18),
                const SizedBox(width: 8),
                const Text(
                  'تفاصيل الأصناف المباعة',
                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  '${report.items.length} صنف مختلف',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // ── Items Table Header ──────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Expanded(flex: 5, child: Text('اسم الصنف', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold))),
                  Expanded(flex: 2, child: Center(child: Text('الكمية', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)))),
                  Expanded(flex: 3, child: Center(child: Text('سعر الوحدة', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)))),
                  Expanded(flex: 3, child: Align(alignment: Alignment.centerLeft, child: Text('الإجمالي', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)))),
                ],
              ),
            ),
            const SizedBox(height: 4),

            // ── Items Table Body (Scrollable) ───────────────────────────────
            Expanded(
              child: report.items.isEmpty
                  ? const Center(
                      child: Text(
                        'لا توجد أصناف مباعة في هذه الوردية حتى الآن',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                      ),
                    )
                  : ListView.builder(
                      itemCount: report.items.length,
                      itemBuilder: (context, index) {
                        final item = report.items[index];
                        final isEven = index % 2 == 0;
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isEven ? Colors.transparent : Colors.white.withAlpha(8),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 5,
                                child: Text(
                                  item.productName,
                                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withAlpha(38),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '${item.quantity}',
                                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Center(
                                  child: Text(
                                    item.unitPrice.toStringAsFixed(2),
                                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    '${item.totalPrice.toStringAsFixed(2)} ج.م',
                                    style: const TextStyle(color: AppColors.secondary, fontSize: 13, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),

            // ── Dialog Bottom Action Buttons ────────────────────────────────
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      icon: _isProcessing
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.print, color: Colors.white),
                      label: const Text(
                        'طباعة وإرسال تيليجرام 🖨️',
                        style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: _isProcessing ? null : _handlePrint,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.send_rounded, color: Colors.white, size: 16),
                      label: const Text(
                        'تيليجرام فقط 📱',
                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0088CC),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: _isProcessing ? null : _handleSendTelegramOnly,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: Colors.white24),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('إغلاق'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderStat(String label, String value, Color color, {bool isLarge = false}) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: isLarge ? 20 : 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentBreakdownItem(String label, double amount, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        const SizedBox(height: 2),
        Text(
          '${amount.toStringAsFixed(2)} ج.م',
          style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
