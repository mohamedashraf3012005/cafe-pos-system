/// Abstract contract for sending WhatsApp messages.
abstract class WhatsAppRemoteDataSource {
  /// Send a text message via configured Backend Proxy or Direct Meta Cloud API.
  Future<void> sendMessage({
    required String recipientPhone,
    required String message,
  });

  /// Check if the WhatsApp endpoint / backend connection is healthy.
  Future<bool> checkConnection();
}

/// Thrown when WhatsApp message sending fails.
class WhatsAppSendException implements Exception {
  final String message;
  final int? statusCode;

  const WhatsAppSendException(this.message, {this.statusCode});

  @override
  String toString() => message;
}
