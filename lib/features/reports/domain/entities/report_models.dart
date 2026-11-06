class DashboardSummary {
  const DashboardSummary({
    required this.totalTickets,
    required this.abiertos,
    required this.asignados,
    required this.enProceso,
    required this.resueltos,
    required this.cerrados,
    required this.cancelados,
    required this.creadosHoy,
    required this.creadosSemana,
    required this.creadosMes,
    required this.totalEncuestas,
    required this.pendientesEncuesta,
    this.promedioMinutosResolucion,
    this.promedioSatisfaccion,
  });

  final int totalTickets;
  final int abiertos;
  final int asignados;
  final int enProceso;
  final int resueltos;
  final int cerrados;
  final int cancelados;
  final int creadosHoy;
  final int creadosSemana;
  final int creadosMes;
  final double? promedioMinutosResolucion;
  final double? promedioSatisfaccion;
  final int totalEncuestas;
  final int pendientesEncuesta;

  int get activos => abiertos + asignados + enProceso;
}

class CountByKey {
  const CountByKey({required this.clave, required this.total});

  final String clave;
  final int total;
}

class TopEquipment {
  const TopEquipment({
    required this.idEquipo,
    required this.codigoActivo,
    required this.nombreEquipo,
    required this.categoria,
    required this.nombreDepartamento,
    required this.totalTickets,
    required this.abiertos,
    required this.cerrados,
  });

  final int idEquipo;
  final String codigoActivo;
  final String nombreEquipo;
  final String categoria;
  final String nombreDepartamento;
  final int totalTickets;
  final int abiertos;
  final int cerrados;
}

class TopRequester {
  const TopRequester({
    required this.idUsuario,
    required this.nombreCompleto,
    required this.usuario,
    required this.nombreDepartamento,
    required this.totalTickets,
    required this.abiertos,
  });

  final int idUsuario;
  final String nombreCompleto;
  final String usuario;
  final String nombreDepartamento;
  final int totalTickets;
  final int abiertos;
}

class ResolutionTime {
  const ResolutionTime({
    required this.idTecnicoAsignado,
    required this.tecnico,
    required this.nombreCategoria,
    required this.resueltos,
    this.promedioMinutos,
  });

  final int idTecnicoAsignado;
  final String tecnico;
  final String nombreCategoria;
  final int resueltos;
  final double? promedioMinutos;
}

class SatisfactionSummary {
  const SatisfactionSummary({
    required this.totalEncuestas,
    required this.solucionados,
    required this.noSolucionados,
    required this.distribucion,
    this.promedioSatisfaccion,
  });

  final int totalEncuestas;
  final double? promedioSatisfaccion;
  final int solucionados;
  final int noSolucionados;
  final List<CountByKey> distribucion;
}

class TrendPoint {
  const TrendPoint({
    required this.dia,
    required this.total,
    required this.atendidos,
  });

  final String dia;
  final int total;
  final int atendidos;
}
