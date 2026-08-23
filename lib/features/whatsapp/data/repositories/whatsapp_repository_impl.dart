import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/whatsapp_message_entity.dart';
import '../../domain/repositories/whatsapp_repository.dart';

class WhatsAppRepositoryImpl implements WhatsAppRepository {
  final AppDatabase db;

  WhatsAppRepositoryImpl(this.db);

  // ── Helpers ──────────────────────────────────────────────────────────────────

  WhatsAppMessageEntity _toEntity(WhatsAppQueueData row) {
    return WhatsAppMessageEntity(
      id: row.id,
      messageType: row.messageType,
      invoiceId: row.invoiceId,
      dailyClosingId: row.dailyClosingId,
      recipientPhone: row.recipientPhone,
      messagePayload: row.messagePayload,
      status: row.status,
      attemptCount: row.attemptCount,
      lastAttemptAt: row.lastAttemptAt,
      sentAt: row.sentAt,
      errorMessage: row.errorMessage,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  // ── Enqueue ──────────────────────────────────────────────────────────────────

  @override
  Future<int> enqueueInvoice({
    required int invoiceId,
    required String recipientPhone,
    required String messagePayload,
  }) async {
    return db.into(db.whatsAppQueue).insert(
          WhatsAppQueueCompanion.insert(
            messageType: 'invoice',
            invoiceId: Value(invoiceId),
            recipientPhone: recipientPhone,
            messagePayload: messagePayload,
            status: const Value('pending'),
          ),
        );
  }

  @override
  Future<int> enqueueDailyClosing({
    required int dailyClosingId,
    required String recipientPhone,
    required String messagePayload,
  }) async {
    return db.into(db.whatsAppQueue).insert(
          WhatsAppQueueCompanion.insert(
            messageType: 'daily_closing',
            dailyClosingId: Value(dailyClosingId),
            recipientPhone: recipientPhone,
            messagePayload: messagePayload,
            status: const Value('pending'),
          ),
        );
  }

  // ── Queries ──────────────────────────────────────────────────────────────────

  @override
  Future<List<WhatsAppMessageEntity>> getPendingMessages() async {
    final rows = await (db.select(db.whatsAppQueue)
          ..where((q) => q.status.equals('pending'))
          ..orderBy([(q) => OrderingTerm.asc(q.createdAt)]))
        .get();
    return rows.map(_toEntity).toList();
  }

  @override
  Future<List<WhatsAppMessageEntity>> getFailedMessages() async {
    final rows = await (db.select(db.whatsAppQueue)
          ..where((q) => q.status.equals('failed'))
          ..orderBy([(q) => OrderingTerm.desc(q.updatedAt)]))
        .get();
    return rows.map(_toEntity).toList();
  }

  @override
  Future<List<WhatsAppMessageEntity>> getAllMessages({int limit = 50}) async {
    final rows = await (db.select(db.whatsAppQueue)
          ..orderBy([(q) => OrderingTerm.desc(q.createdAt)])
          ..limit(limit))
        .get();
    return rows.map(_toEntity).toList();
  }

  @override
  Future<int> getPendingCount() async {
    final result = await db.customSelect(
      "SELECT COUNT(*) as cnt FROM whats_app_queue WHERE status = 'pending'",
    ).getSingle();
    return result.read<int>('cnt');
  }

  @override
  Future<int> getFailedCount() async {
    final result = await db.customSelect(
      "SELECT COUNT(*) as cnt FROM whats_app_queue WHERE status = 'failed'",
    ).getSingle();
    return result.read<int>('cnt');
  }

  @override
  Future<bool> isInvoiceAlreadySent(int invoiceId) async {
    final row = await (db.select(db.whatsAppQueue)
          ..where((q) => q.invoiceId.equals(invoiceId))
          ..where((q) => q.status.equals('sent'))
          ..limit(1))
        .getSingleOrNull();
    return row != null;
  }

  @override
  Future<bool> isDailyClosingAlreadySent(int dailyClosingId) async {
    final row = await (db.select(db.whatsAppQueue)
          ..where((q) => q.dailyClosingId.equals(dailyClosingId))
          ..where((q) => q.status.equals('sent'))
          ..limit(1))
        .getSingleOrNull();
    return row != null;
  }

  // ── Status Updates ───────────────────────────────────────────────────────────

  @override
  Future<void> markAsSending(int queueId) async {
    await (db.update(db.whatsAppQueue)..where((q) => q.id.equals(queueId)))
        .write(WhatsAppQueueCompanion(
      status: const Value('sending'),
      updatedAt: Value(DateTime.now()),
    ));
  }

  @override
  Future<void> markAsSent(int queueId) async {
    await (db.update(db.whatsAppQueue)..where((q) => q.id.equals(queueId)))
        .write(WhatsAppQueueCompanion(
      status: const Value('sent'),
      sentAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
    ));
  }

  @override
  Future<void> markAsFailed(int queueId, String errorMessage) async {
    // Get current attempt count
    final row = await (db.select(db.whatsAppQueue)
          ..where((q) => q.id.equals(queueId)))
        .getSingleOrNull();
    final newCount = (row?.attemptCount ?? 0) + 1;

    await (db.update(db.whatsAppQueue)..where((q) => q.id.equals(queueId)))
        .write(WhatsAppQueueCompanion(
      status: const Value('failed'),
      attemptCount: Value(newCount),
      lastAttemptAt: Value(DateTime.now()),
      errorMessage: Value(errorMessage),
      updatedAt: Value(DateTime.now()),
    ));
  }

  @override
  Future<void> resetToRetry(int queueId) async {
    await (db.update(db.whatsAppQueue)..where((q) => q.id.equals(queueId)))
        .write(WhatsAppQueueCompanion(
      status: const Value('pending'),
      updatedAt: Value(DateTime.now()),
    ));
  }
}
