// Widget tests for TableTransferDialog.
//
// Verifies dialog rendering, source and target selector rows, options
// controls, action buttons, and close behavior.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/datalens_models.dart';
import 'package:codeops/providers/datalens_providers.dart';
import 'package:codeops/widgets/datalens/import/table_transfer_dialog.dart';

const _testConnections = [
  DatabaseConnection(id: 'c1', name: 'TestDB'),
  DatabaseConnection(id: 'c2', name: 'Staging'),
];

Widget _createWidget({
  String? sourceConnectionId,
  String? sourceSchema,
  String? sourceTable,
  List<DatabaseConnection> connections = _testConnections,
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: [
      datalensConnectionsProvider.overrideWith(
        (ref) => Future.value(connections),
      ),
      datalensSchemasProvider.overrideWith((ref) => Future.value([])),
      datalensTablesProvider.overrideWith((ref) => Future.value([])),
      datalensColumnsProvider.overrideWith((ref) => Future.value([])),
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
                child: TableTransferDialog(
                  sourceConnectionId: sourceConnectionId,
                  sourceSchema: sourceSchema,
                  sourceTable: sourceTable,
                ),
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
  group('TableTransferDialog', () {
    testWidgets('renders dialog with title and sections', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_createWidget());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Table Transfer'), findsOneWidget);
      expect(find.text('Source'), findsOneWidget);
      expect(find.text('Target'), findsOneWidget);
      expect(find.text('Options'), findsOneWidget);
    });

    testWidgets('shows source and target selector rows', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_createWidget());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Hint texts for connection/schema/table dropdowns.
      expect(find.text('Connection'), findsWidgets);
      expect(find.text('Schema'), findsWidgets);
    });

    testWidgets('shows WHERE clause input and options', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_createWidget());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('WHERE clause (optional)'), findsOneWidget);
      expect(find.text('Create new table'), findsOneWidget);
      expect(find.text('Truncate target before transfer'), findsOneWidget);
      expect(find.text('Batch Size:'), findsOneWidget);
    });

    testWidgets('shows action buttons (Close and Transfer)', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_createWidget());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Close'), findsOneWidget);
      expect(find.text('Transfer'), findsOneWidget);
    });

    testWidgets('Transfer button is disabled when source/target not set',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_createWidget());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Transfer'),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('Close button closes the dialog', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_createWidget());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Table Transfer'), findsOneWidget);

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      expect(find.text('Table Transfer'), findsNothing);
    });

    testWidgets('close icon closes the dialog', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_createWidget());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.text('Table Transfer'), findsNothing);
    });

    testWidgets('has the swap_horiz icon in title bar', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_createWidget());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.swap_horiz), findsOneWidget);
    });
  });
}
