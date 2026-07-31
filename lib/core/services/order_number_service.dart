import 'package:shared_preferences/shared_preferences.dart';

/// Manages a daily sequential order number that resets each day.
class OrderNumberService {
  static const _counterKey = 'daily_order_counter';
  static const _dateKey = 'daily_order_date';

  final SharedPreferences _prefs;

  OrderNumberService(this._prefs);

  /// Returns the next order number for today.
  /// Resets to 1 if the day has changed.
  int getNextOrderNumber() {
    final today = DateTime.now().toIso8601String().substring(0, 10); // "2026-05-05"
    final savedDate = _prefs.getString(_dateKey);

    int counter;
    if (savedDate == today) {
      counter = (_prefs.getInt(_counterKey) ?? 0) + 1;
    } else {
      // New day — reset counter
      counter = 1;
      _prefs.setString(_dateKey, today);
    }

    _prefs.setInt(_counterKey, counter);
    return counter;
  }
}
