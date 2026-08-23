import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/inventory_product_entity.dart';
import '../../domain/repositories/inventory_repository.dart';
import 'inventory_state.dart';

class InventoryCubit extends Cubit<InventoryState> {
  final InventoryRepository repository;

  InventoryCubit(this.repository) : super(InventoryInitial());

  Future<void> loadInventory() async {
    emit(InventoryLoading());
    try {
      final products = await repository.getInventoryProducts();
      final summary = await repository.getInventorySummary();
      emit(InventoryLoaded(
        products: products,
        summary: summary,
      ));
    } catch (e) {
      emit(InventoryError('??? ????? ????? ?????? ???????: ${e.toString()}'));
    }
  }

  void search(String query) {
    final s = state;
    if (s is InventoryLoaded) {
      emit(s.copyWith(searchQuery: query));
    }
  }

  void filterByStatus(StockStatus? status) {
    final s = state;
    if (s is InventoryLoaded) {
      emit(s.copyWith(
        filterStatus: status,
        clearStatusFilter: status == null,
      ));
    }
  }

  void filterByCategory(String? category) {
    final s = state;
    if (s is InventoryLoaded) {
      emit(s.copyWith(
        filterCategory: category,
        clearCategoryFilter: category == null,
      ));
    }
  }

  Future<void> addStock(int productId, int quantity, {String? reason}) async {
    try {
      await repository.addStock(productId: productId, quantity: quantity, reason: reason);
      await _reload();
    } catch (e) {
      emit(InventoryError(e.toString()));
    }
  }

  Future<void> removeStock(int productId, int quantity, String reason) async {
    try {
      await repository.removeStock(productId: productId, quantity: quantity, reason: reason);
      await _reload();
    } catch (e) {
      emit(InventoryError(e.toString()));
    }
  }

  Future<void> adjustStock(int productId, int newQuantity, {String? reason}) async {
    try {
      await repository.adjustStock(productId: productId, newQuantity: newQuantity, reason: reason);
      await _reload();
    } catch (e) {
      emit(InventoryError(e.toString()));
    }
  }

  Future<void> updateMinimumStock(int productId, int minimumStock) async {
    try {
      await repository.updateMinimumStock(productId: productId, minimumStock: minimumStock);
      await _reload();
    } catch (e) {
      emit(InventoryError(e.toString()));
    }
  }

  Future<void> loadMovements({int? productId}) async {
    emit(InventoryLoading());
    try {
      final movements = await repository.getMovements(productId: productId);
      final products = await repository.getInventoryProducts();
      final summary = await repository.getInventorySummary();
      emit(InventoryLoaded(
        products: products,
        movements: movements,
        summary: summary,
      ));
    } catch (e) {
      emit(InventoryError('??? ????? ????? ??? ???????: ${e.toString()}'));
    }
  }

  Future<void> _reload() async {
    final current = state;
    try {
      final products = await repository.getInventoryProducts();
      final summary = await repository.getInventorySummary();
      if (current is InventoryLoaded) {
        emit(current.copyWith(
          products: products,
          summary: summary,
        ));
      } else {
        emit(InventoryLoaded(products: products, summary: summary));
      }
    } catch (e) {
      emit(InventoryError(e.toString()));
    }
  }
}
