import 'dart:convert';
import 'dart:io';
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
      final client = HttpClient()..connectionTimeout = timeout;

      final uri = Uri.parse('$baseUrl$path')
          .replace(queryParameters: queryParams);
      final request = await client.openUrl(method, uri);

      final headers = await _buildHeaders();
      headers.forEach((k, v) => request.headers.set(k, v));

      if (body != null) {
        request.add(utf8.encode(jsonEncode(body)));
      }

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode == 401 && retryCount < 1) {
        await _tryRefreshToken();
        return _request(method, path, body: body, retryCount: retryCount + 1);
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(response.statusCode, responseBody);
      }

      if (responseBody.isEmpty) return {};
      return jsonDecode(responseBody) as Map<String, dynamic>;
    } on SocketException {
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
      final client = HttpClient()..connectionTimeout = timeout;
      final request = await client.postUrl(Uri.parse('$baseUrl/auth/refresh'));
      request.headers.set('Content-Type', 'application/json');
      request.add(utf8.encode(jsonEncode({'refreshToken': refreshToken})));
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();

      if (response.statusCode == 200) {
        final data = jsonDecode(body) as Map<String, dynamic>;
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
