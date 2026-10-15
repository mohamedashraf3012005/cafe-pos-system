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
  String selectedPaymentMethod = 'cash';

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

  String _getPaymentMethodLabel(String method) {
    switch (method) {
      case 'wallet':
        return 'محفظة إلكترونية';
      case 'instapay':
        return 'إنستاباي';
      case 'cash':
      default:
        return 'نقدي';
    }
  }

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
          paymentMethod: selectedPaymentMethod,
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
            width: 620,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [BoxShadow(color: Colors.black26, offset: Offset(0, 4), blurRadius: 10)],
            ),
            child: BlocConsumer<CheckoutCubit, CheckoutState>(
              listener: (context, state) {
                if (state is CheckoutSuccess) {
                  final methodLabel = _getPaymentMethodLabel(selectedPaymentMethod);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(widget.order.orderType == 'takeaway'
                          ? 'تم الدفع بنجاح ($methodLabel)!'
                          : 'تم الدفع بنجاح ($methodLabel)! الطاولة أصبحت متاحة.'),
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
                      const Icon(Icons.receipt_long, size: 48, color: AppColors.primary),
                      const SizedBox(height: 8),

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

                      // ── Order Items Detailed List (Modification 2) ────────
                      _buildOrderItemsList(),
                      const SizedBox(height: 16),

                      // ── Financial Summary ──────────────────────────────────
                      const Align(
                        alignment: Alignment.centerRight,
                        child: Text('ملخص الحساب', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                      const Divider(height: 16, color: Colors.white24),
                      if (widget.order.playStationCost > 0) ...[
                        _buildSummaryRow('المشروبات والأطعمة', widget.order.itemsSubtotal),
                        const SizedBox(height: 6),
                        _buildSummaryRow(
                          '🎮 ${widget.order.playStationDescription ?? "PlayStation"}',
                          widget.order.playStationCost,
                        ),
                        const SizedBox(height: 6),
                      ],
                      _buildSummaryRow('المجموع الفرعي', widget.order.subtotal),
                      const SizedBox(height: 6),
                      if (serviceChargeRate > 0) ...[
                        _buildSummaryRow('خدمة (${(serviceChargeRate * 100).toInt()}%)', serviceCharge),
                        const SizedBox(height: 6),
                      ],
                      if (taxRate > 0) ...[
                        _buildSummaryRow('ضريبة (${(taxRate * 100).toInt()}%)', tax),
                        const SizedBox(height: 6),
                      ],
                      const Divider(height: 20, color: Colors.white24),
                      _buildSummaryRow('الإجمالي الكلي', grandTotal, isTotal: true),
                      const SizedBox(height: 20),

                      // ── 3 Payment Methods Selector (Modification 4) ─────────
                      _buildPaymentMethodSelector(),
                      const SizedBox(height: 24),

                      // ── Checkout Action Button ─────────────────────────────
                      if (state is CheckoutLoading)
                        const CircularProgressIndicator()
                      else
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.payment, color: Colors.white),
                            label: Text(
                              'إتمام الدفع (${_getPaymentMethodLabel(selectedPaymentMethod)})',
                              style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            onPressed: () => _handleCheckout(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.tableFree,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  Widget _buildOrderItemsList() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.format_list_bulleted_rounded, color: AppColors.secondary, size: 18),
              SizedBox(width: 8),
              Text(
                'أصناف الطلب',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 6),
          // Table Header
          const Row(
            children: [
              Expanded(flex: 5, child: Text('الصنف', style: TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.bold))),
              Expanded(flex: 2, child: Center(child: Text('الكمية', style: TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.bold)))),
              Expanded(flex: 3, child: Center(child: Text('السعر', style: TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.bold)))),
              Expanded(flex: 3, child: Align(alignment: Alignment.centerLeft, child: Text('الإجمالي', style: TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.bold)))),
            ],
          ),
          const SizedBox(height: 4),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 4),
          ...widget.order.items.map((item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                Expanded(flex: 5, child: Text(item.productName, style: const TextStyle(color: Colors.white, fontSize: 13))),
                Expanded(flex: 2, child: Center(child: Text('${item.quantity}', style: const TextStyle(color: Colors.white70, fontSize: 13)))),
                Expanded(flex: 3, child: Center(child: Text(item.unitPrice.toStringAsFixed(2), style: const TextStyle(color: Colors.white70, fontSize: 13)))),
                Expanded(flex: 3, child: Align(alignment: Alignment.centerLeft, child: Text('${item.totalPrice.toStringAsFixed(2)} ج.م', style: const TextStyle(color: AppColors.secondary, fontSize: 13, fontWeight: FontWeight.bold)))),
              ],
            ),
          )),
          if (widget.order.playStationCost > 0) ...[
            const Divider(color: Colors.white12, height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Expanded(flex: 5, child: Text('🎮 ${widget.order.playStationDescription ?? "جلسة بلايستيشن"}', style: const TextStyle(color: Colors.lightBlueAccent, fontSize: 13))),
                  const Expanded(flex: 2, child: Center(child: Text('1', style: TextStyle(color: Colors.white70, fontSize: 13)))),
                  Expanded(flex: 3, child: Center(child: Text(widget.order.playStationCost.toStringAsFixed(2), style: const TextStyle(color: Colors.white70, fontSize: 13)))),
                  Expanded(flex: 3, child: Align(alignment: Alignment.centerLeft, child: Text('${widget.order.playStationCost.toStringAsFixed(2)} ج.م', style: const TextStyle(color: AppColors.secondary, fontSize: 13, fontWeight: FontWeight.bold)))),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'وسيلة الدفع:',
          style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildPaymentOption('cash', 'نقدي (Cash)', Icons.payments_rounded, AppColors.tableFree),
            const SizedBox(width: 8),
            _buildPaymentOption('wallet', 'محفظة (Wallet)', Icons.phone_android_rounded, Colors.deepPurpleAccent),
            const SizedBox(width: 8),
            _buildPaymentOption('instapay', 'إنستاباي (InstaPay)', Icons.bolt_rounded, Colors.amber),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentOption(String methodKey, String label, IconData icon, Color activeColor) {
    final isSelected = selectedPaymentMethod == methodKey;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => selectedPaymentMethod = methodKey),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          decoration: BoxDecoration(
            color: isSelected ? activeColor.withAlpha(40) : AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? activeColor : Colors.white24,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: isSelected ? activeColor : Colors.white60, size: 24),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 15,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Colors.white : Colors.white70,
          ),
        ),
        Text(
          '${amount.toStringAsFixed(2)} ج.م',
          style: TextStyle(
            fontSize: isTotal ? 22 : 15,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? AppColors.secondary : Colors.white,
          ),
        ),
      ],
    );
  }
}