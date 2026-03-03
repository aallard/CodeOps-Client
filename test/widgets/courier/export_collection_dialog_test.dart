// Widget tests for ExportCollectionDialog.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/widgets/courier/export_dialog.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

Widget buildExportDialog() {
  return ProviderScope(
    child: MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              showDialog<void>(
                context: context,
                builder: (_) => const ExportCollectionDialog(
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
  group('ExportCollectionDialog', () {
    testWidgets('renders dialog with header', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildExportDialog());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('export_collection_dialog')), findsOneWidget);
      expect(find.text('Export Collection'), findsOneWidget);
    });

    testWidgets('shows format selector tiles', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildExportDialog());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('format_postman')), findsOneWidget);
      expect(find.byKey(const Key('format_openapi')), findsOneWidget);
      expect(find.byKey(const Key('format_native_')), findsOneWidget);
    });

    testWidgets('shows include environment toggle', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildExportDialog());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('include_environment_toggle')),
          findsOneWidget);
    });

    testWidgets('shows export button', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildExportDialog());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('export_button')), findsOneWidget);
    });
  });
}
