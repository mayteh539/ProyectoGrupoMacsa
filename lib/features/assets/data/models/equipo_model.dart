import '../../domain/entities/equipo.dart';

class EquipoModel extends Equipo {
  const EquipoModel({
    required super.idEquipo,
    required super.codigoActivo,
    required super.nombreEquipo,
    required super.categoria,
    required super.idDepartamento,
    required super.departamento,
    required super.estadoOperativo,
    required super.activo,
    super.marca,
    super.modelo,
    super.serie,
    super.fechaIngreso,
  });

  factory EquipoModel.fromJson(Map<String, dynamic> json) {
    return EquipoModel(
      idEquipo: _toInt(json['id_equipo']),
      codigoActivo: json['codigo_activo'] as String? ?? '',
      nombreEquipo: json['nombre_equipo'] as String? ?? '',
      categoria: json['categoria'] as String? ?? '',
      marca: json['marca'] as String?,
      modelo: json['modelo'] as String?,
      serie: json['serie'] as String?,
      idDepartamento: _toInt(json['id_departamento']),
      departamento: json['departamento'] as String? ?? '',
      estadoOperativo: json['estado_operativo'] as String? ?? 'OPERATIVO',
      activo: json['activo'] as bool? ?? true,
      fechaIngreso: json['fecha_ingreso'] as String?,
    );
  }

  static int _toInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class DepartamentoModel extends Departamento {
  const DepartamentoModel({
    required super.idDepartamento,
    required super.nombreDepartamento,
    required super.activo,
    super.ubicacionPlanta,
  });

  factory DepartamentoModel.fromJson(Map<String, dynamic> json) {
    return DepartamentoModel(
      idDepartamento: EquipoModel._toInt(json['id_departamento']),
      nombreDepartamento: json['nombre_departamento'] as String? ?? '',
      ubicacionPlanta: json['ubicacion_planta'] as String?,
      activo: json['activo'] as bool? ?? true,
    );
  }
}
