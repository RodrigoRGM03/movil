import 'package:flutter/foundation.dart';

import '../api/api_client.dart';
import 'auth_repository.dart';

class AuthController extends ChangeNotifier {
  AuthController(this._gateway);

  final AuthGateway _gateway;

  bool isInitializing = true;
  bool isBusy = false;
  bool isAuthenticated = false;
  bool isDemo = false;
  String? userName;
  String? errorMessage;
  String? _token;

  String? get accessToken => _token;

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  void enterDemoMode() {
    isDemo = true;
    isAuthenticated = true;
    userName = 'Demo';
    _token = null;
    errorMessage = null;
    notifyListeners();
  }

  Future<void> restoreSession() async {
    try {
      final session = await _gateway.restoreSession();
      _setSession(session);
    } on ApiException catch (error) {
      errorMessage = error.message;
    } finally {
      isInitializing = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    return _run(() async {
      final session = await _gateway.login(email, password);
      _setSession(session);
    });
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    return _run(() async {
      final session = await _gateway.register(
        name: name,
        email: email,
        password: password,
      );
      if (session != null) _setSession(session);
    });
  }

  Future<bool> sendPasswordReset(String email) async {
    return _run(() => _gateway.sendPasswordReset(email));
  }

  Future<void> logout() async {
    if (isDemo) {
      isDemo = false;
      _setSession(null);
      errorMessage = null;
      notifyListeners();
      return;
    }
    final previousToken = _token;
    _setSession(null);
    errorMessage = null;
    notifyListeners();
    try {
      await _gateway.logout();
    } on ApiException catch (error) {
      errorMessage = error.message;
      notifyListeners();
    } finally {
      if (previousToken == null) _token = null;
    }
  }

  Future<bool> _run(Future<void> Function() action) async {
    isBusy = true;
    errorMessage = null;
    notifyListeners();
    try {
      await action();
      return true;
    } on ApiException catch (error) {
      errorMessage = error.message;
      return false;
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  void _setSession(AuthResult? session) {
    isDemo = false;
    _token = session?.token;
    userName = session?.name;
    isAuthenticated = session != null;
  }
}
