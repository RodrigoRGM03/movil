import 'package:flutter/material.dart';

import '../../app/demo_mode.dart';
import '../../app/posly_theme.dart';
import '../../core/auth/auth_controller.dart';
import '../../shared/posly_brand_mark.dart';

enum _AuthMode { welcome, login, register, forgotPassword }

class AuthScreen extends StatefulWidget {
  const AuthScreen({
    required this.auth,
    required this.onToggleTheme,
    required this.isDarkMode,
    super.key,
  });

  final AuthController auth;
  final VoidCallback onToggleTheme;
  final bool isDarkMode;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  _AuthMode _mode = _AuthMode.welcome;
  bool _obscurePassword = true;
  String? _successMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _setMode(_AuthMode mode) {
    widget.auth.clearError();
    setState(() {
      _mode = mode;
      _successMessage = null;
      _formKey.currentState?.reset();
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _successMessage = null);

    switch (_mode) {
      case _AuthMode.login:
        await widget.auth.login(
          _emailController.text.trim(),
          _passwordController.text,
        );
      case _AuthMode.register:
        final success = await widget.auth.register(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        if (success && mounted && !widget.auth.isAuthenticated) {
          setState(() {
            _mode = _AuthMode.login;
            _successMessage =
                'Cuenta creada. Inicia sesión para comenzar a usar PoSly.';
          });
        }
      case _AuthMode.forgotPassword:
        final success = await widget.auth.sendPasswordReset(
          _emailController.text.trim(),
        );
        if (success && mounted) {
          setState(() {
            _successMessage = 'Si el correo está registrado, recibirás instrucciones para recuperar tu contraseña.';
          });
        }
      case _AuthMode.welcome:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1120),
                  child: wide ? _wideLayout() : _compactLayout(),
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 12,
              child: IconButton(
                tooltip: widget.isDarkMode ? 'Modo claro' : 'Modo oscuro',
                onPressed: widget.onToggleTheme,
                icon: Icon(
                  widget.isDarkMode
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _wideLayout() {
    return Row(
      children: [
        Expanded(child: _heroPanel()),
        const SizedBox(width: 58),
        SizedBox(width: 420, child: _authPanel()),
      ],
    );
  }

  Widget _compactLayout() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_mode == _AuthMode.welcome) ...[
          const SizedBox(height: 24),
          _compactHero(),
          const SizedBox(height: 30),
        ] else ...[
          const PoslyBrandMark(),
          const SizedBox(height: 24),
        ],
        _authPanel(),
      ],
    );
  }

  Widget _heroPanel() {
    return Container(
      constraints: const BoxConstraints(minHeight: 580),
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: PoslyColors.navy,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const PoslyBrandMark(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tu negocio,\nsiempre en control.',
                style: TextStyle(
                  color: PoslyColors.white,
                  fontSize: 44,
                  height: 1.12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.5,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Ventas, inventario y clientes en un solo lugar. '
                'Una forma más sencilla de hacer crecer tu tienda.',
                style: TextStyle(
                  color: PoslyColors.white.withValues(alpha: 0.75),
                  fontSize: 17,
                  height: 1.6,
                ),
              ),
            ],
          ),
          Row(
            children: [
              _heroFeature(Icons.bolt_rounded, 'Rápido'),
              const SizedBox(width: 26),
              _heroFeature(Icons.insights_rounded, 'Claro'),
              const SizedBox(width: 26),
              _heroFeature(Icons.shield_outlined, 'Seguro'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroFeature(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: PoslyColors.turquoise, size: 19),
        const SizedBox(width: 7),
        Text(
          label,
          style: const TextStyle(
            color: PoslyColors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _compactHero() {
    return Column(
      children: [
        const PoslyBrandMark(),
        const SizedBox(height: 22),
        Text(
          'Tu negocio,\nsiempre en control.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium
              ?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -1),
        ),
        const SizedBox(height: 10),
        Text(
          'Ventas, inventario y clientes en un solo lugar.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }

  Widget _authPanel() {
    if (_mode == _AuthMode.welcome) return _welcomePanel();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _heading,
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(_subheading),
              const SizedBox(height: 24),
              if (_mode == _AuthMode.register) ...[
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Nombre completo',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                  validator: (value) => value == null || value.trim().length < 2
                      ? 'Escribe tu nombre.'
                      : null,
                ),
                const SizedBox(height: 14),
              ],
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                  prefixIcon: Icon(Icons.mail_outline_rounded),
                ),
                validator: _validateEmail,
              ),
              if (_mode != _AuthMode.forgotPassword) ...[
                const SizedBox(height: 14),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: _mode == _AuthMode.register
                      ? TextInputAction.next
                      : TextInputAction.done,
                  autofillHints: _mode == _AuthMode.login
                      ? const [AutofillHints.password]
                      : const [AutofillHints.newPassword],
                  onFieldSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      tooltip: _obscurePassword
                          ? 'Mostrar contraseña'
                          : 'Ocultar contraseña',
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Escribe tu contraseña.';
                    }
                    if (_mode == _AuthMode.register && value.length < 8) {
                      return 'Usa al menos 8 caracteres.';
                    }
                    return null;
                  },
                ),
              ],
              if (_mode == _AuthMode.register) ...[
                const SizedBox(height: 14),
                TextFormField(
                  controller: _confirmController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  decoration: const InputDecoration(
                    labelText: 'Confirmar contraseña',
                    prefixIcon: Icon(Icons.lock_outline_rounded),
                  ),
                  validator: (value) => value != _passwordController.text
                      ? 'Las contraseñas no coinciden.'
                      : null,
                ),
              ],
              if (_mode == _AuthMode.login)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => _setMode(_AuthMode.forgotPassword),
                    child: const Text('¿Olvidaste tu contraseña?'),
                  ),
                ),
              if (widget.auth.errorMessage != null) ...[
                const SizedBox(height: 12),
                _notice(widget.auth.errorMessage!, isError: true),
              ],
              if (_successMessage != null) ...[
                const SizedBox(height: 12),
                _notice(_successMessage!),
              ],
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: widget.auth.isBusy ? null : _submit,
                child: widget.auth.isBusy
                    ? const SizedBox(
                        width: 21,
                        height: 21,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_submitLabel),
              ),
              const SizedBox(height: 14),
              TextButton(
                onPressed: () => _setMode(
                  _mode == _AuthMode.login
                      ? _AuthMode.register
                      : _AuthMode.login,
                ),
                child: Text(
                  _mode == _AuthMode.login
                      ? '¿No tienes cuenta? Crear cuenta'
                      : '¿Ya tienes cuenta? Iniciar sesión',
                ),
              ),
              if (isDemoModeEnabled) ...[
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: widget.auth.enterDemoMode,
                  icon: const Icon(Icons.visibility_outlined),
                  label: const Text('Explorar dashboard de demostración'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(48, 48),
                    foregroundColor: Theme.of(context).colorScheme.onSurface,
                    side: const BorderSide(color: PoslyColors.blueGray),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
              if (_mode == _AuthMode.forgotPassword)
                TextButton(
                  onPressed: () => _setMode(_AuthMode.login),
                  child: const Text('Volver a iniciar sesión'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _welcomePanel() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Empieza hoy',
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            const Text('Administra tu punto de venta con más claridad.'),
            const SizedBox(height: 26),
            ElevatedButton(
              onPressed: () => _setMode(_AuthMode.login),
              child: const Text('Iniciar sesión'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => _setMode(_AuthMode.register),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(48, 50),
                foregroundColor: Theme.of(context).colorScheme.onSurface,
                side: const BorderSide(color: PoslyColors.blueGray),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Crear cuenta'),
            ),
            if (isDemoModeEnabled) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: widget.auth.enterDemoMode,
                icon: const Icon(Icons.visibility_outlined),
                label: const Text('Explorar modo demo'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(48, 50),
                  foregroundColor: Theme.of(context).colorScheme.onSurface,
                  side: const BorderSide(color: PoslyColors.blueGray),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _notice(String message, {bool isError = false}) {
    final color = isError
        ? Theme.of(context).colorScheme.error
        : PoslyColors.turquoise;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: isError ? color : Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  String get _heading => switch (_mode) {
    _AuthMode.login => 'Qué bueno verte',
    _AuthMode.register => 'Crea tu cuenta',
    _AuthMode.forgotPassword => 'Recuperar contraseña',
    _AuthMode.welcome => 'Bienvenido',
  };

  String get _subheading => switch (_mode) {
    _AuthMode.login => 'Ingresa tus datos para continuar.',
    _AuthMode.register => 'Completa tus datos para comenzar.',
    _AuthMode.forgotPassword => 'Te enviaremos instrucciones a tu correo.',
    _AuthMode.welcome => '',
  };

  String get _submitLabel => switch (_mode) {
    _AuthMode.login => 'Iniciar sesión',
    _AuthMode.register => 'Crear cuenta',
    _AuthMode.forgotPassword => 'Enviar instrucciones',
    _AuthMode.welcome => 'Continuar',
  };

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Escribe tu correo electrónico.';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Escribe un correo válido.';
    }
    return null;
  }
}
