class Usuario {
  const Usuario({
    required this.idUsuario,
    required this.nombreCompleto,
    required this.usuario,
    required this.rol,
    required this.idRol,
    required this.idDepartamento,
    required this.departamento,
    required this.activo,
    this.correo,
    this.telefono,
    this.fechaCreacion,
    this.ultimoAcceso,
  });

  final int idUsuario;
  final String nombreCompleto;
  final String usuario;
  final String rol;
  final int idRol;
  final int idDepartamento;
  final String departamento;
  final bool activo;
  final String? correo;
  final String? telefono;
  final String? fechaCreacion;
  final String? ultimoAcceso;

  bool get isAdmin => rol == 'ADMIN_IT';
  bool get isTecnico => rol == 'TECNICO_IT';
  bool get isSolicitante => rol == 'SOLICITANTE';
  bool get puedeVerReportes => isAdmin || isTecnico;

  String get rolLabel {
    switch (rol) {
      case 'ADMIN_IT':
        return 'Administrador de IT';
      case 'TECNICO_IT':
        return 'Tecnico de IT';
      case 'SOLICITANTE':
        return 'Solicitante';
      default:
        return rol;
    }
  }
}

class AuthSession {
  const AuthSession({required this.token, required this.user});

  final String token;
  final Usuario user;
}
