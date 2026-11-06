import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/datasources/assets_remote_datasource.dart';
import '../../data/repositories/assets_repository_impl.dart';
import '../../domain/entities/equipo.dart';
import '../../domain/repositories/assets_repository.dart';

final assetsRepositoryProvider = Provider<AssetsRepository>((ref) {
  return AssetsRepositoryImpl(
    AssetsRemoteDataSource(ref.watch(apiClientProvider)),
  );
});

final assetsProvider =
    AsyncNotifierProvider<AssetsNotifier, List<Equipo>>(AssetsNotifier.new);

class AssetsNotifier extends AsyncNotifier<List<Equipo>> {
  String _search = '';
  int? _idDepartamento;

  @override
  Future<List<Equipo>> build() => _load();

  Future<List<Equipo>> _load() async {
    final result = await ref.read(assetsRepositoryProvider).list(
          search: _search,
          idDepartamento: _idDepartamento,
          limit: 100,
        );
    return result.data;
  }

  Future<void> search(String value) async {
    _search = value;
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> filterByDepartment(int? idDepartamento) async {
    _idDepartamento = idDepartamento;
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(_load);
  }

  Future<Equipo> create(Map<String, dynamic> payload) async {
    final equipo = await ref.read(assetsRepositoryProvider).create(payload);
    state = await AsyncValue.guard(_load);
    return equipo;
  }
}

final departamentosProvider = FutureProvider<List<Departamento>>((ref) {
  return ref.watch(assetsRepositoryProvider).getDepartamentos();
});
