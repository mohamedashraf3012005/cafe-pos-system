import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/services/whatsapp_queue_processor.dart';
import '../../../../core/services/whatsapp_settings_service.dart';
import '../../data/datasources/whatsapp_remote_datasource.dart';
import '../../domain/repositories/whatsapp_repository.dart';
import 'whatsapp_state.dart';

class WhatsAppCubit extends Cubit<WhatsAppState> {
  final WhatsAppRepository whatsappRepository;
  final WhatsAppRemoteDataSource remoteDataSource;
  final WhatsAppSettingsService settingsService;
  final ConnectivityService connectivityService;
  final WhatsAppQueueProcessor queueProcessor;

  StreamSubscription<bool>? _connectivitySub;

  WhatsAppCubit({
    required this.whatsappRepository,
    required this.remoteDataSource,
    required this.settingsService,
    required this.connectivityService,
    required this.queueProcessor,
  }) : super(WhatsAppInitial());

  void init() {
    _connectivitySub = connectivityService.onConnectivityChanged.listen((_) {
      loadStatus();
    });
    loadStatus();
  }

  @override
  Future<void> close() {
    _connectivitySub?.cancel();
    return super.close();
  }

  Future<void> loadStatus() async {
    try {
      final isOnline = connectivityService.isOnline;
      final pendingCount = await whatsappRepository.getPendingCount();
      final failedCount = await whatsappRepository.getFailedCount();
      final recentMessages = await whatsappRepository.getAllMessages(limit: 50);

      bool isWaConnected = false;
      if (isOnline) {
        isWaConnected = await remoteDataSource.checkConnection();
      }

      final lastFailed = recentMessages.where((m) => m.isFailed).firstOrNull;

      emit(WhatsAppStatusLoaded(
        isOnline: isOnline,
        isWhatsAppConnected: isWaConnected,
        pendingCount: pendingCount,
        failedCount: failedCount,
        recipientPhone: settingsService.recipientPhone,
        sendInvoicesEnabled: settingsService.sendInvoicesEnabled,
        sendDailyClosingEnabled: settingsService.sendDailyClosingEnabled,
        mode: settingsService.mode,
        backendUrl: settingsService.backendUrl,
        metaPhoneId: settingsService.metaPhoneId,
        metaToken: settingsService.metaToken,
        recentMessages: recentMessages,
        lastError: lastFailed?.errorMessage,
      ));
    } catch (e) {
      emit(WhatsAppOperationError(e.toString()));
    }
  }

  Future<void> updateSettings({
    required bool sendInvoices,
    required bool sendClosing,
    required String recipientPhone,
    required String mode,
    required String backendUrl,
    required String metaPhoneId,
    required String metaToken,
  }) async {
    final phoneError = WhatsAppSettingsService.validatePhone(recipientPhone);
    if (phoneError != null) {
      emit(WhatsAppOperationError(phoneError));
      return;
    }

    await settingsService.setSendInvoicesEnabled(sendInvoices);
    await settingsService.setSendDailyClosingEnabled(sendClosing);
    await settingsService.setRecipientPhone(recipientPhone.trim());
    await settingsService.setMode(mode);
    await settingsService.setBackendUrl(backendUrl.trim());
    await settingsService.setMetaPhoneId(metaPhoneId.trim());
    await settingsService.setMetaToken(metaToken.trim());

    emit(const WhatsAppOperationSuccess('تم حفظ إعدادات WhatsApp بنجاح'));
    await loadStatus();
  }

  Future<void> sendTestMessage() async {
    if (!connectivityService.isOnline) {
      emit(const WhatsAppOperationError('لا يوجد اتصال بالإنترنت لإجراء اختبار إرسال'));
      return;
    }

    emit(WhatsAppLoading());
    try {
      await remoteDataSource.sendMessage(
        recipientPhone: settingsService.recipientPhone,
        message: '☕ تجربة الاتصال - Cafe POS WhatsApp Integration\nالفرع يعمل وتوصيل WhatsApp فعال.',
      );
      emit(const WhatsAppOperationSuccess('تم إرسال رسالة الاختبار بنجاح إلى WhatsApp!'));
    } catch (e) {
      final msg = e is WhatsAppSendException ? e.message : e.toString();
      emit(WhatsAppOperationError('فشل الاختبار: $msg'));
    } finally {
      await loadStatus();
    }
  }

  Future<void> processPendingQueue() async {
    if (!connectivityService.isOnline) {
      emit(const WhatsAppOperationError('لا يوجد اتصال بالإنترنت'));
      return;
    }

    emit(WhatsAppLoading());
    await queueProcessor.processQueue();
    emit(const WhatsAppOperationSuccess('تم بدء معالجة الرسائل المعلقة'));
    await loadStatus();
  }

  Future<void> retryFailedMessages() async {
    if (!connectivityService.isOnline) {
      emit(const WhatsAppOperationError('لا يوجد اتصال بالإنترنت'));
      return;
    }

    emit(WhatsAppLoading());
    await queueProcessor.retryAllFailed();
    emit(const WhatsAppOperationSuccess('تم إعادة محاولة إرسال الرسائل الفاشلة'));
    await loadStatus();
  }

  Future<void> retrySingleMessage(int queueId) async {
    if (!connectivityService.isOnline) {
      emit(const WhatsAppOperationError('لا يوجد اتصال بالإنترنت'));
      return;
    }

    emit(WhatsAppLoading());
    final success = await queueProcessor.retryMessage(queueId);
    if (success) {
      emit(const WhatsAppOperationSuccess('تم إعادة إرسال الرسالة بنجاح'));
    } else {
      emit(const WhatsAppOperationError('فشل إعادة إرسال الرسالة'));
    }
    await loadStatus();
  }
}
