import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_widgets.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/equipo.dart';
import '../providers/assets_provider.dart';

class AssetsPage extends ConsumerStatefulWidget {
  const AssetsPage({super.key});

  @override
  ConsumerState<AssetsPage> createState() => _AssetsPageState();
}

class _AssetsPageState extends ConsumerState<AssetsPage> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(assetsProvider.notifier).search(value);
    });
  }

  IconData _iconFor(String categoria) {
    switch (categoria.toLowerCase()) {
      case 'pc':
        return Icons.computer_rounded;
      case 'impresora':
        return Icons.print_rounded;
      case 'switch':
        return Icons.router_rounded;
      case 'servidor':
        return Icons.dns_rounded;
      case 'bascula':
        return Icons.scale_rounded;
      default:
        return Icons.devices_other_rounded;
    }
  }

  Color _statusColor(String estado) {
    switch (estado) {
      case 'OPERATIVO':
        return const Color(0xFF2E7D32);
      case 'EN_MANTENIMIENTO':
        return const Color(0xFFEF6C00);
      case 'DE_BAJA':
      case 'FUERA_DE_SERVICIO':
        return const Color(0xFFC62828);
      default:
        return const Color(0xFF546E7A);
    }
  }

  String _statusLabel(String estado) {
    switch (estado) {
      case 'OPERATIVO':
        return 'Operativo';
      case 'EN_MANTENIMIENTO':
        return 'En mantenimiento';
      case 'DE_BAJA':
        return 'De baja';
      case 'FUERA_DE_SERVICIO':
        return 'Fuera de servicio';
      default:
        return estado;
    }
  }

  @override
  Widget build(BuildContext context) {
    final assets = ref.watch(assetsProvider);
    final departamentos = ref.watch(departamentosProvider);
    final user = ref.watch(authProvider).user;
    final isAdmin = user?.isAdmin ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Equipos'),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: () => ref.read(assetsProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => _showCreateDialog(context, departamentos.value ?? const []),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Equipo'),
            )
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearch,
                    decoration: const InputDecoration(
                      hintText: 'Buscar por codigo, nombre, serie o marca',
                      prefixIcon: Icon(Icons.search_rounded),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                departamentos.when(
                  data: (items) => DropdownButton<int?>(
                    value: null,
                    hint: const Text('Departamento'),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('Todos'),
                      ),
                      ...items.map(
                        (d) => DropdownMenuItem<int?>(
                          value: d.idDepartamento,
                          child: Text(d.nombreDepartamento),
                        ),
                      ),
                    ],
                    onChanged: (value) =>
                        ref.read(assetsProvider.notifier).filterByDepartment(value),
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          Expanded(
            child: assets.when(
              loading: () => const AppLoadingView(message: 'Cargando equipos...'),
              error: (error, _) => AppErrorView(
                message: error.toString(),
                onRetry: () => ref.read(assetsProvider.notifier).refresh(),
              ),
              data: (items) {
                if (items.isEmpty) {
                  return const EmptyState(
                    title: 'Sin equipos registrados',
                    message: 'No se encontraron equipos con los filtros actuales.',
                    icon: Icons.devices_other_rounded,
                  );
                }
                return RefreshIndicator(
                  onRefresh: () => ref.read(assetsProvider.notifier).refresh(),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final equipo = items[index];
                      return Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor:
                                Theme.of(context).colorScheme.primaryContainer,
                            child: Icon(
                              _iconFor(equipo.categoria),
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                          ),
                          title: Text(
                            equipo.nombreEquipo,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                '${equipo.codigoActivo} · ${equipo.descripcionTecnica}',
                              ),
                              const SizedBox(height: 2),
                              Text('Departamento: ${equipo.departamento}'),
                            ],
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _statusColor(equipo.estadoOperativo).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              _statusLabel(equipo.estadoOperativo),
                              style: TextStyle(
                                color: _statusColor(equipo.estadoOperativo),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showCreateDialog(
    BuildContext context,
    List<Departamento> departamentos,
  ) async {
    final formKey = GlobalKey<FormState>();
    final codigo = TextEditingController();
    final nombre = TextEditingController();
    final categoria = TextEditingController(text: 'PC');
    final marca = TextEditingController();
    final modelo = TextEditingController();
    final serie = TextEditingController();
    int? idDepartamento = departamentos.isNotEmpty ? departamentos.first.idDepartamento : null;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Nuevo equipo'),
              content: SizedBox(
                width: 520,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: codigo,
                          decoration: const InputDecoration(labelText: 'Codigo de activo *'),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: nombre,
                          decoration: const InputDecoration(labelText: 'Nombre del equipo *'),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: categoria,
                          decoration: const InputDecoration(
                            labelText: 'Categoria *',
                            helperText: 'PC, Impresora, Switch, Servidor, Bascula...',
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: marca,
                                decoration: const InputDecoration(labelText: 'Marca'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: modelo,
                                decoration: const InputDecoration(labelText: 'Modelo'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: serie,
                          decoration: const InputDecoration(labelText: 'Serie'),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<int>(
                          initialValue: idDepartamento,
                          decoration: const InputDecoration(labelText: 'Departamento *'),
                          items: departamentos
                              .map(
                                (d) => DropdownMenuItem(
                                  value: d.idDepartamento,
                                  child: Text(d.nombreDepartamento),
                                ),
                              )
                              .toList(),
                          onChanged: (value) => setState(() => idDepartamento = value),
                          validator: (value) => value == null ? 'Requerido' : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    try {
                      await ref.read(assetsProvider.notifier).create({
                        'codigo_activo': codigo.text.trim(),
                        'nombre_equipo': nombre.text.trim(),
                        'categoria': categoria.text.trim(),
                        'marca': marca.text.trim(),
                        'modelo': modelo.text.trim(),
                        'serie': serie.text.trim(),
                        'id_departamento': idDepartamento,
                      });
                      if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                      if (context.mounted) {
                        showAppSnackBar(context, 'Equipo registrado correctamente');
                      }
                    } catch (error) {
                      if (context.mounted) {
                        showAppSnackBar(context, error.toString(), error: true);
                      }
                    }
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );

    codigo.dispose();
    nombre.dispose();
    categoria.dispose();
    marca.dispose();
    modelo.dispose();
    serie.dispose();
  }
}
