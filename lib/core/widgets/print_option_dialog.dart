import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Result from the print option dialog.
enum PrintChoice { print, noPrint }

/// Shows a dialog asking the user whether to print the receipt on every checkout.
/// Returns [PrintChoice.print] or [PrintChoice.noPrint].
Future<PrintChoice> showPrintOptionDialog(BuildContext context) async {
  final result = await showDialog<PrintChoice>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => const _PrintOptionDialogContent(),
  );

  return result ?? PrintChoice.noPrint;
}

class _PrintOptionDialogContent extends StatelessWidget {
  const _PrintOptionDialogContent();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 380,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.receipt_long,
                    color: AppColors.primary, size: 40),
              ),
              const SizedBox(height: 18),

              // Title
              const Text(
                'تم الدفع بنجاح!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 8),
              const Text(
                'هل تريد طباعة الفاتورة؟',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 24),

              // Print button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context, PrintChoice.print),
                  icon: const Icon(Icons.print, size: 22),
                  label: const Text(
                    'طباعة البون / الفاتورة',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.tableFree,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // No print button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context, PrintChoice.noPrint),
                  icon: Icon(Icons.close, size: 22, color: Colors.grey[400]),
                  label: Text(
                    'عدم الطباعة',
                    style: TextStyle(fontSize: 16, color: Colors.grey[400]),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey[700]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
