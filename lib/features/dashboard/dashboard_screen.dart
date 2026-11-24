import 'package:flutter/material.dart';

import '../../app/posly_theme.dart';
import '../../core/api/api_client.dart';
import '../demo/demo_data.dart';
import '../shell/posly_modules.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    required this.api,
    required this.token,
    required this.isDemo,
    required this.onOpenModule,
    super.key,
  });

  final ApiClient api;
  final String? token;
  final bool isDemo;
  final ValueChanged<int> onOpenModule;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<dynamic> _summary;

  @override
  void initState() {
    super.initState();
    _summary = _loadSummary();
  }

  Future<dynamic> _loadSummary() => widget.isDemo
      ? Future.value(demoDashboardSummary)
      : widget.api.getJson('dashboard', token: widget.token);

  void _refresh() {
    setState(() {
      _summary = _loadSummary();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        if (widget.isDemo) ...[const _DemoNotice(), const SizedBox(height: 18)],
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resumen del negocio',
                    style: Theme.of(context).textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Una vista rápida de la operación de tu tienda.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Actualizar resumen',
              onPressed: _refresh,
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
        const SizedBox(height: 24),
        FutureBuilder<dynamic>(
          future: _summary,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const _SummaryPanel(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                ),
              );
            }
            if (snapshot.hasError) {
              return _SummaryPanel(
                child: _ErrorContent(
                  message: snapshot.error.toString(),
                  onRetry: _refresh,
                ),
              );
            }
            final metrics = _extractMetrics(snapshot.data);
            if (metrics.isEmpty) {
              return const _SummaryPanel(
                child: Padding(
                  padding: EdgeInsets.all(22),
                  child: Text(
                    'El backend respondió correctamente, pero aún no hay '
                    'indicadores para mostrar en /dashboard.',
                  ),
                ),
              );
            }
            return LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth > 900
                    ? 4
                    : constraints.maxWidth > 580
                    ? 2
                    : 1;
                final width =
                    (constraints.maxWidth - (columns - 1) * 14) / columns;
                return Wrap(
                  spacing: 14,
                  runSpacing: 14,
                  children: metrics.take(8).map((entry) {
                    return SizedBox(
                      width: width,
                      child: _MetricCard(label: entry.key, value: entry.value),
                    );
                  }).toList(),
                );
              },
            );
          },
        ),
        const SizedBox(height: 30),
        Text(
          'Accesos rápidos',
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth > 900
                ? 4
                : constraints.maxWidth > 560
                ? 3
                : 2;
            final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: List.generate(4, (index) {
                final module = poslyModules[index];
                return SizedBox(
                  width: width,
                  child: _QuickLink(
                    module: module,
                    onTap: () => widget.onOpenModule(index + 1),
                  ),
                );
              }),
            );
          },
        ),
      ],
    );
  }

  List<MapEntry<String, String>> _extractMetrics(dynamic response) {
    if (response is! Map) return const [];
    final data = response['data'];
    final source = data is Map ? data : response;
    return source.entries
        .where((entry) => entry.value is! Map && entry.value is! List)
        .map(
          (entry) => MapEntry(
            _readable(entry.key.toString()),
            entry.value?.toString() ?? '—',
          ),
        )
        .toList();
  }

  String _readable(String value) {
    final spaced = value.replaceAll(RegExp(r'[_-]+'), ' ');
    if (spaced.isEmpty) return spaced;
    return '${spaced[0].toUpperCase()}${spaced.substring(1)}';
  }
}

class _DemoNotice extends StatelessWidget {
  const _DemoNotice();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: PoslyColors.turquoise.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Row(
      children: [
        Icon(Icons.science_outlined, color: PoslyColors.turquoise),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            'Modo demostración: los datos son de ejemplo y no se guardan.',
          ),
        ),
      ],
    ),
  );
}

class _SummaryPanel extends StatelessWidget {
  const _SummaryPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(width: double.infinity, child: child),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 12),
            Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickLink extends StatelessWidget {
  const _QuickLink({required this.module, required this.onTap});

  final PoslyModule module;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.arrow_outward_rounded,
                color: PoslyColors.turquoise,
              ),
              const SizedBox(height: 18),
              Icon(module.icon, size: 23),
              const SizedBox(height: 9),
              Text(
                module.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorContent extends StatelessWidget {
  const _ErrorContent({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Intentar de nuevo'),
          ),
        ],
      ),
    );
  }
}
