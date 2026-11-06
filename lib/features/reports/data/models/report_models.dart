import '../../domain/entities/report_models.dart';

int _toInt(Object? value, [int fallback = 0]) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

double? _toDouble(Object? value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

class DashboardSummaryModel extends DashboardSummary {
  const DashboardSummaryModel({
    required super.totalTickets,
    required super.abiertos,
    required super.asignados,
    required super.enProceso,
    required super.resueltos,
    required super.cerrados,
    required super.cancelados,
    required super.creadosHoy,
    required super.creadosSemana,
    required super.creadosMes,
    required super.totalEncuestas,
    required super.pendientesEncuesta,
    super.promedioMinutosResolucion,
    super.promedioSatisfaccion,
  });

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    return DashboardSummaryModel(
      totalTickets: _toInt(json['total_tickets']),
      abiertos: _toInt(json['abiertos']),
      asignados: _toInt(json['asignados']),
      enProceso: _toInt(json['en_proceso']),
      resueltos: _toInt(json['resueltos']),
      cerrados: _toInt(json['cerrados']),
      cancelados: _toInt(json['cancelados']),
      creadosHoy: _toInt(json['creados_hoy']),
      creadosSemana: _toInt(json['creados_semana']),
      creadosMes: _toInt(json['creados_mes']),
      promedioMinutosResolucion: _toDouble(json['promedio_minutos_resolucion']),
      promedioSatisfaccion: _toDouble(json['promedio_satisfaccion']),
      totalEncuestas: _toInt(json['total_encuestas']),
      pendientesEncuesta: _toInt(json['pendientes_encuesta']),
    );
  }
}

class CountByKeyModel extends CountByKey {
  const CountByKeyModel({required super.clave, required super.total});

  factory CountByKeyModel.fromJson(Map<String, dynamic> json) {
    return CountByKeyModel(
      clave: json['clave'] as String? ?? '',
      total: _toInt(json['total']),
    );
  }
}

class TopEquipmentModel extends TopEquipment {
  const TopEquipmentModel({
    required super.idEquipo,
    required super.codigoActivo,
    required super.nombreEquipo,
    required super.categoria,
    required super.nombreDepartamento,
    required super.totalTickets,
    required super.abiertos,
    required super.cerrados,
  });

  factory TopEquipmentModel.fromJson(Map<String, dynamic> json) {
    return TopEquipmentModel(
      idEquipo: _toInt(json['id_equipo']),
      codigoActivo: json['codigo_activo'] as String? ?? '',
      nombreEquipo: json['nombre_equipo'] as String? ?? '',
      categoria: json['categoria'] as String? ?? '',
      nombreDepartamento: json['nombre_departamento'] as String? ?? '',
      totalTickets: _toInt(json['total_tickets']),
      abiertos: _toInt(json['abiertos']),
      cerrados: _toInt(json['cerrados']),
    );
  }
}

class TopRequesterModel extends TopRequester {
  const TopRequesterModel({
    required super.idUsuario,
    required super.nombreCompleto,
    required super.usuario,
    required super.nombreDepartamento,
    required super.totalTickets,
    required super.abiertos,
  });

  factory TopRequesterModel.fromJson(Map<String, dynamic> json) {
    return TopRequesterModel(
      idUsuario: _toInt(json['id_usuario']),
      nombreCompleto: json['nombre_completo'] as String? ?? '',
      usuario: json['usuario'] as String? ?? '',
      nombreDepartamento: json['nombre_departamento'] as String? ?? '',
      totalTickets: _toInt(json['total_tickets']),
      abiertos: _toInt(json['abiertos']),
    );
  }
}

class ResolutionTimeModel extends ResolutionTime {
  const ResolutionTimeModel({
    required super.idTecnicoAsignado,
    required super.tecnico,
    required super.nombreCategoria,
    required super.resueltos,
    super.promedioMinutos,
  });

  factory ResolutionTimeModel.fromJson(Map<String, dynamic> json) {
    return ResolutionTimeModel(
      idTecnicoAsignado: _toInt(json['id_tecnico_asignado']),
      tecnico: json['tecnico'] as String? ?? '',
      nombreCategoria: json['nombre_categoria'] as String? ?? '',
      resueltos: _toInt(json['resueltos']),
      promedioMinutos: _toDouble(json['promedio_minutos']),
    );
  }
}

class SatisfactionSummaryModel extends SatisfactionSummary {
  const SatisfactionSummaryModel({
    required super.totalEncuestas,
    required super.solucionados,
    required super.noSolucionados,
    required super.distribucion,
    super.promedioSatisfaccion,
  });

  factory SatisfactionSummaryModel.fromJson(Map<String, dynamic> json) {
    final distribucion = json['distribucion'] as List? ?? const [];
    return SatisfactionSummaryModel(
      totalEncuestas: _toInt(json['total_encuestas']),
      promedioSatisfaccion: _toDouble(json['promedio_satisfaccion']),
      solucionados: _toInt(json['solucionados']),
      noSolucionados: _toInt(json['no_solucionados']),
      distribucion: distribucion
          .whereType<Map>()
          .map((item) {
            final map = Map<String, dynamic>.from(item);
            return CountByKeyModel(
              clave: map['nivel_satisfaccion']?.toString() ?? '',
              total: _toInt(map['total']),
            );
          })
          .toList(),
    );
  }
}

class TrendPointModel extends TrendPoint {
  const TrendPointModel({
    required super.dia,
    required super.total,
    required super.atendidos,
  });

  factory TrendPointModel.fromJson(Map<String, dynamic> json) {
    return TrendPointModel(
      dia: json['dia'] as String? ?? '',
      total: _toInt(json['total']),
      atendidos: _toInt(json['atendidos']),
    );
  }
}
