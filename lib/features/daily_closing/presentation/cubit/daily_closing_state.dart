import 'package:equatable/equatable.dart';
import '../../domain/entities/daily_closing_entity.dart';

abstract class DailyClosingState extends Equatable {
  const DailyClosingState();
  @override
  List<Object?> get props => [];
}

class DailyClosingInitial extends DailyClosingState {}

class DailyClosingLoading extends DailyClosingState {}

class DailyClosingHistoryLoaded extends DailyClosingState {
  final List<DailyClosingEntity> history;
  final bool isTodayClosed;
  final DailyClosingEntity? todayClosing;

  const DailyClosingHistoryLoaded({
    required this.history,
    required this.isTodayClosed,
    this.todayClosing,
  });

  @override
  List<Object?> get props => [history, isTodayClosed, todayClosing];
}

class DailyClosingSuccess extends DailyClosingState {
  final DailyClosingEntity closing;
  final bool isOnline;

  const DailyClosingSuccess({
    required this.closing,
    required this.isOnline,
  });

  @override
  List<Object?> get props => [closing, isOnline];
}

class DailyClosingError extends DailyClosingState {
  final String message;
  const DailyClosingError(this.message);
  @override
  List<Object?> get props => [message];
}

class ExpenseOperationSuccess extends DailyClosingState {
  final String message;
  const ExpenseOperationSuccess(this.message);
  @override
  List<Object?> get props => [message];
}
