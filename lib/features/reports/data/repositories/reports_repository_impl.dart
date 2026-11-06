import '../../domain/entities/report_models.dart';
import '../../domain/repositories/reports_repository.dart';
import '../datasources/reports_remote_datasource.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  ReportsRepositoryImpl(this._remote);

  final ReportsRemoteDataSource _remote;

  @override
  Future<DashboardSummary> getDashboard() => _remote.getDashboard();

  @override
  Future<List<CountByKey>> getByStatus() => _remote.getByStatus();

  @override
  Future<List<CountByKey>> getByPriority() => _remote.getByPriority();

  @override
  Future<List<CountByKey>> getByCategory() => _remote.getByCategory();

  @override
  Future<List<CountByKey>> getByDepartment() => _remote.getByDepartment();

  @override
  Future<List<TopEquipment>> getTopEquipment({int limit = 10}) =>
      _remote.getTopEquipment(limit: limit);

  @override
  Future<List<TopRequester>> getTopRequesters({int limit = 10}) =>
      _remote.getTopRequesters(limit: limit);

  @override
  Future<List<ResolutionTime>> getResolutionTimes() => _remote.getResolutionTimes();

  @override
  Future<SatisfactionSummary> getSatisfaction() => _remote.getSatisfaction();

  @override
  Future<List<TrendPoint>> getTrend({int days = 30}) => _remote.getTrend(days: days);
}
