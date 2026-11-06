import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge(this.estado, {super.key, this.compact = false});

  final String estado;
  final bool compact;

  static Color colorFor(String estado) {
    switch (estado) {
      case 'ABIERTO':
        return const Color(0xFF1565C0);
      case 'ASIGNADO':
        return const Color(0xFF6A1B9A);
      case 'EN_PROCESO':
        return const Color(0xFFEF6C00);
      case 'RESUELTO':
        return const Color(0xFF00897B);
      case 'CERRADO':
        return const Color(0xFF2E7D32);
      case 'CANCELADO':
        return const Color(0xFF616161);
      default:
        return const Color(0xFF546E7A);
    }
  }

  static String labelFor(String estado) {
    switch (estado) {
      case 'ABIERTO':
        return 'Abierto';
      case 'ASIGNADO':
        return 'Asignado';
      case 'EN_PROCESO':
        return 'En proceso';
      case 'RESUELTO':
        return 'Resuelto';
      case 'CERRADO':
        return 'Cerrado';
      case 'CANCELADO':
        return 'Cancelado';
      default:
        return estado;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = colorFor(estado);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 10, vertical: compact ? 3 : 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        labelFor(estado),
        style: TextStyle(
          color: color,
          fontSize: compact ? 11 : 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class PriorityBadge extends StatelessWidget {
  const PriorityBadge(this.prioridad, {super.key});

  final String prioridad;

  static Color colorFor(String prioridad) {
    switch (prioridad) {
      case 'BAJA':
        return const Color(0xFF2E7D32);
      case 'MEDIA':
        return const Color(0xFF1565C0);
      case 'ALTA':
        return const Color(0xFFEF6C00);
      case 'CRITICA':
        return const Color(0xFFC62828);
      default:
        return const Color(0xFF546E7A);
    }
  }

  static String labelFor(String prioridad) {
    switch (prioridad) {
      case 'BAJA':
        return 'Baja';
      case 'MEDIA':
        return 'Media';
      case 'ALTA':
        return 'Alta';
      case 'CRITICA':
        return 'Critica';
      default:
        return prioridad;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = colorFor(prioridad);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.flag_rounded, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          labelFor(prioridad),
          style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
