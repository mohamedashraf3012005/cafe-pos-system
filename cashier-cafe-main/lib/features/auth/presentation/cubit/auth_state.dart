import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();  

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final String username;
  final bool isAdmin;
  const AuthAuthenticated({required this.username, required this.isAdmin});

  @override
  List<Object> get props => [username, isAdmin];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}
