// Tests for keyboard shortcut integration in NavigationShell.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:codeops/providers/auth_providers.dart';
import 'package:codeops/providers/settings_providers.dart';
import 'package:codeops/providers/team_providers.dart';
import 'package:codeops/models/user.dart';
import 'package:codeops/widgets/shell/navigation_shell.dart';
import 'package:codeops/widgets/search/global_search_dialog.dart';

void main() {
  Widget createShell({List<Override> overrides = const []}) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        ShellRoute(
          builder: (context, state, child) => NavigationShell(child: child),
          routes: [
            GoRoute(
              path: '/',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: Center(child: Text('Home')),
              ),
            ),
          ],
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        currentUserProvider.overrideWith(
          (ref) => const User(
            id: 'u1',
            email: 'test@test.com',
            displayName: 'Tester',
          ),
        ),
        selectedTeamIdProvider.overrideWith((ref) => 'team-1'),
        sidebarCollapsedProvider.overrideWith((ref) => false),
        ...overrides,
      ],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  group('Keyboard shortcuts', () {
    testWidgets('search button has correct tooltip', (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createShell());
      await tester.pumpAndSettle();

      expect(find.byTooltip('Search (Ctrl+K)'), findsOneWidget);
    });

    testWidgets('search button opens dialog', (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createShell());
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Search (Ctrl+K)'));
      await tester.pumpAndSettle();

      expect(find.byType(GlobalSearchDialog), findsOneWidget);
    });

    testWidgets('Ctrl+K opens search dialog', (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createShell());
      await tester.pumpAndSettle();

      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();

      expect(find.byType(GlobalSearchDialog), findsOneWidget);
    });
  });
}
