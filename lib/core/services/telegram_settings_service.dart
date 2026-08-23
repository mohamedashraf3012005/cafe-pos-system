import 'package:shared_preferences/shared_preferences.dart';

/// Service managing Telegram Bot configuration settings via SharedPreferences.
class TelegramSettingsService {
  final SharedPreferences _prefs;

  static const _keyEnabledInvoices = 'telegram_enabled_invoices';
  static const _keyEnabledClosing = 'telegram_enabled_closing';
  static const _keyBotToken = 'telegram_bot_token';
  static const _keyChatId = 'telegram_chat_id';

  TelegramSettingsService(this._prefs);

  // ── Invoice Sending Toggle ───────────────────────────────────────────────────
  bool get sendInvoicesEnabled => _prefs.getBool(_keyEnabledInvoices) ?? true;
  Future<void> setSendInvoicesEnabled(bool value) =>
      _prefs.setBool(_keyEnabledInvoices, value);

  // ── Daily Closing Sending Toggle ─────────────────────────────────────────────
  bool get sendDailyClosingEnabled => _prefs.getBool(_keyEnabledClosing) ?? true;
  Future<void> setSendDailyClosingEnabled(bool value) =>
      _prefs.setBool(_keyEnabledClosing, value);

  // ── Telegram Bot Token ──────────────────────────────────────────────────────
  String get botToken {
    final raw = _prefs.getString(_keyBotToken) ?? '';
    return normalizeBotToken(raw);
  }

  Future<void> setBotToken(String token) {
    final normalized = normalizeBotToken(token);
    return _prefs.setString(_keyBotToken, normalized);
  }

  // ── Telegram Chat ID ─────────────────────────────────────────────────────────
  String get chatId => _prefs.getString(_keyChatId) ?? '';
  Future<void> setChatId(String id) => _prefs.setString(_keyChatId, id.trim());

  // ── Verification Helper ──────────────────────────────────────────────────────
  bool get isConfigured => botToken.isNotEmpty && chatId.isNotEmpty;

  // ── Auto Normalize Bot Token ─────────────────────────────────────────────────
  /// Normalizes tokens pasted in reverse format (HASH:ID) to standard Telegram format (ID:HASH)
  static String normalizeBotToken(String rawToken) {
    final trimmed = rawToken.trim();
    if (trimmed.contains(':')) {
      final parts = trimmed.split(':');
      if (parts.length == 2) {
        final part1IsDigits = RegExp(r'^\d+$').hasMatch(parts[0]);
        final part2IsDigits = RegExp(r'^\d+$').hasMatch(parts[1]);

        if (!part1IsDigits && part2IsDigits) {
          return '${parts[1]}:${parts[0]}';
        }
      }
    }
    return trimmed;
  }
}
