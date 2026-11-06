import '../../domain/entities/categoria.dart';
import '../../domain/entities/ticket.dart';

int _toInt(Object? value, [int fallback = 0]) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

int? _toNullableInt(Object? value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

bool? _toNullableBool(Object? value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is num) return value != 0;
  return null;
}

class CategoriaModel extends Categoria {
  const CategoriaModel({
    required super.idCategoria,
    required super.nombreCategoria,
    required super.activo,
    super.descripcion,
  });

  factory CategoriaModel.fromJson(Map<String, dynamic> json) {
    return CategoriaModel(
      idCategoria: _toInt(json['id_categoria']),
      nombreCategoria: json['nombre_categoria'] as String? ?? '',
      descripcion: json['descripcion'] as String?,
      activo: json['activo'] as bool? ?? true,
    );
  }
}

class TicketModel extends Ticket {
  const TicketModel({
    required super.idTicket,
    required super.asunto,
    required super.descripcionProblema,
    required super.prioridad,
    required super.estado,
    required super.fechaCreacion,
    required super.fechaActualizacion,
    required super.idSolicitante,
    required super.solicitante,
    required super.usuarioSolicitante,
    required super.idEquipo,
    required super.codigoActivo,
    required super.nombreEquipo,
    required super.categoriaEquipo,
    required super.idCategoria,
    required super.nombreCategoria,
    required super.idDepartamento,
    required super.nombreDepartamento,
    required super.totalAdjuntos,
    super.codigoTicket,
    super.comoOcurrio,
    super.fechaAsignacion,
    super.fechaResolucion,
    super.fechaCierre,
    super.correoSolicitante,
    super.idTecnicoAsignado,
    super.tecnico,
    super.usuarioTecnico,
    super.marca,
    super.modelo,
    super.serie,
    super.idEncuesta,
    super.solucionoProblema,
    super.nivelSatisfaccion,
    super.comentariosEncuesta,
    super.fechaRespuesta,
    super.minutosResolucion,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      idTicket: _toInt(json['id_ticket']),
      codigoTicket: json['codigo_ticket'] as String?,
      asunto: json['asunto'] as String? ?? '',
      descripcionProblema: json['descripcion_problema'] as String? ?? '',
      comoOcurrio: json['como_ocurrio'] as String?,
      prioridad: json['prioridad'] as String? ?? 'MEDIA',
      estado: json['estado'] as String? ?? 'ABIERTO',
      fechaCreacion: json['fecha_creacion'] as String? ?? '',
      fechaAsignacion: json['fecha_asignacion'] as String?,
      fechaResolucion: json['fecha_resolucion'] as String?,
      fechaCierre: json['fecha_cierre'] as String?,
      fechaActualizacion: json['fecha_actualizacion'] as String? ?? '',
      idSolicitante: _toInt(json['id_solicitante']),
      solicitante: json['solicitante'] as String? ?? '',
      usuarioSolicitante: json['usuario_solicitante'] as String? ?? '',
      correoSolicitante: json['correo_solicitante'] as String?,
      idTecnicoAsignado: _toNullableInt(json['id_tecnico_asignado']),
      tecnico: json['tecnico'] as String?,
      usuarioTecnico: json['usuario_tecnico'] as String?,
      idEquipo: _toInt(json['id_equipo']),
      codigoActivo: json['codigo_activo'] as String? ?? '',
      nombreEquipo: json['nombre_equipo'] as String? ?? '',
      categoriaEquipo: json['categoria_equipo'] as String? ?? '',
      marca: json['marca'] as String?,
      modelo: json['modelo'] as String?,
      serie: json['serie'] as String?,
      idCategoria: _toInt(json['id_categoria']),
      nombreCategoria: json['nombre_categoria'] as String? ?? '',
      idDepartamento: _toInt(json['id_departamento']),
      nombreDepartamento: json['nombre_departamento'] as String? ?? '',
      idEncuesta: _toNullableInt(json['id_encuesta']),
      solucionoProblema: _toNullableBool(json['soluciono_problema']),
      nivelSatisfaccion: _toNullableInt(json['nivel_satisfaccion']),
      comentariosEncuesta: json['comentarios_encuesta'] as String?,
      fechaRespuesta: json['fecha_respuesta'] as String?,
      totalAdjuntos: _toInt(json['total_adjuntos']),
      minutosResolucion: _toNullableInt(json['minutos_resolucion']),
    );
  }
}

