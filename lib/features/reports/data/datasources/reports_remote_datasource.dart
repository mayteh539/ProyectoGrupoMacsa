import '../../../../core/network/api_client.dart';
import '../models/report_models.dart';

class ReportsRemoteDataSource {
  ReportsRemoteDataSource(this._client);

  final ApiClient _client;

  Future<DashboardSummaryModel> getDashboard() async {
    final response = await _client.get('/reportes/dashboard');
    final data = Map<String, dynamic>.from(response as Map);
    return DashboardSummaryModel.fromJson(
      Map<String, dynamic>.from(data['data'] as Map),
    );
  }

  Future<List<CountByKeyModel>> _countList(String path) async {
    final response = await _client.get(path);
    final data = Map<String, dynamic>.from(response as Map);
    final list = data['data'] as List? ?? const [];
    return list
        .whereType<Map>()
        .map((item) => CountByKeyModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<List<CountByKeyModel>> getByStatus() => _countList('/reportes/por-estado');

  Future<List<CountByKeyModel>> getByPriority() => _countList('/reportes/por-prioridad');

  Future<List<CountByKeyModel>> getByCategory() => _countList('/reportes/por-categoria');

  Future<List<CountByKeyModel>> getByDepartment() =>
      _countList('/reportes/por-departamento');

  Future<List<TopEquipmentModel>> getTopEquipment({int limit = 10}) async {
    final response = await _client.get(
      '/reportes/top-equipos',
      queryParameters: {'limit': limit},
    );
    final data = Map<String, dynamic>.from(response as Map);
    final list = data['data'] as List? ?? const [];
    return list
        .whereType<Map>()
        .map((item) => TopEquipmentModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<List<TopRequesterModel>> getTopRequesters({int limit = 10}) async {
    final response = await _client.get(
      '/reportes/top-solicitantes',
      queryParameters: {'limit': limit},
    );
    final data = Map<String, dynamic>.from(response as Map);
    final list = data['data'] as List? ?? const [];
    return list
        .whereType<Map>()
        .map((item) => TopRequesterModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<List<ResolutionTimeModel>> getResolutionTimes() async {
    final response = await _client.get('/reportes/tiempos-resolucion');
    final data = Map<String, dynamic>.from(response as Map);
    final list = data['data'] as List? ?? const [];
    return list
        .whereType<Map>()
        .map((item) => ResolutionTimeModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<SatisfactionSummaryModel> getSatisfaction() async {
    final response = await _client.get('/reportes/satisfaccion');
    final data = Map<String, dynamic>.from(response as Map);
    return SatisfactionSummaryModel.fromJson(
      Map<String, dynamic>.from(data['data'] as Map),
    );
  }

  Future<List<TrendPointModel>> getTrend({int days = 30}) async {
    final response = await _client.get(
      '/reportes/tendencia',
      queryParameters: {'dias': days},
    );
    final data = Map<String, dynamic>.from(response as Map);
    final list = data['data'] as List? ?? const [];
    return list
        .whereType<Map>()
        .map((item) => TrendPointModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }
}
