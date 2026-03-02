// Widget tests for CourierStatusBar.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:codeops/providers/courier_ui_providers.dart';
import 'package:codeops/widgets/courier/courier_status_bar.dart';

/// Wraps [child] in a [ProviderScope] + [MaterialApp] with a stub router.
Widget wrapWithRouter(Widget child, {List<Override> overrides = const []}) {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => Scaffold(body: child),
      ),
      GoRoute(
        path: '/courier/history',
        builder: (_, __) => const Scaffold(body: Text('History')),
      ),
    ],
  );

  return ProviderScope(
    overrides: overrides,
    child: MaterialApp.router(routerConfig: router),
  );
}

void setWideScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(1400, 200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  group('CourierStatusBar', () {
    testWidgets('renders without error', (tester) async {
      setWideScreen(tester);
      await tester.pumpWidget(wrapWithRouter(const CourierStatusBar()));
      await tester.pumpAndSettle();

      expect(find.byType(CourierStatusBar), findsOneWidget);
    });

    testWidgets('shows Online indicator', (tester) async {
      setWideScreen(tester);
      await tester.pumpWidget(wrapWithRouter(const CourierStatusBar()));
      await tester.pumpAndSettle();

      expect(find.text('Online'), findsOneWidget);
    });

    testWidgets('shows Console button', (tester) async {
      setWideScreen(tester);
      await tester.pumpWidget(wrapWithRouter(const CourierStatusBar()));
      await tester.pumpAndSettle();

      expect(find.text('Console'), findsOneWidget);
    });

    testWidgets('console toggle updates provider state', (tester) async {
      setWideScreen(tester);
      await tester.pumpWidget(wrapWithRouter(const CourierStatusBar()));
      await tester.pumpAndSettle();

      // Initially not visible
      final container = ProviderScope.containerOf(
        tester.element(find.byType(CourierStatusBar)),
      );
      expect(container.read(consoleVisibleProvider), isFalse);

      // Tap Console button
      await tester.tap(find.text('Console'));
      await tester.pump();

      expect(container.read(consoleVisibleProvider), isTrue);
    });

    testWidgets('shows History button', (tester) async {
      setWideScreen(tester);
      await tester.pumpWidget(wrapWithRouter(const CourierStatusBar()));
      await tester.pumpAndSettle();

      expect(find.text('History'), findsOneWidget);
    });

    testWidgets('shows Cookies button', (tester) async {
      setWideScreen(tester);
      await tester.pumpWidget(wrapWithRouter(const CourierStatusBar()));
      await tester.pumpAndSettle();

      expect(find.text('Cookies'), findsOneWidget);
    });

    testWidgets('shows keyboard shortcut hint', (tester) async {
      setWideScreen(tester);
      await tester.pumpWidget(wrapWithRouter(const CourierStatusBar()));
      await tester.pumpAndSettle();

      expect(find.text('⌘+Enter to send'), findsOneWidget);
    });
  });
}
