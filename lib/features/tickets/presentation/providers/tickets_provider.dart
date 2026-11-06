import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/upload_file.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../auth/domain/entities/usuario.dart';
import '../../data/datasources/tickets_remote_datasource.dart';
import '../../data/repositories/tickets_repository_impl.dart';
import '../../domain/entities/categoria.dart';
import '../../domain/entities/ticket.dart';
import '../../domain/repositories/tickets_repository.dart';

final ticketsRepositoryProvider = Provider<TicketsRepository>((ref) {
  return TicketsRepositoryImpl(
    TicketsRemoteDataSource(ref.watch(apiClientProvider)),
  );
});

final ticketFilterProvider =
    NotifierProvider<TicketFilterNotifier, TicketFilter>(TicketFilterNotifier.new);

class TicketFilterNotifier extends Notifier<TicketFilter> {
  @override
  TicketFilter build() => const TicketFilter();

  void setEstado(String? estado) {
    state = estado == null
        ? state.copyWith(clearEstado: true)
        : state.copyWith(estado: estado);
  }

  void setPrioridad(String? prioridad) {
    state = prioridad == null
        ? state.copyWith(clearPrioridad: true)
        : state.copyWith(prioridad: prioridad);
  }

  void setSearch(String search) {
    state = state.copyWith(search: search);
  }

  void reset() {
    state = const TicketFilter();
  }
}

class TicketsPageData {
  const TicketsPageData({
    required this.items,
    required this.page,
    required this.totalPages,
    required this.total,
  });

  final List<Ticket> items;
  final int page;
  final int totalPages;
  final int total;

  bool get hasMore => page < totalPages;

  TicketsPageData copyWith({
    List<Ticket>? items,
    int? page,
    int? totalPages,
    int? total,
  }) {
    return TicketsPageData(
      items: items ?? this.items,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      total: total ?? this.total,
    );
  }
}

final ticketsProvider =
    AsyncNotifierProvider<TicketsNotifier, TicketsPageData>(TicketsNotifier.new);

class TicketsNotifier extends AsyncNotifier<TicketsPageData> {
  static const int _pageSize = 20;

  @override
  Future<TicketsPageData> build() async {
    final filter = ref.watch(ticketFilterProvider);
    final result = await ref.read(ticketsRepositoryProvider).list(
          filter: filter,
          page: 1,
          limit: _pageSize,
        );
    return TicketsPageData(
      items: result.data,
      page: result.page,
      totalPages: result.totalPages,
      total: result.total,
    );
  }

  Future<void> refresh() async {
    final filter = ref.read(ticketFilterProvider);
    final result = await ref.read(ticketsRepositoryProvider).list(
          filter: filter,
          page: 1,
          limit: _pageSize,
        );
    state = AsyncData(
      TicketsPageData(
        items: result.data,
        page: result.page,
        totalPages: result.totalPages,
        total: result.total,
      ),
    );
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore) return;

    final filter = ref.read(ticketFilterProvider);
    final result = await ref.read(ticketsRepositoryProvider).list(
          filter: filter,
          page: current.page + 1,
          limit: _pageSize,
        );

    state = AsyncData(
      current.copyWith(
        items: [...current.items, ...result.data],
        page: result.page,
        totalPages: result.totalPages,
        total: result.total,
      ),
    );
  }
}

final ticketDetailProvider =
    FutureProvider.autoDispose.family<TicketDetail, int>((ref, id) {
  return ref.watch(ticketsRepositoryProvider).getDetail(id);
});

final ticketSummaryProvider = FutureProvider<TicketSummary>((ref) {
  return ref.watch(ticketsRepositoryProvider).getSummary();
});

final categoriasProvider = FutureProvider<List<Categoria>>((ref) {
  return ref.watch(ticketsRepositoryProvider).getCategorias();
});

final techniciansProvider = FutureProvider<List<Usuario>>((ref) {
  return ref.watch(ticketsRepositoryProvider).getTechnicians();
});

/// Acciones sobre tickets. Tras cada accion refresca los datos derivados.
class TicketActions {
  TicketActions(this._ref);

  final Ref _ref;

  TicketsRepository get _repository => _ref.read(ticketsRepositoryProvider);

  void _invalidate(int id) {
    _ref.invalidate(ticketDetailProvider(id));
    _ref.invalidate(ticketsProvider);
    _ref.invalidate(ticketSummaryProvider);
  }

  Future<TicketDetail> assign(int id, int idTecnico, {String? observacion}) async {
    final detail = await _repository.assign(id, idTecnico, observacion: observacion);
    _invalidate(id);
    return detail;
  }

  Future<TicketDetail> changeStatus(int id, String estado, {String? observacion}) async {
    final detail = await _repository.changeStatus(id, estado, observacion: observacion);
    _invalidate(id);
    return detail;
  }

  Future<TicketDetail> addNote(int id, String observacion) async {
    final detail = await _repository.addNote(id, observacion);
    _invalidate(id);
    return detail;
  }

  Future<TicketDetail> addAttachment(int id, UploadFile imagen) async {
    final detail = await _repository.addAttachment(id, imagen);
    _invalidate(id);
    return detail;
  }
}

final ticketActionsProvider = Provider<TicketActions>((ref) => TicketActions(ref));
