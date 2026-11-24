import 'dart:convert';

import 'package:flutter/material.dart';

import '../../core/api/api_client.dart';
import '../demo/demo_data.dart';
import '../shell/posly_modules.dart';

class ModuleScreen extends StatefulWidget {
  const ModuleScreen({
    required this.module,
    required this.api,
    required this.token,
    required this.isDemo,
    super.key,
  });

  final PoslyModule module;
  final ApiClient api;
  final String? token;
  final bool isDemo;

  @override
  State<ModuleScreen> createState() => _ModuleScreenState();
}

class _ModuleScreenState extends State<ModuleScreen> {
  late ModuleEndpoint _endpoint;
  late Future<dynamic> _data;

  @override
  void initState() {
    super.initState();
    _endpoint = widget.module.endpoints.first;
    _data = _load();
  }

  Future<dynamic> _load() => widget.isDemo
      ? Future.value(demoRowsFor(_endpoint.path))
      : widget.api.getJson(_endpoint.path, token: widget.token);

  void _selectEndpoint(ModuleEndpoint endpoint) {
    setState(() {
      _endpoint = endpoint;
      _data = _load();
    });
  }

  void _refresh() {
    setState(() => _data = _load());
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        if (widget.isDemo) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary
                  .withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Modo demostración: datos de ejemplo, no se guardan.',
            ),
          ),
          const SizedBox(height: 18),
        ],
        Text(
          widget.module.title,
          style: Theme.of(context).textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(widget.module.description),
        const SizedBox(height: 22),
        Row(
          children: [
            if (widget.module.endpoints.length > 1)
              Expanded(
                child: DropdownButtonFormField<ModuleEndpoint>(
                  initialValue: _endpoint,
                  decoration: const InputDecoration(
                    labelText: 'Vista',
                    prefixIcon: Icon(Icons.filter_list_rounded),
                  ),
                  items: widget.module.endpoints
                      .map(
                        (endpoint) => DropdownMenuItem(
                          value: endpoint,
                          child: Text(endpoint.label),
                        ),
                      )
                      .toList(),
                  onChanged: (endpoint) {
                    if (endpoint != null) _selectEndpoint(endpoint);
                  },
                ),
              )
            else
              Expanded(
                child: Text(
                  _endpoint.label,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            const SizedBox(width: 12),
            IconButton.filledTonal(
              tooltip: 'Actualizar',
              onPressed: _refresh,
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
        const SizedBox(height: 18),
        FutureBuilder<dynamic>(
          future: _data,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const _StateCard(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(36),
                    child: CircularProgressIndicator(),
                  ),
                ),
              );
            }
            if (snapshot.hasError) {
              return _StateCard(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        snapshot.error.toString(),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Endpoint consultado: ${_endpoint.path}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: _refresh,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Intentar de nuevo'),
                      ),
                    ],
                  ),
                ),
              );
            }
            final rows = _extractRows(snapshot.data);
            if (rows.isEmpty) {
              return const _StateCard(
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: Center(child: Text('No hay registros para mostrar.')),
                ),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${rows.length} ${rows.length == 1 ? 'registro' : 'registros'}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 10),
                ...rows.map((row) => _RecordCard(row: row)),
              ],
            );
          },
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _extractRows(dynamic response) {
    dynamic data = response;
    if (data is Map && data.containsKey('data')) data = data['data'];
    if (data is Map) return [Map<String, dynamic>.from(data)];
    if (data is! List) return const [];
    return data.map((item) {
      if (item is Map) return Map<String, dynamic>.from(item);
      return <String, dynamic>{'registro': item};
    }).toList();
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Card(
    child: SizedBox(width: double.infinity, child: child),
  );
}

class _RecordCard extends StatelessWidget {
  const _RecordCard({required this.row});

  final Map<String, dynamic> row;

  @override
  Widget build(BuildContext context) {
    final fields = row.entries.take(6).toList();
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 28,
          runSpacing: 12,
          children: fields.map((field) {
            final label = field.key
                .replaceAll(RegExp(r'[_-]+'), ' ')
                .split(' ')
                .map(
                  (word) => word.isEmpty
                      ? word
                      : '${word[0].toUpperCase()}${word.substring(1)}',
                )
                .join(' ');
            final value = field.value is Map || field.value is List
                ? jsonEncode(field.value)
                : field.value?.toString() ?? '—';
            return SizedBox(
              width: 185,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: Theme.of(context).textTheme.labelSmall),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
