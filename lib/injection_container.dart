import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
import 'features/reports/domain/repositories/daily_report_repository.dart';
import 'features/reports/data/repositories/daily_report_repository_impl.dart';
import 'features/reports/presentation/cubit/daily_report_cubit.dart';
import 'core/services/printer_service.dart';
import 'core/services/order_number_service.dart';
import 'core/services/audit_log_service.dart';
import 'core/database/app_database.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Shared Preferences (for non-sensitive data like order counter)
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => prefs);

  // Task 1 & 2: Secure Storage — replaces SharedPreferences for sensitive session data
  const secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    wOptions: WindowsOptions(),
  );
  sl.registerLazySingleton<FlutterSecureStorage>(() => secureStorage);

  // Database setup
  sl.registerLazySingleton(() => AppDatabase());

  // Services
  sl.registerLazySingleton(() => OrderNumberService(sl()));
  sl.registerLazySingleton(() => PrinterService());
  sl.registerLazySingleton(() => AuditLogService());

  // Features - Auth
  sl.registerFactory(() => AuthCubit(sl()));

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
  sl.registerFactory(() => CheckoutCubit(
        printerService: sl(),
        tableRepository: sl(),
        orderRepository: sl(),
        orderNumberService: sl(),
        db: sl(),
      ));

  // Features - Daily Report (Task 6)
  sl.registerLazySingleton<DailyReportRepository>(() => DailyReportRepositoryImpl(sl()));
  sl.registerFactory(() => DailyReportCubit(sl()));
}
