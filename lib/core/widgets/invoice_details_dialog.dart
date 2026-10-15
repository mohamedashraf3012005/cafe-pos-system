import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/printer_service.dart';
import '../../features/daily_closing/domain/entities/invoice_item_entity.dart';
import '../../injection_container.dart' as di;

/// Shows a dialog displaying full invoice details (with historical items snapshot)
/// and provides an "إعادة طباعة الفاتورة" (Reprint Invoice) button.
Future<void> showInvoiceDetailsDialog(BuildContext context, InvoiceDetailEntity invoice) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => _InvoiceDetailsDialog(invoice: invoice),
  );
}

class _InvoiceDetailsDialog extends StatefulWidget {
  final InvoiceDetailEntity invoice;

  const _InvoiceDetailsDialog({required this.invoice});

  @override
  State<_InvoiceDetailsDialog> createState() => _InvoiceDetailsDialogState();
}

class _InvoiceDetailsDialogState extends State<_InvoiceDetailsDialog> {
  bool _isPrinting = false;

  Future<void> _handleReprint() async {
    setState(() => _isPrinting = true);
    try {
      final printerService = di.sl<PrinterService>();
      await printerService.printHistoricalReceipt(widget.invoice);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تمت إعادة طباعة الفاتورة بنجاح!'),
            backgroundColor: AppColors.tableFree,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل إعادة الطباعة: ${e.toString().replaceAll("Exception: ", "")}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isPrinting = false);
    }
  }

  Color _getPaymentColor(String method) {
    switch (method) {
      case 'wallet':
        return Colors.deepPurpleAccent;
      case 'instapay':
        return Colors.amber;
      case 'card':
        return Colors.blueAccent;
      case 'cash':
      default:
        return AppColors.tableFree;
    }
  }

  @override
  Widget build(BuildContext context) {
    final inv = widget.invoice;
    final paymentColor = _getPaymentColor(inv.paymentMethod);

    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          const Icon(Icons.receipt_long_rounded, color: AppColors.primary, size: 26),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'تفاصيل فاتورة ${inv.invoiceNumber}',
              style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header Badges & Info ──────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('وسيلة الدفع:', style: TextStyle(color: Colors.white70, fontSize: 13)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: paymentColor.withAlpha(40),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: paymentColor.withAlpha(120)),
                          ),
                          child: Text(
                            inv.paymentMethodLabel,
                            style: TextStyle(color: paymentColor, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _infoRow('التاريخ والوقت', '${inv.createdAt.year}/${inv.createdAt.month.toString().padLeft(2, '0')}/${inv.createdAt.day.toString().padLeft(2, '0')} — ${inv.createdAt.hour.toString().padLeft(2, '0')}:${inv.createdAt.minute.toString().padLeft(2, '0')}'),
                    _infoRow('رقم الطلب', '#${inv.orderId}'),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // ── Items List ────────────────────────────────────────────────
              const Text(
                'الأصناف المشتراة',
                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              if (inv.items.isNotEmpty) ...[
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      // Header
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

                      // Rows
                      ...inv.items.map((item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Expanded(flex: 5, child: Text(item.productName, style: const TextStyle(color: Colors.white, fontSize: 13))),
                            Expanded(flex: 2, child: Center(child: Text('${item.quantity}', style: const TextStyle(color: Colors.white70, fontSize: 13)))),
                            Expanded(flex: 3, child: Center(child: Text(item.unitPrice.toStringAsFixed(2), style: const TextStyle(color: Colors.white70, fontSize: 13)))),
                            Expanded(flex: 3, child: Align(alignment: Alignment.centerLeft, child: Text('${item.totalPrice.toStringAsFixed(2)} ج.م', style: const TextStyle(color: AppColors.secondary, fontSize: 13, fontWeight: FontWeight.bold)))),
                          ],
                        ),
                      )),

                      // PlayStation row if present
                      if (inv.playStationAmount > 0) ...[
                        const Divider(color: Colors.white12, height: 6),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              const Expanded(flex: 5, child: Text('🎮 جلسة بلايستيشن', style: TextStyle(color: Colors.lightBlueAccent, fontSize: 13))),
                              const Expanded(flex: 2, child: Center(child: Text('1', style: TextStyle(color: Colors.white70, fontSize: 13)))),
                              Expanded(flex: 3, child: Center(child: Text(inv.playStationAmount.toStringAsFixed(2), style: const TextStyle(color: Colors.white70, fontSize: 13)))),
                              Expanded(flex: 3, child: Align(alignment: Alignment.centerLeft, child: Text('${inv.playStationAmount.toStringAsFixed(2)} ج.م', style: const TextStyle(color: AppColors.secondary, fontSize: 13, fontWeight: FontWeight.bold)))),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ] else ...[
                // Graceful fallback for old invoices
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.orange.withAlpha(25),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.orange.withAlpha(80)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orangeAccent, size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'تفاصيل الأصناف غير متوفرة لهذه الفاتورة القديمة (تم إغلاقها قبل هذا التحديث). تم استرجاع الإجماليات المالية بدقة.',
                          style: TextStyle(color: Colors.orangeAccent, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 14),

              // ── Financial Summary ──────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  children: [
                    _financialRow('المجموع الفرعي', inv.subtotal),
                    if (inv.serviceCharge > 0)
                      _financialRow('خدمة', inv.serviceCharge),
                    if (inv.taxAmount > 0)
                      _financialRow('ضريبة', inv.taxAmount),
                    const Divider(color: Colors.white24, height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('الإجمالي الكلي', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('${inv.grandTotal.toStringAsFixed(2)} ج.م', style: const TextStyle(color: AppColors.secondary, fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إغلاق', style: TextStyle(color: Colors.white54)),
        ),
        ElevatedButton.icon(
          onPressed: _isPrinting ? null : _handleReprint,
          icon: _isPrinting
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.print_rounded, size: 18),
          label: Text(_isPrinting ? 'جاري الطباعة...' : 'إعادة طباعة الفاتورة'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _financialRow(String label, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          Text('${amount.toStringAsFixed(2)} ج.م', style: const TextStyle(color: Colors.white, fontSize: 13)),
        ],
      ),
    );
  }
}
