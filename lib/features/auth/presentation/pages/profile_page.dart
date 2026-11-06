import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../providers/auth_provider.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  bool _saving = false;

  Future<void> _changePassword() async {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cambiar contrasena'),
        content: SizedBox(
          width: 420,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: currentController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Contrasena actual'),
                  validator: (value) =>
                      (value == null || value.isEmpty) ? 'Requerido' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: newController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Nueva contrasena',
                    helperText: 'Minimo 8 caracteres',
                  ),
                  validator: (value) => (value == null || value.length < 8)
                      ? 'Minimo 8 caracteres'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: confirmController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Confirmar contrasena'),
                  validator: (value) =>
                      value != newController.text ? 'No coincide' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(dialogContext).pop(true);
              }
            },
            child: const Text('Actualizar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _saving = true);
      try {
        await ref.read(authRepositoryProvider).changePassword(
              currentPassword: currentController.text,
              newPassword: newController.text,
            );
        if (mounted) showAppSnackBar(context, 'Contrasena actualizada correctamente');
      } catch (error) {
        if (mounted) showAppSnackBar(context, error.toString(), error: true);
      } finally {
        if (mounted) setState(() => _saving = false);
      }
    }

    currentController.dispose();
    newController.dispose();
    confirmController.dispose();
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cerrar sesion'),
        content: const Text('¿Deseas salir de la aplicacion?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Salir'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(authProvider.notifier).logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Mi perfil')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppTheme.seed.withValues(alpha: 0.12),
                    child: Text(
                      iniciales(user.nombreCompleto),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.seed,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    user.nombreCompleto,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '@${user.usuario}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.seed.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      user.rolLabel,
                      style: const TextStyle(
                        color: AppTheme.seed,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Datos de la cuenta',
            icon: Icons.badge_outlined,
            child: Column(
              children: [
                InfoRow(
                  label: 'Departamento',
                  value: user.departamento,
                  icon: Icons.apartment_rounded,
                ),
                InfoRow(
                  label: 'Correo',
                  value: user.correo ?? 'No registrado',
                  icon: Icons.mail_outline_rounded,
                ),
                InfoRow(
                  label: 'Telefono',
                  value: user.telefono ?? 'No registrado',
                  icon: Icons.phone_outlined,
                ),
                InfoRow(
                  label: 'Estado',
                  value: user.activo ? 'Activo' : 'Inactivo',
                  icon: Icons.verified_user_outlined,
                ),
                InfoRow(
                  label: 'Ultimo acceso',
                  value: formatFecha(user.ultimoAcceso),
                  icon: Icons.login_rounded,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Seguridad',
            icon: Icons.lock_outline_rounded,
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.password_rounded),
                  title: const Text('Cambiar contrasena'),
                  subtitle: const Text('Actualiza tu clave de acceso'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: _saving ? null : _changePassword,
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.logout_rounded, color: colorScheme.error),
                  title: Text(
                    'Cerrar sesion',
                    style: TextStyle(color: colorScheme.error),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: _logout,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'Macsa Tickets · v1.0.0',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
