import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  Future<void> checkAppStatus() async {
    emit(AuthLoading());
    await Future.delayed(const Duration(seconds: 1));
    emit(AuthUnauthenticated());
  }

  Future<void> login(String pinCode) async {
    emit(AuthLoading());
    await Future.delayed(const Duration(milliseconds: 500));

    // Hardcoded pins for demonstration
    if (pinCode == "1234") {
      emit(const AuthAuthenticated(username: "مدير النظام", isAdmin: true));
    } else if (pinCode == "0000") {
      emit(const AuthAuthenticated(username: "كاشير 1", isAdmin: false));
    } else {
      emit(const AuthError("الرمز السري غير صحيح"));
      emit(AuthUnauthenticated());
    }
  }

  void logout() {
    emit(AuthUnauthenticated());
  }
}
