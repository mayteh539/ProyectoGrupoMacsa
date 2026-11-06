import '../../domain/entities/encuesta.dart';

class EncuestaModel extends Encuesta {
  const EncuestaModel({
    required super.idEncuesta,
    required super.idTicket,
    required super.idUsuarioEvaluador,
    required super.evaluador,
    required super.solucionoProblema,
    required super.nivelSatisfaccion,
    required super.fechaRespuesta,
    super.comentarios,
  });

  factory EncuestaModel.fromJson(Map<String, dynamic> json) {
    return EncuestaModel(
      idEncuesta: _toInt(json['id_encuesta']),
      idTicket: _toInt(json['id_ticket']),
      idUsuarioEvaluador: _toInt(json['id_usuario_evaluador']),
      evaluador: json['evaluador'] as String? ?? '',
      solucionoProblema: json['soluciono_problema'] as bool? ?? false,
      nivelSatisfaccion: _toInt(json['nivel_satisfaccion']),
      comentarios: json['comentarios'] as String?,
      fechaRespuesta: json['fecha_respuesta'] as String? ?? '',
    );
  }

  static int _toInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
