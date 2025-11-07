import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ihealthy/services/database_helper.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  AuthBloc() : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  // LOGIN
  Future<void> _onLoginRequested(
      LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final user = await _dbHelper.getUserByEmail(event.email);

      if (user == null) {
        emit(AuthFailure('Usuário não encontrado.'));
      } else if (user['password'] != event.password) {
        emit(AuthFailure('Senha incorreta.'));
      } else {
        emit(AuthSuccess());
      }
    } catch (e) {
      emit(AuthFailure('Erro ao realizar login: $e'));
    }
  }

  // CADASTRO
  Future<void> _onRegisterRequested(
      RegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final existingUser = await _dbHelper.getUserByEmail(event.email);

      if (existingUser != null) {
        emit(AuthFailure('E-mail já cadastrado.'));
        return;
      }

      await _dbHelper.insertUser({
        'name': event.name,
        'email': event.email,
        'password': event.password,
      });

      emit(AuthSuccess());
    } catch (e) {
      emit(AuthFailure('Erro ao cadastrar: $e'));
    }
  }

  // LOGOUT
  void _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) {
    emit(AuthInitial());
  }
}
