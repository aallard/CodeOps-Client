// Widget tests for HeadersTab.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/providers/courier_ui_providers.dart';
import 'package:codeops/widgets/courier/headers_tab.dart';
import 'package:codeops/widgets/courier/key_value_editor.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

Widget buildHeadersTab({
  List<Override> overrides = const [],
  List<KeyValuePair> initialHeaders = const [],
}) {
  return ProviderScope(
    overrides: [
      requestHeadersProvider.overrideWith((ref) => initialHeaders),
      ...overrides,
    ],
    child: const MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 800,
          height: 600,
          child: HeadersTab(),
        ),
      ),
    ),
  );
}

void setSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(1200, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

// ─────────────────────────────────────────────────────────────────────────────
// Tests
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  group('HeadersTab', () {
    testWidgets('renders with KeyValueEditor', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildHeadersTab());
      await tester.pumpAndSettle();

      expect(find.byType(HeadersTab), findsOneWidget);
      expect(find.byKey(const Key('headers_editor')), findsOneWidget);
    });

    testWidgets('shows auto-generated headers section', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildHeadersTab());
      await tester.pumpAndSettle();

      expect(find.text('Auto-generated Headers'), findsOneWidget);
      // Default auto-headers shown.
      expect(find.text('User-Agent'), findsOneWidget);
      expect(find.text('Accept'), findsOneWidget);
      expect(find.text('Accept-Encoding'), findsOneWidget);
      expect(find.text('Connection'), findsOneWidget);
    });

    testWidgets('collapse/expand auto-generated headers', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildHeadersTab());
      await tester.pumpAndSettle();

      // Initially expanded — auto-header values visible.
      expect(find.text('CodeOps-Courier/1.0'), findsOneWidget);

      // Collapse.
      await tester.tap(find.byKey(const Key('auto_headers_toggle')));
      await tester.pumpAndSettle();

      // Values should be hidden.
      expect(find.text('CodeOps-Courier/1.0'), findsNothing);
    });

    testWidgets('header presets are shown', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildHeadersTab());
      await tester.pumpAndSettle();

      expect(find.text('Presets:'), findsOneWidget);
      expect(find.byKey(const Key('preset_JSON')), findsOneWidget);
      expect(find.byKey(const Key('preset_Form')), findsOneWidget);
      expect(find.byKey(const Key('preset_XML')), findsOneWidget);
    });

    testWidgets('displays existing headers', (tester) async {
      setSize(tester);
      final headers = [
        const KeyValuePair(
            id: '1', key: 'Authorization', value: 'Bearer token123'),
        const KeyValuePair(
            id: '2', key: 'Content-Type', value: 'application/json'),
      ];
      await tester.pumpWidget(buildHeadersTab(initialHeaders: headers));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(TextField, 'Authorization'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Bearer token123'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Content-Type'), findsOneWidget);
    });
  });
}
