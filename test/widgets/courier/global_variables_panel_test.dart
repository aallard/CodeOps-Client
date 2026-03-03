// Widget tests for GlobalVariablesPanel.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/courier_models.dart';
import 'package:codeops/providers/courier_providers.dart';
import 'package:codeops/widgets/courier/global_variables_panel.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

final _globals = [
  const GlobalVariableResponse(
    id: 'g1',
    variableKey: 'BASE_URL',
    variableValue: 'https://api.example.com',
    isSecret: false,
    isEnabled: true,
  ),
  const GlobalVariableResponse(
    id: 'g2',
    variableKey: 'MASTER_KEY',
    variableValue: 'supersecret',
    isSecret: true,
    isEnabled: true,
  ),
];

Widget buildGlobals({List<GlobalVariableResponse> vars = const []}) {
  return ProviderScope(
    overrides: [
      courierGlobalVariablesProvider.overrideWith((ref) => vars),
    ],
    child: const MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 800,
          height: 600,
          child: GlobalVariablesPanel(),
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
  group('GlobalVariablesPanel', () {
    testWidgets('renders panel', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildGlobals(vars: _globals));
      await tester.pumpAndSettle();

      expect(
          find.byKey(const Key('global_variables_panel')), findsOneWidget);
    });

    testWidgets('shows header with title', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildGlobals(vars: _globals));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('globals_header')), findsOneWidget);
      expect(find.text('Global Variables'), findsOneWidget);
    });

    testWidgets('shows save button', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildGlobals(vars: _globals));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('save_globals_button')), findsOneWidget);
    });

    testWidgets('shows variable count', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildGlobals(vars: _globals));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('global_var_count')), findsOneWidget);
      expect(find.text('2 variables'), findsOneWidget);
    });

    testWidgets('shows variable table', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildGlobals(vars: _globals));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('global_variable_table')), findsOneWidget);
    });

    testWidgets('shows info text about global scope', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildGlobals(vars: _globals));
      await tester.pumpAndSettle();

      expect(
        find.text('Global variables are available in all environments'),
        findsOneWidget,
      );
    });

    testWidgets('shows zero count when empty', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildGlobals());
      await tester.pumpAndSettle();

      expect(find.text('0 variables'), findsOneWidget);
    });
  });
}
