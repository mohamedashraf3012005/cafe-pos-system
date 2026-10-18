import 'package:drift/drift.dart';
import 'connection/shared.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  SystemTables,
  Categories,
  Products,
  Orders,
  OrderItems,
  Invoices,
  DailyClosings,
  WhatsAppQueue,
  PlayStationDevices,
  PlayStationSessions,
  InventoryMovements,
  InvoiceItems,
  Expenses,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  @override
  int get schemaVersion => 9; // v9: shiftClosingId on Invoices for per-shift cashier reports

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await _seedDummyData();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        Future<void> safeAddColumn(TableInfo table, GeneratedColumn column) async {
          try {
            await m.addColumn(table, column);
          } catch (_) {
            // Column already exists, safe to ignore
          }
        }

        Future<void> safeCreateTable(TableInfo table) async {
          try {
            await m.createTable(table);
          } catch (_) {
            // Table already exists, safe to ignore
          }
        }

        // v3→v4: isClosedShift column on invoices
        if (from < 4) {
          await safeAddColumn(invoices, invoices.isClosedShift);
        }
        // v4→v5: paymentMethod column on invoices + two new tables
        if (from < 5) {
          await safeAddColumn(invoices, invoices.paymentMethod);
          await safeCreateTable(dailyClosings);
          await safeCreateTable(whatsAppQueue);
        }
        // v5→v6: PlayStation + Inventory support
        if (from < 6) {
          // Add stock columns to products
          await safeAddColumn(products, products.stockQuantity);
          await safeAddColumn(products, products.minimumStock);
          // Add PlayStation cost column to invoices
          await safeAddColumn(invoices, invoices.playStationAmount);
          // Add PlayStation total to daily_closings
          await safeAddColumn(dailyClosings, dailyClosings.playStationTotal);
          // Create new tables
          await safeCreateTable(inventoryMovements);
          await safeCreateTable(playStationDevices);
          await safeCreateTable(playStationSessions);
          // Seed default PlayStation device if none exists
          try {
            final devices = await (select(playStationDevices)).get();
            if (devices.isEmpty) {
              await _seedDefaultPlayStationDevice();
            }
          } catch (_) {}
        }
        // v6→v7: InvoiceItems table, trackInventory on Products, wallet/instapay totals on DailyClosings
        if (from < 7) {
          // Mod 2: InvoiceItems table
          await safeCreateTable(invoiceItems);

          // Mod 3: trackInventory column on Products (default true)
          await safeAddColumn(products, products.trackInventory);

          // Mod 4: wallet and instapay totals on DailyClosings
          await safeAddColumn(dailyClosings, dailyClosings.walletTotal);
          await safeAddColumn(dailyClosings, dailyClosings.instapayTotal);
        }

        // v7→v8: Shift closing support & Expenses table
        if (from < 8) {
          // 1. Create Expenses table
          await safeCreateTable(expenses);

          // 2. Add expensesTotal column to dailyClosings
          await safeAddColumn(dailyClosings, dailyClosings.expensesTotal);

          // 3. Remove inline unique constraint on closing_date in daily_closings table
          try {
            await customStatement('''
              CREATE TABLE IF NOT EXISTS daily_closings_v8 (
                id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
                closing_date TEXT NOT NULL,
                closing_time TEXT NOT NULL,
                invoice_count INTEGER NOT NULL DEFAULT 0,
                gross_sales REAL NOT NULL DEFAULT 0.0,
                discounts REAL NOT NULL DEFAULT 0.0,
                tax_total REAL NOT NULL DEFAULT 0.0,
                net_sales REAL NOT NULL DEFAULT 0.0,
                cash_total REAL NOT NULL DEFAULT 0.0,
                card_total REAL NOT NULL DEFAULT 0.0,
                other_payments REAL NOT NULL DEFAULT 0.0,
                total_items INTEGER NOT NULL DEFAULT 0,
                status TEXT NOT NULL DEFAULT 'closed',
                created_at INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)),
                updated_at INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)),
                play_station_total REAL NOT NULL DEFAULT 0.0,
                wallet_total REAL NOT NULL DEFAULT 0.0,
                instapay_total REAL NOT NULL DEFAULT 0.0,
                expenses_total REAL NOT NULL DEFAULT 0.0
              );
            ''');
            await customStatement('''
              INSERT OR IGNORE INTO daily_closings_v8 (
                id, closing_date, closing_time, invoice_count, gross_sales, discounts,
                tax_total, net_sales, cash_total, card_total, other_payments, total_items,
                status, created_at, updated_at, play_station_total, wallet_total, instapay_total, expenses_total
              )
              SELECT 
                id, closing_date, closing_time, invoice_count, gross_sales, discounts,
                tax_total, net_sales, cash_total, card_total, other_payments, total_items,
                status, created_at, updated_at, play_station_total, wallet_total, instapay_total, 0.0
              FROM daily_closings;
            ''');
            await customStatement('DROP TABLE daily_closings;');
            await customStatement('ALTER TABLE daily_closings_v8 RENAME TO daily_closings;');
          } catch (_) {}
        }

        // v8→v9: shiftClosingId on Invoices for per-shift isolation
        if (from < 9) {
          await safeAddColumn(invoices, invoices.shiftClosingId);
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

    // Seed default PlayStation device
    await _seedDefaultPlayStationDevice();
  }

  Future<void> _seedDefaultPlayStationDevice() async {
    await into(playStationDevices).insert(
      PlayStationDevicesCompanion.insert(
        name: 'PlayStation 5',
        hourlyRate: const Value(50.0),
        isActive: const Value(true),
      ),
    );
  }
}
