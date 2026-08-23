/// Abstract contract for sending messages to Telegram via Bot API.
abstract class TelegramRemoteDataSource {
  /// Send a text message to the configured Telegram Chat ID.
  Future<void> sendMessage({
    required String message,
  });

  /// Check if Bot Token and Chat ID are valid and reach Telegram API.
  Future<bool> checkConnection();
}

/// Custom Exception thrown on Telegram API errors.
class TelegramSendException implements Exception {
  final String message;
  final int? statusCode;

  const TelegramSendException(this.message, {this.statusCode});

  @override
  String toString() => message;
}
