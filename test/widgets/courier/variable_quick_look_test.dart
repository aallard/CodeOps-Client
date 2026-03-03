// Widget tests for VariableQuickLook.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/widgets/courier/variable_quick_look.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

Widget buildQuickLook(ResolvedVariable variable) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: VariableQuickLook(variable: variable),
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
  group('VariableQuickLook', () {
    testWidgets('renders quick look widget', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildQuickLook(
        const ResolvedVariable(
          name: 'BASE_URL',
          value: 'http://localhost:8090',
          source: 'environment',
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('variable_quick_look')), findsOneWidget);
    });

    testWidgets('shows variable name', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildQuickLook(
        const ResolvedVariable(
          name: 'API_KEY',
          value: 'abc123',
          source: 'global',
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('ql_variable_name')), findsOneWidget);
      expect(find.text('{{API_KEY}}'), findsOneWidget);
    });

    testWidgets('shows source badge', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildQuickLook(
        const ResolvedVariable(
          name: 'HOST',
          value: 'example.com',
          source: 'environment',
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('ql_source_badge')), findsOneWidget);
      expect(find.text('environment'), findsOneWidget);
    });

    testWidgets('shows resolved value', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildQuickLook(
        const ResolvedVariable(
          name: 'PORT',
          value: '8090',
          source: 'environment',
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('ql_value')), findsOneWidget);
      expect(find.text('8090'), findsOneWidget);
    });

    testWidgets('masks secret values', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildQuickLook(
        const ResolvedVariable(
          name: 'SECRET',
          value: 'supersecret',
          source: 'global',
          isSecret: true,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('••••••••'), findsOneWidget);
      expect(find.text('supersecret'), findsNothing);
    });

    testWidgets('shows "Not found" for unresolved variables',
        (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildQuickLook(
        const ResolvedVariable(
          name: 'MISSING',
          source: 'unresolved',
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Not found'), findsOneWidget);
      expect(find.text('unresolved'), findsOneWidget);
    });

    testWidgets('shows lock icon for secret', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildQuickLook(
        const ResolvedVariable(
          name: 'TOKEN',
          value: 'xyz',
          source: 'environment',
          isSecret: true,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.lock), findsOneWidget);
    });
  });
}
