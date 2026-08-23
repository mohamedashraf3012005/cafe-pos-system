import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cash_cafe/core/constants/app_colors.dart';
import 'package:cash_cafe/core/widgets/print_option_dialog.dart';
import 'package:cash_cafe/injection_container.dart' as di;
import 'package:cash_cafe/features/orders/domain/entities/order_entity.dart';
import 'package:cash_cafe/features/checkout/presentation/cubit/checkout_cubit.dart';

class CheckoutPage extends StatefulWidget {
  final OrderEntity order;
  final int? tableNumber;

  const CheckoutPage({super.key, required this.order, this.tableNumber});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  late double serviceChargeRate;
  late double taxRate;
  late TextEditingController serviceController;
  late TextEditingController taxController;

  @override
  void initState() {
    super.initState();
    serviceChargeRate = 0.0;
    taxRate = 0.0;
    serviceController = TextEditingController(text: (serviceChargeRate * 100).toInt().toString());
    taxController = TextEditingController(text: (taxRate * 100).toInt().toString());
  }

  @override
  void dispose() {
    serviceController.dispose();
    taxController.dispose();
    super.dispose();
  }

  double get serviceCharge => widget.order.subtotal * serviceChargeRate;
  double get tax => widget.order.subtotal * taxRate;
  double get grandTotal => widget.order.subtotal + serviceCharge + tax;

  Future<void> _handleCheckout(BuildContext context) async {
    final printChoice = await showPrintOptionDialog(context);

    if (!context.mounted) return;

    final shouldPrint = printChoice == PrintChoice.print;

    context.read<CheckoutCubit>().processCheckout(
          widget.order,
          serviceChargeRate,
          taxRate,
          serviceCharge,
          tax,
          grandTotal,
          widget.tableNumber,
          shouldPrint: shouldPrint,
          paymentMethod: 'cash',
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<CheckoutCubit>(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.order.orderType == 'takeaway' ? 'الدفع - تيك أواي' : 'الدفع - طاولة ${widget.tableNumber ?? widget.order.tableId}'),
        ),
        body: Center(
          child: Container(
            width: 540,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [BoxShadow(color: Colors.black26, offset: Offset(0, 4), blurRadius: 10)],
            ),
            child: BlocConsumer<CheckoutCubit, CheckoutState>(
              listener: (context, state) {
                if (state is CheckoutSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(widget.order.orderType == 'takeaway' ? 'تم الدفع بنجاح (نقدي)!' : 'تم الدفع بنجاح! الطاولة أصبحت متاحة.'),
                      backgroundColor: AppColors.tableFree,
                    ),
                  );
                  Navigator.popUntil(context, (route) => route.isFirst);
                } else if (state is CheckoutError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
                  );
                }
              },
              builder: (context, state) {
                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.receipt_long, size: 56, color: AppColors.primary),
                      const SizedBox(height: 12),
                      if (widget.order.orderType != 'takeaway') ...[
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: serviceController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'نسبة الخدمة (%)',
                                  border: OutlineInputBorder(),
                                ),
                                style: const TextStyle(color: Colors.white),
                                onChanged: (val) {
                                  setState(() {
                                    serviceChargeRate = (double.tryParse(val) ?? 0) / 100;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextField(
                                controller: taxController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'نسبة الضريبة (%)',
                                  border: OutlineInputBorder(),
                                ),
                                style: const TextStyle(color: Colors.white),
                                onChanged: (val) {
                                  setState(() {
                                    taxRate = (double.tryParse(val) ?? 0) / 100;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                      const Text('ملخص الطلب', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                      const Divider(height: 24, color: Colors.white24),
                      if (widget.order.playStationCost > 0) ...[
                        _buildSummaryRow('المشروبات والأطعمة', widget.order.itemsSubtotal),
                        const SizedBox(height: 8),
                        _buildSummaryRow(
                          '🎮 ${widget.order.playStationDescription ?? "PlayStation"}',
                          widget.order.playStationCost,
                        ),
                        const SizedBox(height: 8),
                      ],
                      _buildSummaryRow('المجموع الفرعي', widget.order.subtotal),
                      const SizedBox(height: 8),
                      if (serviceChargeRate > 0) ...[
                        _buildSummaryRow('خدمة (${(serviceChargeRate * 100).toInt()}%)', serviceCharge),
                        const SizedBox(height: 8),
                      ],
                      if (taxRate > 0) ...[
                        _buildSummaryRow('ضريبة (${(taxRate * 100).toInt()}%)', tax),
                        const SizedBox(height: 8),
                      ],
                      const Divider(height: 24, color: Colors.white24),
                      _buildSummaryRow('طريقة الدفع', 0, isPaymentMethod: true),
                      const Divider(height: 24, color: Colors.white24),
                      _buildSummaryRow('الإجمالي الكلي', grandTotal, isTotal: true),
                      const SizedBox(height: 32),
                      if (state is CheckoutLoading)
                        const CircularProgressIndicator()
                      else
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.payment),
                            label: const Text('إتمام الدفع (نقدي)', style: TextStyle(fontSize: 18, color: Colors.white)),
                            onPressed: () => _handleCheckout(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.tableFree,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isTotal = false, bool isPaymentMethod = false}) {
    if (isPaymentMethod) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, color: Colors.white70)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.tableFree.withAlpha(38),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.tableFree.withAlpha(102)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.money, color: AppColors.tableFree, size: 16),
                SizedBox(width: 6),
                Text('نقدي (Cash Only)', style: TextStyle(color: AppColors.tableFree, fontSize: 13, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 20 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Colors.white : Colors.white70,
          ),
        ),
        Text(
          '${amount.toStringAsFixed(2)} ج.م',
          style: TextStyle(
            fontSize: isTotal ? 24 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? AppColors.secondary : Colors.white,
          ),
        ),
      ],
    );
  }
}