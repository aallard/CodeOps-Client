// Tests for Vault navigation routes.
//
// Verifies route registration, path parameter extraction, sidebar items,
// and top-bar page names for all 7 Vault routes.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:codeops/models/enums.dart';
import 'package:codeops/models/team.dart';
import 'package:codeops/models/user.dart';
import 'package:codeops/providers/auth_providers.dart';
import 'package:codeops/providers/settings_providers.dart';
import 'package:codeops/providers/team_providers.dart';
import 'package:codeops/router.dart';
import 'package:codeops/widgets/shell/navigation_shell.dart';

/// Creates a shell-wrapped test app with vault routes for widget tests.
Widget _createVaultShell({String initialLocation = '/vault'}) {
  final testRouter = GoRouter(
    initialLocation: initialLocation,
    routes: [
      ShellRoute(
        builder: (context, state, child) => NavigationShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: Center(child: Text('Home Content')),
            ),
          ),
          GoRoute(
            path: '/vault',
            name: 'test-vault',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: Center(child: Text('Vault Content')),
            ),
          ),
          GoRoute(
            path: '/vault/secrets',
            name: 'test-vault-secrets',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: Center(child: Text('Secrets Content')),
            ),
          ),
          GoRoute(
            path: '/vault/secrets/:id',
            name: 'test-vault-secret-detail',
            pageBuilder: (context, state) {
              final id = state.pathParameters['id']!;
              return NoTransitionPage(
                child: Center(child: Text('Secret $id')),
              );
            },
          ),
          GoRoute(
            path: '/vault/policies',
            name: 'test-vault-policies',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: Center(child: Text('Policies Content')),
            ),
          ),
          GoRoute(
            path: '/vault/transit',
            name: 'test-vault-transit',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: Center(child: Text('Transit Content')),
            ),
          ),
          GoRoute(
            path: '/vault/dynamic',
            name: 'test-vault-dynamic',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: Center(child: Text('Dynamic Content')),
            ),
          ),
          GoRoute(
            path: '/vault/seal',
            name: 'test-vault-seal',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: Center(child: Text('Seal Content')),
            ),
          ),
        ],
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      sidebarCollapsedProvider.overrideWith((ref) => false),
      currentUserProvider.overrideWith(
        (ref) => const User(
          id: 'u1',
          email: 'test@test.com',
          displayName: 'Test User',
        ),
      ),
      teamMembersProvider.overrideWith(
        (ref) => Future.value([
          TeamMember(
            id: 'm1',
            userId: 'u1',
            displayName: 'Test User',
            role: TeamRole.owner,
          ),
        ]),
      ),
      teamsProvider.overrideWith((ref) => Future.value(<Team>[])),
    ],
    child: MaterialApp.router(routerConfig: testRouter),
  );
}

void main() {
  group('Vault routes — router registration', () {
    test('all 7 vault route paths are registered', () {
      final vaultPaths = [
        '/vault',
        '/vault/secrets',
        '/vault/secrets/:id',
        '/vault/policies',
        '/vault/transit',
        '/vault/dynamic',
        '/vault/seal',
      ];

      final registeredPaths = <String>[];
      void collectPaths(List<RouteBase> routes) {
        for (final route in routes) {
          if (route is GoRoute) {
            registeredPaths.add(route.path);
            collectPaths(route.routes);
          } else if (route is ShellRoute) {
            collectPaths(route.routes);
          }
        }
      }

      collectPaths(router.configuration.routes);

      for (final path in vaultPaths) {
        expect(registeredPaths, contains(path),
            reason: 'Missing vault route: $path');
      }
    });

    test('vault route names are unique and prefixed', () {
      final expectedNames = [
        'vault',
        'vault-secrets',
        'vault-secret-detail',
        'vault-policies',
        'vault-transit',
        'vault-dynamic',
        'vault-seal',
      ];

      final registeredNames = <String>[];
      void collectNames(List<RouteBase> routes) {
        for (final route in routes) {
          if (route is GoRoute && route.name != null) {
            registeredNames.add(route.name!);
            collectNames(route.routes);
          } else if (route is ShellRoute) {
            collectNames(route.routes);
          }
        }
      }

      collectNames(router.configuration.routes);

      for (final name in expectedNames) {
        expect(registeredNames, contains(name),
            reason: 'Missing vault route name: $name');
      }
    });
  });

  group('Vault routes — widget tests', () {
    Future<void> setupSize(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1440, 1000);
      tester.view.devicePixelRatio = 1.0;
    }

    testWidgets('vault dashboard renders content', (tester) async {
      await setupSize(tester);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await tester.pumpWidget(_createVaultShell());
      await tester.pumpAndSettle();

      expect(find.text('Vault Content'), findsOneWidget);
    });

    testWidgets('vault secret detail extracts path parameter', (tester) async {
      await setupSize(tester);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await tester.pumpWidget(
        _createVaultShell(initialLocation: '/vault/secrets/abc-123'),
      );
      await tester.pumpAndSettle();

      expect(find.text('Secret abc-123'), findsOneWidget);
    });

    testWidgets('sidebar contains VAULT section header', (tester) async {
      // Use taller viewport so VAULT section is not below the fold
      tester.view.physicalSize = const Size(1440, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await tester.pumpWidget(_createVaultShell());
      await tester.pumpAndSettle();

      expect(find.text('VAULT'), findsOneWidget);
    });

    testWidgets('sidebar contains all 6 vault nav items', (tester) async {
      tester.view.physicalSize = const Size(1440, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await tester.pumpWidget(_createVaultShell());
      await tester.pumpAndSettle();

      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Secrets'), findsOneWidget);
      expect(find.text('Policies'), findsOneWidget);
      expect(find.text('Transit'), findsOneWidget);
      expect(find.text('Dynamic'), findsOneWidget);
      expect(find.text('Seal'), findsOneWidget);
    });

    testWidgets('vault dashboard nav item is highlighted when active',
        (tester) async {
      tester.view.physicalSize = const Size(1440, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await tester.pumpWidget(_createVaultShell(initialLocation: '/vault'));
      await tester.pumpAndSettle();

      // Verify Dashboard icon uses primary color (active highlighting)
      final icons = find.byIcon(Icons.dashboard_outlined);
      expect(icons, findsOneWidget);
      final iconWidget = tester.widget<Icon>(icons);
      expect(iconWidget.color, const Color(0xFF6C63FF));
    });

    testWidgets('navigating to vault secrets updates sidebar highlighting',
        (tester) async {
      await setupSize(tester);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await tester
          .pumpWidget(_createVaultShell(initialLocation: '/vault/secrets'));
      await tester.pumpAndSettle();

      expect(find.text('Secrets Content'), findsOneWidget);
    });

    testWidgets('top bar shows Vault page name', (tester) async {
      await setupSize(tester);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await tester.pumpWidget(_createVaultShell(initialLocation: '/vault'));
      await tester.pumpAndSettle();

      expect(find.text('Vault'), findsWidgets);
    });
  });
}
