// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SystemTablesTable extends SystemTables
    with TableInfo<$SystemTablesTable, SystemTable> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SystemTablesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _tableNumberMeta =
      const VerificationMeta('tableNumber');
  @override
  late final GeneratedColumn<int> tableNumber = GeneratedColumn<int>(
      'table_number', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('free'));
  @override
  List<GeneratedColumn> get $columns => [id, tableNumber, status];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'system_tables';
  @override
  VerificationContext validateIntegrity(Insertable<SystemTable> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('table_number')) {
      context.handle(
          _tableNumberMeta,
          tableNumber.isAcceptableOrUnknown(
              data['table_number']!, _tableNumberMeta));
    } else if (isInserting) {
      context.missing(_tableNumberMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SystemTable map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SystemTable(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      tableNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}table_number'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
    );
  }

  @override
  $SystemTablesTable createAlias(String alias) {
    return $SystemTablesTable(attachedDatabase, alias);
  }
}

class SystemTable extends DataClass implements Insertable<SystemTable> {
  final int id;
  final int tableNumber;
  final String status;
  const SystemTable(
      {required this.id, required this.tableNumber, required this.status});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['table_number'] = Variable<int>(tableNumber);
    map['status'] = Variable<String>(status);
    return map;
  }

  SystemTablesCompanion toCompanion(bool nullToAbsent) {
    return SystemTablesCompanion(
      id: Value(id),
      tableNumber: Value(tableNumber),
      status: Value(status),
    );
  }

  factory SystemTable.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SystemTable(
      id: serializer.fromJson<int>(json['id']),
      tableNumber: serializer.fromJson<int>(json['tableNumber']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'tableNumber': serializer.toJson<int>(tableNumber),
      'status': serializer.toJson<String>(status),
    };
  }

  SystemTable copyWith({int? id, int? tableNumber, String? status}) =>
      SystemTable(
        id: id ?? this.id,
        tableNumber: tableNumber ?? this.tableNumber,
        status: status ?? this.status,
      );
  SystemTable copyWithCompanion(SystemTablesCompanion data) {
    return SystemTable(
      id: data.id.present ? data.id.value : this.id,
      tableNumber:
          data.tableNumber.present ? data.tableNumber.value : this.tableNumber,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SystemTable(')
          ..write('id: $id, ')
          ..write('tableNumber: $tableNumber, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, tableNumber, status);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SystemTable &&
          other.id == this.id &&
          other.tableNumber == this.tableNumber &&
          other.status == this.status);
}

class SystemTablesCompanion extends UpdateCompanion<SystemTable> {
  final Value<int> id;
  final Value<int> tableNumber;
  final Value<String> status;
  const SystemTablesCompanion({
    this.id = const Value.absent(),
    this.tableNumber = const Value.absent(),
    this.status = const Value.absent(),
  });
  SystemTablesCompanion.insert({
    this.id = const Value.absent(),
    required int tableNumber,
    this.status = const Value.absent(),
  }) : tableNumber = Value(tableNumber);
  static Insertable<SystemTable> custom({
    Expression<int>? id,
    Expression<int>? tableNumber,
    Expression<String>? status,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tableNumber != null) 'table_number': tableNumber,
      if (status != null) 'status': status,
    });
  }

  SystemTablesCompanion copyWith(
      {Value<int>? id, Value<int>? tableNumber, Value<String>? status}) {
    return SystemTablesCompanion(
      id: id ?? this.id,
      tableNumber: tableNumber ?? this.tableNumber,
      status: status ?? this.status,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (tableNumber.present) {
      map['table_number'] = Variable<int>(tableNumber.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SystemTablesCompanion(')
          ..write('id: $id, ')
          ..write('tableNumber: $tableNumber, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(Insertable<Category> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends DataClass implements Insertable<Category> {
  final int id;
  final String name;
  const Category({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
    );
  }

  factory Category.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  Category copyWith({int? id, String? name}) => Category(
        id: id ?? this.id,
        name: name ?? this.name,
      );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category && other.id == this.id && other.name == this.name);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<int> id;
  final Value<String> name;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  CategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
  }) : name = Value(name);
  static Insertable<Category> custom({
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  CategoriesCompanion copyWith({Value<int>? id, Value<String>? name}) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $ProductsTable extends Products with TableInfo<$ProductsTable, Product> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
      'category_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES categories (id)'));
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<double> price = GeneratedColumn<double>(
      'price', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _hasAddonsMeta =
      const VerificationMeta('hasAddons');
  @override
  late final GeneratedColumn<bool> hasAddons = GeneratedColumn<bool>(
      'has_addons', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("has_addons" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _stockQuantityMeta =
      const VerificationMeta('stockQuantity');
  @override
  late final GeneratedColumn<int> stockQuantity = GeneratedColumn<int>(
      'stock_quantity', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _minimumStockMeta =
      const VerificationMeta('minimumStock');
  @override
  late final GeneratedColumn<int> minimumStock = GeneratedColumn<int>(
      'minimum_stock', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _trackInventoryMeta =
      const VerificationMeta('trackInventory');
  @override
  late final GeneratedColumn<bool> trackInventory = GeneratedColumn<bool>(
      'track_inventory', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("track_inventory" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        categoryId,
        price,
        hasAddons,
        stockQuantity,
        minimumStock,
        trackInventory
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'products';
  @override
  VerificationContext validateIntegrity(Insertable<Product> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('price')) {
      context.handle(
          _priceMeta, price.isAcceptableOrUnknown(data['price']!, _priceMeta));
    } else if (isInserting) {
      context.missing(_priceMeta);
    }
    if (data.containsKey('has_addons')) {
      context.handle(_hasAddonsMeta,
          hasAddons.isAcceptableOrUnknown(data['has_addons']!, _hasAddonsMeta));
    }
    if (data.containsKey('stock_quantity')) {
      context.handle(
          _stockQuantityMeta,
          stockQuantity.isAcceptableOrUnknown(
              data['stock_quantity']!, _stockQuantityMeta));
    }
    if (data.containsKey('minimum_stock')) {
      context.handle(
          _minimumStockMeta,
          minimumStock.isAcceptableOrUnknown(
              data['minimum_stock']!, _minimumStockMeta));
    }
    if (data.containsKey('track_inventory')) {
      context.handle(
          _trackInventoryMeta,
          trackInventory.isAcceptableOrUnknown(
              data['track_inventory']!, _trackInventoryMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Product map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Product(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}category_id'])!,
      price: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}price'])!,
      hasAddons: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}has_addons'])!,
      stockQuantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}stock_quantity'])!,
      minimumStock: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}minimum_stock'])!,
      trackInventory: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}track_inventory'])!,
    );
  }

  @override
  $ProductsTable createAlias(String alias) {
    return $ProductsTable(attachedDatabase, alias);
  }
}

class Product extends DataClass implements Insertable<Product> {
  final int id;
  final String name;
  final int categoryId;
  final double price;
  final bool hasAddons;
  final int stockQuantity;
  final int minimumStock;
  final bool trackInventory;
  const Product(
      {required this.id,
      required this.name,
      required this.categoryId,
      required this.price,
      required this.hasAddons,
      required this.stockQuantity,
      required this.minimumStock,
      required this.trackInventory});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['category_id'] = Variable<int>(categoryId);
    map['price'] = Variable<double>(price);
    map['has_addons'] = Variable<bool>(hasAddons);
    map['stock_quantity'] = Variable<int>(stockQuantity);
    map['minimum_stock'] = Variable<int>(minimumStock);
    map['track_inventory'] = Variable<bool>(trackInventory);
    return map;
  }

  ProductsCompanion toCompanion(bool nullToAbsent) {
    return ProductsCompanion(
      id: Value(id),
      name: Value(name),
      categoryId: Value(categoryId),
      price: Value(price),
      hasAddons: Value(hasAddons),
      stockQuantity: Value(stockQuantity),
      minimumStock: Value(minimumStock),
      trackInventory: Value(trackInventory),
    );
  }

  factory Product.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Product(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
      price: serializer.fromJson<double>(json['price']),
      hasAddons: serializer.fromJson<bool>(json['hasAddons']),
      stockQuantity: serializer.fromJson<int>(json['stockQuantity']),
      minimumStock: serializer.fromJson<int>(json['minimumStock']),
      trackInventory: serializer.fromJson<bool>(json['trackInventory']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'categoryId': serializer.toJson<int>(categoryId),
      'price': serializer.toJson<double>(price),
      'hasAddons': serializer.toJson<bool>(hasAddons),
      'stockQuantity': serializer.toJson<int>(stockQuantity),
      'minimumStock': serializer.toJson<int>(minimumStock),
      'trackInventory': serializer.toJson<bool>(trackInventory),
    };
  }

  Product copyWith(
          {int? id,
          String? name,
          int? categoryId,
          double? price,
          bool? hasAddons,
          int? stockQuantity,
          int? minimumStock,
          bool? trackInventory}) =>
      Product(
        id: id ?? this.id,
        name: name ?? this.name,
        categoryId: categoryId ?? this.categoryId,
        price: price ?? this.price,
        hasAddons: hasAddons ?? this.hasAddons,
        stockQuantity: stockQuantity ?? this.stockQuantity,
        minimumStock: minimumStock ?? this.minimumStock,
        trackInventory: trackInventory ?? this.trackInventory,
      );
  Product copyWithCompanion(ProductsCompanion data) {
    return Product(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      price: data.price.present ? data.price.value : this.price,
      hasAddons: data.hasAddons.present ? data.hasAddons.value : this.hasAddons,
      stockQuantity: data.stockQuantity.present
          ? data.stockQuantity.value
          : this.stockQuantity,
      minimumStock: data.minimumStock.present
          ? data.minimumStock.value
          : this.minimumStock,
      trackInventory: data.trackInventory.present
          ? data.trackInventory.value
          : this.trackInventory,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Product(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('categoryId: $categoryId, ')
          ..write('price: $price, ')
          ..write('hasAddons: $hasAddons, ')
          ..write('stockQuantity: $stockQuantity, ')
          ..write('minimumStock: $minimumStock, ')
          ..write('trackInventory: $trackInventory')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, categoryId, price, hasAddons,
      stockQuantity, minimumStock, trackInventory);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Product &&
          other.id == this.id &&
          other.name == this.name &&
          other.categoryId == this.categoryId &&
          other.price == this.price &&
          other.hasAddons == this.hasAddons &&
          other.stockQuantity == this.stockQuantity &&
          other.minimumStock == this.minimumStock &&
          other.trackInventory == this.trackInventory);
}

class ProductsCompanion extends UpdateCompanion<Product> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> categoryId;
  final Value<double> price;
  final Value<bool> hasAddons;
  final Value<int> stockQuantity;
  final Value<int> minimumStock;
  final Value<bool> trackInventory;
  const ProductsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.price = const Value.absent(),
    this.hasAddons = const Value.absent(),
    this.stockQuantity = const Value.absent(),
    this.minimumStock = const Value.absent(),
    this.trackInventory = const Value.absent(),
  });
  ProductsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int categoryId,
    required double price,
    this.hasAddons = const Value.absent(),
    this.stockQuantity = const Value.absent(),
    this.minimumStock = const Value.absent(),
    this.trackInventory = const Value.absent(),
  })  : name = Value(name),
        categoryId = Value(categoryId),
        price = Value(price);
  static Insertable<Product> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? categoryId,
    Expression<double>? price,
    Expression<bool>? hasAddons,
    Expression<int>? stockQuantity,
    Expression<int>? minimumStock,
    Expression<bool>? trackInventory,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (categoryId != null) 'category_id': categoryId,
      if (price != null) 'price': price,
      if (hasAddons != null) 'has_addons': hasAddons,
      if (stockQuantity != null) 'stock_quantity': stockQuantity,
      if (minimumStock != null) 'minimum_stock': minimumStock,
      if (trackInventory != null) 'track_inventory': trackInventory,
    });
  }

  ProductsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<int>? categoryId,
      Value<double>? price,
      Value<bool>? hasAddons,
      Value<int>? stockQuantity,
      Value<int>? minimumStock,
      Value<bool>? trackInventory}) {
    return ProductsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      price: price ?? this.price,
      hasAddons: hasAddons ?? this.hasAddons,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      minimumStock: minimumStock ?? this.minimumStock,
      trackInventory: trackInventory ?? this.trackInventory,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (price.present) {
      map['price'] = Variable<double>(price.value);
    }
    if (hasAddons.present) {
      map['has_addons'] = Variable<bool>(hasAddons.value);
    }
    if (stockQuantity.present) {
      map['stock_quantity'] = Variable<int>(stockQuantity.value);
    }
    if (minimumStock.present) {
      map['minimum_stock'] = Variable<int>(minimumStock.value);
    }
    if (trackInventory.present) {
      map['track_inventory'] = Variable<bool>(trackInventory.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('categoryId: $categoryId, ')
          ..write('price: $price, ')
          ..write('hasAddons: $hasAddons, ')
          ..write('stockQuantity: $stockQuantity, ')
          ..write('minimumStock: $minimumStock, ')
          ..write('trackInventory: $trackInventory')
          ..write(')'))
        .toString();
  }
}

