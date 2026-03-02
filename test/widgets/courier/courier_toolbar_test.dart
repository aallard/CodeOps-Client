// Widget tests for CourierToolbar.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:codeops/models/courier_models.dart';
import 'package:codeops/providers/courier_providers.dart';
import 'package:codeops/providers/courier_ui_providers.dart';
import 'package:codeops/widgets/courier/courier_toolbar.dart';

Widget wrapWithRouter(Widget child, {List<Override> overrides = const []}) {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => Scaffold(body: child),
      ),
      GoRoute(
        path: '/courier/import',
        builder: (_, __) => const Scaffold(body: Text('Import')),
      ),
      GoRoute(
        path: '/courier/runner',
        builder: (_, __) => const Scaffold(body: Text('Runner')),
      ),
      GoRoute(
        path: '/courier/environments',
        builder: (_, __) => const Scaffold(body: Text('Environments')),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      courierEnvironmentsProvider
          .overrideWith((ref) => Future.value(<EnvironmentResponse>[])),
      ...overrides,
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

/// Sets a 1400x200 logical viewport for toolbar-level tests.
void setWideScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(1400, 200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  group('CourierToolbar', () {
    testWidgets('renders without error', (tester) async {
      setWideScreen(tester);
      await tester.pumpWidget(wrapWithRouter(const CourierToolbar()));
      await tester.pumpAndSettle();

      expect(find.byType(CourierToolbar), findsOneWidget);
    });

    testWidgets('shows New button', (tester) async {
      setWideScreen(tester);
      await tester.pumpWidget(wrapWithRouter(const CourierToolbar()));
      await tester.pumpAndSettle();

      expect(find.text('New'), findsOneWidget);
    });

    testWidgets('New dropdown opens on tap', (tester) async {
      setWideScreen(tester);
      await tester.pumpWidget(wrapWithRouter(const CourierToolbar()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('new_dropdown')));
      await tester.pumpAndSettle();

      expect(find.text('New Request'), findsOneWidget);
      expect(find.text('New Collection'), findsOneWidget);
      expect(find.text('New Folder'), findsOneWidget);
      expect(find.text('New Environment'), findsOneWidget);
    });

    testWidgets('shows Import button', (tester) async {
      setWideScreen(tester);
      await tester.pumpWidget(wrapWithRouter(const CourierToolbar()));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('import_button')), findsOneWidget);
      expect(find.text('Import'), findsOneWidget);
    });

    testWidgets('shows Runner button', (tester) async {
      setWideScreen(tester);
      await tester.pumpWidget(wrapWithRouter(const CourierToolbar()));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('runner_button')), findsOneWidget);
      expect(find.text('Runner'), findsOneWidget);
    });

    testWidgets('shows search field', (tester) async {
      setWideScreen(tester);
      await tester.pumpWidget(wrapWithRouter(const CourierToolbar()));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('toolbar_search')), findsOneWidget);
    });

    testWidgets('search input updates sidebarSearchQueryProvider', (tester) async {
      setWideScreen(tester);
      await tester.pumpWidget(wrapWithRouter(const CourierToolbar()));
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(CourierToolbar)),
      );
      expect(container.read(sidebarSearchQueryProvider), '');

      await tester.enterText(find.byKey(const Key('toolbar_search')), 'Auth');
      await tester.pump();

      expect(container.read(sidebarSearchQueryProvider), 'Auth');
    });

    testWidgets('shows environment selector', (tester) async {
      setWideScreen(tester);
      await tester.pumpWidget(wrapWithRouter(const CourierToolbar()));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('environment_selector')), findsOneWidget);
    });

    testWidgets('environment selector shows No environment by default',
        (tester) async {
      setWideScreen(tester);
      await tester.pumpWidget(wrapWithRouter(const CourierToolbar()));
      await tester.pumpAndSettle();

      expect(find.text('No environment'), findsOneWidget);
    });
  });
}
