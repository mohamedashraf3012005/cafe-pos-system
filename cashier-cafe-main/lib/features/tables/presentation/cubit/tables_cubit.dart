import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/table_repository.dart';
import 'tables_state.dart';

class TablesCubit extends Cubit<TablesState> {
  final TableRepository repository;

  TablesCubit(this.repository) : super(TablesInitial());

  Future<void> loadTables() async {
    emit(TablesLoading());
    try {
      final tables = await repository.getTables();
      emit(TablesLoaded(tables: tables));
    } catch (e) {
      emit(TablesError(e.toString()));
    }
  }

  Future<void> updateTableStatus(int tableId, String status) async {
    try {
      await repository.updateTableStatus(tableId, status);
      // Reload tables after updating
      await loadTables();
    } catch (e) {
      emit(TablesError(e.toString()));
    }
  }

  Future<void> addTable() async {
    try {
      await repository.addTable();
      await loadTables();
    } catch (e) {
      emit(TablesError(e.toString()));
    }
  }

  Future<void> removeLatestTable() async {
    try {
      await repository.removeLatestTable();
      await loadTables();
    } catch (e) {
      emit(TablesError(e.toString()));
    }
  }
}
