/// Represents a single WhatsApp outbox queue item.
class WhatsAppMessageEntity {
  final int id;
  final String messageType; // 'invoice' | 'daily_closing'
  final int? invoiceId;
  final int? dailyClosingId;
  final String recipientPhone;
  final String messagePayload; // JSON text
  final String status; // 'pending' | 'sending' | 'sent' | 'failed'
  final int attemptCount;
  final DateTime? lastAttemptAt;
  final DateTime? sentAt;
  final String? errorMessage;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WhatsAppMessageEntity({
    required this.id,
    required this.messageType,
    this.invoiceId,
    this.dailyClosingId,
    required this.recipientPhone,
    required this.messagePayload,
    required this.status,
    required this.attemptCount,
    this.lastAttemptAt,
    this.sentAt,
    this.errorMessage,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isPending => status == 'pending';
  bool get isSending => status == 'sending';
  bool get isSent => status == 'sent';
  bool get isFailed => status == 'failed';
  bool get canRetry => status == 'pending' || status == 'failed';
}
