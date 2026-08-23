import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../../core/services/whatsapp_settings_service.dart';
import 'whatsapp_remote_datasource.dart';

class WhatsAppRemoteDataSourceImpl implements WhatsAppRemoteDataSource {
  final WhatsAppSettingsService settingsService;

  static const Duration _timeout = Duration(seconds: 30);

  WhatsAppRemoteDataSourceImpl({required this.settingsService});

  @override
  Future<void> sendMessage({
    required String recipientPhone,
    required String message,
  }) async {
    final mode = settingsService.mode;

    if (mode == 'direct_meta') {
      await _sendViaMetaDirect(recipientPhone: recipientPhone, message: message);
    } else {
      await _sendViaBackendServer(recipientPhone: recipientPhone, message: message);
    }
  }

  Future<void> _sendViaBackendServer({
    required String recipientPhone,
    required String message,
  }) async {
    final baseUrl = settingsService.backendUrl.trim();
    if (baseUrl.isEmpty || baseUrl.contains('your-backend.com')) {
      throw const WhatsAppSendException(
        'يرجى إدخال رابط خادم صحيح (Backend URL) في إعدادات WhatsApp أو اختيار الربط المباشر بـ Meta Cloud API.',
      );
    }

    final urlString = baseUrl.endsWith('/') ? '${baseUrl}send' : '$baseUrl/send';
    final uri = Uri.parse(urlString);

    try {
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: jsonEncode({
              'to': recipientPhone,
              'message': message,
            }),
          )
          .timeout(_timeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw WhatsAppSendException(
          'الخادم أرجع خطأ HTTP ${response.statusCode}: ${response.body}',
          statusCode: response.statusCode,
        );
      }
    } on WhatsAppSendException {
      rethrow;
    } on SocketException catch (_) {
      throw const WhatsAppSendException(
        'فشل الاتصال بالخادم. يرجى التأكد من تشغيل سيرفر الـ Backend وتأكد من الرابط.',
      );
    } catch (e) {
      final str = e.toString();
      if (str.contains('ClientSocketException') ||
          str.contains('SocketException') ||
          str.contains('Failed host lookup')) {
        throw const WhatsAppSendException(
          'فشل الاتصال بالخادم. يرجى التأكد من تشغيل سيرفر الـ Backend أو صحة الرابط في الإعدادات.',
        );
      }
      throw WhatsAppSendException('فشل إرسال الرسالة: $str');
    }
  }

  Future<void> _sendViaMetaDirect({
    required String recipientPhone,
    required String message,
  }) async {
    final phoneId = settingsService.metaPhoneId.trim();
    final token = settingsService.metaToken.trim();

    if (phoneId.isEmpty || token.isEmpty) {
      throw const WhatsAppSendException(
        'يرجى إدخال Meta Phone Number ID والـ Access Token في إعدادات WhatsApp.',
      );
    }

    // Meta expects phone number without leading '+' (e.g. 201002773665)
    final normalizedPhone = recipientPhone.replaceAll('+', '').replaceAll(' ', '');
    final uri = Uri.parse('https://graph.facebook.com/v18.0/$phoneId/messages');

    try {
      final response = await http
          .post(
            uri,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'messaging_product': 'whatsapp',
              'recipient_type': 'individual',
              'to': normalizedPhone,
              'type': 'text',
              'text': {
                'preview_url': false,
                'body': message,
              },
            }),
          )
          .timeout(_timeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final decoded = jsonDecode(response.body);
        final errText = decoded['error']?['message'] ?? response.body;
        throw WhatsAppSendException(
          'خطأ من Meta API (${response.statusCode}): $errText',
          statusCode: response.statusCode,
        );
      }
    } on WhatsAppSendException {
      rethrow;
    } on SocketException catch (_) {
      throw const WhatsAppSendException('لا يوجد اتصال بالإنترنت للربط مع Meta API.');
    } catch (e) {
      final str = e.toString();
      if (str.contains('ClientSocketException') || str.contains('SocketException')) {
        throw const WhatsAppSendException('فشل الاتصال بـ Meta API. يرجى التأكد من اتصال الإنترنت.');
      }
      throw WhatsAppSendException('خطأ في إرسال الرسالة: $str');
    }
  }

  @override
  Future<bool> checkConnection() async {
    final mode = settingsService.mode;
    if (mode == 'direct_meta') {
      return settingsService.metaPhoneId.isNotEmpty && settingsService.metaToken.isNotEmpty;
    }

    final baseUrl = settingsService.backendUrl.trim();
    if (baseUrl.isEmpty || baseUrl.contains('your-backend.com')) return false;

    final urlString = baseUrl.endsWith('/') ? '${baseUrl}health' : '$baseUrl/health';
    try {
      final response = await http
          .get(Uri.parse(urlString), headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 5));
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return false;
    }
  }
}
