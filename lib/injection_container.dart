import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/database/app_database.dart';
import 'core/services/audit_log_service.dart';
import 'core/services/connectivity_service.dart';
import 'core/services/order_number_service.dart';
import 'core/services/printer_service.dart';
import 'core/services/telegram_settings_service.dart';
import 'core/services/whatsapp_queue_processor.dart';
import 'core/services/whatsapp_settings_service.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/checkout/presentation/cubit/checkout_cubit.dart';
import 'features/daily_closing/data/repositories/daily_closing_repository_impl.dart';
import 'features/daily_closing/domain/repositories/daily_closing_repository.dart';
import 'features/daily_closing/presentation/cubit/daily_closing_cubit.dart';
import 'features/orders/data/repositories/order_repository_impl.dart';
import 'features/orders/domain/repositories/order_repository.dart';
import 'features/orders/presentation/cubit/orders_cubit.dart';
import 'features/inventory/data/repositories/inventory_repository_impl.dart';
import 'features/inventory/domain/repositories/inventory_repository.dart';
import 'features/inventory/presentation/cubit/inventory_cubit.dart';
import 'features/playstation/data/repositories/playstation_repository_impl.dart';
import 'features/playstation/domain/repositories/playstation_repository.dart';
import 'features/playstation/presentation/cubit/playstation_cubit.dart';
import 'features/products/data/repositories/product_repository_impl.dart';
import 'features/products/domain/repositories/product_repository.dart';
import 'features/products/presentation/cubit/product_management_cubit.dart';
import 'features/reports/data/repositories/daily_report_repository_impl.dart';
import 'features/reports/domain/repositories/daily_report_repository.dart';
import 'features/reports/presentation/cubit/daily_report_cubit.dart';
import 'features/tables/data/repositories/table_repository_impl.dart';
import 'features/tables/domain/repositories/table_repository.dart';
import 'features/tables/presentation/cubit/tables_cubit.dart';
import 'features/telegram/data/datasources/telegram_remote_datasource.dart';
import 'features/telegram/data/datasources/telegram_remote_datasource_impl.dart';
import 'features/telegram/presentation/cubit/telegram_cubit.dart';
import 'features/whatsapp/data/datasources/whatsapp_remote_datasource.dart';
import 'features/whatsapp/data/datasources/whatsapp_remote_datasource_impl.dart';
import 'features/whatsapp/data/repositories/whatsapp_repository_impl.dart';
import 'features/whatsapp/domain/repositories/whatsapp_repository.dart';
import 'features/whatsapp/presentation/cubit/whatsapp_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ── Core External Services ──────────────────────────────────────────────────
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => prefs);

  const secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    wOptions: WindowsOptions(),
  );
  sl.registerLazySingleton<FlutterSecureStorage>(() => secureStorage);

  // ── Database setup ──────────────────────────────────────────────────────────
  sl.registerLazySingleton(() => AppDatabase());

  // ── Core Services ───────────────────────────────────────────────────────────
  sl.registerLazySingleton(() => OrderNumberService(sl()));
  sl.registerLazySingleton(() => PrinterService());
  sl.registerLazySingleton(() => AuditLogService());
  sl.registerLazySingleton(() => WhatsAppSettingsService(sl()));
  sl.registerLazySingleton(() => TelegramSettingsService(sl()));

  final connectivityService = ConnectivityService();
  await connectivityService.initialize();
  sl.registerLazySingleton<ConnectivityService>(() => connectivityService);

  // ── Telegram & WhatsApp Remote Data Sources ─────────────────────────────────
  sl.registerLazySingleton<WhatsAppRemoteDataSource>(
    () => WhatsAppRemoteDataSourceImpl(settingsService: sl()),
  );

  sl.registerLazySingleton<TelegramRemoteDataSource>(
    () => TelegramRemoteDataSourceImpl(settingsService: sl()),
  );

  sl.registerLazySingleton<WhatsAppRepository>(
    () => WhatsAppRepositoryImpl(sl()),
  );

  // ── Queue Processor ─────────────────────────────────────────────────────────
  final queueProcessor = WhatsAppQueueProcessor(
    connectivityService: sl(),
    whatsappRepository: sl(),
    remoteDataSource: sl(),
    settingsService: sl(),
    telegramRemoteDataSource: sl(),
    telegramSettingsService: sl(),
  );
  queueProcessor.start();
  sl.registerLazySingleton<WhatsAppQueueProcessor>(() => queueProcessor);

  // ── Daily Closing Repository ───────────────────────────────────────────────
  sl.registerLazySingleton<DailyClosingRepository>(
    () => DailyClosingRepositoryImpl(
      db: sl(),
      whatsappRepository: sl(),
    ),
  );

  // ── Features - Auth ─────────────────────────────────────────────────────────
  sl.registerFactory(() => AuthCubit(sl()));

  // ── Features - Tables ───────────────────────────────────────────────────────
  sl.registerFactory(() => TablesCubit(sl()));
  sl.registerLazySingleton<TableRepository>(() => TableRepositoryImpl(sl()));

  // ── Features - Orders ───────────────────────────────────────────────────────
  sl.registerFactory(() => OrdersCubit(sl()));
  sl.registerLazySingleton<OrderRepository>(() => OrderRepositoryImpl(sl()));

  // ── Features - Products Management ─────────────────────────────────────────
  sl.registerLazySingleton<ProductRepository>(() => ProductRepositoryImpl(sl()));
  sl.registerFactory(() => ProductManagementCubit(sl()));

  // ── Features - PlayStation ──────────────────────────────────────────────────
  sl.registerLazySingleton<PlayStationRepository>(() => PlayStationRepositoryImpl(sl()));
  sl.registerFactory(() => PlayStationCubit(sl()));

  // ── Features - Inventory ────────────────────────────────────────────────────
  sl.registerLazySingleton<InventoryRepository>(() => InventoryRepositoryImpl(sl()));
  sl.registerFactory(() => InventoryCubit(sl()));

  // ── Features - Checkout & Printing ─────────────────────────────────────────
  sl.registerFactory(() => CheckoutCubit(
        printerService: sl(),
        tableRepository: sl(),
        orderRepository: sl(),
        orderNumberService: sl(),
        db: sl(),
        whatsappRepository: sl(),
        settingsService: sl(),
        connectivityService: sl(),
        queueProcessor: sl(),
      ));

  // ── Features - Daily Report & Daily Closing ────────────────────────────────
  sl.registerLazySingleton<DailyReportRepository>(() => DailyReportRepositoryImpl(sl()));
  sl.registerFactory(() => DailyReportCubit(sl()));
  sl.registerFactory(() => DailyClosingCubit(
        dailyClosingRepository: sl(),
        settingsService: sl(),
        connectivityService: sl(),
        queueProcessor: sl(),
      ));

  // ── Features - WhatsApp & Telegram ─────────────────────────────────────────
  sl.registerFactory(() => WhatsAppCubit(
        whatsappRepository: sl(),
        remoteDataSource: sl(),
        settingsService: sl(),
        connectivityService: sl(),
        queueProcessor: sl(),
      ));

  sl.registerFactory(() => TelegramCubit(
        remoteDataSource: sl(),
        settingsService: sl(),
        connectivityService: sl(),
      ));
}
