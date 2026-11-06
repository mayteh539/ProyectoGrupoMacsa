import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/entities/report_models.dart';
import '../providers/reports_provider.dart';
import '../widgets/failure_chart_widget.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  int _dias = 30;

  Future<void> _refresh() async {
    ref.invalidate(dashboardProvider);
    ref.invalidate(trendProvider(_dias));
    ref.invalidate(ticketsByStatusProvider);
    ref.invalidate(topEquipmentProvider);
    ref.invalidate(satisfactionProvider);
    await ref.read(dashboardProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = ref.watch(dashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: dashboard.when(
        loading: () => const AppLoadingView(message: 'Cargando indicadores...'),
        error: (error, _) => AppErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(dashboardProvider),
        ),
        data: (data) => RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            children: [
              _KpiGrid(data: data),
              const SizedBox(height: 16),
              SectionCard(
                title: 'Tendencia de tickets',
                icon: Icons.show_chart_rounded,
                trailing: DropdownButton<int>(
                  value: _dias,
                  underline: const SizedBox.shrink(),
                  items: const [
                    DropdownMenuItem(value: 7, child: Text('7 dias')),
                    DropdownMenuItem(value: 30, child: Text('30 dias')),
                    DropdownMenuItem(value: 90, child: Text('90 dias')),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _dias = value);
                  },
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Wrap(
                      spacing: 16,
                      children: [
                        ChartLegendDot(color: Color(0xFF0B5FA5), label: 'Creados'),
                        ChartLegendDot(color: Color(0xFF2E7D32), label: 'Atendidos'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ref.watch(trendProvider(_dias)).when(
                          loading: () => const SizedBox(
                            height: 240,
                            child: Center(child: CircularProgressIndicator()),
                          ),
                          error: (error, _) => SizedBox(
                            height: 240,
                            child: Center(child: Text('Error: $error')),
                          ),
                          data: (points) => TrendLineChart(points: points),
                        ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 760;
                  final statusCard = SectionCard(
                    title: 'Tickets por estado',
                    icon: Icons.donut_small_rounded,
                    child: ref.watch(ticketsByStatusProvider).when(
                          loading: () => const SizedBox(
                            height: 240,
                            child: Center(child: CircularProgressIndicator()),
                          ),
                          error: (error, _) => SizedBox(
                            height: 240,
                            child: Center(child: Text('Error: $error')),
                          ),
                          data: (items) => DistributionPieChart(
                            data: items,
                            labelBuilder: StatusBadge.labelFor,
                          ),
                        ),
                  );

                  final satisfactionCard = SectionCard(
                    title: 'Satisfaccion',
                    icon: Icons.star_outline_rounded,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              data.promedioSatisfaccion == null
                                  ? '—'
                                  : data.promedioSatisfaccion!.toStringAsFixed(1),
                              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFFF9A825),
                                  ),
                            ),
                            const SizedBox(width: 4),
                            const Text('/ 5'),
                            const Spacer(),
                            ...List.generate(
                              5,
                              (index) => Icon(
                                index < (data.promedioSatisfaccion ?? 0).round()
                                    ? Icons.star_rounded
                                    : Icons.star_border_rounded,
                                color: const Color(0xFFF9A825),
                                size: 22,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${data.totalEncuestas} encuesta(s) respondida(s)',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 12),
                        if (data.pendientesEncuesta > 0)
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9A825).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.pending_actions_rounded,
                                  size: 18,
                                  color: Color(0xFF8D6E00),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${data.pendientesEncuesta} ticket(s) resueltos '
                                    'esperando encuesta',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          children: [
                            _MiniStat(
                              label: 'Resueltos hoy',
                              value: '${data.resueltos}',
                              color: const Color(0xFF00897B),
                            ),
                            _MiniStat(
                              label: 'Creados hoy',
                              value: '${data.creadosHoy}',
                              color: const Color(0xFF0B5FA5),
                            ),
                            _MiniStat(
                              label: 'Esta semana',
                              value: '${data.creadosSemana}',
                              color: const Color(0xFF6A1B9A),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );

                  if (!wide) {
                    return Column(
                      children: [
                        statusCard,
                        const SizedBox(height: 16),
                        satisfactionCard,
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: statusCard),
                      const SizedBox(width: 16),
                      Expanded(child: satisfactionCard),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              SectionCard(
                title: 'Equipos con mas fallas',
                icon: Icons.warning_amber_rounded,
                child: ref.watch(topEquipmentProvider).when(
                      loading: () => const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (error, _) => Text('Error: $error'),
                      data: (items) {
                        if (items.isEmpty) {
                          return const Text('Sin equipos con tickets registrados.');
                        }
                        return Column(
                          children: [
                            for (var i = 0; i < items.length; i++) ...[
                              if (i > 0) const Divider(height: 20),
                              _EquipmentRow(index: i + 1, equipo: items[i]),
                            ],
                          ],
                        );
                      },
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KpiGrid extends StatelessWidget {
  const _KpiGrid({required this.data});

  final DashboardSummary data;

  @override
  Widget build(BuildContext context) {
    final items = [
      _Kpi('Total tickets', '${data.totalTickets}', Icons.confirmation_number_outlined, const Color(0xFF0B5FA5)),
      _Kpi('Activos', '${data.activos}', Icons.pending_actions_rounded, const Color(0xFF1565C0)),
      _Kpi('En proceso', '${data.enProceso}', Icons.autorenew_rounded, const Color(0xFFEF6C00)),
      _Kpi('Resueltos', '${data.resueltos}', Icons.task_alt_rounded, const Color(0xFF00897B)),
      _Kpi('Cerrados', '${data.cerrados}', Icons.lock_outline_rounded, const Color(0xFF2E7D32)),
      _Kpi(
        'Tiempo prom.',
        formatDuracion(data.promedioMinutosResolucion),
        Icons.timer_outlined,
        const Color(0xFF6A1B9A),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900
            ? 6
            : constraints.maxWidth >= 620
                ? 3
                : 2;
        final spacing = 10.0;
        final width = (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: items
              .map(
                (item) => SizedBox(
                  width: width,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .outlineVariant
                            .withValues(alpha: 0.6),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(item.icon, color: item.color, size: 20),
                        const SizedBox(height: 8),
                        Text(
                          item.value,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 22,
                            height: 1.1,
                            fontWeight: FontWeight.w800,
                            color: item.color,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _Kpi {
  const _Kpi(this.label, this.value, this.icon, this.color);

  final String label;
  final String value;
  final IconData icon;
  final Color color;
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color),
          ),
          Text(label, style: const TextStyle(fontSize: 10)),
        ],
      ),
    );
  }
}

class _EquipmentRow extends StatelessWidget {
  const _EquipmentRow({required this.index, required this.equipo});

  final int index;
  final TopEquipment equipo;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: chartPalette[(index - 1) % chartPalette.length]
              .withValues(alpha: 0.14),
          child: Text(
            '$index',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: chartPalette[(index - 1) % chartPalette.length],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                equipo.nombreEquipo,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
              Text(
                '${equipo.codigoActivo} · ${equipo.nombreDepartamento}',
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Text(
          '${equipo.totalTickets}',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        const SizedBox(width: 4),
        Text(
          'ticket(s)',
          style: TextStyle(
            fontSize: 10,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
