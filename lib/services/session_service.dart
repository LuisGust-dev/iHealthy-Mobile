import 'package:shared_preferences/shared_preferences.dart';

/// Serviço responsável por manipular dados de sessão do usuário.
/// 
/// Esta classe centraliza operações de armazenamento, leitura
/// e remoção de informações relacionadas ao login.
class SessionService {
  // ----------------------------------------------------------
  // KEYS PADRONIZADAS (apenas para organização visual)
  // ----------------------------------------------------------
  static const String _keyUserId       = "user_id";
  static const String _keyName         = "name";
  static const String _keyEmail        = "email";
  static const String _keyAccessToken  = "access_token";
  static const String _keyRefreshToken = "refresh_token";

  // ----------------------------------------------------------
  // MÉTODO: SALVAR LOGIN
  // ----------------------------------------------------------

  /// Salva informações básicas da sessão do usuário.
  /// Este método persiste dados no armazenamento local via SharedPreferences.
  static Future<void> saveSession({
    required int userId,
    required String name,
    required String email,
    required String accessToken,
    required String refreshToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Armazenamento organizado por chave
    await prefs.setInt(_keyUserId, userId);
    await prefs.setString(_keyName, name);
    await prefs.setString(_keyEmail, email);
    await prefs.setString(_keyAccessToken, accessToken);
    await prefs.setString(_keyRefreshToken, refreshToken);
  }

  // ----------------------------------------------------------
  // MÉTODO: VERIFICAR LOGIN
  // ----------------------------------------------------------

  /// Verifica se já existe uma sessão ativa baseada em dados salvos.
  static Future<bool> isLogged() async {
    final prefs = await SharedPreferences.getInstance();

    // A sessão é considerada válida se houver identificador e token
    return prefs.containsKey(_keyUserId) &&
           prefs.containsKey(_keyAccessToken);
  }

  // ----------------------------------------------------------
  // MÉTODOS: GETTERS IMPORTANTES
  // ----------------------------------------------------------

  /// Retorna o ID do usuário logado, caso exista.
  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyUserId);
  }

  /// Retorna o token de acesso salvo.
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAccessToken);
  }

  /// Retorna o token de atualização salvo.
  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRefreshToken);
  }

  /// Retorna o nome do usuário logado.
  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyName);
  }

  /// Retorna o e-mail do usuário logado.
  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEmail);
  }

  // ----------------------------------------------------------
  // MÉTODO: LIMPAR SESSÃO
  // ----------------------------------------------------------

  /// Limpa todas as informações relacionadas à sessão.
  /// Ideal para operações de logout.
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
