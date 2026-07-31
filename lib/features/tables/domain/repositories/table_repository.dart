import '../entities/table_entity.dart';

abstract class TableRepository {
  Future<List<TableEntity>> getTables();
  Future<void> updateTableStatus(int tableId, String status);
  Future<void> addTable();
  Future<void> removeLatestTable();
}
