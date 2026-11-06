import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../tickets/presentation/providers/tickets_provider.dart';
import '../providers/survey_provider.dart';

class SurveyPage extends ConsumerStatefulWidget {
  const SurveyPage({super.key, required this.idTicket, this.folio});

  final int idTicket;
  final String? folio;

  @override
  ConsumerState<SurveyPage> createState() => _SurveyPageState();
}

class _SurveyPageState extends ConsumerState<SurveyPage> {
  final _comentariosController = TextEditingController();
  bool _solucionoProblema = true;
  int _nivelSatisfaccion = 5;
  bool _enviando = false;

  @override
  void dispose() {
    _comentariosController.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    setState(() => _enviando = true);
    try {
      await ref.read(surveyActionsProvider).submit(
            idTicket: widget.idTicket,
            solucionoProblema: _solucionoProblema,
            nivelSatisfaccion: _nivelSatisfaccion,
            comentarios: _comentariosController.text,
          );
      if (!mounted) return;
      showAppSnackBar(context, 'Encuesta registrada. El ticket fue cerrado.');
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      showAppSnackBar(context, error.toString(), error: true);
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(ticketDetailProvider(widget.idTicket));
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Encuesta de satisfaccion')),
      body: detail.when(
        loading: () => const AppLoadingView(message: 'Cargando ticket...'),
        error: (error, _) => AppErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(ticketDetailProvider(widget.idTicket)),
        ),
        data: (data) {
          final ticket = data.ticket;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: AppTheme.seed.withValues(alpha: 0.12),
                                  child: const Icon(Icons.support_agent_rounded, color: AppTheme.seed),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Ticket ${ticket.folio}',
                                        style: textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      Text(
                                        ticket.asunto,
                                        style: textTheme.bodySmall?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Tu opinion nos ayuda a mejorar el soporte de IT. '
                              'Al enviar la encuesta el ticket se marcara como CERRADO.',
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SectionCard(
                      title: '¿El problema fue solucionado?',
                      icon: Icons.task_alt_rounded,
                      child: Row(
                        children: [
                          Expanded(
                            child: _OptionTile(
                              label: 'Si, quedo resuelto',
                              icon: Icons.check_circle_outline_rounded,
                              selected: _solucionoProblema,
                              color: const Color(0xFF2E7D32),
                              onTap: () => setState(() => _solucionoProblema = true),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _OptionTile(
                              label: 'No, sigue el problema',
                              icon: Icons.cancel_outlined,
                              selected: !_solucionoProblema,
                              color: const Color(0xFFC62828),
                              onTap: () => setState(() => _solucionoProblema = false),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SectionCard(
                      title: 'Nivel de satisfaccion',
                      icon: Icons.star_outline_rounded,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(5, (index) {
                              final value = index + 1;
                              final selected = value <= _nivelSatisfaccion;
                              return IconButton(
                                onPressed: () => setState(() => _nivelSatisfaccion = value),
                                iconSize: 40,
                                tooltip: '$value de 5',
                                icon: Icon(
                                  selected ? Icons.star_rounded : Icons.star_border_rounded,
                                  color: selected
                                      ? const Color(0xFFF9A825)
                                      : colorScheme.outlineVariant,
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _satisfaccionLabel(_nivelSatisfaccion),
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SectionCard(
                      title: 'Comentarios',
                      icon: Icons.chat_bubble_outline_rounded,
                      child: TextField(
                        controller: _comentariosController,
                        minLines: 3,
                        maxLines: 6,
                        maxLength: 2000,
                        decoration: const InputDecoration(
                          hintText: 'Cuentanos como fue la atencion (opcional)',
                          alignLabelWithHint: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: _enviando ? null : _enviar,
                      icon: _enviando
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send_rounded),
                      label: Text(_enviando ? 'Enviando...' : 'Enviar encuesta y cerrar ticket'),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _enviando ? null : () => Navigator.of(context).pop(false),
                      child: const Text('Responder mas tarde'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _satisfaccionLabel(int value) {
    switch (value) {
      case 1:
        return 'Muy insatisfecho';
      case 2:
        return 'Insatisfecho';
      case 3:
        return 'Neutral';
      case 4:
        return 'Satisfecho';
      case 5:
        return 'Muy satisfecho';
      default:
        return '$value/5';
    }
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: selected ? color.withValues(alpha: 0.10) : null,
          border: Border.all(
            color: selected ? color : Theme.of(context).colorScheme.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? color : Theme.of(context).colorScheme.outline, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? color : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
