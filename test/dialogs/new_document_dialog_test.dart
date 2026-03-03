// Widget tests for NewDocumentDialog.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/pages/mcp/document_management_page.dart';

void main() {
  Widget createDialog() {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              showDialog<Map<String, dynamic>>(
                context: context,
                builder: (_) =>
                    const NewDocumentDialog(projectId: 'proj-1'),
              );
            },
            child: const Text('Open'),
          ),
        ),
      ),
    );
  }

  group('NewDocumentDialog', () {
    testWidgets('renders dialog with type selector', (tester) async {
      await tester.pumpWidget(createDialog());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('New Document'), findsOneWidget);
      expect(find.text('Type'), findsOneWidget);
      expect(find.text('Create'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('renders initial content field', (tester) async {
      await tester.pumpWidget(createDialog());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Initial Content'), findsOneWidget);
    });

    testWidgets('shows name field for custom type', (tester) async {
      await tester.pumpWidget(createDialog());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Default type is Custom, so Name field should be visible
      expect(find.text('Name'), findsOneWidget);
    });

    testWidgets('cancel closes dialog', (tester) async {
      await tester.pumpWidget(createDialog());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('New Document'), findsNothing);
    });
  });
}
