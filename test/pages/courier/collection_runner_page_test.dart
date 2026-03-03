// Widget tests for CollectionRunnerPage.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/courier_models.dart';
import 'package:codeops/providers/courier_providers.dart';
import 'package:codeops/pages/courier/collection_runner_page.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

final _collections = [
  const CollectionSummaryResponse(
    id: 'col-1',
    name: 'User API',
  ),
  const CollectionSummaryResponse(
    id: 'col-2',
    name: 'Auth API',
  ),
];

final _envs = [
  const EnvironmentResponse(
    id: 'env-1',
    name: 'Development',
    isActive: true,
  ),
  const EnvironmentResponse(
    id: 'env-2',
    name: 'Staging',
    isActive: false,
  ),
];

Widget buildRunnerPage({
  List<CollectionSummaryResponse> collections = const [],
  List<EnvironmentResponse> envs = const [],
}) {
  return ProviderScope(
    overrides: [
      courierCollectionsProvider.overrideWith((ref) => collections),
      courierEnvironmentsProvider.overrideWith((ref) => envs),
    ],
    child: const MaterialApp(
      home: CollectionRunnerPage(),
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
  group('CollectionRunnerPage', () {
    testWidgets('renders page header', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildRunnerPage(
        collections: _collections,
        envs: _envs,
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('runner_page_header')), findsOneWidget);
      expect(find.text('Collection Runner'), findsOneWidget);
    });

    testWidgets('shows back button', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildRunnerPage(
        collections: _collections,
        envs: _envs,
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('runner_back_button')), findsOneWidget);
    });

    testWidgets('shows config panel with collection selector', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildRunnerPage(
        collections: _collections,
        envs: _envs,
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('runner_config_panel')), findsOneWidget);
      expect(find.byKey(const Key('collection_selector')), findsOneWidget);
    });

    testWidgets('shows environment selector', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildRunnerPage(
        collections: _collections,
        envs: _envs,
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('environment_selector')), findsOneWidget);
    });

    testWidgets('shows iterations and delay fields', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildRunnerPage(
        collections: _collections,
        envs: _envs,
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('iterations_field')), findsOneWidget);
      expect(find.byKey(const Key('delay_field')), findsOneWidget);
    });

    testWidgets('shows data file picker', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildRunnerPage(
        collections: _collections,
        envs: _envs,
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('data_file_picker')), findsOneWidget);
    });

    testWidgets('shows toggle switches', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildRunnerPage(
        collections: _collections,
        envs: _envs,
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('keep_variables_toggle')), findsOneWidget);
      expect(find.byKey(const Key('save_responses_toggle')), findsOneWidget);
    });

    testWidgets('shows run button disabled when no collection selected',
        (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildRunnerPage(
        collections: _collections,
        envs: _envs,
      ));
      await tester.pumpAndSettle();

      final button = tester.widget<ElevatedButton>(
          find.byKey(const Key('run_collection_button')));
      expect(button.onPressed, isNull);
    });
  });
}
