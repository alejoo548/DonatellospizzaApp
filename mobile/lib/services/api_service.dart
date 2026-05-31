import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final String message;
  final Map<String, dynamic>? errors;
  ApiException(this.message, {this.errors});

  @override
  String toString() => message;
}

class ApiService {
  // Emulador Android: http://10.0.2.2:8010
  // Dispositivo físico en misma red: http://192.168.3.85:8010
  static const String _baseUrl = 'http://192.168.3.85:8010/api';

  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Future<Map<String, dynamic>> register({
    required String name,
    required String lastname,
    required String email,
    required String password,
  }) async {
    final response = await http
        .post(
          Uri.parse('$_baseUrl/register'),
          headers: _headers,
          body: jsonEncode({
            'name': name,
            'lastname': lastname,
            'email': email,
            'password': password,
            'password_confirmation': password,
          }),
        )
        .timeout(const Duration(seconds: 15));

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 201) return body;

    final msg = body['message'] as String? ?? 'Error al registrar';
    throw ApiException(msg, errors: body['errors'] as Map<String, dynamic>?);
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http
        .post(
          Uri.parse('$_baseUrl/login'),
          headers: _headers,
          body: jsonEncode({'email': email, 'password': password}),
        )
        .timeout(const Duration(seconds: 15));

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) return body;

    final msg = body['message'] as String? ?? 'Error al iniciar sesión';
    throw ApiException(msg, errors: body['errors'] as Map<String, dynamic>?);
  }
}
