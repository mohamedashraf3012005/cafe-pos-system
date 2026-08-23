import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cash_cafe/core/constants/app_colors.dart';
import 'package:cash_cafe/injection_container.dart' as di;
import 'package:cash_cafe/features/playstation/domain/entities/playstation_device_entity.dart';
import 'package:cash_cafe/features/playstation/presentation/cubit/playstation_cubit.dart';
import 'package:cash_cafe/features/playstation/presentation/cubit/playstation_state.dart';
import 'package:cash_cafe/features/playstation/presentation/pages/playstation_history_page.dart';

class PlayStationSettingsPage extends StatelessWidget {
  const PlayStationSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<PlayStationCubit>()..loadDevices(),
      child: const _PlayStationSettingsView(),
    );
  }
}

class _PlayStationSettingsView extends StatelessWidget {
  const _PlayStationSettingsView();

  Future<void> _showDeviceDialog(BuildContext context, {PlayStationDeviceEntity? device}) async {
    final nameController = TextEditingController(text: device?.name ?? '');
    final rateController = TextEditingController(text: device != null ? device.hourlyRate.toStringAsFixed(2) : '50.00');

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            device == null ? 'إضافة جهاز بلايستيشن' : 'تعديل جهاز بلايستيشن',
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'اسم الجهاز (مثال: PlayStation 5)',
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: rateController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'سعر الساعة (ج.م)',
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('إلغاء', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () {
                if (nameController.text.trim().isNotEmpty && double.tryParse(rateController.text.trim()) != null) {
                  Navigator.pop(ctx, true);
                }
              },
              child: Text(device == null ? 'إضافة' : 'حفظ التعديلات'),
            ),
          ],
        );
      },
    );

    if (result == true && context.mounted) {
      final name = nameController.text.trim();
      final rate = double.parse(rateController.text.trim());
      final cubit = context.read<PlayStationCubit>();
      if (device == null) {
        await cubit.addDevice(name, rate);
      } else {
        await cubit.updateDevice(device.id, name, rate);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إعدادات أجهزة PlayStation'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'سجل الجلسات',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PlayStationHistoryPage()),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('إضافة جهاز جديد'),
        onPressed: () => _showDeviceDialog(context),
      ),
      body: BlocConsumer<PlayStationCubit, PlayStationState>(
        listener: (context, state) {
          if (state is PlayStationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
            );
          }
        },
        builder: (context, state) {
          if (state is PlayStationLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PlayStationLoaded) {
            final devices = state.devices;

            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blueAccent.withAlpha(77)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blueAccent, size: 24),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'سياسة التسعير: الحساب بالدقيقة',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'يتم حساب التكلفة وفق المعادلة: (دقائق الاستخدام ÷ 60) × سعر الساعة.\nالسعر يثبت عند بداية كل جلسة حتى لو تم تعديل سعر الجهاز لاحقاً.',
                                style: TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('الأجهزة المسجلة', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 16),
                  if (devices.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text('لا توجد أجهزة مسجلة بعد. اضغط "إضافة جهاز جديد" للبدء.',
                            style: TextStyle(color: Colors.white54, fontSize: 16)),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: devices.length,
                        itemBuilder: (context, index) {
                          final device = devices[index];
                          return Card(
                            color: AppColors.surface,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: device.isActive ? Colors.blueAccent.withAlpha(102) : Colors.white12,
                              ),
                            ),
                            child: ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: (device.isActive ? Colors.blueAccent : Colors.grey).withAlpha(51),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.sports_esports,
                                  color: device.isActive ? Colors.blueAccent : Colors.grey,
                                  size: 28,
                                ),
                              ),
                              title: Text(
                                device.name,
                                style: TextStyle(
                                  color: device.isActive ? Colors.white : Colors.white54,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Text(
                                '${device.hourlyRate.toStringAsFixed(2)} ج.م / ساعة • ${device.isActive ? "نشط ومتاح" : "معطل"}',
                                style: const TextStyle(color: AppColors.secondary, fontSize: 13),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Switch(
                                    value: device.isActive,
                                    activeThumbColor: AppColors.tableFree,
                                    onChanged: (val) {
                                      context.read<PlayStationCubit>().toggleDeviceStatus(device.id, val);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.white70),
                                    onPressed: () => _showDeviceDialog(context, device: device),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: AppColors.error),
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (c) => AlertDialog(
                                          backgroundColor: AppColors.surface,
                                          title: const Text('تأكيد الحذف', style: TextStyle(color: Colors.white)),
                                          content: Text('هل تريد حذف الجهاز "${device.name}"؟',
                                              style: const TextStyle(color: AppColors.textSecondary)),
                                          actions: [
                                            TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('إلغاء')),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                                              onPressed: () => Navigator.pop(c, true),
                                              child: const Text('حذف'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm == true && context.mounted) {
                                        context.read<PlayStationCubit>().deleteDevice(device.id);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}