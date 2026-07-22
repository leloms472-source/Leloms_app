import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiService {
  final String baseUrl;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static const _tokenKey = 'auth_token';
  static const _refreshTokenKey = 'refresh_token';

  final http.Client _client = http.Client();
  Duration timeout = const Duration(seconds: 30);
  int maxRetries = 3;

  ApiService({required this.baseUrl});

  Future<String?> get accessToken async =>
      await _secureStorage.read(key: _tokenKey);

  Future<void> setTokens(String token, String refreshToken) async {
    await _secureStorage.write(key: _tokenKey, value: token);
    await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<void> clearTokens() async {
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
  }

  Future<Map<String, String>> _buildHeaders({
    bool includeAuth = true,
    Map<String, String>? extra,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (includeAuth) {
      final token = await accessToken;
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    if (extra != null) headers.addAll(extra);
    return headers;
  }

  Future<Map<String, dynamic>> get(String path, {Map<String, String>? queryParams}) async {
    return _request('GET', path, queryParams: queryParams);
  }

  Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? body}) async {
    return _request('POST', path, body: body);
  }

  Future<Map<String, dynamic>> put(String path, {Map<String, dynamic>? body}) async {
    return _request('PUT', path, body: body);
  }

  Future<Map<String, dynamic>> delete(String path) async {
    return _request('DELETE', path);
  }

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
    int retryCount = 0,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$path')
          .replace(queryParameters: queryParams);
      final headers = await _buildHeaders();

      http.Response response;
      switch (method) {
        case 'GET':
          response = await _client.get(uri, headers: headers).timeout(timeout);
        case 'POST':
          response = await _client.post(uri, headers: headers, body: body != null ? jsonEncode(body) : null).timeout(timeout);
        case 'PUT':
          response = await _client.put(uri, headers: headers, body: body != null ? jsonEncode(body) : null).timeout(timeout);
        case 'DELETE':
          response = await _client.delete(uri, headers: headers).timeout(timeout);
        default:
          throw ApiException(0, 'Método no soportado: $method');
      }

      if (response.statusCode == 401 && retryCount < 1) {
        await _tryRefreshToken();
        return _request(method, path, body: body, retryCount: retryCount + 1);
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(response.statusCode, response.body);
      }

      if (response.body.isEmpty) return {};
      return jsonDecode(response.body) as Map<String, dynamic>;
    } on Exception {
      if (retryCount < maxRetries) {
        await Future.delayed(Duration(seconds: 1 * (retryCount + 1)));
        return _request(method, path, body: body, retryCount: retryCount + 1);
      }
      throw ApiException(0, 'Error de conexión');
    }
  }

  Future<void> _tryRefreshToken() async {
    final refreshToken = await _secureStorage.read(key: _refreshTokenKey);
    if (refreshToken == null) return;

    try {
      final uri = Uri.parse('$baseUrl/auth/refresh');
      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      ).timeout(timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        await setTokens(
          data['token'] as String,
          data['refreshToken'] as String,
        );
      } else {
        await clearTokens();
      }
    } catch (_) {
      await clearTokens();
    }
  }
}
