class Ticket {
  const Ticket({
    required this.idTicket,
    required this.asunto,
    required this.descripcionProblema,
    required this.prioridad,
    required this.estado,
    required this.fechaCreacion,
    required this.fechaActualizacion,
    required this.idSolicitante,
    required this.solicitante,
    required this.usuarioSolicitante,
    required this.idEquipo,
    required this.codigoActivo,
    required this.nombreEquipo,
    required this.categoriaEquipo,
    required this.idCategoria,
    required this.nombreCategoria,
    required this.idDepartamento,
    required this.nombreDepartamento,
    required this.totalAdjuntos,
    this.codigoTicket,
    this.comoOcurrio,
    this.fechaAsignacion,
    this.fechaResolucion,
    this.fechaCierre,
    this.correoSolicitante,
    this.idTecnicoAsignado,
    this.tecnico,
    this.usuarioTecnico,
    this.marca,
    this.modelo,
    this.serie,
    this.idEncuesta,
    this.solucionoProblema,
    this.nivelSatisfaccion,
    this.comentariosEncuesta,
    this.fechaRespuesta,
    this.minutosResolucion,
  });

  final int idTicket;
  final String? codigoTicket;
  final String asunto;
  final String descripcionProblema;
  final String? comoOcurrio;
  final String prioridad;
  final String estado;
  final String fechaCreacion;
  final String? fechaAsignacion;
  final String? fechaResolucion;
  final String? fechaCierre;
  final String fechaActualizacion;
  final int idSolicitante;
  final String solicitante;
  final String usuarioSolicitante;
  final String? correoSolicitante;
  final int? idTecnicoAsignado;
  final String? tecnico;
  final String? usuarioTecnico;
  final int idEquipo;
  final String codigoActivo;
  final String nombreEquipo;
  final String categoriaEquipo;
  final String? marca;
  final String? modelo;
  final String? serie;
  final int idCategoria;
  final String nombreCategoria;
  final int idDepartamento;
  final String nombreDepartamento;
  final int? idEncuesta;
  final bool? solucionoProblema;
  final int? nivelSatisfaccion;
  final String? comentariosEncuesta;
  final String? fechaRespuesta;
  final int totalAdjuntos;
  final int? minutosResolucion;

  String get folio => codigoTicket ?? 'TCK-$idTicket';
  bool get estaCerrado => estado == 'CERRADO' || estado == 'CANCELADO';
  bool get estaResuelto => estado == 'RESUELTO';
  bool get pendienteEncuesta => estado == 'RESUELTO' && idEncuesta == null;
  bool get tieneTecnico => idTecnicoAsignado != null;

  String get equipoDescripcion {
    final partes = [marca, modelo].whereType<String>().where((p) => p.isNotEmpty);
    return partes.isEmpty ? categoriaEquipo : '$categoriaEquipo · ${partes.join(' ')}';
  }
}

class TicketAttachment {
  const TicketAttachment({
    required this.idAdjunto,
    required this.idTicket,
    required this.nombreArchivoOriginal,
    required this.nombreArchivoServidor,
    required this.rutaAlmacenamiento,
    required this.fechaSubida,
    required this.url,
    this.mimeType,
    this.tamanioBytes,
  });

  final int idAdjunto;
  final int idTicket;
  final String nombreArchivoOriginal;
  final String nombreArchivoServidor;
  final String rutaAlmacenamiento;
  final String? mimeType;
  final int? tamanioBytes;
  final String fechaSubida;
  final String url;
}

class KardexEntry {
  const KardexEntry({
    required this.idHistorial,
    required this.idTicket,
    required this.idUsuarioAccion,
    required this.usuarioAccion,
    required this.usuarioLogin,
    required this.accion,
    required this.fechaRegistro,
    this.estadoAnterior,
    this.estadoNuevo,
    this.observacion,
  });

  final int idHistorial;
  final int idTicket;
  final int idUsuarioAccion;
  final String usuarioAccion;
  final String usuarioLogin;
  final String? estadoAnterior;
  final String? estadoNuevo;
  final String accion;
  final String? observacion;
  final String fechaRegistro;

  String get accionLabel {
    switch (accion) {
      case 'CREACION':
        return 'Creacion del ticket';
      case 'ASIGNACION':
        return 'Asignacion de tecnico';
      case 'CAMBIO_ESTADO':
        return 'Cambio de estado';
      case 'NOTA':
        return 'Nota';
      case 'ADJUNTO':
        return 'Evidencia adjunta';
      case 'ENCUESTA':
        return 'Encuesta de satisfaccion';
      default:
        return accion;
    }
  }
}

class TicketDetail {
  const TicketDetail({
    required this.ticket,
    required this.adjuntos,
    required this.historial,
  });

  final Ticket ticket;
  final List<TicketAttachment> adjuntos;
  final List<KardexEntry> historial;
}

class TicketSummary {
  const TicketSummary({
    required this.total,
    required this.abiertos,
    required this.asignados,
    required this.enProceso,
    required this.resueltos,
    required this.cerrados,
    required this.cancelados,
    required this.pendientesEncuesta,
  });

  final int total;
  final int abiertos;
  final int asignados;
  final int enProceso;
  final int resueltos;
  final int cerrados;
  final int cancelados;
  final int pendientesEncuesta;

  int get activos => abiertos + asignados + enProceso;
}

class TicketFilter {
  const TicketFilter({this.estado, this.prioridad, this.search});

  final String? estado;
  final String? prioridad;
  final String? search;

  TicketFilter copyWith({
    String? estado,
    String? prioridad,
    String? search,
    bool clearEstado = false,
    bool clearPrioridad = false,
  }) {
    return TicketFilter(
      estado: clearEstado ? null : (estado ?? this.estado),
      prioridad: clearPrioridad ? null : (prioridad ?? this.prioridad),
      search: search ?? this.search,
    );
  }
}
