import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cash_cafe/core/constants/app_colors.dart';
import 'package:cash_cafe/injection_container.dart' as di;
import 'package:cash_cafe/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:cash_cafe/features/auth/presentation/cubit/auth_state.dart';
import 'package:cash_cafe/features/auth/presentation/pages/login_page.dart';
import 'package:cash_cafe/features/inventory/presentation/pages/inventory_page.dart';
import 'package:cash_cafe/features/orders/presentation/pages/order_details_page.dart';
import 'package:cash_cafe/features/playstation/presentation/pages/playstation_settings_page.dart';
import 'package:cash_cafe/features/products/presentation/pages/product_management_page.dart';
import 'package:cash_cafe/features/reports/presentation/pages/daily_report_page.dart';
import 'package:cash_cafe/features/tables/presentation/pages/tables_page.dart';
import 'package:cash_cafe/features/telegram/presentation/cubit/telegram_cubit.dart';
import 'package:cash_cafe/features/telegram/presentation/cubit/telegram_state.dart';
import 'package:cash_cafe/features/telegram/presentation/pages/telegram_settings_page.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const TablesPage(),
    const OrderDetailsPage(isTakeaway: true),
    const ProductManagementPage(),
    const InventoryPage(),
    const PlayStationSettingsPage(),
    const DailyReportPage(),
    const TelegramSettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<TelegramCubit>()..init(),
      child: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
            );
          }
        },
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, authState) {
            final isManager = authState is AuthAuthenticated && authState.isManager;
            return Scaffold(
              body: Row(
                children: [
                  Container(
                    width: 250,
                    color: AppColors.sidebarBg,
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        const Icon(Icons.coffee, size: 60, color: AppColors.primary),
                        const SizedBox(height: 10),
                        const Text(
                          'نظام الكاشير',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (isManager) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withAlpha(51),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'مدير النظام',
                              style: TextStyle(color: AppColors.secondary, fontSize: 12),
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),

                        // Connectivity Indicator
                        BlocBuilder<TelegramCubit, TelegramState>(
                          builder: (context, tgState) {
                            final isOnline = tgState is TelegramStatusLoaded ? tgState.isOnline : false;

                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: (isOnline ? AppColors.tableFree : AppColors.error).withAlpha(38),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: (isOnline ? AppColors.tableFree : AppColors.error).withAlpha(102),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: isOnline ? AppColors.tableFree : AppColors.error,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    isOnline ? 'متصل بالإنترنت' : 'غير متصل (Offline)',
                                    style: TextStyle(
                                      color: isOnline ? AppColors.tableFree : AppColors.error,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 24),
                        _buildNavItem(Icons.table_restaurant, 'الطاولات', 0),
                        _buildNavItem(Icons.takeout_dining, 'طلبات تيك اواى', 1),
                        _buildNavItem(Icons.category_rounded, 'إدارة الأصناف', 2),
                        _buildNavItem(Icons.inventory_2_rounded, 'المخزون', 3),
                        _buildNavItem(Icons.sports_esports, 'أجهزة PlayStation', 4),
                        if (isManager) ...[
                          _buildNavItem(Icons.bar_chart_rounded, 'تقفيل الوردية والتقرير', 5),
                          _buildNavItem(Icons.send_rounded, 'إعدادات Telegram', 6),
                        ],
                        const Spacer(),
                        _buildNavItem(
                          Icons.logout,
                          'تسجيل خروج',
                          -1,
                          onTap: () {
                            context.read<AuthCubit>().logout();
                          },
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),

                  Expanded(
                    child: Container(
                      color: AppColors.background,
                      child: _pages[_selectedIndex.clamp(0, _pages.length - 1)],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String title, int index, {VoidCallback? onTap}) {
    bool isSelected = _selectedIndex == index;
    return InkWell(
      onTap: onTap ??
          () {
            setState(() {
              _selectedIndex = index;
            });
          },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        color: isSelected ? AppColors.sidebarItemActive : Colors.transparent,
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppColors.primary : AppColors.textSecondary, size: 20),
            const SizedBox(width: 14),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}