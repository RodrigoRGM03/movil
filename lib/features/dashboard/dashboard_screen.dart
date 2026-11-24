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
    setState(() => _summary = _loadSummary());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(30, 26, 30, 36),
      children: [
        if (widget.isDemo) ...[const _DemoNotice(), const SizedBox(height: 22)],
        _WelcomeHeader(onRefresh: _refresh),
        const SizedBox(height: 22),
        _WelcomeBanner(
          isDemo: widget.isDemo,
          onOpenSales: () => widget.onOpenModule(4),
        ),
        const SizedBox(height: 28),
        Row(
          children: [
            Expanded(
              child: Text(
                'Así va tu negocio',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
            ),
            Text(
              'HOY',
              style: theme.textTheme.labelSmall?.copyWith(
                letterSpacing: 1.4,
                fontWeight: FontWeight.w800,
                color: PoslyColors.turquoise,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        FutureBuilder<dynamic>(
          future: _summary,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const _SummaryLoading();
            }
            if (snapshot.hasError) {
              return _ErrorPanel(
                message: snapshot.error.toString(),
                onRetry: _refresh,
              );
            }
            final metrics = _extractMetrics(snapshot.data);
            if (metrics.isEmpty) {
              return const _EmptyPanel(
                message:
                    'El backend respondió, pero todavía no hay indicadores '
                    'disponibles para mostrar.',
              );
            }
            return LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth > 900
                    ? 4
                    : constraints.maxWidth > 560
                    ? 2
                    : 1;
                final width =
                    (constraints.maxWidth - (columns - 1) * 14) / columns;
                return Wrap(
                  spacing: 14,
                  runSpacing: 14,
                  children: List.generate(
                    metrics.length > 4 ? 4 : metrics.length,
                    (index) => SizedBox(
                      width: width,
                      child: _MetricCard(
                        label: metrics[index].key,
                        value: metrics[index].value,
                        icon: _metricIcon(index),
                        index: index,
                        showTrend: widget.isDemo,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
        if (widget.isDemo) ...[
          const SizedBox(height: 26),
          const _SalesOverview(),
        ],
        const SizedBox(height: 28),
        Row(
          children: [
            Expanded(
              child: Text(
                'Todo a la mano',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
            ),
            Text(
              'Explora tus módulos',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth > 900
                ? 4
                : constraints.maxWidth > 560
                ? 3
                : 2;
            final width = (constraints.maxWidth - (columns - 1) * 13) / columns;
            return Wrap(
              spacing: 13,
              runSpacing: 13,
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

  IconData _metricIcon(int index) => switch (index % 4) {
    0 => Icons.payments_outlined,
    1 => Icons.receipt_long_outlined,
    2 => Icons.inventory_2_outlined,
    _ => Icons.notifications_active_outlined,
  };
}

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader({required this.onRefresh});

  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final date = '${_weekday(now.weekday)}, ${now.day} de ${_month(now.month)}';
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '¡Hola, qué gusto verte!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.7,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '$date · Aquí tienes el resumen de tu tienda.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface
                      .withValues(alpha: 0.62),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Actualizar resumen',
          onPressed: onRefresh,
          style: IconButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.surface,
            side: const BorderSide(color: PoslyColors.blueGray),
          ),
          icon: const Icon(Icons.refresh_rounded),
        ),
      ],
    );
  }

  String _weekday(int weekday) => const [
    'lunes',
    'martes',
    'miércoles',
    'jueves',
    'viernes',
    'sábado',
    'domingo',
  ][weekday - 1];

  String _month(int month) => const [
    'enero',
    'febrero',
    'marzo',
    'abril',
    'mayo',
    'junio',
    'julio',
    'agosto',
    'septiembre',
    'octubre',
    'noviembre',
    'diciembre',
  ][month - 1];
}

class _WelcomeBanner extends StatelessWidget {
  const _WelcomeBanner({required this.isDemo, required this.onOpenSales});

  final bool isDemo;
  final VoidCallback onOpenSales;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.sizeOf(context).width < 1000 ? 245 : 210,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [PoslyColors.navy, PoslyColors.navy, PoslyColors.turquoise],
          stops: [0, 0.88, 1],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 110,
            top: -116,
            child: _Orb(diameter: 250, opacity: 0.08),
          ),
          Positioned(
            right: -56,
            bottom: -134,
            child: _Orb(diameter: 265, opacity: 0.12),
          ),
          Positioned(
            right: 52,
            top: 28,
            child: Icon(
              Icons.storefront_rounded,
              size: 130,
              color: PoslyColors.white.withValues(alpha: 0.07),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 18),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: PoslyColors.turquoise.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.auto_awesome_rounded,
                              color: PoslyColors.turquoise,
                              size: 14,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'POSLY · CONTROL DE TU TIENDA',
                              style: TextStyle(
                                color: PoslyColors.white,
                                fontSize: 10,
                                letterSpacing: 1.1,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        isDemo
                            ? 'Tu negocio va por buen camino'
                            : 'Tu tienda, bajo control',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: PoslyColors.white,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.6,
                            ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        isDemo
                            ? 'Explora los módulos y conoce todo lo que puedes hacer.'
                            : 'Revisa la actividad de hoy y mantén todo en marcha.',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: PoslyColors.white.withValues(alpha: 0.72),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        height: 38,
                        child: FilledButton.icon(
                          onPressed: onOpenSales,
                          style: FilledButton.styleFrom(
                            backgroundColor: PoslyColors.turquoise,
                            foregroundColor: PoslyColors.navy,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                          ),
                          icon: const Icon(
                            Icons.receipt_long_rounded,
                            size: 17,
                          ),
                          label: const Text(
                            'Ver ventas',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 18),
                if (MediaQuery.sizeOf(context).width > 900)
                  const _BannerIllustration(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Orb extends StatelessWidget {
  const _Orb({required this.diameter, required this.opacity});

  final double diameter;
  final double opacity;

  @override
  Widget build(BuildContext context) => Container(
    width: diameter,
    height: diameter,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(
        color: PoslyColors.turquoise.withValues(alpha: opacity),
        width: 28,
      ),
    ),
  );
}

class _BannerIllustration extends StatelessWidget {
  const _BannerIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 210,
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 144,
            height: 144,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: PoslyColors.turquoise.withValues(alpha: 0.10),
            ),
          ),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: PoslyColors.turquoise,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: PoslyColors.turquoise.withValues(alpha: 0.3),
                  blurRadius: 28,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: const Icon(
              Icons.point_of_sale_rounded,
              color: PoslyColors.navy,
              size: 48,
            ),
          ),
          Positioned(
            top: 12,
            right: 16,
            child: _FloatTag(
              icon: Icons.trending_up_rounded,
              text: 'En marcha',
            ),
          ),
          Positioned(
            bottom: 8,
            left: 0,
            child: _FloatTag(icon: Icons.check_rounded, text: 'Todo listo'),
          ),
        ],
      ),
    );
  }
}

class _FloatTag extends StatelessWidget {
  const _FloatTag({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
    decoration: BoxDecoration(
      color: PoslyColors.white,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          color: PoslyColors.navy.withValues(alpha: 0.14),
          blurRadius: 15,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: PoslyColors.turquoise),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(
            color: PoslyColors.navy,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.index,
    required this.showTrend,
  });

  final String label;
  final String value;
  final IconData icon;
  final int index;
  final bool showTrend;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: PoslyColors.blueGray.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: PoslyColors.navy.withValues(alpha: 0.035),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: PoslyColors.turquoise.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: PoslyColors.turquoise, size: 20),
              ),
              const Spacer(),
              if (showTrend && index == 0 && value.startsWith('\$'))
                const _TrendPill(),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.64),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.7,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendPill extends StatelessWidget {
  const _TrendPill();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
    decoration: BoxDecoration(
      color: PoslyColors.turquoise.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(20),
    ),
    child: const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.trending_up_rounded, size: 13, color: PoslyColors.turquoise),
        SizedBox(width: 3),
        Text(
          '+12%',
          style: TextStyle(
            color: PoslyColors.navy,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}

class _SalesOverview extends StatelessWidget {
  const _SalesOverview();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth > 760;
        final chart = const _SalesChart();
        final activity = const _RecentActivity();
        if (!wide) {
          return Column(
            children: [
              SizedBox(height: 255, child: chart),
              const SizedBox(height: 14),
              SizedBox(height: 255, child: activity),
            ],
          );
        }
        return SizedBox(
          height: 255,
          child: Row(
            children: [
              Expanded(flex: 6, child: chart),
              const SizedBox(width: 14),
              Expanded(flex: 4, child: activity),
            ],
          ),
        );
      },
    );
  }
}

class _SalesChart extends StatelessWidget {
  const _SalesChart();

  static const _days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
  static const _values = [0.35, 0.55, 0.42, 0.78, 0.59, 0.92, 0.69];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _PanelCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ventas de la semana',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Actividad de ejemplo',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.bar_chart_rounded, color: PoslyColors.turquoise),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(_days.length, (index) {
                final isToday = index == 5;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (isToday)
                          const Padding(
                            padding: EdgeInsets.only(bottom: 5),
                            child: Text(
                              '\$1.2k',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: FractionallySizedBox(
                              heightFactor: _values[index],
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isToday
                                      ? PoslyColors.turquoise
                                      : PoslyColors.turquoise.withValues(
                                          alpha: 0.24,
                                        ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _days[index],
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: isToday ? FontWeight.w800 : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentActivity extends StatelessWidget {
  const _RecentActivity();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _PanelCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ventas recientes',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text('Últimos movimientos', style: theme.textTheme.bodySmall),
          const SizedBox(height: 12),
          for (final sale in demoRecentSales)
            Expanded(
              child: _RecentSale(
                code: sale['code']!,
                customer: sale['customer']!,
                amount: sale['amount']!,
              ),
            ),
        ],
      ),
    );
  }
}

class _RecentSale extends StatelessWidget {
  const _RecentSale({
    required this.code,
    required this.customer,
    required this.amount,
  });

  final String code;
  final String customer;
  final String amount;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: PoslyColors.turquoise.withValues(alpha: 0.13),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          Icons.receipt_long_rounded,
          size: 17,
          color: PoslyColors.turquoise,
        ),
      ),
      const SizedBox(width: 9),
      Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              code,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
            ),
            Text(
              customer,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ),
      Text(
        amount,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
      ),
    ],
  );
}

