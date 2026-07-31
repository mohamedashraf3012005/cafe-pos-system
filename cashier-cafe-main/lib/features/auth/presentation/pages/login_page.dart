import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../../../main/presentation/pages/main_layout.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _pin = '';

  void _onKeypadTap(String value) {
    if (_pin.length < 4) {
      setState(() {
        _pin += value;
      });
      if (_pin.length == 4) {
        context.read<AuthCubit>().login(_pin);
      }
    }
  }

  void _onBackspace() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
            );
            setState(() {
              _pin = '';
            });
          } else if (state is AuthAuthenticated) {
             ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("أهلاً بك، ${state.username}!"), backgroundColor: AppColors.tableFree),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const MainLayout()),
            );
          }
        },
        builder: (context, state) {
          return Center(
            child: Container(
              width: 400,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_outline, size: 60, color: AppColors.primary),
                  const SizedBox(height: 16),
                  Text(
                    "أدخل الرمز السري",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 24),
                  
                  // PIN Display
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index < _pin.length ? AppColors.primary : Colors.grey[800],
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 32),
                  
                  if (state is AuthLoading) 
                    const CircularProgressIndicator(color: AppColors.primary)
                  else
                    // Numpad
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildKeypadButton('1'),
                            _buildKeypadButton('2'),
                            _buildKeypadButton('3'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildKeypadButton('4'),
                            _buildKeypadButton('5'),
                            _buildKeypadButton('6'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildKeypadButton('7'),
                            _buildKeypadButton('8'),
                            _buildKeypadButton('9'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const SizedBox(width: 64), // spacer for middle alignment
                            _buildKeypadButton('0'),
                            _buildKeypadButton('X', isAction: true, onTap: _onBackspace),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text("المدير: 1234 | الكاشير: 0000", style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildKeypadButton(String label, {bool isAction = false, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap ?? () => _onKeypadTap(label),
      borderRadius: BorderRadius.circular(32),
      child: Container(
        width: 64,
        height: 64,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isAction ? Colors.transparent : Colors.grey[800],
          border: isAction ? Border.all(color: Colors.grey) : null,
        ),
        child: isAction 
            ? Icon(Icons.backspace, color: AppColors.textSecondary)
            : Text(
                label,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
