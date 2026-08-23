class PlayStationDeviceEntity {
  final int id;
  final String name;
  final double hourlyRate;
  final bool isActive;
  final DateTime createdAt;

  const PlayStationDeviceEntity({
    required this.id,
    required this.name,
    required this.hourlyRate,
    required this.isActive,
    required this.createdAt,
  });
}