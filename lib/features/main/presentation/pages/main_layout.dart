import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../tables/presentation/pages/tables_page.dart';
import '../../../products/presentation/pages/product_management_page.dart';
import '../../../orders/presentation/pages/order_details_page.dart';
import '../../../reports/presentation/pages/daily_report_page.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  // Pages indexed: 0=Tables, 1=Takeaway, 2=ProductMgmt, 3=DailyReport(manager only)
  final List<Widget> _pages = [
    const TablesPage(),
    const OrderDetailsPage(isTakeaway: true),
    const ProductManagementPage(),
    const DailyReportPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
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
                // ── Sidebar Navigation ─────────────────────────────────────
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
                            fontWeight: FontWeight.bold),
                      ),
                      if (isManager) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'مدير النظام',
                            style: TextStyle(
                                color: AppColors.secondary, fontSize: 12),
                          ),
                        ),
                      ],
                      const SizedBox(height: 32),
                      _buildNavItem(Icons.table_restaurant, 'الطاولات', 0),
                      _buildNavItem(Icons.takeout_dining, 'طلبات تيك اواى', 1),
                      _buildNavItem(Icons.inventory_2_rounded, 'إدارة الأصناف', 2),
                      // Task 6: Only visible to manager
                      if (isManager)
                        _buildNavItem(
                            Icons.bar_chart_rounded, 'تقرير اليومية', 3),
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

                // ── Main Content Area ──────────────────────────────────────
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
    );
  }

  Widget _buildNavItem(IconData icon, String title, int index,
      {VoidCallback? onTap}) {
    bool isSelected = _selectedIndex == index;
    return InkWell(
      onTap: onTap ??
          () {
            setState(() {
              _selectedIndex = index;
            });
          },
      child: Container(
        padding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        color:
            isSelected ? AppColors.sidebarItemActive : Colors.transparent,
        child: Row(
          children: [
            Icon(icon,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textSecondary),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                color: isSelected
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
                fontSize: 16,
                fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