class $OrdersTable extends Orders with TableInfo<$OrdersTable, Order> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OrdersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _tableIdMeta =
      const VerificationMeta('tableId');
  @override
  late final GeneratedColumn<int> tableId = GeneratedColumn<int>(
      'table_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES system_tables (id)'));
  static const VerificationMeta _subtotalMeta =
      const VerificationMeta('subtotal');
  @override
  late final GeneratedColumn<double> subtotal = GeneratedColumn<double>(
      'subtotal', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('active'));
  static const VerificationMeta _orderTypeMeta =
      const VerificationMeta('orderType');
  @override
  late final GeneratedColumn<String> orderType = GeneratedColumn<String>(
      'order_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('dine_in'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, tableId, subtotal, status, orderType, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'orders';
  @override
  VerificationContext validateIntegrity(Insertable<Order> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('table_id')) {
      context.handle(_tableIdMeta,
          tableId.isAcceptableOrUnknown(data['table_id']!, _tableIdMeta));
    }
    if (data.containsKey('subtotal')) {
      context.handle(_subtotalMeta,
          subtotal.isAcceptableOrUnknown(data['subtotal']!, _subtotalMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('order_type')) {
      context.handle(_orderTypeMeta,
          orderType.isAcceptableOrUnknown(data['order_type']!, _orderTypeMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Order map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Order(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      tableId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}table_id']),
      subtotal: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}subtotal'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      orderType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}order_type'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $OrdersTable createAlias(String alias) {
    return $OrdersTable(attachedDatabase, alias);
  }
}

class Order extends DataClass implements Insertable<Order> {
  final int id;
  final int? tableId;
  final double subtotal;
  final String status;
  final String orderType;
  final DateTime createdAt;
  const Order(
      {required this.id,
      this.tableId,
      required this.subtotal,
      required this.status,
      required this.orderType,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || tableId != null) {
      map['table_id'] = Variable<int>(tableId);
    }
    map['subtotal'] = Variable<double>(subtotal);
    map['status'] = Variable<String>(status);
    map['order_type'] = Variable<String>(orderType);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  OrdersCompanion toCompanion(bool nullToAbsent) {
    return OrdersCompanion(
      id: Value(id),
      tableId: tableId == null && nullToAbsent
          ? const Value.absent()
          : Value(tableId),
      subtotal: Value(subtotal),
      status: Value(status),
      orderType: Value(orderType),
      createdAt: Value(createdAt),
    );
  }

  factory Order.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Order(
      id: serializer.fromJson<int>(json['id']),
      tableId: serializer.fromJson<int?>(json['tableId']),
      subtotal: serializer.fromJson<double>(json['subtotal']),
      status: serializer.fromJson<String>(json['status']),
      orderType: serializer.fromJson<String>(json['orderType']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'tableId': serializer.toJson<int?>(tableId),
      'subtotal': serializer.toJson<double>(subtotal),
      'status': serializer.toJson<String>(status),
      'orderType': serializer.toJson<String>(orderType),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Order copyWith(
          {int? id,
          Value<int?> tableId = const Value.absent(),
          double? subtotal,
          String? status,
          String? orderType,
          DateTime? createdAt}) =>
      Order(
        id: id ?? this.id,
        tableId: tableId.present ? tableId.value : this.tableId,
        subtotal: subtotal ?? this.subtotal,
        status: status ?? this.status,
        orderType: orderType ?? this.orderType,
        createdAt: createdAt ?? this.createdAt,
      );
  Order copyWithCompanion(OrdersCompanion data) {
    return Order(
      id: data.id.present ? data.id.value : this.id,
      tableId: data.tableId.present ? data.tableId.value : this.tableId,
      subtotal: data.subtotal.present ? data.subtotal.value : this.subtotal,
      status: data.status.present ? data.status.value : this.status,
      orderType: data.orderType.present ? data.orderType.value : this.orderType,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Order(')
          ..write('id: $id, ')
          ..write('tableId: $tableId, ')
          ..write('subtotal: $subtotal, ')
          ..write('status: $status, ')
          ..write('orderType: $orderType, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, tableId, subtotal, status, orderType, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Order &&
          other.id == this.id &&
          other.tableId == this.tableId &&
          other.subtotal == this.subtotal &&
          other.status == this.status &&
          other.orderType == this.orderType &&
          other.createdAt == this.createdAt);
}

class OrdersCompanion extends UpdateCompanion<Order> {
  final Value<int> id;
  final Value<int?> tableId;
  final Value<double> subtotal;
  final Value<String> status;
  final Value<String> orderType;
  final Value<DateTime> createdAt;
  const OrdersCompanion({
    this.id = const Value.absent(),
    this.tableId = const Value.absent(),
    this.subtotal = const Value.absent(),
    this.status = const Value.absent(),
    this.orderType = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  OrdersCompanion.insert({
    this.id = const Value.absent(),
    this.tableId = const Value.absent(),
    this.subtotal = const Value.absent(),
    this.status = const Value.absent(),
    this.orderType = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  static Insertable<Order> custom({
    Expression<int>? id,
    Expression<int>? tableId,
    Expression<double>? subtotal,
    Expression<String>? status,
    Expression<String>? orderType,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tableId != null) 'table_id': tableId,
      if (subtotal != null) 'subtotal': subtotal,
      if (status != null) 'status': status,
      if (orderType != null) 'order_type': orderType,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  OrdersCompanion copyWith(
      {Value<int>? id,
      Value<int?>? tableId,
      Value<double>? subtotal,
      Value<String>? status,
      Value<String>? orderType,
      Value<DateTime>? createdAt}) {
    return OrdersCompanion(
      id: id ?? this.id,
      tableId: tableId ?? this.tableId,
      subtotal: subtotal ?? this.subtotal,
      status: status ?? this.status,
      orderType: orderType ?? this.orderType,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (tableId.present) {
      map['table_id'] = Variable<int>(tableId.value);
    }
    if (subtotal.present) {
      map['subtotal'] = Variable<double>(subtotal.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (orderType.present) {
      map['order_type'] = Variable<String>(orderType.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OrdersCompanion(')
          ..write('id: $id, ')
          ..write('tableId: $tableId, ')
          ..write('subtotal: $subtotal, ')
          ..write('status: $status, ')
          ..write('orderType: $orderType, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $OrderItemsTable extends OrderItems
    with TableInfo<$OrderItemsTable, OrderItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OrderItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _orderIdMeta =
      const VerificationMeta('orderId');
  @override
  late final GeneratedColumn<int> orderId = GeneratedColumn<int>(
      'order_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES orders (id)'));
  static const VerificationMeta _productIdMeta =
      const VerificationMeta('productId');
  @override
  late final GeneratedColumn<int> productId = GeneratedColumn<int>(
      'product_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES products (id)'));
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
      'quantity', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _unitPriceMeta =
      const VerificationMeta('unitPrice');
  @override
  late final GeneratedColumn<double> unitPrice = GeneratedColumn<double>(
      'unit_price', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _totalPriceMeta =
      const VerificationMeta('totalPrice');
  @override
  late final GeneratedColumn<double> totalPrice = GeneratedColumn<double>(
      'total_price', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, orderId, productId, quantity, unitPrice, totalPrice];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'order_items';
  @override
  VerificationContext validateIntegrity(Insertable<OrderItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('order_id')) {
      context.handle(_orderIdMeta,
          orderId.isAcceptableOrUnknown(data['order_id']!, _orderIdMeta));
    } else if (isInserting) {
      context.missing(_orderIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(_productIdMeta,
          productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta));
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    }
    if (data.containsKey('unit_price')) {
      context.handle(_unitPriceMeta,
          unitPrice.isAcceptableOrUnknown(data['unit_price']!, _unitPriceMeta));
    } else if (isInserting) {
      context.missing(_unitPriceMeta);
    }
    if (data.containsKey('total_price')) {
      context.handle(
          _totalPriceMeta,
          totalPrice.isAcceptableOrUnknown(
              data['total_price']!, _totalPriceMeta));
    } else if (isInserting) {
      context.missing(_totalPriceMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OrderItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OrderItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      orderId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order_id'])!,
      productId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}product_id'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantity'])!,
      unitPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}unit_price'])!,
      totalPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total_price'])!,
    );
  }

  @override
  $OrderItemsTable createAlias(String alias) {
    return $OrderItemsTable(attachedDatabase, alias);
  }
}

class OrderItem extends DataClass implements Insertable<OrderItem> {
  final int id;
  final int orderId;
  final int productId;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  const OrderItem(
      {required this.id,
      required this.orderId,
      required this.productId,
      required this.quantity,
      required this.unitPrice,
      required this.totalPrice});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['order_id'] = Variable<int>(orderId);
    map['product_id'] = Variable<int>(productId);
    map['quantity'] = Variable<int>(quantity);
    map['unit_price'] = Variable<double>(unitPrice);
    map['total_price'] = Variable<double>(totalPrice);
    return map;
  }

  OrderItemsCompanion toCompanion(bool nullToAbsent) {
    return OrderItemsCompanion(
      id: Value(id),
      orderId: Value(orderId),
      productId: Value(productId),
      quantity: Value(quantity),
      unitPrice: Value(unitPrice),
      totalPrice: Value(totalPrice),
    );
  }

  factory OrderItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OrderItem(
      id: serializer.fromJson<int>(json['id']),
      orderId: serializer.fromJson<int>(json['orderId']),
      productId: serializer.fromJson<int>(json['productId']),
      quantity: serializer.fromJson<int>(json['quantity']),
      unitPrice: serializer.fromJson<double>(json['unitPrice']),
      totalPrice: serializer.fromJson<double>(json['totalPrice']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'orderId': serializer.toJson<int>(orderId),
      'productId': serializer.toJson<int>(productId),
      'quantity': serializer.toJson<int>(quantity),
      'unitPrice': serializer.toJson<double>(unitPrice),
      'totalPrice': serializer.toJson<double>(totalPrice),
    };
  }

  OrderItem copyWith(
          {int? id,
          int? orderId,
          int? productId,
          int? quantity,
          double? unitPrice,
          double? totalPrice}) =>
      OrderItem(
        id: id ?? this.id,
        orderId: orderId ?? this.orderId,
        productId: productId ?? this.productId,
        quantity: quantity ?? this.quantity,
        unitPrice: unitPrice ?? this.unitPrice,
        totalPrice: totalPrice ?? this.totalPrice,
      );
  OrderItem copyWithCompanion(OrderItemsCompanion data) {
    return OrderItem(
      id: data.id.present ? data.id.value : this.id,
      orderId: data.orderId.present ? data.orderId.value : this.orderId,
      productId: data.productId.present ? data.productId.value : this.productId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unitPrice: data.unitPrice.present ? data.unitPrice.value : this.unitPrice,
      totalPrice:
          data.totalPrice.present ? data.totalPrice.value : this.totalPrice,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OrderItem(')
          ..write('id: $id, ')
          ..write('orderId: $orderId, ')
          ..write('productId: $productId, ')
          ..write('quantity: $quantity, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('totalPrice: $totalPrice')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, orderId, productId, quantity, unitPrice, totalPrice);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OrderItem &&
          other.id == this.id &&
          other.orderId == this.orderId &&
          other.productId == this.productId &&
          other.quantity == this.quantity &&
          other.unitPrice == this.unitPrice &&
          other.totalPrice == this.totalPrice);
}

class OrderItemsCompanion extends UpdateCompanion<OrderItem> {
  final Value<int> id;
  final Value<int> orderId;
  final Value<int> productId;
  final Value<int> quantity;
  final Value<double> unitPrice;
  final Value<double> totalPrice;
  const OrderItemsCompanion({
    this.id = const Value.absent(),
    this.orderId = const Value.absent(),
    this.productId = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unitPrice = const Value.absent(),
    this.totalPrice = const Value.absent(),
  });
  OrderItemsCompanion.insert({
    this.id = const Value.absent(),
    required int orderId,
    required int productId,
    this.quantity = const Value.absent(),
    required double unitPrice,
    required double totalPrice,
  })  : orderId = Value(orderId),
        productId = Value(productId),
        unitPrice = Value(unitPrice),
        totalPrice = Value(totalPrice);
  static Insertable<OrderItem> custom({
    Expression<int>? id,
    Expression<int>? orderId,
    Expression<int>? productId,
    Expression<int>? quantity,
    Expression<double>? unitPrice,
    Expression<double>? totalPrice,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (orderId != null) 'order_id': orderId,
      if (productId != null) 'product_id': productId,
      if (quantity != null) 'quantity': quantity,
      if (unitPrice != null) 'unit_price': unitPrice,
      if (totalPrice != null) 'total_price': totalPrice,
    });
  }

  OrderItemsCompanion copyWith(
      {Value<int>? id,
      Value<int>? orderId,
      Value<int>? productId,
      Value<int>? quantity,
      Value<double>? unitPrice,
      Value<double>? totalPrice}) {
    return OrderItemsCompanion(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (orderId.present) {
      map['order_id'] = Variable<int>(orderId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<int>(productId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (unitPrice.present) {
      map['unit_price'] = Variable<double>(unitPrice.value);
    }
    if (totalPrice.present) {
      map['total_price'] = Variable<double>(totalPrice.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OrderItemsCompanion(')
          ..write('id: $id, ')
          ..write('orderId: $orderId, ')
          ..write('productId: $productId, ')
          ..write('quantity: $quantity, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('totalPrice: $totalPrice')
          ..write(')'))
        .toString();
  }
}

class $InvoicesTable extends Invoices with TableInfo<$InvoicesTable, Invoice> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InvoicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _orderIdMeta =
      const VerificationMeta('orderId');
  @override
  late final GeneratedColumn<int> orderId = GeneratedColumn<int>(
      'order_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES orders (id)'));
  static const VerificationMeta _invoiceNumberMeta =
      const VerificationMeta('invoiceNumber');
  @override
  late final GeneratedColumn<String> invoiceNumber = GeneratedColumn<String>(
      'invoice_number', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _subtotalMeta =
      const VerificationMeta('subtotal');
  @override
  late final GeneratedColumn<double> subtotal = GeneratedColumn<double>(
      'subtotal', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _taxAmountMeta =
      const VerificationMeta('taxAmount');
  @override
  late final GeneratedColumn<double> taxAmount = GeneratedColumn<double>(
      'tax_amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _serviceChargeMeta =
      const VerificationMeta('serviceCharge');
  @override
  late final GeneratedColumn<double> serviceCharge = GeneratedColumn<double>(
      'service_charge', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _grandTotalMeta =
      const VerificationMeta('grandTotal');
  @override
  late final GeneratedColumn<double> grandTotal = GeneratedColumn<double>(
      'grand_total', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _paymentMethodMeta =
      const VerificationMeta('paymentMethod');
  @override
  late final GeneratedColumn<String> paymentMethod = GeneratedColumn<String>(
      'payment_method', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('cash'));
  static const VerificationMeta _playStationAmountMeta =
      const VerificationMeta('playStationAmount');
  @override
  late final GeneratedColumn<double> playStationAmount =
      GeneratedColumn<double>('play_station_amount', aliasedName, false,
          type: DriftSqlType.double,
          requiredDuringInsert: false,
          defaultValue: const Constant(0.0));
  static const VerificationMeta _isClosedShiftMeta =
      const VerificationMeta('isClosedShift');
  @override
  late final GeneratedColumn<bool> isClosedShift = GeneratedColumn<bool>(
      'is_closed_shift', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_closed_shift" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        orderId,
        invoiceNumber,
        subtotal,
        taxAmount,
        serviceCharge,
        grandTotal,
        paymentMethod,
        playStationAmount,
        isClosedShift,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'invoices';
  @override
  VerificationContext validateIntegrity(Insertable<Invoice> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('order_id')) {
      context.handle(_orderIdMeta,
          orderId.isAcceptableOrUnknown(data['order_id']!, _orderIdMeta));
    } else if (isInserting) {
      context.missing(_orderIdMeta);
    }
    if (data.containsKey('invoice_number')) {
      context.handle(
          _invoiceNumberMeta,
          invoiceNumber.isAcceptableOrUnknown(
              data['invoice_number']!, _invoiceNumberMeta));
    } else if (isInserting) {
      context.missing(_invoiceNumberMeta);
    }
    if (data.containsKey('subtotal')) {
      context.handle(_subtotalMeta,
          subtotal.isAcceptableOrUnknown(data['subtotal']!, _subtotalMeta));
    } else if (isInserting) {
      context.missing(_subtotalMeta);
    }
    if (data.containsKey('tax_amount')) {
      context.handle(_taxAmountMeta,
          taxAmount.isAcceptableOrUnknown(data['tax_amount']!, _taxAmountMeta));
    } else if (isInserting) {
      context.missing(_taxAmountMeta);
    }
    if (data.containsKey('service_charge')) {
      context.handle(
          _serviceChargeMeta,
          serviceCharge.isAcceptableOrUnknown(
              data['service_charge']!, _serviceChargeMeta));
    } else if (isInserting) {
      context.missing(_serviceChargeMeta);
    }
    if (data.containsKey('grand_total')) {
      context.handle(
          _grandTotalMeta,
          grandTotal.isAcceptableOrUnknown(
              data['grand_total']!, _grandTotalMeta));
    } else if (isInserting) {
      context.missing(_grandTotalMeta);
    }
    if (data.containsKey('payment_method')) {
      context.handle(
          _paymentMethodMeta,
          paymentMethod.isAcceptableOrUnknown(
              data['payment_method']!, _paymentMethodMeta));
    }
    if (data.containsKey('play_station_amount')) {
      context.handle(
          _playStationAmountMeta,
          playStationAmount.isAcceptableOrUnknown(
              data['play_station_amount']!, _playStationAmountMeta));
    }
    if (data.containsKey('is_closed_shift')) {
      context.handle(
          _isClosedShiftMeta,
          isClosedShift.isAcceptableOrUnknown(
              data['is_closed_shift']!, _isClosedShiftMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Invoice map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Invoice(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      orderId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order_id'])!,
      invoiceNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}invoice_number'])!,
      subtotal: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}subtotal'])!,
      taxAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}tax_amount'])!,
      serviceCharge: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}service_charge'])!,
      grandTotal: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}grand_total'])!,
      paymentMethod: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payment_method'])!,
      playStationAmount: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}play_station_amount'])!,
      isClosedShift: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_closed_shift'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $InvoicesTable createAlias(String alias) {
    return $InvoicesTable(attachedDatabase, alias);
  }
}

class Invoice extends DataClass implements Insertable<Invoice> {
  final int id;
  final int orderId;
  final String invoiceNumber;
  final double subtotal;
  final double taxAmount;
  final double serviceCharge;
  final double grandTotal;
  final String paymentMethod;
  final double playStationAmount;
  final bool isClosedShift;
  final DateTime createdAt;
  const Invoice(
      {required this.id,
      required this.orderId,
      required this.invoiceNumber,
      required this.subtotal,
      required this.taxAmount,
      required this.serviceCharge,
      required this.grandTotal,
      required this.paymentMethod,
      required this.playStationAmount,
      required this.isClosedShift,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['order_id'] = Variable<int>(orderId);
    map['invoice_number'] = Variable<String>(invoiceNumber);
    map['subtotal'] = Variable<double>(subtotal);
    map['tax_amount'] = Variable<double>(taxAmount);
    map['service_charge'] = Variable<double>(serviceCharge);
    map['grand_total'] = Variable<double>(grandTotal);
    map['payment_method'] = Variable<String>(paymentMethod);
    map['play_station_amount'] = Variable<double>(playStationAmount);
    map['is_closed_shift'] = Variable<bool>(isClosedShift);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  InvoicesCompanion toCompanion(bool nullToAbsent) {
    return InvoicesCompanion(
      id: Value(id),
      orderId: Value(orderId),
      invoiceNumber: Value(invoiceNumber),
      subtotal: Value(subtotal),
      taxAmount: Value(taxAmount),
      serviceCharge: Value(serviceCharge),
      grandTotal: Value(grandTotal),
      paymentMethod: Value(paymentMethod),
      playStationAmount: Value(playStationAmount),
      isClosedShift: Value(isClosedShift),
      createdAt: Value(createdAt),
    );
  }

  factory Invoice.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Invoice(
      id: serializer.fromJson<int>(json['id']),
      orderId: serializer.fromJson<int>(json['orderId']),
      invoiceNumber: serializer.fromJson<String>(json['invoiceNumber']),
      subtotal: serializer.fromJson<double>(json['subtotal']),
      taxAmount: serializer.fromJson<double>(json['taxAmount']),
      serviceCharge: serializer.fromJson<double>(json['serviceCharge']),
      grandTotal: serializer.fromJson<double>(json['grandTotal']),
      paymentMethod: serializer.fromJson<String>(json['paymentMethod']),
      playStationAmount: serializer.fromJson<double>(json['playStationAmount']),
      isClosedShift: serializer.fromJson<bool>(json['isClosedShift']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'orderId': serializer.toJson<int>(orderId),
      'invoiceNumber': serializer.toJson<String>(invoiceNumber),
      'subtotal': serializer.toJson<double>(subtotal),
      'taxAmount': serializer.toJson<double>(taxAmount),
      'serviceCharge': serializer.toJson<double>(serviceCharge),
      'grandTotal': serializer.toJson<double>(grandTotal),
      'paymentMethod': serializer.toJson<String>(paymentMethod),
      'playStationAmount': serializer.toJson<double>(playStationAmount),
      'isClosedShift': serializer.toJson<bool>(isClosedShift),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Invoice copyWith(
          {int? id,
          int? orderId,
          String? invoiceNumber,
          double? subtotal,
          double? taxAmount,
          double? serviceCharge,
          double? grandTotal,
          String? paymentMethod,
          double? playStationAmount,
          bool? isClosedShift,
          DateTime? createdAt}) =>
      Invoice(
        id: id ?? this.id,
        orderId: orderId ?? this.orderId,
        invoiceNumber: invoiceNumber ?? this.invoiceNumber,
        subtotal: subtotal ?? this.subtotal,
        taxAmount: taxAmount ?? this.taxAmount,
        serviceCharge: serviceCharge ?? this.serviceCharge,
        grandTotal: grandTotal ?? this.grandTotal,
        paymentMethod: paymentMethod ?? this.paymentMethod,
        playStationAmount: playStationAmount ?? this.playStationAmount,
        isClosedShift: isClosedShift ?? this.isClosedShift,
        createdAt: createdAt ?? this.createdAt,
      );
  Invoice copyWithCompanion(InvoicesCompanion data) {
    return Invoice(
      id: data.id.present ? data.id.value : this.id,
      orderId: data.orderId.present ? data.orderId.value : this.orderId,
      invoiceNumber: data.invoiceNumber.present
          ? data.invoiceNumber.value
          : this.invoiceNumber,
      subtotal: data.subtotal.present ? data.subtotal.value : this.subtotal,
      taxAmount: data.taxAmount.present ? data.taxAmount.value : this.taxAmount,
      serviceCharge: data.serviceCharge.present
          ? data.serviceCharge.value
          : this.serviceCharge,
      grandTotal:
          data.grandTotal.present ? data.grandTotal.value : this.grandTotal,
      paymentMethod: data.paymentMethod.present
          ? data.paymentMethod.value
          : this.paymentMethod,
      playStationAmount: data.playStationAmount.present
          ? data.playStationAmount.value
          : this.playStationAmount,
      isClosedShift: data.isClosedShift.present
          ? data.isClosedShift.value
          : this.isClosedShift,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Invoice(')
          ..write('id: $id, ')
          ..write('orderId: $orderId, ')
          ..write('invoiceNumber: $invoiceNumber, ')
          ..write('subtotal: $subtotal, ')
          ..write('taxAmount: $taxAmount, ')
          ..write('serviceCharge: $serviceCharge, ')
          ..write('grandTotal: $grandTotal, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('playStationAmount: $playStationAmount, ')
          ..write('isClosedShift: $isClosedShift, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      orderId,
      invoiceNumber,
      subtotal,
      taxAmount,
      serviceCharge,
      grandTotal,
      paymentMethod,
      playStationAmount,
      isClosedShift,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Invoice &&
          other.id == this.id &&
          other.orderId == this.orderId &&
          other.invoiceNumber == this.invoiceNumber &&
          other.subtotal == this.subtotal &&
          other.taxAmount == this.taxAmount &&
          other.serviceCharge == this.serviceCharge &&
          other.grandTotal == this.grandTotal &&
          other.paymentMethod == this.paymentMethod &&
          other.playStationAmount == this.playStationAmount &&
          other.isClosedShift == this.isClosedShift &&
          other.createdAt == this.createdAt);
}

class InvoicesCompanion extends UpdateCompanion<Invoice> {
  final Value<int> id;
  final Value<int> orderId;
  final Value<String> invoiceNumber;
  final Value<double> subtotal;
  final Value<double> taxAmount;
  final Value<double> serviceCharge;
  final Value<double> grandTotal;
  final Value<String> paymentMethod;
  final Value<double> playStationAmount;
  final Value<bool> isClosedShift;
  final Value<DateTime> createdAt;
  const InvoicesCompanion({
    this.id = const Value.absent(),
    this.orderId = const Value.absent(),
    this.invoiceNumber = const Value.absent(),
    this.subtotal = const Value.absent(),
    this.taxAmount = const Value.absent(),
    this.serviceCharge = const Value.absent(),
    this.grandTotal = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.playStationAmount = const Value.absent(),
    this.isClosedShift = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  InvoicesCompanion.insert({
    this.id = const Value.absent(),
    required int orderId,
    required String invoiceNumber,
    required double subtotal,
    required double taxAmount,
    required double serviceCharge,
    required double grandTotal,
    this.paymentMethod = const Value.absent(),
    this.playStationAmount = const Value.absent(),
    this.isClosedShift = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : orderId = Value(orderId),
        invoiceNumber = Value(invoiceNumber),
        subtotal = Value(subtotal),
        taxAmount = Value(taxAmount),
        serviceCharge = Value(serviceCharge),
        grandTotal = Value(grandTotal);
  static Insertable<Invoice> custom({
    Expression<int>? id,
    Expression<int>? orderId,
    Expression<String>? invoiceNumber,
    Expression<double>? subtotal,
    Expression<double>? taxAmount,
    Expression<double>? serviceCharge,
    Expression<double>? grandTotal,
    Expression<String>? paymentMethod,
    Expression<double>? playStationAmount,
    Expression<bool>? isClosedShift,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (orderId != null) 'order_id': orderId,
      if (invoiceNumber != null) 'invoice_number': invoiceNumber,
      if (subtotal != null) 'subtotal': subtotal,
      if (taxAmount != null) 'tax_amount': taxAmount,
      if (serviceCharge != null) 'service_charge': serviceCharge,
      if (grandTotal != null) 'grand_total': grandTotal,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (playStationAmount != null) 'play_station_amount': playStationAmount,
      if (isClosedShift != null) 'is_closed_shift': isClosedShift,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  InvoicesCompanion copyWith(
      {Value<int>? id,
      Value<int>? orderId,
      Value<String>? invoiceNumber,
      Value<double>? subtotal,
      Value<double>? taxAmount,
      Value<double>? serviceCharge,
      Value<double>? grandTotal,
      Value<String>? paymentMethod,
      Value<double>? playStationAmount,
      Value<bool>? isClosedShift,
      Value<DateTime>? createdAt}) {
    return InvoicesCompanion(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      subtotal: subtotal ?? this.subtotal,
      taxAmount: taxAmount ?? this.taxAmount,
      serviceCharge: serviceCharge ?? this.serviceCharge,
      grandTotal: grandTotal ?? this.grandTotal,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      playStationAmount: playStationAmount ?? this.playStationAmount,
      isClosedShift: isClosedShift ?? this.isClosedShift,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (orderId.present) {
      map['order_id'] = Variable<int>(orderId.value);
    }
    if (invoiceNumber.present) {
      map['invoice_number'] = Variable<String>(invoiceNumber.value);
    }
    if (subtotal.present) {
      map['subtotal'] = Variable<double>(subtotal.value);
    }
    if (taxAmount.present) {
      map['tax_amount'] = Variable<double>(taxAmount.value);
    }
    if (serviceCharge.present) {
      map['service_charge'] = Variable<double>(serviceCharge.value);
    }
    if (grandTotal.present) {
      map['grand_total'] = Variable<double>(grandTotal.value);
    }
    if (paymentMethod.present) {
      map['payment_method'] = Variable<String>(paymentMethod.value);
    }
    if (playStationAmount.present) {
      map['play_station_amount'] = Variable<double>(playStationAmount.value);
    }
    if (isClosedShift.present) {
      map['is_closed_shift'] = Variable<bool>(isClosedShift.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InvoicesCompanion(')
          ..write('id: $id, ')
          ..write('orderId: $orderId, ')
          ..write('invoiceNumber: $invoiceNumber, ')
          ..write('subtotal: $subtotal, ')
          ..write('taxAmount: $taxAmount, ')
          ..write('serviceCharge: $serviceCharge, ')
          ..write('grandTotal: $grandTotal, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('playStationAmount: $playStationAmount, ')
          ..write('isClosedShift: $isClosedShift, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $DailyClosingsTable extends DailyClosings
    with TableInfo<$DailyClosingsTable, DailyClosing> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyClosingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _closingDateMeta =
      const VerificationMeta('closingDate');
  @override
  late final GeneratedColumn<String> closingDate = GeneratedColumn<String>(
      'closing_date', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _closingTimeMeta =
      const VerificationMeta('closingTime');
  @override
  late final GeneratedColumn<String> closingTime = GeneratedColumn<String>(
      'closing_time', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _invoiceCountMeta =
      const VerificationMeta('invoiceCount');
  @override
  late final GeneratedColumn<int> invoiceCount = GeneratedColumn<int>(
      'invoice_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _grossSalesMeta =
      const VerificationMeta('grossSales');
  @override
  late final GeneratedColumn<double> grossSales = GeneratedColumn<double>(
      'gross_sales', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _discountsMeta =
      const VerificationMeta('discounts');
  @override
  late final GeneratedColumn<double> discounts = GeneratedColumn<double>(
      'discounts', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _taxTotalMeta =
      const VerificationMeta('taxTotal');
  @override
  late final GeneratedColumn<double> taxTotal = GeneratedColumn<double>(
      'tax_total', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _netSalesMeta =
      const VerificationMeta('netSales');
  @override
  late final GeneratedColumn<double> netSales = GeneratedColumn<double>(
      'net_sales', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _cashTotalMeta =
      const VerificationMeta('cashTotal');
  @override
  late final GeneratedColumn<double> cashTotal = GeneratedColumn<double>(
      'cash_total', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _cardTotalMeta =
      const VerificationMeta('cardTotal');
  @override
  late final GeneratedColumn<double> cardTotal = GeneratedColumn<double>(
      'card_total', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _otherPaymentsMeta =
      const VerificationMeta('otherPayments');
  @override
  late final GeneratedColumn<double> otherPayments = GeneratedColumn<double>(
      'other_payments', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _playStationTotalMeta =
      const VerificationMeta('playStationTotal');
  @override
  late final GeneratedColumn<double> playStationTotal = GeneratedColumn<double>(
      'play_station_total', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _walletTotalMeta =
      const VerificationMeta('walletTotal');
  @override
  late final GeneratedColumn<double> walletTotal = GeneratedColumn<double>(
      'wallet_total', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _instapayTotalMeta =
      const VerificationMeta('instapayTotal');
  @override
  late final GeneratedColumn<double> instapayTotal = GeneratedColumn<double>(
      'instapay_total', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _totalItemsMeta =
      const VerificationMeta('totalItems');
  @override
  late final GeneratedColumn<int> totalItems = GeneratedColumn<int>(
      'total_items', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('closed'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        closingDate,
        closingTime,
        invoiceCount,
        grossSales,
        discounts,
        taxTotal,
        netSales,
        cashTotal,
        cardTotal,
        otherPayments,
        playStationTotal,
        walletTotal,
        instapayTotal,
        totalItems,
        status,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_closings';
  @override
  VerificationContext validateIntegrity(Insertable<DailyClosing> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('closing_date')) {
      context.handle(
          _closingDateMeta,
          closingDate.isAcceptableOrUnknown(
              data['closing_date']!, _closingDateMeta));
    } else if (isInserting) {
      context.missing(_closingDateMeta);
    }
    if (data.containsKey('closing_time')) {
      context.handle(
          _closingTimeMeta,
          closingTime.isAcceptableOrUnknown(
              data['closing_time']!, _closingTimeMeta));
    } else if (isInserting) {
      context.missing(_closingTimeMeta);
    }
    if (data.containsKey('invoice_count')) {
      context.handle(
          _invoiceCountMeta,
          invoiceCount.isAcceptableOrUnknown(
              data['invoice_count']!, _invoiceCountMeta));
    }
    if (data.containsKey('gross_sales')) {
      context.handle(
          _grossSalesMeta,
          grossSales.isAcceptableOrUnknown(
              data['gross_sales']!, _grossSalesMeta));
    }
    if (data.containsKey('discounts')) {
      context.handle(_discountsMeta,
          discounts.isAcceptableOrUnknown(data['discounts']!, _discountsMeta));
    }
    if (data.containsKey('tax_total')) {
      context.handle(_taxTotalMeta,
          taxTotal.isAcceptableOrUnknown(data['tax_total']!, _taxTotalMeta));
    }
    if (data.containsKey('net_sales')) {
      context.handle(_netSalesMeta,
          netSales.isAcceptableOrUnknown(data['net_sales']!, _netSalesMeta));
    }
    if (data.containsKey('cash_total')) {
      context.handle(_cashTotalMeta,
          cashTotal.isAcceptableOrUnknown(data['cash_total']!, _cashTotalMeta));
    }
    if (data.containsKey('card_total')) {
      context.handle(_cardTotalMeta,
          cardTotal.isAcceptableOrUnknown(data['card_total']!, _cardTotalMeta));
    }
    if (data.containsKey('other_payments')) {
      context.handle(
          _otherPaymentsMeta,
          otherPayments.isAcceptableOrUnknown(
              data['other_payments']!, _otherPaymentsMeta));
    }
    if (data.containsKey('play_station_total')) {
      context.handle(
          _playStationTotalMeta,
          playStationTotal.isAcceptableOrUnknown(
              data['play_station_total']!, _playStationTotalMeta));
    }
    if (data.containsKey('wallet_total')) {
      context.handle(
          _walletTotalMeta,
          walletTotal.isAcceptableOrUnknown(
              data['wallet_total']!, _walletTotalMeta));
    }
    if (data.containsKey('instapay_total')) {
      context.handle(
          _instapayTotalMeta,
          instapayTotal.isAcceptableOrUnknown(
              data['instapay_total']!, _instapayTotalMeta));
    }
    if (data.containsKey('total_items')) {
      context.handle(
          _totalItemsMeta,
          totalItems.isAcceptableOrUnknown(
              data['total_items']!, _totalItemsMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DailyClosing map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyClosing(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      closingDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}closing_date'])!,
      closingTime: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}closing_time'])!,
      invoiceCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}invoice_count'])!,
      grossSales: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}gross_sales'])!,
      discounts: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}discounts'])!,
      taxTotal: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}tax_total'])!,
      netSales: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}net_sales'])!,
      cashTotal: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}cash_total'])!,
      cardTotal: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}card_total'])!,
      otherPayments: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}other_payments'])!,
      playStationTotal: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}play_station_total'])!,
      walletTotal: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}wallet_total'])!,
      instapayTotal: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}instapay_total'])!,
      totalItems: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_items'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $DailyClosingsTable createAlias(String alias) {
    return $DailyClosingsTable(attachedDatabase, alias);
  }
}

class DailyClosing extends DataClass implements Insertable<DailyClosing> {
  final int id;

  /// Stored as yyyy-MM-dd string for uniqueness constraint
  final String closingDate;
  final String closingTime;
  final int invoiceCount;
  final double grossSales;
  final double discounts;
  final double taxTotal;
  final double netSales;
  final double cashTotal;
  final double cardTotal;
  final double otherPayments;
  final double playStationTotal;
  final double walletTotal;
  final double instapayTotal;
  final int totalItems;

  /// 'open' or 'closed'
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  const DailyClosing(
      {required this.id,
      required this.closingDate,
      required this.closingTime,
      required this.invoiceCount,
      required this.grossSales,
      required this.discounts,
      required this.taxTotal,
      required this.netSales,
      required this.cashTotal,
      required this.cardTotal,
      required this.otherPayments,
      required this.playStationTotal,
      required this.walletTotal,
      required this.instapayTotal,
      required this.totalItems,
      required this.status,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['closing_date'] = Variable<String>(closingDate);
    map['closing_time'] = Variable<String>(closingTime);
    map['invoice_count'] = Variable<int>(invoiceCount);
    map['gross_sales'] = Variable<double>(grossSales);
    map['discounts'] = Variable<double>(discounts);
    map['tax_total'] = Variable<double>(taxTotal);
    map['net_sales'] = Variable<double>(netSales);
    map['cash_total'] = Variable<double>(cashTotal);
    map['card_total'] = Variable<double>(cardTotal);
    map['other_payments'] = Variable<double>(otherPayments);
    map['play_station_total'] = Variable<double>(playStationTotal);
    map['wallet_total'] = Variable<double>(walletTotal);
    map['instapay_total'] = Variable<double>(instapayTotal);
    map['total_items'] = Variable<int>(totalItems);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DailyClosingsCompanion toCompanion(bool nullToAbsent) {
    return DailyClosingsCompanion(
      id: Value(id),
      closingDate: Value(closingDate),
      closingTime: Value(closingTime),
      invoiceCount: Value(invoiceCount),
      grossSales: Value(grossSales),
      discounts: Value(discounts),
      taxTotal: Value(taxTotal),
      netSales: Value(netSales),
      cashTotal: Value(cashTotal),
      cardTotal: Value(cardTotal),
      otherPayments: Value(otherPayments),
      playStationTotal: Value(playStationTotal),
      walletTotal: Value(walletTotal),
      instapayTotal: Value(instapayTotal),
      totalItems: Value(totalItems),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory DailyClosing.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyClosing(
      id: serializer.fromJson<int>(json['id']),
      closingDate: serializer.fromJson<String>(json['closingDate']),
      closingTime: serializer.fromJson<String>(json['closingTime']),
      invoiceCount: serializer.fromJson<int>(json['invoiceCount']),
      grossSales: serializer.fromJson<double>(json['grossSales']),
      discounts: serializer.fromJson<double>(json['discounts']),
      taxTotal: serializer.fromJson<double>(json['taxTotal']),
      netSales: serializer.fromJson<double>(json['netSales']),
      cashTotal: serializer.fromJson<double>(json['cashTotal']),
      cardTotal: serializer.fromJson<double>(json['cardTotal']),
      otherPayments: serializer.fromJson<double>(json['otherPayments']),
      playStationTotal: serializer.fromJson<double>(json['playStationTotal']),
      walletTotal: serializer.fromJson<double>(json['walletTotal']),
      instapayTotal: serializer.fromJson<double>(json['instapayTotal']),
      totalItems: serializer.fromJson<int>(json['totalItems']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'closingDate': serializer.toJson<String>(closingDate),
      'closingTime': serializer.toJson<String>(closingTime),
      'invoiceCount': serializer.toJson<int>(invoiceCount),
      'grossSales': serializer.toJson<double>(grossSales),
      'discounts': serializer.toJson<double>(discounts),
      'taxTotal': serializer.toJson<double>(taxTotal),
      'netSales': serializer.toJson<double>(netSales),
      'cashTotal': serializer.toJson<double>(cashTotal),
      'cardTotal': serializer.toJson<double>(cardTotal),
      'otherPayments': serializer.toJson<double>(otherPayments),
      'playStationTotal': serializer.toJson<double>(playStationTotal),
      'walletTotal': serializer.toJson<double>(walletTotal),
      'instapayTotal': serializer.toJson<double>(instapayTotal),
      'totalItems': serializer.toJson<int>(totalItems),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DailyClosing copyWith(
          {int? id,
          String? closingDate,
          String? closingTime,
          int? invoiceCount,
          double? grossSales,
          double? discounts,
          double? taxTotal,
          double? netSales,
          double? cashTotal,
          double? cardTotal,
          double? otherPayments,
          double? playStationTotal,
          double? walletTotal,
          double? instapayTotal,
          int? totalItems,
          String? status,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      DailyClosing(
        id: id ?? this.id,
        closingDate: closingDate ?? this.closingDate,
        closingTime: closingTime ?? this.closingTime,
        invoiceCount: invoiceCount ?? this.invoiceCount,
        grossSales: grossSales ?? this.grossSales,
        discounts: discounts ?? this.discounts,
        taxTotal: taxTotal ?? this.taxTotal,
        netSales: netSales ?? this.netSales,
        cashTotal: cashTotal ?? this.cashTotal,
        cardTotal: cardTotal ?? this.cardTotal,
        otherPayments: otherPayments ?? this.otherPayments,
        playStationTotal: playStationTotal ?? this.playStationTotal,
        walletTotal: walletTotal ?? this.walletTotal,
        instapayTotal: instapayTotal ?? this.instapayTotal,
        totalItems: totalItems ?? this.totalItems,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  DailyClosing copyWithCompanion(DailyClosingsCompanion data) {
    return DailyClosing(
      id: data.id.present ? data.id.value : this.id,
      closingDate:
          data.closingDate.present ? data.closingDate.value : this.closingDate,
      closingTime:
          data.closingTime.present ? data.closingTime.value : this.closingTime,
      invoiceCount: data.invoiceCount.present
          ? data.invoiceCount.value
          : this.invoiceCount,
      grossSales:
          data.grossSales.present ? data.grossSales.value : this.grossSales,
      discounts: data.discounts.present ? data.discounts.value : this.discounts,
      taxTotal: data.taxTotal.present ? data.taxTotal.value : this.taxTotal,
      netSales: data.netSales.present ? data.netSales.value : this.netSales,
      cashTotal: data.cashTotal.present ? data.cashTotal.value : this.cashTotal,
      cardTotal: data.cardTotal.present ? data.cardTotal.value : this.cardTotal,
      otherPayments: data.otherPayments.present
          ? data.otherPayments.value
          : this.otherPayments,
      playStationTotal: data.playStationTotal.present
          ? data.playStationTotal.value
          : this.playStationTotal,
      walletTotal:
          data.walletTotal.present ? data.walletTotal.value : this.walletTotal,
      instapayTotal: data.instapayTotal.present
          ? data.instapayTotal.value
          : this.instapayTotal,
      totalItems:
          data.totalItems.present ? data.totalItems.value : this.totalItems,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyClosing(')
          ..write('id: $id, ')
          ..write('closingDate: $closingDate, ')
          ..write('closingTime: $closingTime, ')
          ..write('invoiceCount: $invoiceCount, ')
          ..write('grossSales: $grossSales, ')
          ..write('discounts: $discounts, ')
          ..write('taxTotal: $taxTotal, ')
          ..write('netSales: $netSales, ')
          ..write('cashTotal: $cashTotal, ')
          ..write('cardTotal: $cardTotal, ')
          ..write('otherPayments: $otherPayments, ')
          ..write('playStationTotal: $playStationTotal, ')
          ..write('walletTotal: $walletTotal, ')
          ..write('instapayTotal: $instapayTotal, ')
          ..write('totalItems: $totalItems, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      closingDate,
      closingTime,
      invoiceCount,
      grossSales,
      discounts,
      taxTotal,
      netSales,
      cashTotal,
      cardTotal,
      otherPayments,
      playStationTotal,
      walletTotal,
      instapayTotal,
      totalItems,
      status,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyClosing &&
          other.id == this.id &&
          other.closingDate == this.closingDate &&
          other.closingTime == this.closingTime &&
          other.invoiceCount == this.invoiceCount &&
          other.grossSales == this.grossSales &&
          other.discounts == this.discounts &&
          other.taxTotal == this.taxTotal &&
          other.netSales == this.netSales &&
          other.cashTotal == this.cashTotal &&
          other.cardTotal == this.cardTotal &&
          other.otherPayments == this.otherPayments &&
          other.playStationTotal == this.playStationTotal &&
          other.walletTotal == this.walletTotal &&
          other.instapayTotal == this.instapayTotal &&
          other.totalItems == this.totalItems &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class DailyClosingsCompanion extends UpdateCompanion<DailyClosing> {
  final Value<int> id;
  final Value<String> closingDate;
  final Value<String> closingTime;
  final Value<int> invoiceCount;
  final Value<double> grossSales;
  final Value<double> discounts;
  final Value<double> taxTotal;
  final Value<double> netSales;
  final Value<double> cashTotal;
  final Value<double> cardTotal;
  final Value<double> otherPayments;
  final Value<double> playStationTotal;
  final Value<double> walletTotal;
  final Value<double> instapayTotal;
  final Value<int> totalItems;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const DailyClosingsCompanion({
    this.id = const Value.absent(),
    this.closingDate = const Value.absent(),
    this.closingTime = const Value.absent(),
    this.invoiceCount = const Value.absent(),
    this.grossSales = const Value.absent(),
    this.discounts = const Value.absent(),
    this.taxTotal = const Value.absent(),
    this.netSales = const Value.absent(),
    this.cashTotal = const Value.absent(),
    this.cardTotal = const Value.absent(),
    this.otherPayments = const Value.absent(),
    this.playStationTotal = const Value.absent(),
    this.walletTotal = const Value.absent(),
    this.instapayTotal = const Value.absent(),
    this.totalItems = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  DailyClosingsCompanion.insert({
    this.id = const Value.absent(),
    required String closingDate,
    required String closingTime,
    this.invoiceCount = const Value.absent(),
    this.grossSales = const Value.absent(),
    this.discounts = const Value.absent(),
    this.taxTotal = const Value.absent(),
    this.netSales = const Value.absent(),
    this.cashTotal = const Value.absent(),
    this.cardTotal = const Value.absent(),
    this.otherPayments = const Value.absent(),
    this.playStationTotal = const Value.absent(),
    this.walletTotal = const Value.absent(),
    this.instapayTotal = const Value.absent(),
    this.totalItems = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : closingDate = Value(closingDate),
        closingTime = Value(closingTime);
  static Insertable<DailyClosing> custom({
    Expression<int>? id,
    Expression<String>? closingDate,
    Expression<String>? closingTime,
    Expression<int>? invoiceCount,
    Expression<double>? grossSales,
    Expression<double>? discounts,
    Expression<double>? taxTotal,
    Expression<double>? netSales,
    Expression<double>? cashTotal,
    Expression<double>? cardTotal,
    Expression<double>? otherPayments,
    Expression<double>? playStationTotal,
    Expression<double>? walletTotal,
    Expression<double>? instapayTotal,
    Expression<int>? totalItems,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (closingDate != null) 'closing_date': closingDate,
      if (closingTime != null) 'closing_time': closingTime,
      if (invoiceCount != null) 'invoice_count': invoiceCount,
      if (grossSales != null) 'gross_sales': grossSales,
      if (discounts != null) 'discounts': discounts,
      if (taxTotal != null) 'tax_total': taxTotal,
      if (netSales != null) 'net_sales': netSales,
      if (cashTotal != null) 'cash_total': cashTotal,
      if (cardTotal != null) 'card_total': cardTotal,
      if (otherPayments != null) 'other_payments': otherPayments,
      if (playStationTotal != null) 'play_station_total': playStationTotal,
      if (walletTotal != null) 'wallet_total': walletTotal,
      if (instapayTotal != null) 'instapay_total': instapayTotal,
      if (totalItems != null) 'total_items': totalItems,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  DailyClosingsCompanion copyWith(
      {Value<int>? id,
      Value<String>? closingDate,
      Value<String>? closingTime,
      Value<int>? invoiceCount,
      Value<double>? grossSales,
      Value<double>? discounts,
      Value<double>? taxTotal,
      Value<double>? netSales,
      Value<double>? cashTotal,
      Value<double>? cardTotal,
      Value<double>? otherPayments,
      Value<double>? playStationTotal,
      Value<double>? walletTotal,
      Value<double>? instapayTotal,
      Value<int>? totalItems,
      Value<String>? status,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return DailyClosingsCompanion(
      id: id ?? this.id,
      closingDate: closingDate ?? this.closingDate,
      closingTime: closingTime ?? this.closingTime,
      invoiceCount: invoiceCount ?? this.invoiceCount,
      grossSales: grossSales ?? this.grossSales,
      discounts: discounts ?? this.discounts,
      taxTotal: taxTotal ?? this.taxTotal,
      netSales: netSales ?? this.netSales,
      cashTotal: cashTotal ?? this.cashTotal,
      cardTotal: cardTotal ?? this.cardTotal,
      otherPayments: otherPayments ?? this.otherPayments,
      playStationTotal: playStationTotal ?? this.playStationTotal,
      walletTotal: walletTotal ?? this.walletTotal,
      instapayTotal: instapayTotal ?? this.instapayTotal,
      totalItems: totalItems ?? this.totalItems,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (closingDate.present) {
      map['closing_date'] = Variable<String>(closingDate.value);
    }
    if (closingTime.present) {
      map['closing_time'] = Variable<String>(closingTime.value);
    }
    if (invoiceCount.present) {
      map['invoice_count'] = Variable<int>(invoiceCount.value);
    }
    if (grossSales.present) {
      map['gross_sales'] = Variable<double>(grossSales.value);
    }
    if (discounts.present) {
      map['discounts'] = Variable<double>(discounts.value);
    }
    if (taxTotal.present) {
      map['tax_total'] = Variable<double>(taxTotal.value);
    }
    if (netSales.present) {
      map['net_sales'] = Variable<double>(netSales.value);
    }
    if (cashTotal.present) {
      map['cash_total'] = Variable<double>(cashTotal.value);
    }
    if (cardTotal.present) {
      map['card_total'] = Variable<double>(cardTotal.value);
    }
    if (otherPayments.present) {
      map['other_payments'] = Variable<double>(otherPayments.value);
    }
    if (playStationTotal.present) {
      map['play_station_total'] = Variable<double>(playStationTotal.value);
    }
    if (walletTotal.present) {
      map['wallet_total'] = Variable<double>(walletTotal.value);
    }
    if (instapayTotal.present) {
      map['instapay_total'] = Variable<double>(instapayTotal.value);
    }
    if (totalItems.present) {
      map['total_items'] = Variable<int>(totalItems.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyClosingsCompanion(')
          ..write('id: $id, ')
          ..write('closingDate: $closingDate, ')
          ..write('closingTime: $closingTime, ')
          ..write('invoiceCount: $invoiceCount, ')
          ..write('grossSales: $grossSales, ')
          ..write('discounts: $discounts, ')
          ..write('taxTotal: $taxTotal, ')
          ..write('netSales: $netSales, ')
          ..write('cashTotal: $cashTotal, ')
          ..write('cardTotal: $cardTotal, ')
          ..write('otherPayments: $otherPayments, ')
          ..write('playStationTotal: $playStationTotal, ')
          ..write('walletTotal: $walletTotal, ')
          ..write('instapayTotal: $instapayTotal, ')
          ..write('totalItems: $totalItems, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $WhatsAppQueueTable extends WhatsAppQueue
    with TableInfo<$WhatsAppQueueTable, WhatsAppQueueData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WhatsAppQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _messageTypeMeta =
      const VerificationMeta('messageType');
  @override
  late final GeneratedColumn<String> messageType = GeneratedColumn<String>(
      'message_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _invoiceIdMeta =
      const VerificationMeta('invoiceId');
  @override
  late final GeneratedColumn<int> invoiceId = GeneratedColumn<int>(
      'invoice_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _dailyClosingIdMeta =
      const VerificationMeta('dailyClosingId');
  @override
  late final GeneratedColumn<int> dailyClosingId = GeneratedColumn<int>(
      'daily_closing_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _recipientPhoneMeta =
      const VerificationMeta('recipientPhone');
  @override
  late final GeneratedColumn<String> recipientPhone = GeneratedColumn<String>(
      'recipient_phone', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _messagePayloadMeta =
      const VerificationMeta('messagePayload');
  @override
  late final GeneratedColumn<String> messagePayload = GeneratedColumn<String>(
      'message_payload', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _attemptCountMeta =
      const VerificationMeta('attemptCount');
  @override
  late final GeneratedColumn<int> attemptCount = GeneratedColumn<int>(
      'attempt_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastAttemptAtMeta =
      const VerificationMeta('lastAttemptAt');
  @override
  late final GeneratedColumn<DateTime> lastAttemptAt =
      GeneratedColumn<DateTime>('last_attempt_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _sentAtMeta = const VerificationMeta('sentAt');
  @override
  late final GeneratedColumn<DateTime> sentAt = GeneratedColumn<DateTime>(
      'sent_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _errorMessageMeta =
      const VerificationMeta('errorMessage');
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
      'error_message', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        messageType,
        invoiceId,
        dailyClosingId,
        recipientPhone,
        messagePayload,
        status,
        attemptCount,
        lastAttemptAt,
        sentAt,
        errorMessage,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'whats_app_queue';
  @override
  VerificationContext validateIntegrity(Insertable<WhatsAppQueueData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('message_type')) {
      context.handle(
          _messageTypeMeta,
          messageType.isAcceptableOrUnknown(
              data['message_type']!, _messageTypeMeta));
    } else if (isInserting) {
      context.missing(_messageTypeMeta);
    }
    if (data.containsKey('invoice_id')) {
      context.handle(_invoiceIdMeta,
          invoiceId.isAcceptableOrUnknown(data['invoice_id']!, _invoiceIdMeta));
    }
    if (data.containsKey('daily_closing_id')) {
      context.handle(
          _dailyClosingIdMeta,
          dailyClosingId.isAcceptableOrUnknown(
              data['daily_closing_id']!, _dailyClosingIdMeta));
    }
    if (data.containsKey('recipient_phone')) {
      context.handle(
          _recipientPhoneMeta,
          recipientPhone.isAcceptableOrUnknown(
              data['recipient_phone']!, _recipientPhoneMeta));
    } else if (isInserting) {
      context.missing(_recipientPhoneMeta);
    }
    if (data.containsKey('message_payload')) {
      context.handle(
          _messagePayloadMeta,
          messagePayload.isAcceptableOrUnknown(
              data['message_payload']!, _messagePayloadMeta));
    } else if (isInserting) {
      context.missing(_messagePayloadMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('attempt_count')) {
      context.handle(
          _attemptCountMeta,
          attemptCount.isAcceptableOrUnknown(
              data['attempt_count']!, _attemptCountMeta));
    }
    if (data.containsKey('last_attempt_at')) {
      context.handle(
          _lastAttemptAtMeta,
          lastAttemptAt.isAcceptableOrUnknown(
              data['last_attempt_at']!, _lastAttemptAtMeta));
    }
    if (data.containsKey('sent_at')) {
      context.handle(_sentAtMeta,
          sentAt.isAcceptableOrUnknown(data['sent_at']!, _sentAtMeta));
    }
    if (data.containsKey('error_message')) {
      context.handle(
          _errorMessageMeta,
          errorMessage.isAcceptableOrUnknown(
              data['error_message']!, _errorMessageMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WhatsAppQueueData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WhatsAppQueueData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      messageType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}message_type'])!,
      invoiceId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}invoice_id']),
      dailyClosingId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}daily_closing_id']),
      recipientPhone: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}recipient_phone'])!,
      messagePayload: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}message_payload'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      attemptCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}attempt_count'])!,
      lastAttemptAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_attempt_at']),
      sentAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}sent_at']),
      errorMessage: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}error_message']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $WhatsAppQueueTable createAlias(String alias) {
    return $WhatsAppQueueTable(attachedDatabase, alias);
  }
}

class WhatsAppQueueData extends DataClass
    implements Insertable<WhatsAppQueueData> {
  final int id;
  final String messageType;
  final int? invoiceId;
  final int? dailyClosingId;
  final String recipientPhone;

  /// JSON-encoded message payload (invoice summary or daily report text)
  final String messagePayload;
  final String status;
  final int attemptCount;
  final DateTime? lastAttemptAt;
  final DateTime? sentAt;
  final String? errorMessage;
  final DateTime createdAt;
  final DateTime updatedAt;
  const WhatsAppQueueData(
      {required this.id,
      required this.messageType,
      this.invoiceId,
      this.dailyClosingId,
      required this.recipientPhone,
      required this.messagePayload,
      required this.status,
      required this.attemptCount,
      this.lastAttemptAt,
      this.sentAt,
      this.errorMessage,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['message_type'] = Variable<String>(messageType);
    if (!nullToAbsent || invoiceId != null) {
      map['invoice_id'] = Variable<int>(invoiceId);
    }
    if (!nullToAbsent || dailyClosingId != null) {
      map['daily_closing_id'] = Variable<int>(dailyClosingId);
    }
    map['recipient_phone'] = Variable<String>(recipientPhone);
    map['message_payload'] = Variable<String>(messagePayload);
    map['status'] = Variable<String>(status);
    map['attempt_count'] = Variable<int>(attemptCount);
    if (!nullToAbsent || lastAttemptAt != null) {
      map['last_attempt_at'] = Variable<DateTime>(lastAttemptAt);
    }
    if (!nullToAbsent || sentAt != null) {
      map['sent_at'] = Variable<DateTime>(sentAt);
    }
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  WhatsAppQueueCompanion toCompanion(bool nullToAbsent) {
    return WhatsAppQueueCompanion(
      id: Value(id),
      messageType: Value(messageType),
      invoiceId: invoiceId == null && nullToAbsent
          ? const Value.absent()
          : Value(invoiceId),
      dailyClosingId: dailyClosingId == null && nullToAbsent
          ? const Value.absent()
          : Value(dailyClosingId),
      recipientPhone: Value(recipientPhone),
      messagePayload: Value(messagePayload),
      status: Value(status),
      attemptCount: Value(attemptCount),
      lastAttemptAt: lastAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAttemptAt),
      sentAt:
          sentAt == null && nullToAbsent ? const Value.absent() : Value(sentAt),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory WhatsAppQueueData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WhatsAppQueueData(
      id: serializer.fromJson<int>(json['id']),
      messageType: serializer.fromJson<String>(json['messageType']),
      invoiceId: serializer.fromJson<int?>(json['invoiceId']),
      dailyClosingId: serializer.fromJson<int?>(json['dailyClosingId']),
      recipientPhone: serializer.fromJson<String>(json['recipientPhone']),
      messagePayload: serializer.fromJson<String>(json['messagePayload']),
      status: serializer.fromJson<String>(json['status']),
      attemptCount: serializer.fromJson<int>(json['attemptCount']),
      lastAttemptAt: serializer.fromJson<DateTime?>(json['lastAttemptAt']),
      sentAt: serializer.fromJson<DateTime?>(json['sentAt']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'messageType': serializer.toJson<String>(messageType),
      'invoiceId': serializer.toJson<int?>(invoiceId),
      'dailyClosingId': serializer.toJson<int?>(dailyClosingId),
      'recipientPhone': serializer.toJson<String>(recipientPhone),
      'messagePayload': serializer.toJson<String>(messagePayload),
      'status': serializer.toJson<String>(status),
      'attemptCount': serializer.toJson<int>(attemptCount),
      'lastAttemptAt': serializer.toJson<DateTime?>(lastAttemptAt),
      'sentAt': serializer.toJson<DateTime?>(sentAt),
      'errorMessage': serializer.toJson<String?>(errorMessage),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  WhatsAppQueueData copyWith(
          {int? id,
          String? messageType,
          Value<int?> invoiceId = const Value.absent(),
          Value<int?> dailyClosingId = const Value.absent(),
          String? recipientPhone,
          String? messagePayload,
          String? status,
          int? attemptCount,
          Value<DateTime?> lastAttemptAt = const Value.absent(),
          Value<DateTime?> sentAt = const Value.absent(),
          Value<String?> errorMessage = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      WhatsAppQueueData(
        id: id ?? this.id,
        messageType: messageType ?? this.messageType,
        invoiceId: invoiceId.present ? invoiceId.value : this.invoiceId,
        dailyClosingId:
            dailyClosingId.present ? dailyClosingId.value : this.dailyClosingId,
        recipientPhone: recipientPhone ?? this.recipientPhone,
        messagePayload: messagePayload ?? this.messagePayload,
        status: status ?? this.status,
        attemptCount: attemptCount ?? this.attemptCount,
        lastAttemptAt:
            lastAttemptAt.present ? lastAttemptAt.value : this.lastAttemptAt,
        sentAt: sentAt.present ? sentAt.value : this.sentAt,
        errorMessage:
            errorMessage.present ? errorMessage.value : this.errorMessage,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  WhatsAppQueueData copyWithCompanion(WhatsAppQueueCompanion data) {
    return WhatsAppQueueData(
      id: data.id.present ? data.id.value : this.id,
      messageType:
          data.messageType.present ? data.messageType.value : this.messageType,
      invoiceId: data.invoiceId.present ? data.invoiceId.value : this.invoiceId,
      dailyClosingId: data.dailyClosingId.present
          ? data.dailyClosingId.value
          : this.dailyClosingId,
      recipientPhone: data.recipientPhone.present
          ? data.recipientPhone.value
          : this.recipientPhone,
      messagePayload: data.messagePayload.present
          ? data.messagePayload.value
          : this.messagePayload,
      status: data.status.present ? data.status.value : this.status,
      attemptCount: data.attemptCount.present
          ? data.attemptCount.value
          : this.attemptCount,
      lastAttemptAt: data.lastAttemptAt.present
          ? data.lastAttemptAt.value
          : this.lastAttemptAt,
      sentAt: data.sentAt.present ? data.sentAt.value : this.sentAt,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WhatsAppQueueData(')
          ..write('id: $id, ')
          ..write('messageType: $messageType, ')
          ..write('invoiceId: $invoiceId, ')
          ..write('dailyClosingId: $dailyClosingId, ')
          ..write('recipientPhone: $recipientPhone, ')
          ..write('messagePayload: $messagePayload, ')
          ..write('status: $status, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('lastAttemptAt: $lastAttemptAt, ')
          ..write('sentAt: $sentAt, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      messageType,
      invoiceId,
      dailyClosingId,
      recipientPhone,
      messagePayload,
      status,
      attemptCount,
      lastAttemptAt,
      sentAt,
      errorMessage,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WhatsAppQueueData &&
          other.id == this.id &&
          other.messageType == this.messageType &&
          other.invoiceId == this.invoiceId &&
          other.dailyClosingId == this.dailyClosingId &&
          other.recipientPhone == this.recipientPhone &&
          other.messagePayload == this.messagePayload &&
          other.status == this.status &&
          other.attemptCount == this.attemptCount &&
          other.lastAttemptAt == this.lastAttemptAt &&
          other.sentAt == this.sentAt &&
          other.errorMessage == this.errorMessage &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class WhatsAppQueueCompanion extends UpdateCompanion<WhatsAppQueueData> {
  final Value<int> id;
  final Value<String> messageType;
  final Value<int?> invoiceId;
  final Value<int?> dailyClosingId;
  final Value<String> recipientPhone;
  final Value<String> messagePayload;
  final Value<String> status;
  final Value<int> attemptCount;
  final Value<DateTime?> lastAttemptAt;
  final Value<DateTime?> sentAt;
  final Value<String?> errorMessage;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const WhatsAppQueueCompanion({
    this.id = const Value.absent(),
    this.messageType = const Value.absent(),
    this.invoiceId = const Value.absent(),
    this.dailyClosingId = const Value.absent(),
    this.recipientPhone = const Value.absent(),
    this.messagePayload = const Value.absent(),
    this.status = const Value.absent(),
    this.attemptCount = const Value.absent(),
    this.lastAttemptAt = const Value.absent(),
    this.sentAt = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  WhatsAppQueueCompanion.insert({
    this.id = const Value.absent(),
    required String messageType,
    this.invoiceId = const Value.absent(),
    this.dailyClosingId = const Value.absent(),
    required String recipientPhone,
    required String messagePayload,
    this.status = const Value.absent(),
    this.attemptCount = const Value.absent(),
    this.lastAttemptAt = const Value.absent(),
    this.sentAt = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : messageType = Value(messageType),
        recipientPhone = Value(recipientPhone),
        messagePayload = Value(messagePayload);
  static Insertable<WhatsAppQueueData> custom({
    Expression<int>? id,
    Expression<String>? messageType,
    Expression<int>? invoiceId,
    Expression<int>? dailyClosingId,
    Expression<String>? recipientPhone,
    Expression<String>? messagePayload,
    Expression<String>? status,
    Expression<int>? attemptCount,
    Expression<DateTime>? lastAttemptAt,
    Expression<DateTime>? sentAt,
    Expression<String>? errorMessage,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (messageType != null) 'message_type': messageType,
      if (invoiceId != null) 'invoice_id': invoiceId,
      if (dailyClosingId != null) 'daily_closing_id': dailyClosingId,
      if (recipientPhone != null) 'recipient_phone': recipientPhone,
      if (messagePayload != null) 'message_payload': messagePayload,
      if (status != null) 'status': status,
      if (attemptCount != null) 'attempt_count': attemptCount,
      if (lastAttemptAt != null) 'last_attempt_at': lastAttemptAt,
      if (sentAt != null) 'sent_at': sentAt,
      if (errorMessage != null) 'error_message': errorMessage,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  WhatsAppQueueCompanion copyWith(
      {Value<int>? id,
      Value<String>? messageType,
      Value<int?>? invoiceId,
      Value<int?>? dailyClosingId,
      Value<String>? recipientPhone,
      Value<String>? messagePayload,
      Value<String>? status,
      Value<int>? attemptCount,
      Value<DateTime?>? lastAttemptAt,
      Value<DateTime?>? sentAt,
      Value<String?>? errorMessage,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return WhatsAppQueueCompanion(
      id: id ?? this.id,
      messageType: messageType ?? this.messageType,
      invoiceId: invoiceId ?? this.invoiceId,
      dailyClosingId: dailyClosingId ?? this.dailyClosingId,
      recipientPhone: recipientPhone ?? this.recipientPhone,
      messagePayload: messagePayload ?? this.messagePayload,
      status: status ?? this.status,
      attemptCount: attemptCount ?? this.attemptCount,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      sentAt: sentAt ?? this.sentAt,
      errorMessage: errorMessage ?? this.errorMessage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (messageType.present) {
      map['message_type'] = Variable<String>(messageType.value);
    }
    if (invoiceId.present) {
      map['invoice_id'] = Variable<int>(invoiceId.value);
    }
    if (dailyClosingId.present) {
      map['daily_closing_id'] = Variable<int>(dailyClosingId.value);
    }
    if (recipientPhone.present) {
      map['recipient_phone'] = Variable<String>(recipientPhone.value);
    }
    if (messagePayload.present) {
      map['message_payload'] = Variable<String>(messagePayload.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (attemptCount.present) {
      map['attempt_count'] = Variable<int>(attemptCount.value);
    }
    if (lastAttemptAt.present) {
      map['last_attempt_at'] = Variable<DateTime>(lastAttemptAt.value);
    }
    if (sentAt.present) {
      map['sent_at'] = Variable<DateTime>(sentAt.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WhatsAppQueueCompanion(')
          ..write('id: $id, ')
          ..write('messageType: $messageType, ')
          ..write('invoiceId: $invoiceId, ')
          ..write('dailyClosingId: $dailyClosingId, ')
          ..write('recipientPhone: $recipientPhone, ')
          ..write('messagePayload: $messagePayload, ')
          ..write('status: $status, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('lastAttemptAt: $lastAttemptAt, ')
          ..write('sentAt: $sentAt, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $PlayStationDevicesTable extends PlayStationDevices
    with TableInfo<$PlayStationDevicesTable, PlayStationDevice> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlayStationDevicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _hourlyRateMeta =
      const VerificationMeta('hourlyRate');
  @override
  late final GeneratedColumn<double> hourlyRate = GeneratedColumn<double>(
      'hourly_rate', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(50.0));
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, hourlyRate, isActive, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'play_station_devices';
  @override
  VerificationContext validateIntegrity(Insertable<PlayStationDevice> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('hourly_rate')) {
      context.handle(
          _hourlyRateMeta,
          hourlyRate.isAcceptableOrUnknown(
              data['hourly_rate']!, _hourlyRateMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlayStationDevice map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlayStationDevice(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      hourlyRate: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}hourly_rate'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $PlayStationDevicesTable createAlias(String alias) {
    return $PlayStationDevicesTable(attachedDatabase, alias);
  }
}

class PlayStationDevice extends DataClass
    implements Insertable<PlayStationDevice> {
  final int id;
  final String name;
  final double hourlyRate;
  final bool isActive;
  final DateTime createdAt;
  const PlayStationDevice(
      {required this.id,
      required this.name,
      required this.hourlyRate,
      required this.isActive,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['hourly_rate'] = Variable<double>(hourlyRate);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PlayStationDevicesCompanion toCompanion(bool nullToAbsent) {
    return PlayStationDevicesCompanion(
      id: Value(id),
      name: Value(name),
      hourlyRate: Value(hourlyRate),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
    );
  }

  factory PlayStationDevice.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlayStationDevice(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      hourlyRate: serializer.fromJson<double>(json['hourlyRate']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'hourlyRate': serializer.toJson<double>(hourlyRate),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PlayStationDevice copyWith(
          {int? id,
          String? name,
          double? hourlyRate,
          bool? isActive,
          DateTime? createdAt}) =>
      PlayStationDevice(
        id: id ?? this.id,
        name: name ?? this.name,
        hourlyRate: hourlyRate ?? this.hourlyRate,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
      );
  PlayStationDevice copyWithCompanion(PlayStationDevicesCompanion data) {
    return PlayStationDevice(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      hourlyRate:
          data.hourlyRate.present ? data.hourlyRate.value : this.hourlyRate,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlayStationDevice(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('hourlyRate: $hourlyRate, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, hourlyRate, isActive, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlayStationDevice &&
          other.id == this.id &&
          other.name == this.name &&
          other.hourlyRate == this.hourlyRate &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt);
}

class PlayStationDevicesCompanion extends UpdateCompanion<PlayStationDevice> {
  final Value<int> id;
  final Value<String> name;
  final Value<double> hourlyRate;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  const PlayStationDevicesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.hourlyRate = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  PlayStationDevicesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.hourlyRate = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<PlayStationDevice> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<double>? hourlyRate,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (hourlyRate != null) 'hourly_rate': hourlyRate,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  PlayStationDevicesCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<double>? hourlyRate,
      Value<bool>? isActive,
      Value<DateTime>? createdAt}) {
    return PlayStationDevicesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (hourlyRate.present) {
      map['hourly_rate'] = Variable<double>(hourlyRate.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlayStationDevicesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('hourlyRate: $hourlyRate, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $PlayStationSessionsTable extends PlayStationSessions
    with TableInfo<$PlayStationSessionsTable, PlayStationSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlayStationSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _tableIdMeta =
      const VerificationMeta('tableId');
  @override
  late final GeneratedColumn<int> tableId = GeneratedColumn<int>(
      'table_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES system_tables (id)'));
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<int> deviceId = GeneratedColumn<int>(
      'device_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES play_station_devices (id)'));
  static const VerificationMeta _startTimeMeta =
      const VerificationMeta('startTime');
  @override
  late final GeneratedColumn<DateTime> startTime = GeneratedColumn<DateTime>(
      'start_time', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _endTimeMeta =
      const VerificationMeta('endTime');
  @override
  late final GeneratedColumn<DateTime> endTime = GeneratedColumn<DateTime>(
      'end_time', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _elapsedSecondsMeta =
      const VerificationMeta('elapsedSeconds');
  @override
  late final GeneratedColumn<int> elapsedSeconds = GeneratedColumn<int>(
      'elapsed_seconds', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _hourlyRateMeta =
      const VerificationMeta('hourlyRate');
  @override
  late final GeneratedColumn<double> hourlyRate = GeneratedColumn<double>(
      'hourly_rate', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _calculatedAmountMeta =
      const VerificationMeta('calculatedAmount');
  @override
  late final GeneratedColumn<double> calculatedAmount = GeneratedColumn<double>(
      'calculated_amount', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('active'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        tableId,
        deviceId,
        startTime,
        endTime,
        elapsedSeconds,
        hourlyRate,
        calculatedAmount,
        status,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'play_station_sessions';
  @override
  VerificationContext validateIntegrity(Insertable<PlayStationSession> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('table_id')) {
      context.handle(_tableIdMeta,
          tableId.isAcceptableOrUnknown(data['table_id']!, _tableIdMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('start_time')) {
      context.handle(_startTimeMeta,
          startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta));
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('end_time')) {
      context.handle(_endTimeMeta,
          endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta));
    }
    if (data.containsKey('elapsed_seconds')) {
      context.handle(
          _elapsedSecondsMeta,
          elapsedSeconds.isAcceptableOrUnknown(
              data['elapsed_seconds']!, _elapsedSecondsMeta));
    }
    if (data.containsKey('hourly_rate')) {
      context.handle(
          _hourlyRateMeta,
          hourlyRate.isAcceptableOrUnknown(
              data['hourly_rate']!, _hourlyRateMeta));
    } else if (isInserting) {
      context.missing(_hourlyRateMeta);
    }
    if (data.containsKey('calculated_amount')) {
      context.handle(
          _calculatedAmountMeta,
          calculatedAmount.isAcceptableOrUnknown(
              data['calculated_amount']!, _calculatedAmountMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlayStationSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlayStationSession(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      tableId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}table_id']),
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}device_id'])!,
      startTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_time'])!,
      endTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}end_time']),
      elapsedSeconds: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}elapsed_seconds']),
      hourlyRate: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}hourly_rate'])!,
      calculatedAmount: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}calculated_amount'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $PlayStationSessionsTable createAlias(String alias) {
    return $PlayStationSessionsTable(attachedDatabase, alias);
  }
}

class PlayStationSession extends DataClass
    implements Insertable<PlayStationSession> {
  final int id;
  final int? tableId;
  final int deviceId;
  final DateTime startTime;
  final DateTime? endTime;
  final int? elapsedSeconds;

  /// Frozen at session start — immune to future price changes
  final double hourlyRate;
  final double calculatedAmount;
  final String status;
  final DateTime createdAt;
  const PlayStationSession(
      {required this.id,
      this.tableId,
      required this.deviceId,
      required this.startTime,
      this.endTime,
      this.elapsedSeconds,
      required this.hourlyRate,
      required this.calculatedAmount,
      required this.status,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || tableId != null) {
      map['table_id'] = Variable<int>(tableId);
    }
    map['device_id'] = Variable<int>(deviceId);
    map['start_time'] = Variable<DateTime>(startTime);
    if (!nullToAbsent || endTime != null) {
      map['end_time'] = Variable<DateTime>(endTime);
    }
    if (!nullToAbsent || elapsedSeconds != null) {
      map['elapsed_seconds'] = Variable<int>(elapsedSeconds);
    }
    map['hourly_rate'] = Variable<double>(hourlyRate);
    map['calculated_amount'] = Variable<double>(calculatedAmount);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PlayStationSessionsCompanion toCompanion(bool nullToAbsent) {
    return PlayStationSessionsCompanion(
      id: Value(id),
      tableId: tableId == null && nullToAbsent
          ? const Value.absent()
          : Value(tableId),
      deviceId: Value(deviceId),
      startTime: Value(startTime),
      endTime: endTime == null && nullToAbsent
          ? const Value.absent()
          : Value(endTime),
      elapsedSeconds: elapsedSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(elapsedSeconds),
      hourlyRate: Value(hourlyRate),
      calculatedAmount: Value(calculatedAmount),
      status: Value(status),
      createdAt: Value(createdAt),
    );
  }

  factory PlayStationSession.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlayStationSession(
      id: serializer.fromJson<int>(json['id']),
      tableId: serializer.fromJson<int?>(json['tableId']),
      deviceId: serializer.fromJson<int>(json['deviceId']),
      startTime: serializer.fromJson<DateTime>(json['startTime']),
      endTime: serializer.fromJson<DateTime?>(json['endTime']),
      elapsedSeconds: serializer.fromJson<int?>(json['elapsedSeconds']),
      hourlyRate: serializer.fromJson<double>(json['hourlyRate']),
      calculatedAmount: serializer.fromJson<double>(json['calculatedAmount']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'tableId': serializer.toJson<int?>(tableId),
      'deviceId': serializer.toJson<int>(deviceId),
      'startTime': serializer.toJson<DateTime>(startTime),
      'endTime': serializer.toJson<DateTime?>(endTime),
      'elapsedSeconds': serializer.toJson<int?>(elapsedSeconds),
      'hourlyRate': serializer.toJson<double>(hourlyRate),
      'calculatedAmount': serializer.toJson<double>(calculatedAmount),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PlayStationSession copyWith(
          {int? id,
          Value<int?> tableId = const Value.absent(),
          int? deviceId,
          DateTime? startTime,
          Value<DateTime?> endTime = const Value.absent(),
          Value<int?> elapsedSeconds = const Value.absent(),
          double? hourlyRate,
          double? calculatedAmount,
          String? status,
          DateTime? createdAt}) =>
      PlayStationSession(
        id: id ?? this.id,
        tableId: tableId.present ? tableId.value : this.tableId,
        deviceId: deviceId ?? this.deviceId,
        startTime: startTime ?? this.startTime,
        endTime: endTime.present ? endTime.value : this.endTime,
        elapsedSeconds:
            elapsedSeconds.present ? elapsedSeconds.value : this.elapsedSeconds,
        hourlyRate: hourlyRate ?? this.hourlyRate,
        calculatedAmount: calculatedAmount ?? this.calculatedAmount,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
      );
  PlayStationSession copyWithCompanion(PlayStationSessionsCompanion data) {
    return PlayStationSession(
      id: data.id.present ? data.id.value : this.id,
      tableId: data.tableId.present ? data.tableId.value : this.tableId,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      elapsedSeconds: data.elapsedSeconds.present
          ? data.elapsedSeconds.value
          : this.elapsedSeconds,
      hourlyRate:
          data.hourlyRate.present ? data.hourlyRate.value : this.hourlyRate,
      calculatedAmount: data.calculatedAmount.present
          ? data.calculatedAmount.value
          : this.calculatedAmount,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlayStationSession(')
          ..write('id: $id, ')
          ..write('tableId: $tableId, ')
          ..write('deviceId: $deviceId, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('elapsedSeconds: $elapsedSeconds, ')
          ..write('hourlyRate: $hourlyRate, ')
          ..write('calculatedAmount: $calculatedAmount, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, tableId, deviceId, startTime, endTime,
      elapsedSeconds, hourlyRate, calculatedAmount, status, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlayStationSession &&
          other.id == this.id &&
          other.tableId == this.tableId &&
          other.deviceId == this.deviceId &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.elapsedSeconds == this.elapsedSeconds &&
          other.hourlyRate == this.hourlyRate &&
          other.calculatedAmount == this.calculatedAmount &&
          other.status == this.status &&
          other.createdAt == this.createdAt);
}

class PlayStationSessionsCompanion extends UpdateCompanion<PlayStationSession> {
  final Value<int> id;
  final Value<int?> tableId;
  final Value<int> deviceId;
  final Value<DateTime> startTime;
  final Value<DateTime?> endTime;
  final Value<int?> elapsedSeconds;
  final Value<double> hourlyRate;
  final Value<double> calculatedAmount;
  final Value<String> status;
  final Value<DateTime> createdAt;
  const PlayStationSessionsCompanion({
    this.id = const Value.absent(),
    this.tableId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.elapsedSeconds = const Value.absent(),
    this.hourlyRate = const Value.absent(),
    this.calculatedAmount = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  PlayStationSessionsCompanion.insert({
    this.id = const Value.absent(),
    this.tableId = const Value.absent(),
    required int deviceId,
    required DateTime startTime,
    this.endTime = const Value.absent(),
    this.elapsedSeconds = const Value.absent(),
    required double hourlyRate,
    this.calculatedAmount = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : deviceId = Value(deviceId),
        startTime = Value(startTime),
        hourlyRate = Value(hourlyRate);
  static Insertable<PlayStationSession> custom({
    Expression<int>? id,
    Expression<int>? tableId,
    Expression<int>? deviceId,
    Expression<DateTime>? startTime,
    Expression<DateTime>? endTime,
    Expression<int>? elapsedSeconds,
    Expression<double>? hourlyRate,
    Expression<double>? calculatedAmount,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tableId != null) 'table_id': tableId,
      if (deviceId != null) 'device_id': deviceId,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (elapsedSeconds != null) 'elapsed_seconds': elapsedSeconds,
      if (hourlyRate != null) 'hourly_rate': hourlyRate,
      if (calculatedAmount != null) 'calculated_amount': calculatedAmount,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  PlayStationSessionsCompanion copyWith(
      {Value<int>? id,
      Value<int?>? tableId,
      Value<int>? deviceId,
      Value<DateTime>? startTime,
      Value<DateTime?>? endTime,
      Value<int?>? elapsedSeconds,
      Value<double>? hourlyRate,
      Value<double>? calculatedAmount,
      Value<String>? status,
      Value<DateTime>? createdAt}) {
    return PlayStationSessionsCompanion(
      id: id ?? this.id,
      tableId: tableId ?? this.tableId,
      deviceId: deviceId ?? this.deviceId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      calculatedAmount: calculatedAmount ?? this.calculatedAmount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (tableId.present) {
      map['table_id'] = Variable<int>(tableId.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<int>(deviceId.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<DateTime>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<DateTime>(endTime.value);
    }
    if (elapsedSeconds.present) {
      map['elapsed_seconds'] = Variable<int>(elapsedSeconds.value);
    }
    if (hourlyRate.present) {
      map['hourly_rate'] = Variable<double>(hourlyRate.value);
    }
    if (calculatedAmount.present) {
      map['calculated_amount'] = Variable<double>(calculatedAmount.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlayStationSessionsCompanion(')
          ..write('id: $id, ')
          ..write('tableId: $tableId, ')
          ..write('deviceId: $deviceId, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('elapsedSeconds: $elapsedSeconds, ')
          ..write('hourlyRate: $hourlyRate, ')
          ..write('calculatedAmount: $calculatedAmount, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $InventoryMovementsTable extends InventoryMovements
    with TableInfo<$InventoryMovementsTable, InventoryMovement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InventoryMovementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _productIdMeta =
      const VerificationMeta('productId');
  @override
  late final GeneratedColumn<int> productId = GeneratedColumn<int>(
      'product_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES products (id)'));
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
      'quantity', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _movementTypeMeta =
      const VerificationMeta('movementType');
  @override
  late final GeneratedColumn<String> movementType = GeneratedColumn<String>(
      'movement_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _previousQuantityMeta =
      const VerificationMeta('previousQuantity');
  @override
  late final GeneratedColumn<int> previousQuantity = GeneratedColumn<int>(
      'previous_quantity', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _newQuantityMeta =
      const VerificationMeta('newQuantity');
  @override
  late final GeneratedColumn<int> newQuantity = GeneratedColumn<int>(
      'new_quantity', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
      'reason', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        productId,
        quantity,
        movementType,
        previousQuantity,
        newQuantity,
        reason,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'inventory_movements';
  @override
  VerificationContext validateIntegrity(Insertable<InventoryMovement> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('product_id')) {
      context.handle(_productIdMeta,
          productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta));
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('movement_type')) {
      context.handle(
          _movementTypeMeta,
          movementType.isAcceptableOrUnknown(
              data['movement_type']!, _movementTypeMeta));
    } else if (isInserting) {
      context.missing(_movementTypeMeta);
    }
    if (data.containsKey('previous_quantity')) {
      context.handle(
          _previousQuantityMeta,
          previousQuantity.isAcceptableOrUnknown(
              data['previous_quantity']!, _previousQuantityMeta));
    } else if (isInserting) {
      context.missing(_previousQuantityMeta);
    }
    if (data.containsKey('new_quantity')) {
      context.handle(
          _newQuantityMeta,
          newQuantity.isAcceptableOrUnknown(
              data['new_quantity']!, _newQuantityMeta));
    } else if (isInserting) {
      context.missing(_newQuantityMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(_reasonMeta,
          reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InventoryMovement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InventoryMovement(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      productId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}product_id'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantity'])!,
      movementType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}movement_type'])!,
      previousQuantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}previous_quantity'])!,
      newQuantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}new_quantity'])!,
      reason: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reason']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $InventoryMovementsTable createAlias(String alias) {
    return $InventoryMovementsTable(attachedDatabase, alias);
  }
}

class InventoryMovement extends DataClass
    implements Insertable<InventoryMovement> {
  final int id;
  final int productId;
  final int quantity;
  final String movementType;
  final int previousQuantity;
  final int newQuantity;
  final String? reason;
  final DateTime createdAt;
  const InventoryMovement(
      {required this.id,
      required this.productId,
      required this.quantity,
      required this.movementType,
      required this.previousQuantity,
      required this.newQuantity,
      this.reason,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['product_id'] = Variable<int>(productId);
    map['quantity'] = Variable<int>(quantity);
    map['movement_type'] = Variable<String>(movementType);
    map['previous_quantity'] = Variable<int>(previousQuantity);
    map['new_quantity'] = Variable<int>(newQuantity);
    if (!nullToAbsent || reason != null) {
      map['reason'] = Variable<String>(reason);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  InventoryMovementsCompanion toCompanion(bool nullToAbsent) {
    return InventoryMovementsCompanion(
      id: Value(id),
      productId: Value(productId),
      quantity: Value(quantity),
      movementType: Value(movementType),
      previousQuantity: Value(previousQuantity),
      newQuantity: Value(newQuantity),
      reason:
          reason == null && nullToAbsent ? const Value.absent() : Value(reason),
      createdAt: Value(createdAt),
    );
  }

  factory InventoryMovement.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InventoryMovement(
      id: serializer.fromJson<int>(json['id']),
      productId: serializer.fromJson<int>(json['productId']),
      quantity: serializer.fromJson<int>(json['quantity']),
      movementType: serializer.fromJson<String>(json['movementType']),
      previousQuantity: serializer.fromJson<int>(json['previousQuantity']),
      newQuantity: serializer.fromJson<int>(json['newQuantity']),
      reason: serializer.fromJson<String?>(json['reason']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'productId': serializer.toJson<int>(productId),
      'quantity': serializer.toJson<int>(quantity),
      'movementType': serializer.toJson<String>(movementType),
      'previousQuantity': serializer.toJson<int>(previousQuantity),
      'newQuantity': serializer.toJson<int>(newQuantity),
      'reason': serializer.toJson<String?>(reason),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  InventoryMovement copyWith(
          {int? id,
          int? productId,
          int? quantity,
          String? movementType,
          int? previousQuantity,
          int? newQuantity,
          Value<String?> reason = const Value.absent(),
          DateTime? createdAt}) =>
      InventoryMovement(
        id: id ?? this.id,
        productId: productId ?? this.productId,
        quantity: quantity ?? this.quantity,
        movementType: movementType ?? this.movementType,
        previousQuantity: previousQuantity ?? this.previousQuantity,
        newQuantity: newQuantity ?? this.newQuantity,
        reason: reason.present ? reason.value : this.reason,
        createdAt: createdAt ?? this.createdAt,
      );
  InventoryMovement copyWithCompanion(InventoryMovementsCompanion data) {
    return InventoryMovement(
      id: data.id.present ? data.id.value : this.id,
      productId: data.productId.present ? data.productId.value : this.productId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      movementType: data.movementType.present
          ? data.movementType.value
          : this.movementType,
      previousQuantity: data.previousQuantity.present
          ? data.previousQuantity.value
          : this.previousQuantity,
      newQuantity:
          data.newQuantity.present ? data.newQuantity.value : this.newQuantity,
      reason: data.reason.present ? data.reason.value : this.reason,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InventoryMovement(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('quantity: $quantity, ')
          ..write('movementType: $movementType, ')
          ..write('previousQuantity: $previousQuantity, ')
          ..write('newQuantity: $newQuantity, ')
          ..write('reason: $reason, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, productId, quantity, movementType,
      previousQuantity, newQuantity, reason, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InventoryMovement &&
          other.id == this.id &&
          other.productId == this.productId &&
          other.quantity == this.quantity &&
          other.movementType == this.movementType &&
          other.previousQuantity == this.previousQuantity &&
          other.newQuantity == this.newQuantity &&
          other.reason == this.reason &&
          other.createdAt == this.createdAt);
}

class InventoryMovementsCompanion extends UpdateCompanion<InventoryMovement> {
  final Value<int> id;
  final Value<int> productId;
  final Value<int> quantity;
  final Value<String> movementType;
  final Value<int> previousQuantity;
  final Value<int> newQuantity;
  final Value<String?> reason;
  final Value<DateTime> createdAt;
  const InventoryMovementsCompanion({
    this.id = const Value.absent(),
    this.productId = const Value.absent(),
    this.quantity = const Value.absent(),
    this.movementType = const Value.absent(),
    this.previousQuantity = const Value.absent(),
    this.newQuantity = const Value.absent(),
    this.reason = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  InventoryMovementsCompanion.insert({
    this.id = const Value.absent(),
    required int productId,
    required int quantity,
    required String movementType,
    required int previousQuantity,
    required int newQuantity,
    this.reason = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : productId = Value(productId),
        quantity = Value(quantity),
        movementType = Value(movementType),
        previousQuantity = Value(previousQuantity),
        newQuantity = Value(newQuantity);
  static Insertable<InventoryMovement> custom({
    Expression<int>? id,
    Expression<int>? productId,
    Expression<int>? quantity,
    Expression<String>? movementType,
    Expression<int>? previousQuantity,
    Expression<int>? newQuantity,
    Expression<String>? reason,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (productId != null) 'product_id': productId,
      if (quantity != null) 'quantity': quantity,
      if (movementType != null) 'movement_type': movementType,
      if (previousQuantity != null) 'previous_quantity': previousQuantity,
      if (newQuantity != null) 'new_quantity': newQuantity,
      if (reason != null) 'reason': reason,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  InventoryMovementsCompanion copyWith(
      {Value<int>? id,
      Value<int>? productId,
      Value<int>? quantity,
      Value<String>? movementType,
      Value<int>? previousQuantity,
      Value<int>? newQuantity,
      Value<String?>? reason,
      Value<DateTime>? createdAt}) {
    return InventoryMovementsCompanion(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      movementType: movementType ?? this.movementType,
      previousQuantity: previousQuantity ?? this.previousQuantity,
      newQuantity: newQuantity ?? this.newQuantity,
      reason: reason ?? this.reason,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<int>(productId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (movementType.present) {
      map['movement_type'] = Variable<String>(movementType.value);
    }
    if (previousQuantity.present) {
      map['previous_quantity'] = Variable<int>(previousQuantity.value);
    }
    if (newQuantity.present) {
      map['new_quantity'] = Variable<int>(newQuantity.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InventoryMovementsCompanion(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('quantity: $quantity, ')
          ..write('movementType: $movementType, ')
          ..write('previousQuantity: $previousQuantity, ')
          ..write('newQuantity: $newQuantity, ')
          ..write('reason: $reason, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $InvoiceItemsTable extends InvoiceItems
    with TableInfo<$InvoiceItemsTable, InvoiceItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InvoiceItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _invoiceIdMeta =
      const VerificationMeta('invoiceId');
  @override
  late final GeneratedColumn<int> invoiceId = GeneratedColumn<int>(
      'invoice_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES invoices (id)'));
  static const VerificationMeta _productIdMeta =
      const VerificationMeta('productId');
  @override
  late final GeneratedColumn<int> productId = GeneratedColumn<int>(
      'product_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _productNameMeta =
      const VerificationMeta('productName');
  @override
  late final GeneratedColumn<String> productName = GeneratedColumn<String>(
      'product_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
      'quantity', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _unitPriceMeta =
      const VerificationMeta('unitPrice');
  @override
  late final GeneratedColumn<double> unitPrice = GeneratedColumn<double>(
      'unit_price', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _totalPriceMeta =
      const VerificationMeta('totalPrice');
  @override
  late final GeneratedColumn<double> totalPrice = GeneratedColumn<double>(
      'total_price', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, invoiceId, productId, productName, quantity, unitPrice, totalPrice];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'invoice_items';
  @override
  VerificationContext validateIntegrity(Insertable<InvoiceItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('invoice_id')) {
      context.handle(_invoiceIdMeta,
          invoiceId.isAcceptableOrUnknown(data['invoice_id']!, _invoiceIdMeta));
    } else if (isInserting) {
      context.missing(_invoiceIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(_productIdMeta,
          productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta));
    }
    if (data.containsKey('product_name')) {
      context.handle(
          _productNameMeta,
          productName.isAcceptableOrUnknown(
              data['product_name']!, _productNameMeta));
    } else if (isInserting) {
      context.missing(_productNameMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    }
    if (data.containsKey('unit_price')) {
      context.handle(_unitPriceMeta,
          unitPrice.isAcceptableOrUnknown(data['unit_price']!, _unitPriceMeta));
    } else if (isInserting) {
      context.missing(_unitPriceMeta);
    }
    if (data.containsKey('total_price')) {
      context.handle(
          _totalPriceMeta,
          totalPrice.isAcceptableOrUnknown(
              data['total_price']!, _totalPriceMeta));
    } else if (isInserting) {
      context.missing(_totalPriceMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InvoiceItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InvoiceItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      invoiceId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}invoice_id'])!,
      productId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}product_id']),
      productName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}product_name'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantity'])!,
      unitPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}unit_price'])!,
      totalPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total_price'])!,
    );
  }

  @override
  $InvoiceItemsTable createAlias(String alias) {
    return $InvoiceItemsTable(attachedDatabase, alias);
  }
}

class InvoiceItem extends DataClass implements Insertable<InvoiceItem> {
  final int id;
  final int invoiceId;
  final int? productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  const InvoiceItem(
      {required this.id,
      required this.invoiceId,
      this.productId,
      required this.productName,
      required this.quantity,
      required this.unitPrice,
      required this.totalPrice});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['invoice_id'] = Variable<int>(invoiceId);
    if (!nullToAbsent || productId != null) {
      map['product_id'] = Variable<int>(productId);
    }
    map['product_name'] = Variable<String>(productName);
    map['quantity'] = Variable<int>(quantity);
    map['unit_price'] = Variable<double>(unitPrice);
    map['total_price'] = Variable<double>(totalPrice);
    return map;
  }

  InvoiceItemsCompanion toCompanion(bool nullToAbsent) {
    return InvoiceItemsCompanion(
      id: Value(id),
      invoiceId: Value(invoiceId),
      productId: productId == null && nullToAbsent
          ? const Value.absent()
          : Value(productId),
      productName: Value(productName),
      quantity: Value(quantity),
      unitPrice: Value(unitPrice),
      totalPrice: Value(totalPrice),
    );
  }

  factory InvoiceItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InvoiceItem(
      id: serializer.fromJson<int>(json['id']),
      invoiceId: serializer.fromJson<int>(json['invoiceId']),
      productId: serializer.fromJson<int?>(json['productId']),
      productName: serializer.fromJson<String>(json['productName']),
      quantity: serializer.fromJson<int>(json['quantity']),
      unitPrice: serializer.fromJson<double>(json['unitPrice']),
      totalPrice: serializer.fromJson<double>(json['totalPrice']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'invoiceId': serializer.toJson<int>(invoiceId),
      'productId': serializer.toJson<int?>(productId),
      'productName': serializer.toJson<String>(productName),
      'quantity': serializer.toJson<int>(quantity),
      'unitPrice': serializer.toJson<double>(unitPrice),
      'totalPrice': serializer.toJson<double>(totalPrice),
    };
  }

  InvoiceItem copyWith(
          {int? id,
          int? invoiceId,
          Value<int?> productId = const Value.absent(),
          String? productName,
          int? quantity,
          double? unitPrice,
          double? totalPrice}) =>
      InvoiceItem(
        id: id ?? this.id,
        invoiceId: invoiceId ?? this.invoiceId,
        productId: productId.present ? productId.value : this.productId,
        productName: productName ?? this.productName,
        quantity: quantity ?? this.quantity,
        unitPrice: unitPrice ?? this.unitPrice,
        totalPrice: totalPrice ?? this.totalPrice,
      );
  InvoiceItem copyWithCompanion(InvoiceItemsCompanion data) {
    return InvoiceItem(
      id: data.id.present ? data.id.value : this.id,
      invoiceId: data.invoiceId.present ? data.invoiceId.value : this.invoiceId,
      productId: data.productId.present ? data.productId.value : this.productId,
      productName:
          data.productName.present ? data.productName.value : this.productName,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unitPrice: data.unitPrice.present ? data.unitPrice.value : this.unitPrice,
      totalPrice:
          data.totalPrice.present ? data.totalPrice.value : this.totalPrice,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InvoiceItem(')
          ..write('id: $id, ')
          ..write('invoiceId: $invoiceId, ')
          ..write('productId: $productId, ')
          ..write('productName: $productName, ')
          ..write('quantity: $quantity, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('totalPrice: $totalPrice')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, invoiceId, productId, productName, quantity, unitPrice, totalPrice);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InvoiceItem &&
          other.id == this.id &&
          other.invoiceId == this.invoiceId &&
          other.productId == this.productId &&
          other.productName == this.productName &&
          other.quantity == this.quantity &&
          other.unitPrice == this.unitPrice &&
          other.totalPrice == this.totalPrice);
}

class InvoiceItemsCompanion extends UpdateCompanion<InvoiceItem> {
  final Value<int> id;
  final Value<int> invoiceId;
  final Value<int?> productId;
  final Value<String> productName;
  final Value<int> quantity;
  final Value<double> unitPrice;
  final Value<double> totalPrice;
  const InvoiceItemsCompanion({
    this.id = const Value.absent(),
    this.invoiceId = const Value.absent(),
    this.productId = const Value.absent(),
    this.productName = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unitPrice = const Value.absent(),
    this.totalPrice = const Value.absent(),
  });
  InvoiceItemsCompanion.insert({
    this.id = const Value.absent(),
    required int invoiceId,
    this.productId = const Value.absent(),
    required String productName,
    this.quantity = const Value.absent(),
    required double unitPrice,
    required double totalPrice,
  })  : invoiceId = Value(invoiceId),
        productName = Value(productName),
        unitPrice = Value(unitPrice),
        totalPrice = Value(totalPrice);
  static Insertable<InvoiceItem> custom({
    Expression<int>? id,
    Expression<int>? invoiceId,
    Expression<int>? productId,
    Expression<String>? productName,
    Expression<int>? quantity,
    Expression<double>? unitPrice,
    Expression<double>? totalPrice,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (invoiceId != null) 'invoice_id': invoiceId,
      if (productId != null) 'product_id': productId,
      if (productName != null) 'product_name': productName,
      if (quantity != null) 'quantity': quantity,
      if (unitPrice != null) 'unit_price': unitPrice,
      if (totalPrice != null) 'total_price': totalPrice,
    });
  }

  InvoiceItemsCompanion copyWith(
      {Value<int>? id,
      Value<int>? invoiceId,
      Value<int?>? productId,
      Value<String>? productName,
      Value<int>? quantity,
      Value<double>? unitPrice,
      Value<double>? totalPrice}) {
    return InvoiceItemsCompanion(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (invoiceId.present) {
      map['invoice_id'] = Variable<int>(invoiceId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<int>(productId.value);
    }
    if (productName.present) {
      map['product_name'] = Variable<String>(productName.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (unitPrice.present) {
      map['unit_price'] = Variable<double>(unitPrice.value);
    }
    if (totalPrice.present) {
      map['total_price'] = Variable<double>(totalPrice.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InvoiceItemsCompanion(')
          ..write('id: $id, ')
          ..write('invoiceId: $invoiceId, ')
          ..write('productId: $productId, ')
          ..write('productName: $productName, ')
          ..write('quantity: $quantity, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('totalPrice: $totalPrice')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SystemTablesTable systemTables = $SystemTablesTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $ProductsTable products = $ProductsTable(this);
  late final $OrdersTable orders = $OrdersTable(this);
  late final $OrderItemsTable orderItems = $OrderItemsTable(this);
  late final $InvoicesTable invoices = $InvoicesTable(this);
  late final $DailyClosingsTable dailyClosings = $DailyClosingsTable(this);
  late final $WhatsAppQueueTable whatsAppQueue = $WhatsAppQueueTable(this);
  late final $PlayStationDevicesTable playStationDevices =
      $PlayStationDevicesTable(this);
  late final $PlayStationSessionsTable playStationSessions =
      $PlayStationSessionsTable(this);
  late final $InventoryMovementsTable inventoryMovements =
      $InventoryMovementsTable(this);
  late final $InvoiceItemsTable invoiceItems = $InvoiceItemsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        systemTables,
        categories,
        products,
        orders,
        orderItems,
        invoices,
        dailyClosings,
        whatsAppQueue,
        playStationDevices,
        playStationSessions,
        inventoryMovements,
        invoiceItems
      ];
}

typedef $$SystemTablesTableCreateCompanionBuilder = SystemTablesCompanion
    Function({
  Value<int> id,
  required int tableNumber,
  Value<String> status,
});
typedef $$SystemTablesTableUpdateCompanionBuilder = SystemTablesCompanion
    Function({
  Value<int> id,
  Value<int> tableNumber,
  Value<String> status,
});

final class $$SystemTablesTableReferences
    extends BaseReferences<_$AppDatabase, $SystemTablesTable, SystemTable> {
  $$SystemTablesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$OrdersTable, List<Order>> _ordersRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.orders,
          aliasName:
              $_aliasNameGenerator(db.systemTables.id, db.orders.tableId));

  $$OrdersTableProcessedTableManager get ordersRefs {
    final manager = $$OrdersTableTableManager($_db, $_db.orders)
        .filter((f) => f.tableId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_ordersRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$PlayStationSessionsTable,
      List<PlayStationSession>> _playStationSessionsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.playStationSessions,
          aliasName: $_aliasNameGenerator(
              db.systemTables.id, db.playStationSessions.tableId));

  $$PlayStationSessionsTableProcessedTableManager get playStationSessionsRefs {
    final manager =
        $$PlayStationSessionsTableTableManager($_db, $_db.playStationSessions)
            .filter((f) => f.tableId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_playStationSessionsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$SystemTablesTableFilterComposer
    extends Composer<_$AppDatabase, $SystemTablesTable> {
  $$SystemTablesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get tableNumber => $composableBuilder(
      column: $table.tableNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  Expression<bool> ordersRefs(
      Expression<bool> Function($$OrdersTableFilterComposer f) f) {
    final $$OrdersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.orders,
        getReferencedColumn: (t) => t.tableId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OrdersTableFilterComposer(
              $db: $db,
              $table: $db.orders,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> playStationSessionsRefs(
      Expression<bool> Function($$PlayStationSessionsTableFilterComposer f) f) {
    final $$PlayStationSessionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.playStationSessions,
        getReferencedColumn: (t) => t.tableId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlayStationSessionsTableFilterComposer(
              $db: $db,
              $table: $db.playStationSessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SystemTablesTableOrderingComposer
    extends Composer<_$AppDatabase, $SystemTablesTable> {
  $$SystemTablesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get tableNumber => $composableBuilder(
      column: $table.tableNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));
}

class $$SystemTablesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SystemTablesTable> {
  $$SystemTablesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get tableNumber => $composableBuilder(
      column: $table.tableNumber, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  Expression<T> ordersRefs<T extends Object>(
      Expression<T> Function($$OrdersTableAnnotationComposer a) f) {
    final $$OrdersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.orders,
        getReferencedColumn: (t) => t.tableId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OrdersTableAnnotationComposer(
              $db: $db,
              $table: $db.orders,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> playStationSessionsRefs<T extends Object>(
      Expression<T> Function($$PlayStationSessionsTableAnnotationComposer a)
          f) {
    final $$PlayStationSessionsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.playStationSessions,
            getReferencedColumn: (t) => t.tableId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$PlayStationSessionsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.playStationSessions,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$SystemTablesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SystemTablesTable,
    SystemTable,
    $$SystemTablesTableFilterComposer,
    $$SystemTablesTableOrderingComposer,
    $$SystemTablesTableAnnotationComposer,
    $$SystemTablesTableCreateCompanionBuilder,
    $$SystemTablesTableUpdateCompanionBuilder,
    (SystemTable, $$SystemTablesTableReferences),
    SystemTable,
    PrefetchHooks Function({bool ordersRefs, bool playStationSessionsRefs})> {
  $$SystemTablesTableTableManager(_$AppDatabase db, $SystemTablesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SystemTablesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SystemTablesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SystemTablesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> tableNumber = const Value.absent(),
            Value<String> status = const Value.absent(),
          }) =>
              SystemTablesCompanion(
            id: id,
            tableNumber: tableNumber,
            status: status,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int tableNumber,
            Value<String> status = const Value.absent(),
          }) =>
              SystemTablesCompanion.insert(
            id: id,
            tableNumber: tableNumber,
            status: status,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$SystemTablesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {ordersRefs = false, playStationSessionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (ordersRefs) db.orders,
                if (playStationSessionsRefs) db.playStationSessions
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (ordersRefs)
                    await $_getPrefetchedData<SystemTable, $SystemTablesTable,
                            Order>(
                        currentTable: table,
                        referencedTable:
                            $$SystemTablesTableReferences._ordersRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SystemTablesTableReferences(db, table, p0)
                                .ordersRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.tableId == item.id),
                        typedResults: items),
                  if (playStationSessionsRefs)
                    await $_getPrefetchedData<SystemTable, $SystemTablesTable,
                            PlayStationSession>(
                        currentTable: table,
                        referencedTable: $$SystemTablesTableReferences
                            ._playStationSessionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SystemTablesTableReferences(db, table, p0)
                                .playStationSessionsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.tableId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$SystemTablesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SystemTablesTable,
    SystemTable,
    $$SystemTablesTableFilterComposer,
    $$SystemTablesTableOrderingComposer,
    $$SystemTablesTableAnnotationComposer,
    $$SystemTablesTableCreateCompanionBuilder,
    $$SystemTablesTableUpdateCompanionBuilder,
    (SystemTable, $$SystemTablesTableReferences),
    SystemTable,
    PrefetchHooks Function({bool ordersRefs, bool playStationSessionsRefs})>;
typedef $$CategoriesTableCreateCompanionBuilder = CategoriesCompanion Function({
  Value<int> id,
  required String name,
});
typedef $$CategoriesTableUpdateCompanionBuilder = CategoriesCompanion Function({
  Value<int> id,
  Value<String> name,
});

final class $$CategoriesTableReferences
    extends BaseReferences<_$AppDatabase, $CategoriesTable, Category> {
  $$CategoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ProductsTable, List<Product>> _productsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.products,
          aliasName:
              $_aliasNameGenerator(db.categories.id, db.products.categoryId));

  $$ProductsTableProcessedTableManager get productsRefs {
    final manager = $$ProductsTableTableManager($_db, $_db.products)
        .filter((f) => f.categoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_productsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  Expression<bool> productsRefs(
      Expression<bool> Function($$ProductsTableFilterComposer f) f) {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.products,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductsTableFilterComposer(
              $db: $db,
              $table: $db.products,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  Expression<T> productsRefs<T extends Object>(
      Expression<T> Function($$ProductsTableAnnotationComposer a) f) {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.products,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductsTableAnnotationComposer(
              $db: $db,
              $table: $db.products,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CategoriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CategoriesTable,
    Category,
    $$CategoriesTableFilterComposer,
    $$CategoriesTableOrderingComposer,
    $$CategoriesTableAnnotationComposer,
    $$CategoriesTableCreateCompanionBuilder,
    $$CategoriesTableUpdateCompanionBuilder,
    (Category, $$CategoriesTableReferences),
    Category,
    PrefetchHooks Function({bool productsRefs})> {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
          }) =>
              CategoriesCompanion(
            id: id,
            name: name,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
          }) =>
              CategoriesCompanion.insert(
            id: id,
            name: name,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$CategoriesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({productsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (productsRefs) db.products],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (productsRefs)
                    await $_getPrefetchedData<Category, $CategoriesTable,
                            Product>(
                        currentTable: table,
                        referencedTable:
                            $$CategoriesTableReferences._productsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CategoriesTableReferences(db, table, p0)
                                .productsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.categoryId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$CategoriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CategoriesTable,
    Category,
    $$CategoriesTableFilterComposer,
    $$CategoriesTableOrderingComposer,
    $$CategoriesTableAnnotationComposer,
    $$CategoriesTableCreateCompanionBuilder,
    $$CategoriesTableUpdateCompanionBuilder,
    (Category, $$CategoriesTableReferences),
    Category,
    PrefetchHooks Function({bool productsRefs})>;
typedef $$ProductsTableCreateCompanionBuilder = ProductsCompanion Function({
  Value<int> id,
  required String name,
  required int categoryId,
  required double price,
  Value<bool> hasAddons,
  Value<int> stockQuantity,
  Value<int> minimumStock,
  Value<bool> trackInventory,
});
typedef $$ProductsTableUpdateCompanionBuilder = ProductsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<int> categoryId,
  Value<double> price,
  Value<bool> hasAddons,
  Value<int> stockQuantity,
  Value<int> minimumStock,
  Value<bool> trackInventory,
});

final class $$ProductsTableReferences
    extends BaseReferences<_$AppDatabase, $ProductsTable, Product> {
  $$ProductsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias(
          $_aliasNameGenerator(db.products.categoryId, db.categories.id));

  $$CategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<int>('category_id')!;

    final manager = $$CategoriesTableTableManager($_db, $_db.categories)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$OrderItemsTable, List<OrderItem>>
      _orderItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.orderItems,
          aliasName:
              $_aliasNameGenerator(db.products.id, db.orderItems.productId));

  $$OrderItemsTableProcessedTableManager get orderItemsRefs {
    final manager = $$OrderItemsTableTableManager($_db, $_db.orderItems)
        .filter((f) => f.productId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_orderItemsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$InventoryMovementsTable, List<InventoryMovement>>
      _inventoryMovementsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.inventoryMovements,
              aliasName: $_aliasNameGenerator(
                  db.products.id, db.inventoryMovements.productId));

  $$InventoryMovementsTableProcessedTableManager get inventoryMovementsRefs {
    final manager =
        $$InventoryMovementsTableTableManager($_db, $_db.inventoryMovements)
            .filter((f) => f.productId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_inventoryMovementsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ProductsTableFilterComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get price => $composableBuilder(
      column: $table.price, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get hasAddons => $composableBuilder(
      column: $table.hasAddons, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get stockQuantity => $composableBuilder(
      column: $table.stockQuantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get minimumStock => $composableBuilder(
      column: $table.minimumStock, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get trackInventory => $composableBuilder(
      column: $table.trackInventory,
      builder: (column) => ColumnFilters(column));

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableFilterComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> orderItemsRefs(
      Expression<bool> Function($$OrderItemsTableFilterComposer f) f) {
    final $$OrderItemsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.orderItems,
        getReferencedColumn: (t) => t.productId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OrderItemsTableFilterComposer(
              $db: $db,
              $table: $db.orderItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> inventoryMovementsRefs(
      Expression<bool> Function($$InventoryMovementsTableFilterComposer f) f) {
    final $$InventoryMovementsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.inventoryMovements,
        getReferencedColumn: (t) => t.productId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InventoryMovementsTableFilterComposer(
              $db: $db,
              $table: $db.inventoryMovements,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ProductsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get price => $composableBuilder(
      column: $table.price, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get hasAddons => $composableBuilder(
      column: $table.hasAddons, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get stockQuantity => $composableBuilder(
      column: $table.stockQuantity,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get minimumStock => $composableBuilder(
      column: $table.minimumStock,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get trackInventory => $composableBuilder(
      column: $table.trackInventory,
      builder: (column) => ColumnOrderings(column));

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableOrderingComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ProductsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<bool> get hasAddons =>
      $composableBuilder(column: $table.hasAddons, builder: (column) => column);

  GeneratedColumn<int> get stockQuantity => $composableBuilder(
      column: $table.stockQuantity, builder: (column) => column);

  GeneratedColumn<int> get minimumStock => $composableBuilder(
      column: $table.minimumStock, builder: (column) => column);

  GeneratedColumn<bool> get trackInventory => $composableBuilder(
      column: $table.trackInventory, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableAnnotationComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> orderItemsRefs<T extends Object>(
      Expression<T> Function($$OrderItemsTableAnnotationComposer a) f) {
    final $$OrderItemsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.orderItems,
        getReferencedColumn: (t) => t.productId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OrderItemsTableAnnotationComposer(
              $db: $db,
              $table: $db.orderItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> inventoryMovementsRefs<T extends Object>(
      Expression<T> Function($$InventoryMovementsTableAnnotationComposer a) f) {
    final $$InventoryMovementsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.inventoryMovements,
            getReferencedColumn: (t) => t.productId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$InventoryMovementsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.inventoryMovements,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$ProductsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProductsTable,
    Product,
    $$ProductsTableFilterComposer,
    $$ProductsTableOrderingComposer,
    $$ProductsTableAnnotationComposer,
    $$ProductsTableCreateCompanionBuilder,
    $$ProductsTableUpdateCompanionBuilder,
    (Product, $$ProductsTableReferences),
    Product,
    PrefetchHooks Function(
        {bool categoryId, bool orderItemsRefs, bool inventoryMovementsRefs})> {
  $$ProductsTableTableManager(_$AppDatabase db, $ProductsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> categoryId = const Value.absent(),
            Value<double> price = const Value.absent(),
            Value<bool> hasAddons = const Value.absent(),
            Value<int> stockQuantity = const Value.absent(),
            Value<int> minimumStock = const Value.absent(),
            Value<bool> trackInventory = const Value.absent(),
          }) =>
              ProductsCompanion(
            id: id,
            name: name,
            categoryId: categoryId,
            price: price,
            hasAddons: hasAddons,
            stockQuantity: stockQuantity,
            minimumStock: minimumStock,
            trackInventory: trackInventory,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required int categoryId,
            required double price,
            Value<bool> hasAddons = const Value.absent(),
            Value<int> stockQuantity = const Value.absent(),
            Value<int> minimumStock = const Value.absent(),
            Value<bool> trackInventory = const Value.absent(),
          }) =>
              ProductsCompanion.insert(
            id: id,
            name: name,
            categoryId: categoryId,
            price: price,
            hasAddons: hasAddons,
            stockQuantity: stockQuantity,
            minimumStock: minimumStock,
            trackInventory: trackInventory,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$ProductsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {categoryId = false,
              orderItemsRefs = false,
              inventoryMovementsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (orderItemsRefs) db.orderItems,
                if (inventoryMovementsRefs) db.inventoryMovements
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (categoryId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.categoryId,
                    referencedTable:
                        $$ProductsTableReferences._categoryIdTable(db),
                    referencedColumn:
                        $$ProductsTableReferences._categoryIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (orderItemsRefs)
                    await $_getPrefetchedData<Product, $ProductsTable,
                            OrderItem>(
                        currentTable: table,
                        referencedTable:
                            $$ProductsTableReferences._orderItemsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProductsTableReferences(db, table, p0)
                                .orderItemsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.productId == item.id),
                        typedResults: items),
                  if (inventoryMovementsRefs)
                    await $_getPrefetchedData<Product, $ProductsTable,
                            InventoryMovement>(
                        currentTable: table,
                        referencedTable: $$ProductsTableReferences
                            ._inventoryMovementsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProductsTableReferences(db, table, p0)
                                .inventoryMovementsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.productId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ProductsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ProductsTable,
    Product,
    $$ProductsTableFilterComposer,
    $$ProductsTableOrderingComposer,
    $$ProductsTableAnnotationComposer,
    $$ProductsTableCreateCompanionBuilder,
    $$ProductsTableUpdateCompanionBuilder,
    (Product, $$ProductsTableReferences),
    Product,
    PrefetchHooks Function(
        {bool categoryId, bool orderItemsRefs, bool inventoryMovementsRefs})>;
typedef $$OrdersTableCreateCompanionBuilder = OrdersCompanion Function({
  Value<int> id,
  Value<int?> tableId,
  Value<double> subtotal,
  Value<String> status,
  Value<String> orderType,
  Value<DateTime> createdAt,
});
typedef $$OrdersTableUpdateCompanionBuilder = OrdersCompanion Function({
  Value<int> id,
  Value<int?> tableId,
  Value<double> subtotal,
  Value<String> status,
  Value<String> orderType,
  Value<DateTime> createdAt,
});

final class $$OrdersTableReferences
    extends BaseReferences<_$AppDatabase, $OrdersTable, Order> {
  $$OrdersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SystemTablesTable _tableIdTable(_$AppDatabase db) => db.systemTables
      .createAlias($_aliasNameGenerator(db.orders.tableId, db.systemTables.id));

  $$SystemTablesTableProcessedTableManager? get tableId {
    final $_column = $_itemColumn<int>('table_id');
    if ($_column == null) return null;
    final manager = $$SystemTablesTableTableManager($_db, $_db.systemTables)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tableIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$OrderItemsTable, List<OrderItem>>
      _orderItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.orderItems,
          aliasName: $_aliasNameGenerator(db.orders.id, db.orderItems.orderId));

  $$OrderItemsTableProcessedTableManager get orderItemsRefs {
    final manager = $$OrderItemsTableTableManager($_db, $_db.orderItems)
        .filter((f) => f.orderId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_orderItemsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$InvoicesTable, List<Invoice>> _invoicesRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.invoices,
          aliasName: $_aliasNameGenerator(db.orders.id, db.invoices.orderId));

  $$InvoicesTableProcessedTableManager get invoicesRefs {
    final manager = $$InvoicesTableTableManager($_db, $_db.invoices)
        .filter((f) => f.orderId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_invoicesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$OrdersTableFilterComposer
    extends Composer<_$AppDatabase, $OrdersTable> {
  $$OrdersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get subtotal => $composableBuilder(
      column: $table.subtotal, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get orderType => $composableBuilder(
      column: $table.orderType, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$SystemTablesTableFilterComposer get tableId {
    final $$SystemTablesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.tableId,
        referencedTable: $db.systemTables,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SystemTablesTableFilterComposer(
              $db: $db,
              $table: $db.systemTables,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> orderItemsRefs(
      Expression<bool> Function($$OrderItemsTableFilterComposer f) f) {
    final $$OrderItemsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.orderItems,
        getReferencedColumn: (t) => t.orderId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OrderItemsTableFilterComposer(
              $db: $db,
              $table: $db.orderItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> invoicesRefs(
      Expression<bool> Function($$InvoicesTableFilterComposer f) f) {
    final $$InvoicesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.invoices,
        getReferencedColumn: (t) => t.orderId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InvoicesTableFilterComposer(
              $db: $db,
              $table: $db.invoices,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$OrdersTableOrderingComposer
    extends Composer<_$AppDatabase, $OrdersTable> {
  $$OrdersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get subtotal => $composableBuilder(
      column: $table.subtotal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get orderType => $composableBuilder(
      column: $table.orderType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$SystemTablesTableOrderingComposer get tableId {
    final $$SystemTablesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.tableId,
        referencedTable: $db.systemTables,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SystemTablesTableOrderingComposer(
              $db: $db,
              $table: $db.systemTables,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$OrdersTableAnnotationComposer
    extends Composer<_$AppDatabase, $OrdersTable> {
  $$OrdersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get subtotal =>
      $composableBuilder(column: $table.subtotal, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get orderType =>
      $composableBuilder(column: $table.orderType, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$SystemTablesTableAnnotationComposer get tableId {
    final $$SystemTablesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.tableId,
        referencedTable: $db.systemTables,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SystemTablesTableAnnotationComposer(
              $db: $db,
              $table: $db.systemTables,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> orderItemsRefs<T extends Object>(
      Expression<T> Function($$OrderItemsTableAnnotationComposer a) f) {
    final $$OrderItemsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.orderItems,
        getReferencedColumn: (t) => t.orderId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OrderItemsTableAnnotationComposer(
              $db: $db,
              $table: $db.orderItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> invoicesRefs<T extends Object>(
      Expression<T> Function($$InvoicesTableAnnotationComposer a) f) {
    final $$InvoicesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.invoices,
        getReferencedColumn: (t) => t.orderId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InvoicesTableAnnotationComposer(
              $db: $db,
              $table: $db.invoices,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$OrdersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $OrdersTable,
    Order,
    $$OrdersTableFilterComposer,
    $$OrdersTableOrderingComposer,
    $$OrdersTableAnnotationComposer,
    $$OrdersTableCreateCompanionBuilder,
    $$OrdersTableUpdateCompanionBuilder,
    (Order, $$OrdersTableReferences),
    Order,
    PrefetchHooks Function(
        {bool tableId, bool orderItemsRefs, bool invoicesRefs})> {
  $$OrdersTableTableManager(_$AppDatabase db, $OrdersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OrdersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OrdersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OrdersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> tableId = const Value.absent(),
            Value<double> subtotal = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String> orderType = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              OrdersCompanion(
            id: id,
            tableId: tableId,
            subtotal: subtotal,
            status: status,
            orderType: orderType,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> tableId = const Value.absent(),
            Value<double> subtotal = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String> orderType = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              OrdersCompanion.insert(
            id: id,
            tableId: tableId,
            subtotal: subtotal,
            status: status,
            orderType: orderType,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$OrdersTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {tableId = false, orderItemsRefs = false, invoicesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (orderItemsRefs) db.orderItems,
                if (invoicesRefs) db.invoices
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (tableId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.tableId,
                    referencedTable: $$OrdersTableReferences._tableIdTable(db),
                    referencedColumn:
                        $$OrdersTableReferences._tableIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (orderItemsRefs)
                    await $_getPrefetchedData<Order, $OrdersTable, OrderItem>(
                        currentTable: table,
                        referencedTable:
                            $$OrdersTableReferences._orderItemsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$OrdersTableReferences(db, table, p0)
                                .orderItemsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.orderId == item.id),
                        typedResults: items),
                  if (invoicesRefs)
                    await $_getPrefetchedData<Order, $OrdersTable, Invoice>(
                        currentTable: table,
                        referencedTable:
                            $$OrdersTableReferences._invoicesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$OrdersTableReferences(db, table, p0).invoicesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.orderId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$OrdersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $OrdersTable,
    Order,
    $$OrdersTableFilterComposer,
    $$OrdersTableOrderingComposer,
    $$OrdersTableAnnotationComposer,
    $$OrdersTableCreateCompanionBuilder,
    $$OrdersTableUpdateCompanionBuilder,
    (Order, $$OrdersTableReferences),
    Order,
    PrefetchHooks Function(
        {bool tableId, bool orderItemsRefs, bool invoicesRefs})>;
typedef $$OrderItemsTableCreateCompanionBuilder = OrderItemsCompanion Function({
  Value<int> id,
  required int orderId,
  required int productId,
  Value<int> quantity,
  required double unitPrice,
  required double totalPrice,
});
typedef $$OrderItemsTableUpdateCompanionBuilder = OrderItemsCompanion Function({
  Value<int> id,
  Value<int> orderId,
  Value<int> productId,
  Value<int> quantity,
  Value<double> unitPrice,
  Value<double> totalPrice,
});

final class $$OrderItemsTableReferences
    extends BaseReferences<_$AppDatabase, $OrderItemsTable, OrderItem> {
  $$OrderItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $OrdersTable _orderIdTable(_$AppDatabase db) => db.orders
      .createAlias($_aliasNameGenerator(db.orderItems.orderId, db.orders.id));

  $$OrdersTableProcessedTableManager get orderId {
    final $_column = $_itemColumn<int>('order_id')!;

    final manager = $$OrdersTableTableManager($_db, $_db.orders)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_orderIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $ProductsTable _productIdTable(_$AppDatabase db) =>
      db.products.createAlias(
          $_aliasNameGenerator(db.orderItems.productId, db.products.id));

  $$ProductsTableProcessedTableManager get productId {
    final $_column = $_itemColumn<int>('product_id')!;

    final manager = $$ProductsTableTableManager($_db, $_db.products)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$OrderItemsTableFilterComposer
    extends Composer<_$AppDatabase, $OrderItemsTable> {
  $$OrderItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get unitPrice => $composableBuilder(
      column: $table.unitPrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get totalPrice => $composableBuilder(
      column: $table.totalPrice, builder: (column) => ColumnFilters(column));

  $$OrdersTableFilterComposer get orderId {
    final $$OrdersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.orderId,
        referencedTable: $db.orders,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OrdersTableFilterComposer(
              $db: $db,
              $table: $db.orders,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ProductsTableFilterComposer get productId {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productId,
        referencedTable: $db.products,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductsTableFilterComposer(
              $db: $db,
              $table: $db.products,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$OrderItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $OrderItemsTable> {
  $$OrderItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get unitPrice => $composableBuilder(
      column: $table.unitPrice, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get totalPrice => $composableBuilder(
      column: $table.totalPrice, builder: (column) => ColumnOrderings(column));

  $$OrdersTableOrderingComposer get orderId {
    final $$OrdersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.orderId,
        referencedTable: $db.orders,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OrdersTableOrderingComposer(
              $db: $db,
              $table: $db.orders,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ProductsTableOrderingComposer get productId {
    final $$ProductsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productId,
        referencedTable: $db.products,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductsTableOrderingComposer(
              $db: $db,
              $table: $db.products,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$OrderItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OrderItemsTable> {
  $$OrderItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get unitPrice =>
      $composableBuilder(column: $table.unitPrice, builder: (column) => column);

  GeneratedColumn<double> get totalPrice => $composableBuilder(
      column: $table.totalPrice, builder: (column) => column);

  $$OrdersTableAnnotationComposer get orderId {
    final $$OrdersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.orderId,
        referencedTable: $db.orders,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OrdersTableAnnotationComposer(
              $db: $db,
              $table: $db.orders,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ProductsTableAnnotationComposer get productId {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productId,
        referencedTable: $db.products,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductsTableAnnotationComposer(
              $db: $db,
              $table: $db.products,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$OrderItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $OrderItemsTable,
    OrderItem,
    $$OrderItemsTableFilterComposer,
    $$OrderItemsTableOrderingComposer,
    $$OrderItemsTableAnnotationComposer,
    $$OrderItemsTableCreateCompanionBuilder,
    $$OrderItemsTableUpdateCompanionBuilder,
    (OrderItem, $$OrderItemsTableReferences),
    OrderItem,
    PrefetchHooks Function({bool orderId, bool productId})> {
  $$OrderItemsTableTableManager(_$AppDatabase db, $OrderItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OrderItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OrderItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OrderItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> orderId = const Value.absent(),
            Value<int> productId = const Value.absent(),
            Value<int> quantity = const Value.absent(),
            Value<double> unitPrice = const Value.absent(),
            Value<double> totalPrice = const Value.absent(),
          }) =>
              OrderItemsCompanion(
            id: id,
            orderId: orderId,
            productId: productId,
            quantity: quantity,
            unitPrice: unitPrice,
            totalPrice: totalPrice,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int orderId,
            required int productId,
            Value<int> quantity = const Value.absent(),
            required double unitPrice,
            required double totalPrice,
          }) =>
              OrderItemsCompanion.insert(
            id: id,
            orderId: orderId,
            productId: productId,
            quantity: quantity,
            unitPrice: unitPrice,
            totalPrice: totalPrice,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$OrderItemsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({orderId = false, productId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (orderId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.orderId,
                    referencedTable:
                        $$OrderItemsTableReferences._orderIdTable(db),
                    referencedColumn:
                        $$OrderItemsTableReferences._orderIdTable(db).id,
                  ) as T;
                }
                if (productId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.productId,
                    referencedTable:
                        $$OrderItemsTableReferences._productIdTable(db),
                    referencedColumn:
                        $$OrderItemsTableReferences._productIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$OrderItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $OrderItemsTable,
    OrderItem,
    $$OrderItemsTableFilterComposer,
    $$OrderItemsTableOrderingComposer,
    $$OrderItemsTableAnnotationComposer,
    $$OrderItemsTableCreateCompanionBuilder,
    $$OrderItemsTableUpdateCompanionBuilder,
    (OrderItem, $$OrderItemsTableReferences),
    OrderItem,
    PrefetchHooks Function({bool orderId, bool productId})>;
typedef $$InvoicesTableCreateCompanionBuilder = InvoicesCompanion Function({
  Value<int> id,
  required int orderId,
  required String invoiceNumber,
  required double subtotal,
  required double taxAmount,
  required double serviceCharge,
  required double grandTotal,
  Value<String> paymentMethod,
  Value<double> playStationAmount,
  Value<bool> isClosedShift,
  Value<DateTime> createdAt,
});
typedef $$InvoicesTableUpdateCompanionBuilder = InvoicesCompanion Function({
  Value<int> id,
  Value<int> orderId,
  Value<String> invoiceNumber,
  Value<double> subtotal,
  Value<double> taxAmount,
  Value<double> serviceCharge,
  Value<double> grandTotal,
  Value<String> paymentMethod,
  Value<double> playStationAmount,
  Value<bool> isClosedShift,
  Value<DateTime> createdAt,
});

final class $$InvoicesTableReferences
    extends BaseReferences<_$AppDatabase, $InvoicesTable, Invoice> {
  $$InvoicesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $OrdersTable _orderIdTable(_$AppDatabase db) => db.orders
      .createAlias($_aliasNameGenerator(db.invoices.orderId, db.orders.id));

  $$OrdersTableProcessedTableManager get orderId {
    final $_column = $_itemColumn<int>('order_id')!;

    final manager = $$OrdersTableTableManager($_db, $_db.orders)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_orderIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$InvoiceItemsTable, List<InvoiceItem>>
      _invoiceItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.invoiceItems,
          aliasName:
              $_aliasNameGenerator(db.invoices.id, db.invoiceItems.invoiceId));

  $$InvoiceItemsTableProcessedTableManager get invoiceItemsRefs {
    final manager = $$InvoiceItemsTableTableManager($_db, $_db.invoiceItems)
        .filter((f) => f.invoiceId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_invoiceItemsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$InvoicesTableFilterComposer
    extends Composer<_$AppDatabase, $InvoicesTable> {
  $$InvoicesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get invoiceNumber => $composableBuilder(
      column: $table.invoiceNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get subtotal => $composableBuilder(
      column: $table.subtotal, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get taxAmount => $composableBuilder(
      column: $table.taxAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get serviceCharge => $composableBuilder(
      column: $table.serviceCharge, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get grandTotal => $composableBuilder(
      column: $table.grandTotal, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get paymentMethod => $composableBuilder(
      column: $table.paymentMethod, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get playStationAmount => $composableBuilder(
      column: $table.playStationAmount,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isClosedShift => $composableBuilder(
      column: $table.isClosedShift, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$OrdersTableFilterComposer get orderId {
    final $$OrdersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.orderId,
        referencedTable: $db.orders,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OrdersTableFilterComposer(
              $db: $db,
              $table: $db.orders,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> invoiceItemsRefs(
      Expression<bool> Function($$InvoiceItemsTableFilterComposer f) f) {
    final $$InvoiceItemsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.invoiceItems,
        getReferencedColumn: (t) => t.invoiceId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InvoiceItemsTableFilterComposer(
              $db: $db,
              $table: $db.invoiceItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$InvoicesTableOrderingComposer
    extends Composer<_$AppDatabase, $InvoicesTable> {
  $$InvoicesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get invoiceNumber => $composableBuilder(
      column: $table.invoiceNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get subtotal => $composableBuilder(
      column: $table.subtotal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get taxAmount => $composableBuilder(
      column: $table.taxAmount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get serviceCharge => $composableBuilder(
      column: $table.serviceCharge,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get grandTotal => $composableBuilder(
      column: $table.grandTotal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get paymentMethod => $composableBuilder(
      column: $table.paymentMethod,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get playStationAmount => $composableBuilder(
      column: $table.playStationAmount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isClosedShift => $composableBuilder(
      column: $table.isClosedShift,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$OrdersTableOrderingComposer get orderId {
    final $$OrdersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.orderId,
        referencedTable: $db.orders,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OrdersTableOrderingComposer(
              $db: $db,
              $table: $db.orders,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$InvoicesTableAnnotationComposer
    extends Composer<_$AppDatabase, $InvoicesTable> {
  $$InvoicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get invoiceNumber => $composableBuilder(
      column: $table.invoiceNumber, builder: (column) => column);

  GeneratedColumn<double> get subtotal =>
      $composableBuilder(column: $table.subtotal, builder: (column) => column);

  GeneratedColumn<double> get taxAmount =>
      $composableBuilder(column: $table.taxAmount, builder: (column) => column);

  GeneratedColumn<double> get serviceCharge => $composableBuilder(
      column: $table.serviceCharge, builder: (column) => column);

  GeneratedColumn<double> get grandTotal => $composableBuilder(
      column: $table.grandTotal, builder: (column) => column);

  GeneratedColumn<String> get paymentMethod => $composableBuilder(
      column: $table.paymentMethod, builder: (column) => column);

  GeneratedColumn<double> get playStationAmount => $composableBuilder(
      column: $table.playStationAmount, builder: (column) => column);

  GeneratedColumn<bool> get isClosedShift => $composableBuilder(
      column: $table.isClosedShift, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$OrdersTableAnnotationComposer get orderId {
    final $$OrdersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.orderId,
        referencedTable: $db.orders,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OrdersTableAnnotationComposer(
              $db: $db,
              $table: $db.orders,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> invoiceItemsRefs<T extends Object>(
      Expression<T> Function($$InvoiceItemsTableAnnotationComposer a) f) {
    final $$InvoiceItemsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.invoiceItems,
        getReferencedColumn: (t) => t.invoiceId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InvoiceItemsTableAnnotationComposer(
              $db: $db,
              $table: $db.invoiceItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$InvoicesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $InvoicesTable,
    Invoice,
    $$InvoicesTableFilterComposer,
    $$InvoicesTableOrderingComposer,
    $$InvoicesTableAnnotationComposer,
    $$InvoicesTableCreateCompanionBuilder,
    $$InvoicesTableUpdateCompanionBuilder,
    (Invoice, $$InvoicesTableReferences),
    Invoice,
    PrefetchHooks Function({bool orderId, bool invoiceItemsRefs})> {
  $$InvoicesTableTableManager(_$AppDatabase db, $InvoicesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InvoicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InvoicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InvoicesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> orderId = const Value.absent(),
            Value<String> invoiceNumber = const Value.absent(),
            Value<double> subtotal = const Value.absent(),
            Value<double> taxAmount = const Value.absent(),
            Value<double> serviceCharge = const Value.absent(),
            Value<double> grandTotal = const Value.absent(),
            Value<String> paymentMethod = const Value.absent(),
            Value<double> playStationAmount = const Value.absent(),
            Value<bool> isClosedShift = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              InvoicesCompanion(
            id: id,
            orderId: orderId,
            invoiceNumber: invoiceNumber,
            subtotal: subtotal,
            taxAmount: taxAmount,
            serviceCharge: serviceCharge,
            grandTotal: grandTotal,
            paymentMethod: paymentMethod,
            playStationAmount: playStationAmount,
            isClosedShift: isClosedShift,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int orderId,
            required String invoiceNumber,
            required double subtotal,
            required double taxAmount,
            required double serviceCharge,
            required double grandTotal,
            Value<String> paymentMethod = const Value.absent(),
            Value<double> playStationAmount = const Value.absent(),
            Value<bool> isClosedShift = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              InvoicesCompanion.insert(
            id: id,
            orderId: orderId,
            invoiceNumber: invoiceNumber,
            subtotal: subtotal,
            taxAmount: taxAmount,
            serviceCharge: serviceCharge,
            grandTotal: grandTotal,
            paymentMethod: paymentMethod,
            playStationAmount: playStationAmount,
            isClosedShift: isClosedShift,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$InvoicesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({orderId = false, invoiceItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (invoiceItemsRefs) db.invoiceItems],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (orderId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.orderId,
                    referencedTable:
                        $$InvoicesTableReferences._orderIdTable(db),
                    referencedColumn:
                        $$InvoicesTableReferences._orderIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (invoiceItemsRefs)
                    await $_getPrefetchedData<Invoice, $InvoicesTable,
                            InvoiceItem>(
                        currentTable: table,
                        referencedTable: $$InvoicesTableReferences
                            ._invoiceItemsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$InvoicesTableReferences(db, table, p0)
                                .invoiceItemsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.invoiceId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$InvoicesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $InvoicesTable,
    Invoice,
    $$InvoicesTableFilterComposer,
    $$InvoicesTableOrderingComposer,
    $$InvoicesTableAnnotationComposer,
    $$InvoicesTableCreateCompanionBuilder,
    $$InvoicesTableUpdateCompanionBuilder,
    (Invoice, $$InvoicesTableReferences),
    Invoice,
    PrefetchHooks Function({bool orderId, bool invoiceItemsRefs})>;
typedef $$DailyClosingsTableCreateCompanionBuilder = DailyClosingsCompanion
    Function({
  Value<int> id,
  required String closingDate,
  required String closingTime,
  Value<int> invoiceCount,
  Value<double> grossSales,
  Value<double> discounts,
  Value<double> taxTotal,
  Value<double> netSales,
  Value<double> cashTotal,
  Value<double> cardTotal,
  Value<double> otherPayments,
  Value<double> playStationTotal,
  Value<double> walletTotal,
  Value<double> instapayTotal,
  Value<int> totalItems,
  Value<String> status,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$DailyClosingsTableUpdateCompanionBuilder = DailyClosingsCompanion
    Function({
  Value<int> id,
  Value<String> closingDate,
  Value<String> closingTime,
  Value<int> invoiceCount,
  Value<double> grossSales,
  Value<double> discounts,
  Value<double> taxTotal,
  Value<double> netSales,
  Value<double> cashTotal,
  Value<double> cardTotal,
  Value<double> otherPayments,
  Value<double> playStationTotal,
  Value<double> walletTotal,
  Value<double> instapayTotal,
  Value<int> totalItems,
  Value<String> status,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

class $$DailyClosingsTableFilterComposer
    extends Composer<_$AppDatabase, $DailyClosingsTable> {
  $$DailyClosingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get closingDate => $composableBuilder(
      column: $table.closingDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get closingTime => $composableBuilder(
      column: $table.closingTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get invoiceCount => $composableBuilder(
      column: $table.invoiceCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get grossSales => $composableBuilder(
      column: $table.grossSales, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get discounts => $composableBuilder(
      column: $table.discounts, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get taxTotal => $composableBuilder(
      column: $table.taxTotal, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get netSales => $composableBuilder(
      column: $table.netSales, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get cashTotal => $composableBuilder(
      column: $table.cashTotal, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get cardTotal => $composableBuilder(
      column: $table.cardTotal, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get otherPayments => $composableBuilder(
      column: $table.otherPayments, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get playStationTotal => $composableBuilder(
      column: $table.playStationTotal,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get walletTotal => $composableBuilder(
      column: $table.walletTotal, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get instapayTotal => $composableBuilder(
      column: $table.instapayTotal, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalItems => $composableBuilder(
      column: $table.totalItems, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$DailyClosingsTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyClosingsTable> {
  $$DailyClosingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get closingDate => $composableBuilder(
      column: $table.closingDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get closingTime => $composableBuilder(
      column: $table.closingTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get invoiceCount => $composableBuilder(
      column: $table.invoiceCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get grossSales => $composableBuilder(
      column: $table.grossSales, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get discounts => $composableBuilder(
      column: $table.discounts, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get taxTotal => $composableBuilder(
      column: $table.taxTotal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get netSales => $composableBuilder(
      column: $table.netSales, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get cashTotal => $composableBuilder(
      column: $table.cashTotal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get cardTotal => $composableBuilder(
      column: $table.cardTotal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get otherPayments => $composableBuilder(
      column: $table.otherPayments,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get playStationTotal => $composableBuilder(
      column: $table.playStationTotal,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get walletTotal => $composableBuilder(
      column: $table.walletTotal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get instapayTotal => $composableBuilder(
      column: $table.instapayTotal,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalItems => $composableBuilder(
      column: $table.totalItems, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$DailyClosingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyClosingsTable> {
  $$DailyClosingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get closingDate => $composableBuilder(
      column: $table.closingDate, builder: (column) => column);

  GeneratedColumn<String> get closingTime => $composableBuilder(
      column: $table.closingTime, builder: (column) => column);

  GeneratedColumn<int> get invoiceCount => $composableBuilder(
      column: $table.invoiceCount, builder: (column) => column);

  GeneratedColumn<double> get grossSales => $composableBuilder(
      column: $table.grossSales, builder: (column) => column);

  GeneratedColumn<double> get discounts =>
      $composableBuilder(column: $table.discounts, builder: (column) => column);

  GeneratedColumn<double> get taxTotal =>
      $composableBuilder(column: $table.taxTotal, builder: (column) => column);

  GeneratedColumn<double> get netSales =>
      $composableBuilder(column: $table.netSales, builder: (column) => column);

  GeneratedColumn<double> get cashTotal =>
      $composableBuilder(column: $table.cashTotal, builder: (column) => column);

  GeneratedColumn<double> get cardTotal =>
      $composableBuilder(column: $table.cardTotal, builder: (column) => column);

  GeneratedColumn<double> get otherPayments => $composableBuilder(
      column: $table.otherPayments, builder: (column) => column);

  GeneratedColumn<double> get playStationTotal => $composableBuilder(
      column: $table.playStationTotal, builder: (column) => column);

  GeneratedColumn<double> get walletTotal => $composableBuilder(
      column: $table.walletTotal, builder: (column) => column);

  GeneratedColumn<double> get instapayTotal => $composableBuilder(
      column: $table.instapayTotal, builder: (column) => column);

  GeneratedColumn<int> get totalItems => $composableBuilder(
      column: $table.totalItems, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$DailyClosingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DailyClosingsTable,
    DailyClosing,
    $$DailyClosingsTableFilterComposer,
    $$DailyClosingsTableOrderingComposer,
    $$DailyClosingsTableAnnotationComposer,
    $$DailyClosingsTableCreateCompanionBuilder,
    $$DailyClosingsTableUpdateCompanionBuilder,
    (
      DailyClosing,
      BaseReferences<_$AppDatabase, $DailyClosingsTable, DailyClosing>
    ),
    DailyClosing,
    PrefetchHooks Function()> {
  $$DailyClosingsTableTableManager(_$AppDatabase db, $DailyClosingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyClosingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyClosingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyClosingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> closingDate = const Value.absent(),
            Value<String> closingTime = const Value.absent(),
            Value<int> invoiceCount = const Value.absent(),
            Value<double> grossSales = const Value.absent(),
            Value<double> discounts = const Value.absent(),
            Value<double> taxTotal = const Value.absent(),
            Value<double> netSales = const Value.absent(),
            Value<double> cashTotal = const Value.absent(),
            Value<double> cardTotal = const Value.absent(),
            Value<double> otherPayments = const Value.absent(),
            Value<double> playStationTotal = const Value.absent(),
            Value<double> walletTotal = const Value.absent(),
            Value<double> instapayTotal = const Value.absent(),
            Value<int> totalItems = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              DailyClosingsCompanion(
            id: id,
            closingDate: closingDate,
            closingTime: closingTime,
            invoiceCount: invoiceCount,
            grossSales: grossSales,
            discounts: discounts,
            taxTotal: taxTotal,
            netSales: netSales,
            cashTotal: cashTotal,
            cardTotal: cardTotal,
            otherPayments: otherPayments,
            playStationTotal: playStationTotal,
            walletTotal: walletTotal,
            instapayTotal: instapayTotal,
            totalItems: totalItems,
            status: status,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String closingDate,
            required String closingTime,
            Value<int> invoiceCount = const Value.absent(),
            Value<double> grossSales = const Value.absent(),
            Value<double> discounts = const Value.absent(),
            Value<double> taxTotal = const Value.absent(),
            Value<double> netSales = const Value.absent(),
            Value<double> cashTotal = const Value.absent(),
            Value<double> cardTotal = const Value.absent(),
            Value<double> otherPayments = const Value.absent(),
            Value<double> playStationTotal = const Value.absent(),
            Value<double> walletTotal = const Value.absent(),
            Value<double> instapayTotal = const Value.absent(),
            Value<int> totalItems = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              DailyClosingsCompanion.insert(
            id: id,
            closingDate: closingDate,
            closingTime: closingTime,
            invoiceCount: invoiceCount,
            grossSales: grossSales,
            discounts: discounts,
            taxTotal: taxTotal,
            netSales: netSales,
            cashTotal: cashTotal,
            cardTotal: cardTotal,
            otherPayments: otherPayments,
            playStationTotal: playStationTotal,
            walletTotal: walletTotal,
            instapayTotal: instapayTotal,
            totalItems: totalItems,
            status: status,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DailyClosingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DailyClosingsTable,
    DailyClosing,
    $$DailyClosingsTableFilterComposer,
    $$DailyClosingsTableOrderingComposer,
    $$DailyClosingsTableAnnotationComposer,
    $$DailyClosingsTableCreateCompanionBuilder,
    $$DailyClosingsTableUpdateCompanionBuilder,
    (
      DailyClosing,
      BaseReferences<_$AppDatabase, $DailyClosingsTable, DailyClosing>
    ),
    DailyClosing,
    PrefetchHooks Function()>;
typedef $$WhatsAppQueueTableCreateCompanionBuilder = WhatsAppQueueCompanion
    Function({
  Value<int> id,
  required String messageType,
  Value<int?> invoiceId,
  Value<int?> dailyClosingId,
  required String recipientPhone,
  required String messagePayload,
  Value<String> status,
  Value<int> attemptCount,
  Value<DateTime?> lastAttemptAt,
  Value<DateTime?> sentAt,
  Value<String?> errorMessage,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$WhatsAppQueueTableUpdateCompanionBuilder = WhatsAppQueueCompanion
    Function({
  Value<int> id,
  Value<String> messageType,
  Value<int?> invoiceId,
  Value<int?> dailyClosingId,
  Value<String> recipientPhone,
  Value<String> messagePayload,
  Value<String> status,
  Value<int> attemptCount,
  Value<DateTime?> lastAttemptAt,
  Value<DateTime?> sentAt,
  Value<String?> errorMessage,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

class $$WhatsAppQueueTableFilterComposer
    extends Composer<_$AppDatabase, $WhatsAppQueueTable> {
  $$WhatsAppQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get messageType => $composableBuilder(
      column: $table.messageType, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get invoiceId => $composableBuilder(
      column: $table.invoiceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get dailyClosingId => $composableBuilder(
      column: $table.dailyClosingId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get recipientPhone => $composableBuilder(
      column: $table.recipientPhone,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get messagePayload => $composableBuilder(
      column: $table.messagePayload,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get attemptCount => $composableBuilder(
      column: $table.attemptCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastAttemptAt => $composableBuilder(
      column: $table.lastAttemptAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get sentAt => $composableBuilder(
      column: $table.sentAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get errorMessage => $composableBuilder(
      column: $table.errorMessage, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$WhatsAppQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $WhatsAppQueueTable> {
  $$WhatsAppQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get messageType => $composableBuilder(
      column: $table.messageType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get invoiceId => $composableBuilder(
      column: $table.invoiceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get dailyClosingId => $composableBuilder(
      column: $table.dailyClosingId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get recipientPhone => $composableBuilder(
      column: $table.recipientPhone,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get messagePayload => $composableBuilder(
      column: $table.messagePayload,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get attemptCount => $composableBuilder(
      column: $table.attemptCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastAttemptAt => $composableBuilder(
      column: $table.lastAttemptAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get sentAt => $composableBuilder(
      column: $table.sentAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get errorMessage => $composableBuilder(
      column: $table.errorMessage,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$WhatsAppQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $WhatsAppQueueTable> {
  $$WhatsAppQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get messageType => $composableBuilder(
      column: $table.messageType, builder: (column) => column);

  GeneratedColumn<int> get invoiceId =>
      $composableBuilder(column: $table.invoiceId, builder: (column) => column);

  GeneratedColumn<int> get dailyClosingId => $composableBuilder(
      column: $table.dailyClosingId, builder: (column) => column);

  GeneratedColumn<String> get recipientPhone => $composableBuilder(
      column: $table.recipientPhone, builder: (column) => column);

  GeneratedColumn<String> get messagePayload => $composableBuilder(
      column: $table.messagePayload, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get attemptCount => $composableBuilder(
      column: $table.attemptCount, builder: (column) => column);

  GeneratedColumn<DateTime> get lastAttemptAt => $composableBuilder(
      column: $table.lastAttemptAt, builder: (column) => column);

  GeneratedColumn<DateTime> get sentAt =>
      $composableBuilder(column: $table.sentAt, builder: (column) => column);

  GeneratedColumn<String> get errorMessage => $composableBuilder(
      column: $table.errorMessage, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$WhatsAppQueueTableTableManager extends RootTableManager<
    _$AppDatabase,
    $WhatsAppQueueTable,
    WhatsAppQueueData,
    $$WhatsAppQueueTableFilterComposer,
    $$WhatsAppQueueTableOrderingComposer,
    $$WhatsAppQueueTableAnnotationComposer,
    $$WhatsAppQueueTableCreateCompanionBuilder,
    $$WhatsAppQueueTableUpdateCompanionBuilder,
    (
      WhatsAppQueueData,
      BaseReferences<_$AppDatabase, $WhatsAppQueueTable, WhatsAppQueueData>
    ),
    WhatsAppQueueData,
    PrefetchHooks Function()> {
  $$WhatsAppQueueTableTableManager(_$AppDatabase db, $WhatsAppQueueTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WhatsAppQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WhatsAppQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WhatsAppQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> messageType = const Value.absent(),
            Value<int?> invoiceId = const Value.absent(),
            Value<int?> dailyClosingId = const Value.absent(),
            Value<String> recipientPhone = const Value.absent(),
            Value<String> messagePayload = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> attemptCount = const Value.absent(),
            Value<DateTime?> lastAttemptAt = const Value.absent(),
            Value<DateTime?> sentAt = const Value.absent(),
            Value<String?> errorMessage = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              WhatsAppQueueCompanion(
            id: id,
            messageType: messageType,
            invoiceId: invoiceId,
            dailyClosingId: dailyClosingId,
            recipientPhone: recipientPhone,
            messagePayload: messagePayload,
            status: status,
            attemptCount: attemptCount,
            lastAttemptAt: lastAttemptAt,
            sentAt: sentAt,
            errorMessage: errorMessage,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String messageType,
            Value<int?> invoiceId = const Value.absent(),
            Value<int?> dailyClosingId = const Value.absent(),
            required String recipientPhone,
            required String messagePayload,
            Value<String> status = const Value.absent(),
            Value<int> attemptCount = const Value.absent(),
            Value<DateTime?> lastAttemptAt = const Value.absent(),
            Value<DateTime?> sentAt = const Value.absent(),
            Value<String?> errorMessage = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              WhatsAppQueueCompanion.insert(
            id: id,
            messageType: messageType,
            invoiceId: invoiceId,
            dailyClosingId: dailyClosingId,
            recipientPhone: recipientPhone,
            messagePayload: messagePayload,
            status: status,
            attemptCount: attemptCount,
            lastAttemptAt: lastAttemptAt,
            sentAt: sentAt,
            errorMessage: errorMessage,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$WhatsAppQueueTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $WhatsAppQueueTable,
    WhatsAppQueueData,
    $$WhatsAppQueueTableFilterComposer,
    $$WhatsAppQueueTableOrderingComposer,
    $$WhatsAppQueueTableAnnotationComposer,
    $$WhatsAppQueueTableCreateCompanionBuilder,
    $$WhatsAppQueueTableUpdateCompanionBuilder,
    (
      WhatsAppQueueData,
      BaseReferences<_$AppDatabase, $WhatsAppQueueTable, WhatsAppQueueData>
    ),
    WhatsAppQueueData,
    PrefetchHooks Function()>;
typedef $$PlayStationDevicesTableCreateCompanionBuilder
    = PlayStationDevicesCompanion Function({
  Value<int> id,
  required String name,
  Value<double> hourlyRate,
  Value<bool> isActive,
  Value<DateTime> createdAt,
});
typedef $$PlayStationDevicesTableUpdateCompanionBuilder
    = PlayStationDevicesCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<double> hourlyRate,
  Value<bool> isActive,
  Value<DateTime> createdAt,
});

final class $$PlayStationDevicesTableReferences extends BaseReferences<
    _$AppDatabase, $PlayStationDevicesTable, PlayStationDevice> {
  $$PlayStationDevicesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PlayStationSessionsTable,
      List<PlayStationSession>> _playStationSessionsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.playStationSessions,
          aliasName: $_aliasNameGenerator(
              db.playStationDevices.id, db.playStationSessions.deviceId));

  $$PlayStationSessionsTableProcessedTableManager get playStationSessionsRefs {
    final manager =
        $$PlayStationSessionsTableTableManager($_db, $_db.playStationSessions)
            .filter((f) => f.deviceId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_playStationSessionsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$PlayStationDevicesTableFilterComposer
    extends Composer<_$AppDatabase, $PlayStationDevicesTable> {
  $$PlayStationDevicesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get hourlyRate => $composableBuilder(
      column: $table.hourlyRate, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  Expression<bool> playStationSessionsRefs(
      Expression<bool> Function($$PlayStationSessionsTableFilterComposer f) f) {
    final $$PlayStationSessionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.playStationSessions,
        getReferencedColumn: (t) => t.deviceId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlayStationSessionsTableFilterComposer(
              $db: $db,
              $table: $db.playStationSessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$PlayStationDevicesTableOrderingComposer
    extends Composer<_$AppDatabase, $PlayStationDevicesTable> {
  $$PlayStationDevicesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get hourlyRate => $composableBuilder(
      column: $table.hourlyRate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$PlayStationDevicesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlayStationDevicesTable> {
  $$PlayStationDevicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get hourlyRate => $composableBuilder(
      column: $table.hourlyRate, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> playStationSessionsRefs<T extends Object>(
      Expression<T> Function($$PlayStationSessionsTableAnnotationComposer a)
          f) {
    final $$PlayStationSessionsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.playStationSessions,
            getReferencedColumn: (t) => t.deviceId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$PlayStationSessionsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.playStationSessions,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$PlayStationDevicesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PlayStationDevicesTable,
    PlayStationDevice,
    $$PlayStationDevicesTableFilterComposer,
    $$PlayStationDevicesTableOrderingComposer,
    $$PlayStationDevicesTableAnnotationComposer,
    $$PlayStationDevicesTableCreateCompanionBuilder,
    $$PlayStationDevicesTableUpdateCompanionBuilder,
    (PlayStationDevice, $$PlayStationDevicesTableReferences),
    PlayStationDevice,
    PrefetchHooks Function({bool playStationSessionsRefs})> {
  $$PlayStationDevicesTableTableManager(
      _$AppDatabase db, $PlayStationDevicesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlayStationDevicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlayStationDevicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlayStationDevicesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<double> hourlyRate = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              PlayStationDevicesCompanion(
            id: id,
            name: name,
            hourlyRate: hourlyRate,
            isActive: isActive,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<double> hourlyRate = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              PlayStationDevicesCompanion.insert(
            id: id,
            name: name,
            hourlyRate: hourlyRate,
            isActive: isActive,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$PlayStationDevicesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({playStationSessionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (playStationSessionsRefs) db.playStationSessions
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (playStationSessionsRefs)
                    await $_getPrefetchedData<PlayStationDevice,
                            $PlayStationDevicesTable, PlayStationSession>(
                        currentTable: table,
                        referencedTable: $$PlayStationDevicesTableReferences
                            ._playStationSessionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$PlayStationDevicesTableReferences(db, table, p0)
                                .playStationSessionsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.deviceId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$PlayStationDevicesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PlayStationDevicesTable,
    PlayStationDevice,
    $$PlayStationDevicesTableFilterComposer,
    $$PlayStationDevicesTableOrderingComposer,
    $$PlayStationDevicesTableAnnotationComposer,
    $$PlayStationDevicesTableCreateCompanionBuilder,
    $$PlayStationDevicesTableUpdateCompanionBuilder,
    (PlayStationDevice, $$PlayStationDevicesTableReferences),
    PlayStationDevice,
    PrefetchHooks Function({bool playStationSessionsRefs})>;
typedef $$PlayStationSessionsTableCreateCompanionBuilder
    = PlayStationSessionsCompanion Function({
  Value<int> id,
  Value<int?> tableId,
  required int deviceId,
  required DateTime startTime,
  Value<DateTime?> endTime,
  Value<int?> elapsedSeconds,
  required double hourlyRate,
  Value<double> calculatedAmount,
  Value<String> status,
  Value<DateTime> createdAt,
});
typedef $$PlayStationSessionsTableUpdateCompanionBuilder
    = PlayStationSessionsCompanion Function({
  Value<int> id,
  Value<int?> tableId,
  Value<int> deviceId,
  Value<DateTime> startTime,
  Value<DateTime?> endTime,
  Value<int?> elapsedSeconds,
  Value<double> hourlyRate,
  Value<double> calculatedAmount,
  Value<String> status,
  Value<DateTime> createdAt,
});

final class $$PlayStationSessionsTableReferences extends BaseReferences<
    _$AppDatabase, $PlayStationSessionsTable, PlayStationSession> {
  $$PlayStationSessionsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $SystemTablesTable _tableIdTable(_$AppDatabase db) =>
      db.systemTables.createAlias($_aliasNameGenerator(
          db.playStationSessions.tableId, db.systemTables.id));

  $$SystemTablesTableProcessedTableManager? get tableId {
    final $_column = $_itemColumn<int>('table_id');
    if ($_column == null) return null;
    final manager = $$SystemTablesTableTableManager($_db, $_db.systemTables)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tableIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $PlayStationDevicesTable _deviceIdTable(_$AppDatabase db) =>
      db.playStationDevices.createAlias($_aliasNameGenerator(
          db.playStationSessions.deviceId, db.playStationDevices.id));

  $$PlayStationDevicesTableProcessedTableManager get deviceId {
    final $_column = $_itemColumn<int>('device_id')!;

    final manager =
        $$PlayStationDevicesTableTableManager($_db, $_db.playStationDevices)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_deviceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$PlayStationSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $PlayStationSessionsTable> {
  $$PlayStationSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startTime => $composableBuilder(
      column: $table.startTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endTime => $composableBuilder(
      column: $table.endTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get elapsedSeconds => $composableBuilder(
      column: $table.elapsedSeconds,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get hourlyRate => $composableBuilder(
      column: $table.hourlyRate, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get calculatedAmount => $composableBuilder(
      column: $table.calculatedAmount,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$SystemTablesTableFilterComposer get tableId {
    final $$SystemTablesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.tableId,
        referencedTable: $db.systemTables,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SystemTablesTableFilterComposer(
              $db: $db,
              $table: $db.systemTables,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$PlayStationDevicesTableFilterComposer get deviceId {
    final $$PlayStationDevicesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.deviceId,
        referencedTable: $db.playStationDevices,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlayStationDevicesTableFilterComposer(
              $db: $db,
              $table: $db.playStationDevices,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PlayStationSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlayStationSessionsTable> {
  $$PlayStationSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startTime => $composableBuilder(
      column: $table.startTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endTime => $composableBuilder(
      column: $table.endTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get elapsedSeconds => $composableBuilder(
      column: $table.elapsedSeconds,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get hourlyRate => $composableBuilder(
      column: $table.hourlyRate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get calculatedAmount => $composableBuilder(
      column: $table.calculatedAmount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$SystemTablesTableOrderingComposer get tableId {
    final $$SystemTablesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.tableId,
        referencedTable: $db.systemTables,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SystemTablesTableOrderingComposer(
              $db: $db,
              $table: $db.systemTables,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$PlayStationDevicesTableOrderingComposer get deviceId {
    final $$PlayStationDevicesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.deviceId,
        referencedTable: $db.playStationDevices,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlayStationDevicesTableOrderingComposer(
              $db: $db,
              $table: $db.playStationDevices,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PlayStationSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlayStationSessionsTable> {
  $$PlayStationSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<DateTime> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<int> get elapsedSeconds => $composableBuilder(
      column: $table.elapsedSeconds, builder: (column) => column);

  GeneratedColumn<double> get hourlyRate => $composableBuilder(
      column: $table.hourlyRate, builder: (column) => column);

  GeneratedColumn<double> get calculatedAmount => $composableBuilder(
      column: $table.calculatedAmount, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$SystemTablesTableAnnotationComposer get tableId {
    final $$SystemTablesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.tableId,
        referencedTable: $db.systemTables,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SystemTablesTableAnnotationComposer(
              $db: $db,
              $table: $db.systemTables,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$PlayStationDevicesTableAnnotationComposer get deviceId {
    final $$PlayStationDevicesTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.deviceId,
            referencedTable: $db.playStationDevices,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$PlayStationDevicesTableAnnotationComposer(
                  $db: $db,
                  $table: $db.playStationDevices,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }
}

class $$PlayStationSessionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PlayStationSessionsTable,
    PlayStationSession,
    $$PlayStationSessionsTableFilterComposer,
    $$PlayStationSessionsTableOrderingComposer,
    $$PlayStationSessionsTableAnnotationComposer,
    $$PlayStationSessionsTableCreateCompanionBuilder,
    $$PlayStationSessionsTableUpdateCompanionBuilder,
    (PlayStationSession, $$PlayStationSessionsTableReferences),
    PlayStationSession,
    PrefetchHooks Function({bool tableId, bool deviceId})> {
  $$PlayStationSessionsTableTableManager(
      _$AppDatabase db, $PlayStationSessionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlayStationSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlayStationSessionsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlayStationSessionsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> tableId = const Value.absent(),
            Value<int> deviceId = const Value.absent(),
            Value<DateTime> startTime = const Value.absent(),
            Value<DateTime?> endTime = const Value.absent(),
            Value<int?> elapsedSeconds = const Value.absent(),
            Value<double> hourlyRate = const Value.absent(),
            Value<double> calculatedAmount = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              PlayStationSessionsCompanion(
            id: id,
            tableId: tableId,
            deviceId: deviceId,
            startTime: startTime,
            endTime: endTime,
            elapsedSeconds: elapsedSeconds,
            hourlyRate: hourlyRate,
            calculatedAmount: calculatedAmount,
            status: status,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> tableId = const Value.absent(),
            required int deviceId,
            required DateTime startTime,
            Value<DateTime?> endTime = const Value.absent(),
            Value<int?> elapsedSeconds = const Value.absent(),
            required double hourlyRate,
            Value<double> calculatedAmount = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              PlayStationSessionsCompanion.insert(
            id: id,
            tableId: tableId,
            deviceId: deviceId,
            startTime: startTime,
            endTime: endTime,
            elapsedSeconds: elapsedSeconds,
            hourlyRate: hourlyRate,
            calculatedAmount: calculatedAmount,
            status: status,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$PlayStationSessionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({tableId = false, deviceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (tableId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.tableId,
                    referencedTable:
                        $$PlayStationSessionsTableReferences._tableIdTable(db),
                    referencedColumn: $$PlayStationSessionsTableReferences
                        ._tableIdTable(db)
                        .id,
                  ) as T;
                }
                if (deviceId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.deviceId,
                    referencedTable:
                        $$PlayStationSessionsTableReferences._deviceIdTable(db),
                    referencedColumn: $$PlayStationSessionsTableReferences
                        ._deviceIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$PlayStationSessionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PlayStationSessionsTable,
    PlayStationSession,
    $$PlayStationSessionsTableFilterComposer,
    $$PlayStationSessionsTableOrderingComposer,
    $$PlayStationSessionsTableAnnotationComposer,
    $$PlayStationSessionsTableCreateCompanionBuilder,
    $$PlayStationSessionsTableUpdateCompanionBuilder,
    (PlayStationSession, $$PlayStationSessionsTableReferences),
    PlayStationSession,
    PrefetchHooks Function({bool tableId, bool deviceId})>;
typedef $$InventoryMovementsTableCreateCompanionBuilder
    = InventoryMovementsCompanion Function({
  Value<int> id,
  required int productId,
  required int quantity,
  required String movementType,
  required int previousQuantity,
  required int newQuantity,
  Value<String?> reason,
  Value<DateTime> createdAt,
});
typedef $$InventoryMovementsTableUpdateCompanionBuilder
    = InventoryMovementsCompanion Function({
  Value<int> id,
  Value<int> productId,
  Value<int> quantity,
  Value<String> movementType,
  Value<int> previousQuantity,
  Value<int> newQuantity,
  Value<String?> reason,
  Value<DateTime> createdAt,
});

final class $$InventoryMovementsTableReferences extends BaseReferences<
    _$AppDatabase, $InventoryMovementsTable, InventoryMovement> {
  $$InventoryMovementsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ProductsTable _productIdTable(_$AppDatabase db) =>
      db.products.createAlias($_aliasNameGenerator(
          db.inventoryMovements.productId, db.products.id));

  $$ProductsTableProcessedTableManager get productId {
    final $_column = $_itemColumn<int>('product_id')!;

    final manager = $$ProductsTableTableManager($_db, $_db.products)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$InventoryMovementsTableFilterComposer
    extends Composer<_$AppDatabase, $InventoryMovementsTable> {
  $$InventoryMovementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get movementType => $composableBuilder(
      column: $table.movementType, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get previousQuantity => $composableBuilder(
      column: $table.previousQuantity,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get newQuantity => $composableBuilder(
      column: $table.newQuantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reason => $composableBuilder(
      column: $table.reason, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$ProductsTableFilterComposer get productId {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productId,
        referencedTable: $db.products,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductsTableFilterComposer(
              $db: $db,
              $table: $db.products,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$InventoryMovementsTableOrderingComposer
    extends Composer<_$AppDatabase, $InventoryMovementsTable> {
  $$InventoryMovementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get movementType => $composableBuilder(
      column: $table.movementType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get previousQuantity => $composableBuilder(
      column: $table.previousQuantity,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get newQuantity => $composableBuilder(
      column: $table.newQuantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reason => $composableBuilder(
      column: $table.reason, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$ProductsTableOrderingComposer get productId {
    final $$ProductsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productId,
        referencedTable: $db.products,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductsTableOrderingComposer(
              $db: $db,
              $table: $db.products,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$InventoryMovementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InventoryMovementsTable> {
  $$InventoryMovementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get movementType => $composableBuilder(
      column: $table.movementType, builder: (column) => column);

  GeneratedColumn<int> get previousQuantity => $composableBuilder(
      column: $table.previousQuantity, builder: (column) => column);

  GeneratedColumn<int> get newQuantity => $composableBuilder(
      column: $table.newQuantity, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ProductsTableAnnotationComposer get productId {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productId,
        referencedTable: $db.products,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductsTableAnnotationComposer(
              $db: $db,
              $table: $db.products,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$InventoryMovementsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $InventoryMovementsTable,
    InventoryMovement,
    $$InventoryMovementsTableFilterComposer,
    $$InventoryMovementsTableOrderingComposer,
    $$InventoryMovementsTableAnnotationComposer,
    $$InventoryMovementsTableCreateCompanionBuilder,
    $$InventoryMovementsTableUpdateCompanionBuilder,
    (InventoryMovement, $$InventoryMovementsTableReferences),
    InventoryMovement,
    PrefetchHooks Function({bool productId})> {
  $$InventoryMovementsTableTableManager(
      _$AppDatabase db, $InventoryMovementsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InventoryMovementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InventoryMovementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InventoryMovementsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> productId = const Value.absent(),
            Value<int> quantity = const Value.absent(),
            Value<String> movementType = const Value.absent(),
            Value<int> previousQuantity = const Value.absent(),
            Value<int> newQuantity = const Value.absent(),
            Value<String?> reason = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              InventoryMovementsCompanion(
            id: id,
            productId: productId,
            quantity: quantity,
            movementType: movementType,
            previousQuantity: previousQuantity,
            newQuantity: newQuantity,
            reason: reason,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int productId,
            required int quantity,
            required String movementType,
            required int previousQuantity,
            required int newQuantity,
            Value<String?> reason = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              InventoryMovementsCompanion.insert(
            id: id,
            productId: productId,
            quantity: quantity,
            movementType: movementType,
            previousQuantity: previousQuantity,
            newQuantity: newQuantity,
            reason: reason,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$InventoryMovementsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({productId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (productId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.productId,
                    referencedTable:
                        $$InventoryMovementsTableReferences._productIdTable(db),
                    referencedColumn: $$InventoryMovementsTableReferences
                        ._productIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$InventoryMovementsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $InventoryMovementsTable,
    InventoryMovement,
    $$InventoryMovementsTableFilterComposer,
    $$InventoryMovementsTableOrderingComposer,
    $$InventoryMovementsTableAnnotationComposer,
    $$InventoryMovementsTableCreateCompanionBuilder,
    $$InventoryMovementsTableUpdateCompanionBuilder,
    (InventoryMovement, $$InventoryMovementsTableReferences),
    InventoryMovement,
    PrefetchHooks Function({bool productId})>;
typedef $$InvoiceItemsTableCreateCompanionBuilder = InvoiceItemsCompanion
    Function({
  Value<int> id,
  required int invoiceId,
  Value<int?> productId,
  required String productName,
  Value<int> quantity,
  required double unitPrice,
  required double totalPrice,
});
typedef $$InvoiceItemsTableUpdateCompanionBuilder = InvoiceItemsCompanion
    Function({
  Value<int> id,
  Value<int> invoiceId,
  Value<int?> productId,
  Value<String> productName,
  Value<int> quantity,
  Value<double> unitPrice,
  Value<double> totalPrice,
});

final class $$InvoiceItemsTableReferences
    extends BaseReferences<_$AppDatabase, $InvoiceItemsTable, InvoiceItem> {
  $$InvoiceItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $InvoicesTable _invoiceIdTable(_$AppDatabase db) =>
      db.invoices.createAlias(
          $_aliasNameGenerator(db.invoiceItems.invoiceId, db.invoices.id));

  $$InvoicesTableProcessedTableManager get invoiceId {
    final $_column = $_itemColumn<int>('invoice_id')!;

    final manager = $$InvoicesTableTableManager($_db, $_db.invoices)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_invoiceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$InvoiceItemsTableFilterComposer
    extends Composer<_$AppDatabase, $InvoiceItemsTable> {
  $$InvoiceItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get productId => $composableBuilder(
      column: $table.productId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get productName => $composableBuilder(
      column: $table.productName, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get unitPrice => $composableBuilder(
      column: $table.unitPrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get totalPrice => $composableBuilder(
      column: $table.totalPrice, builder: (column) => ColumnFilters(column));

  $$InvoicesTableFilterComposer get invoiceId {
    final $$InvoicesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.invoiceId,
        referencedTable: $db.invoices,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InvoicesTableFilterComposer(
              $db: $db,
              $table: $db.invoices,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$InvoiceItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $InvoiceItemsTable> {
  $$InvoiceItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get productId => $composableBuilder(
      column: $table.productId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get productName => $composableBuilder(
      column: $table.productName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get unitPrice => $composableBuilder(
      column: $table.unitPrice, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get totalPrice => $composableBuilder(
      column: $table.totalPrice, builder: (column) => ColumnOrderings(column));

  $$InvoicesTableOrderingComposer get invoiceId {
    final $$InvoicesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.invoiceId,
        referencedTable: $db.invoices,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InvoicesTableOrderingComposer(
              $db: $db,
              $table: $db.invoices,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$InvoiceItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InvoiceItemsTable> {
  $$InvoiceItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<String> get productName => $composableBuilder(
      column: $table.productName, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get unitPrice =>
      $composableBuilder(column: $table.unitPrice, builder: (column) => column);

  GeneratedColumn<double> get totalPrice => $composableBuilder(
      column: $table.totalPrice, builder: (column) => column);

  $$InvoicesTableAnnotationComposer get invoiceId {
    final $$InvoicesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.invoiceId,
        referencedTable: $db.invoices,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InvoicesTableAnnotationComposer(
              $db: $db,
              $table: $db.invoices,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$InvoiceItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $InvoiceItemsTable,
    InvoiceItem,
    $$InvoiceItemsTableFilterComposer,
    $$InvoiceItemsTableOrderingComposer,
    $$InvoiceItemsTableAnnotationComposer,
    $$InvoiceItemsTableCreateCompanionBuilder,
    $$InvoiceItemsTableUpdateCompanionBuilder,
    (InvoiceItem, $$InvoiceItemsTableReferences),
    InvoiceItem,
    PrefetchHooks Function({bool invoiceId})> {
  $$InvoiceItemsTableTableManager(_$AppDatabase db, $InvoiceItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InvoiceItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InvoiceItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InvoiceItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> invoiceId = const Value.absent(),
            Value<int?> productId = const Value.absent(),
            Value<String> productName = const Value.absent(),
            Value<int> quantity = const Value.absent(),
            Value<double> unitPrice = const Value.absent(),
            Value<double> totalPrice = const Value.absent(),
          }) =>
              InvoiceItemsCompanion(
            id: id,
            invoiceId: invoiceId,
            productId: productId,
            productName: productName,
            quantity: quantity,
            unitPrice: unitPrice,
            totalPrice: totalPrice,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int invoiceId,
            Value<int?> productId = const Value.absent(),
            required String productName,
            Value<int> quantity = const Value.absent(),
            required double unitPrice,
            required double totalPrice,
          }) =>
              InvoiceItemsCompanion.insert(
            id: id,
            invoiceId: invoiceId,
            productId: productId,
            productName: productName,
            quantity: quantity,
            unitPrice: unitPrice,
            totalPrice: totalPrice,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$InvoiceItemsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({invoiceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (invoiceId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.invoiceId,
                    referencedTable:
                        $$InvoiceItemsTableReferences._invoiceIdTable(db),
                    referencedColumn:
                        $$InvoiceItemsTableReferences._invoiceIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$InvoiceItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $InvoiceItemsTable,
    InvoiceItem,
    $$InvoiceItemsTableFilterComposer,
    $$InvoiceItemsTableOrderingComposer,
    $$InvoiceItemsTableAnnotationComposer,
    $$InvoiceItemsTableCreateCompanionBuilder,
    $$InvoiceItemsTableUpdateCompanionBuilder,
    (InvoiceItem, $$InvoiceItemsTableReferences),
    InvoiceItem,
    PrefetchHooks Function({bool invoiceId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SystemTablesTableTableManager get systemTables =>
      $$SystemTablesTableTableManager(_db, _db.systemTables);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$ProductsTableTableManager get products =>
      $$ProductsTableTableManager(_db, _db.products);
  $$OrdersTableTableManager get orders =>
      $$OrdersTableTableManager(_db, _db.orders);
  $$OrderItemsTableTableManager get orderItems =>
      $$OrderItemsTableTableManager(_db, _db.orderItems);
  $$InvoicesTableTableManager get invoices =>
      $$InvoicesTableTableManager(_db, _db.invoices);
  $$DailyClosingsTableTableManager get dailyClosings =>
      $$DailyClosingsTableTableManager(_db, _db.dailyClosings);
  $$WhatsAppQueueTableTableManager get whatsAppQueue =>
      $$WhatsAppQueueTableTableManager(_db, _db.whatsAppQueue);
  $$PlayStationDevicesTableTableManager get playStationDevices =>
      $$PlayStationDevicesTableTableManager(_db, _db.playStationDevices);
  $$PlayStationSessionsTableTableManager get playStationSessions =>
      $$PlayStationSessionsTableTableManager(_db, _db.playStationSessions);
  $$InventoryMovementsTableTableManager get inventoryMovements =>
      $$InventoryMovementsTableTableManager(_db, _db.inventoryMovements);
  $$InvoiceItemsTableTableManager get invoiceItems =>
      $$InvoiceItemsTableTableManager(_db, _db.invoiceItems);
}
