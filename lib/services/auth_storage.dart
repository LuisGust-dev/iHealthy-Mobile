import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  static Future<void> saveSession(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('access', data['access']);
    await prefs.setString('refresh', data['refresh']);
    await prefs.setInt('user_id', data['user']['id']);
    await prefs.setString('user_email', data['user']['email']);
    await prefs.setString('user_name', data['user']['name']);
  }

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access');
  }

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
