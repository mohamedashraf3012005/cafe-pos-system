import '../entities/whatsapp_message_entity.dart';

/// Abstract contract for all WhatsApp queue operations.
/// Data flows: Presentation → Cubit → Repository → DB (local) or RemoteDataSource (network).
abstract class WhatsAppRepository {
  // ── Queue Management ─────────────────────────────────────────────────────────

  /// Add an invoice to the send queue.
  /// Returns the new queue-item id.
  Future<int> enqueueInvoice({
    required int invoiceId,
    required String recipientPhone,
    required String messagePayload,
  });

  /// Add a daily closing report to the send queue.
  Future<int> enqueueDailyClosing({
    required int dailyClosingId,
    required String recipientPhone,
    required String messagePayload,
  });

  // ── Queue Queries ────────────────────────────────────────────────────────────

  Future<List<WhatsAppMessageEntity>> getPendingMessages();
  Future<List<WhatsAppMessageEntity>> getFailedMessages();
  Future<List<WhatsAppMessageEntity>> getAllMessages({int limit = 50});
  Future<int> getPendingCount();
  Future<int> getFailedCount();

  /// Returns true if a sent queue item already exists for this invoiceId.
  Future<bool> isInvoiceAlreadySent(int invoiceId);

  /// Returns true if a sent queue item already exists for this dailyClosingId.
  Future<bool> isDailyClosingAlreadySent(int dailyClosingId);

  // ── Status Updates ───────────────────────────────────────────────────────────

  Future<void> markAsSending(int queueId);
  Future<void> markAsSent(int queueId);
  Future<void> markAsFailed(int queueId, String errorMessage);
  Future<void> resetToRetry(int queueId);
}
