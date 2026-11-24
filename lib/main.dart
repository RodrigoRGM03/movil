import 'package:flutter/material.dart';

import 'app/posly_app.dart';
import 'core/api/api_client.dart';
import 'core/auth/auth_controller.dart';
import 'core/auth/auth_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final api = ApiClient();
  final auth = AuthController(AuthRepository(api));
  runApp(PoslyApp(auth: auth, api: api));
  auth.restoreSession();
}
