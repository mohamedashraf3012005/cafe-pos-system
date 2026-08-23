import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:cash_cafe/core/constants/app_colors.dart';
import 'package:cash_cafe/injection_container.dart' as di;
import 'package:cash_cafe/features/inventory/presentation/cubit/inventory_cubit.dart';
import 'package:cash_cafe/features/inventory/presentation/cubit/inventory_state.dart';

class InventoryMovementPage extends StatelessWidget {
  final int? productId;

  const InventoryMovementPage({super.key, this.productId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<InventoryCubit>()..loadMovements(productId: productId),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('سجل حركات المخزون'),
        ),
        body: BlocBuilder<InventoryCubit, InventoryState>(
          builder: (context, state) {
            if (state is InventoryLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is InventoryLoaded) {
              final movements = state.movements;

              if (movements.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long, size: 64, color: Colors.white24),
                      SizedBox(height: 16),
                      Text('لا توجد حركات مسجلة بالمخزون بعد', style: TextStyle(color: Colors.white54, fontSize: 16)),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: movements.length,
                itemBuilder: (context, index) {
                  final m = movements[index];
                  final dateStr = DateFormat('yyyy/MM/dd HH:mm').format(m.createdAt);

                  Color typeColor = Colors.blue;
                  IconData typeIcon = Icons.swap_horiz;
                  if (m.movementType == 'stock_in') {
                    typeColor = AppColors.tableFree;
                    typeIcon = Icons.add_circle_outline;
                  } else if (m.movementType == 'sale') {
                    typeColor = Colors.blueAccent;
                    typeIcon = Icons.shopping_cart_outlined;
                  } else if (m.movementType == 'manual_remove') {
                    typeColor = AppColors.error;
                    typeIcon = Icons.remove_circle_outline;
                  } else if (m.movementType == 'return') {
                    typeColor = Colors.tealAccent;
                    typeIcon = Icons.replay;
                  }

                  return Card(
                    color: AppColors.surface,
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: typeColor.withAlpha(38),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(typeIcon, color: typeColor, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      m.productName,
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: typeColor.withAlpha(51),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        m.movementTypeLabel,
                                        style: TextStyle(color: typeColor, fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$dateStr ${m.reason != null ? "• ${m.reason}" : ""}',
                                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${m.movementType == "manual_remove" || m.movementType == "sale" ? "-" : "+"}${m.quantity}',
                                style: TextStyle(
                                  color: typeColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                'السابق: ${m.previousQuantity} → الحالي: ${m.newQuantity}',
                                style: const TextStyle(color: Colors.white38, fontSize: 11),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}