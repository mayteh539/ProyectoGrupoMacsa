import '../../../../core/models/paged_result.dart';
import '../entities/equipo.dart';

abstract class AssetsRepository {
  Future<PagedResult<Equipo>> list({
    String? search,
    int? idDepartamento,
    int page = 1,
    int limit = 100,
  });

  Future<List<Departamento>> getDepartamentos();

  Future<Equipo> create(Map<String, dynamic> payload);

  Future<Equipo> update(int id, Map<String, dynamic> payload);
}
