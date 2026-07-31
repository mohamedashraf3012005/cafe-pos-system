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
}

class Orders extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get tableId => integer().nullable().references(SystemTables, #id)();
  RealColumn get subtotal => real().withDefault(const Constant(0.0))();
  TextColumn get status => text().withDefault(const Constant('active'))(); // active, completed (checked out)
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
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
