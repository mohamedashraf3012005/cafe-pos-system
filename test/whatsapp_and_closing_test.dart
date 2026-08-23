import 'package:flutter_test/flutter_test.dart';
import 'package:cash_cafe/core/services/whatsapp_settings_service.dart';
import 'package:cash_cafe/features/whatsapp/domain/entities/whatsapp_message_entity.dart';
import 'package:cash_cafe/features/daily_closing/domain/entities/daily_closing_entity.dart';

void main() {
  group('WhatsApp Settings & Phone Number Validation', () {
    test('Valid international phone format should return null error', () {
      expect(WhatsAppSettingsService.validatePhone('+201002773665'), isNull);
      expect(WhatsAppSettingsService.validatePhone('+14155552671'), isNull);
    });

    test('Invalid phone format should return error message in Arabic', () {
      expect(WhatsAppSettingsService.validatePhone('01002773665'), isNotNull);
      expect(WhatsAppSettingsService.validatePhone('123'), isNotNull);
      expect(WhatsAppSettingsService.validatePhone(''), isNotNull);
    });
  });

  group('WhatsApp Message Entity Idempotency & Status', () {
    test('WhatsAppMessageEntity properties check', () {
      final msg = WhatsAppMessageEntity(
        id: 1,
        messageType: 'invoice',
        invoiceId: 1001,
        recipientPhone: '+201002773665',
        messagePayload: 'Test payload',
        status: 'pending',
        attemptCount: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(msg.isPending, isTrue);
      expect(msg.isSent, isFalse);
      expect(msg.canRetry, isTrue);
    });
  });

  group('Daily Closing Entity', () {
    test('DailyClosingEntity snapshot properties', () {
      final closing = DailyClosingEntity(
        id: 1,
        closingDate: '2026-08-22',
        closingTime: '20:45',
        invoiceCount: 25,
        grossSales: 1500.0,
        discounts: 50.0,
        taxTotal: 100.0,
        netSales: 1550.0,
        cashTotal: 1000.0,
        cardTotal: 550.0,
        otherPayments: 0.0,
        totalItems: 40,
        status: 'closed',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(closing.isClosed, isTrue);
      expect(closing.invoiceCount, equals(25));
      expect(closing.netSales, equals(1550.0));
    });
  });
}
