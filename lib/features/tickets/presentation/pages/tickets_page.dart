import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_widgets.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/ticket.dart';
import '../providers/tickets_provider.dart';
import '../widgets/ticket_card.dart';
import 'create_ticket_page.dart';
import 'ticket_detail_page.dart';

class TicketsPage extends ConsumerStatefulWidget {
  const TicketsPage({super.key});

  @override
  ConsumerState<TicketsPage> createState() => _TicketsPageState();
}

class _TicketsPageState extends ConsumerState<TicketsPage> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 300) {
      ref.read(ticketsProvider.notifier).loadMore();
    }
  }

  void _onSearch(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () {
      ref.read(ticketFilterProvider.notifier).setSearch(value);
    });
  }

  Future<void> _openCreate() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const CreateTicketPage()),
    );
    if (created == true) {
      await ref.read(ticketsProvider.notifier).refresh();
      ref.invalidate(ticketSummaryProvider);
    }
  }

  void _openDetail(Ticket ticket) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TicketDetailPage(
          idTicket: ticket.idTicket,
          folio: ticket.folio,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tickets = ref.watch(ticketsProvider);
    final filter = ref.watch(ticketFilterProvider);
    final summary = ref.watch(ticketSummaryProvider).value;
    final user = ref.watch(authProvider).user;
    final showSolicitante = user == null || !user.isSolicitante;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tickets'),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: () {
              ref.read(ticketsProvider.notifier).refresh();
              ref.invalidate(ticketSummaryProvider);
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreate,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nuevo ticket'),
      ),
      body: Column(
        children: [
          if (summary != null) _SummaryStrip(summary: summary),
          _Filters(
            searchController: _searchController,
            onSearch: _onSearch,
            filter: filter,
            onEstado: (value) =>
                ref.read(ticketFilterProvider.notifier).setEstado(value),
            onPrioridad: (value) =>
                ref.read(ticketFilterProvider.notifier).setPrioridad(value),
            onReset: () {
              _searchController.clear();
              ref.read(ticketFilterProvider.notifier).reset();
            },
          ),
          Expanded(
            child: tickets.when(
              loading: () => const AppLoadingView(message: 'Cargando tickets...'),
              error: (error, _) => AppErrorView(
                message: error.toString(),
                onRetry: () => ref.read(ticketsProvider.notifier).refresh(),
              ),
              data: (data) {
                if (data.items.isEmpty) {
                  return EmptyState(
                    title: 'Sin tickets',
                    message: filter.estado == null && filter.prioridad == null
                        ? 'Aun no hay tickets registrados. Crea el primero.'
                        : 'No hay tickets con los filtros seleccionados.',
                    icon: Icons.confirmation_number_outlined,
                    action: FilledButton.icon(
                      onPressed: _openCreate,
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Crear ticket'),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await ref.read(ticketsProvider.notifier).refresh();
                    ref.invalidate(ticketSummaryProvider);
                  },
                  child: ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                    itemCount: data.items.length + 1,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      if (index == data.items.length) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: data.hasMore
                                ? const CircularProgressIndicator(strokeWidth: 2)
                                : Text(
                                    '${data.total} ticket(s) en total',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                          ),
                        );
                      }
                      final ticket = data.items[index];
                      return TicketCard(
                        ticket: ticket,
                        showSolicitante: showSolicitante,
                        onTap: () => _openDetail(ticket),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryStrip extends StatelessWidget {
  const _SummaryStrip({required this.summary});

  final TicketSummary summary;

  @override
  Widget build(BuildContext context) {
    final items = [
      _SummaryItem('Activos', summary.activos, const Color(0xFF1565C0), Icons.pending_actions_rounded),
      _SummaryItem('Abiertos', summary.abiertos, const Color(0xFF1565C0), Icons.inbox_rounded),
      _SummaryItem('En proceso', summary.enProceso, const Color(0xFFEF6C00), Icons.autorenew_rounded),
      _SummaryItem('Resueltos', summary.resueltos, const Color(0xFF00897B), Icons.task_alt_rounded),
      _SummaryItem('Cerrados', summary.cerrados, const Color(0xFF2E7D32), Icons.lock_outline_rounded),
    ];

    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final item = items[index];
          return Container(
            width: 128,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.6),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Icon(item.icon, size: 16, color: item.color),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${item.value}',
                  style: TextStyle(
                    fontSize: 22,
                    height: 1,
                    fontWeight: FontWeight.w800,
                    color: item.color,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SummaryItem {
  const _SummaryItem(this.label, this.value, this.color, this.icon);

  final String label;
  final int value;
  final Color color;
  final IconData icon;
}

class _Filters extends StatelessWidget {
  const _Filters({
    required this.searchController,
    required this.onSearch,
    required this.filter,
    required this.onEstado,
    required this.onPrioridad,
    required this.onReset,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearch;
  final TicketFilter filter;
  final ValueChanged<String?> onEstado;
  final ValueChanged<String?> onPrioridad;
  final VoidCallback onReset;

  static const _estados = <String, String>{
    'ABIERTO': 'Abierto',
    'ASIGNADO': 'Asignado',
    'EN_PROCESO': 'En proceso',
    'RESUELTO': 'Resuelto',
    'CERRADO': 'Cerrado',
    'CANCELADO': 'Cancelado',
  };

  @override
  Widget build(BuildContext context) {
    final hasFilters = filter.estado != null || filter.prioridad != null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchController,
                  onChanged: onSearch,
                  decoration: const InputDecoration(
                    hintText: 'Buscar por folio, asunto o equipo',
                    prefixIcon: Icon(Icons.search_rounded),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              PopupMenuButton<String?>(
                tooltip: 'Prioridad',
                onSelected: onPrioridad,
                itemBuilder: (context) => const [
                  PopupMenuItem(value: null, child: Text('Todas las prioridades')),
                  PopupMenuItem(value: 'BAJA', child: Text('Baja')),
                  PopupMenuItem(value: 'MEDIA', child: Text('Media')),
                  PopupMenuItem(value: 'ALTA', child: Text('Alta')),
                  PopupMenuItem(value: 'CRITICA', child: Text('Critica')),
                ],
                icon: Icon(
                  Icons.flag_rounded,
                  color: filter.prioridad != null
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
              ),
              if (hasFilters)
                IconButton(
                  tooltip: 'Limpiar filtros',
                  onPressed: onReset,
                  icon: const Icon(Icons.filter_alt_off_rounded),
                ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _Chip(
                  label: 'Todos',
                  selected: filter.estado == null,
                  onSelected: () => onEstado(null),
                ),
                ..._estados.entries.map(
                  (entry) => _Chip(
                    label: entry.value,
                    selected: filter.estado == entry.key,
                    onSelected: () => onEstado(entry.key),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onSelected(),
      ),
    );
  }
}
