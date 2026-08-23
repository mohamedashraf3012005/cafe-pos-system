import 'package:shared_preferences/shared_preferences.dart';

/// Persists WhatsApp user-configurable settings using SharedPreferences.
class WhatsAppSettingsService {
  final SharedPreferences _prefs;

  static const _keyEnabled = 'wa_enabled_invoices';
  static const _keyEnabledClosing = 'wa_enabled_closing';
  static const _keyPhone = 'wa_recipient_phone';
  static const _keyBackendUrl = 'wa_backend_url';
  static const _keyMode = 'wa_mode'; // 'backend' | 'direct_meta'
  static const _keyMetaPhoneId = 'wa_meta_phone_id';
  static const _keyMetaToken = 'wa_meta_token';

  static const defaultPhone = '+201002773665';
  static const defaultBackendUrl = 'http://localhost:3000/api/whatsapp';

  WhatsAppSettingsService(this._prefs);

  // ── Invoice sending toggle ───────────────────────────────────────────────────
  bool get sendInvoicesEnabled => _prefs.getBool(_keyEnabled) ?? true;
  Future<void> setSendInvoicesEnabled(bool value) =>
      _prefs.setBool(_keyEnabled, value);

  // ── Daily closing sending toggle ─────────────────────────────────────────────
  bool get sendDailyClosingEnabled => _prefs.getBool(_keyEnabledClosing) ?? true;
  Future<void> setSendDailyClosingEnabled(bool value) =>
      _prefs.setBool(_keyEnabledClosing, value);

  // ── Recipient phone ──────────────────────────────────────────────────────────
  String get recipientPhone => _prefs.getString(_keyPhone) ?? defaultPhone;
  Future<void> setRecipientPhone(String phone) =>
      _prefs.setString(_keyPhone, phone);

  // ── Backend URL ──────────────────────────────────────────────────────────────
  String get backendUrl => _prefs.getString(_keyBackendUrl) ?? defaultBackendUrl;
  Future<void> setBackendUrl(String url) => _prefs.setString(_keyBackendUrl, url);

  // ── Mode: 'backend' or 'direct_meta' ────────────────────────────────────────
  String get mode => _prefs.getString(_keyMode) ?? 'backend';
  Future<void> setMode(String mode) => _prefs.setString(_keyMode, mode);

  // ── Meta Direct API Phone Number ID ──────────────────────────────────────────
  String get metaPhoneId => _prefs.getString(_keyMetaPhoneId) ?? '';
  Future<void> setMetaPhoneId(String phoneId) => _prefs.setString(_keyMetaPhoneId, phoneId);

  // ── Meta Direct API Access Token ─────────────────────────────────────────────
  String get metaToken => _prefs.getString(_keyMetaToken) ?? '';
  Future<void> setMetaToken(String token) => _prefs.setString(_keyMetaToken, token);

  // ── Phone number validation ──────────────────────────────────────────────────
  static String? validatePhone(String phone) {
    final trimmed = phone.trim();
    if (trimmed.isEmpty) return 'رقم الهاتف مطلوب';
    final regex = RegExp(r'^\+[1-9]\d{6,14}$');
    if (!regex.hasMatch(trimmed)) {
      return 'رقم الهاتف غير صالح. استخدم الصيغة الدولية مثل: +201002773665';
    }
    return null;
  }
}
