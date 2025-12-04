import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  LoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class RegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;

  RegisterRequested({
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [name, emaiimport 'package:equatable/equatable.dart';

/// Evento base para autenticação.
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  /// Lista de propriedades usada para comparação via Equatable.
  @override
  List<Object?> get props => const [];
}

/// Evento disparado quando o usuário solicita login.
class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  /// Construtor do evento de login.
  const LoginRequested({
    required this.email,
    required this.password,
  });

  /// Propriedades utilizadas para comparação e otimização.
  @override
  List<Object?> get props => [email, password];
}

/// Evento disparado quando o usuário solicita registro.
class RegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;

  /// Construtor do evento de registro.
  const RegisterRequested({
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [name, email, password];
}

/// Evento disparado quando o usuário solicita logout.
class LogoutRequested extends AuthEvent {
  /// Logout não precisa de parâmetros, mas o construtor é definido
  /// para manter consistência e extensibilidade.
  const LogoutRequested();
}
l, password];
}

class LogoutRequested extends AuthEvent {}
