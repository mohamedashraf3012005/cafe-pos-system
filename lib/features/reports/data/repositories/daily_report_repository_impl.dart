import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/invoice_report_entity.dart';
import '../../domain/repositories/daily_report_repository.dart';

class DailyReportRepositoryImpl implements DailyReportRepository {
  final AppDatabase db;

  DailyReportRepositoryImpl(this.db);

  @override
  Future<List<InvoiceReportEntity>> getOpenShiftInvoices() async {
    final rows = await (db.select(db.invoices)
          ..where((inv) => inv.isClosedShift.equals(false))
          ..orderBy([(inv) => OrderingTerm.desc(inv.createdAt)]))
        .get();

    return rows
        .map((inv) => InvoiceReportEntity(
              id: inv.id,
              invoiceNumber: inv.invoiceNumber,
              grandTotal: inv.grandTotal,
              createdAt: inv.createdAt,
              isClosedShift: inv.isClosedShift,
            ))
        .toList();
  }

  @override
  Future<void> closeShift() async {
    await (db.update(db.invoices)
          ..where((inv) => inv.isClosedShift.equals(false)))
        .write(const InvoicesCompanion(isClosedShift: Value(true)));
  }
}
