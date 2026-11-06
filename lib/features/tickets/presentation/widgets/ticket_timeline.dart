import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/entities/ticket.dart';

class TicketTimeline extends StatelessWidget {
  const TicketTimeline({super.key, required this.entries});

  final List<KardexEntry> entries;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Text('Sin movimientos registrados.'),
      );
    }

    return Column(
      children: [
        for (var i = 0; i < entries.length; i++)
          _TimelineTile(
            entry: entries[i],
            isFirst: i == 0,
            isLast: i == entries.length - 1,
          ),
      ],
    );
  }
}

class _TimelineTile extends StatelessWidget {
  const _TimelineTile({
    required this.entry,
    required this.isFirst,
    required this.isLast,
  });

  final KardexEntry entry;
  final bool isFirst;
  final bool isLast;

  ({IconData icon, Color color}) get _style {
    switch (entry.accion) {
      case 'CREACION':
        return (icon: Icons.add_circle_outline_rounded, color: const Color(0xFF1565C0));
      case 'ASIGNACION':
        return (icon: Icons.assignment_ind_outlined, color: const Color(0xFF6A1B9A));
      case 'CAMBIO_ESTADO':
        return (icon: Icons.swap_horiz_rounded, color: const Color(0xFFEF6C00));
      case 'NOTA':
        return (icon: Icons.sticky_note_2_outlined, color: const Color(0xFF00897B));
      case 'ADJUNTO':
        return (icon: Icons.attach_file_rounded, color: const Color(0xFF546E7A));
      case 'ENCUESTA':
        return (icon: Icons.star_outline_rounded, color: const Color(0xFFF9A825));
      default:
        return (icon: Icons.history_rounded, color: const Color(0xFF546E7A));
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = _style;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 36,
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    width: 2,
                    color: isFirst
                        ? Colors.transparent
                        : colorScheme.outlineVariant.withValues(alpha: 0.7),
                  ),
                ),
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: style.color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(color: style.color.withValues(alpha: 0.5)),
                  ),
                  child: Icon(style.icon, size: 16, color: style.color),
                ),
                Expanded(
                  child: Container(
                    width: 2,
                    color: isLast
                        ? Colors.transparent
                        : colorScheme.outlineVariant.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.accionLabel,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        formatFecha(entry.fechaRegistro),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline_rounded,
                        size: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        entry.usuarioAccion,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  if (entry.estadoNuevo != null) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (entry.estadoAnterior != null)
                          StatusBadge(entry.estadoAnterior!, compact: true),
                        if (entry.estadoAnterior != null)
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 14,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        StatusBadge(entry.estadoNuevo!, compact: true),
                      ],
                    ),
                  ],
                  if (entry.observacion != null && entry.observacion!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        entry.observacion!,
                        style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
