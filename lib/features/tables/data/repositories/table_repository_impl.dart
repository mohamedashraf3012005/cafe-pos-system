import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/table_entity.dart';
import '../../domain/repositories/table_repository.dart';

class TableRepositoryImpl implements TableRepository {
  final AppDatabase db;

  TableRepositoryImpl(this.db);

  @override
  Future<List<TableEntity>> getTables() async {
    final driftTables = await db.select(db.systemTables).get();
    return driftTables.map((t) => TableEntity(
      id: t.id,
      tableNumber: t.tableNumber,
      status: t.status,
    )).toList();
  }

  @override
  Future<void> updateTableStatus(int tableId, String status) async {
    await (db.update(db.systemTables)..where((t) => t.id.equals(tableId)))
        .write(SystemTablesCompanion(status: Value(status)));
  }

  @override
  Future<void> addTable() async {
    final tables = await (db.select(db.systemTables)
          ..orderBy([(t) => OrderingTerm(expression: t.tableNumber, mode: OrderingMode.desc)])
          ..limit(1))
        .get();
    
    final currentMax = tables.isNotEmpty ? tables.first.tableNumber : 0;

    await db.into(db.systemTables).insert(
          SystemTablesCompanion.insert(tableNumber: currentMax + 1),
        );
  }

  @override
  Future<void> removeLatestTable() async {
    final tables = await (db.select(db.systemTables)
          ..orderBy([(t) => OrderingTerm(expression: t.tableNumber, mode: OrderingMode.desc)])
          ..limit(1))
        .get();
        
    if (tables.isNotEmpty) {
      await (db.delete(db.systemTables)..where((t) => t.id.equals(tables.first.id))).go();
    }
  }
}
