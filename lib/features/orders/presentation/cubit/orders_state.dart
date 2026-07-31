import 'package:equatable/equatable.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/entities/category_entity.dart';

abstract class OrdersState extends Equatable {
  const OrdersState();

  @override
  List<Object?> get props => [];
}

class OrdersInitial extends OrdersState {}

class OrdersLoading extends OrdersState {}

class OrdersLoaded extends OrdersState {
  final OrderEntity? activeOrder;
  final List<CategoryEntity> categories;
  final List<ProductEntity> availableProducts;
  final int? selectedCategoryId;

  const OrdersLoaded({
    this.activeOrder,
    required this.categories,
    required this.availableProducts,
    this.selectedCategoryId,
  });

  OrdersLoaded copyWith({
    OrderEntity? activeOrder,
    List<CategoryEntity>? categories,
    List<ProductEntity>? availableProducts,
    int? selectedCategoryId,
  }) {
    return OrdersLoaded(
      activeOrder: activeOrder ?? this.activeOrder,
      categories: categories ?? this.categories,
      availableProducts: availableProducts ?? this.availableProducts,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
    );
  }

  @override
  List<Object?> get props => [activeOrder, categories, availableProducts, selectedCategoryId];
}

class OrdersError extends OrdersState {
  final String message;
  const OrdersError(this.message);

  @override
  List<Object?> get props => [message];
}
