import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/services/telegram_settings_service.dart';
import '../../data/datasources/telegram_remote_datasource.dart';
import 'telegram_state.dart';

class TelegramCubit extends Cubit<TelegramState> {
  final TelegramRemoteDataSource remoteDataSource;
  final TelegramSettingsService settingsService;
  final ConnectivityService connectivityService;

  StreamSubscription<bool>? _connectivitySub;

  TelegramCubit({
    required this.remoteDataSource,
    required this.settingsService,
    required this.connectivityService,
  }) : super(TelegramInitial());

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
      bool isConnected = false;
      if (isOnline && settingsService.isConfigured) {
        isConnected = await remoteDataSource.checkConnection();
      }

      emit(TelegramStatusLoaded(
        isOnline: isOnline,
        isTelegramConnected: isConnected,
        botToken: settingsService.botToken,
        chatId: settingsService.chatId,
        sendInvoicesEnabled: settingsService.sendInvoicesEnabled,
        sendDailyClosingEnabled: settingsService.sendDailyClosingEnabled,
      ));
    } catch (e) {
      emit(TelegramOperationError(e.toString()));
    }
  }

  Future<void> updateSettings({
    required bool sendInvoices,
    required bool sendClosing,
    required String botToken,
    required String chatId,
  }) async {
    if (botToken.trim().isEmpty || chatId.trim().isEmpty) {
      emit(const TelegramOperationError('برجاء إدخال Bot Token و Chat ID.'));
      return;
    }

    await settingsService.setSendInvoicesEnabled(sendInvoices);
    await settingsService.setSendDailyClosingEnabled(sendClosing);
    await settingsService.setBotToken(botToken);
    await settingsService.setChatId(chatId);

    emit(const TelegramOperationSuccess('تم حفظ إعدادات Telegram بنجاح!'));
    await loadStatus();
  }

  Future<void> sendTestMessage() async {
    if (!connectivityService.isOnline) {
      emit(const TelegramOperationError('لا يوجد اتصال بالإنترنت لإجراء اختبار الإرسال'));
      return;
    }

    if (!settingsService.isConfigured) {
      emit(const TelegramOperationError('يرجى إدخال Bot Token و Chat ID أولاً وحفظ الإعدادات'));
      return;
    }

    emit(TelegramLoading());
    try {
      await remoteDataSource.sendMessage(
        message: '☕ <b>تجربة الاتصال - Cafe POS Telegram Integration</b>\nالفرع يعمل وإشعار تليجرام شغال بنجاح! ❤️',
      );
      emit(const TelegramOperationSuccess('تم إرسال رسالة الاختبار بنجاح إلى حساب تليجرام! 🎉'));
    } catch (e) {
      final msg = e is TelegramSendException ? e.message : e.toString();
      emit(TelegramOperationError('فشل الاختبار: $msg'));
    } finally {
      await loadStatus();
    }
  }
}
