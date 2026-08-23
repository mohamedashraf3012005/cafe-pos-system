import 'package:equatable/equatable.dart';
import '../../domain/entities/playstation_device_entity.dart';
import '../../domain/entities/playstation_session_entity.dart';

abstract class PlayStationState extends Equatable {
  const PlayStationState();

  @override
  List<Object?> get props => [];
}

class PlayStationInitial extends PlayStationState {}

class PlayStationLoading extends PlayStationState {}

class PlayStationLoaded extends PlayStationState {
  final List<PlayStationDeviceEntity> devices;
  final PlayStationSessionEntity? activeSession;
  final List<PlayStationSessionEntity> sessionHistory;
  final int tick; // Updates every second for UI refresh without hitting DB

  const PlayStationLoaded({
    required this.devices,
    this.activeSession,
    this.sessionHistory = const [],
    this.tick = 0,
  });

  PlayStationLoaded copyWith({
    List<PlayStationDeviceEntity>? devices,
    PlayStationSessionEntity? activeSession,
    bool clearActiveSession = false,
    List<PlayStationSessionEntity>? sessionHistory,
    int? tick,
  }) {
    return PlayStationLoaded(
      devices: devices ?? this.devices,
      activeSession: clearActiveSession ? null : (activeSession ?? this.activeSession),
      sessionHistory: sessionHistory ?? this.sessionHistory,
      tick: tick ?? this.tick,
    );
  }

  @override
  List<Object?> get props => [devices, activeSession, sessionHistory, tick];
}

class PlayStationError extends PlayStationState {
  final String message;
  const PlayStationError(this.message);

  @override
  List<Object?> get props => [message];
}
