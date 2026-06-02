import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final String message;
  final Map<String, dynamic>? errors;
  ApiException(this.message, {this.errors});

  @override
  String toString() => message;
}

class ApiService {
  static const String _lanBaseUrl = 'http://192.168.1.13:8010/api';
  // Emulador Android con `adb reverse tcp:8010 tcp:8010`: http://127.0.0.1:8010
  // Alternativa clasica de emulador Android: http://10.0.2.2:8010
  // Dispositivo fisico en misma red: http://192.168.1.13:8010
  static const String _defaultBaseUrl = _lanBaseUrl;
  static const String _androidEmulatorFallbackBaseUrl =
      'http://10.0.2.2:8010/api';
  static const String _androidReverseBaseUrl = 'http://127.0.0.1:8010/api';
  static const String _configuredBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: _defaultBaseUrl,
  );

  static const String imageBaseUrl ='http://192.168.1.13:8000/storage';

  static String productImage(String path) {
    return '$imageBaseUrl/$path';
  }

  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static const Duration _requestTimeout = Duration(seconds: 35);

  static Future<Map<String, dynamic>> register({
    required String name,
    required String lastname,
    required String email,
    required String password,
  }) async {
    final response = await _post('/register', {
      'name': name,
      'lastname': lastname,
      'email': email,
      'password': password,
      'password_confirmation': password,
    });

    final body = _decodeBody(response);

    if (response.statusCode == 201) return body;

    final msg = body['message'] as String? ?? _defaultMessageFor(response);
    throw ApiException(msg, errors: body['errors'] as Map<String, dynamic>?);
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _post('/login', {
      'email': email,
      'password': password,
    });

    final body = _decodeBody(response);

    if (response.statusCode == 200) return body;

    final msg = body['message'] as String? ?? _defaultMessageFor(response);
    throw ApiException(msg, errors: body['errors'] as Map<String, dynamic>?);
  }

  static Future<Map<String, dynamic>> requestPasswordReset({
    required String email,
  }) async {
    final response = await _post('/forgot-password', {'email': email});

    final body = _decodeBody(response);

    if (response.statusCode == 200) return body;

    final msg = body['message'] as String? ?? _defaultMessageFor(response);
    throw ApiException(msg, errors: body['errors'] as Map<String, dynamic>?);
  }

  static Future<Map<String, dynamic>> validatePasswordResetToken({
    required String email,
    required String token,
  }) async {
    final response = await _post('/forgot-password/validate-token', {
      'email': email,
      'token': token,
    });

    final body = _decodeBody(response);

    if (response.statusCode == 200) return body;

    final msg = body['message'] as String? ?? _defaultMessageFor(response);
    throw ApiException(msg, errors: body['errors'] as Map<String, dynamic>?);
  }

  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String token,
    required String password,
  }) async {
    final response = await _post('/forgot-password/reset', {
      'email': email,
      'token': token,
      'password': password,
      'password_confirmation': password,
    });

    final body = _decodeBody(response);

    if (response.statusCode == 200) return body;

    final msg = body['message'] as String? ?? _defaultMessageFor(response);
    throw ApiException(msg, errors: body['errors'] as Map<String, dynamic>?);
  }

  static Map<String, dynamic> _decodeBody(http.Response response) {
    if (response.body.isEmpty) {
      return {};
    }

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } on FormatException {
      return {'message': _defaultMessageFor(response), 'raw': response.body};
    }

    return {'message': _defaultMessageFor(response)};
  }

  static String _defaultMessageFor(http.Response response) {
    if (response.statusCode >= 500) {
      return 'El servidor devolvio un error interno.';
    }

    return 'The request could not be completed.';
  }

  static List<String> _candidateBaseUrls() {
    final urls = <String>[_configuredBaseUrl];

    if (Platform.isAndroid && _configuredBaseUrl == _defaultBaseUrl) {
      for (final url in [
        _lanBaseUrl,
        _androidReverseBaseUrl,
        _androidEmulatorFallbackBaseUrl,
      ]) {
        if (!urls.contains(url)) {
          urls.add(url);
        }
      }
    }

    return urls;
  }

  static Future<http.Response> _post(
    String path,
    Map<String, dynamic> payload,
  ) async {
    ApiException? lastNetworkError;

    for (final baseUrl in _candidateBaseUrls()) {
      try {
        return await http
            .post(
              Uri.parse('$baseUrl$path'),
              headers: _headers,
              body: jsonEncode(payload),
            )
            .timeout(_requestTimeout);
      } on SocketException {
        lastNetworkError = ApiException(
          'Could not connect to $baseUrl. The app will try another development path if one is available.',
        );
      } on TimeoutException {
        lastNetworkError = ApiException(
          'El servidor tardo demasiado en responder ($baseUrl$path).',
        );
      } on http.ClientException catch (e) {
        lastNetworkError = ApiException(
          'Error de red en $baseUrl: ${e.message}',
        );
      }
    }

    throw lastNetworkError ??
        ApiException('The request could not be completed.');
  }

  static Future<Map<String, dynamic>> getCategories() async {
    final response = await _get('/categories');
    final body = _decodeBody(response);

    if (response.statusCode == 200) return body;

    final msg = body['message'] as String? ?? _defaultMessageFor(response);
    throw ApiException(msg, errors: body['errors'] as Map<String, dynamic>?);
  }

  static Future<Map<String, dynamic>> getProducts() async {
    final response = await _get('/products');
    final body = _decodeBody(response);

    if (response.statusCode == 200) return body;

    final msg = body['message'] as String? ?? _defaultMessageFor(response);
    throw ApiException(msg, errors: body['errors'] as Map<String, dynamic>?);
  }

  static Future<http.Response> _get(String path) async {
    ApiException? lastNetworkError;

    for (final baseUrl in _candidateBaseUrls()) {
      try {
        return await http
            .get(Uri.parse('$baseUrl$path'), headers: _headers)
            .timeout(_requestTimeout);
      } on SocketException {
        lastNetworkError = ApiException('No se pudo conectar a $baseUrl.');
      } on TimeoutException {
        lastNetworkError = ApiException(
          'El servidor tardó demasiado en responder ($baseUrl$path).',
        );
      } on http.ClientException catch (e) {
        lastNetworkError = ApiException(
          'Error de red en $baseUrl: ${e.message}',
        );
      }
    }

    throw lastNetworkError ??
        ApiException('No se pudo completar la solicitud.');
  }
}