class _PanelCard extends StatelessWidget {
  const _PanelCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(17),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(17),
      border: Border.all(color: PoslyColors.blueGray.withValues(alpha: 0.8)),
      boxShadow: [
        BoxShadow(
          color: PoslyColors.navy.withValues(alpha: 0.035),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: child,
  );
}

class _QuickLink extends StatelessWidget {
  const _QuickLink({required this.module, required this.onTap});

  final PoslyModule module;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: PoslyColors.blueGray.withValues(alpha: 0.8),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: PoslyColors.turquoise.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  module.icon,
                  color: PoslyColors.turquoise,
                  size: 21,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  module.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 13,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DemoNotice extends StatelessWidget {
  const _DemoNotice();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
    decoration: BoxDecoration(
      color: PoslyColors.turquoise.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(13),
      border: Border.all(color: PoslyColors.turquoise.withValues(alpha: 0.2)),
    ),
    child: const Row(
      children: [
        Icon(Icons.science_outlined, color: PoslyColors.turquoise, size: 19),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            'Estás explorando PoSly. Los datos son de ejemplo y no se guardan.',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}

class _SummaryLoading extends StatelessWidget {
  const _SummaryLoading();

  @override
  Widget build(BuildContext context) => const SizedBox(
    height: 145,
    child: Center(child: CircularProgressIndicator()),
  );
}

class _EmptyPanel extends StatelessWidget {
  const _EmptyPanel({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => _PanelCard(
    child: Row(
      children: [
        const Icon(Icons.insights_outlined, color: PoslyColors.turquoise),
        const SizedBox(width: 12),
        Expanded(child: Text(message)),
      ],
    ),
  );
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => _PanelCard(
    child: Row(
      children: [
        Expanded(
          child: Text(
            message,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
        TextButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Reintentar'),
        ),
      ],
    ),
  );
}
