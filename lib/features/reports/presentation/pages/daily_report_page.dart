import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/invoice_details_dialog.dart';
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

class _DailyReportView extends StatelessWidget {
  const _DailyReportView();

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
          'تأكيد تقفيل حساب اليوم',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'هل أنت متأكد من تقفيل حساب اليوم؟\nسيتم إغلاق حساب اليوم وإنشاء التقرير المحفوظ وحفظه محليًا.',
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
            child: const Text('نعم، تقفيل اليوم', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<DailyClosingCubit>().closeDay();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تقرير اليومية وتقفيل اليوم'),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.history, color: AppColors.secondary, size: 18),
            label: const Text(
              'سجل التقفيلات',
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
          if (state is DailyClosingSuccess) {
            String message = 'تم تقفيل اليوم بنجاح.';
            if (state.isOnline) {
              message += '\nتم إرسال تقرير اليوم إلى Telegram ✓';
            } else {
              message += '\n⚠️ لا يوجد اتصال بالإنترنت.\nسيتم إرسال تقرير اليوم تلقائيًا على Telegram عند عودة الاتصال.';
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
                          // ── Total Revenue Card ──────────────────────────────────
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
                                  'مجموع إيرادات الوردية الحالية',
                                  style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${state.totalRevenue.toStringAsFixed(2)} ج.م',
                                  style: const TextStyle(
                                    color: AppColors.secondary,
                                    fontSize: 42,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${state.invoices.length} فاتورة مفتوحة',
                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                ),
                                const SizedBox(height: 14),
                                const Divider(color: Colors.white12, height: 1),
                                const SizedBox(height: 12),
                                // Payment Breakdown Row
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildPaymentSummaryItem('💵 نقدي (Cash)', cashTotal, AppColors.tableFree),
                                    Container(width: 1, height: 30, color: Colors.white12),
                                    _buildPaymentSummaryItem('📱 محفظة (Wallet)', walletTotal, Colors.deepPurpleAccent),
                                    Container(width: 1, height: 30, color: Colors.white12),
                                    _buildPaymentSummaryItem('⚡ إنستاباي (InstaPay)', instapayTotal, Colors.amber),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // ── Transactions List ───────────────────────────────────
                          const Text(
                            'معاملات الوردية الحالية (اضغط لعرض الأصناف وإعادة الطباعة)',
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                            child: state.invoices.isEmpty
                                ? const Center(
                                    child: Text(
                                      'لا توجد معاملات في هذه الوردية',
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
                                  ),
                          ),
                    const SizedBox(height: 16),

                    // ── Close Shift Button ──────────────────────────────────
                    BlocBuilder<DailyClosingCubit, DailyClosingState>(
                      builder: (context, closingState) {
                        if (closingState is DailyClosingLoading) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        return SizedBox(
                          height: 60,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.lock_clock, color: Colors.white),
                            label: const Text(
                              'تقفيل حساب اليوم',
                              style: TextStyle(fontSize: 20, color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () => _confirmCloseShift(context),
                          ),
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

  Widget _buildPaymentSummaryItem(String label, double amount, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          '${amount.toStringAsFixed(2)} ج.م',
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
