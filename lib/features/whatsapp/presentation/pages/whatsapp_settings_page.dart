import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../injection_container.dart' as di;
import '../cubit/whatsapp_cubit.dart';
import '../cubit/whatsapp_state.dart';
import 'whatsapp_outbox_page.dart';

class WhatsAppSettingsPage extends StatelessWidget {
  const WhatsAppSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<WhatsAppCubit>()..init(),
      child: const _WhatsAppSettingsView(),
    );
  }
}

class _WhatsAppSettingsView extends StatefulWidget {
  const _WhatsAppSettingsView();

  @override
  State<_WhatsAppSettingsView> createState() => _WhatsAppSettingsViewState();
}

class _WhatsAppSettingsViewState extends State<_WhatsAppSettingsView> {
  final _phoneController = TextEditingController();
  final _backendUrlController = TextEditingController();
  final _metaPhoneIdController = TextEditingController();
  final _metaTokenController = TextEditingController();

  bool _sendInvoices = true;
  bool _sendClosing = true;
  String _mode = 'backend'; // 'backend' | 'direct_meta'
  bool _initialized = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _backendUrlController.dispose();
    _metaPhoneIdController.dispose();
    _metaTokenController.dispose();
    super.dispose();
  }

  void _saveSettings(BuildContext context) {
    context.read<WhatsAppCubit>().updateSettings(
          sendInvoices: _sendInvoices,
          sendClosing: _sendClosing,
          recipientPhone: _phoneController.text.trim(),
          mode: _mode,
          backendUrl: _backendUrlController.text.trim(),
          metaPhoneId: _metaPhoneIdController.text.trim(),
          metaToken: _metaTokenController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إعدادات WhatsApp Integration'),
        actions: [
          IconButton(
            icon: const Icon(Icons.outbox),
            tooltip: 'صندوق الرسائل (Outbox)',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WhatsAppOutboxPage()),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<WhatsAppCubit, WhatsAppState>(
        listener: (context, state) {
          if (state is WhatsAppOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.tableFree),
            );
          } else if (state is WhatsAppOperationError) {
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
          if (state is WhatsAppStatusLoaded && !_initialized) {
            _phoneController.text = state.recipientPhone;
            _backendUrlController.text = state.backendUrl;
            _metaPhoneIdController.text = state.metaPhoneId;
            _metaTokenController.text = state.metaToken;
            _sendInvoices = state.sendInvoicesEnabled;
            _sendClosing = state.sendDailyClosingEnabled;
            _mode = state.mode;
            _initialized = true;
          }

          final loaded = state is WhatsAppStatusLoaded ? state : null;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                        title: 'حالة WhatsApp',
                        value: (loaded?.isWhatsAppConnected ?? false) ? 'جاهز للإرسال' : 'تحتاج ضبط الإعدادات',
                        isGood: loaded?.isWhatsAppConnected ?? false,
                        icon: Icons.chat,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildCounterCard(
                        title: 'رسائل معلقة',
                        count: loaded?.pendingCount ?? 0,
                        color: Colors.amber,
                        icon: Icons.hourglass_top,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildCounterCard(
                        title: 'رسائل فاشلة',
                        count: loaded?.failedCount ?? 0,
                        color: AppColors.error,
                        icon: Icons.error_outline,
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
                        'خيارات الإرسال التلقائي',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Divider(color: Colors.white24, height: 24),
                      SwitchListTile(
                        title: const Text('إرسال الفواتير تلقائيًا', style: TextStyle(color: Colors.white)),
                        subtitle: const Text('إرسال نسخة من كل فاتورة جديدة لـ WhatsApp', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        value: _sendInvoices,
                        activeColor: AppColors.primary,
                        onChanged: (val) => setState(() => _sendInvoices = val),
                      ),
                      SwitchListTile(
                        title: const Text('إرسال تقفيل اليوم تلقائيًا', style: TextStyle(color: Colors.white)),
                        subtitle: const Text('إرسال ملخص الحساب عند تقفيل اليوم', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        value: _sendClosing,
                        activeColor: AppColors.primary,
                        onChanged: (val) => setState(() => _sendClosing = val),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Recipient Phone Number ────────────────────────────────────
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
                        'رقم هاتف المستلم الافتراضي',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'الرقم الذي يستقبل الفواتير وتقفيل الوردية (الافتراضي: +201002773665)',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _phoneController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'رقم WhatsApp المستلم (بالصيغة الدولية)',
                          hintText: '+201002773665',
                          prefixIcon: Icon(Icons.phone, color: AppColors.primary),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Integration Mode & Endpoint Configuration ────────────────
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
                        'طريقة الربط والاتصال',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Divider(color: Colors.white24, height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('خادم خاص (Backend Proxy)', style: TextStyle(color: Colors.white, fontSize: 14)),
                              subtitle: const Text('تشغيل خادم محلي أو خادم أونلاين', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                              value: 'backend',
                              groupValue: _mode,
                              activeColor: AppColors.primary,
                              onChanged: (val) => setState(() => _mode = val!),
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('ربط مباشر مع Meta Cloud API', style: TextStyle(color: Colors.white, fontSize: 14)),
                              subtitle: const Text('إدخال Phone Number ID والـ Access Token', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                              value: 'direct_meta',
                              groupValue: _mode,
                              activeColor: AppColors.primary,
                              onChanged: (val) => setState(() => _mode = val!),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      if (_mode == 'backend') ...[
                        TextField(
                          controller: _backendUrlController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'رابط خادم WhatsApp Backend URL',
                            hintText: 'http://localhost:3000/api/whatsapp',
                            prefixIcon: Icon(Icons.link, color: AppColors.primary),
                            border: OutlineInputBorder(),
                            helperText: 'مثال: http://localhost:3000/api/whatsapp (يوجد خادم Node.js جاهز في مجلد backend)',
                            helperStyle: TextStyle(color: AppColors.secondary),
                          ),
                        ),
                      ] else ...[
                        TextField(
                          controller: _metaPhoneIdController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Meta Phone Number ID',
                            hintText: '109283746501923',
                            prefixIcon: Icon(Icons.numbers, color: AppColors.primary),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _metaTokenController,
                          style: const TextStyle(color: Colors.white),
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Meta Access Token (Permanent / Temporary)',
                            hintText: 'EAAXxXX...',
                            prefixIcon: Icon(Icons.key, color: AppColors.primary),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.save, color: Colors.white),
                          label: const Text('حفظ الإعدادات', style: TextStyle(color: Colors.white, fontSize: 16)),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                          onPressed: () => _saveSettings(context),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Action Buttons ────────────────────────────────────────────
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.send),
                      label: const Text('اختبار WhatsApp'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                      onPressed: () => context.read<WhatsAppCubit>().sendTestMessage(),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('إرسال المعلقات الآن'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent),
                      onPressed: () => context.read<WhatsAppCubit>().processPendingQueue(),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('إعادة إرسال الفاشلة'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                      onPressed: () => context.read<WhatsAppCubit>().retryFailedMessages(),
                    ),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.receipt_long, color: Colors.white),
                      label: const Text('عرض صندوق الرسائل (Outbox)', style: TextStyle(color: Colors.white)),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const WhatsAppOutboxPage()),
                        );
                      },
                    ),
                  ],
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

  Widget _buildCounterCard({
    required String title,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
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
              Text(
                '$count رسالة',
                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
