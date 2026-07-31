import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/services/printer_service.dart';
import '../../../../core/services/order_number_service.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../../tables/domain/repositories/table_repository.dart';
import '../../../orders/domain/repositories/order_repository.dart';
// Note: Normally we'd use InvoiceRepository to save the invoice. For this demo, we'll update table status.

abstract class CheckoutState extends Equatable {
  const CheckoutState();
  @override
  List<Object> get props => [];
}

class CheckoutInitial extends CheckoutState {}

class CheckoutLoading extends CheckoutState {}

class CheckoutSuccess extends CheckoutState {}

class CheckoutError extends CheckoutState {
  final String message;
  const CheckoutError(this.message);
  @override
  List<Object> get props => [message];
}

class CheckoutCubit extends Cubit<CheckoutState> {
  final PrinterService printerService;
  final TableRepository tableRepository;
  final OrderRepository orderRepository;
  final OrderNumberService orderNumberService;

  CheckoutCubit({
    required this.printerService,
    required this.tableRepository,
    required this.orderRepository,
    required this.orderNumberService,
  }) : super(CheckoutInitial());

  Future<void> processCheckout(OrderEntity order, double serviceChargeRate, double taxRate, double serviceCharge, double tax, double grandTotal, int? tableNumber) async {
    emit(CheckoutLoading());
    try {
      // 1. Get daily order number
      final orderNumber = orderNumberService.getNextOrderNumber();

      // 2. Print receipt
      // If printing fails, it will catch the error, and the table and order will NOT be closed, avoiding data wipe!
      await printerService.printReceipt(order, serviceChargeRate, taxRate, serviceCharge, tax, grandTotal, tableNumber, orderNumber);

      // 2. Free up the table
      if (order.tableId != null) {
        await tableRepository.updateTableStatus(order.tableId!, 'free');
      }

      // 3. Mark the order as completed so it clears from UI
      await orderRepository.updateOrderStatus(order.id, 'completed');

      emit(CheckoutSuccess());
    } catch (e) {
      emit(CheckoutError(e.toString()));
    }
  }
}
