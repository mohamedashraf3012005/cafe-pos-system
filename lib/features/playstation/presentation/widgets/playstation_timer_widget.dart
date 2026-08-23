import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cash_cafe/core/constants/app_colors.dart';
import 'package:cash_cafe/features/playstation/domain/entities/playstation_device_entity.dart';
import 'package:cash_cafe/features/playstation/domain/entities/playstation_session_entity.dart';
import 'package:cash_cafe/features/playstation/presentation/cubit/playstation_cubit.dart';
import 'package:cash_cafe/features/playstation/presentation/cubit/playstation_state.dart';

class PlayStationTimerWidget extends StatelessWidget {
  final int? tableId;
  final int? tableNumber;
  final Function(PlayStationSessionEntity completedSession)? onSessionStopped;

  const PlayStationTimerWidget({
    super.key,
    required this.tableId,
    this.tableNumber,
    this.onSessionStopped,
  });

  Future<void> _showStartDialog(BuildContext context, List<PlayStationDeviceEntity> devices) async {
    final activeDevices = devices.where((d) => d.isActive).toList();
    if (activeDevices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لا توجد أجهزة بلايستيشن متاحة. يرجى إضافتها من الإعدادات.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    PlayStationDeviceEntity selectedDevice = activeDevices.first;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.sports_esports, color: AppColors.secondary, size: 28),
                  SizedBox(width: 8),
                  Text('تشغيل البلايستيشن', style: TextStyle(color: Colors.white, fontSize: 20)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('اختر الجهاز:', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<PlayStationDeviceEntity>(
                    initialValue: selectedDevice,
                    dropdownColor: AppColors.surface,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      filled: true,
                      fillColor: AppColors.background,
                    ),
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                    items: activeDevices.map((d) {
                      return DropdownMenuItem(
                        value: d,
                        child: Text('${d.name} (${d.hourlyRate.toStringAsFixed(0)} ج.م / ساعة)'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() => selectedDevice = val);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(26),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.primary.withAlpha(77)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('سعر الساعة:', style: TextStyle(color: Colors.white70)),
                            Text('${selectedDevice.hourlyRate.toStringAsFixed(2)} ج.م',
                                style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('طريقة الحساب:', style: TextStyle(color: Colors.white70)),
                            Text('بالدقيقة (دقيق)', style: TextStyle(color: AppColors.tableFree, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('إلغاء', style: TextStyle(color: AppColors.textSecondary)),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('بدء الجلسة'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.tableFree),
                  onPressed: () => Navigator.pop(ctx, true),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed == true && context.mounted) {
      context.read<PlayStationCubit>().startSession(
            deviceId: selectedDevice.id,
            tableId: tableId,
          );
    }
  }

  Future<void> _showStopDialog(BuildContext context, PlayStationSessionEntity session) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.stop_circle, color: AppColors.error, size: 28),
              SizedBox(width: 8),
              Text('إيقاف البلايستيشن', style: TextStyle(color: Colors.white, fontSize: 20)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('الجهاز: ${session.deviceName}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('مدة الاستخدام: ${session.formattedElapsed}', style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 4),
              Text('سعر الساعة: ${session.hourlyRate.toStringAsFixed(2)} ج.م', style: const TextStyle(color: Colors.white70)),
              const Divider(color: Colors.white24, height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('المبلغ المطلوب:', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(
                    '${session.currentCost.toStringAsFixed(2)} ج.م',
                    style: const TextStyle(color: AppColors.secondary, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('تراجع', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.check),
              label: const Text('إيقاف وإضافة للفاتورة'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () => Navigator.pop(ctx, true),
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      final completed = await context.read<PlayStationCubit>().stopSession(session.id);
      if (completed != null && onSessionStopped != null) {
        onSessionStopped!(completed);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayStationCubit, PlayStationState>(
      builder: (context, state) {
        if (state is PlayStationLoading) {
          return const SizedBox(
            height: 60,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }

        if (state is PlayStationLoaded) {
          final session = state.activeSession;

          if (session != null && session.isActive) {
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF1A237E).withAlpha(153),
                    const Color(0xFF0D47A1).withAlpha(102),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blueAccent.withAlpha(128), width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.sports_esports, color: Colors.lightBlueAccent, size: 22),
                          const SizedBox(width: 6),
                          Text(
                            session.deviceName,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.withAlpha(51),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.greenAccent),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.circle, color: Colors.greenAccent, size: 8),
                            SizedBox(width: 4),
                            Text('يعمل الآن', style: TextStyle(color: Colors.greenAccent, fontSize: 11)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('الوقت المنقضي', style: TextStyle(color: Colors.white60, fontSize: 11)),
                          const SizedBox(height: 2),
                          Text(
                            session.formattedElapsed,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('التكلفة الحالية', style: TextStyle(color: Colors.white60, fontSize: 11)),
                          const SizedBox(height: 2),
                          Text(
                            '${session.currentCost.toStringAsFixed(2)} ج.م',
                            style: const TextStyle(
                              color: AppColors.secondary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.cancel, size: 16, color: AppColors.error),
                          label: const Text('إلغاء الجلسة', style: TextStyle(color: AppColors.error, fontSize: 12)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.error),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (c) => AlertDialog(
                                backgroundColor: AppColors.surface,
                                title: const Text('تأكيد إلغاء الجلسة', style: TextStyle(color: Colors.white)),
                                content: const Text('هل تريد إلغاء جلسة البلايستيشن بدون حساب تكلفة؟',
                                    style: TextStyle(color: AppColors.textSecondary)),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('تراجع')),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                                    onPressed: () => Navigator.pop(c, true),
                                    child: const Text('نعم، إلغاء'),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true && context.mounted) {
                              context.read<PlayStationCubit>().cancelSession(session.id);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.stop, size: 18),
                          label: const Text('إيقاف البلايستيشن', style: TextStyle(fontSize: 13)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          onPressed: () => _showStopDialog(context, session),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          } else {
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withAlpha(38),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.sports_esports, color: Colors.lightBlueAccent, size: 28),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('بلايستيشن', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                        Text('الجهاز متاح للتشغيل', style: TextStyle(color: Colors.white54, fontSize: 12)),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.play_arrow, size: 18),
                    label: const Text('تشغيل', style: TextStyle(fontSize: 13)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    onPressed: () => _showStartDialog(context, state.devices),
                  ),
                ],
              ),
            );
          }
        }

        return const SizedBox.shrink();
      },
    );
  }
}
