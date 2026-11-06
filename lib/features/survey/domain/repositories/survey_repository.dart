import '../entities/encuesta.dart';

abstract class SurveyRepository {
  Future<Encuesta?> getByTicket(int idTicket);

  Future<Encuesta> submit({
    required int idTicket,
    required bool solucionoProblema,
    required int nivelSatisfaccion,
    String? comentarios,
  });
}
