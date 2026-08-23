import 'package:equatable/equatable.dart';

abstract class TelegramState extends Equatable {
  const TelegramState();
  @override
  List<Object?> get props => [];
}

class TelegramInitial extends TelegramState {}

class TelegramLoading extends TelegramState {}

class TelegramStatusLoaded extends TelegramState {
  final bool isOnline;
  final bool isTelegramConnected;
  final String botToken;
  final String chatId;
  final bool sendInvoicesEnabled;
  final bool sendDailyClosingEnabled;

  const TelegramStatusLoaded({
    required this.isOnline,
    required this.isTelegramConnected,
    required this.botToken,
    required this.chatId,
    required this.sendInvoicesEnabled,
    required this.sendDailyClosingEnabled,
  });

  @override
  List<Object?> get props => [
        isOnline,
        isTelegramConnected,
        botToken,
        chatId,
        sendInvoicesEnabled,
        sendDailyClosingEnabled,
      ];
}

class TelegramOperationSuccess extends TelegramState {
  final String message;
  const TelegramOperationSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class TelegramOperationError extends TelegramState {
  final String message;
  const TelegramOperationError(this.message);
  @override
  List<Object?> get props => [message];
}
