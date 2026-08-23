import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_colors.dart';
import '../../injection_container.dart' as di;

/// The result returned from [showAdminPasswordDialog].
class AdminPasswordResult {
  final bool authenticated;
  final String reason;

  const AdminPasswordResult({
    required this.authenticated,
    this.reason = '',
  });
}

/// Shows a dialog that requires the admin PIN before proceeding.
///
/// Returns an [AdminPasswordResult] with `authenticated = true` when the
/// correct PIN is entered, or `null` if the user cancels.
///
/// [title] — dialog title (e.g. "تأكيد حذف الطاولة").
/// [description] — explanatory text shown below the title.
/// [showReasonField] — whether to show an optional reason text field.
Future<AdminPasswordResult?> showAdminPasswordDialog(
  BuildContext context, {
  required String title,
  String description = '',
  bool showReasonField = true,
}) async {
  return showDialog<AdminPasswordResult>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => _AdminPasswordDialogContent(
      title: title,
      description: description,
      showReasonField: showReasonField,
    ),
  );
}

class _AdminPasswordDialogContent extends StatefulWidget {
  final String title;
  final String description;
  final bool showReasonField;

  const _AdminPasswordDialogContent({
    required this.title,
    required this.description,
    required this.showReasonField,
  });

  @override
  State<_AdminPasswordDialogContent> createState() =>
      _AdminPasswordDialogContentState();
}

class _AdminPasswordDialogContentState
    extends State<_AdminPasswordDialogContent> with SingleTickerProviderStateMixin {
  String _pin = '';
  String _errorMessage = '';
  final TextEditingController _reasonController = TextEditingController();
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _onKeyTap(String digit) {
    if (_pin.length < 4) {
      setState(() {
        _pin += digit;
        _errorMessage = '';
      });

      if (_pin.length == 4) {
        _verifyPin();
      }
    }
  }

  void _onBackspace() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
        _errorMessage = '';
      });
    }
  }

  Future<void> _verifyPin() async {
    final secureStorage = di.sl<FlutterSecureStorage>();
    final managerPin = await secureStorage.read(key: 'custom_manager_pin') ?? '4444';

    if (_pin == managerPin) {
      if (!mounted) return;
      Navigator.pop(
        context,
        AdminPasswordResult(
          authenticated: true,
          reason: _reasonController.text.trim(),
        ),
      );
    } else {
      _shakeController.forward(from: 0);
      setState(() {
        _errorMessage = 'كلمة المرور غير صحيحة';
        _pin = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxDialogHeight = MediaQuery.of(context).size.height * 0.85;

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 380,
        constraints: BoxConstraints(maxHeight: maxDialogHeight),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withAlpha(38),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.admin_panel_settings,
                    color: AppColors.error, size: 32),
              ),
              const SizedBox(height: 12),

              // Title
              Text(
                widget.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
              ),
              if (widget.description.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  widget.description,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                ),
              ],

              const SizedBox(height: 16),

              // Label
              const Text(
                'أدخل رمز المدير للمتابعة',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 12),

              // PIN Dots
              AnimatedBuilder(
                animation: _shakeAnimation,
                builder: (context, child) {
                  final shake = _shakeAnimation.value *
                      10 *
                      ((_shakeController.status == AnimationStatus.forward)
                          ? 1
                          : -1);
                  return Transform.translate(
                    offset: Offset(shake, 0),
                    child: child,
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    final filled = index < _pin.length;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: filled
                            ? (_errorMessage.isEmpty
                                ? AppColors.primary
                                : AppColors.error)
                            : Colors.grey[800],
                        border: Border.all(
                          color: filled
                              ? Colors.transparent
                              : Colors.grey[600]!,
                          width: 1.5,
                        ),
                      ),
                    );
                  }),
                ),
              ),

              // Error message
              if (_errorMessage.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  _errorMessage,
                  style: const TextStyle(color: AppColors.error, fontSize: 13),
                  textDirection: TextDirection.rtl,
                ),
              ],

              const SizedBox(height: 14),

              // Numpad
              _buildNumpad(),

              // Reason field
              if (widget.showReasonField) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _reasonController,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'سبب الحذف (اختياري)',
                    hintTextDirection: TextDirection.rtl,
                    hintStyle:
                        TextStyle(color: Colors.grey[600], fontSize: 12),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                  ),
                ),
              ],

              const SizedBox(height: 14),

              // Cancel button
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context, null),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: Colors.grey[700]!),
                    ),
                  ),
                  child: const Text(
                    'إلغاء',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumpad() {
    const keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', 'X'],
    ];

    return Column(
      children: keys.map((row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.map((key) {
              if (key.isEmpty) {
                return const SizedBox(width: 56, height: 48);
              }
              if (key == 'X') {
                return _buildKey(
                  child: const Icon(Icons.backspace_outlined,
                      color: AppColors.textSecondary, size: 20),
                  onTap: _onBackspace,
                );
              }
              return _buildKey(
                child: Text(key,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                onTap: () => _onKeyTap(key),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildKey({required Widget child, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Material(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 56,
            height: 48,
            alignment: Alignment.center,
            child: child,
          ),
        ),
      ),
    );
  }
}
