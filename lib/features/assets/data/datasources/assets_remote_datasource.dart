import '../../../../core/models/paged_result.dart';
import '../../../../core/network/api_client.dart';
import '../models/equipo_model.dart';

class AssetsRemoteDataSource {
  AssetsRemoteDataSource(this._client);

  final ApiClient _client;

  Future<PagedResult<EquipoModel>> list({
    String? search,
    int? idDepartamento,
    int page = 1,
    int limit = 100,
  }) async {
    final query = <String, dynamic>{'page': page, 'limit': limit};
    if (search != null && search.trim().isNotEmpty) query['search'] = search.trim();
    if (idDepartamento != null) query['id_departamento'] = idDepartamento;

    final response = await _client.get('/equipos', queryParameters: query);
    return PagedResult<EquipoModel>.fromJson(
      Map<String, dynamic>.from(response as Map),
      EquipoModel.fromJson,
    );
  }

  Future<List<DepartamentoModel>> getDepartamentos() async {
    final response = await _client.get('/departamentos');
    final data = Map<String, dynamic>.from(response as Map);
    final list = data['data'] as List? ?? const [];
    return list
        .whereType<Map>()
        .map((item) => DepartamentoModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<EquipoModel> create(Map<String, dynamic> payload) async {
    final response = await _client.post('/equipos', data: payload);
    final data = Map<String, dynamic>.from(response as Map);
    return EquipoModel.fromJson(Map<String, dynamic>.from(data['asset'] as Map));
  }

  Future<EquipoModel> update(int id, Map<String, dynamic> payload) async {
    final response = await _client.patch('/equipos/$id', data: payload);
    final data = Map<String, dynamic>.from(response as Map);
    return EquipoModel.fromJson(Map<String, dynamic>.from(data['asset'] as Map));
  }
}
