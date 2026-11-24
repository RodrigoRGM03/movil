import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/services.dart';

import '../api/api_client.dart';

class AuthResult {
  const AuthResult({required this.token, this.name});

  final String token;
  final String? name;
}

abstract interface class AuthGateway {
  Future<AuthResult?> restoreSession();
  Future<AuthResult> login(String email, String password);
  Future<AuthResult?> register({
    required String name,
    required String email,
    required String password,
  });
  Future<void> sendPasswordReset(String email);
  Future<void> logout();
}

class AuthRepository implements AuthGateway {
  AuthRepository(this._api, {FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _tokenKey = 'posly_access_token';

  final ApiClient _api;
  final FlutterSecureStorage _storage;
  String? _token;

  @override
  Future<AuthResult?> restoreSession() async {
    try {
      _token = await _storage.read(key: _tokenKey);
    } on PlatformException {
      throw const ApiException(
        'No se pudo acceder al almacenamiento seguro del dispositivo.',
      );
    }
    if (_token == null || _token!.isEmpty) return null;
    return AuthResult(token: _token!);
  }

  @override
  Future<AuthResult> login(String email, String password) async {
    final response = await _api.postJson(
      'auth/login',
      body: {'email': email, 'password': password},
    );
    return _saveResult(response);
  }

  @override
  Future<AuthResult?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _api.postJson(
      'auth/register',
      body: {'name': name, 'email': email, 'password': password},
    );
    final result = _readResult(response);
    if (result != null) await _saveToken(result.token);
    return result;
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    await _api.postJson('auth/forgot-password', body: {'email': email});
  }

  @override
  Future<void> logout() async {
    final token = _token;
    try {
      await _storage.delete(key: _tokenKey);
    } on PlatformException {
      throw const ApiException(
        'No se pudo borrar la sesión del almacenamiento seguro.',
      );
    }
    _token = null;
    if (token != null) {
      await _api.postJson('auth/logout', token: token);
    }
  }

  Future<AuthResult> _saveResult(dynamic response) async {
    final result = _readResult(response);
    if (result == null) {
      throw const ApiException(
        'La respuesta de autenticación no incluyó un token de acceso.',
      );
    }
    await _saveToken(result.token);
    return result;
  }

  Future<void> _saveToken(String token) async {
    try {
      await _storage.write(key: _tokenKey, value: token);
    } on PlatformException {
      throw const ApiException(
        'No se pudo guardar la sesión en el almacenamiento seguro.',
      );
    }
    _token = token;
  }

  AuthResult? _readResult(dynamic response) {
    if (response is! Map<String, dynamic>) return null;
    final data = response['data'];
    final payload = data is Map<String, dynamic> ? data : response;
    final token = payload['token'] ?? payload['access_token'];
    if (token is! String || token.isEmpty) return null;
    final user = payload['user'];
    final name = user is Map<String, dynamic> && user['name'] is String
        ? user['name'] as String
        : null;
    return AuthResult(token: token, name: name);
  }
}
