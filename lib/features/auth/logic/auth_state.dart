import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Estado inicial
class AuthInitial extends AuthState {}

/// Estado enquanto processa login/cadastro
class AuthLoading extends AuthState {}

/// Estado quando o login foi bem-sucedido
class AuthSuccess extends AuthState {
  final int userId;
  final String name;
  final String email;
  final String accessToken;
  final String refreshToken;

  AuthSuccess({
    required this.userId,
    required this.name,
    required this.email,
    required this.accessToken,
    required this.refreshToken,
  });

  @override
  List<Object?> get props => [
        userId,
        name,
        email,
        accessToken,
        refreshToken,
      ];
}

/// Estado quando o cadastro foi concluído (não faz login automático)
class AuthRegistered extends AuthState {}

/// Estado quando há erro
class AuthFailure extends AuthState {
  final String message;

  AuthFailure(this.message);

  @override
  List<Object?> get props => [message];
}
