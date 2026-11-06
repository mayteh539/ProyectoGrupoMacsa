import '../../../../core/models/paged_result.dart';
import '../../domain/entities/equipo.dart';
import '../../domain/repositories/assets_repository.dart';
import '../datasources/assets_remote_datasource.dart';

class AssetsRepositoryImpl implements AssetsRepository {
  AssetsRepositoryImpl(this._remote);

  final AssetsRemoteDataSource _remote;

  @override
  Future<PagedResult<Equipo>> list({
    String? search,
    int? idDepartamento,
    int page = 1,
    int limit = 100,
  }) {
    return _remote.list(
      search: search,
      idDepartamento: idDepartamento,
      page: page,
      limit: limit,
    );
  }

  @override
  Future<List<Departamento>> getDepartamentos() => _remote.getDepartamentos();

  @override
  Future<Equipo> create(Map<String, dynamic> payload) => _remote.create(payload);

  @override
  Future<Equipo> update(int id, Map<String, dynamic> payload) =>
      _remote.update(id, payload);
}
