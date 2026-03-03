// Widget tests for EnvironmentListPanel.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/courier_models.dart';
import 'package:codeops/providers/courier_providers.dart';
import 'package:codeops/widgets/courier/environment_list_panel.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

final _envs = [
  const EnvironmentResponse(
    id: 'env-1',
    name: 'Development',
    isActive: true,
    variableCount: 3,
  ),
  const EnvironmentResponse(
    id: 'env-2',
    name: 'Staging',
    isActive: false,
    variableCount: 5,
  ),
  const EnvironmentResponse(
    id: 'env-3',
    name: 'Production',
    isActive: false,
    variableCount: 8,
  ),
];

Widget buildListPanel({
  List<EnvironmentResponse> envs = const [],
  String? selectedId,
  bool globalsSelected = false,
}) {
  String? lastSelected;
  bool globalsClicked = false;
  return ProviderScope(
    overrides: [
      courierEnvironmentsProvider.overrideWith((ref) => envs),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 280,
          height: 600,
          child: EnvironmentListPanel(
            selectedEnvironmentId: selectedId,
            globalsSelected: globalsSelected,
            onSelectEnvironment: (id) => lastSelected = id,
            onSelectGlobals: () => globalsClicked = true,
          ),
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
  group('EnvironmentListPanel', () {
    testWidgets('renders panel with header', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildListPanel(envs: _envs));
      await tester.pumpAndSettle();

      expect(
          find.byKey(const Key('environment_list_panel')), findsOneWidget);
      expect(find.byKey(const Key('env_list_header')), findsOneWidget);
      expect(find.text('Environments'), findsOneWidget);
    });

    testWidgets('shows new environment button', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildListPanel(envs: _envs));
      await tester.pumpAndSettle();

      expect(
          find.byKey(const Key('new_environment_button')), findsOneWidget);
    });

    testWidgets('shows search field', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildListPanel(envs: _envs));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('env_search_field')), findsOneWidget);
    });

    testWidgets('shows globals row', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildListPanel(envs: _envs));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('globals_row')), findsOneWidget);
      expect(find.text('Globals'), findsOneWidget);
    });

    testWidgets('displays environment names', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildListPanel(envs: _envs));
      await tester.pumpAndSettle();

      expect(find.text('Development'), findsOneWidget);
      expect(find.text('Staging'), findsOneWidget);
      expect(find.text('Production'), findsOneWidget);
    });

    testWidgets('shows variable count', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildListPanel(envs: _envs));
      await tester.pumpAndSettle();

      expect(find.text('3 variables'), findsOneWidget);
      expect(find.text('5 variables'), findsOneWidget);
      expect(find.text('8 variables'), findsOneWidget);
    });

    testWidgets('shows empty state when no environments', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildListPanel());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('env_list_empty')), findsOneWidget);
      expect(find.text('No environments yet'), findsOneWidget);
    });

    testWidgets('filters environments by search query', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildListPanel(envs: _envs));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byKey(const Key('env_search_field')), 'Stag');
      await tester.pumpAndSettle();

      expect(find.text('Staging'), findsOneWidget);
      expect(find.text('Development'), findsNothing);
      expect(find.text('Production'), findsNothing);
    });

    testWidgets('shows context menu button on each row', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildListPanel(envs: _envs));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('env_menu_env-1')), findsOneWidget);
      expect(find.byKey(const Key('env_menu_env-2')), findsOneWidget);
    });
  });
}