class TicketAttachmentModel extends TicketAttachment {
  const TicketAttachmentModel({
    required super.idAdjunto,
    required super.idTicket,
    required super.nombreArchivoOriginal,
    required super.nombreArchivoServidor,
    required super.rutaAlmacenamiento,
    required super.fechaSubida,
    required super.url,
    super.mimeType,
    super.tamanioBytes,
  });

  factory TicketAttachmentModel.fromJson(Map<String, dynamic> json) {
    return TicketAttachmentModel(
      idAdjunto: _toInt(json['id_adjunto']),
      idTicket: _toInt(json['id_ticket']),
      nombreArchivoOriginal: json['nombre_archivo_original'] as String? ?? '',
      nombreArchivoServidor: json['nombre_archivo_servidor'] as String? ?? '',
      rutaAlmacenamiento: json['ruta_almacenamiento'] as String? ?? '',
      mimeType: json['mime_type'] as String?,
      tamanioBytes: _toNullableInt(json['tamanio_bytes']),
      fechaSubida: json['fecha_subida'] as String? ?? '',
      url: json['url'] as String? ?? '',
    );
  }
}

class KardexEntryModel extends KardexEntry {
  const KardexEntryModel({
    required super.idHistorial,
    required super.idTicket,
    required super.idUsuarioAccion,
    required super.usuarioAccion,
    required super.usuarioLogin,
    required super.accion,
    required super.fechaRegistro,
    super.estadoAnterior,
    super.estadoNuevo,
    super.observacion,
  });

  factory KardexEntryModel.fromJson(Map<String, dynamic> json) {
    return KardexEntryModel(
      idHistorial: _toInt(json['id_historial']),
      idTicket: _toInt(json['id_ticket']),
      idUsuarioAccion: _toInt(json['id_usuario_accion']),
      usuarioAccion: json['usuario_accion'] as String? ?? '',
      usuarioLogin: json['usuario_login'] as String? ?? '',
      estadoAnterior: json['estado_anterior'] as String?,
      estadoNuevo: json['estado_nuevo'] as String?,
      accion: json['accion'] as String? ?? '',
      observacion: json['observacion'] as String?,
      fechaRegistro: json['fecha_registro'] as String? ?? '',
    );
  }
}

class TicketDetailModel extends TicketDetail {
  const TicketDetailModel({
    required super.ticket,
    required super.adjuntos,
    required super.historial,
  });

  factory TicketDetailModel.fromJson(Map<String, dynamic> json) {
    final adjuntosRaw = json['adjuntos'] as List? ?? const [];
    final historialRaw = json['historial'] as List? ?? const [];

    return TicketDetailModel(
      ticket: TicketModel.fromJson(
        Map<String, dynamic>.from(json['ticket'] as Map),
      ),
      adjuntos: adjuntosRaw
          .whereType<Map>()
          .map((item) => TicketAttachmentModel.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
      historial: historialRaw
          .whereType<Map>()
          .map((item) => KardexEntryModel.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
    );
  }
}

class TicketSummaryModel extends TicketSummary {
  const TicketSummaryModel({
    required super.total,
    required super.abiertos,
    required super.asignados,
    required super.enProceso,
    required super.resueltos,
    required super.cerrados,
    required super.cancelados,
    required super.pendientesEncuesta,
  });

  factory TicketSummaryModel.fromJson(Map<String, dynamic> json) {
    return TicketSummaryModel(
      total: _toInt(json['total']),
      abiertos: _toInt(json['abiertos']),
      asignados: _toInt(json['asignados']),
      enProceso: _toInt(json['en_proceso']),
      resueltos: _toInt(json['resueltos']),
      cerrados: _toInt(json['cerrados']),
      cancelados: _toInt(json['cancelados']),
      pendientesEncuesta: _toInt(json['pendientes_encuesta']),
    );
  }
}
