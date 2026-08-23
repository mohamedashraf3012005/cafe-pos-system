import 'package:equatable/equatable.dart';
import '../../domain/entities/whatsapp_message_entity.dart';

abstract class WhatsAppState extends Equatable {
  const WhatsAppState();
  @override
  List<Object?> get props => [];
}

class WhatsAppInitial extends WhatsAppState {}

class WhatsAppLoading extends WhatsAppState {}

class WhatsAppStatusLoaded extends WhatsAppState {
  final bool isOnline;
  final bool isWhatsAppConnected;
  final int pendingCount;
  final int failedCount;
  final String recipientPhone;
  final bool sendInvoicesEnabled;
  final bool sendDailyClosingEnabled;
  final String mode; // 'backend' | 'direct_meta'
  final String backendUrl;
  final String metaPhoneId;
  final String metaToken;
  final List<WhatsAppMessageEntity> recentMessages;
  final String? lastError;

  const WhatsAppStatusLoaded({
    required this.isOnline,
    required this.isWhatsAppConnected,
    required this.pendingCount,
    required this.failedCount,
    required this.recipientPhone,
    required this.sendInvoicesEnabled,
    required this.sendDailyClosingEnabled,
    required this.mode,
    required this.backendUrl,
    required this.metaPhoneId,
    required this.metaToken,
    required this.recentMessages,
    this.lastError,
  });

  @override
  List<Object?> get props => [
        isOnline,
        isWhatsAppConnected,
        pendingCount,
        failedCount,
        recipientPhone,
        sendInvoicesEnabled,
        sendDailyClosingEnabled,
        mode,
        backendUrl,
        metaPhoneId,
        metaToken,
        recentMessages,
        lastError,
      ];
}

class WhatsAppOperationSuccess extends WhatsAppState {
  final String message;
  const WhatsAppOperationSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class WhatsAppOperationError extends WhatsAppState {
  final String message;
  const WhatsAppOperationError(this.message);
  @override
  List<Object?> get props => [message];
}
