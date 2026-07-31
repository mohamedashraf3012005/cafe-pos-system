import '../entities/invoice_report_entity.dart';

abstract class DailyReportRepository {
  /// Fetch all invoices where isClosedShift == false (current open shift)
  Future<List<InvoiceReportEntity>> getOpenShiftInvoices();

  /// Close all open-shift invoices (set isClosedShift = true)
  Future<void> closeShift();
}
