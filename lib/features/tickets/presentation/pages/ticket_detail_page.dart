import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/models/upload_file.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../auth/domain/entities/usuario.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../survey/presentation/pages/survey_page.dart';
import '../../domain/entities/ticket.dart';
import '../providers/tickets_provider.dart';
import '../widgets/ticket_timeline.dart';

class TicketDetailPage extends ConsumerStatefulWidget {
  const TicketDetailPage({super.key, required this.idTicket, this.folio});

  final int idTicket;
  final String? folio;

  @override
  ConsumerState<TicketDetailPage> createState() => _TicketDetailPageState();
}

class _TicketDetailPageState extends ConsumerState<TicketDetailPage> {
  final _picker = ImagePicker();
  bool _busy = false;

  void _notify(String message, {bool error = false}) {
    if (!mounted) return;
    showAppSnackBar(context, message, error: error);
  }

  Future<T> _run<T>(Future<T> Function() action) async {
    setState(() => _busy = true);
    try {
      return await action();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _assign(Ticket ticket, List<Usuario> technicians) async {
    if (technicians.isEmpty) {
      _notify('No hay tecnicos activos disponibles', error: true);
      return;
    }

    var selected = technicians.first.idUsuario;
    final observacion = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Asignar tecnico'),
          content: SizedBox(
            width: 460,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  initialValue: selected,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Tecnico',
                    prefixIcon: Icon(Icons.build_outlined),
                  ),
                  items: technicians
                      .map(
                        (tecnico) => DropdownMenuItem(
                          value: tecnico.idUsuario,
                          child: Text(tecnico.nombreCompleto),
                        ),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setDialogState(() => selected = value ?? selected),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: observacion,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Observacion (opcional)',
                    alignLabelWithHint: true,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Asignar'),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true) {
      try {
        await _run(
          () => ref.read(ticketActionsProvider).assign(
                ticket.idTicket,
                selected,
                observacion: observacion.text,
              ),
        );
        _notify('Ticket asignado correctamente');
      } catch (error) {
        _notify(error.toString(), error: true);
      }
    }
    observacion.dispose();
  }

  Future<void> _changeStatus(Ticket ticket, String estado, String label) async {
    final observacion = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(label),
        content: SizedBox(
          width: 460,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'El ticket ${ticket.folio} pasara al estado ${StatusBadge.labelFor(estado)}.',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: observacion,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Observacion',
                  alignLabelWithHint: true,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(label),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _run(
          () => ref.read(ticketActionsProvider).changeStatus(
                ticket.idTicket,
                estado,
                observacion: observacion.text,
              ),
        );
        _notify('Estado actualizado a ${StatusBadge.labelFor(estado)}');
      } catch (error) {
        _notify(error.toString(), error: true);
      }
    }
    observacion.dispose();
  }

  Future<void> _addNote(Ticket ticket) async {
    final observacion = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Agregar nota'),
        content: SizedBox(
          width: 460,
          child: TextField(
            controller: observacion,
            autofocus: true,
            minLines: 3,
            maxLines: 6,
            maxLength: 1000,
            decoration: const InputDecoration(
              labelText: 'Nota para el kardex',
              alignLabelWithHint: true,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final text = observacion.text.trim();
      if (text.isEmpty) {
        _notify('La nota no puede estar vacia', error: true);
      } else {
        try {
          await _run(() => ref.read(ticketActionsProvider).addNote(ticket.idTicket, text));
          _notify('Nota registrada en el historial');
        } catch (error) {
          _notify(error.toString(), error: true);
        }
      }
    }
    observacion.dispose();
  }

  Future<void> _addAttachment(Ticket ticket, ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 72,
        maxWidth: 1600,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      await _run(
        () => ref.read(ticketActionsProvider).addAttachment(
              ticket.idTicket,
              UploadFile(name: picked.name, bytes: bytes),
            ),
      );
      _notify('Evidencia adjuntada correctamente');
    } catch (error) {
      _notify('No se pudo adjuntar la imagen: $error', error: true);
    }
  }

  Future<void> _openSurvey(Ticket ticket) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => SurveyPage(idTicket: ticket.idTicket, folio: ticket.folio),
      ),
    );
    if (result == true) {
      ref.invalidate(ticketDetailProvider(ticket.idTicket));
      ref.invalidate(ticketSummaryProvider);
      ref.invalidate(ticketsProvider);
    }
  }

  void _viewImage(TicketAttachment attachment) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(12),
        child: Stack(
          children: [
            Positioned.fill(
              child: InteractiveViewer(
                child: CachedNetworkImage(
                  imageUrl: ApiClient.resolveMediaUrl(attachment.url),
                  fit: BoxFit.contain,
                  errorWidget: (_, _, _) => const Center(
                    child: Text(
                      'No se pudo cargar la imagen',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: IconButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                icon: const Icon(Icons.close_rounded, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(ticketDetailProvider(widget.idTicket));
    final user = ref.watch(authProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: Text(detail.value?.ticket.folio ?? widget.folio ?? 'Ticket'),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: () => ref.invalidate(ticketDetailProvider(widget.idTicket)),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: detail.when(
        loading: () => const AppLoadingView(message: 'Cargando ticket...'),
        error: (error, _) => AppErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(ticketDetailProvider(widget.idTicket)),
        ),
        data: (data) => _buildContent(context, data, user),
      ),
      bottomNavigationBar: detail.value == null
          ? null
          : _ActionBar(
              ticket: detail.value!.ticket,
              user: user,
              busy: _busy,
              onAssign: () {
                final technicians = ref.read(techniciansProvider).value ?? const [];
                _assign(detail.value!.ticket, technicians);
              },
              onStatus: (estado, label) =>
                  _changeStatus(detail.value!.ticket, estado, label),
              onNote: () => _addNote(detail.value!.ticket),
              onAttach: (source) => _addAttachment(detail.value!.ticket, source),
              onSurvey: () => _openSurvey(detail.value!.ticket),
            ),
    );
  }

  Widget _buildContent(BuildContext context, TicketDetail data, Usuario? user) {
    final ticket = data.ticket;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    StatusBadge(ticket.estado),
                    const SizedBox(width: 10),
                    PriorityBadge(ticket.prioridad),
                    const Spacer(),
                    Text(
                      formatFecha(ticket.fechaCreacion),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  ticket.asunto,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  ticket.descripcionProblema,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                ),
                if (ticket.comoOcurrio != null && ticket.comoOcurrio!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    '¿Como ocurrio?',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ticket.comoOcurrio!,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: 'Informacion del ticket',
          icon: Icons.info_outline_rounded,
          child: Column(
            children: [
              InfoRow(
                label: 'Equipo',
                value: '${ticket.codigoActivo} · ${ticket.nombreEquipo}',
                icon: Icons.devices_other_rounded,
              ),
              InfoRow(
                label: 'Categoria',
                value: ticket.nombreCategoria,
                icon: Icons.category_outlined,
              ),
              InfoRow(
                label: 'Departamento',
                value: ticket.nombreDepartamento,
                icon: Icons.apartment_rounded,
              ),
              InfoRow(
                label: 'Solicitante',
                value: ticket.solicitante,
                icon: Icons.person_outline_rounded,
              ),
              InfoRow(
                label: 'Tecnico',
                value: ticket.tecnico ?? 'Sin asignar',
                icon: Icons.build_outlined,
              ),
              InfoRow(
                label: 'Asignado',
                value: formatFecha(ticket.fechaAsignacion),
                icon: Icons.event_available_outlined,
              ),
              InfoRow(
                label: 'Resuelto',
                value: formatFecha(ticket.fechaResolucion),
                icon: Icons.task_alt_rounded,
              ),
              if (ticket.fechaCierre != null)
                InfoRow(
                  label: 'Cerrado',
                  value: formatFecha(ticket.fechaCierre),
                  icon: Icons.lock_outline_rounded,
                ),
              if (ticket.minutosResolucion != null)
                InfoRow(
                  label: 'Tiempo atencion',
                  value: formatDuracion(ticket.minutosResolucion),
                  icon: Icons.timer_outlined,
                ),
            ],
          ),
        ),
        if (ticket.pendienteEncuesta && (user?.isSolicitante ?? false)) ...[
          const SizedBox(height: 16),
          Card(
            color: const Color(0xFFFFF8E1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: Color(0xFFF9A825)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Encuesta de satisfaccion pendiente',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'El ticket fue resuelto. Responde la encuesta para cerrarlo.',
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _busy ? null : () => _openSurvey(ticket),
                    icon: const Icon(Icons.rate_review_outlined),
                    label: const Text('Responder encuesta'),
                  ),
                ],
              ),
            ),
          ),
        ],
        if (ticket.idEncuesta != null) ...[
          const SizedBox(height: 16),
          SectionCard(
            title: 'Encuesta de satisfaccion',
            icon: Icons.star_outline_rounded,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ...List.generate(
                      5,
                      (index) => Icon(
                        index < (ticket.nivelSatisfaccion ?? 0)
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        color: const Color(0xFFF9A825),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${ticket.nivelSatisfaccion ?? 0}/5',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      ticket.solucionoProblema == true
                          ? Icons.check_circle_rounded
                          : Icons.cancel_rounded,
                      size: 18,
                      color: ticket.solucionoProblema == true
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFFC62828),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      ticket.solucionoProblema == true
                          ? 'El problema fue solucionado'
                          : 'El problema no fue solucionado',
                    ),
                  ],
                ),
                if (ticket.comentariosEncuesta != null &&
                    ticket.comentariosEncuesta!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    ticket.comentariosEncuesta!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  'Respondida el ${formatFecha(ticket.fechaRespuesta)}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        SectionCard(
          title: 'Evidencias (${data.adjuntos.length})',
          icon: Icons.photo_library_outlined,
          child: data.adjuntos.isEmpty
              ? Text(
                  'Sin evidencias adjuntas.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                )
              : Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: data.adjuntos
                      .map(
                        (adjunto) => InkWell(
                          onTap: () => _viewImage(adjunto),
                          borderRadius: BorderRadius.circular(12),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              width: 108,
                              height: 108,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  CachedNetworkImage(
                                    imageUrl: ApiClient.resolveMediaUrl(adjunto.url),
                                    fit: BoxFit.cover,
                                    placeholder: (_, _) => Container(
                                      color: colorScheme.surfaceContainerHighest,
                                      child: const Center(
                                        child: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        ),
                                      ),
                                    ),
                                    errorWidget: (_, _, _) => Container(
                                      color: colorScheme.surfaceContainerHighest,
                                      child: const Icon(Icons.broken_image_outlined),
                                    ),
                                  ),
                                  Positioned(
                                    left: 0,
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 3,
                                      ),
                                      color: Colors.black54,
                                      child: Text(
                                        adjunto.nombreArchivoOriginal,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: 'Historial (kardex)',
          icon: Icons.history_rounded,
          child: TicketTimeline(entries: data.historial),
        ),
      ],
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.ticket,
    required this.user,
    required this.busy,
    required this.onAssign,
    required this.onStatus,
    required this.onNote,
    required this.onAttach,
    required this.onSurvey,
  });

  final Ticket ticket;
  final Usuario? user;
  final bool busy;
  final VoidCallback onAssign;
  final void Function(String estado, String label) onStatus;
  final VoidCallback onNote;
  final ValueChanged<ImageSource> onAttach;
  final VoidCallback onSurvey;

  @override
  Widget build(BuildContext context) {
    final actions = <Widget>[];

    if (user != null) {
      if (user!.isAdmin &&
          (ticket.estado == 'ABIERTO' || ticket.estado == 'ASIGNADO')) {
        actions.add(
          FilledButton.icon(
            onPressed: busy ? null : onAssign,
            icon: const Icon(Icons.assignment_ind_outlined),
            label: const Text('Asignar'),
          ),
        );
      }

      if (user!.isAdmin) {
        if (ticket.estado == 'ABIERTO' || ticket.estado == 'ASIGNADO') {
          actions.add(
            OutlinedButton.icon(
              onPressed: busy ? null : () => onStatus('EN_PROCESO', 'Iniciar proceso'),
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Iniciar'),
            ),
          );
        }
        if (ticket.estado == 'EN_PROCESO') {
          actions.add(
            OutlinedButton.icon(
              onPressed: busy ? null : () => onStatus('RESUELTO', 'Marcar resuelto'),
              icon: const Icon(Icons.task_alt_rounded),
              label: const Text('Resolver'),
            ),
          );
        }
        if (!ticket.estaCerrado) {
          actions.add(
            TextButton.icon(
              onPressed: busy ? null : () => onStatus('CANCELADO', 'Cancelar ticket'),
              icon: const Icon(Icons.block_rounded),
              label: const Text('Cancelar'),
            ),
          );
        }
      } else if (user!.isTecnico && ticket.idTecnicoAsignado == user!.idUsuario) {
        if (ticket.estado == 'ASIGNADO') {
          actions.add(
            FilledButton.icon(
              onPressed: busy ? null : () => onStatus('EN_PROCESO', 'Iniciar proceso'),
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Iniciar proceso'),
            ),
          );
        } else if (ticket.estado == 'EN_PROCESO') {
          actions.add(
            FilledButton.icon(
              onPressed: busy ? null : () => onStatus('RESUELTO', 'Marcar resuelto'),
              icon: const Icon(Icons.task_alt_rounded),
              label: const Text('Marcar resuelto'),
            ),
          );
        }
      } else if (user!.isSolicitante) {
        if (ticket.pendienteEncuesta) {
          actions.add(
            FilledButton.icon(
              onPressed: busy ? null : onSurvey,
              icon: const Icon(Icons.rate_review_outlined),
              label: const Text('Responder encuesta'),
            ),
          );
        }
        if (ticket.estado == 'ABIERTO' || ticket.estado == 'ASIGNADO') {
          actions.add(
            TextButton.icon(
              onPressed: busy ? null : () => onStatus('CANCELADO', 'Cancelar ticket'),
              icon: const Icon(Icons.block_rounded),
              label: const Text('Cancelar ticket'),
            ),
          );
        }
      }

      actions.add(
        OutlinedButton.icon(
          onPressed: busy ? null : onNote,
          icon: const Icon(Icons.sticky_note_2_outlined),
          label: const Text('Nota'),
        ),
      );

      if (!ticket.estaCerrado) {
        actions.add(
          OutlinedButton.icon(
            onPressed: busy
                ? null
                : () => showModalBottomSheet<void>(
                      context: context,
                      builder: (sheetContext) => SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.photo_library_outlined),
                              title: const Text('Elegir de la galeria'),
                              onTap: () {
                                Navigator.of(sheetContext).pop();
                                onAttach(ImageSource.gallery);
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.photo_camera_outlined),
                              title: const Text('Tomar foto'),
                              onTap: () {
                                Navigator.of(sheetContext).pop();
                                onAttach(ImageSource.camera);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
            icon: const Icon(Icons.attach_file_rounded),
            label: const Text('Evidencia'),
          ),
        );
      }
    }

    if (actions.isEmpty) return const SizedBox.shrink();

    return Material(
      elevation: 8,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var i = 0; i < actions.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  actions[i],
                ],
                if (busy) ...[
                  const SizedBox(width: 12),
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
