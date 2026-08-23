import '../entities/playstation_device_entity.dart';
import '../entities/playstation_session_entity.dart';

abstract class PlayStationRepository {
  /// Get all active PlayStation devices
  Future<List<PlayStationDeviceEntity>> getDevices();

  /// Get a single device by id
  Future<PlayStationDeviceEntity?> getDeviceById(int id);

  /// Add a new device
  Future<void> addDevice(String name, double hourlyRate);

  /// Update an existing device
  Future<void> updateDevice(int id, String name, double hourlyRate);

  /// Toggle device active status
  Future<void> toggleDeviceStatus(int id, bool isActive);

  /// Delete a device (only if no active sessions)
  Future<void> deleteDevice(int id);

  // -- Sessions ---------------------------------------------------------------

  /// Start a PlayStation session for a table
  Future<PlayStationSessionEntity> startSession({
    required int deviceId,
    required int? tableId,
  });

  /// Get active session for a table (null if none)
  Future<PlayStationSessionEntity?> getActiveSessionForTable(int? tableId);

  /// Stop a session and calculate final cost
  Future<PlayStationSessionEntity> stopSession(int sessionId);

  /// Cancel a session without billing
  Future<void> cancelSession(int sessionId);

  /// Get all sessions for a table (history)
  Future<List<PlayStationSessionEntity>> getSessionsForTable(int tableId);

  /// Get all sessions history (for reports)
  Future<List<PlayStationSessionEntity>> getAllSessions({
    DateTime? from,
    DateTime? to,
    String? status,
  });

  /// Get total PlayStation revenue for a date range
  Future<double> getTotalRevenue({DateTime? from, DateTime? to});

  /// Get count of sessions for a date range
  Future<int> getSessionCount({DateTime? from, DateTime? to});

  /// Get total hours played for a date range
  Future<int> getTotalSeconds({DateTime? from, DateTime? to});
}
