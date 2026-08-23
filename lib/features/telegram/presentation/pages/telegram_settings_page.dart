import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../injection_container.dart' as di;
import '../cubit/telegram_cubit.dart';
import '../cubit/telegram_state.dart';

class TelegramSettingsPage extends StatelessWidget {
  const TelegramSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<TelegramCubit>()..init(),
      child: const _TelegramSettingsView(),
    );
  }
}

class _TelegramSettingsView extends StatefulWidget {
  const _TelegramSettingsView();

  @override
  State<_TelegramSettingsView> createState() => _TelegramSettingsViewState();
}

class _TelegramSettingsViewState extends State<_TelegramSettingsView> {
  final _botTokenController = TextEditingController();
  final _chatIdController = TextEditingController();
  bool _sendInvoices = true;
  bool _sendClosing = true;
  bool _initialized = false;

  @override
  void dispose() {
    _botTokenController.dispose();
    _chatIdController.dispose();
    super.dispose();
  }

  void _saveSettings(BuildContext context) {
    context.read<TelegramCubit>().updateSettings(
          sendInvoices: _sendInvoices,
          sendClosing: _sendClosing,
          botToken: _botTokenController.text.trim(),
          chatId: _chatIdController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إعدادات Telegram Bot'),
      ),
      body: BlocConsumer<TelegramCubit, TelegramState>(
        listener: (context, state) {
          if (state is TelegramOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.tableFree),
            );
          } else if (state is TelegramOperationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                duration: const Duration(seconds: 5),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is TelegramStatusLoaded && !_initialized) {
            _botTokenController.text = state.botToken;
            _chatIdController.text = state.chatId;
            _sendInvoices = state.sendInvoicesEnabled;
            _sendClosing = state.sendDailyClosingEnabled;
            _initialized = true;
          }

          final loaded = state is TelegramStatusLoaded ? state : null;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Instructions Card ─────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withAlpha(26),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blueAccent.withAlpha(102)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.send_rounded, color: Colors.blueAccent, size: 24),
                          SizedBox(width: 10),
                          Text(
                            'طريقة إنشاء وتفعيل تليجرام بوت في دقيقة واحدة (مجاني 100%):',
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '1. افتح تطبيق تليجرام وابحث عن المستخدم @BotFather\n'
                        '2. أرسل الأمر /newbot ثم اكتب اسماً للبوت الخاص بك.\n'
                        '3. سيمنحك BotFather كود يسمى HTTP API Token (انسخه وضعه في خانة Bot Token بالأسفل).\n'
                        '4. افتح البوت الجديد الذي أنشأته واضغط Start وابحث عن Chat ID الخاص بك وضعه في خانة Chat ID.',
                        style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.6),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Status Cards ──────────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: _buildStatusCard(
                        title: 'حالة الإنترنت',
                        value: (loaded?.isOnline ?? false) ? 'متصل' : 'غير متصل',
                        isGood: loaded?.isOnline ?? false,
                        icon: Icons.wifi,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatusCard(
                        title: 'حالة Telegram Bot',
                        value: (loaded?.isTelegramConnected ?? false) ? 'جاهز ومتصل' : 'تحتاج ضبط المفاتيح',
                        isGood: loaded?.isTelegramConnected ?? false,
                        icon: Icons.send,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Toggle Options ────────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'خيارات الإرسال التلقائي عبر Telegram',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Divider(color: Colors.white24, height: 24),
                      SwitchListTile(
                        title: const Text('إرسال الفواتير تلقائيًا إلى تليجرام', style: TextStyle(color: Colors.white)),
                        subtitle: const Text('إرسال ملخص كل فاتورة جديدة فور حفظها', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        value: _sendInvoices,
                        activeThumbColor: AppColors.primary,
                        onChanged: (val) => setState(() => _sendInvoices = val),
                      ),
                      SwitchListTile(
                        title: const Text('إرسال تقفيل اليوم تلقائيًا إلى تليجرام', style: TextStyle(color: Colors.white)),
                        subtitle: const Text('إرسال التقرير المالي المكتمل عند تقفيل الوردية', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        value: _sendClosing,
                        activeThumbColor: AppColors.primary,
                        onChanged: (val) => setState(() => _sendClosing = val),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Credentials Form ──────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'مفاتيح الربط الخاص بـ Telegram Bot',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Divider(color: Colors.white24, height: 24),
                      TextField(
                        controller: _botTokenController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Telegram Bot Token',
                          hintText: '123456789:ABCdefGhIJKlmNoPQRstuVWXyz',
                          prefixIcon: Icon(Icons.key, color: AppColors.primary),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _chatIdController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Telegram Chat ID (رقم حسابك أو الجروب)',
                          hintText: '987654321',
                          prefixIcon: Icon(Icons.account_box, color: AppColors.primary),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.save, color: Colors.white),
                          label: const Text('حفظ إعدادات Telegram', style: TextStyle(color: Colors.white, fontSize: 16)),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                          onPressed: () => _saveSettings(context),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Test Button ───────────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.send),
                    label: const Text('اختبار إرسال رسالة تليجرام الآن', style: TextStyle(fontSize: 16)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                    onPressed: () => context.read<TelegramCubit>().sendTestMessage(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusCard({
    required String title,
    required String value,
    required bool isGood,
    required IconData icon,
  }) {
    final color = isGood ? AppColors.tableFree : AppColors.error;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(128)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    value,
                    style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
