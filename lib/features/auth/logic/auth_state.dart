import 'package:equatable/equatable.dart';

/// Estado base para autenticação.
/// Todos os estados relacionados ao fluxo de autenticação devem estender esta classe.
abstract class AuthState extends Equatable {
  const AuthState();

  /// Lista de propriedades utilizada para comparação via Equatable.
  @override
  List<Object?> get props => const [];
}

/// Estado inicial da autenticação, antes de qualquer ação do usuário.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Estado exibido enquanto o sistema processa login ou cadastro.
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Estado representando um login bem-sucedido.
class AuthSuccess extends AuthState {
  final int userId;
  final String name;
  final String email;
  final String accessToken;
  final String refreshToken;

  /// Construtor do estado de sucesso.
  const AuthSuccess({
    required this.userId,
    required this.name,
    required this.email,
    required this.accessToken,
    required this.refreshToken,
  });

  /// Propriedades utilizadas na comparação de estados.
  @override
  List<Object?> get props => [
        userId,
        name,
        email,
        accessToken,
        refreshToken,
      ];
}

/// Estado emitido quando o cadastro é feito com sucesso,
/// mas sem realizar login automático.
class AuthRegistered extends AuthState {
  const AuthRegistered();
}

/// Estado que representa falha em algum processo de autenticação.
class AuthFailure extends AuthState {
  final String message;

  /// Construtor do estado de falha.
  const AuthFailure(this.message);

  @override
  List<Object?> get props => [message];
}
