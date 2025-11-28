import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  // -----------------------------
  // SALVAR LOGIN
  // -----------------------------
  static Future<void> saveSession({
    required int userId,
    required String name,
    required String email,
    required String accessToken,
    required String refreshToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("user_id", userId);
    await prefs.setString("name", name);
    await prefs.setString("email", email);
    await prefs.setString("access_token", accessToken);
    await prefs.setString("refresh_token", refreshToken);
  }

  // -----------------------------
  // VERIFICAR LOGIN
  // -----------------------------
  static Future<bool> isLogged() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey("user_id") &&
           prefs.containsKey("access_token");
  }

  // -----------------------------
  // GETTERS IMPORTANTES
  // -----------------------------

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("user_id");
  }

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("access_token");
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("refresh_token");
  }

  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("name");
  }

  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("email");
  }

  // -----------------------------
  // LIMPAR SESSÃO
  // -----------------------------
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
