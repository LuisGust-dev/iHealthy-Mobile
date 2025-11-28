import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DashboardApi {
  static const String baseUrl = "http://10.0.2.2:8000";

  static Future<Map<String, dynamic>> getDashboardData() async {
    final prefs = await SharedPreferences.getInstance();

    final int? userId = prefs.getInt("user_id");
    final String? token = prefs.getString("access_token");

    if (userId == null || token == null) {
      throw Exception("Usuário não autenticado.");
    }

    final headers = {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json"
    };

    final url = Uri.parse("$baseUrl/api/dashboard/$userId/");

    final response = await http.get(url, headers: headers);

    print("STATUS DASHBOARD: ${response.statusCode}");
    print("BODY DASHBOARD: ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Erro ao buscar dashboard da API.");
    }
  }
}
