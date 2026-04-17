import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../storage/local_storage.dart';

class ApiClient {
  static String get _baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8080/api';
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8080/api';
    }
    return 'http://localhost:8080/api';
  }

  final LocalStorage _localStorage;
  final http.Client _client;

  ApiClient({required LocalStorage localStorage, http.Client? client})
    : _localStorage = localStorage,
      _client = client ?? http.Client();

  Map<String, String> _getHeaders({bool requireAuth = true}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requireAuth) {
      final token = _localStorage.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  Future<Map<String, dynamic>> get(
    String endpoint, {
    bool requireAuth = true,
  }) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    final response = await _client.get(
      uri,
      headers: _getHeaders(requireAuth: requireAuth),
    );

    return _processResponse(response);
  }

  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requireAuth = true,
  }) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    final response = await _client.post(
      uri,
      headers: _getHeaders(requireAuth: requireAuth),
      body: body != null ? jsonEncode(body) : null,
    );

    return _processResponse(response);
  }

  /// POST with a top-level JSON array or any encodable value (not only [Map]).
  Future<Map<String, dynamic>> postJson(
    String endpoint, {
    required Object body,
    bool requireAuth = true,
  }) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    final response = await _client.post(
      uri,
      headers: _getHeaders(requireAuth: requireAuth),
      body: jsonEncode(body),
    );

    return _processResponse(response);
  }

  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requireAuth = true,
  }) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    final response = await _client.put(
      uri,
      headers: _getHeaders(requireAuth: requireAuth),
      body: body != null ? jsonEncode(body) : null,
    );

    return _processResponse(response);
  }

  Future<Map<String, dynamic>> patch(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requireAuth = true,
  }) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    final response = await _client.patch(
      uri,
      headers: _getHeaders(requireAuth: requireAuth),
      body: body != null ? jsonEncode(body) : null,
    );

    return _processResponse(response);
  }

  Future<Map<String, dynamic>> delete(
    String endpoint, {
    bool requireAuth = true,
  }) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    final response = await _client.delete(
      uri,
      headers: _getHeaders(requireAuth: requireAuth),
    );

    return _processResponse(response);
  }

  Map<String, dynamic> _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isNotEmpty) {
        return jsonDecode(response.body);
      }
      return {};
    } else {
      String message = 'Unexpected error occurred.';
      try {
        final body = jsonDecode(response.body);
        if (body is Map<String, dynamic>) {
          if (body['message'] != null) {
            message = body['message'].toString();
          } else if (body['error'] != null) {
            message = body['error'].toString();
          } else if (body['detail'] != null) {
            message = body['detail'].toString();
          }
        }
      } catch (_) {
        message = response.reasonPhrase ?? message;
      }
      debugPrint('API ERROR [${response.statusCode}] ${response.request?.url}: $message');
      debugPrint('Response body: ${response.body}');
      throw Exception('[${ response.statusCode}] $message');
    }
  }
}
