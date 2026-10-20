import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/invoice_details_dialog.dart';
import '../../../../core/widgets/cashier_report_dialog.dart';
import '../../../reports/domain/repositories/daily_report_repository.dart';
import '../../../../injection_container.dart' as di;
import '../../domain/entities/daily_closing_entity.dart';
import '../../domain/entities/invoice_item_entity.dart';
import '../cubit/daily_closing_cubit.dart';
import '../cubit/daily_closing_state.dart';

import '../../domain/entities/expense_item_entity.dart';

class DailyClosingHistoryPage extends StatelessWidget {
  const DailyClosingHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<DailyClosingCubit>()..loadHistory(),
      child: const _DailyClosingHistoryView(),
    );
  }
}

class _DailyClosingHistoryView extends StatelessWidget {
  const _DailyClosingHistoryView();

  Future<void> _openCashierReportForShift(BuildContext context, DailyClosingEntity closing) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final repo = di.sl<DailyReportRepository>();
      final report = await repo.getCashierReport(shiftClosingId: closing.id);
      if (context.mounted) {
        Navigator.pop(context);
        await showCashierReportDialog(context, report);
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ أثناء إنشاء تقرير الكاشير لهذه الوردية: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showClosingDetails(BuildContext context, DailyClosingEntity closing) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.assessment, color: AppColors.primary),
            const SizedBox(width: 10),
            Text(
              'تقرير تقفيل وردية ${closing.closingDate} (${closing.closingTime})',
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('تاريخ الوردية', closing.closingDate),
                _buildDetailRow('وقت التقفيل', closing.closingTime),
                _buildDetailRow('عدد الفواتير', '${closing.invoiceCount} فاتورة'),
                _buildDetailRow('عدد الأصناف المباعة', '${closing.totalItems} قطعة'),
                const Divider(color: Colors.white24, height: 24),
                _buildDetailRow('إجمالي المبيعات', '${closing.grossSales.toStringAsFixed(2)} ج.م'),
                if (closing.playStationTotal > 0)
                  _buildDetailRow('🎮 مبيعات البلايستيشن', '${closing.playStationTotal.toStringAsFixed(2)} ج.م', color: Colors.lightBlueAccent),
                _buildDetailRow('الخصومات', '${closing.discounts.toStringAsFixed(2)} ج.م'),
                _buildDetailRow('الضرائب', '${closing.taxTotal.toStringAsFixed(2)} ج.م'),
                _buildDetailRow('صافي المبيعات', '${closing.netSales.toStringAsFixed(2)} ج.م', isBold: true),
                const Divider(color: Colors.white24, height: 24),
                _buildDetailRow('💵 المدفوع نقدي (Cash)', '${closing.cashTotal.toStringAsFixed(2)} ج.م'),
                if (closing.walletTotal > 0)
                  _buildDetailRow('📱 المدفوع محفظة (Wallet)', '${closing.walletTotal.toStringAsFixed(2)} ج.م', color: Colors.deepPurpleAccent),
                if (closing.instapayTotal > 0)
                  _buildDetailRow('⚡ المدفوع إنستاباي (InstaPay)', '${closing.instapayTotal.toStringAsFixed(2)} ج.م', color: Colors.amber),
                if (closing.cardTotal > 0)
                  _buildDetailRow('💳 المدفوع بطاقة (Card)', '${closing.cardTotal.toStringAsFixed(2)} ج.م'),
                if (closing.otherPayments > 0)
                  _buildDetailRow('🔹 طرق أخرى', '${closing.otherPayments.toStringAsFixed(2)} ج.م'),
                if (closing.expensesTotal > 0) ...[
                  const Divider(color: Colors.white24, height: 24),
                  _buildDetailRow('💸 إجمالي المصروفات', '${closing.expensesTotal.toStringAsFixed(2)} ج.م', color: Colors.redAccent, isBold: true),
                ],
                const Divider(color: Colors.white24, height: 24),
                _buildDetailRow('حالة الوردية', 'مغلقة (Closed)', color: AppColors.tableFree),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إغلاق', style: TextStyle(color: Colors.white54)),
          ),
          if (closing.expensesTotal > 0)
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD97706),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.money_off, size: 18),
              label: const Text('مصروفات الوردية 💸', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.pop(ctx);
                _showShiftExpenses(context, closing.id, closing.closingDate, closing.closingTime);
              },
            ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.assessment_rounded, size: 18),
            label: const Text('تقرير الكاشير 📋', style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () {
              Navigator.pop(ctx);
              _openCashierReportForShift(context, closing);
            },
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.receipt_long, size: 18),
            label: const Text('فواتير الوردية', style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () {
              Navigator.pop(ctx);
              _showShiftInvoices(context, closing.id, closing.closingDate, closing.closingTime);
            },
          ),
        ],
      ),
    );
  }

  void _showShiftExpenses(BuildContext context, int closingId, String date, String time) {
    final cubit = context.read<DailyClosingCubit>();
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.money_off, color: Colors.amber),
            const SizedBox(width: 10),
            Text('مصروفات وردية $date ($time)', style: const TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
        content: SizedBox(
          width: 500,
          height: 380,
          child: FutureBuilder<List<ExpenseItemEntity>>(
            future: cubit.getExpensesForClosing(closingId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(child: Text('حدث خطأ أثناء تحميل المصروفات', style: TextStyle(color: AppColors.error)));
              }
              final expenses = snapshot.data ?? [];
              if (expenses.isEmpty) {
                return const Center(
                  child: Text('لا توجد مصروفات مسجلة لهذه الوردية', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                );
              }
              return ListView.builder(
                itemCount: expenses.length,
                itemBuilder: (context, index) {
                  final exp = expenses[index];
                  final timeStr = '${exp.createdAt.hour.toString().padLeft(2, '0')}:${exp.createdAt.minute.toString().padLeft(2, '0')}';
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.money_off, color: Colors.amber),
                      title: Text(exp.reason, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: Text('الوقت: $timeStr', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      trailing: Text(
                        '-${exp.amount.toStringAsFixed(2)} ج.م',
                        style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('إغلاق', style: TextStyle(color: Colors.white54)),
          ),
        ],
      ),
    );
  }

  void _showShiftInvoices(BuildContext context, int shiftClosingId, String dateStr, String timeStr) {
    final cubit = context.read<DailyClosingCubit>();
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.receipt_long_rounded, color: AppColors.secondary),
            const SizedBox(width: 10),
            Text('فواتير وردية $dateStr ($timeStr)', style: const TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
        content: SizedBox(
          width: 550,
          height: 420,
          child: FutureBuilder<List<InvoiceDetailEntity>>(
            future: cubit.getInvoicesForShift(shiftClosingId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(child: Text('حدث خطأ أثناء تحميل الفواتير', style: TextStyle(color: AppColors.error)));
              }
              final invoices = snapshot.data ?? [];
              if (invoices.isEmpty) {
                return const Center(child: Text('لا توجد فواتير مسجلة لهذه الوردية', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)));
              }

              return ListView.builder(
                itemCount: invoices.length,
                itemBuilder: (context, index) {
                  final inv = invoices[index];
                  final timeStr = '${inv.createdAt.hour.toString().padLeft(2, '0')}:${inv.createdAt.minute.toString().padLeft(2, '0')}';
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      title: Row(
                        children: [
                          Text(inv.invoiceNumber, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                          const Spacer(),
                          Text('${inv.grandTotal.toStringAsFixed(2)} ج.م', style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 15)),
                        ],
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Row(
                          children: [
                            Text('الوقت: $timeStr', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: Colors.white10,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(inv.paymentMethodLabel, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                            ),
                            const Spacer(),
                            const Text('اضغط للتفاصيل والطباعة', style: TextStyle(color: AppColors.primary, fontSize: 11)),
                          ],
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_left_rounded, color: Colors.white54),
                      onTap: () => showInvoiceDetailsDialog(context, inv),
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('إغلاق', style: TextStyle(color: Colors.white54)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String title, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color ?? (isBold ? AppColors.secondary : Colors.white),
              fontSize: isBold ? 16 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سجل تقفيلات الورديات السابقة'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<DailyClosingCubit>().loadHistory(),
          ),
        ],
      ),
      body: BlocBuilder<DailyClosingCubit, DailyClosingState>(
        builder: (context, state) {
          if (state is DailyClosingLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DailyClosingHistoryLoaded) {
            if (state.history.isEmpty) {
              return const Center(
                child: Text(
                  'لا توجد ورديات سابقة مسجلة في النظام',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: state.history.length,
              itemBuilder: (context, index) {
                final closing = state.history[index];
                return Card(
                  color: AppColors.surface,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    title: Row(
                      children: [
                        const Icon(Icons.schedule, color: AppColors.secondary, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'تقفيل وردية ${closing.closingDate}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '(${closing.closingTime})',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                        const Spacer(),
                        Text(
                          '${closing.netSales.toStringAsFixed(2)} ج.م',
                          style: const TextStyle(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          Text(
                            'الفواتير: ${closing.invoiceCount}',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          ),
                          if (closing.expensesTotal > 0) ...[
                            const SizedBox(width: 12),
                            Text(
                              'المصروفات: ${closing.expensesTotal.toStringAsFixed(2)} ج.م',
                              style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ],
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.tableFree.withAlpha(51),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'وردية مغلقة',
                              style: TextStyle(color: AppColors.tableFree, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: const Icon(Icons.assessment, size: 16),
                          label: const Text('تقرير الكاشير 📋', style: TextStyle(fontSize: 12)),
                          onPressed: () => _openCashierReportForShift(context, closing),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_ios, color: AppColors.textSecondary, size: 16),
                      ],
                    ),
                    onTap: () => _showClosingDetails(context, closing),
                  ),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
