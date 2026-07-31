import 'package:get_it/get_it.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/tables/presentation/cubit/tables_cubit.dart';
import 'features/tables/domain/repositories/table_repository.dart';
import 'features/tables/data/repositories/table_repository_impl.dart';
import 'features/orders/presentation/cubit/orders_cubit.dart';
import 'features/orders/domain/repositories/order_repository.dart';
import 'features/orders/data/repositories/order_repository_impl.dart';
import 'features/checkout/presentation/cubit/checkout_cubit.dart';
import 'features/products/domain/repositories/product_repository.dart';
import 'features/products/data/repositories/product_repository_impl.dart';
import 'features/products/presentation/cubit/product_management_cubit.dart';
import 'core/services/printer_service.dart';
import 'core/services/order_number_service.dart';
import 'core/database/app_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Shared Preferences
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => prefs);

  // Database setup
  sl.registerLazySingleton(() => AppDatabase());

  // Services
  sl.registerLazySingleton(() => OrderNumberService(sl()));

  // Features - Auth
  // Cubit
  sl.registerFactory(() => AuthCubit());

  // Features - Tables
  sl.registerFactory(() => TablesCubit(sl()));
  sl.registerLazySingleton<TableRepository>(() => TableRepositoryImpl(sl()));

  // Features - Orders
  sl.registerFactory(() => OrdersCubit(sl()));
  sl.registerLazySingleton<OrderRepository>(() => OrderRepositoryImpl(sl()));

  // Features - Products Management
  sl.registerLazySingleton<ProductRepository>(() => ProductRepositoryImpl(sl()));
  sl.registerFactory(() => ProductManagementCubit(sl()));

  // Features - Checkout & Printing
  sl.registerLazySingleton(() => PrinterService());
  sl.registerFactory(() => CheckoutCubit(printerService: sl(), tableRepository: sl(), orderRepository: sl(), orderNumberService: sl()));
}
