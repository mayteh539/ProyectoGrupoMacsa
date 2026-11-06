import '../../../../core/network/api_client.dart';
import '../models/encuesta_model.dart';

class SurveyRemoteDataSource {
  SurveyRemoteDataSource(this._client);

  final ApiClient _client;

  Future<EncuestaModel?> getByTicket(int idTicket) async {
    try {
      final response = await _client.get('/encuestas/$idTicket');
      final data = Map<String, dynamic>.from(response as Map);
      return EncuestaModel.fromJson(Map<String, dynamic>.from(data['survey'] as Map));
    } catch (_) {
      return null;
    }
  }

  Future<EncuestaModel> submit({
    required int idTicket,
    required bool solucionoProblema,
    required int nivelSatisfaccion,
    String? comentarios,
  }) async {
    final response = await _client.post(
      '/encuestas/$idTicket',
      data: {
        'soluciono_problema': solucionoProblema,
        'nivel_satisfaccion': nivelSatisfaccion,
        if (comentarios != null && comentarios.trim().isNotEmpty)
          'comentarios': comentarios.trim(),
      },
    );
    final data = Map<String, dynamic>.from(response as Map);
    return EncuestaModel.fromJson(Map<String, dynamic>.from(data['survey'] as Map));
  }
}
