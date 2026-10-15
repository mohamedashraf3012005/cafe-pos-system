import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../orders/domain/entities/category_entity.dart';
import '../../../orders/domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';

// ─── States ───────────────────────────────────────────────────────────────────

abstract class ProductManagementState extends Equatable {
  const ProductManagementState();
  @override
  List<Object?> get props => [];
}

class ProductManagementInitial extends ProductManagementState {}

class ProductManagementLoading extends ProductManagementState {}

class ProductManagementLoaded extends ProductManagementState {
  final List<CategoryEntity> categories;
  final List<ProductEntity> products;
  final int? selectedCategoryId;

  const ProductManagementLoaded({
    required this.categories,
    required this.products,
    this.selectedCategoryId,
  });

  List<ProductEntity> get filteredProducts {
    if (selectedCategoryId == null) return products;
    return products.where((p) => p.categoryId == selectedCategoryId).toList();
  }

  ProductManagementLoaded copyWith({
    List<CategoryEntity>? categories,
    List<ProductEntity>? products,
    int? selectedCategoryId,
    bool clearCategoryFilter = false,
  }) {
    return ProductManagementLoaded(
      categories: categories ?? this.categories,
      products: products ?? this.products,
      selectedCategoryId: clearCategoryFilter ? null : (selectedCategoryId ?? this.selectedCategoryId),
    );
  }

  @override
  List<Object?> get props => [categories, products, selectedCategoryId];
}

class ProductManagementError extends ProductManagementState {
  final String message;
  const ProductManagementError(this.message);
  @override
  List<Object?> get props => [message];
}

// ─── Cubit ────────────────────────────────────────────────────────────────────

class ProductManagementCubit extends Cubit<ProductManagementState> {
  final ProductRepository repository;

  ProductManagementCubit(this.repository) : super(ProductManagementInitial());

  Future<void> loadAll() async {
    emit(ProductManagementLoading());
    try {
      final categories = await repository.getCategories();
      final products = await repository.getProducts();
      emit(ProductManagementLoaded(categories: categories, products: products));
    } catch (e) {
      emit(ProductManagementError(e.toString()));
    }
  }

  void selectCategory(int? categoryId) {
    final s = state;
    if (s is ProductManagementLoaded) {
      emit(s.copyWith(
        selectedCategoryId: categoryId,
        clearCategoryFilter: categoryId == null,
      ));
    }
  }

  // ── Products ──────────────────────────────────────────────────────────────

  Future<void> addProduct(String name, double price, int categoryId, {bool trackInventory = true}) async {
    try {
      await repository.addProduct(name, price, categoryId, trackInventory: trackInventory);
      await _reload();
    } catch (e) {
      emit(ProductManagementError(e.toString()));
    }
  }

  Future<void> updateProduct(int id, String name, double price, int categoryId, {bool? trackInventory}) async {
    try {
      await repository.updateProduct(id, name, price, categoryId, trackInventory: trackInventory);
      await _reload();
    } catch (e) {
      emit(ProductManagementError(e.toString()));
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      await repository.deleteProduct(id);
      await _reload();
    } catch (e) {
      emit(ProductManagementError(e.toString()));
    }
  }

  // ── Categories ────────────────────────────────────────────────────────────

  Future<void> addCategory(String name) async {
    try {
      await repository.addCategory(name);
      await _reload();
    } catch (e) {
      emit(ProductManagementError(e.toString()));
    }
  }

  Future<void> updateCategory(int id, String name) async {
    try {
      await repository.updateCategory(id, name);
      await _reload();
    } catch (e) {
      emit(ProductManagementError(e.toString()));
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      await repository.deleteCategory(id);
      await _reload();
    } catch (e) {
      emit(ProductManagementError(e.toString()));
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Future<void> _reload() async {
    final currentState = state;
    try {
      final categories = await repository.getCategories();
      final products = await repository.getProducts();
      emit(ProductManagementLoaded(
        categories: categories,
        products: products,
        selectedCategoryId: currentState is ProductManagementLoaded ? currentState.selectedCategoryId : null,
      ));
    } catch (e) {
      emit(ProductManagementError(e.toString()));
    }
  }
}
