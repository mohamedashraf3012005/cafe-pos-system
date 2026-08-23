import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../injection_container.dart' as di;
import '../../../orders/domain/entities/category_entity.dart';
import '../../../orders/domain/entities/product_entity.dart';
import '../cubit/product_management_cubit.dart';

class ProductManagementPage extends StatelessWidget {
  const ProductManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<ProductManagementCubit>()..loadAll(),
      child: const _ProductManagementView(),
    );
  }
}

class _ProductManagementView extends StatefulWidget {
  const _ProductManagementView();

  @override
  State<_ProductManagementView> createState() => _ProductManagementViewState();
}

class _ProductManagementViewState extends State<_ProductManagementView> {
  final ScrollController _filterScrollController = ScrollController();
  final ScrollController _bottomScrollController = ScrollController();

  @override
  void dispose() {
    _filterScrollController.dispose();
    _bottomScrollController.dispose();
    super.dispose();
  }

  void _scrollLeft(ScrollController controller) {
    controller.animateTo(
      (controller.offset - 200).clamp(0.0, controller.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _scrollRight(ScrollController controller) {
    controller.animateTo(
      (controller.offset + 200).clamp(0.0, controller.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<ProductManagementCubit, ProductManagementState>(
        listener: (context, state) {
          if (state is ProductManagementError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
            );
            context.read<ProductManagementCubit>().loadAll();
          }
        },
        builder: (context, state) {
          if (state is ProductManagementLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          } else if (state is ProductManagementLoaded) {
            return _buildLoadedBody(context, state);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildLoadedBody(BuildContext context, ProductManagementLoaded state) {
    return Column(
      children: [
        // ── Header ──────────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(bottom: BorderSide(color: Colors.white12)),
          ),
          child: Row(
            children: [
              const Icon(Icons.inventory_2_rounded, color: AppColors.primary, size: 32),
              const SizedBox(width: 12),
              const Text(
                'إدارة الأصناف',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const Spacer(),
              _HeaderButton(
                icon: Icons.category_rounded,
                label: 'إضافة فئة',
                color: AppColors.secondary,
                onTap: () => _showCategoryDialog(context),
              ),
              const SizedBox(width: 12),
              _HeaderButton(
                icon: Icons.add_circle_rounded,
                label: 'إضافة صنف',
                color: AppColors.tableFree,
                onTap: () => _showProductDialog(context, state.categories),
              ),
            ],
          ),
        ),

        // ── Category Filter Chips with Arrow Buttons ────────────────────
        Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          color: AppColors.surface.withAlpha(128),
          child: Row(
            children: [
              // Left Arrow
              _ScrollArrow(
                icon: Icons.chevron_left_rounded,
                onTap: () => _scrollLeft(_filterScrollController),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: ListView.builder(
                  controller: _filterScrollController,
                  scrollDirection: Axis.horizontal,
                  itemCount: state.categories.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _buildFilterChip(context, null, 'الكل', state.selectedCategoryId == null);
                    }
                    final cat = state.categories[index - 1];
                    return _buildFilterChip(context, cat.id, cat.name, state.selectedCategoryId == cat.id);
                  },
                ),
              ),
              const SizedBox(width: 4),
              // Right Arrow
              _ScrollArrow(
                icon: Icons.chevron_right_rounded,
                onTap: () => _scrollRight(_filterScrollController),
              ),
            ],
          ),
        ),

        // ── Products Grid ───────────────────────────────────────────────
        Expanded(
          child: state.filteredProducts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.coffee_rounded, size: 80, color: Colors.white.withAlpha(26)),
                      const SizedBox(height: 16),
                      Text('لا توجد أصناف', style: TextStyle(fontSize: 18, color: Colors.white.withAlpha(76))),
                      const SizedBox(height: 8),
                      Text(
                        'اضغط على "إضافة صنف" لإضافة منتج جديد',
                        style: TextStyle(fontSize: 14, color: Colors.white.withAlpha(51)),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(24),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.9,
                    ),
                    itemCount: state.filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = state.filteredProducts[index];
                      final category = state.categories.where((c) => c.id == product.categoryId).firstOrNull;
                      return _ProductCard(
                        product: product,
                        categoryName: category?.name ?? '—',
                        categories: state.categories,
                        onEdit: () => _showProductDialog(context, state.categories, product: product),
                        onDelete: () => _confirmDelete(
                          context,
                          title: 'تأكيد الحذف',
                          message: 'هل تريد حذف "${product.name}"؟',
                          onConfirm: () => context.read<ProductManagementCubit>().deleteProduct(product.id),
                        ),
                      );
                    },
                  ),
                ),
        ),

        // ── Bottom Bar: Categories List with Arrow Buttons ──────────────
        Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: Colors.white12)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              const Icon(Icons.category_rounded, color: AppColors.secondary, size: 20),
              const SizedBox(width: 8),
              const Text('الفئات:', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              // Left Arrow
              _ScrollArrow(
                icon: Icons.chevron_left_rounded,
                onTap: () => _scrollLeft(_bottomScrollController),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: SizedBox(
                  height: 36,
                  child: ListView.builder(
                    controller: _bottomScrollController,
                    scrollDirection: Axis.horizontal,
                    itemCount: state.categories.length,
                    itemBuilder: (context, index) {
                      final cat = state.categories[index];
                      return _CategoryChipEditable(
                        category: cat,
                        onEdit: () => _showCategoryDialog(context, category: cat),
                        onDelete: () => _confirmDelete(
                          context,
                          title: 'تأكيد الحذف',
                          message: 'هل تريد حذف فئة "${cat.name}"؟',
                          onConfirm: () => context.read<ProductManagementCubit>().deleteCategory(cat.id),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 4),
              // Right Arrow
              _ScrollArrow(
                icon: Icons.chevron_right_rounded,
                onTap: () => _scrollRight(_bottomScrollController),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(BuildContext context, int? categoryId, String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Center(
        child: ChoiceChip(
          label: Text(label),
          selected: isSelected,
          onSelected: (selected) {
            context.read<ProductManagementCubit>().selectCategory(selected ? categoryId : null);
          },
          selectedColor: AppColors.primary,
          backgroundColor: Colors.white12,
          labelStyle: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // ── Shared Confirm Delete ─────────────────────────────────────────────────

  void _confirmDelete(BuildContext context, {required String title, required String message, required VoidCallback onConfirm}) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.error),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(color: Colors.white)),
          ],
        ),
        content: Text(message, style: const TextStyle(color: Colors.white70, fontSize: 16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('إلغاء', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              onConfirm();
              Navigator.pop(dialogCtx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── Category Dialog ───────────────────────────────────────────────────────

  void _showCategoryDialog(BuildContext context, {CategoryEntity? category}) {
    final cubit = context.read<ProductManagementCubit>();
    final nameController = TextEditingController(text: category?.name ?? '');
    final isEdit = category != null;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(isEdit ? Icons.edit_rounded : Icons.category_rounded, color: AppColors.secondary),
              const SizedBox(width: 8),
              Text(isEdit ? 'تعديل الفئة' : 'إضافة فئة جديدة', style: const TextStyle(color: Colors.white)),
            ],
          ),
          content: SizedBox(
            width: 400,
            child: TextField(
              controller: nameController,
              autofocus: true,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: InputDecoration(
                labelText: 'اسم الفئة',
                labelStyle: const TextStyle(color: Colors.white54),
                hintText: 'مثال: مشروبات ساخنة',
                hintStyle: TextStyle(color: Colors.white.withAlpha(51)),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white24),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.secondary, width: 2),
                ),
                prefixIcon: const Icon(Icons.label_rounded, color: AppColors.secondary),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إلغاء', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isEmpty) return;
                if (isEdit) {
                  cubit.updateCategory(category.id, name);
                } else {
                  cubit.addCategory(name);
                }
                Navigator.pop(dialogContext);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(isEdit ? 'تحديث' : 'إضافة'),
            ),
          ],
        );
      },
    );
  }

  // ── Product Dialog ────────────────────────────────────────────────────────

  void _showProductDialog(BuildContext context, List<CategoryEntity> categories, {ProductEntity? product}) {
    if (categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يجب إضافة فئة أولاً قبل إضافة صنف'), backgroundColor: AppColors.error),
      );
      return;
    }

    final cubit = context.read<ProductManagementCubit>();
    final nameController = TextEditingController(text: product?.name ?? '');
    final priceController = TextEditingController(text: product != null ? product.price.toString() : '');
    int selectedCategoryId = product?.categoryId ?? categories.first.id;
    final isEdit = product != null;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  Icon(isEdit ? Icons.edit_rounded : Icons.add_circle_rounded, color: AppColors.tableFree),
                  const SizedBox(width: 8),
                  Text(isEdit ? 'تعديل الصنف' : 'إضافة صنف جديد', style: const TextStyle(color: Colors.white)),
                ],
              ),
              content: SizedBox(
                width: 450,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Product Name
                    TextField(
                      controller: nameController,
                      autofocus: true,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      decoration: InputDecoration(
                        labelText: 'اسم الصنف',
                        labelStyle: const TextStyle(color: Colors.white54),
                        hintText: 'مثال: كابتشينو',
                        hintStyle: TextStyle(color: Colors.white.withAlpha(51)),
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white24),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.tableFree, width: 2),
                        ),
                        prefixIcon: const Icon(Icons.fastfood_rounded, color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Category Dropdown
                    DropdownButtonFormField<int>(
                      initialValue: selectedCategoryId,
                      dropdownColor: AppColors.background,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      decoration: InputDecoration(
                        labelText: 'الفئة',
                        labelStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white24),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.tableFree, width: 2),
                        ),
                        prefixIcon: const Icon(Icons.category_rounded, color: AppColors.secondary),
                      ),
                      items: categories.map((cat) {
                        return DropdownMenuItem<int>(value: cat.id, child: Text(cat.name));
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() => selectedCategoryId = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Price
                    TextField(
                      controller: priceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      decoration: InputDecoration(
                        labelText: 'السعر',
                        labelStyle: const TextStyle(color: Colors.white54),
                        hintText: 'مثال: 25.00',
                        hintStyle: TextStyle(color: Colors.white.withAlpha(51)),
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white24),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.tableFree, width: 2),
                        ),
                        prefixIcon: const Icon(Icons.attach_money_rounded, color: AppColors.tableFree),
                        suffixText: 'ج.م',
                        suffixStyle: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('إلغاء', style: TextStyle(color: Colors.white54)),
                ),
                ElevatedButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    final price = double.tryParse(priceController.text.trim());
                    if (name.isEmpty || price == null || price <= 0) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        const SnackBar(
                          content: Text('يرجى ملء جميع الحقول بشكل صحيح'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                      return;
                    }
                    if (isEdit) {
                      cubit.updateProduct(product.id, name, price, selectedCategoryId);
                    } else {
                      cubit.addProduct(name, price, selectedCategoryId);
                    }
                    Navigator.pop(dialogContext);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.tableFree,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(isEdit ? 'تحديث' : 'إضافة'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ── Product Card Widget ─────────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════

class _ProductCard extends StatefulWidget {
  final ProductEntity product;
  final String categoryName;
  final List<CategoryEntity> categories;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductCard({
    required this.product,
    required this.categoryName,
    required this.categories,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: _isHovered ? AppColors.surface.withAlpha(230) : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovered ? AppColors.primary.withAlpha(153) : Colors.white12,
            width: _isHovered ? 2 : 1,
          ),
          boxShadow: _isHovered
              ? [BoxShadow(color: AppColors.primary.withAlpha(38), blurRadius: 16, offset: const Offset(0, 4))]
              : [],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(38),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.coffee_rounded, size: 24, color: AppColors.primary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.product.name,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withAlpha(38),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.categoryName,
                      style: const TextStyle(color: AppColors.secondary, fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.product.price.toStringAsFixed(2)} ج.م',
                    style: const TextStyle(color: AppColors.tableFree, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: widget.product.isOutOfStock
                          ? AppColors.error.withAlpha(38)
                          : (widget.product.isLowStock
                              ? Colors.orangeAccent.withAlpha(38)
                              : Colors.white10),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      widget.product.isOutOfStock
                          ? '🔴 نفد المخزون'
                          : (widget.product.isLowStock
                              ? '⚠️ منخفض (${widget.product.stockQuantity})'
                              : 'المخزون: ${widget.product.stockQuantity}'),
                      style: TextStyle(
                        color: widget.product.isOutOfStock
                            ? AppColors.error
                            : (widget.product.isLowStock ? Colors.orangeAccent : Colors.white60),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Actions overlay on hover
            if (_isHovered)
              Positioned(
                top: 6,
                left: 6,
                child: Row(
                  children: [
                    _ActionIcon(
                      icon: Icons.edit_rounded,
                      color: AppColors.secondary,
                      tooltip: 'تعديل',
                      onTap: widget.onEdit,
                    ),
                    const SizedBox(width: 4),
                    _ActionIcon(
                      icon: Icons.delete_rounded,
                      color: AppColors.error,
                      tooltip: 'حذف',
                      onTap: widget.onDelete,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ── Category Chip (Editable) ────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════

class _CategoryChipEditable extends StatelessWidget {
  final CategoryEntity category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CategoryChipEditable({
    required this.category,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(category.name, style: const TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(width: 6),
            InkWell(
              onTap: onEdit,
              child: const Icon(Icons.edit_rounded, size: 14, color: AppColors.secondary),
            ),
            const SizedBox(width: 4),
            InkWell(
              onTap: onDelete,
              child: const Icon(Icons.close_rounded, size: 14, color: AppColors.error),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ── Small Action Icon Button ────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _ActionIcon({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color.withAlpha(38),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ── Header Button ───────────────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _HeaderButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withAlpha(38),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ── Scroll Arrow Button ─────────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════

class _ScrollArrow extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ScrollArrow({
    required this.icon,
    required this.onTap,
  });

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
