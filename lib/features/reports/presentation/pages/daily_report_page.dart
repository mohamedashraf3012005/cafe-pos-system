import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/invoice_details_dialog.dart';
import '../../../../core/widgets/cashier_report_dialog.dart';
import '../../../../injection_container.dart' as di;
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../daily_closing/presentation/cubit/daily_closing_cubit.dart';
import '../../../daily_closing/presentation/cubit/daily_closing_state.dart';
import '../../../daily_closing/presentation/pages/daily_closing_history_page.dart';
import '../cubit/daily_report_cubit.dart';

class DailyReportPage extends StatelessWidget {
  const DailyReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<DailyReportCubit>()..loadReport()),
        BlocProvider(create: (_) => di.sl<DailyClosingCubit>()),
      ],
      child: const _DailyReportView(),
    );
  }
}

class _DailyReportView extends StatefulWidget {
  const _DailyReportView();

  @override
  State<_DailyReportView> createState() => _DailyReportViewState();
}

class _DailyReportViewState extends State<_DailyReportView> {
  int _selectedTab = 0; // 0: Invoices, 1: Expenses

  Future<void> _showChangePasswordDialog(BuildContext context) async {
    final success = await showDialog<bool>(
      context: context,
      builder: (_) => const _ChangePasswordDialog(),
    );

    if (success == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تغيير كلمة مرور المدير بنجاح!'),
          backgroundColor: AppColors.tableFree,
        ),
      );
    }
  }

  Future<void> _confirmCloseShift(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'تأكيد تقفيل الوردية',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'هل أنت متأكد من تقفيل الوردية الحالية؟\nسيتم إغلاق الوردية وحساب المبيعات والمصروفات بدقة بالوقت والتاريخ وحفظها محليًا وإرسال التقرير.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('تراجع', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('نعم، تقفيل الوردية', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<DailyClosingCubit>().closeShift();
    }
  }

  Future<void> _showAddExpenseDialog(BuildContext context) async {
    final amountController = TextEditingController();
    final reasonController = TextEditingController();
    String? localError;

    final presets = ['شراء بن', 'شراء ثلج', 'مستلزمات نظافة', 'صيانة', 'خامات ومشتريات', 'أخرى'];

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return AlertDialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.withAlpha(40),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.payments_rounded, color: Colors.amber, size: 24),
                ),
                const SizedBox(width: 12),
                const Text(
                  'إضافة مصروف للوردية',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: SizedBox(
              width: 440,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'أدخل قيمة المصروف وسبب الصرف، وسيتم حفظها وتسجيلها في تقرير الوردية.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      decoration: InputDecoration(
                        labelText: 'المبلغ (ج.م) *',
                        labelStyle: const TextStyle(color: AppColors.textSecondary),
                        prefixIcon: const Icon(Icons.attach_money, color: Colors.amber),
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: reasonController,
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                      decoration: InputDecoration(
                        labelText: 'سبب المصروف / ملاحظة *',
                        labelStyle: const TextStyle(color: AppColors.textSecondary),
                        prefixIcon: const Icon(Icons.notes_rounded, color: AppColors.primary),
                        hintText: 'مثال: شراء بن، ثلج، صيانة، نظافة...',
                        hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: presets.map((preset) {
                        return ActionChip(
                          backgroundColor: Colors.white10,
                          side: BorderSide.none,
                          label: Text(preset, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                          onPressed: () {
                            setDialogState(() {
                              reasonController.text = preset;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    if (localError != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        localError!,
                        style: const TextStyle(color: AppColors.error, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: const Text('إلغاء', style: TextStyle(color: AppColors.textSecondary)),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.check, size: 18),
                label: const Text('حفظ المصروف 💸', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD97706),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  final amountText = amountController.text.trim();
                  final reason = reasonController.text.trim();
                  final amount = double.tryParse(amountText);

                  if (amount == null || amount <= 0) {
                    setDialogState(() => localError = 'يرجى إدخال مبلغ صحيح أكبر من صفر');
                    return;
                  }
                  if (reason.isEmpty) {
                    setDialogState(() => localError = 'يرجى إدخال سبب المصروف');
                    return;
                  }

                  Navigator.pop(dialogCtx, {'amount': amount, 'reason': reason});
                },
              ),
            ],
          );
        },
      ),
    );

    if (result != null && mounted) {
      final double amount = result['amount'] as double;
      final String reason = result['reason'] as String;

      setState(() {
        _selectedTab = 1; // الانتقال لتبويب المصروفات فوراً لرؤية المصروف المسجل
      });

      try {
        await this.context.read<DailyClosingCubit>().addExpense(amount, reason);
        if (mounted) {
          await this.context.read<DailyReportCubit>().loadReport();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(this.context).showSnackBar(
            SnackBar(
              content: Text('حدث خطأ أثناء حفظ المصروف: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _confirmDeleteExpense(BuildContext context, int expenseId, String reason) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('حذف المصروف', style: TextStyle(color: Colors.white)),
        content: Text(
          'هل أنت متأكد من حذف هذا المصروف: "$reason"؟',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('نعم، حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await this.context.read<DailyClosingCubit>().deleteExpense(expenseId);
        if (mounted) {
          await this.context.read<DailyReportCubit>().loadReport();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(this.context).showSnackBar(
            SnackBar(
              content: Text('حدث خطأ أثناء حذف المصروف: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _openCashierReport(BuildContext context, {int? shiftClosingId, DateTime? date}) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final report = await context.read<DailyReportCubit>().getCashierReport(
            shiftClosingId: shiftClosingId,
            date: date,
          );
      if (context.mounted) {
        Navigator.pop(context);
        await showCashierReportDialog(context, report);
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ أثناء إنشاء تقرير الكاشير: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _pickDateAndOpenCashierReport(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: 'اختر تاريخ الوردية',
      cancelText: 'إلغاء',
      confirmText: 'عرض الورديات',
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.surface,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && context.mounted) {
      final dateStr = DateFormat('yyyy-MM-dd').format(pickedDate);
      final closings = await context.read<DailyClosingCubit>().getClosingsForDate(dateStr);
      if (!context.mounted) return;

      if (closings.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('لا توجد أي ورديات مقفلة مسجلة في تاريخ $dateStr'),
            backgroundColor: AppColors.error,
          ),
        );
      } else if (closings.length == 1) {
        await _openCashierReport(context, shiftClosingId: closings.first.id);
      } else {
        // Show dialog to pick shift
        await showDialog(
          context: context,
          builder: (dialogCtx) => AlertDialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                const Icon(Icons.schedule, color: AppColors.secondary),
                const SizedBox(width: 8),
                Text('اختر الوردية ($dateStr)', style: const TextStyle(color: Colors.white, fontSize: 18)),
              ],
            ),
            content: SizedBox(
              width: 440,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'يوجد أكثر من وردية في هذا اليوم، اختر الوردية لعرض تقرير الكاشير المنفصل الخاص بها:',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  ...closings.map((closing) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.assessment, color: AppColors.primary),
                          title: Text(
                            'تقفيل وردية (${closing.closingTime})',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          subtitle: Text(
                            'الفواتير: ${closing.invoiceCount} • المبيعات: ${closing.netSales.toStringAsFixed(2)} ج.م',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, color: AppColors.textSecondary, size: 14),
                          onTap: () {
                            Navigator.pop(dialogCtx);
                            _openCashierReport(context, shiftClosingId: closing.id);
                          },
                        ),
                      )),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: const Text('إلغاء', style: TextStyle(color: Colors.white54)),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تقرير الوردية وتقفيل الشيفت'),
        actions: [
          ElevatedButton.icon(
            icon: const Icon(Icons.assessment, color: Colors.white, size: 18),
            label: const Text(
              'تقرير كاشير الوردية الحالية 📋',
              style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => _openCashierReport(context),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.date_range_rounded, color: AppColors.secondary, size: 18),
            label: const Text(
              'تقرير وردية سابقة 📅',
              style: TextStyle(color: AppColors.secondary, fontSize: 13, fontWeight: FontWeight.bold),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.secondary),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => _pickDateAndOpenCashierReport(context),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            icon: const Icon(Icons.history, color: AppColors.secondary, size: 18),
            label: const Text(
              'سجل الورديات',
              style: TextStyle(color: AppColors.secondary, fontSize: 13),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DailyClosingHistoryPage()),
              );
            },
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            icon: const Icon(Icons.key, color: AppColors.secondary, size: 18),
            label: const Text(
              'تغيير كلمة مرور المدير',
              style: TextStyle(color: AppColors.secondary, fontSize: 13),
            ),
            onPressed: () => _showChangePasswordDialog(context),
          ),
          const SizedBox(width: 8),
          Builder(
            builder: (innerCtx) => IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'تحديث',
              onPressed: () => innerCtx.read<DailyReportCubit>().loadReport(),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocListener<DailyClosingCubit, DailyClosingState>(
        listener: (context, state) {
          if (state is ExpenseOperationSuccess) {
            context.read<DailyReportCubit>().loadReport();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.tableFree,
              ),
            );
          } else if (state is DailyClosingSuccess) {
            String message = 'تم تقفيل الوردية بنجاح.';
            if (state.isOnline) {
              message += '\nتم إرسال تقرير الوردية إلى Telegram ✓';
            } else {
              message += '\n⚠️ لا يوجد اتصال بالإنترنت.\nسيتم إرسال تقرير الوردية تلقائيًا على Telegram عند عودة الاتصال.';
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: AppColors.tableFree,
                duration: const Duration(seconds: 5),
              ),
            );
            // Reload daily report page to reflect closed shift
            context.read<DailyReportCubit>().loadReport();
            // Immediately open cashier report for the closed shift
            _openCashierReport(context, shiftClosingId: state.closing.id);
          } else if (state is DailyClosingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
            );
          }
        },
        child: BlocConsumer<DailyReportCubit, DailyReportState>(
          listener: (context, state) {
            if (state is DailyReportError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
              );
            }
          },
          builder: (context, state) {
            if (state is DailyReportLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is DailyReportLoaded) {
              double cashTotal = 0.0;
              double walletTotal = 0.0;
              double instapayTotal = 0.0;
              for (final inv in state.invoices) {
                if (inv.paymentMethod == 'wallet') {
                  walletTotal += inv.grandTotal;
                } else if (inv.paymentMethod == 'instapay') {
                  instapayTotal += inv.grandTotal;
                } else {
                  cashTotal += inv.grandTotal;
                }
              }

              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Financial Summary Card ──────────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primary, width: 2),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'إجمالي المبيعات',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${state.totalRevenue.toStringAsFixed(2)} ج.م',
                            style: const TextStyle(
                              color: AppColors.secondary,
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${state.invoices.length} فاتورة مسجلة بهذه الوردية',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                          ),
                          const SizedBox(height: 14),
                          const Divider(color: Colors.white12, height: 1),
                          const SizedBox(height: 12),
                          // Payment Breakdown Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildPaymentSummaryItem('💵 فلوس نقدي', cashTotal, AppColors.tableFree),
                              Container(width: 1, height: 30, color: Colors.white12),
                              _buildPaymentSummaryItem('📱 فلوس محفظة', walletTotal, Colors.deepPurpleAccent),
                              Container(width: 1, height: 30, color: Colors.white12),
                              _buildPaymentSummaryItem('⚡ فلوس إنستا', instapayTotal, Colors.amber),
                              Container(width: 1, height: 30, color: Colors.white12),
                              _buildPaymentSummaryItem('💸 فلوس مصروف', state.totalExpenses, Colors.redAccent),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Transactions & Expenses Tabs Header ─────────────────
                    Row(
                      children: [
                        // Tab button 0: Invoices
                        InkWell(
                          onTap: () => setState(() => _selectedTab = 0),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: _selectedTab == 0 ? AppColors.primary : Colors.white10,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.receipt_long, size: 16, color: Colors.white),
                                const SizedBox(width: 6),
                                Text(
                                  'فواتير الوردية (${state.invoices.length})',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: _selectedTab == 0 ? FontWeight.bold : FontWeight.normal,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Tab button 1: Expenses
                        InkWell(
                          onTap: () => setState(() => _selectedTab = 1),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: _selectedTab == 1 ? const Color(0xFFD97706) : Colors.white10,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.money_off, size: 16, color: Colors.white),
                                const SizedBox(width: 6),
                                Text(
                                  'مصروفات الوردية (${state.expenses.length})',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: _selectedTab == 1 ? FontWeight.bold : FontWeight.normal,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (_selectedTab == 1)
                          ElevatedButton.icon(
                            icon: const Icon(Icons.add, size: 16, color: Colors.white),
                            label: const Text('إضافة مصروف 💸', style: TextStyle(color: Colors.white, fontSize: 12)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD97706),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () => _showAddExpenseDialog(context),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // ── Active Tab Content (Invoices or Expenses) ───────────
                    Expanded(
                      child: _selectedTab == 0
                          ? (state.invoices.isEmpty
                              ? const Center(
                                  child: Text(
                                    'لا توجد فواتير في هذه الوردية حتى الآن',
                                    style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: state.invoices.length,
                                  itemBuilder: (context, index) {
                                    final inv = state.invoices[index];
                                    final formattedDate = DateFormat('yyyy/MM/dd – HH:mm', 'ar').format(inv.createdAt);
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      decoration: BoxDecoration(
                                        color: AppColors.surface,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: ListTile(
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                        leading: const Icon(Icons.receipt_long, color: AppColors.primary),
                                        title: Row(
                                          children: [
                                            Text(
                                              inv.invoiceNumber,
                                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                              decoration: BoxDecoration(
                                                color: Colors.white10,
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                inv.paymentMethodLabel,
                                                style: const TextStyle(color: Colors.white70, fontSize: 11),
                                              ),
                                            ),
                                            const Spacer(),
                                            Text(
                                              '${inv.grandTotal.toStringAsFixed(2)} ج.م',
                                              style: const TextStyle(
                                                color: AppColors.secondary,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        subtitle: Row(
                                          children: [
                                            Text(
                                              formattedDate,
                                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                            ),
                                            const Spacer(),
                                            const Text('تفاصيل الأصناف / إعادة طباعة 🖨️', style: TextStyle(color: AppColors.primary, fontSize: 11)),
                                          ],
                                        ),
                                        onTap: () async {
                                          final details = await context.read<DailyClosingCubit>().getInvoiceDetails(inv.id);
                                          if (details != null && context.mounted) {
                                            showInvoiceDetailsDialog(context, details);
                                          }
                                        },
                                      ),
                                    );
                                  },
                                ))
                          : (state.expenses.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.payments_outlined, color: Colors.white30, size: 48),
                                      const SizedBox(height: 12),
                                      const Text(
                                        'لا توجد مصروفات مسجلة في هذه الوردية',
                                        style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                                      ),
                                      const SizedBox(height: 16),
                                      ElevatedButton.icon(
                                        icon: const Icon(Icons.add, color: Colors.white),
                                        label: const Text('تسجيل أول مصروف للوردية 💸', style: TextStyle(color: Colors.white)),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFFD97706),
                                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        ),
                                        onPressed: () => _showAddExpenseDialog(context),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: state.expenses.length,
                                  itemBuilder: (context, index) {
                                    final exp = state.expenses[index];
                                    final formattedDate = DateFormat('yyyy/MM/dd – HH:mm', 'ar').format(exp.createdAt);
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      decoration: BoxDecoration(
                                        color: AppColors.surface,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: Colors.amber.withAlpha(50)),
                                      ),
                                      child: ListTile(
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                        leading: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.amber.withAlpha(30),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(Icons.money_off, color: Colors.amber, size: 22),
                                        ),
                                        title: Text(
                                          exp.reason,
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                                        ),
                                        subtitle: Text(
                                          'وقت التسجيل: $formattedDate',
                                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              '-${exp.amount.toStringAsFixed(2)} ج.م',
                                              style: const TextStyle(
                                                color: Colors.redAccent,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            IconButton(
                                              icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                                              tooltip: 'حذف المصروف',
                                              onPressed: () => _confirmDeleteExpense(context, exp.id, exp.reason),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                )),
                    ),
                    const SizedBox(height: 16),

                    // ── Bottom Action Buttons: Close Shift & Add Expense ────
                    BlocBuilder<DailyClosingCubit, DailyClosingState>(
                      builder: (context, closingState) {
                        if (closingState is DailyClosingLoading) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        return Row(
                          children: [
                            // 1. Close Shift Button
                            Expanded(
                              flex: 3,
                              child: SizedBox(
                                height: 56,
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.lock_clock, color: Colors.white, size: 22),
                                  label: const Text(
                                    'تقفيل الوردية 🔒',
                                    style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  onPressed: () => _confirmCloseShift(context),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            // 2. Add Expense Button (Directly next to it / under it)
                            Expanded(
                              flex: 2,
                              child: SizedBox(
                                height: 56,
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.payments_outlined, color: Colors.white, size: 22),
                                  label: const Text(
                                    'إضافة مصروف يومي 💸',
                                    style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFD97706),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  onPressed: () => _showAddExpenseDialog(context),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildPaymentSummaryItem(String label, double amount, Color color, {bool isNegative = false}) {
    final formatted = isNegative
        ? '- ${amount.abs().toStringAsFixed(2)} ج.م'
        : '${amount.toStringAsFixed(2)} ج.م';
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          formatted,
          style: TextStyle(
            color: color,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Change Password Dialog Widget for Manager / Owner Page
// ─────────────────────────────────────────────────────────────────────────────

class _ChangePasswordDialog extends StatefulWidget {
  const _ChangePasswordDialog();

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _oldPinController = TextEditingController();
  final _newPinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  String _errorMessage = '';
  bool _isLoading = false;

  @override
  void dispose() {
    _oldPinController.dispose();
    _newPinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final oldPin = _oldPinController.text.trim();
    final newPin = _newPinController.text.trim();
    final confirmPin = _confirmPinController.text.trim();

    if (oldPin.length != 4) {
      setState(() => _errorMessage = 'رمز المرور الحالي يجب أن يتكون من 4 أرقام');
      return;
    }
    if (newPin.length != 4) {
      setState(() => _errorMessage = 'رمز المرور الجديد يجب أن يتكون من 4 أرقام');
      return;
    }
    if (newPin != confirmPin) {
      setState(() => _errorMessage = 'كلمة المرور الجديدة غير متطابقة');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final success = await context.read<AuthCubit>().changeManagerPin(oldPin, newPin);

    if (!mounted) return;

    if (success) {
      Navigator.pop(context, true);
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'كلمة المرور الحالية غير صحيحة';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 400,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(38),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.key, color: AppColors.primary, size: 36),
              ),
              const SizedBox(height: 16),
              const Text(
                'تغيير كلمة مرور المدير',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 6),
              const Text(
                'أدخل كلمة المرور الحالية ثم كلمة المرور الجديدة',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 20),
              _buildPinTextField(_oldPinController, 'كلمة المرور الحالية (4 أرقام)'),
              const SizedBox(height: 12),
              _buildPinTextField(_newPinController, 'كلمة المرور الجديدة (4 أرقام)'),
              const SizedBox(height: 12),
              _buildPinTextField(_confirmPinController, 'تأكيد كلمة المرور الجديدة'),
              if (_errorMessage.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  _errorMessage,
                  style: const TextStyle(color: AppColors.error, fontSize: 13),
                  textDirection: TextDirection.rtl,
                ),
              ],
              const SizedBox(height: 24),
              if (_isLoading)
                const CircularProgressIndicator(color: AppColors.primary)
              else
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: Colors.grey[700]!),
                          ),
                        ),
                        child: const Text('إلغاء', style: TextStyle(color: AppColors.textSecondary)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('حفظ التغيير', style: TextStyle(color: Colors.white, fontSize: 15)),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPinTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      obscureText: true,
      keyboardType: TextInputType.number,
      maxLength: 4,
      textDirection: TextDirection.rtl,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        counterText: '',
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
