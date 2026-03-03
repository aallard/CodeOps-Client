// Widget tests for EnvironmentManagerPage.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/courier_models.dart';
import 'package:codeops/providers/courier_providers.dart';
import 'package:codeops/pages/courier/environment_manager_page.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

final _sampleEnvs = [
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
];

Widget buildPage({List<EnvironmentResponse> envs = const []}) {
  return ProviderScope(
    overrides: [
      courierEnvironmentsProvider.overrideWith((ref) => envs),
    ],
    child: const MaterialApp(
      home: EnvironmentManagerPage(),
    ),
  );
}

void setSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(1400, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

// ─────────────────────────────────────────────────────────────────────────────
// Tests
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  group('EnvironmentManagerPage', () {
    testWidgets('renders page header with back button', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('env_page_header')), findsOneWidget);
      expect(find.byKey(const Key('env_back_button')), findsOneWidget);
      expect(find.text('Environment Manager'), findsOneWidget);
    });

    testWidgets('shows list panel and placeholder', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildPage(envs: _sampleEnvs));
      await tester.pumpAndSettle();

      expect(
          find.byKey(const Key('environment_list_panel')), findsOneWidget);
      expect(find.byKey(const Key('env_placeholder')), findsOneWidget);
      expect(find.text('Select an environment to edit'), findsOneWidget);
    });

    testWidgets('selects globals panel', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildPage(envs: _sampleEnvs));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('globals_row')));
      await tester.pumpAndSettle();

      expect(
          find.byKey(const Key('global_variables_panel')), findsOneWidget);
    });

    testWidgets('displays environment list with names', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildPage(envs: _sampleEnvs));
      await tester.pumpAndSettle();

      expect(find.text('Development'), findsOneWidget);
      expect(find.text('Staging'), findsOneWidget);
    });

    testWidgets('shows new environment button', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildPage(envs: _sampleEnvs));
      await tester.pumpAndSettle();

      expect(
          find.byKey(const Key('new_environment_button')), findsOneWidget);
    });

    testWidgets('shows search field', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildPage(envs: _sampleEnvs));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('env_search_field')), findsOneWidget);
    });
  });
}
