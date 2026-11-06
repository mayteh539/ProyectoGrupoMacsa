import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../domain/entities/report_models.dart';
import '../providers/reports_provider.dart';
import '../widgets/failure_chart_widget.dart';

class ReportsPage extends ConsumerWidget {
  const ReportsPage({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(ticketsByCategoryProvider);
    ref.invalidate(ticketsByDepartmentProvider);
    ref.invalidate(ticketsByPriorityProvider);
    ref.invalidate(topRequestersProvider);
    ref.invalidate(topEquipmentProvider);
    ref.invalidate(resolutionTimesProvider);
    ref.invalidate(satisfactionProvider);
    await ref.read(ticketsByCategoryProvider.future);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes'),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: () => _refresh(ref),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _refresh(ref),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            _AsyncSection<CountByKey>(
              title: 'Tickets por categoria',
              icon: Icons.category_outlined,
              value: ref.watch(ticketsByCategoryProvider),
              builder: (items) => CategoryBarChart(data: items),
            ),
            const SizedBox(height: 16),
            _AsyncSection<CountByKey>(
              title: 'Tickets por prioridad',
              icon: Icons.flag_outlined,
              value: ref.watch(ticketsByPriorityProvider),
              builder: (items) => DistributionPieChart(
                data: items,
                labelBuilder: _priorityLabel,
                colors: const [
                  Color(0xFF2E7D32),
                  Color(0xFF1565C0),
                  Color(0xFFEF6C00),
                  Color(0xFFC62828),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _AsyncSection<CountByKey>(
              title: 'Tickets por departamento',
              icon: Icons.apartment_rounded,
              value: ref.watch(ticketsByDepartmentProvider),
              builder: (items) => CategoryBarChart(data: items),
            ),
            const SizedBox(height: 16),
            _AsyncSection<TopEquipment>(
              title: 'Equipos con mas fallas',
              icon: Icons.warning_amber_rounded,
              value: ref.watch(topEquipmentProvider),
              builder: (items) => _EquipmentTable(items: items),
            ),
            const SizedBox(height: 16),
            _AsyncSection<TopRequester>(
              title: 'Solicitantes con mas tickets',
              icon: Icons.people_outline_rounded,
              value: ref.watch(topRequestersProvider),
              builder: (items) => _RequestersTable(items: items),
            ),
            const SizedBox(height: 16),
            _AsyncSection<ResolutionTime>(
              title: 'Tiempos de resolucion',
              icon: Icons.timer_outlined,
              value: ref.watch(resolutionTimesProvider),
              builder: (items) => _ResolutionTable(items: items),
            ),
            const SizedBox(height: 16),
            Consumer(
              builder: (context, ref, _) {
                final satisfaction = ref.watch(satisfactionProvider);
                return SectionCard(
                  title: 'Satisfaccion de los solicitantes',
                  icon: Icons.star_outline_rounded,
                  child: satisfaction.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (error, _) => Text('Error: $error'),
                    data: (data) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 20,
                          runSpacing: 12,
                          children: [
                            _SatisfactionStat(
                              label: 'Promedio',
                              value: data.promedioSatisfaccion == null
                                  ? '—'
                                  : '${data.promedioSatisfaccion!.toStringAsFixed(1)}/5',
                              color: const Color(0xFFF9A825),
                            ),
                            _SatisfactionStat(
                              label: 'Encuestas',
                              value: '${data.totalEncuestas}',
                              color: const Color(0xFF0B5FA5),
                            ),
                            _SatisfactionStat(
                              label: 'Solucionados',
                              value: '${data.solucionados}',
                              color: const Color(0xFF2E7D32),
                            ),
                            _SatisfactionStat(
                              label: 'No solucionados',
                              value: '${data.noSolucionados}',
                              color: const Color(0xFFC62828),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SatisfactionBarChart(data: data.distribucion),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _priorityLabel(String clave) {
    switch (clave) {
      case 'BAJA':
        return 'Baja';
      case 'MEDIA':
        return 'Media';
      case 'ALTA':
        return 'Alta';
      case 'CRITICA':
        return 'Critica';
      default:
        return clave;
    }
  }
}

class _AsyncSection<T> extends StatelessWidget {
  const _AsyncSection({
    required this.title,
    required this.icon,
    required this.value,
    required this.builder,
  });

  final String title;
  final IconData icon;
  final AsyncValue<List<T>> value;
  final Widget Function(List<T> items) builder;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: title,
      icon: icon,
      child: value.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (error, _) => Text('Error: $error'),
        data: (items) {
          if (items.isEmpty) {
            return Text(
              'Sin datos disponibles.',
              style: Theme.of(context).textTheme.bodySmall,
            );
          }
          return builder(items);
        },
      ),
    );
  }
}

class _EquipmentTable extends StatelessWidget {
  const _EquipmentTable({required this.items});

  final List<TopEquipment> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const Divider(height: 18),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      items[i].nombreEquipo,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                    Text(
                      '${items[i].codigoActivo} · ${items[i].categoria} · '
                      '${items[i].nombreDepartamento}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              _CountPill(
                value: items[i].totalTickets,
                color: const Color(0xFF0B5FA5),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _RequestersTable extends StatelessWidget {
  const _RequestersTable({required this.items});

  final List<TopRequester> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const Divider(height: 18),
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: chartPalette[i % chartPalette.length]
                    .withValues(alpha: 0.14),
                child: Text(
                  '${i + 1}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: chartPalette[i % chartPalette.length],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      items[i].nombreCompleto,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                    Text(
                      '${items[i].usuario} · ${items[i].nombreDepartamento}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              _CountPill(
                value: items[i].totalTickets,
                color: const Color(0xFF6A1B9A),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _ResolutionTable extends StatelessWidget {
  const _ResolutionTable({required this.items});

  final List<ResolutionTime> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const Divider(height: 18),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      items[i].tecnico,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                    Text(
                      '${items[i].nombreCategoria} · ${items[i].resueltos} resuelto(s)',
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF00897B).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  formatDuracion(items[i].promedioMinutos),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF00695C),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _CountPill extends StatelessWidget {
  const _CountPill({required this.value, required this.color});

  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$value',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: color),
      ),
    );
  }
}

class _SatisfactionStat extends StatelessWidget {
  const _SatisfactionStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
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
