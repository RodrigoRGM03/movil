import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:posly/app/posly_app.dart';
import 'package:posly/core/api/api_client.dart';
import 'package:posly/core/auth/auth_controller.dart';
import 'package:posly/core/auth/auth_repository.dart';

void main() {
  testWidgets('welcome screen switches theme and opens account form', (
    tester,
  ) async {
    final auth = AuthController(_FakeAuthGateway());
    await auth.restoreSession();

    await tester.pumpWidget(PoslyApp(auth: auth, api: ApiClient()));
    await tester.pumpAndSettle();

    expect(find.text('Empieza hoy'), findsOneWidget);
    await tester.tap(find.byTooltip('Modo oscuro'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Modo claro'), findsOneWidget);

    await tester.tap(find.text('Crear cuenta'));
    await tester.pumpAndSettle();
    expect(find.text('Nombre completo'), findsOneWidget);
    expect(find.text('Confirmar contraseña'), findsOneWidget);
  });

  testWidgets('registration form validates required and matching fields', (
    tester,
  ) async {
    final auth = AuthController(_FakeAuthGateway());
    await auth.restoreSession();

    await tester.pumpWidget(PoslyApp(auth: auth, api: ApiClient()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Crear cuenta'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(
      find.widgetWithText(ElevatedButton, 'Crear cuenta'),
    );
    await tester.tap(find.widgetWithText(ElevatedButton, 'Crear cuenta'));
    await tester.pumpAndSettle();
    expect(find.text('Escribe tu nombre.'), findsOneWidget);
    expect(find.text('Escribe tu correo electrónico.'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nombre completo'),
      'Ana',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Correo electrónico'),
      'ana@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Contraseña'),
      'password123',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Confirmar contraseña'),
      'different123',
    );
    await tester.ensureVisible(
      find.widgetWithText(ElevatedButton, 'Crear cuenta'),
    );
    await tester.tap(find.widgetWithText(ElevatedButton, 'Crear cuenta'));
    await tester.pumpAndSettle();
    expect(find.text('Las contraseñas no coinciden.'), findsOneWidget);
  });

  testWidgets('demo session opens dashboard without calling the API', (
    tester,
  ) async {
    final auth = AuthController(_FakeAuthGateway());
    await auth.restoreSession();
    auth.enterDemoMode();

    await tester.pumpWidget(PoslyApp(auth: auth, api: ApiClient()));
    await tester.pumpAndSettle();

    expect(find.text('Resumen del negocio'), findsOneWidget);
    expect(find.text('Ventas de hoy'), findsOneWidget);
    expect(
      find.text('Modo demostración: los datos son de ejemplo y no se guardan.'),
      findsOneWidget,
    );
    expect(find.textContaining('Configura API_BASE_URL'), findsNothing);
  });
}

class _FakeAuthGateway implements AuthGateway {
  @override
  Future<AuthResult?> restoreSession() async => null;

  @override
  Future<AuthResult> login(String email, String password) async =>
      const AuthResult(token: 'test-token', name: 'Ana');

  @override
  Future<AuthResult?> register({
    required String name,
    required String email,
    required String password,
  }) async => null;

  @override
  Future<void> sendPasswordReset(String email) async {}

  @override
  Future<void> logout() async {}
}
