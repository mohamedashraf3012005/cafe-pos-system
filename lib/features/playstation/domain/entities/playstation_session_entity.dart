/// Billing policy for PlayStation sessions
enum PsBillingPolicy { byMinute }

class PlayStationSessionEntity {
  final int id;
  final int? tableId;
  final int deviceId;
  final String deviceName;
  final DateTime startTime;
  final DateTime? endTime;
  final int? elapsedSeconds;
  /// Frozen at session start — immune to future price changes
  final double hourlyRate;
  final double calculatedAmount;
  /// 'active' | 'completed' | 'cancelled'
  final String status;
  final DateTime createdAt;
  final PsBillingPolicy billingPolicy;

  const PlayStationSessionEntity({
    required this.id,
    this.tableId,
    required this.deviceId,
    required this.deviceName,
    required this.startTime,
    this.endTime,
    this.elapsedSeconds,
    required this.hourlyRate,
    required this.calculatedAmount,
    required this.status,
    required this.createdAt,
    this.billingPolicy = PsBillingPolicy.byMinute,
  });

  bool get isActive => status == 'active';
  bool get isCompleted => status == 'completed';

  /// Elapsed duration — uses real timestamps (not a counter).
  /// Safe across app restarts, widget rebuilds, and navigation.
  Duration get elapsed {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  /// Calculate cost based on billing policy
  double get currentCost {
    switch (billingPolicy) {
      case PsBillingPolicy.byMinute:
        final minutes = elapsed.inSeconds / 60.0;
        return (minutes / 60.0) * hourlyRate;
    }
  }

  /// Format elapsed as HH:MM:SS
  String get formattedElapsed {
    final d = elapsed;
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  /// Human-readable duration, e.g. "1 ساعة و30 دقيقة"
  String get humanDuration {
    final d = elapsed;
    final h = d.inHours;
    final m = d.inMinutes % 60;
    if (h == 0) return '$m دقيقة';
    if (m == 0) return '$h ساعة';
    return '$h ساعة و$m دقيقة';
  }
}