import 'package:drift/drift.dart';

class SystemTables extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get tableNumber => integer().unique()();
  TextColumn get status => text().withDefault(const Constant('free'))(); // free, busy
}

class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
}

class Products extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get categoryId => integer().references(Categories, #id)();
  RealColumn get price => real()();
  BoolColumn get hasAddons => boolean().withDefault(const Constant(false))();
  // v6: Inventory tracking columns
  IntColumn get stockQuantity => integer().withDefault(const Constant(0))();
  IntColumn get minimumStock => integer().withDefault(const Constant(0))();
}

class Orders extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get tableId => integer().nullable().references(SystemTables, #id)();
  RealColumn get subtotal => real().withDefault(const Constant(0.0))();
  TextColumn get status => text().withDefault(const Constant('active'))(); // active, completed
  TextColumn get orderType => text().withDefault(const Constant('dine_in'))(); // dine_in, takeaway
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class OrderItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get orderId => integer().references(Orders, #id)();
  IntColumn get productId => integer().references(Products, #id)();
  IntColumn get quantity => integer().withDefault(const Constant(1))();
  RealColumn get unitPrice => real()();
  RealColumn get totalPrice => real()();
}

class Invoices extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get orderId => integer().references(Orders, #id)();
  TextColumn get invoiceNumber => text().unique()();
  RealColumn get subtotal => real()();
  RealColumn get taxAmount => real()();
  RealColumn get serviceCharge => real()();
  RealColumn get grandTotal => real()();
  // v5: payment method (cash, card, other) — defaults to cash
  TextColumn get paymentMethod => text().withDefault(const Constant('cash'))();
  // v6: PlayStation cost stored separately in invoice for reporting
  RealColumn get playStationAmount => real().withDefault(const Constant(0.0))();
  // Task 6: shift closing flag — default false (open shift)
  BoolColumn get isClosedShift => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Daily Closing snapshot — one record per calendar day.
/// Stores a frozen snapshot of the day's financials at closing time.
class DailyClosings extends Table {
  IntColumn get id => integer().autoIncrement()();
  /// Stored as yyyy-MM-dd string for uniqueness constraint
  TextColumn get closingDate => text().unique()();
  TextColumn get closingTime => text()();
  IntColumn get invoiceCount => integer().withDefault(const Constant(0))();
  RealColumn get grossSales => real().withDefault(const Constant(0.0))();
  RealColumn get discounts => real().withDefault(const Constant(0.0))();
  RealColumn get taxTotal => real().withDefault(const Constant(0.0))();
  RealColumn get netSales => real().withDefault(const Constant(0.0))();
  RealColumn get cashTotal => real().withDefault(const Constant(0.0))();
  RealColumn get cardTotal => real().withDefault(const Constant(0.0))();
  RealColumn get otherPayments => real().withDefault(const Constant(0.0))();
  // v6: PlayStation sales total for daily closing
  RealColumn get playStationTotal => real().withDefault(const Constant(0.0))();
  IntColumn get totalItems => integer().withDefault(const Constant(0))();
  /// 'open' or 'closed'
  TextColumn get status => text().withDefault(const Constant('closed'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

/// WhatsApp outbox queue — persisted in SQLite so messages survive restarts.
/// messageType: 'invoice' | 'daily_closing'
/// status:      'pending' | 'sending' | 'sent' | 'failed'
class WhatsAppQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get messageType => text()();
  IntColumn get invoiceId => integer().nullable()();
  IntColumn get dailyClosingId => integer().nullable()();
  TextColumn get recipientPhone => text()();
  /// JSON-encoded message payload (invoice summary or daily report text)
  TextColumn get messagePayload => text()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  IntColumn get attemptCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastAttemptAt => dateTime().nullable()();
  DateTimeColumn get sentAt => dateTime().nullable()();
  TextColumn get errorMessage => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

// ─────────────────────────────────────────────────────────────────────────────
// v6: PlayStation Management Tables
// ─────────────────────────────────────────────────────────────────────────────

/// PlayStation Devices — manages multiple PS devices with individual pricing
class PlayStationDevices extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()(); // e.g., "PlayStation 5", "PlayStation 4"
  RealColumn get hourlyRate => real().withDefault(const Constant(50.0))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// PlayStation Sessions — tracks usage per table
/// status: 'active' | 'completed' | 'cancelled'
class PlayStationSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get tableId => integer().nullable().references(SystemTables, #id)();
  IntColumn get deviceId => integer().references(PlayStationDevices, #id)();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime().nullable()();
  IntColumn get elapsedSeconds => integer().nullable()();
  /// Frozen at session start — immune to future price changes
  RealColumn get hourlyRate => real()();
  RealColumn get calculatedAmount => real().withDefault(const Constant(0.0))();
  TextColumn get status => text().withDefault(const Constant('active'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// ─────────────────────────────────────────────────────────────────────────────
// v6: Inventory Movement History
// ─────────────────────────────────────────────────────────────────────────────

/// InventoryMovements — every stock change is recorded here
/// movementType: 'stock_in' | 'sale' | 'manual_remove' | 'adjustment' | 'return'
class InventoryMovements extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get productId => integer().references(Products, #id)();
  IntColumn get quantity => integer()();
  TextColumn get movementType => text()();
  IntColumn get previousQuantity => integer()();
  IntColumn get newQuantity => integer()();
  TextColumn get reason => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
