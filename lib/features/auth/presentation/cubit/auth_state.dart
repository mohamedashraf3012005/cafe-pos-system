import 'package:equatable/equatable.dart';

// Task 2: UserRole enum
enum UserRole { manager, cashier }

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final String username;
  final UserRole role;

  const AuthAuthenticated({required this.username, required this.role});

  bool get isManager => role == UserRole.manager;

  @override
  List<Object> get props => [username, role];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}
