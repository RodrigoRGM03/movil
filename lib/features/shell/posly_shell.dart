import 'package:flutter/material.dart';

import '../../core/api/api_client.dart';
import '../../core/auth/auth_controller.dart';
import '../../shared/posly_brand_mark.dart';
import '../dashboard/dashboard_screen.dart';
import '../modules/module_screen.dart';
import 'posly_modules.dart';

class PoslyShell extends StatefulWidget {
  const PoslyShell({
    required this.auth,
    required this.api,
    required this.onToggleTheme,
    required this.isDarkMode,
    super.key,
  });

  final AuthController auth;
  final ApiClient api;
  final VoidCallback onToggleTheme;
  final bool isDarkMode;

  @override
  State<PoslyShell> createState() => _PoslyShellState();
}

class _PoslyShellState extends State<PoslyShell> {
  int _selectedIndex = 0;

  bool get _isWide => MediaQuery.sizeOf(context).width >= 1000;

  @override
  Widget build(BuildContext context) {
    final title = _selectedIndex == 0
        ? 'Inicio'
        : poslyModules[_selectedIndex - 1].title;
    return Scaffold(
      appBar: AppBar(
        title: _isWide
            ? Text(title, style: const TextStyle(fontWeight: FontWeight.w700))
            : const PoslyBrandMark(compact: true),
        actions: [
          IconButton(
            tooltip: widget.isDarkMode ? 'Modo claro' : 'Modo oscuro',
            onPressed: widget.onToggleTheme,
            icon: Icon(
              widget.isDarkMode
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
            ),
          ),
          PopupMenuButton<String>(
            tooltip: 'Cuenta',
            onSelected: (value) {
              if (value == 'logout') _logout();
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    const Icon(Icons.logout_rounded),
                    const SizedBox(width: 10),
                    Text(
                      widget.auth.userName == null
                          ? 'Cerrar sesión'
                          : 'Salir de ${widget.auth.userName}',
                    ),
                  ],
                ),
              ),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: CircleAvatar(radius: 17, child: Text(_avatarInitials)),
            ),
          ),
        ],
      ),
      drawer: _isWide
          ? null
          : Drawer(
              width: 290,
              child: SafeArea(child: _navigationPanel(isDrawer: true)),
            ),
      body: Row(
        children: [
          if (_isWide) SizedBox(width: 264, child: _navigationPanel()),
          Expanded(child: _selectedPage()),
        ],
      ),
    );
  }

  Widget _navigationPanel({bool isDrawer = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 16, 20),
          child: Row(
            children: [
              const Expanded(child: PoslyBrandMark(compact: true)),
              if (isDrawer)
                IconButton(
                  tooltip: 'Cerrar menú',
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 8, 20, 8),
          child: Text(
            'OPERACIÓN',
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 1.1,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              _navigationTile(
                index: 0,
                title: 'Dashboard',
                icon: Icons.space_dashboard_outlined,
                isDrawer: isDrawer,
              ),
              for (var index = 0; index < poslyModules.length; index++)
                _navigationTile(
                  index: index + 1,
                  title: poslyModules[index].title,
                  icon: poslyModules[index].icon,
                  isDrawer: isDrawer,
                ),
            ],
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'PoSly · Punto de venta',
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ),
      ],
    );
  }

  Widget _navigationTile({
    required int index,
    required String title,
    required IconData icon,
    required bool isDrawer,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: ListTile(
        selected: _selectedIndex == index,
        selectedTileColor: Theme.of(context).colorScheme.primary
            .withValues(alpha: 0.16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Icon(icon),
        title: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis),
        onTap: () {
          setState(() => _selectedIndex = index);
          if (isDrawer) Navigator.pop(context);
        },
      ),
    );
  }

  Widget _selectedPage() {
    if (_selectedIndex == 0) {
      return DashboardScreen(
        api: widget.api,
        token: widget.auth.accessToken,
        isDemo: widget.auth.isDemo,
        onOpenModule: (index) => setState(() => _selectedIndex = index),
      );
    }
    return ModuleScreen(
      key: ValueKey(_selectedIndex),
      module: poslyModules[_selectedIndex - 1],
      api: widget.api,
      token: widget.auth.accessToken,
      isDemo: widget.auth.isDemo,
    );
  }

  String get _avatarInitials {
    final name = widget.auth.userName?.trim();
    if (name == null || name.isEmpty) return 'P';
    final parts = name.split(RegExp(r'\s+'));
    return parts.length == 1
        ? parts.first.substring(0, 1).toUpperCase()
        : '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  Future<void> _logout() async {
    await widget.auth.logout();
    if (!mounted || widget.auth.errorMessage == null) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(widget.auth.errorMessage!)));
  }
}
