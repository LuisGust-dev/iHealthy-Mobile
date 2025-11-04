import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static const _keyEmail = 'user_email';
  static const _keyPassword = 'user_password';
  static const _keyName = 'user_name';
  static const _keyLoggedIn = 'user_logged_in';

  // Salva os dados do usuário
  static Future<void> registerUser(
    String name,
    String email,
    String password,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyName, name);
    await prefs.setString(_keyEmail, email);
    await prefs.setString(_keyPassword, password);
  }

  // Tenta login
  static Future<bool> login(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final storedEmail = prefs.getString(_keyEmail);
    final storedPassword = prefs.getString(_keyPassword);

    if (email == storedEmail && password == storedPassword) {
      await prefs.setBool(_keyLoggedIn, true);
      return true;
    }
    return false;
  }

  // Obtém nome do usuário logado
  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyName);
  }

  // Verifica se está logado
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyLoggedIn) ?? false;
  }

  // Faz logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLoggedIn, false);
  }
}
