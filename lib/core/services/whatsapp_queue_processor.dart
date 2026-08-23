import 'dart:async';
import 'connectivity_service.dart';
import 'telegram_settings_service.dart';
import 'whatsapp_settings_service.dart';
import '../../features/telegram/data/datasources/telegram_remote_datasource.dart';
import '../../features/whatsapp/data/datasources/whatsapp_remote_datasource.dart';
import '../../features/whatsapp/domain/repositories/whatsapp_repository.dart';

class WhatsAppQueueProcessor {
  final ConnectivityService connectivityService;
  final WhatsAppRepository whatsappRepository;
  final WhatsAppRemoteDataSource remoteDataSource;
  final WhatsAppSettingsService settingsService;
  final TelegramRemoteDataSource? telegramRemoteDataSource;
  final TelegramSettingsService? telegramSettingsService;

  StreamSubscription<bool>? _connectivitySub;
  bool _isProcessing = false;

  WhatsAppQueueProcessor({
    required this.connectivityService,
    required this.whatsappRepository,
    required this.remoteDataSource,
    required this.settingsService,
    this.telegramRemoteDataSource,
    this.telegramSettingsService,
  });

  /// Starts listening to network connectivity events and automatically triggers processing when coming online.
  void start() {
    _connectivitySub?.cancel();
    _connectivitySub = connectivityService.onConnectivityChanged.listen((isOnline) {
      if (isOnline) {
        processQueue();
      }
    });

    if (connectivityService.isOnline) {
      processQueue();
    }
  }

  void stop() {
    _connectivitySub?.cancel();
    _connectivitySub = null;
  }

  /// Process all pending messages sequentially.
  Future<void> processQueue() async {
    if (_isProcessing) return;
    if (!connectivityService.isOnline) return;

    _isProcessing = true;

    try {
      final pendingMessages = await whatsappRepository.getPendingMessages();
      for (final message in pendingMessages) {
        if (!connectivityService.isOnline) break;

        final isInvoice = message.messageType == 'invoice';
        final isClosing = message.messageType == 'daily_closing';

        final tgEnabled = telegramSettingsService != null &&
            telegramSettingsService!.isConfigured &&
            (isInvoice
                ? telegramSettingsService!.sendInvoicesEnabled
                : isClosing
                    ? telegramSettingsService!.sendDailyClosingEnabled
                    : false);

        final waEnabled = isInvoice
            ? settingsService.sendInvoicesEnabled
            : isClosing
                ? settingsService.sendDailyClosingEnabled
                : false;

        if (!tgEnabled && !waEnabled) {
          continue;
        }

        await _processSingleMessage(
          queueId: message.id,
          recipientPhone: message.recipientPhone,
          payload: message.messagePayload,
          sendTg: tgEnabled,
          sendWa: waEnabled,
        );
      }
    } catch (_) {
    } finally {
      _isProcessing = false;
    }
  }

  Future<bool> _processSingleMessage({
    required int queueId,
    required String recipientPhone,
    required String payload,
    bool sendTg = true,
    bool sendWa = false,
  }) async {
    try {
      await whatsappRepository.markAsSending(queueId);

      if (sendTg && telegramRemoteDataSource != null) {
        await telegramRemoteDataSource!.sendMessage(message: payload);
        await whatsappRepository.markAsSent(queueId);
        return true;
      }

      if (sendWa) {
        await remoteDataSource.sendMessage(
          recipientPhone: recipientPhone,
          message: payload,
        );
        await whatsappRepository.markAsSent(queueId);
        return true;
      }

      await whatsappRepository.markAsSent(queueId);
      return true;
    } catch (e) {
      await whatsappRepository.markAsFailed(queueId, e.toString());
      return false;
    }
  }

  Future<bool> retryMessage(int queueId) async {
    if (!connectivityService.isOnline) return false;
    await whatsappRepository.resetToRetry(queueId);
    final pending = await whatsappRepository.getPendingMessages();
    final target = pending.where((m) => m.id == queueId).firstOrNull;
    if (target != null) {
      final isInvoice = target.messageType == 'invoice';

      final tgEnabled = telegramSettingsService != null &&
          telegramSettingsService!.isConfigured &&
          (isInvoice ? telegramSettingsService!.sendInvoicesEnabled : telegramSettingsService!.sendDailyClosingEnabled);

      final waEnabled = isInvoice ? settingsService.sendInvoicesEnabled : settingsService.sendDailyClosingEnabled;

      return await _processSingleMessage(
        queueId: target.id,
        recipientPhone: target.recipientPhone,
        payload: target.messagePayload,
        sendTg: tgEnabled,
        sendWa: waEnabled,
      );
    }
    return false;
  }

  Future<void> retryAllFailed() async {
    final failed = await whatsappRepository.getFailedMessages();
    for (final msg in failed) {
      await whatsappRepository.resetToRetry(msg.id);
    }
    await processQueue();
  }
}
