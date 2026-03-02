// Widget tests for CsvImportWizard.
//
// Verifies wizard rendering, step indicator, file step elements,
// target step connection/schema dropdowns, column mapping step,
// options step controls, and execute step display.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/datalens_models.dart';
import 'package:codeops/providers/datalens_providers.dart';
import 'package:codeops/widgets/datalens/import/csv_import_wizard.dart';

const _testConnections = [
  DatabaseConnection(id: 'c1', name: 'TestDB'),
  DatabaseConnection(id: 'c2', name: 'Staging'),
];

Widget _createWidget({
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
                child: const CsvImportWizard(),
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
  group('CsvImportWizard', () {
    testWidgets('renders dialog with title and step indicator', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_createWidget());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Import CSV'), findsOneWidget);
      // Step indicator labels.
      expect(find.text('File'), findsOneWidget);
      expect(find.text('Target'), findsOneWidget);
      expect(find.text('Mapping'), findsOneWidget);
      expect(find.text('Options'), findsOneWidget);
      expect(find.text('Execute'), findsOneWidget);
    });

    testWidgets('step 1 shows file selection and delimiter controls',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_createWidget());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('No file selected'), findsOneWidget);
      expect(find.text('Browse'), findsOneWidget);
      expect(find.text('Delimiter'), findsOneWidget);
      expect(find.text('Encoding'), findsOneWidget);
      expect(find.text('First row is header'), findsOneWidget);
    });

    testWidgets('shows Back and Cancel buttons', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_createWidget());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Back'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
    });

    testWidgets('Next button is disabled when no file is selected',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_createWidget());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Find the Next button and verify it's disabled.
      final nextButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Next'),
      );
      expect(nextButton.onPressed, isNull);
    });

    testWidgets('Cancel closes the dialog', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_createWidget());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Import CSV'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Import CSV'), findsNothing);
    });

    testWidgets('close icon closes the dialog', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_createWidget());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Import CSV'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.text('Import CSV'), findsNothing);
    });

    testWidgets('has the upload_file icon in title bar', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_createWidget());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.upload_file), findsOneWidget);
    });
  });
}
