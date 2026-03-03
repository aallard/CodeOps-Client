// Widget tests for ForkDialog.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/courier_models.dart';
import 'package:codeops/providers/courier_providers.dart';
import 'package:codeops/widgets/courier/fork_dialog.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

final _forks = [
  ForkResponse(
    id: 'f1',
    sourceCollectionId: 'col-1',
    sourceCollectionName: 'User API',
    forkedCollectionId: 'col-fork-1',
    forkedByUserId: 'user-bob',
    label: 'My fork',
    forkedAt: DateTime(2026, 1, 15),
  ),
];

Widget buildForkDialog({
  List<ForkResponse> forks = const [],
}) {
  return ProviderScope(
    overrides: [
      courierCollectionForksProvider('col-1').overrideWith((ref) => forks),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              showDialog<void>(
                context: context,
                builder: (_) => const ForkDialog(
                  collectionId: 'col-1',
                  collectionName: 'User API',
                ),
              );
            },
            child: const Text('Open'),
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
  group('ForkDialog', () {
    testWidgets('renders dialog with header', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildForkDialog());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('fork_dialog')), findsOneWidget);
      expect(find.textContaining('Fork'), findsWidgets);
    });

    testWidgets('shows fork label field', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildForkDialog());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('fork_label_field')), findsOneWidget);
    });

    testWidgets('shows fork button', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildForkDialog());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('fork_button')), findsOneWidget);
      expect(find.text('Fork Collection'), findsOneWidget);
    });

    testWidgets('shows existing forks list', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildForkDialog(forks: _forks));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('forks_list')), findsOneWidget);
      expect(find.text('My fork'), findsOneWidget);
      expect(find.text('by user-bob'), findsOneWidget);
    });
  });
}
