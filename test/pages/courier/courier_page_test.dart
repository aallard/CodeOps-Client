// Widget tests for CourierPage (three-pane layout shell).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:codeops/models/courier_models.dart';
import 'package:codeops/pages/courier/courier_page.dart';
import 'package:codeops/providers/courier_providers.dart';
import 'package:codeops/providers/courier_ui_providers.dart';
import 'package:codeops/widgets/courier/collection_sidebar.dart';
import 'package:codeops/widgets/courier/courier_status_bar.dart';
import 'package:codeops/widgets/courier/courier_toolbar.dart';
import 'package:codeops/widgets/courier/request_builder.dart';
import 'package:codeops/widgets/courier/response_viewer.dart';

/// Creates a fully-wrapped [CourierPage] with stub providers and router.
Widget createCourierPage({
  String? requestId,
  String? collectionId,
  List<Override> overrides = const [],
}) {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => Scaffold(
          body: CourierPage(
            requestId: requestId,
            collectionId: collectionId,
          ),
        ),
      ),
      GoRoute(
        path: '/courier/history',
        builder: (_, __) => const Scaffold(body: Text('History')),
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

/// Sets a 1400x900 logical viewport for tests that need a wide layout.
void setWideScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(1400, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  group('CourierPage', () {
    testWidgets('renders without error', (tester) async {
      setWideScreen(tester);
      await tester.pumpWidget(createCourierPage());
      await tester.pumpAndSettle();

      expect(find.byType(CourierPage), findsOneWidget);
    });

    testWidgets('renders three-pane layout — toolbar, sidebar, builder, viewer',
        (tester) async {
      setWideScreen(tester);
      await tester.pumpWidget(createCourierPage());
      await tester.pumpAndSettle();

      expect(find.byType(CourierToolbar), findsOneWidget);
      expect(find.byType(CollectionSidebar), findsOneWidget);
      expect(find.byType(RequestBuilder), findsOneWidget);
      expect(find.byType(ResponseViewer), findsOneWidget);
    });

    testWidgets('renders status bar', (tester) async {
      setWideScreen(tester);
      await tester.pumpWidget(createCourierPage());
      await tester.pumpAndSettle();

      expect(find.byType(CourierStatusBar), findsOneWidget);
    });

    testWidgets('renders request tab bar with new-tab button', (tester) async {
      setWideScreen(tester);
      await tester.pumpWidget(createCourierPage());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('new_tab_button')), findsOneWidget);
    });

    testWidgets('sidebar width changes when sidebarWidthProvider updates',
        (tester) async {
      setWideScreen(tester);
      await tester.pumpWidget(createCourierPage());
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(CourierPage)),
      );

      // Confirm initial width is 280
      expect(container.read(sidebarWidthProvider), 280.0);

      // Update to 350 and verify
      container.read(sidebarWidthProvider.notifier).state = 350.0;
      await tester.pump();

      expect(container.read(sidebarWidthProvider), 350.0);
    });

    testWidgets('response pane hides when responsePaneCollapsedProvider is true',
        (tester) async {
      setWideScreen(tester);
      await tester.pumpWidget(
        createCourierPage(
          overrides: [
            responsePaneCollapsedProvider.overrideWith((ref) => true),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // ResponseViewer should not be rendered when collapsed
      expect(find.byType(ResponseViewer), findsNothing);
    });

    testWidgets('response pane visible when not collapsed', (tester) async {
      setWideScreen(tester);
      await tester.pumpWidget(
        createCourierPage(
          overrides: [
            responsePaneCollapsedProvider.overrideWith((ref) => false),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ResponseViewer), findsOneWidget);
    });
  });
}
