import 'package:intl/intl.dart';

String formatFecha(String? iso) {
  if (iso == null || iso.isEmpty) return '—';
  final date = DateTime.tryParse(iso)?.toLocal();
  if (date == null) return '—';
  return DateFormat('dd/MM/yyyy HH:mm').format(date);
}

String formatFechaCorta(String? iso) {
  if (iso == null || iso.isEmpty) return '—';
  final date = DateTime.tryParse(iso)?.toLocal();
  if (date == null) return '—';
  return DateFormat('dd/MM/yyyy').format(date);
}

String formatHora(String? iso) {
  if (iso == null || iso.isEmpty) return '—';
  final date = DateTime.tryParse(iso)?.toLocal();
  if (date == null) return '—';
  return DateFormat('HH:mm').format(date);
}

String formatDuracion(num? minutos) {
  if (minutos == null) return 'Sin datos';
  final total = minutos.round();
  if (total < 60) return '$total min';
  final horas = total ~/ 60;
  final resto = total % 60;
  if (horas < 24) return '${horas}h ${resto}m';
  final dias = horas ~/ 24;
  return '${dias}d ${horas % 24}h';
}

String formatBytes(int? bytes) {
  if (bytes == null) return '—';
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}

String iniciales(String nombre) {
  final partes = nombre.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (partes.isEmpty) return '?';
  if (partes.length == 1) return partes.first.substring(0, 1).toUpperCase();
  return '${partes.first.substring(0, 1)}${partes.last.substring(0, 1)}'.toUpperCase();
}
