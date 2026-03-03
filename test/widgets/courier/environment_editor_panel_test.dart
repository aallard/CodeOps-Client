// Widget tests for EnvironmentEditorPanel.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/courier_models.dart';
import 'package:codeops/providers/courier_providers.dart';
import 'package:codeops/widgets/courier/environment_editor_panel.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

const _env = EnvironmentResponse(
  id: 'env-1',
  name: 'Development',
  description: 'Dev environment',
  isActive: true,
  variableCount: 2,
);

const _inactiveEnv = EnvironmentResponse(
  id: 'env-2',
  name: 'Staging',
  description: 'Staging environment',
  isActive: false,
  variableCount: 1,
);

final _vars = [
  const EnvironmentVariableResponse(
    id: 'v1',
    variableKey: 'BASE_URL',
    variableValue: 'http://localhost:8090',
    isSecret: false,
    isEnabled: true,
  ),
  const EnvironmentVariableResponse(
    id: 'v2',
    variableKey: 'API_KEY',
    variableValue: 'secret123',
    isSecret: true,
    isEnabled: true,
  ),
];

Widget buildEditor({
  EnvironmentResponse env = _env,
  List<EnvironmentVariableResponse> vars = const [],
}) {
  return ProviderScope(
    overrides: [
      courierEnvironmentDetailProvider(env.id!)
          .overrideWith((ref) => env),
      courierEnvironmentVariablesProvider(env.id!)
          .overrideWith((ref) => vars),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 800,
          height: 600,
          child: EnvironmentEditorPanel(environmentId: env.id!),
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
  group('EnvironmentEditorPanel', () {
    testWidgets('renders editor panel', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildEditor(vars: _vars));
      await tester.pumpAndSettle();

      expect(
          find.byKey(const Key('environment_editor_panel')), findsOneWidget);
    });

    testWidgets('shows editor header with name', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildEditor(vars: _vars));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('editor_header')), findsOneWidget);
      expect(find.text('Development'), findsAtLeast(1));
    });

    testWidgets('shows active badge for active environment', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildEditor(vars: _vars));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('active_badge')), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);
    });

    testWidgets('shows activate button for inactive environment',
        (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildEditor(env: _inactiveEnv));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('activate_button')), findsOneWidget);
      expect(find.text('Activate'), findsOneWidget);
    });

    testWidgets('shows save button', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildEditor(vars: _vars));
      await tester.pumpAndSettle();

      expect(
          find.byKey(const Key('save_environment_button')), findsOneWidget);
    });

    testWidgets('shows name and description inputs', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildEditor(vars: _vars));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('env_name_input')), findsOneWidget);
      expect(find.byKey(const Key('env_description_input')), findsOneWidget);
    });

    testWidgets('shows variable table', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildEditor(vars: _vars));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('variable_table')), findsOneWidget);
      expect(find.byKey(const Key('variable_toolbar')), findsOneWidget);
    });

    testWidgets('shows bulk edit toggle', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildEditor(vars: _vars));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bulk_edit_toggle')), findsOneWidget);
      expect(find.text('Bulk Edit'), findsOneWidget);
    });

    testWidgets('toggles to bulk editor', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildEditor(vars: _vars));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('bulk_edit_toggle')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bulk_editor')), findsOneWidget);
      expect(find.text('Table View'), findsOneWidget);
    });
  });
}
