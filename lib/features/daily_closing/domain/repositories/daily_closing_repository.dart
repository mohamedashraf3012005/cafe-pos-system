import '../entities/daily_closing_entity.dart';
import '../entities/invoice_item_entity.dart';
import '../entities/expense_item_entity.dart';

abstract class DailyClosingRepository {
  /// Check if a closing record exists for the given date (yyyy-MM-dd).
  Future<DailyClosingEntity?> getClosingForDate(String dateStr);

  /// Performs Shift Closing (تقفيل الوردية):
  /// 1. Calculates financial totals from currently open-shift invoices.
  /// 2. Calculates total expenses from open-shift expenses.
  /// 3. Saves a frozen snapshot into DailyClosings table.
  /// 4. Marks open-shift invoices & expenses as closed (isClosedShift = true).
  /// 5. Enqueues WhatsApp/Telegram notification if enabled.
  Future<DailyClosingEntity> performDailyClosing({
    required String recipientPhone,
    required bool enqueueWhatsApp,
  });

  /// Get list of all previous shift closings.
  Future<List<DailyClosingEntity>> getClosingHistory({int limit = 50});

  /// Get a single closing record by ID.
  Future<DailyClosingEntity?> getClosingById(int id);

  /// Get all invoices for a given calendar date (yyyy-MM-dd).
  Future<List<InvoiceDetailEntity>> getInvoicesForClosingDate(String dateStr);

  /// Get full invoice details with items snapshot (with graceful fallback for older invoices).
  Future<InvoiceDetailEntity?> getInvoiceDetails(int invoiceId);

  /// Add a new expense (إضافة مصروف للوردية الحالية).
  Future<void> addExpense(double amount, String reason);

  /// Get all expenses recorded in the currently open shift.
  Future<List<ExpenseItemEntity>> getOpenShiftExpenses();

  /// Delete an open expense (حذف مصروف بالخطأ).
  Future<void> deleteExpense(int expenseId);

  /// Get all expenses associated with a specific shift closing.
  Future<List<ExpenseItemEntity>> getExpensesForClosing(int closingId);
}
