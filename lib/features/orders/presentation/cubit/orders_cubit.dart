import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/order_repository.dart';
import 'orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  final OrderRepository repository;

  OrdersCubit(this.repository) : super(OrdersInitial());

  Future<void> initForTable(int? tableId, {String orderType = 'dine_in'}) async {
    emit(OrdersLoading());
    try {
      final categories = await repository.getCategories();
      final products = await repository.getProducts();
      final order = await repository.getActiveOrderForTable(tableId, orderType: orderType);
      emit(OrdersLoaded(
        availableProducts: products,
        categories: categories,
        activeOrder: order,
        selectedCategoryId: categories.isNotEmpty ? categories.first.id : null,
      ));
    } catch (e) {
      emit(OrdersError(e.toString()));
    }
  }

  void selectCategory(int? categoryId) {
    final currentState = state;
    if (currentState is OrdersLoaded) {
      emit(OrdersLoaded(
        activeOrder: currentState.activeOrder,
        categories: currentState.categories,
        availableProducts: currentState.availableProducts,
        selectedCategoryId: categoryId,
      ));
    }
  }

  Future<void> addProductToOrder(int? tableId, ProductEntity product, int quantity,
      {String orderType = 'dine_in'}) async {
    final currentState = state;
    if (currentState is OrdersLoaded) {
      try {
        await repository.addItemToOrder(tableId, product, quantity, orderType: orderType);
        final updatedOrder =
            await repository.getActiveOrderForTable(tableId, orderType: orderType);
        emit(currentState.copyWith(activeOrder: updatedOrder));
      } catch (e) {
        emit(OrdersError(e.toString()));
      }
    }
  }

  Future<void> updateQuantity(int? tableId, int orderItemId, int quantity,
      {String orderType = 'dine_in'}) async {
    final currentState = state;
    if (currentState is OrdersLoaded) {
      try {
        await repository.updateOrderItemQuantity(orderItemId, quantity);
        final updatedOrder =
            await repository.getActiveOrderForTable(tableId, orderType: orderType);
        emit(currentState.copyWith(activeOrder: updatedOrder));
      } catch (e) {
        emit(OrdersError(e.toString()));
      }
    }
  }

  Future<void> removeItem(int? tableId, int orderItemId,
      {String orderType = 'dine_in'}) async {
    final currentState = state;
    if (currentState is OrdersLoaded) {
      try {
        await repository.removeItemFromOrder(orderItemId);
        final updatedOrder =
            await repository.getActiveOrderForTable(tableId, orderType: orderType);
        emit(currentState.copyWith(activeOrder: updatedOrder));
      } catch (e) {
        emit(OrdersError(e.toString()));
      }
    }
  }

  // Task 4: Cancel table — deletes all items/orders and frees the table
  Future<bool> cancelTable(int tableId) async {
    try {
      await repository.cancelTableOrder(tableId);
      return true;
    } catch (e) {
      emit(OrdersError(e.toString()));
      return false;
    }
  }
}
