import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Estado inicial
class AuthInitial extends AuthState {}

/// Estado enquanto processa login/cadastro
class AuthLoading extends AuthState {}

/// Estado quando o login foi bem-sucedido (entrar no sistema)
class AuthSuccess extends AuthState {}

/// 🔥 NOVO — Estado quando o cadastro foi concluído
/// Usado para redirecionar o usuário para a tela de login
class AuthRegistered extends AuthState {}

/// Estado quando há erro
class AuthFailure extends AuthState {
  final String message;

  AuthFailure(this.message);

  @override
  List<Object?> get props => [message];
}
