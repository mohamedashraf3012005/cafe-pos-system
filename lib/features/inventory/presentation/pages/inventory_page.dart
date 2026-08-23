import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cash_cafe/core/constants/app_colors.dart';
import 'package:cash_cafe/injection_container.dart' as di;
import 'package:cash_cafe/features/inventory/domain/entities/inventory_product_entity.dart';
import 'package:cash_cafe/features/inventory/presentation/cubit/inventory_cubit.dart';
import 'package:cash_cafe/features/inventory/presentation/cubit/inventory_state.dart';
import 'package:cash_cafe/features/inventory/presentation/pages/inventory_movement_page.dart';

class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<InventoryCubit>()..loadInventory(),
      child: const _InventoryView(),
    );
  }
}

class _InventoryView extends StatefulWidget {
  const _InventoryView();

  @override
  State<_InventoryView> createState() => _InventoryViewState();
}

class _InventoryViewState extends State<_InventoryView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showAddStockDialog(BuildContext context, InventoryProductEntity product) async {
    final qtyController = TextEditingController();
    final reasonController = TextEditingController(text: 'شراء / توريد جديد');

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('إضافة كمية: ${product.name}', style: const TextStyle(color: Colors.white, fontSize: 18)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('المخزون الحالي: ${product.stockQuantity} قطعة',
                  style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: qtyController,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'الكمية المضافة',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.add_shopping_cart),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'ملاحظات / السبب',
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('إلغاء', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.tableFree),
              onPressed: () {
                final qty = int.tryParse(qtyController.text.trim());
                if (qty != null && qty > 0) {
                  Navigator.pop(ctx, true);
                }
              },
              child: const Text('تأكيد الإضافة'),
            ),
          ],
        );
      },
    );

    if (result == true && context.mounted) {
      final qty = int.parse(qtyController.text.trim());
      context.read<InventoryCubit>().addStock(product.id, qty, reason: reasonController.text.trim());
    }
  }

  Future<void> _showRemoveStockDialog(BuildContext context, InventoryProductEntity product) async {
    final qtyController = TextEditingController();
    String selectedReason = 'تالف';
    final List<String> reasons = ['تالف', 'استخدام داخلي', 'فقد', 'تصحيح مخزون', 'أخرى'];

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text('سحب يدوي من المخزون: ${product.name}', style: const TextStyle(color: Colors.white, fontSize: 18)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('المخزون الحالي: ${product.stockQuantity} قطعة',
                      style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: qtyController,
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: 'الكمية المسحوبة',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.remove_shopping_cart),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedReason,
                    dropdownColor: AppColors.surface,
                    decoration: const InputDecoration(
                      labelText: 'سبب السحب (إجباري)',
                      border: OutlineInputBorder(),
                    ),
                    style: const TextStyle(color: Colors.white),
                    items: reasons.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => selectedReason = val);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('إلغاء', style: TextStyle(color: AppColors.textSecondary)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                  onPressed: () {
                    final qty = int.tryParse(qtyController.text.trim());
                    if (qty != null && qty > 0) {
                      Navigator.pop(ctx, true);
                    }
                  },
                  child: const Text('تأكيد السحب'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == true && context.mounted) {
      final qty = int.parse(qtyController.text.trim());
      context.read<InventoryCubit>().removeStock(product.id, qty, selectedReason);
    }
  }

  Future<void> _showAdjustStockDialog(BuildContext context, InventoryProductEntity product) async {
    final qtyController = TextEditingController(text: product.stockQuantity.toString());
    final minController = TextEditingController(text: product.minimumStock.toString());

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('تعديل مخزون: ${product.name}', style: const TextStyle(color: Colors.white, fontSize: 18)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: qtyController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'الكمية الفعلية الجديدة',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.inventory),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: minController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'الحد الأدنى للتنبيه',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.warning_amber_rounded),
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('إلغاء', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () {
                final qty = int.tryParse(qtyController.text.trim());
                final min = int.tryParse(minController.text.trim());
                if (qty != null && qty >= 0 && min != null && min >= 0) {
                  Navigator.pop(ctx, true);
                }
              },
              child: const Text('حفظ التعديلات'),
            ),
          ],
        );
      },
    );

    if (result == true && context.mounted) {
      final newQty = int.parse(qtyController.text.trim());
      final newMin = int.parse(minController.text.trim());
      final cubit = context.read<InventoryCubit>();
      await cubit.adjustStock(product.id, newQty, reason: 'جرد وتصحيح يدوي');
      await cubit.updateMinimumStock(product.id, newMin);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة المخزون'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'سجل حركات المخزون',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const InventoryMovementPage()),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<InventoryCubit, InventoryState>(
        listener: (context, state) {
          if (state is InventoryError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
            );
          }
        },
        builder: (context, state) {
          if (state is InventoryLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is InventoryLoaded) {
            final summary = state.summary;
            final filtered = state.filteredProducts;

            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildKpiCard('إجمالي المنتجات', '${summary['totalProducts'] ?? 0}', Icons.inventory_2, Colors.blueAccent),
                      const SizedBox(width: 12),
                      _buildKpiCard('متوفر بالكامل', '${summary['inStock'] ?? 0}', Icons.check_circle_outline, AppColors.tableFree),
                      const SizedBox(width: 12),
                      _buildKpiCard('مخزون منخفض', '${summary['lowStock'] ?? 0}', Icons.warning_amber_rounded, Colors.orangeAccent),
                      const SizedBox(width: 12),
                      _buildKpiCard('نفد المخزون', '${summary['outOfStock'] ?? 0}', Icons.cancel_outlined, AppColors.error),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'بحث باسم المنتج أو الفئة...',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchController.clear();
                                      context.read<InventoryCubit>().search('');
                                    },
                                  )
                                : null,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            filled: true,
                            fillColor: AppColors.surface,
                          ),
                          onChanged: (val) => context.read<InventoryCubit>().search(val),
                        ),
                      ),
                      const SizedBox(width: 16),

                      _buildFilterChip(context, 'الكل', state.filterStatus == null, () {
                        context.read<InventoryCubit>().filterByStatus(null);
                      }),
                      const SizedBox(width: 8),
                      _buildFilterChip(context, '🟢 متوفر', state.filterStatus == StockStatus.inStock, () {
                        context.read<InventoryCubit>().filterByStatus(StockStatus.inStock);
                      }),
                      const SizedBox(width: 8),
                      _buildFilterChip(context, '⚠️ منخفض', state.filterStatus == StockStatus.lowStock, () {
                        context.read<InventoryCubit>().filterByStatus(StockStatus.lowStock);
                      }),
                      const SizedBox(width: 8),
                      _buildFilterChip(context, '🔴 نفد', state.filterStatus == StockStatus.outOfStock, () {
                        context.read<InventoryCubit>().filterByStatus(StockStatus.outOfStock);
                      }),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Expanded(
                    child: filtered.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search_off, size: 64, color: Colors.white24),
                                SizedBox(height: 16),
                                Text('لا توجد منتجات تطابق البحث', style: TextStyle(color: Colors.white54, fontSize: 16)),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final product = filtered[index];
                              return Card(
                                color: AppColors.surface,
                                margin: const EdgeInsets.only(bottom: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: product.status == StockStatus.outOfStock
                                        ? AppColors.error.withAlpha(128)
                                        : (product.status == StockStatus.lowStock
                                            ? Colors.orangeAccent.withAlpha(128)
                                            : Colors.white12),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: product.status == StockStatus.outOfStock
                                              ? AppColors.error.withAlpha(38)
                                              : (product.status == StockStatus.lowStock
                                                  ? Colors.orangeAccent.withAlpha(38)
                                                  : AppColors.tableFree.withAlpha(38)),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          product.statusLabel,
                                          style: TextStyle(
                                            color: product.status == StockStatus.outOfStock
                                                ? AppColors.error
                                                : (product.status == StockStatus.lowStock
                                                    ? Colors.orangeAccent
                                                    : AppColors.tableFree),
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),

                                      Expanded(
                                        flex: 3,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              product.name,
                                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'الفئة: ${product.categoryName} • السعر: ${product.price.toStringAsFixed(2)} ج.م',
                                              style: const TextStyle(color: Colors.white54, fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ),

                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              'المتاح: ${product.stockQuantity} قطعة',
                                              style: TextStyle(
                                                color: product.stockQuantity == 0 ? AppColors.error : Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'الحد الأدنى: ${product.minimumStock}',
                                              style: const TextStyle(color: Colors.white38, fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ),

                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ElevatedButton.icon(
                                            icon: const Icon(Icons.add, size: 16),
                                            label: const Text('إضافة', style: TextStyle(fontSize: 12)),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.tableFree,
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                            ),
                                            onPressed: () => _showAddStockDialog(context, product),
                                          ),
                                          const SizedBox(width: 8),
                                          OutlinedButton.icon(
                                            icon: const Icon(Icons.remove, size: 16, color: AppColors.error),
                                            label: const Text('سحب', style: TextStyle(color: AppColors.error, fontSize: 12)),
                                            style: OutlinedButton.styleFrom(
                                              side: const BorderSide(color: AppColors.error),
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                            ),
                                            onPressed: () => _showRemoveStockDialog(context, product),
                                          ),
                                          const SizedBox(width: 8),
                                          IconButton(
                                            icon: const Icon(Icons.tune, color: Colors.white70),
                                            tooltip: 'تعديل المخزون والحد الأدنى',
                                            onPressed: () => _showAdjustStockDialog(context, product),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildKpiCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(77)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withAlpha(38),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 22)),
                  const SizedBox(height: 2),
                  Text(title, style: const TextStyle(color: Colors.white60, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.primary : Colors.white24),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
