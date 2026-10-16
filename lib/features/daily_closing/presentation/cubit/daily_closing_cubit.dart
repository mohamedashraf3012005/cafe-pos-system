import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/services/whatsapp_queue_processor.dart';
import '../../../../core/services/whatsapp_settings_service.dart';
import '../../domain/entities/invoice_item_entity.dart';
import '../../domain/entities/expense_item_entity.dart';
import '../../domain/repositories/daily_closing_repository.dart';
import 'daily_closing_state.dart';

class DailyClosingCubit extends Cubit<DailyClosingState> {
  final DailyClosingRepository dailyClosingRepository;
  final WhatsAppSettingsService settingsService;
  final ConnectivityService connectivityService;
  final WhatsAppQueueProcessor queueProcessor;

  DailyClosingCubit({
    required this.dailyClosingRepository,
    required this.settingsService,
    required this.connectivityService,
    required this.queueProcessor,
  }) : super(DailyClosingInitial());

  Future<void> loadHistory() async {
    emit(DailyClosingLoading());
    try {
      final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final todayClosing = await dailyClosingRepository.getClosingForDate(todayStr);
      final history = await dailyClosingRepository.getClosingHistory();

      emit(DailyClosingHistoryLoaded(
        history: history,
        isTodayClosed: todayClosing != null && todayClosing.isClosed,
        todayClosing: todayClosing,
      ));
    } catch (e) {
      emit(DailyClosingError(e.toString()));
    }
  }

  Future<void> closeDay() async {
    emit(DailyClosingLoading());
    try {
      final recipientPhone = settingsService.recipientPhone;
      final sendWa = settingsService.sendDailyClosingEnabled;

      final closing = await dailyClosingRepository.performDailyClosing(
        recipientPhone: recipientPhone,
        enqueueWhatsApp: sendWa,
      );

      final isOnline = connectivityService.isOnline;

      // Trigger immediate processor if online
      if (isOnline && sendWa) {
        queueProcessor.processQueue();
      }

      emit(DailyClosingSuccess(closing: closing, isOnline: isOnline));
    } catch (e) {
      emit(DailyClosingError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> closeShift() => closeDay();

  Future<void> addExpense(double amount, String reason) async {
    try {
      await dailyClosingRepository.addExpense(amount, reason);
      emit(ExpenseOperationSuccess('تم تسجيل مصروف ($reason) بمبلغ ${amount.toStringAsFixed(2)} ج.م بنجاح.'));
    } catch (e) {
      emit(DailyClosingError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<List<ExpenseItemEntity>> getOpenShiftExpenses() {
    return dailyClosingRepository.getOpenShiftExpenses();
  }

  Future<void> deleteExpense(int expenseId) async {
    try {
      await dailyClosingRepository.deleteExpense(expenseId);
      emit(const ExpenseOperationSuccess('تم حذف المصروف بنجاح.'));
    } catch (e) {
      emit(DailyClosingError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<List<ExpenseItemEntity>> getExpensesForClosing(int closingId) {
    return dailyClosingRepository.getExpensesForClosing(closingId);
  }

  Future<List<InvoiceDetailEntity>> getInvoicesForClosingDate(String dateStr) {
    return dailyClosingRepository.getInvoicesForClosingDate(dateStr);
  }

  Future<InvoiceDetailEntity?> getInvoiceDetails(int invoiceId) {
    return dailyClosingRepository.getInvoiceDetails(invoiceId);
  }
}
