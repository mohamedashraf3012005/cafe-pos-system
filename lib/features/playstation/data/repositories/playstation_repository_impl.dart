import 'package:drift/drift.dart';
import 'package:cash_cafe/core/database/app_database.dart';
import 'package:cash_cafe/features/playstation/domain/entities/playstation_device_entity.dart';
import 'package:cash_cafe/features/playstation/domain/entities/playstation_session_entity.dart';
import 'package:cash_cafe/features/playstation/domain/repositories/playstation_repository.dart';

class PlayStationRepositoryImpl implements PlayStationRepository {
  final AppDatabase db;

  PlayStationRepositoryImpl(this.db);

  PlayStationDeviceEntity _deviceToEntity(PlayStationDevice d) {
    return PlayStationDeviceEntity(
      id: d.id,
      name: d.name,
      hourlyRate: d.hourlyRate,
      isActive: d.isActive,
      createdAt: d.createdAt,
    );
  }

  PlayStationSessionEntity _sessionToEntity(PlayStationSession s, String deviceName) {
    return PlayStationSessionEntity(
      id: s.id,
      tableId: s.tableId,
      deviceId: s.deviceId,
      deviceName: deviceName,
      startTime: s.startTime,
      endTime: s.endTime,
      elapsedSeconds: s.elapsedSeconds,
      hourlyRate: s.hourlyRate,
      calculatedAmount: s.calculatedAmount,
      status: s.status,
      createdAt: s.createdAt,
    );
  }

  @override
  Future<List<PlayStationDeviceEntity>> getDevices() async {
    final rows = await (db.select(db.playStationDevices)
          ..orderBy([(d) => OrderingTerm.asc(d.id)]))
        .get();
    return rows.map(_deviceToEntity).toList();
  }

  @override
  Future<PlayStationDeviceEntity?> getDeviceById(int id) async {
    final row = await (db.select(db.playStationDevices)
          ..where((d) => d.id.equals(id)))
        .getSingleOrNull();
    return row != null ? _deviceToEntity(row) : null;
  }

  @override
  Future<void> addDevice(String name, double hourlyRate) async {
    await db.into(db.playStationDevices).insert(
          PlayStationDevicesCompanion.insert(
            name: name,
            hourlyRate: Value(hourlyRate),
            isActive: const Value(true),
          ),
        );
  }

  @override
  Future<void> updateDevice(int id, String name, double hourlyRate) async {
    await (db.update(db.playStationDevices)..where((d) => d.id.equals(id))).write(
      PlayStationDevicesCompanion(
        name: Value(name),
        hourlyRate: Value(hourlyRate),
      ),
    );
  }

  @override
  Future<void> toggleDeviceStatus(int id, bool isActive) async {
    await (db.update(db.playStationDevices)..where((d) => d.id.equals(id))).write(
      PlayStationDevicesCompanion(isActive: Value(isActive)),
    );
  }

  @override
  Future<void> deleteDevice(int id) async {
    final activeSessions = await (db.select(db.playStationSessions)
          ..where((s) => s.deviceId.equals(id) & s.status.equals('active')))
        .get();
    if (activeSessions.isNotEmpty) {
      throw Exception('لا يمكن حذف الجهاز أثناء وجود جلسة نشطة عليه');
    }
    await (db.delete(db.playStationDevices)..where((d) => d.id.equals(id))).go();
  }

  @override
  Future<PlayStationSessionEntity> startSession({
    required int deviceId,
    required int? tableId,
  }) async {
    if (tableId != null) {
      final existing = await (db.select(db.playStationSessions)
            ..where((s) => s.tableId.equals(tableId) & s.status.equals('active')))
          .getSingleOrNull();
      if (existing != null) {
        throw Exception('يوجد جلسة بلايستيشن قيد التشغيل بالفعل على هذه الطاولة');
      }
    }

    final device = await (db.select(db.playStationDevices)..where((d) => d.id.equals(deviceId))).getSingle();
    final now = DateTime.now();

    final sessionId = await db.into(db.playStationSessions).insert(
          PlayStationSessionsCompanion.insert(
            tableId: Value(tableId),
            deviceId: deviceId,
            startTime: now,
            hourlyRate: device.hourlyRate,
            calculatedAmount: const Value(0.0),
            status: const Value('active'),
            createdAt: Value(now),
          ),
        );

    final sessionRow = await (db.select(db.playStationSessions)..where((s) => s.id.equals(sessionId))).getSingle();
    return _sessionToEntity(sessionRow, device.name);
  }

