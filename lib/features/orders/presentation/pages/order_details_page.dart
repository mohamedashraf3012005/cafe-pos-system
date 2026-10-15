import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cash_cafe/core/constants/app_colors.dart';
import 'package:cash_cafe/core/services/printer_service.dart';
import 'package:cash_cafe/core/services/audit_log_service.dart';
import 'package:cash_cafe/core/widgets/admin_password_dialog.dart';
import 'package:cash_cafe/injection_container.dart' as di;
import 'package:cash_cafe/features/playstation/presentation/cubit/playstation_cubit.dart';
import 'package:cash_cafe/features/playstation/presentation/widgets/playstation_timer_widget.dart';
import 'package:cash_cafe/features/orders/domain/entities/product_entity.dart';
import 'package:cash_cafe/features/orders/presentation/cubit/orders_cubit.dart';
import 'package:cash_cafe/features/orders/presentation/cubit/orders_state.dart';
import 'package:cash_cafe/features/checkout/presentation/pages/checkout_page.dart';

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
      Navigator.pop(context);
    }
  }

  Future<void> _handleDecreaseItemQuantity(BuildContext context, dynamic item) async {
    final result = await showAdminPasswordDialog(
      context,
      title: 'تأكيد إنقاص/حذف صنف',
      description: 'أدخل رمز المرور للموافقة على إنقاص كمية "${item.productName}".',
      showReasonField: false,
    );

    if (result == null || !result.authenticated) return;
    if (!context.mounted) return;

    final auditService = di.sl<AuditLogService>();
    await auditService.log(
      username: 'مدير النظام',
      actionType: 'decrease_order_item',
      target: '${item.productName} (${item.quantity} -> ${item.quantity - 1})',
      reason: result.reason.isNotEmpty ? result.reason : 'إنقاص كمية صنف من الطلب',
    );

    if (!context.mounted) return;
    context.read<OrdersCubit>().updateQuantity(
          widget.tableId,
          item.id,
          item.quantity - 1,
          orderType: widget.isTakeaway ? 'takeaway' : 'dine_in',
        );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => di.sl<OrdersCubit>()
            ..initForTable(widget.tableId,
                orderType: widget.isTakeaway ? 'takeaway' : 'dine_in'),
        ),
        BlocProvider(
          create: (context) => di.sl<PlayStationCubit>()
            ..initForTable(widget.tableId),
        ),
      ],
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
              final hasItemsOrPlaystation = state.activeOrder != null &&
                  (state.activeOrder!.items.isNotEmpty ||
                      state.activeOrder!.playStationCost > 0);

              return Row(
                children: [
                  // Left: Menu
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
                                childAspectRatio: 0.85,
                              ),
                              itemCount: _getFilteredProducts(state).length,
                              itemBuilder: (context, index) {
                                final product =
                                    _getFilteredProducts(state)[index];
                                return _buildProductCard(context, product, state);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Right: Cart
                  Container(
                    width: 420,
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
                        const SizedBox(height: 12),

                        // PlayStation Live Timer
                        PlayStationTimerWidget(
                          tableId: widget.tableId,
                          tableNumber: widget.tableNumber,
                          onSessionStopped: (completed) {
                            context.read<OrdersCubit>().setPlayStationCost(
                                  completed.calculatedAmount,
                                  '${completed.deviceName} (${completed.humanDuration})',
                                  completed.id,
                                  tableId: widget.tableId,
                                  orderType: widget.isTakeaway ? 'takeaway' : 'dine_in',
                                );
                          },
                        ),
                        const SizedBox(height: 12),
                        const Divider(color: Colors.white24, height: 16),

                        Expanded(
                          child: (state.activeOrder == null ||
                                  (state.activeOrder!.items.isEmpty &&
                                      state.activeOrder!.playStationCost <= 0))
                              ? const Center(
                                  child: Text('لا توجد أصناف بعد',
                                      style:
                                          TextStyle(color: Colors.white54)))
                              : ListView(
                                  children: [
                                    ...state.activeOrder!.items.map((item) {
                                      return _buildOrderItem(context, item, state.availableProducts);
                                    }),
                                    if (state.activeOrder!.playStationCost > 0)
                                      _buildPlayStationOrderItem(
                                        context,
                                        state.activeOrder!.playStationDescription ?? 'PlayStation',
                                        state.activeOrder!.playStationCost,
                                      ),
                                  ],
                                ),
                        ),
                        const Divider(color: Colors.white24, height: 32),

                        if (state.activeOrder != null && state.activeOrder!.playStationCost > 0) ...[
                          _buildSummaryRow(
                            'المشروبات والأطعمة',
                            '${state.activeOrder?.itemsSubtotal.toStringAsFixed(2) ?? "0.00"} ج.م',
                          ),
                          const SizedBox(height: 6),
                          _buildSummaryRow(
                            'تكلفة البلايستيشن',
                            '${state.activeOrder?.playStationCost.toStringAsFixed(2) ?? "0.00"} ج.م',
                          ),
                          const SizedBox(height: 6),
                        ],

                        _buildSummaryRow(
                          'المجموع الفرعي',
                          '${state.activeOrder?.subtotal.toStringAsFixed(2) ?? "0.00"} ج.م',
                        ),
                        const SizedBox(height: 16),

                        if (state.activeOrder != null && state.activeOrder!.items.isNotEmpty) ...[
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
                              onPressed: () => _printKitchen(context, state),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],

                        // Checkout Button
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            onPressed: hasItemsOrPlaystation
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

  Widget _buildProductCard(BuildContext context, ProductEntity product, OrdersLoaded state) {
    final isOutOfStock = product.isOutOfStock;
    final isLowStock = product.isLowStock;

    return InkWell(
      onTap: () {
        if (isOutOfStock) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('الكمية غير متوفرة في المخزون للمنتج "${product.name}". المتاح حاليًا: 0'),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 2),
            ),
          );
          return;
        }

        final existingItem = state.activeOrder?.items
            .where((i) => i.productId == product.id)
            .firstOrNull;
        if (product.trackInventory && existingItem != null && existingItem.quantity >= product.stockQuantity) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('الكمية غير متوفرة في المخزون. المتاح حاليًا: ${product.stockQuantity}'),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 2),
            ),
          );
          return;
        }

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
          color: isOutOfStock ? AppColors.surface.withAlpha(128) : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isOutOfStock
                ? AppColors.error.withAlpha(128)
                : (isLowStock ? Colors.orangeAccent.withAlpha(128) : Colors.white12),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isOutOfStock)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.error.withAlpha(51),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('🔴 نفد المخزون', style: TextStyle(color: AppColors.error, fontSize: 10, fontWeight: FontWeight.bold)),
                )
              else if (isLowStock)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orangeAccent.withAlpha(51),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('⚠️ منخفض (${product.stockQuantity})', style: const TextStyle(color: Colors.orangeAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                )
              else if (product.trackInventory)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('المتاح: ${product.stockQuantity}', style: const TextStyle(color: Colors.white60, fontSize: 10)),
                ),
              const SizedBox(height: 6),
              const Icon(Icons.fastfood, size: 30, color: AppColors.primary),
              const SizedBox(height: 6),
              Expanded(
                child: Center(
                  child: Text(
                    product.name,
                    style: TextStyle(
                        color: isOutOfStock ? Colors.white54 : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${product.price.toStringAsFixed(2)} ج.م',
                style: const TextStyle(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderItem(BuildContext context, dynamic item, List<ProductEntity> products) {
    final product = products.where((p) => p.id == item.productId).firstOrNull;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
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
                    color: AppColors.error, size: 20),
                onPressed: () => _handleDecreaseItemQuantity(context, item),
              ),
              Text('${item.quantity}',
                  style: const TextStyle(color: Colors.white, fontSize: 16)),
              IconButton(
                icon: const Icon(Icons.add_circle_outline,
                    color: AppColors.tableFree, size: 20),
                onPressed: () {
                  if (product != null && product.trackInventory && item.quantity >= product.stockQuantity) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('الكمية غير متوفرة في المخزون. المتاح حاليًا: ${product.stockQuantity}'),
                        backgroundColor: AppColors.error,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                    return;
                  }

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

  Widget _buildPlayStationOrderItem(BuildContext context, String description, double cost) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A237E).withAlpha(77),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blueAccent.withAlpha(102)),
      ),
      child: Row(
        children: [
          const Icon(Icons.sports_esports, color: Colors.lightBlueAccent, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🎮 $description',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const Text('جلسة بلايستيشن', style: TextStyle(color: Colors.white54, fontSize: 11)),
              ],
            ),
          ),
          Text(
            '${cost.toStringAsFixed(2)} ج.م',
            style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(color: Colors.white54, fontSize: 16)),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _ScrollArrow extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ScrollArrow({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withAlpha(20),
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