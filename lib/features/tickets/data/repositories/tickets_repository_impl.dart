import '../../../../core/models/paged_result.dart';
import '../../../../core/models/upload_file.dart';
import '../../../auth/domain/entities/usuario.dart';
import '../../domain/entities/categoria.dart';
import '../../domain/entities/ticket.dart';
import '../../domain/repositories/tickets_repository.dart';
import '../datasources/tickets_remote_datasource.dart';

class TicketsRepositoryImpl implements TicketsRepository {
  TicketsRepositoryImpl(this._remote);

  final TicketsRemoteDataSource _remote;

  @override
  Future<PagedResult<Ticket>> list({
    TicketFilter filter = const TicketFilter(),
    int page = 1,
    int limit = 20,
  }) {
    return _remote.list(filter: filter, page: page, limit: limit);
  }

  @override
  Future<TicketDetail> getDetail(int id) => _remote.getDetail(id);

  @override
  Future<TicketDetail> create({
    required int idEquipo,
    required int idCategoria,
    required String asunto,
    required String descripcionProblema,
    required String prioridad,
    String? comoOcurrio,
    UploadFile? imagen,
  }) {
    return _remote.create(
      idEquipo: idEquipo,
      idCategoria: idCategoria,
      asunto: asunto,
      descripcionProblema: descripcionProblema,
      prioridad: prioridad,
      comoOcurrio: comoOcurrio,
      imagen: imagen,
    );
  }

  @override
  Future<TicketDetail> assign(int id, int idTecnico, {String? observacion}) {
    return _remote.assign(id, idTecnico, observacion: observacion);
  }

  @override
  Future<TicketDetail> changeStatus(int id, String estado, {String? observacion}) {
    return _remote.changeStatus(id, estado, observacion: observacion);
  }

  @override
  Future<TicketDetail> addNote(int id, String observacion) {
    return _remote.addNote(id, observacion);
  }

  @override
  Future<TicketDetail> addAttachment(int id, UploadFile imagen) {
    return _remote.addAttachment(id, imagen);
  }

  @override
  Future<TicketSummary> getSummary() => _remote.getSummary();

  @override
  Future<List<Categoria>> getCategorias() => _remote.getCategorias();

  @override
  Future<List<Usuario>> getTechnicians() => _remote.getTechnicians();
}
