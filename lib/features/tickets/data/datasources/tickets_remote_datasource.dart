import '../../../../core/models/paged_result.dart';
import '../../../../core/models/upload_file.dart';
import '../../../../core/network/api_client.dart';
import '../../../auth/data/models/usuario_model.dart';
import '../../domain/entities/ticket.dart';
import '../models/ticket_models.dart';

class TicketsRemoteDataSource {
  TicketsRemoteDataSource(this._client);

  final ApiClient _client;

  Future<PagedResult<TicketModel>> list({
    TicketFilter filter = const TicketFilter(),
    int page = 1,
    int limit = 20,
  }) async {
    final query = <String, dynamic>{'page': page, 'limit': limit};
    if (filter.estado != null) query['estado'] = filter.estado;
    if (filter.prioridad != null) query['prioridad'] = filter.prioridad;
    if (filter.search != null && filter.search!.trim().isNotEmpty) {
      query['search'] = filter.search!.trim();
    }

    final response = await _client.get('/tickets', queryParameters: query);
    return PagedResult<TicketModel>.fromJson(
      Map<String, dynamic>.from(response as Map),
      TicketModel.fromJson,
    );
  }

  Future<TicketDetailModel> getDetail(int id) async {
    final response = await _client.get('/tickets/$id');
    return TicketDetailModel.fromJson(Map<String, dynamic>.from(response as Map));
  }

  Future<TicketDetailModel> create({
    required int idEquipo,
    required int idCategoria,
    required String asunto,
    required String descripcionProblema,
    required String prioridad,
    String? comoOcurrio,
    UploadFile? imagen,
  }) async {
    final response = await _client.upload(
      '/tickets',
      fields: {
        'id_equipo': idEquipo.toString(),
        'id_categoria': idCategoria.toString(),
        'asunto': asunto,
        'descripcion_problema': descripcionProblema,
        'prioridad': prioridad,
        if (comoOcurrio != null && comoOcurrio.trim().isNotEmpty)
          'como_ocurrio': comoOcurrio.trim(),
      },
      image: imagen,
    );
    return TicketDetailModel.fromJson(Map<String, dynamic>.from(response as Map));
  }

  Future<TicketDetailModel> assign(
    int id,
    int idTecnico, {
    String? observacion,
  }) async {
    final response = await _client.patch(
      '/tickets/$id/asignar',
      data: {
        'id_tecnico_asignado': idTecnico,
        if (observacion != null && observacion.trim().isNotEmpty)
          'observacion': observacion.trim(),
      },
    );
    return TicketDetailModel.fromJson(Map<String, dynamic>.from(response as Map));
  }

  Future<TicketDetailModel> changeStatus(
    int id,
    String estado, {
    String? observacion,
  }) async {
    final response = await _client.patch(
      '/tickets/$id/estado',
      data: {
        'estado': estado,
        if (observacion != null && observacion.trim().isNotEmpty)
          'observacion': observacion.trim(),
      },
    );
    return TicketDetailModel.fromJson(Map<String, dynamic>.from(response as Map));
  }

  Future<TicketDetailModel> addNote(int id, String observacion) async {
    final response = await _client.post(
      '/tickets/$id/notas',
      data: {'observacion': observacion},
    );
    return TicketDetailModel.fromJson(Map<String, dynamic>.from(response as Map));
  }

  Future<TicketDetailModel> addAttachment(int id, UploadFile imagen) async {
    final response = await _client.upload('/tickets/$id/adjuntos', image: imagen);
    return TicketDetailModel.fromJson(Map<String, dynamic>.from(response as Map));
  }

  Future<TicketSummaryModel> getSummary() async {
    final response = await _client.get('/tickets/resumen');
    return TicketSummaryModel.fromJson(Map<String, dynamic>.from(response as Map));
  }

  Future<List<CategoriaModel>> getCategorias() async {
    final response = await _client.get('/categorias');
    final data = Map<String, dynamic>.from(response as Map);
    final list = data['data'] as List? ?? const [];
    return list
        .whereType<Map>()
        .map((item) => CategoriaModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<List<UsuarioModel>> getTechnicians() async {
    final response = await _client.get('/usuarios/technicians');
    final data = Map<String, dynamic>.from(response as Map);
    final list = data['data'] as List? ?? const [];
    return list
        .whereType<Map>()
        .map((item) => UsuarioModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }
}
