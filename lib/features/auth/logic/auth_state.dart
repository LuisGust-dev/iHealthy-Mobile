import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

/// Agora AuthSuccess contém os dados reais da API
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
  List<Object?> get props => [userId, name, email, accessToken, refreshToken];
}

class AuthRegistered extends AuthState {}

class AuthFailure extends AuthState {
  final String message;

  AuthFailure(this.message);

  @override
  List<Object?> get props => [message];
}
