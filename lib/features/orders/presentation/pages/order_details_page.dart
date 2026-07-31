import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/printer_service.dart';
import '../../../../core/services/audit_log_service.dart';
import '../../../../core/widgets/admin_password_dialog.dart';
import '../../../../injection_container.dart' as di;
import '../../domain/entities/product_entity.dart';
import '../cubit/orders_cubit.dart';
import '../cubit/orders_state.dart';
import '../../../checkout/presentation/pages/checkout_page.dart';

class OrderDetailsPage extends StatefulWidget {
  final int? tableId;
  final int? tableNumber;
  final bool isTakeaway;

  const OrderDetailsPage({
    super.key,
    this.tableId,
    this.tableNumber,
    this.isTakeaway = false,
  });

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  final ScrollController _categoryScrollController = ScrollController();

  @override
  void dispose() {
    _categoryScrollController.dispose();
    super.dispose();
  }

  void _scrollLeft() {
    _categoryScrollController.animateTo(
      (_categoryScrollController.offset - 200)
          .clamp(0.0, _categoryScrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _scrollRight() {
    _categoryScrollController.animateTo(
      (_categoryScrollController.offset + 200)
          .clamp(0.0, _categoryScrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  List<ProductEntity> _getFilteredProducts(OrdersLoaded state) {
    if (state.selectedCategoryId == null) return state.availableProducts;
    return state.availableProducts
        .where((p) => p.categoryId == state.selectedCategoryId)
        .toList();
  }

  // Task 3: Print kitchen receipt
  Future<void> _printKitchen(BuildContext context, OrdersLoaded state) async {
    if (state.activeOrder == null || state.activeOrder!.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لا توجد أصناف في الطلب للطباعة'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    try {
      final printerService = di.sl<PrinterService>();
      await printerService.printKitchenReceipt(
        state.activeOrder!.items,
        widget.tableNumber,
        widget.isTakeaway ? 'takeaway' : 'dine_in',
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إرسال التذكرة للمطبخ'),
          backgroundColor: AppColors.tableFree,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
      );
    }
  }

  // Task 4 + Admin password protection: Cancel table with admin PIN verification
  Future<void> _cancelTable(BuildContext context) async {
    if (widget.tableId == null) return;

    final result = await showAdminPasswordDialog(
      context,
      title: 'تأكيد إلغاء الطاولة',
      description:
          'سيتم حذف جميع الأصناف الحالية من طاولة ${widget.tableNumber}.\nأدخل رمز المدير للمتابعة.',
      showReasonField: true,
    );

    if (result == null || !result.authenticated) return;
    if (!context.mounted) return;

    final success =
        await context.read<OrdersCubit>().cancelTable(widget.tableId!);
    if (!context.mounted) return;

    if (success) {
      // Log the action
      final auditService = di.sl<AuditLogService>();
      await auditService.log(
        username: 'مدير النظام',
        actionType: 'cancel_table_order',
        target: 'طاولة ${widget.tableNumber}',
        reason: result.reason,
      );

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إلغاء الطاولة بنجاح'),
          backgroundColor: AppColors.tableFree,
        ),
      );
      Navigator.pop(context); // return to tables page
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<OrdersCubit>()
        ..initForTable(widget.tableId,
            orderType: widget.isTakeaway ? 'takeaway' : 'dine_in'),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.isTakeaway
              ? 'طلب تيك أواي'
              : 'طلب طاولة ${widget.tableNumber}'),
          leading: widget.isTakeaway
              ? null
              : IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
          // Task 4: Cancel Table action in AppBar (only for dine_in tables)
          actions: widget.isTakeaway
              ? null
              : [
                  Builder(
                    builder: (innerCtx) => TextButton.icon(
                      icon: const Icon(Icons.cancel, color: AppColors.error),
                      label: const Text(
                        'إلغاء الطاولة',
                        style: TextStyle(color: AppColors.error),
                      ),
                      onPressed: () => _cancelTable(innerCtx),
                    ),
                  ),
                ],
        ),
        body: BlocBuilder<OrdersCubit, OrdersState>(
          builder: (context, state) {
            if (state is OrdersLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is OrdersError) {
              return Center(
                  child: Text(state.message,
                      style: const TextStyle(color: AppColors.error)));
            } else if (state is OrdersLoaded) {
              return Row(
                children: [
                  // ── Left: Menu Products ──────────────────────────────────
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('القائمة',
                              style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 40,
                            child: Row(
                              children: [
                                _ScrollArrow(
                                    icon: Icons.chevron_left_rounded,
                                    onTap: _scrollLeft),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: ListView.builder(
                                    controller: _categoryScrollController,
                                    scrollDirection: Axis.horizontal,
                                    itemCount: state.categories.length + 1,
                                    itemBuilder: (context, index) {
                                      if (index == 0) {
                                        return _buildCategoryChip(context, null,
                                            'الكل', state.selectedCategoryId == null);
                                      }
                                      final cat = state.categories[index - 1];
                                      return _buildCategoryChip(
                                          context,
                                          cat.id,
                                          cat.name,
                                          state.selectedCategoryId == cat.id);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 6),
                                _ScrollArrow(
                                    icon: Icons.chevron_right_rounded,
                                    onTap: _scrollRight),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                                childAspectRatio: 0.9,
                              ),
                              itemCount: _getFilteredProducts(state).length,
                              itemBuilder: (context, index) {
                                final product =
                                    _getFilteredProducts(state)[index];
                                return _buildProductCard(context, product);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Right: Active Cart ───────────────────────────────────
                  Container(
                    width: 400,
                    color: AppColors.surface,
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('الطلب الحالي',
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        const Divider(color: Colors.white24, height: 32),
                        Expanded(
                          child: state.activeOrder == null ||
                                  state.activeOrder!.items.isEmpty
                              ? const Center(
                                  child: Text('لا توجد أصناف بعد',
                                      style:
                                          TextStyle(color: Colors.white54)))
                              : ListView.builder(
                                  itemCount: state.activeOrder!.items.length,
                                  itemBuilder: (context, index) {
                                    final item =
                                        state.activeOrder!.items[index];
                                    return _buildOrderItem(context, item);
                                  },
                                ),
                        ),
                        const Divider(color: Colors.white24, height: 32),
                        _buildSummaryRow(
                          'المجموع الفرعي',
                          '${state.activeOrder?.subtotal.toStringAsFixed(2) ?? "0.00"} ج.م',
                        ),
                        const SizedBox(height: 16),

                        // Task 3: Kitchen Print Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.restaurant,
                                color: AppColors.secondary),
                            label: const Text(
                              'طباعة للمطبخ',
                              style: TextStyle(
                                  color: AppColors.secondary, fontSize: 16),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                  color: AppColors.secondary, width: 1.5),
                            ),
                            onPressed: state.activeOrder != null &&
                                    state.activeOrder!.items.isNotEmpty
                                ? () => _printKitchen(context, state)
                                : null,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Checkout Button
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            onPressed: state.activeOrder != null &&
                                    state.activeOrder!.items.isNotEmpty
                                ? () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => CheckoutPage(
                                          order: state.activeOrder!,
                                          tableNumber: widget.tableNumber,
                                        ),
                                      ),
                                    ).then((_) {
                                      if (!context.mounted) return;
                                      context.read<OrdersCubit>().initForTable(
                                            widget.tableId,
                                            orderType: widget.isTakeaway
                                                ? 'takeaway'
                                                : 'dine_in',
                                          );
                                    });
                                  }
                                : null,
                            child: const Text('متابعة الدفع',
                                style: TextStyle(fontSize: 18)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildCategoryChip(
      BuildContext context, int? categoryId, String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            context.read<OrdersCubit>().selectCategory(categoryId);
          }
        },
        selectedColor: AppColors.primary,
        backgroundColor: Colors.white12,
        labelStyle:
            TextStyle(color: isSelected ? Colors.black : Colors.white),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, ProductEntity product) {
    return InkWell(
      onTap: () {
        context.read<OrdersCubit>().addProductToOrder(
              widget.tableId,
              product,
              1,
              orderType: widget.isTakeaway ? 'takeaway' : 'dine_in',
            );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.fastfood, size: 36, color: AppColors.primary),
              const SizedBox(height: 8),
              Expanded(
                child: Center(
                  child: Text(
                    product.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${product.price.toStringAsFixed(2)} ج.م',
                style: const TextStyle(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderItem(BuildContext context, dynamic item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.productName,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                Text('${item.unitPrice.toStringAsFixed(2)} ج.م',
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline,
                    color: AppColors.error),
                onPressed: () {
                  context.read<OrdersCubit>().updateQuantity(
                        widget.tableId,
                        item.id,
                        item.quantity - 1,
                        orderType:
                            widget.isTakeaway ? 'takeaway' : 'dine_in',
                      );
                },
              ),
              Text('${item.quantity}',
                  style: const TextStyle(color: Colors.white, fontSize: 16)),
              IconButton(
                icon: const Icon(Icons.add_circle_outline,
                    color: AppColors.tableFree),
                onPressed: () {
                  context.read<OrdersCubit>().updateQuantity(
                        widget.tableId,
                        item.id,
                        item.quantity + 1,
                        orderType:
                            widget.isTakeaway ? 'takeaway' : 'dine_in',
                      );
                },
              ),
            ],
          ),
          const SizedBox(width: 8),
          Text('${item.totalPrice.toStringAsFixed(2)} ج.م',
              style: const TextStyle(
                  color: AppColors.secondary, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(color: Colors.white54, fontSize: 18)),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Scroll Arrow Button
// ─────────────────────────────────────────────────────────────────────────────

class _ScrollArrow extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ScrollArrow({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.08),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          child: Icon(icon, size: 20, color: Colors.white70),
        ),
      ),
    );
  }
}
