import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final FlutterSecureStorage _secureStorage;

  static const _roleKey = 'session_role';
  static const _usernameKey = 'session_username';
  static const _managerPinKey = 'custom_manager_pin';

  // Default PINs: 4444 = manager, 0000 = cashier
  static const _defaultManagerPin = '4444';
  static const _cashierPin = '0000';

  AuthCubit(this._secureStorage) : super(AuthInitial());

  /// Get the current manager PIN from secure storage (defaults to 4444).
  Future<String> getManagerPin() async {
    final pin = await _secureStorage.read(key: _managerPinKey);
    return pin ?? _defaultManagerPin;
  }

  /// Called on splash screen — restores a saved session if present.
  Future<void> checkAppStatus() async {
    emit(AuthLoading());
    await Future.delayed(const Duration(seconds: 1));

    final savedRole = await _secureStorage.read(key: _roleKey);
    final savedUsername = await _secureStorage.read(key: _usernameKey);

    if (savedRole != null && savedUsername != null) {
      final role = savedRole == 'manager' ? UserRole.manager : UserRole.cashier;
      emit(AuthAuthenticated(username: savedUsername, role: role));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> login(String pinCode) async {
    emit(AuthLoading());
    await Future.delayed(const Duration(milliseconds: 300));

    final currentManagerPin = await getManagerPin();

    if (pinCode == currentManagerPin) {
      const username = 'مدير النظام';
      await _secureStorage.write(key: _roleKey, value: 'manager');
      await _secureStorage.write(key: _usernameKey, value: username);
      emit(const AuthAuthenticated(username: username, role: UserRole.manager));
    } else if (pinCode == _cashierPin) {
      const username = 'كاشير';
      await _secureStorage.write(key: _roleKey, value: 'cashier');
      await _secureStorage.write(key: _usernameKey, value: username);
      emit(const AuthAuthenticated(username: username, role: UserRole.cashier));
    } else {
      emit(const AuthError('كلمة المرور غير صحيحة'));
      emit(AuthUnauthenticated());
    }
  }

  /// Dynamically update the manager PIN after verifying the old PIN.
  Future<bool> changeManagerPin(String oldPin, String newPin) async {
    final currentPin = await getManagerPin();
    if (oldPin != currentPin) {
      return false;
    }
    await _secureStorage.write(key: _managerPinKey, value: newPin);
    return true;
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: _roleKey);
    await _secureStorage.delete(key: _usernameKey);
    emit(AuthUnauthenticated());
  }
}
