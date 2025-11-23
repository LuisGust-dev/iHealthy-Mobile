import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ihealthy/services/database_helper.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import 'package:ihealthy/services/api_client.dart';


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

  final result = await IHealthyApiClient.login(
    email: event.email,
    password: event.password,
  );

  if (result == null) {
    emit(AuthFailure("E-mail ou senha inválidos."));
    return;
  }

  // Login OK → emitir sucesso com dados reais
  emit(AuthSuccess(
    userId: result["user_id"],
    name: result["name"],
    email: result["email"],
    accessToken: result["access"],
    refreshToken: result["refresh"],
  ));
}


  // CADASTRO
  Future<void> _onRegisterRequested(
      RegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

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

      // 🔥 agora cadastro NÃO faz login automático
      emit(AuthRegistered());
    } catch (e) {
      emit(AuthFailure('Erro ao cadastrar: $e'));
    }
  }

  // LOGOUT
  void _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) {
    emit(AuthInitial());
  }
}
