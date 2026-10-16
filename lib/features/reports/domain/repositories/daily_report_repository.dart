import '../entities/invoice_report_entity.dart';
import '../entities/cashier_report_entity.dart';
import '../../../daily_closing/domain/entities/expense_item_entity.dart';

abstract class DailyReportRepository {
  /// Fetch all invoices where isClosedShift == false (current open shift)
  Future<List<InvoiceReportEntity>> getOpenShiftInvoices();

  /// Fetch all expenses where isClosedShift == false (current open shift)
  Future<List<ExpenseItemEntity>> getOpenShiftExpenses();

  /// Close all open-shift invoices (set isClosedShift = true)
  Future<void> closeShift();

  /// Generate a detailed Cashier Report of all items sold and payment breakdown.
  /// If [date] or [dateStr] is provided, generates the report for that historical day.
  /// If null, generates for current open shift.
  Future<CashierReportEntity> getCashierReport({DateTime? date, String? dateStr});
}
