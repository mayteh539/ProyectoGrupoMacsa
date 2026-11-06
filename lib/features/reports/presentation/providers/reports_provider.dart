import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/datasources/reports_remote_datasource.dart';
import '../../data/repositories/reports_repository_impl.dart';
import '../../domain/entities/report_models.dart';
import '../../domain/repositories/reports_repository.dart';

final reportsRepositoryProvider = Provider<ReportsRepository>((ref) {
  return ReportsRepositoryImpl(
    ReportsRemoteDataSource(ref.watch(apiClientProvider)),
  );
});

final dashboardProvider = FutureProvider<DashboardSummary>((ref) {
  return ref.watch(reportsRepositoryProvider).getDashboard();
});

final trendProvider = FutureProvider.family<List<TrendPoint>, int>((ref, days) {
  return ref.watch(reportsRepositoryProvider).getTrend(days: days);
});

final ticketsByStatusProvider = FutureProvider<List<CountByKey>>((ref) {
  return ref.watch(reportsRepositoryProvider).getByStatus();
});

final ticketsByPriorityProvider = FutureProvider<List<CountByKey>>((ref) {
  return ref.watch(reportsRepositoryProvider).getByPriority();
});

final ticketsByCategoryProvider = FutureProvider<List<CountByKey>>((ref) {
  return ref.watch(reportsRepositoryProvider).getByCategory();
});

final ticketsByDepartmentProvider = FutureProvider<List<CountByKey>>((ref) {
  return ref.watch(reportsRepositoryProvider).getByDepartment();
});

final topEquipmentProvider = FutureProvider<List<TopEquipment>>((ref) {
  return ref.watch(reportsRepositoryProvider).getTopEquipment(limit: 10);
});

final topRequestersProvider = FutureProvider<List<TopRequester>>((ref) {
  return ref.watch(reportsRepositoryProvider).getTopRequesters(limit: 10);
});

final resolutionTimesProvider = FutureProvider<List<ResolutionTime>>((ref) {
  return ref.watch(reportsRepositoryProvider).getResolutionTimes();
});

final satisfactionProvider = FutureProvider<SatisfactionSummary>((ref) {
  return ref.watch(reportsRepositoryProvider).getSatisfaction();
});
