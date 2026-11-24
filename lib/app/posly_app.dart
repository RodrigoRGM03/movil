import 'package:flutter/material.dart';

import '../core/api/api_client.dart';
import '../core/auth/auth_controller.dart';
import '../features/auth/auth_screen.dart';
import '../features/shell/posly_shell.dart';
import 'posly_theme.dart';

class PoslyApp extends StatefulWidget {
  const PoslyApp({required this.auth, required this.api, super.key});

  final AuthController auth;
  final ApiClient api;

  @override
  State<PoslyApp> createState() => _PoslyAppState();
}

class _PoslyAppState extends State<PoslyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.auth,
      builder: (context, _) => MaterialApp(
        title: 'PoSly',
        debugShowCheckedModeBanner: false,
        theme: PoslyTheme.light,
        darkTheme: PoslyTheme.dark,
        themeMode: _themeMode,
        home: widget.auth.isInitializing
            ? const _StartupScreen()
            : widget.auth.isAuthenticated
            ? PoslyShell(
                auth: widget.auth,
                api: widget.api,
                onToggleTheme: _toggleTheme,
                isDarkMode: _themeMode == ThemeMode.dark,
              )
            : AuthScreen(
                auth: widget.auth,
                onToggleTheme: _toggleTheme,
                isDarkMode: _themeMode == ThemeMode.dark,
              ),
      ),
    );
  }
}

class _StartupScreen extends StatelessWidget {
  const _StartupScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
