class Equipo {
  const Equipo({
    required this.idEquipo,
    required this.codigoActivo,
    required this.nombreEquipo,
    required this.categoria,
    required this.idDepartamento,
    required this.departamento,
    required this.estadoOperativo,
    required this.activo,
    this.marca,
    this.modelo,
    this.serie,
    this.fechaIngreso,
  });

  final int idEquipo;
  final String codigoActivo;
  final String nombreEquipo;
  final String categoria;
  final String? marca;
  final String? modelo;
  final String? serie;
  final int idDepartamento;
  final String departamento;
  final String estadoOperativo;
  final bool activo;
  final String? fechaIngreso;

  String get descripcionTecnica {
    final partes = [marca, modelo].whereType<String>().where((p) => p.isNotEmpty);
    return partes.isEmpty ? categoria : partes.join(' ');
  }
}

class Departamento {
  const Departamento({
    required this.idDepartamento,
    required this.nombreDepartamento,
    required this.activo,
    this.ubicacionPlanta,
  });

  final int idDepartamento;
  final String nombreDepartamento;
  final String? ubicacionPlanta;
  final bool activo;
}
