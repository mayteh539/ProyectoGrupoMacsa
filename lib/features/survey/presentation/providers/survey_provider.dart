import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../tickets/presentation/providers/tickets_provider.dart';
import '../../data/datasources/survey_remote_datasource.dart';
import '../../data/repositories/survey_repository_impl.dart';
import '../../domain/entities/encuesta.dart';
import '../../domain/repositories/survey_repository.dart';

final surveyRepositoryProvider = Provider<SurveyRepository>((ref) {
  return SurveyRepositoryImpl(
    SurveyRemoteDataSource(ref.watch(apiClientProvider)),
  );
});

final surveyByTicketProvider =
    FutureProvider.autoDispose.family<Encuesta?, int>((ref, idTicket) {
  return ref.watch(surveyRepositoryProvider).getByTicket(idTicket);
});

class SurveyActions {
  SurveyActions(this._ref);

  final Ref _ref;

  Future<Encuesta> submit({
    required int idTicket,
    required bool solucionoProblema,
    required int nivelSatisfaccion,
    String? comentarios,
  }) async {
    final encuesta = await _ref.read(surveyRepositoryProvider).submit(
          idTicket: idTicket,
          solucionoProblema: solucionoProblema,
          nivelSatisfaccion: nivelSatisfaccion,
          comentarios: comentarios,
        );

    _ref.invalidate(surveyByTicketProvider(idTicket));
    _ref.invalidate(ticketDetailProvider(idTicket));
    _ref.invalidate(ticketsProvider);
    _ref.invalidate(ticketSummaryProvider);

    return encuesta;
  }
}

final surveyActionsProvider = Provider<SurveyActions>((ref) => SurveyActions(ref));
