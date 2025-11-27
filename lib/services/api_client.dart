import 'dart:convert';
import 'package:http/http.dart' as http;

/// Serviço responsável por conversar com a API Django (ihealthy_api)
class IHealthyApiClient {
  /// IMPORTANTE:
  /// - Se estiver usando emulador Android: use http://10.0.2.2:8000
  /// - Se estiver usando celular físico: use o IP da sua máquina, ex: http://192.168.0.10:8000
  /// - Em ambiente de desenvolvimento direto no PC (Flutter Web): pode usar http://127.0.0.1:8000
  ///
  /// Ajuste essa URL conforme o seu cenário:
  static const String _baseUrl = 'http://10.0.2.2:8000'; // AJUSTE SE PRECISAR

  // ============================================================
  // LOGIN DO USUÁRIO (POST /api/login/)
  // ============================================================
  static Future<Map<String, dynamic>?> login({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/login/');

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      print('STATUS LOGIN: ${response.statusCode}');
      print('BODY LOGIN: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        return null;
      }
    } catch (e) {
      print('Erro ao chamar API de login: $e');
      return null;
    }
  }

  // ============================================================
  // CADASTRO DO USUÁRIO (POST /api/users/)
  // ============================================================
  static Future<Map<String, dynamic>?> register({
  required String name,
  required String email,
  required String password,
}) async {
  final uri = Uri.parse('$_baseUrl/api/register/');

  try {
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );

    print('STATUS REGISTER: ${response.statusCode}');
    print('BODY REGISTER: ${response.body}');

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      return null;
    }
  } catch (e) {
    print('Erro ao chamar API de cadastro: $e');
    return null;
  }
}


static Future<Map<String, dynamic>> getDashboard(int userId, String token) async {
  final uri = Uri.parse('$_baseUrl/api/dashboard/$userId/');

  final response = await http.get(
    uri,
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    },
  );

  print('STATUS DASHBOARD: ${response.statusCode}');
  print('BODY DASHBOARD: ${response.body}');

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception("Erro ao buscar dashboard da API.");
  }
}


}
