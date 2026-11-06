import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/assets/presentation/pages/assets_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/profile_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/reports/presentation/pages/dashboard_page.dart';
import '../../features/reports/presentation/pages/reports_page.dart';
import '../../features/survey/presentation/pages/survey_page.dart';
import '../../features/tickets/presentation/pages/create_ticket_page.dart';
import '../../features/tickets/presentation/pages/ticket_detail_page.dart';
import '../../features/tickets/presentation/pages/tickets_page.dart';
import 'app_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = ValueNotifier<int>(0);
  ref.listen(authProvider, (_, _) => refreshNotifier.value++);
  ref.onDispose(refreshNotifier.dispose);

  final router = GoRouter(
    initialLocation: '/tickets',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      final location = state.matchedLocation;

      if (auth.status == AuthStatus.initial || auth.status == AuthStatus.checking) {
        return location == '/splash' ? null : '/splash';
      }

      if (!auth.isAuthenticated) {
        return location == '/login' ? null : '/login';
      }

      if (location == '/login' || location == '/splash') {
        return '/tickets';
      }

      final user = auth.user;
      final restricted = location == '/dashboard' || location == '/reportes';
      if (restricted && !(user?.puedeVerReportes ?? false)) {
        return '/tickets';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/tickets/nuevo',
        builder: (context, state) => const CreateTicketPage(),
      ),
      GoRoute(
        path: '/tickets/:id',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return TicketDetailPage(
            idTicket: id,
            folio: state.uri.queryParameters['folio'],
          );
        },
      ),
      GoRoute(
        path: '/encuestas/:id',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return SurveyPage(
            idTicket: id,
            folio: state.uri.queryParameters['folio'],
          );
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/tickets',
                builder: (context, state) => const TicketsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const DashboardPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/reportes',
                builder: (context, state) => const ReportsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/equipos',
                builder: (context, state) => const AssetsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/perfil',
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('No encontrado')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.explore_off_rounded, size: 64),
            const SizedBox(height: 12),
            Text('Ruta no encontrada: ${state.uri}'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.go('/tickets'),
              child: const Text('Volver a tickets'),
            ),
          ],
        ),
      ),
    ),
  );

  ref.onDispose(router.dispose);
  return router;
});
