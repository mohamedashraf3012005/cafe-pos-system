import 'package:equatable/equatable.dart';
import '../../domain/entities/table_entity.dart';

abstract class TablesState extends Equatable {
  const TablesState();

  @override
  List<Object> get props => [];
}

class TablesInitial extends TablesState {}

class TablesLoading extends TablesState {}

class TablesLoaded extends TablesState {
  final List<TableEntity> tables;
  const TablesLoaded({required this.tables});

  @override
  List<Object> get props => [tables];
}

class TablesError extends TablesState {
  final String message;
  const TablesError(this.message);

  @override
  List<Object> get props => [message];
}
