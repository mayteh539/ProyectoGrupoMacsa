import '../../../../core/models/paged_result.dart';
import '../../../../core/models/upload_file.dart';
import '../../../auth/domain/entities/usuario.dart';
import '../entities/categoria.dart';
import '../entities/ticket.dart';

abstract class TicketsRepository {
  Future<PagedResult<Ticket>> list({
    TicketFilter filter = const TicketFilter(),
    int page = 1,
    int limit = 20,
  });

  Future<TicketDetail> getDetail(int id);

  Future<TicketDetail> create({
    required int idEquipo,
    required int idCategoria,
    required String asunto,
    required String descripcionProblema,
    required String prioridad,
    String? comoOcurrio,
    UploadFile? imagen,
  });

  Future<TicketDetail> assign(int id, int idTecnico, {String? observacion});

  Future<TicketDetail> changeStatus(int id, String estado, {String? observacion});

  Future<TicketDetail> addNote(int id, String observacion);

  Future<TicketDetail> addAttachment(int id, UploadFile imagen);

  Future<TicketSummary> getSummary();

  Future<List<Categoria>> getCategorias();

  Future<List<Usuario>> getTechnicians();
}
