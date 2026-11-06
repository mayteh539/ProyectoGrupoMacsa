import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/models/upload_file.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../assets/presentation/providers/assets_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/tickets_provider.dart';

class CreateTicketPage extends ConsumerStatefulWidget {
  const CreateTicketPage({super.key});

  @override
  ConsumerState<CreateTicketPage> createState() => _CreateTicketPageState();
}

class _CreateTicketPageState extends ConsumerState<CreateTicketPage> {
  final _formKey = GlobalKey<FormState>();
  final _asuntoController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _comoOcurrioController = TextEditingController();
  final _picker = ImagePicker();

  int? _idEquipo;
  int? _idCategoria;
  String _prioridad = 'MEDIA';
  UploadFile? _imagen;
  String? _imagenNombre;
  bool _enviando = false;

  static const _prioridades = <String, String>{
    'BAJA': 'Baja',
    'MEDIA': 'Media',
    'ALTA': 'Alta',
    'CRITICA': 'Critica',
  };

  @override
  void dispose() {
    _asuntoController.dispose();
    _descripcionController.dispose();
    _comoOcurrioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 72,
        maxWidth: 1600,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      if (!mounted) return;
      setState(() {
        _imagen = UploadFile(name: picked.name, bytes: bytes);
        _imagenNombre = picked.name;
      });
    } catch (error) {
      if (!mounted) return;
      showAppSnackBar(context, 'No se pudo cargar la imagen: $error', error: true);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_idEquipo == null) {
      showAppSnackBar(context, 'Selecciona el equipo afectado', error: true);
      return;
    }
    if (_idCategoria == null) {
      showAppSnackBar(context, 'Selecciona la categoria del problema', error: true);
      return;
    }

    setState(() => _enviando = true);
    try {
      final detail = await ref.read(ticketsRepositoryProvider).create(
            idEquipo: _idEquipo!,
            idCategoria: _idCategoria!,
            asunto: _asuntoController.text.trim(),
            descripcionProblema: _descripcionController.text.trim(),
            prioridad: _prioridad,
            comoOcurrio: _comoOcurrioController.text,
            imagen: _imagen,
          );
      ref.invalidate(ticketsProvider);
      ref.invalidate(ticketSummaryProvider);
      if (!mounted) return;
      showAppSnackBar(context, 'Ticket ${detail.ticket.folio} creado correctamente');
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
    final assets = ref.watch(assetsProvider);
    final categorias = ref.watch(categoriasProvider);
    final user = ref.watch(authProvider).user;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo ticket')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Reportar una falla',
                            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user == null
                                ? 'Describe el problema con el mayor detalle posible.'
                                : '${user.nombreCompleto} · ${user.departamento}',
                            style: textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 20),
                          assets.when(
                            loading: () => const LinearProgressIndicator(),
                            error: (error, _) => Text(
                              'No se pudieron cargar los equipos: $error',
                              style: TextStyle(color: Theme.of(context).colorScheme.error),
                            ),
                            data: (equipos) => DropdownButtonFormField<int>(
                              initialValue: _idEquipo,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                labelText: 'Equipo afectado *',
                                prefixIcon: Icon(Icons.devices_other_rounded),
                              ),
                              items: equipos
                                  .map(
                                    (equipo) => DropdownMenuItem(
                                      value: equipo.idEquipo,
                                      child: Text(
                                        '${equipo.codigoActivo} · ${equipo.nombreEquipo}',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) => setState(() => _idEquipo = value),
                              validator: (value) => value == null ? 'Selecciona un equipo' : null,
                            ),
                          ),
                          const SizedBox(height: 16),
                          categorias.when(
                            loading: () => const LinearProgressIndicator(),
                            error: (error, _) => Text(
                              'No se pudieron cargar las categorias: $error',
                              style: TextStyle(color: Theme.of(context).colorScheme.error),
                            ),
                            data: (items) => DropdownButtonFormField<int>(
                              initialValue: _idCategoria,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                labelText: 'Categoria del problema *',
                                prefixIcon: Icon(Icons.category_outlined),
                              ),
                              items: items
                                  .map(
                                    (categoria) => DropdownMenuItem(
                                      value: categoria.idCategoria,
                                      child: Text(
                                        categoria.nombreCategoria,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) => setState(() => _idCategoria = value),
                              validator: (value) =>
                                  value == null ? 'Selecciona una categoria' : null,
                            ),
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            initialValue: _prioridad,
                            decoration: const InputDecoration(
                              labelText: 'Prioridad *',
                              prefixIcon: Icon(Icons.flag_outlined),
                            ),
                            items: _prioridades.entries
                                .map(
                                  (entry) => DropdownMenuItem(
                                    value: entry.key,
                                    child: Text(entry.value),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) =>
                                setState(() => _prioridad = value ?? 'MEDIA'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _asuntoController,
                            textCapitalization: TextCapitalization.sentences,
                            maxLength: 150,
                            decoration: const InputDecoration(
                              labelText: 'Asunto *',
                              hintText: 'Ej. PC de empaque sin acceso a la red',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().length < 5) {
                                return 'Describe el asunto (minimo 5 caracteres)';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _descripcionController,
                            textCapitalization: TextCapitalization.sentences,
                            minLines: 4,
                            maxLines: 8,
                            maxLength: 2000,
                            decoration: const InputDecoration(
                              labelText: 'Descripcion del problema *',
                              hintText: 'Que ocurre, desde cuando, a quien afecta...',
                              alignLabelWithHint: true,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().length < 10) {
                                return 'Describe el problema (minimo 10 caracteres)';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _comoOcurrioController,
                            textCapitalization: TextCapitalization.sentences,
                            minLines: 2,
                            maxLines: 4,
                            maxLength: 1000,
                            decoration: const InputDecoration(
                              labelText: '¿Como ocurrio? (opcional)',
                              hintText: 'Acciones previas, cambios recientes...',
                              alignLabelWithHint: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Evidencia fotografica',
                            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Adjunta una foto del equipo o del error (JPG, PNG o WEBP, max 5 MB).',
                            style: textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (_imagenNombre != null)
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.image_outlined),
                              title: Text(
                                _imagenNombre!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: IconButton(
                                tooltip: 'Quitar',
                                onPressed: () => setState(() {
                                  _imagen = null;
                                  _imagenNombre = null;
                                }),
                                icon: const Icon(Icons.delete_outline_rounded),
                              ),
                            ),
                          Wrap(
                            spacing: 12,
                            runSpacing: 8,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () => _pickImage(ImageSource.gallery),
                                icon: const Icon(Icons.photo_library_outlined),
                                label: const Text('Galeria'),
                              ),
                              if (!kIsWeb)
                                OutlinedButton.icon(
                                  onPressed: () => _pickImage(ImageSource.camera),
                                  icon: const Icon(Icons.photo_camera_outlined),
                                  label: const Text('Camara'),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _enviando ? null : _submit,
                    icon: _enviando
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send_rounded),
                    label: Text(_enviando ? 'Creando ticket...' : 'Crear ticket'),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
