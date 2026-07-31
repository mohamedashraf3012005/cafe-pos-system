import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [SystemTables, Categories, Products, Orders, OrderItems, Invoices])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        // Seed initial data
        await _seedDummyData();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 3) {
          // Force wipe and recreate for development
          for (final table in allTables) {
            await m.deleteTable(table.actualTableName);
          }
          await m.createAll();
          await _seedDummyData();
        }
      },
    );
  }

  Future<void> _seedDummyData() async {
    // Seed Tables
    for (int i = 1; i <= 10; i++) {
      await into(systemTables).insert(SystemTablesCompanion.insert(tableNumber: i));
    }

    // Seed Categories
    final catCoffee = await into(categories).insertReturning(CategoriesCompanion.insert(name: 'قهوة'));
    final catDrinks = await into(categories).insertReturning(CategoriesCompanion.insert(name: 'مشروبات باردة'));
    final catDessert = await into(categories).insertReturning(CategoriesCompanion.insert(name: 'حلويات'));

    // Seed Products
    await into(products).insert(ProductsCompanion.insert(name: 'Espresso', price: 2.50, categoryId: catCoffee.id));
    await into(products).insert(ProductsCompanion.insert(name: 'Cappuccino', price: 3.50, categoryId: catCoffee.id));
    await into(products).insert(ProductsCompanion.insert(name: 'Latte', price: 4.00, categoryId: catCoffee.id));
    await into(products).insert(ProductsCompanion.insert(name: 'Water', price: 1.00, categoryId: catDrinks.id));
    await into(products).insert(ProductsCompanion.insert(name: 'Cola', price: 2.00, categoryId: catDrinks.id));
    await into(products).insert(ProductsCompanion.insert(name: 'Cheesecake', price: 5.00, categoryId: catDessert.id));
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'cafe_pos', 'db.sqlite'));
    if (!await file.parent.exists()) {
      await file.parent.create(recursive: true);
    }
    return NativeDatabase.createInBackground(file);
  });
}
