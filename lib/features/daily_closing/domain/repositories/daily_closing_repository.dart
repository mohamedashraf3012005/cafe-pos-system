import '../entities/daily_closing_entity.dart';

abstract class DailyClosingRepository {
  /// Check if a closing record already exists for the given date (yyyy-MM-dd).
  Future<DailyClosingEntity?> getClosingForDate(String dateStr);

  /// Performs the actual Daily Closing operation:
  /// 1. Calculates financial totals from currently open-shift invoices.
  /// 2. Saves a frozen snapshot into DailyClosings table.
  /// 3. Marks open-shift invoices as closed (isClosedShift = true).
  /// 4. Creates a WhatsApp queue item for the daily closing.
  ///
  /// Throws Exception if today is already closed.
  Future<DailyClosingEntity> performDailyClosing({
    required String recipientPhone,
    required bool enqueueWhatsApp,
  });

  /// Get list of all previous daily closings.
  Future<List<DailyClosingEntity>> getClosingHistory({int limit = 50});

  /// Get a single closing record by ID.
  Future<DailyClosingEntity?> getClosingById(int id);
}
