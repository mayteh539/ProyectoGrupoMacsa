import '../../domain/entities/encuesta.dart';
import '../../domain/repositories/survey_repository.dart';
import '../datasources/survey_remote_datasource.dart';

class SurveyRepositoryImpl implements SurveyRepository {
  SurveyRepositoryImpl(this._remote);

  final SurveyRemoteDataSource _remote;

  @override
  Future<Encuesta?> getByTicket(int idTicket) => _remote.getByTicket(idTicket);

  @override
  Future<Encuesta> submit({
    required int idTicket,
    required bool solucionoProblema,
    required int nivelSatisfaccion,
    String? comentarios,
  }) {
    return _remote.submit(
      idTicket: idTicket,
      solucionoProblema: solucionoProblema,
      nivelSatisfaccion: nivelSatisfaccion,
      comentarios: comentarios,
    );
  }
}