  @override
  Future<PlayStationSessionEntity?> getActiveSessionForTable(int? tableId) async {
    final query = db.select(db.playStationSessions).join([
      innerJoin(db.playStationDevices, db.playStationDevices.id.equalsExp(db.playStationSessions.deviceId)),
    ])..where(db.playStationSessions.status.equals('active'));

    if (tableId != null) {
      query.where(db.playStationSessions.tableId.equals(tableId));
    } else {
      query.where(db.playStationSessions.tableId.isNull());
    }

    query.limit(1);
    final row = await query.getSingleOrNull();
    if (row == null) return null;

    final session = row.readTable(db.playStationSessions);
    final device = row.readTable(db.playStationDevices);
    return _sessionToEntity(session, device.name);
  }

  @override
  Future<PlayStationSessionEntity> stopSession(int sessionId) async {
    final sessionRow = await (db.select(db.playStationSessions)..where((s) => s.id.equals(sessionId))).getSingle();
    final deviceRow = await (db.select(db.playStationDevices)..where((d) => d.id.equals(sessionRow.deviceId))).getSingle();

    final now = DateTime.now();
    final elapsedSec = now.difference(sessionRow.startTime).inSeconds;
    final elapsedMinutes = elapsedSec / 60.0;
    final amount = (elapsedMinutes / 60.0) * sessionRow.hourlyRate;

    await (db.update(db.playStationSessions)..where((s) => s.id.equals(sessionId))).write(
      PlayStationSessionsCompanion(
        endTime: Value(now),
        elapsedSeconds: Value(elapsedSec),
        calculatedAmount: Value(amount),
        status: const Value('completed'),
      ),
    );

    final updated = await (db.select(db.playStationSessions)..where((s) => s.id.equals(sessionId))).getSingle();
    return _sessionToEntity(updated, deviceRow.name);
  }

  @override
  Future<void> cancelSession(int sessionId) async {
    final now = DateTime.now();
    final sessionRow = await (db.select(db.playStationSessions)..where((s) => s.id.equals(sessionId))).getSingle();
    final elapsedSec = now.difference(sessionRow.startTime).inSeconds;

    await (db.update(db.playStationSessions)..where((s) => s.id.equals(sessionId))).write(
      PlayStationSessionsCompanion(
        endTime: Value(now),
        elapsedSeconds: Value(elapsedSec),
        status: const Value('cancelled'),
      ),
    );
  }

  @override
  Future<List<PlayStationSessionEntity>> getSessionsForTable(int tableId) async {
    final query = db.select(db.playStationSessions).join([
      innerJoin(db.playStationDevices, db.playStationDevices.id.equalsExp(db.playStationSessions.deviceId)),
    ])
      ..where(db.playStationSessions.tableId.equals(tableId))
      ..orderBy([OrderingTerm.desc(db.playStationSessions.startTime)]);

    final rows = await query.get();
    return rows.map((row) {
      final s = row.readTable(db.playStationSessions);
      final d = row.readTable(db.playStationDevices);
      return _sessionToEntity(s, d.name);
    }).toList();
  }

  @override
  Future<List<PlayStationSessionEntity>> getAllSessions({
    DateTime? from,
    DateTime? to,
    String? status,
  }) async {
    final query = db.select(db.playStationSessions).join([
      innerJoin(db.playStationDevices, db.playStationDevices.id.equalsExp(db.playStationSessions.deviceId)),
    ]);

    if (from != null) {
      query.where(db.playStationSessions.startTime.isBiggerOrEqualValue(from));
    }
    if (to != null) {
      query.where(db.playStationSessions.startTime.isSmallerOrEqualValue(to));
    }
    if (status != null) {
      query.where(db.playStationSessions.status.equals(status));
    }

    query.orderBy([OrderingTerm.desc(db.playStationSessions.startTime)]);

    final rows = await query.get();
    return rows.map((row) {
      final s = row.readTable(db.playStationSessions);
      final d = row.readTable(db.playStationDevices);
      return _sessionToEntity(s, d.name);
    }).toList();
  }

  @override
  Future<double> getTotalRevenue({DateTime? from, DateTime? to}) async {
    final sessions = await getAllSessions(from: from, to: to, status: 'completed');
    return sessions.fold<double>(0.0, (sum, s) => sum + s.calculatedAmount);
  }

  @override
  Future<int> getSessionCount({DateTime? from, DateTime? to}) async {
    final sessions = await getAllSessions(from: from, to: to, status: 'completed');
    return sessions.length;
  }

  @override
  Future<int> getTotalSeconds({DateTime? from, DateTime? to}) async {
    final sessions = await getAllSessions(from: from, to: to, status: 'completed');
    return sessions.fold<int>(0, (sum, s) => sum + (s.elapsedSeconds ?? s.elapsed.inSeconds));
  }
}