import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// A single audit log entry for tracking admin-protected operations.
class AuditLogEntry {
  final String username;
  final String dateTime;
  final String actionType; // 'cancel_table_order', 'remove_table'
  final String target; // e.g. 'طاولة 5', 'أوردر #12'
  final String reason;

  AuditLogEntry({
    required this.username,
    required this.dateTime,
    required this.actionType,
    required this.target,
    required this.reason,
  });

  Map<String, dynamic> toJson() => {
        'username': username,
        'dateTime': dateTime,
        'actionType': actionType,
        'target': target,
        'reason': reason,
      };

  factory AuditLogEntry.fromJson(Map<String, dynamic> json) => AuditLogEntry(
        username: json['username'] ?? '',
        dateTime: json['dateTime'] ?? '',
        actionType: json['actionType'] ?? '',
        target: json['target'] ?? '',
        reason: json['reason'] ?? '',
      );
}

/// Persists audit-log entries in a local JSON file.
/// Uses [path_provider] to store the file inside the app's documents directory
/// so no DB schema change is needed.
class AuditLogService {
  static const _fileName = 'audit_log.json';
  File? _file;

  /// Lazily resolve the log file path.
  Future<File> _getFile() async {
    if (_file != null) return _file!;
    final dir = await getApplicationDocumentsDirectory();
    _file = File('${dir.path}/$_fileName');
    return _file!;
  }

  /// Append a new entry to the log file.
  Future<void> log({
    required String username,
    required String actionType,
    required String target,
    String reason = '',
  }) async {
    final entry = AuditLogEntry(
      username: username,
      dateTime: DateTime.now().toIso8601String(),
      actionType: actionType,
      target: target,
      reason: reason,
    );

    final file = await _getFile();
    List<Map<String, dynamic>> entries = [];

    if (await file.exists()) {
      try {
        final content = await file.readAsString();
        if (content.isNotEmpty) {
          entries = List<Map<String, dynamic>>.from(jsonDecode(content));
        }
      } catch (_) {
        // If the file is corrupted, start fresh
        entries = [];
      }
    }

    entries.add(entry.toJson());
    await file.writeAsString(jsonEncode(entries));
  }

  /// Read all log entries (useful for future admin reports).
  Future<List<AuditLogEntry>> getAll() async {
    final file = await _getFile();
    if (!await file.exists()) return [];

    try {
      final content = await file.readAsString();
      if (content.isEmpty) return [];
      final list = List<Map<String, dynamic>>.from(jsonDecode(content));
      return list.map((e) => AuditLogEntry.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }
}
