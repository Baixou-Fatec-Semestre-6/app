import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/env_config.dart';
import '../storage/auth_storage.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  ApiException(this.message, {this.statusCode, this.errors});

  @override
  String toString() => message;
}

class ApiClient {
  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, String>> _getHeaders({bool requiresAuth = true}) async {
    final headers = <String, String>{'Accept': 'application/json'};

    if (requiresAuth) {
      final token = await AuthStorage.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  Uri _buildUri(String path) {
    final baseUrl = EnvConfig.apiBaseUrl.endsWith('/')
        ? EnvConfig.apiBaseUrl.substring(0, EnvConfig.apiBaseUrl.length - 1)
        : EnvConfig.apiBaseUrl;

    final cleanPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$baseUrl$cleanPath');
  }

  void _log(String message) {
    if (EnvConfig.enableDebugLogs) {
      debugPrint('[ApiClient] $message');
    }
  }

  String _safePayload(Map<String, dynamic> body) {
    const sensitiveKeys = {
      'password',
      'password_confirmation',
      'reset_token',
      'token',
      'code',
    };
    final safeBody = body.map(
      (key, value) =>
          MapEntry(key, sensitiveKeys.contains(key) ? '***' : value),
    );
    return jsonEncode(safeBody);
  }

  Future<Map<String, dynamic>> get(
    String path, {
    bool requiresAuth = true,
  }) async {
    final uri = _buildUri(path);
    final headers = await _getHeaders(requiresAuth: requiresAuth);

    _log('GET $uri');
    try {
      final response = await _client
          .get(uri, headers: headers)
          .timeout(EnvConfig.apiTimeout);
      return _processResponse(response);
    } on TimeoutException {
      throw ApiException(
        'Tempo limite da requisição excedido. Verifique sua conexão.',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erro de conexão com o servidor: $e');
    }
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    bool requiresAuth = false,
  }) async {
    final uri = _buildUri(path);
    final headers = await _getHeaders(requiresAuth: requiresAuth);
    final bodyJson = body != null ? jsonEncode(body) : null;
    if (bodyJson != null) headers['Content-Type'] = 'application/json';

    _log('POST $uri');
    if (body != null) _log('Payload: ${_safePayload(body)}');

    try {
      final response = await _client
          .post(uri, headers: headers, body: bodyJson)
          .timeout(EnvConfig.apiTimeout);
      return _processResponse(response);
    } on TimeoutException {
      throw ApiException(
        'Tempo limite da requisição excedido. Verifique sua conexão.',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erro de conexão com o servidor: $e');
    }
  }

  Future<Map<String, dynamic>> patch(
    String path, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    final uri = _buildUri(path);
    final headers = await _getHeaders(requiresAuth: requiresAuth);
    if (body != null) headers['Content-Type'] = 'application/json';
    try {
      final response = await _client
          .patch(
            uri,
            headers: headers,
            body: body == null ? null : jsonEncode(body),
          )
          .timeout(EnvConfig.apiTimeout);
      return _processResponse(response);
    } on TimeoutException {
      throw ApiException(
        'Tempo limite da requisição excedido. Verifique sua conexão.',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erro de conexão com o servidor: $e');
    }
  }

  Future<Map<String, dynamic>> delete(
    String path, {
    bool requiresAuth = true,
  }) async {
    final uri = _buildUri(path);
    final headers = await _getHeaders(requiresAuth: requiresAuth);
    try {
      final response = await _client
          .delete(uri, headers: headers)
          .timeout(EnvConfig.apiTimeout);
      return _processResponse(response);
    } on TimeoutException {
      throw ApiException(
        'Tempo limite da requisição excedido. Verifique sua conexão.',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erro de conexão com o servidor: $e');
    }
  }

  Map<String, dynamic> _processResponse(http.Response response) {
    _log('Response (${response.statusCode}): ${response.body}');

    Map<String, dynamic> body = {};
    if (response.body.isNotEmpty) {
      try {
        body = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (_) {
        body = {'message': response.body};
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    // Handle Unauthenticated
    if (response.statusCode == 401) {
      AuthStorage.clearAll();
      final msg = body['message'] ?? 'Sessão expirada. Faça login novamente.';
      throw ApiException(msg, statusCode: 401);
    }

    // Handle Validation Errors (Laravel standard 422)
    if (response.statusCode == 422) {
      String errorMessage = body['message'] ?? 'Dados inválidos.';
      Map<String, dynamic>? validationErrors;

      if (body.containsKey('errors') && body['errors'] is Map) {
        validationErrors = body['errors'] as Map<String, dynamic>;
        final firstKey = validationErrors.keys.first;
        final firstErrorList = validationErrors[firstKey];
        if (firstErrorList is List && firstErrorList.isNotEmpty) {
          errorMessage = firstErrorList.first.toString();
        }
      }

      throw ApiException(
        errorMessage,
        statusCode: 422,
        errors: validationErrors,
      );
    }

    final message =
        body['message'] ??
        body['mensagem'] ??
        'Erro no servidor (${response.statusCode})';
    throw ApiException(message, statusCode: response.statusCode);
  }
}
