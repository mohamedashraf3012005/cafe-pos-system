import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import 'login_page.dart';
import '../../../main/presentation/pages/main_layout.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    context.read<AuthCubit>().checkAppStatus();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
        } else if (state is AuthAuthenticated) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainLayout()),
          );
        }
      },
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               const Icon(Icons.coffee, size: 100, color: AppColors.primary),
               const SizedBox(height: 24),
               Text(
                 "نظام الكاشير",
                 style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                   color: AppColors.primary,
                   fontWeight: FontWeight.bold,
                   letterSpacing: 2,
                 ),
               ),
               const SizedBox(height: 40),
               const CircularProgressIndicator(color: AppColors.secondary),
            ],
          ),
        ),
      ),
    );
  }
}

