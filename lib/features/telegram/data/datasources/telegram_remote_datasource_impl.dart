import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../../core/services/telegram_settings_service.dart';
import 'telegram_remote_datasource.dart';

class TelegramRemoteDataSourceImpl implements TelegramRemoteDataSource {
  final TelegramSettingsService settingsService;

  static const Duration _timeout = Duration(seconds: 25);

  TelegramRemoteDataSourceImpl({required this.settingsService});

  @override
  Future<void> sendMessage({required String message}) async {
    final token = TelegramSettingsService.normalizeBotToken(settingsService.botToken);
    final chatId = settingsService.chatId.trim();

    if (token.isEmpty || chatId.isEmpty) {
      throw const TelegramSendException(
        'يرجى إدخال Telegram Bot Token و Chat ID في إعدادات التطبيق.',
      );
    }

    final uri = Uri.parse('https://api.telegram.org/bot$token/sendMessage');

    try {
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: jsonEncode({
              'chat_id': chatId,
              'text': message,
              'parse_mode': 'HTML',
            }),
          )
          .timeout(_timeout);

      final decoded = jsonDecode(response.body);

      if (response.statusCode != 200 || decoded['ok'] != true) {
        final description = decoded['description'] ?? response.body;
        throw TelegramSendException(
          'خطأ من Telegram API ($description). برجاء التأكد من صحة Bot Token و Chat ID وإرسال رسالة للبوت أولاً.',
          statusCode: response.statusCode,
        );
      }
    } on TelegramSendException {
      rethrow;
    } on HandshakeException catch (_) {
      throw const TelegramSendException(
        'فشل الاتصال الآمن بـ Telegram بسبب جدار الحماية/برنامج الحماية local proxy SSL.',
      );
    } on SocketException catch (_) {
      throw const TelegramSendException(
        'فشل الاتصال بـ Telegram API. يرجى التأكد من توفر اتصال الإنترنت.',
      );
    } catch (e) {
      final str = e.toString();
      if (str.contains('SocketException') || str.contains('ClientSocketException')) {
        throw const TelegramSendException(
          'فشل الاتصال بـ Telegram. يرجى التأكد من اتصال الإنترنت.',
        );
      }
      throw TelegramSendException('فشل إرسال رسالة تليجرام: $str');
    }
  }

  @override
  Future<bool> checkConnection() async {
    final token = TelegramSettingsService.normalizeBotToken(settingsService.botToken);
    if (token.isEmpty) return false;

    final uri = Uri.parse('https://api.telegram.org/bot$token/getMe');
    try {
      final response = await http
          .get(uri, headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 8));
      final decoded = jsonDecode(response.body);
      return response.statusCode == 200 && decoded['ok'] == true;
    } catch (_) {
      return false;
    }
  }
}
