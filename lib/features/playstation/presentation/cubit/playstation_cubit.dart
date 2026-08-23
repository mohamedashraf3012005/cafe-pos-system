import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/playstation_session_entity.dart';
import '../../domain/repositories/playstation_repository.dart';
import 'playstation_state.dart';

class PlayStationCubit extends Cubit<PlayStationState> {
  final PlayStationRepository repository;
  Timer? _tickerTimer;

  PlayStationCubit(this.repository) : super(PlayStationInitial());

  @override
  Future<void> close() {
    _tickerTimer?.cancel();
    return super.close();
  }

  void _startTicker() {
    _tickerTimer?.cancel();
    _tickerTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final s = state;
      if (s is PlayStationLoaded && s.activeSession != null && s.activeSession!.isActive) {
        emit(s.copyWith(tick: s.tick + 1));
      }
    });
  }

  Future<void> initForTable(int? tableId) async {
    emit(PlayStationLoading());
    try {
      final devices = await repository.getDevices();
      final activeSession = await repository.getActiveSessionForTable(tableId);
      emit(PlayStationLoaded(
        devices: devices,
        activeSession: activeSession,
      ));
      if (activeSession != null && activeSession.isActive) {
        _startTicker();
      }
    } catch (e) {
      emit(PlayStationError('خطأ أثناء تحميل بيانات البلايستيشن: ${e.toString()}'));
    }
  }

  Future<void> loadDevices() async {
    emit(PlayStationLoading());
    try {
      final devices = await repository.getDevices();
      emit(PlayStationLoaded(devices: devices));
    } catch (e) {
      emit(PlayStationError('??? ????? ????? ???????: ${e.toString()}'));
    }
  }

  Future<void> loadHistory({int? tableId}) async {
    emit(PlayStationLoading());
    try {
      final devices = await repository.getDevices();
      final List<PlayStationSessionEntity> history;
      if (tableId != null) {
        history = await repository.getSessionsForTable(tableId);
      } else {
        history = await repository.getAllSessions();
      }
      emit(PlayStationLoaded(
        devices: devices,
        sessionHistory: history,
      ));
    } catch (e) {
      emit(PlayStationError('??? ????? ????? ?????: ${e.toString()}'));
    }
  }

  Future<void> startSession({required int deviceId, required int? tableId}) async {
    try {
      final session = await repository.startSession(deviceId: deviceId, tableId: tableId);
      final s = state;
      if (s is PlayStationLoaded) {
        emit(s.copyWith(activeSession: session));
      } else {
        final devices = await repository.getDevices();
        emit(PlayStationLoaded(devices: devices, activeSession: session));
      }
      _startTicker();
    } catch (e) {
      emit(PlayStationError(e.toString()));
    }
  }

  Future<PlayStationSessionEntity?> stopSession(int sessionId) async {
    try {
      _tickerTimer?.cancel();
      final completedSession = await repository.stopSession(sessionId);
      final s = state;
      if (s is PlayStationLoaded) {
        emit(s.copyWith(clearActiveSession: true));
      }
      return completedSession;
    } catch (e) {
      emit(PlayStationError('??? ????? ????? ??????: ${e.toString()}'));
      return null;
    }
  }

  Future<void> cancelSession(int sessionId) async {
    try {
      _tickerTimer?.cancel();
      await repository.cancelSession(sessionId);
      final s = state;
      if (s is PlayStationLoaded) {
        emit(s.copyWith(clearActiveSession: true));
      }
    } catch (e) {
      emit(PlayStationError('??? ????? ????? ??????: ${e.toString()}'));
    }
  }

  // -- Device Management ------------------------------------------------------

  Future<void> addDevice(String name, double hourlyRate) async {
    try {
      await repository.addDevice(name, hourlyRate);
      await loadDevices();
    } catch (e) {
      emit(PlayStationError('??? ????? ????? ??????: ${e.toString()}'));
    }
  }

  Future<void> updateDevice(int id, String name, double hourlyRate) async {
    try {
      await repository.updateDevice(id, name, hourlyRate);
      await loadDevices();
    } catch (e) {
      emit(PlayStationError('??? ????? ????? ??????: ${e.toString()}'));
    }
  }

  Future<void> toggleDeviceStatus(int id, bool isActive) async {
    try {
      await repository.toggleDeviceStatus(id, isActive);
      await loadDevices();
    } catch (e) {
      emit(PlayStationError('??? ????? ????? ???? ??????: ${e.toString()}'));
    }
  }

  Future<void> deleteDevice(int id) async {
    try {
      await repository.deleteDevice(id);
      await loadDevices();
    } catch (e) {
      emit(PlayStationError(e.toString()));
    }
  }
}
