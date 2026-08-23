import 'package:equatable/equatable.dart';
import '../../domain/entities/inventory_movement_entity.dart';
import '../../domain/entities/inventory_product_entity.dart';

abstract class InventoryState extends Equatable {
  const InventoryState();

  @override
  List<Object?> get props => [];
}

class InventoryInitial extends InventoryState {}

class InventoryLoading extends InventoryState {}

class InventoryLoaded extends InventoryState {
  final List<InventoryProductEntity> products;
  final List<InventoryMovementEntity> movements;
  final Map<String, dynamic> summary;
  final String searchQuery;
  final StockStatus? filterStatus;
  final String? filterCategory;

  const InventoryLoaded({
    required this.products,
    this.movements = const [],
    this.summary = const {},
    this.searchQuery = '',
    this.filterStatus,
    this.filterCategory,
  });

  List<InventoryProductEntity> get filteredProducts {
    return products.where((p) {
      final matchesSearch = searchQuery.isEmpty ||
          p.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          p.categoryName.toLowerCase().contains(searchQuery.toLowerCase());

      final matchesStatus = filterStatus == null || p.status == filterStatus;
      final matchesCategory = filterCategory == null || p.categoryName == filterCategory;

      return matchesSearch && matchesStatus && matchesCategory;
    }).toList();
  }

  InventoryLoaded copyWith({
    List<InventoryProductEntity>? products,
    List<InventoryMovementEntity>? movements,
    Map<String, dynamic>? summary,
    String? searchQuery,
    StockStatus? filterStatus,
    bool clearStatusFilter = false,
    String? filterCategory,
    bool clearCategoryFilter = false,
  }) {
    return InventoryLoaded(
      products: products ?? this.products,
      movements: movements ?? this.movements,
      summary: summary ?? this.summary,
      searchQuery: searchQuery ?? this.searchQuery,
      filterStatus: clearStatusFilter ? null : (filterStatus ?? this.filterStatus),
      filterCategory: clearCategoryFilter ? null : (filterCategory ?? this.filterCategory),
    );
  }

  @override
  List<Object?> get props => [products, movements, summary, searchQuery, filterStatus, filterCategory];
}

class InventoryError extends InventoryState {
  final String message;
  const InventoryError(this.message);

  @override
  List<Object?> get props => [message];
}
