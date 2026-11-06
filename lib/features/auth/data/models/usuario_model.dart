import '../../domain/entities/usuario.dart';

class UsuarioModel extends Usuario {
  const UsuarioModel({
    required super.idUsuario,
    required super.nombreCompleto,
    required super.usuario,
    required super.rol,
    required super.idRol,
    required super.idDepartamento,
    required super.departamento,
    required super.activo,
    super.correo,
    super.telefono,
    super.fechaCreacion,
    super.ultimoAcceso,
  });

  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    return UsuarioModel(
      idUsuario: _toInt(json['id_usuario']),
      nombreCompleto: json['nombre_completo'] as String? ?? '',
      usuario: json['usuario'] as String? ?? '',
      rol: json['rol'] as String? ?? 'SOLICITANTE',
      idRol: _toInt(json['id_rol']),
      idDepartamento: _toInt(json['id_departamento']),
      departamento: json['departamento'] as String? ?? '',
      activo: json['activo'] as bool? ?? true,
      correo: json['correo'] as String?,
      telefono: json['telefono'] as String?,
      fechaCreacion: json['fecha_creacion'] as String?,
      ultimoAcceso: json['ultimo_acceso'] as String?,
    );
  }

  static int _toInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
