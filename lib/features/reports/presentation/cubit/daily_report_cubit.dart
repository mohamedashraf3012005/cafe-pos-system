import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/invoice_report_entity.dart';
import '../../domain/entities/cashier_report_entity.dart';
import '../../domain/repositories/daily_report_repository.dart';

// ── States ────────────────────────────────────────────────────────────────────

abstract class DailyReportState extends Equatable {
  const DailyReportState();
  @override
  List<Object> get props => [];
}

class DailyReportInitial extends DailyReportState {}

class DailyReportLoading extends DailyReportState {}

class DailyReportLoaded extends DailyReportState {
  final List<InvoiceReportEntity> invoices;
  final double totalRevenue;

  const DailyReportLoaded({
    required this.invoices,
    required this.totalRevenue,
  });

  @override
  List<Object> get props => [invoices, totalRevenue];
}

class DailyReportError extends DailyReportState {
  final String message;
  const DailyReportError(this.message);
  @override
  List<Object> get props => [message];
}

class DailyReportShiftClosed extends DailyReportState {}

// ── Cubit ─────────────────────────────────────────────────────────────────────

class DailyReportCubit extends Cubit<DailyReportState> {
  final DailyReportRepository repository;

  DailyReportCubit(this.repository) : super(DailyReportInitial());

  Future<void> loadReport() async {
    emit(DailyReportLoading());
    try {
      final invoices = await repository.getOpenShiftInvoices();
      final total =
          invoices.fold<double>(0.0, (sum, inv) => sum + inv.grandTotal);
      emit(DailyReportLoaded(invoices: invoices, totalRevenue: total));
    } catch (e) {
      emit(DailyReportError(e.toString()));
    }
  }

  Future<void> closeShift() async {
    try {
      await repository.closeShift();
      emit(DailyReportShiftClosed());
    } catch (e) {
      emit(DailyReportError(e.toString()));
    }
  }

  Future<CashierReportEntity> getCashierReport({DateTime? date, String? dateStr}) =>
      repository.getCashierReport(date: date, dateStr: dateStr);
}
