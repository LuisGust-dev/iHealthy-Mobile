import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Estado inicial
class AuthInitial extends AuthState {}

/// Estado de carregamento (ex: login ou cadastro em andamento)
class AuthLoading extends AuthState {}

/// Estado de sucesso (autenticação feita)
class AuthSuccess extends AuthState {}

/// Estado de erro
class AuthFailure extends AuthState {
  final String message;

  AuthFailure(this.message);

  @override
  List<Object?> get props => [message];
}
