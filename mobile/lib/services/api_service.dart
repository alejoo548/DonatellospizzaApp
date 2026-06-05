import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'session_manager.dart';

class ApiException implements Exception {
  final String message;
  final Map<String, dynamic>? errors;

  ApiException(this.message, {this.errors});

  @override
  String toString() => message;
}

class ApiService {
  static const String _lanBaseUrl = 'http://192.168.1.229:8010/api';
  // Android emulator with `adb reverse tcp:8010 tcp:8010`: http://127.0.0.1:8010
  // Classic Android emulator alternative: http://10.0.2.2:8010
  // Physical device on the same network: use the LAN IP of the machine running Docker.
  // To override the URL at build time:
  // flutter run --dart-define=API_BASE_URL=http://YOUR_IP:8010/api
  static const String _androidEmulatorFallbackBaseUrl =
      'http://10.0.2.2:8010/api';
  static const String _androidReverseBaseUrl = 'http://127.0.0.1:8010/api';
  static const String _configuredBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );
  static const String _configuredImageBaseUrl = String.fromEnvironment(
    'IMAGE_BASE_URL',
    defaultValue: '',
  );

  static String? _activeBaseUrl;

  static String get activeImageBaseUrl {
    if (_configuredImageBaseUrl.isNotEmpty) {
      return _configuredImageBaseUrl;
    }
    final base = _activeBaseUrl ?? _candidateBaseUrls().first;
    if (base.endsWith('/api')) {
      return '${base.substring(0, base.length - 4)}/storage';
    }
    return '$base/storage';
  }

  static String productImage(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      final uri = Uri.tryParse(path);
      if (uri != null &&
          (uri.host == 'localhost' ||
              uri.host == '127.0.0.1' ||
              uri.host == '::1') &&
          uri.path.startsWith('/storage/')) {
        return '$activeImageBaseUrl/${uri.path.substring('/storage/'.length)}';
      }
      return path;
    }
    final normalizedPath = path.startsWith('/') ? path.substring(1) : path;
    return '$activeImageBaseUrl/$normalizedPath';
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

  static Future<Map<String, dynamic>> verifyEmail({
    required String email,
    required String code,
  }) async {
    final response = await _post('/verify-email', {
      'email': email,
      'code': code,
    });

    final body = _decodeBody(response);

    if (response.statusCode == 200) return body;

    final msg = body['message'] as String? ?? _defaultMessageFor(response);
    throw ApiException(msg, errors: body['errors'] as Map<String, dynamic>?);
  }

  static Future<void> resendVerification({required String email}) async {
    final response = await _post('/resend-verification', {'email': email});

    final body = _decodeBody(response);

    if (response.statusCode == 200) return;

    final msg = body['message'] as String? ?? _defaultMessageFor(response);
    throw ApiException(msg);
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

    if (response.statusCode == 403 && body['email_unverified'] == true) {
      throw ApiException(
        body['message'] as String? ?? 'Email not verified.',
        errors: {
          'email_unverified': true,
          'email': body['email'] ?? email,
        },
      );
    }

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

  static Future<Map<String, dynamic>> getCarousel() async {
    final response = await _get('/carousel');
    final body = _decodeBody(response);

    if (response.statusCode == 200) return body;

    final msg = body['message'] as String? ?? _defaultMessageFor(response);
    throw ApiException(msg, errors: body['errors'] as Map<String, dynamic>?);
  }

  static Future<Map<String, dynamic>> getFavorites() async {
    final response = await _get('/favorites', authenticated: true);
    final body = _decodeBody(response);

    if (response.statusCode == 200) return body;

    final msg = body['message'] as String? ?? _defaultMessageFor(response);
    throw ApiException(msg, errors: body['errors'] as Map<String, dynamic>?);
  }

  static Future<Map<String, dynamic>> addFavorite(int productId) async {
    final response = await _post(
      '/favorites/$productId',
      {},
      authenticated: true,
    );
    final body = _decodeBody(response);

    if (response.statusCode == 200) return body;

    final msg = body['message'] as String? ?? _defaultMessageFor(response);
    throw ApiException(msg, errors: body['errors'] as Map<String, dynamic>?);
  }

  static Future<Map<String, dynamic>> removeFavorite(int productId) async {
    final response = await _delete('/favorites/$productId');
    final body = _decodeBody(response);

    if (response.statusCode == 200) return body;

    final msg = body['message'] as String? ?? _defaultMessageFor(response);
    throw ApiException(msg, errors: body['errors'] as Map<String, dynamic>?);
  }

  static Future<Map<String, dynamic>> getCart() async {
    final response = await _get('/cart', authenticated: true);
    final body = _decodeBody(response);

    if (response.statusCode == 200) return body;

    final msg = body['message'] as String? ?? _defaultMessageFor(response);
    throw ApiException(msg, errors: body['errors'] as Map<String, dynamic>?);
  }

  static Future<Map<String, dynamic>> addCartItem({
    required int productId,
    required int quantity,
    String? size,
    String? crust,
  }) async {
    final response = await _post('/cart/items', {
      'product_id': productId,
      'quantity': quantity,
      if (size != null) 'size': size,
      if (crust != null) 'crust': crust,
    }, authenticated: true);
    final body = _decodeBody(response);

    if (response.statusCode == 201) return body;

    final msg = body['message'] as String? ?? _defaultMessageFor(response);
    throw ApiException(msg, errors: body['errors'] as Map<String, dynamic>?);
  }

  static Future<Map<String, dynamic>> updateCartItem({
    required int itemId,
    required int quantity,
  }) async {
    final response = await _patch('/cart/items/$itemId', {
      'quantity': quantity,
    });
    final body = _decodeBody(response);

    if (response.statusCode == 200) return body;

    final msg = body['message'] as String? ?? _defaultMessageFor(response);
    throw ApiException(msg, errors: body['errors'] as Map<String, dynamic>?);
  }

  static Future<Map<String, dynamic>> removeCartItem(int itemId) async {
    final response = await _delete('/cart/items/$itemId');
    final body = _decodeBody(response);

    if (response.statusCode == 200) return body;

    final msg = body['message'] as String? ?? _defaultMessageFor(response);
    throw ApiException(msg, errors: body['errors'] as Map<String, dynamic>?);
  }

  static Future<Map<String, dynamic>> clearCart() async {
    final response = await _delete('/cart');
    final body = _decodeBody(response);

    if (response.statusCode == 200) return body;

    final msg = body['message'] as String? ?? _defaultMessageFor(response);
    throw ApiException(msg, errors: body['errors'] as Map<String, dynamic>?);
  }

  static Future<Map<String, dynamic>> checkout({
    required String cardholderName,
    required String cardNumber,
    required int expMonth,
    required int expYear,
    required String cvv,
  }) async {
    final response = await _post('/checkout', {
      'cardholder_name': cardholderName,
      'card_number': cardNumber,
      'exp_month': expMonth,
      'exp_year': expYear,
      'cvv': cvv,
    }, authenticated: true);
    final body = _decodeBody(response);

    if (response.statusCode == 201) return body;

    final msg = body['message'] as String? ?? _defaultMessageFor(response);
    throw ApiException(msg, errors: body['errors'] as Map<String, dynamic>?);
  }

  static Future<Map<String, dynamic>> getOrders() async {
    final response = await _get('/orders', authenticated: true);
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
      return 'The server returned an internal error.';
    }

    return 'The request could not be completed.';
  }

  static List<String> _candidateBaseUrls() {
    final urls = <String>[];

    if (_configuredBaseUrl.isNotEmpty) {
      urls.add(_configuredBaseUrl);
    }

    if (Platform.isAndroid) {
      for (final url in [
        _androidReverseBaseUrl,
        _androidEmulatorFallbackBaseUrl,
        _lanBaseUrl,
      ]) {
        if (!urls.contains(url)) {
          urls.add(url);
        }
      }
    } else {
      for (final url in [
        'http://127.0.0.1:8010/api',
        'http://localhost:8010/api',
        _lanBaseUrl,
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
    Map<String, dynamic> payload, {
    bool authenticated = false,
  }) async {
    final attemptedUrls = <String>[];
    ApiException? lastNetworkError;

    for (final baseUrl in _candidateBaseUrls()) {
      attemptedUrls.add('$baseUrl$path');
      try {
        final response = await http
            .post(
              Uri.parse('$baseUrl$path'),
              headers: authenticated ? _authHeaders() : _headers,
              body: jsonEncode(payload),
            )
            .timeout(_requestTimeout);
        _activeBaseUrl = baseUrl;
        return response;
      } on SocketException {
        lastNetworkError = ApiException(
          'Could not connect to $baseUrl. URLs tried: ${attemptedUrls.join(', ')}',
        );
      } on TimeoutException {
        lastNetworkError = ApiException(
          'The server took too long to respond ($baseUrl$path). URLs tried: ${attemptedUrls.join(', ')}',
        );
      } on http.ClientException catch (e) {
        lastNetworkError = ApiException(
          'Network error at $baseUrl: ${e.message}. URLs tried: ${attemptedUrls.join(', ')}',
        );
      }
    }

    throw lastNetworkError ??
        ApiException(
          'The request could not be completed. URLs tried: ${attemptedUrls.join(', ')}',
        );
  }

  static Future<http.Response> _get(
    String path, {
    bool authenticated = false,
  }) async {
    final attemptedUrls = <String>[];
    ApiException? lastNetworkError;

    for (final baseUrl in _candidateBaseUrls()) {
      attemptedUrls.add('$baseUrl$path');
      try {
        final response = await http
            .get(
              Uri.parse('$baseUrl$path'),
              headers: authenticated ? _authHeaders() : _headers,
            )
            .timeout(_requestTimeout);
        _activeBaseUrl = baseUrl;
        return response;
      } on SocketException {
        lastNetworkError = ApiException(
          'Could not connect to $baseUrl. URLs tried: ${attemptedUrls.join(', ')}',
        );
      } on TimeoutException {
        lastNetworkError = ApiException(
          'The server took too long to respond ($baseUrl$path). URLs tried: ${attemptedUrls.join(', ')}',
        );
      } on http.ClientException catch (e) {
        lastNetworkError = ApiException(
          'Network error at $baseUrl: ${e.message}. URLs tried: ${attemptedUrls.join(', ')}',
        );
      }
    }

    throw lastNetworkError ??
        ApiException(
          'The request could not be completed. URLs tried: ${attemptedUrls.join(', ')}',
        );
  }

  static Future<http.Response> _patch(
    String path,
    Map<String, dynamic> payload,
  ) async {
    final attemptedUrls = <String>[];
    ApiException? lastNetworkError;

    for (final baseUrl in _candidateBaseUrls()) {
      attemptedUrls.add('$baseUrl$path');
      try {
        final response = await http
            .patch(
              Uri.parse('$baseUrl$path'),
              headers: _authHeaders(),
              body: jsonEncode(payload),
            )
            .timeout(_requestTimeout);
        _activeBaseUrl = baseUrl;
        return response;
      } on SocketException {
        lastNetworkError = ApiException(
          'Could not connect to $baseUrl. URLs tried: ${attemptedUrls.join(', ')}',
        );
      } on TimeoutException {
        lastNetworkError = ApiException(
          'The server took too long to respond ($baseUrl$path). URLs tried: ${attemptedUrls.join(', ')}',
        );
      } on http.ClientException catch (e) {
        lastNetworkError = ApiException(
          'Network error at $baseUrl: ${e.message}. URLs tried: ${attemptedUrls.join(', ')}',
        );
      }
    }

    throw lastNetworkError ??
        ApiException(
          'The request could not be completed. URLs tried: ${attemptedUrls.join(', ')}',
        );
  }

  static Future<http.Response> _delete(String path) async {
    final attemptedUrls = <String>[];
    ApiException? lastNetworkError;

    for (final baseUrl in _candidateBaseUrls()) {
      attemptedUrls.add('$baseUrl$path');
      try {
        final response = await http
            .delete(Uri.parse('$baseUrl$path'), headers: _authHeaders())
            .timeout(_requestTimeout);
        _activeBaseUrl = baseUrl;
        return response;
      } on SocketException {
        lastNetworkError = ApiException(
          'Could not connect to $baseUrl. URLs tried: ${attemptedUrls.join(', ')}',
        );
      } on TimeoutException {
        lastNetworkError = ApiException(
          'The server took too long to respond ($baseUrl$path). URLs tried: ${attemptedUrls.join(', ')}',
        );
      } on http.ClientException catch (e) {
        lastNetworkError = ApiException(
          'Network error at $baseUrl: ${e.message}. URLs tried: ${attemptedUrls.join(', ')}',
        );
      }
    }

    throw lastNetworkError ??
        ApiException(
          'The request could not be completed. URLs tried: ${attemptedUrls.join(', ')}',
        );
  }

  static Future<Map<String, dynamic>> getUserProfile() async {
    final response = await _get('/user', authenticated: true);
    final body = _decodeBody(response);

    if (response.statusCode == 200) return body;

    final msg = body['message'] as String? ?? _defaultMessageFor(response);
    throw ApiException(msg, errors: body['errors'] as Map<String, dynamic>?);
  }

  static Future<Map<String, dynamic>> updateUserProfile({
    required String name,
    required String lastname,
  }) async {
    final response = await _put('/user/profile', {'name': name, 'lastname': lastname});
    final body = _decodeBody(response);

    if (response.statusCode == 200) {
      await SessionManager.save(
        token: SessionManager.token!,
        user: Map<String, dynamic>.from(body['user'] as Map),
      );
      return body;
    }

    final msg = body['message'] as String? ?? _defaultMessageFor(response);
    throw ApiException(msg, errors: body['errors'] as Map<String, dynamic>?);
  }

  static Future<http.Response> _put(
    String path,
    Map<String, dynamic> payload,
  ) async {
    final attemptedUrls = <String>[];
    ApiException? lastNetworkError;

    for (final baseUrl in _candidateBaseUrls()) {
      attemptedUrls.add('$baseUrl$path');
      try {
        final response = await http
            .put(
              Uri.parse('$baseUrl$path'),
              headers: _authHeaders(),
              body: jsonEncode(payload),
            )
            .timeout(_requestTimeout);
        _activeBaseUrl = baseUrl;
        return response;
      } on SocketException {
        lastNetworkError = ApiException(
          'Could not connect to $baseUrl. URLs tried: ${attemptedUrls.join(', ')}',
        );
      } on TimeoutException {
        lastNetworkError = ApiException(
          'The server took too long to respond ($baseUrl$path). URLs tried: ${attemptedUrls.join(', ')}',
        );
      } on http.ClientException catch (e) {
        lastNetworkError = ApiException(
          'Network error at $baseUrl: ${e.message}. URLs tried: ${attemptedUrls.join(', ')}',
        );
      }
    }

    throw lastNetworkError ??
        ApiException(
          'The request could not be completed. URLs tried: ${attemptedUrls.join(', ')}',
        );
  }

  static Map<String, String> _authHeaders() {
    final token = SessionManager.token;
    if (token == null || token.isEmpty) {
      throw ApiException('Please sign in to continue.');
    }

    return {..._headers, 'Authorization': 'Bearer $token'};
  }
}
