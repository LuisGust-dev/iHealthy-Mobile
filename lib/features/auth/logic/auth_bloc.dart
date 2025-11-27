import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ihealthy/services/api_client.dart';
import 'package:ihealthy/services/session_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  // ============================================================
  // LOGIN — Agora 100% pela API Django
  // ============================================================
  Future<void> _onLoginRequested(
      LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final result = await IHealthyApiClient.login(
      email: event.email,
      password: event.password,
    );
    print("📌 USER_ID RECEBIDO DO LOGIN: ${result?["user_id"]}");

    if (result == null) {
      emit(AuthFailure("E-mail ou senha inválidos."));
      return;
    }

    // SALVA A SESSÃO LOCALMENTE
    await SessionService.saveSession(
      userId: result["user_id"],
      name: result["name"],
      email: result["email"],
      accessToken: result["access"],
      refreshToken: result["refresh"],
    );

    emit(AuthSuccess(
      userId: result["user_id"],
      name: result["name"],
      email: result["email"],
      accessToken: result["access"],
      refreshToken: result["refresh"],
    ));
    
  }
  

  // ============================================================
  // CADASTRO — AGORA 100% na API Django
  // ============================================================
 Future<void> _onRegisterRequested(
    RegisterRequested event, Emitter<AuthState> emit) async {
  emit(AuthLoading());

  final result = await IHealthyApiClient.register(
    name: event.name,
    email: event.email,
    password: event.password,
  );

  if (result == null) {
    emit(AuthFailure("Erro ao cadastrar! E-mail já usado ou dados inválidos."));
    return;
  }

  emit(AuthRegistered());
}


  // ============================================================
  // LOGOUT
  // ============================================================
  Future<void> _onLogoutRequested(
      LogoutRequested event, Emitter<AuthState> emit) async {
    await SessionService.clearSession();
    emit(AuthInitial());
  }
}
