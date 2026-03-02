// Widget tests for SqlScriptImportDialog.
//
// Verifies dialog rendering, connection dropdown, script options (stop on
// error, wrap in transaction), action buttons, and close behavior.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/datalens_models.dart';
import 'package:codeops/providers/datalens_providers.dart';
import 'package:codeops/widgets/datalens/import/sql_script_import_dialog.dart';

const _testConnections = [
  DatabaseConnection(id: 'c1', name: 'TestDB'),
  DatabaseConnection(id: 'c2', name: 'Staging'),
];

Widget _createWidget({
  String? connectionId,
  List<DatabaseConnection> connections = _testConnections,
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: [
      datalensConnectionsProvider.overrideWith(
        (ref) => Future.value(connections),
      ),
      ...overrides,
    ],
    child: MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showDialog(
              context: context,
              builder: (_) => ProviderScope(
                parent: ProviderScope.containerOf(context),
                child: SqlScriptImportDialog(connectionId: connectionId),
              ),
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('SqlScriptImportDialog', () {
    testWidgets('renders dialog with title and controls', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_createWidget());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Import SQL Script'), findsOneWidget);
      expect(find.text('No file selected'), findsOneWidget);
      expect(find.text('Browse'), findsOneWidget);
      expect(find.text('Connection'), findsOneWidget);
      expect(find.text('Stop on error'), findsOneWidget);
      expect(find.text('Wrap in transaction'), findsOneWidget);
    });

    testWidgets('shows action buttons (Close and Execute)', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_createWidget());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Close'), findsOneWidget);
      expect(find.text('Execute'), findsOneWidget);
    });

    testWidgets('Execute button is disabled when no file/connection selected',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_createWidget());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Find the Execute button — it should be disabled.
      final executeButtons = find.widgetWithText(ElevatedButton, 'Execute');
      final button = tester.widget<ElevatedButton>(executeButtons);
      expect(button.onPressed, isNull);
    });

    testWidgets('Close button closes the dialog', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_createWidget());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Import SQL Script'), findsOneWidget);

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      expect(find.text('Import SQL Script'), findsNothing);
    });

    testWidgets('close icon closes the dialog', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_createWidget());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.text('Import SQL Script'), findsNothing);
    });

    testWidgets('has the description icon in title bar', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_createWidget());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.description), findsOneWidget);
    });
  });
}
