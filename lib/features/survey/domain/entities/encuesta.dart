class Encuesta {
  const Encuesta({
    required this.idEncuesta,
    required this.idTicket,
    required this.idUsuarioEvaluador,
    required this.evaluador,
    required this.solucionoProblema,
    required this.nivelSatisfaccion,
    required this.fechaRespuesta,
    this.comentarios,
  });

  final int idEncuesta;
  final int idTicket;
  final int idUsuarioEvaluador;
  final String evaluador;
  final bool solucionoProblema;
  final int nivelSatisfaccion;
  final String? comentarios;
  final String fechaRespuesta;

  String get satisfaccionLabel {
    switch (nivelSatisfaccion) {
      case 1:
        return 'Muy insatisfecho';
      case 2:
        return 'Insatisfecho';
      case 3:
        return 'Neutral';
      case 4:
        return 'Satisfecho';
      case 5:
        return 'Muy satisfecho';
      default:
        return '$nivelSatisfaccion/5';
    }
  }
}
