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

  /// Faz login na rota /api/login/ (AppUser do Django)
  /// Envia: email e password
  /// Retorna: Map com dados do usuário + tokens ou null em caso de erro
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

      // Apenas pra debugar no console do Flutter:
      print('STATUS LOGIN: ${response.statusCode}');
      print('BODY LOGIN: ${response.body}');

      if (response.statusCode == 200) {
        // Sucesso: retorna o JSON decodificado
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data;
      } else {
        // Falha no login, você pode tratar mensagens específicas aqui
        return null;
      }
    } catch (e) {
      print('Erro ao chamar API de login: $e');
      return null;
    }
  }
}
