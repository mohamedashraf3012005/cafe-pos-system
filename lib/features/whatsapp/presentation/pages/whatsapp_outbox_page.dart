import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../injection_container.dart' as di;
import '../../domain/entities/whatsapp_message_entity.dart';
import '../cubit/whatsapp_cubit.dart';
import '../cubit/whatsapp_state.dart';

class WhatsAppOutboxPage extends StatelessWidget {
  const WhatsAppOutboxPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<WhatsAppCubit>()..init(),
      child: const _WhatsAppOutboxView(),
    );
  }
}

class _WhatsAppOutboxView extends StatelessWidget {
  const _WhatsAppOutboxView();

  void _showMessageDetails(BuildContext context, WhatsAppMessageEntity item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.chat_bubble, color: AppColors.primary),
            const SizedBox(width: 10),
            Text(
              item.messageType == 'invoice' ? 'تفاصيل رسالة الفاتورة' : 'تفاصيل تقرير تقفيل اليوم',
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildInfoRow('رقم المعرف ID', '#${item.id}'),
                _buildInfoRow('نوع الرسالة', item.messageType == 'invoice' ? 'فاتورة' : 'تقفيل يوم'),
                _buildInfoRow('رقم المستلم', item.recipientPhone),
                _buildInfoRow('الحالة', _getStatusLabel(item.status), color: _getStatusColor(item.status)),
                _buildInfoRow('عدد المحاولات', '${item.attemptCount}'),
                _buildInfoRow('تاريخ الإنشاء', DateFormat('yyyy/MM/dd HH:mm').format(item.createdAt)),
                if (item.sentAt != null)
                  _buildInfoRow('تاريخ الإرسال', DateFormat('yyyy/MM/dd HH:mm').format(item.sentAt!)),
                if (item.errorMessage != null && item.errorMessage!.isNotEmpty)
                  _buildInfoRow('آخر خطأ', item.errorMessage!, color: AppColors.error),
                const Divider(color: Colors.white24, height: 24),
                const Text('محتوى الرسالة:', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.messagePayload,
                    style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إغلاق', style: TextStyle(color: AppColors.textSecondary)),
          ),
          if (item.canRetry)
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('إعادة المحاولة الآن'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () {
                Navigator.pop(ctx);
                context.read<WhatsAppCubit>().retrySingleMessage(item.id);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: color ?? Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'sent':
        return '✓ تم الإرسال';
      case 'sending':
        return '🔄 جاري الإرسال';
      case 'failed':
        return '⚠ فشل الإرسال';
      case 'pending':
      default:
        return '⏳ في الانتظار';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'sent':
        return AppColors.tableFree;
      case 'sending':
        return Colors.blueAccent;
      case 'failed':
        return AppColors.error;
      case 'pending':
      default:
        return Colors.amber;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('صندوق رسائل WhatsApp (Outbox)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<WhatsAppCubit>().loadStatus(),
          ),
        ],
      ),
      body: BlocBuilder<WhatsAppCubit, WhatsAppState>(
        builder: (context, state) {
          if (state is WhatsAppLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is WhatsAppStatusLoaded) {
            final messages = state.recentMessages;
            if (messages.isEmpty) {
              return const Center(
                child: Text(
                  'صندوق الرسائل فارغ',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final item = messages[index];
                final statusColor = _getStatusColor(item.status);
                final statusLabel = _getStatusLabel(item.status);

                return Card(
                  color: AppColors.surface,
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: statusColor.withAlpha(51),
                      child: Icon(
                        item.messageType == 'invoice' ? Icons.receipt : Icons.assessment,
                        color: statusColor,
                        size: 20,
                      ),
                    ),
                    title: Row(
                      children: [
                        Text(
                          item.messageType == 'invoice'
                              ? 'فاتورة #${item.invoiceId ?? item.id}'
                              : 'تقفيل يوم #${item.dailyClosingId ?? item.id}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withAlpha(51),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            statusLabel,
                            style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Row(
                        children: [
                          Text(
                            'المستلم: ${item.recipientPhone}',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            DateFormat('HH:mm – yyyy/MM/dd').format(item.createdAt),
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    trailing: item.canRetry
                        ? IconButton(
                            icon: const Icon(Icons.refresh, color: AppColors.primary),
                            tooltip: 'إعادة المحاولة',
                            onPressed: () => context.read<WhatsAppCubit>().retrySingleMessage(item.id),
                          )
                        : const Icon(Icons.arrow_forward_ios, color: AppColors.textSecondary, size: 16),
                    onTap: () => _showMessageDetails(context, item),
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
