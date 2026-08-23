import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../injection_container.dart' as di;
import '../../domain/entities/playstation_session_entity.dart';
import '../cubit/playstation_cubit.dart';
import '../cubit/playstation_state.dart';

class PlayStationHistoryPage extends StatelessWidget {
  final int? tableId;
  final int? tableNumber;

  const PlayStationHistoryPage({super.key, this.tableId, this.tableNumber});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<PlayStationCubit>()..loadHistory(tableId: tableId),
      child: Scaffold(
        appBar: AppBar(
          title: Text(tableNumber != null ? 'سجل بلايستيشن - طاولة $tableNumber' : 'سجل جلسات PlayStation'),
        ),
        body: BlocBuilder<PlayStationCubit, PlayStationState>(
          builder: (context, state) {
            if (state is PlayStationLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is PlayStationLoaded) {
              final history = state.sessionHistory;

              if (history.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history_toggle_off, size: 64, color: Colors.white24),
                      SizedBox(height: 16),
                      Text('لا توجد جلسات مسجلة بعد', style: TextStyle(color: Colors.white54, fontSize: 16)),
                    ],
                  ),
                );
              }

              double totalRevenue = 0.0;
              int totalSeconds = 0;
              for (final PlayStationSessionEntity s in history) {
                if (s.isCompleted) {
                  totalRevenue += s.calculatedAmount;
                  totalSeconds += s.elapsedSeconds ?? s.elapsed.inSeconds;
                }
              }
              final totalHours = totalSeconds ~/ 3600;
              final totalMinutes = (totalSeconds % 3600) ~/ 60;

              return Column(
                children: [
                  // Summary Banner
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStat('عدد الجلسات', '${history.length}', Icons.sports_esports),
                        _buildStat('إجمالي الوقت', '${totalHours}h ${totalMinutes}m', Icons.timer),
                        _buildStat('إجمالي الإيرادات', '${totalRevenue.toStringAsFixed(2)} ج.م', Icons.monetization_on),
                      ],
                    ),
                  ),

                  // Session List
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        final session = history[index];
                        final dateStr = DateFormat('yyyy/MM/dd HH:mm').format(session.startTime);
                        final endDateStr = session.endTime != null
                            ? DateFormat('HH:mm').format(session.endTime!)
                            : 'قيد التشغيل';

                        return Card(
                          color: AppColors.surface,
                          margin: const EdgeInsets.only(bottom: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: (session.isActive ? Colors.green : (session.isCompleted ? Colors.blue : Colors.red))
                                        .withAlpha(38),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    session.isActive
                                        ? Icons.play_circle_fill
                                        : (session.isCompleted ? Icons.check_circle : Icons.cancel),
                                    color: session.isActive
                                        ? Colors.greenAccent
                                        : (session.isCompleted ? Colors.blueAccent : AppColors.error),
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            session.deviceName,
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                                          ),
                                          if (session.tableId != null) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                              decoration: BoxDecoration(
                                                color: Colors.white12,
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                'طاولة ${session.tableId}',
                                                style: const TextStyle(color: Colors.white70, fontSize: 11),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '$dateStr → $endDateStr (${session.humanDuration})',
                                        style: const TextStyle(color: Colors.white54, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${session.calculatedAmount.toStringAsFixed(2)} ج.م',
                                      style: const TextStyle(
                                        color: AppColors.secondary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      '${session.hourlyRate.toStringAsFixed(0)} ج.م/ساعة',
                                      style: const TextStyle(color: Colors.white38, fontSize: 11),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildStat(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        Text(title, style: const TextStyle(color: Colors.white54, fontSize: 11)),
      ],
    );
  }
}