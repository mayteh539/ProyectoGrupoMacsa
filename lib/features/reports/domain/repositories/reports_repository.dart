import '../entities/report_models.dart';

abstract class ReportsRepository {
  Future<DashboardSummary> getDashboard();
  Future<List<CountByKey>> getByStatus();
  Future<List<CountByKey>> getByPriority();
  Future<List<CountByKey>> getByCategory();
  Future<List<CountByKey>> getByDepartment();
  Future<List<TopEquipment>> getTopEquipment({int limit = 10});
  Future<List<TopRequester>> getTopRequesters({int limit = 10});
  Future<List<ResolutionTime>> getResolutionTimes();
  Future<SatisfactionSummary> getSatisfaction();
  Future<List<TrendPoint>> getTrend({int days = 30});
}
