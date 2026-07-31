import 'package:drift/drift.dart';
import 'connection/shared.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [SystemTables, Categories, Products, Orders, OrderItems, Invoices])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  @override
  int get schemaVersion => 4; // bumped from 3 → 4 for isClosedShift column

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await _seedDummyData();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Task 1 fix: NEVER wipe tables in production.
        // Safely add columns per version increment.
        if (from < 4) {
          // Add the isClosedShift column to invoices (Task 6)
          await m.addColumn(invoices, invoices.isClosedShift);
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
