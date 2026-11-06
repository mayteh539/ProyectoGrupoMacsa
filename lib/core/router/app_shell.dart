import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../config/app_config.dart';
import '../providers/core_providers.dart';
import '../sockets/socket_service.dart';
import '../widgets/app_widgets.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/reports/presentation/providers/reports_provider.dart';
import '../../features/tickets/presentation/providers/tickets_provider.dart';

/// Contenedor principal con navegacion inferior y escucha de eventos Socket.io.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  StreamSubscription<TicketSocketEvent>? _subscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _connectSocket());
  }

  void _connectSocket() {
    final token = ref.read(authProvider).token;
    if (token == null || token.isEmpty) return;

    final socket = ref.read(socketServiceProvider);
    socket.connect(url: AppConfig.socketUrl, token: token);
    _subscription = socket.events.listen(_onSocketEvent);
  }

  void _onSocketEvent(TicketSocketEvent event) {
    ref.invalidate(ticketSummaryProvider);
    ref.invalidate(ticketsProvider);
    ref.invalidate(dashboardProvider);
    ref.invalidate(trendProvider(30));

    final idTicket = event.payload['id_ticket'];
    if (idTicket is num) {
      ref.invalidate(ticketDetailProvider(idTicket.toInt()));
    }

    if (!mounted) return;
    showAppSnackBar(context, event.mensaje);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    ref.read(socketServiceProvider).disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final puedeVerReportes = user?.puedeVerReportes ?? false;

    final destinations = <({int branch, IconData icon, IconData selected, String label})>[
      (
        branch: 0,
        icon: Icons.confirmation_number_outlined,
        selected: Icons.confirmation_number_rounded,
        label: 'Tickets',
      ),
      if (puedeVerReportes)
        (
          branch: 1,
          icon: Icons.dashboard_outlined,
          selected: Icons.dashboard_rounded,
          label: 'Dashboard',
        ),
      if (puedeVerReportes)
        (
          branch: 2,
          icon: Icons.bar_chart_outlined,
          selected: Icons.bar_chart_rounded,
          label: 'Reportes',
        ),
      (
        branch: 3,
        icon: Icons.devices_other_outlined,
        selected: Icons.devices_other_rounded,
        label: 'Equipos',
      ),
      (
        branch: 4,
        icon: Icons.person_outline_rounded,
        selected: Icons.person_rounded,
        label: 'Perfil',
      ),
    ];

    final currentIndex =
        destinations.indexWhere((item) => item.branch == widget.navigationShell.currentIndex);

    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex < 0 ? 0 : currentIndex,
        onDestinationSelected: (index) =>
            widget.navigationShell.goBranch(destinations[index].branch),
        destinations: [
          for (final item in destinations)
            NavigationDestination(
              icon: Icon(item.icon),
              selectedIcon: Icon(item.selected),
              label: item.label,
            ),
        ],
      ),
    );
  }
}
