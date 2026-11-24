import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  static const _baseUrl = String.fromEnvironment('API_BASE_URL');
  final http.Client _client;

  Future<dynamic> getJson(String path, {String? token}) =>
      _send('GET', path, token: token);

  Future<dynamic> postJson(
    String path, {
    Map<String, Object?> body = const {},
    String? token,
  }) => _send('POST', path, body: body, token: token);

  Future<dynamic> _send(
    String method,
    String path, {
    Map<String, Object?>? body,
    String? token,
  }) async {
    final base = _baseUrl.trim().replaceFirst(RegExp(r'/+$'), '');
    if (base.isEmpty) {
      throw const ApiException(
        'Configura API_BASE_URL para conectar con el backend Laravel.',
      );
    }

    late final Uri uri;
    try {
      uri = Uri.parse('$base/${path.replaceFirst(RegExp(r'^/+'), '')}');
      if (!uri.hasScheme || (uri.scheme != 'https' && uri.scheme != 'http')) {
        throw const FormatException();
      }
    } on FormatException {
      throw const ApiException(
        'API_BASE_URL debe ser una URL HTTP o HTTPS válida.',
      );
    }

    final headers = <String, String>{
      'Accept': 'application/json',
      if (body != null) 'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    try {
      final response = await switch (method) {
        'GET' =>
          _client
              .get(uri, headers: headers)
              .timeout(const Duration(seconds: 20)),
        _ =>
          _client
              .post(uri, headers: headers, body: jsonEncode(body))
              .timeout(const Duration(seconds: 20)),
      };

      final dynamic decoded;
      if (response.body.isEmpty) {
        decoded = null;
      } else {
        try {
          decoded = jsonDecode(response.body);
        } on FormatException {
          throw const ApiException(
            'El servidor respondió con un formato que no es JSON.',
          );
        }
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(_errorMessage(decoded, response.statusCode));
      }
      return decoded;
    } on http.ClientException {
      throw const ApiException(
        'No se pudo conectar con el servidor. Revisa la URL y tu conexión.',
      );
    } on TimeoutException {
      throw const ApiException(
        'La solicitud tardó demasiado. Intenta de nuevo.',
      );
    }
  }

  String _errorMessage(dynamic response, int statusCode) {
    if (response is Map<String, dynamic>) {
      final message = response['message'];
      if (message is String && message.trim().isNotEmpty) return message;
      final errors = response['errors'];
      if (errors is Map<String, dynamic>) {
        for (final value in errors.values) {
          if (value is List && value.isNotEmpty && value.first is String) {
            return value.first as String;
          }
        }
      }
    }
    return 'La solicitud falló (HTTP $statusCode).';
  }
}
