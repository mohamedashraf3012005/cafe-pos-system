import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:window_manager/window_manager.dart';
import 'core/constants/app_colors.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/pages/splash_page.dart';
import 'injection_container.dart' as di;

/// Allows SSL network calls on Windows Desktop when behind local proxies/antivirus.
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Bypasses SSL certificate verification errors caused by Windows OS / Antivirus SSL inspection
  HttpOverrides.global = MyHttpOverrides();

  // Initialize Desktop Window Manager (only on Desktop)
  if (!kIsWeb) {
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = const WindowOptions(
      size: Size(1280, 720),
      minimumSize: Size(1024, 600),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
      title: 'نظام الكاشير',
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  // Inject dependencies
  await di.init();

  runApp(const CafePosApp());
}

class CafePosApp extends StatelessWidget {
  const CafePosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<AuthCubit>()),
      ],
      child: MaterialApp(
        title: 'نظام الكاشير',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.dark,
          ),
          scaffoldBackgroundColor: AppColors.background,
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.surface,
            elevation: 0,
            centerTitle: true,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            ),
          ),
        ),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('ar', 'AE'), // Arabic
          Locale('en', 'US'), // English
        ],
        locale: const Locale('ar', 'AE'), // Default to Arabic
        home: const SplashPage(),
      ),
    );
  }
}
