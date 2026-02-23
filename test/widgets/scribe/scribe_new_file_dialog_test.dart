// Tests for ScribeNewFileDialog.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/theme/app_theme.dart';
import 'package:codeops/widgets/scribe/scribe_new_file_dialog.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(body: child),
    );
  }

  group('ScribeNewFileDialog', () {
    testWidgets('shows title and input fields', (tester) async {
      await tester.pumpWidget(wrap(
        Builder(builder: (context) {
          return ElevatedButton(
            onPressed: () => ScribeNewFileDialog.show(context),
            child: const Text('open dialog'),
          );
        }),
      ));

      await tester.tap(find.text('open dialog'));
      await tester.pumpAndSettle();

      expect(find.text('New File'), findsOneWidget);
      expect(find.text('File Name'), findsOneWidget);
      expect(find.text('Language'), findsOneWidget);
      expect(find.text('Create'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('cancel returns null', (tester) async {
      ScribeNewFileResult? result;

      await tester.pumpWidget(wrap(
        Builder(builder: (context) {
          return ElevatedButton(
            onPressed: () async {
              result = await ScribeNewFileDialog.show(context);
            },
            child: const Text('open dialog'),
          );
        }),
      ));

      await tester.tap(find.text('open dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(result, isNull);
    });

    testWidgets('create returns file name and language', (tester) async {
      late ScribeNewFileResult result;

      await tester.pumpWidget(wrap(
        Builder(builder: (context) {
          return ElevatedButton(
            onPressed: () async {
              final r = await ScribeNewFileDialog.show(context);
              if (r != null) result = r;
            },
            child: const Text('open dialog'),
          );
        }),
      ));

      await tester.tap(find.text('open dialog'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextField),
        'main.dart',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      expect(result.fileName, 'main.dart');
      expect(result.language, 'dart');
    });

    testWidgets('auto-detects language from file extension', (tester) async {
      late ScribeNewFileResult result;

      await tester.pumpWidget(wrap(
        Builder(builder: (context) {
          return ElevatedButton(
            onPressed: () async {
              final r = await ScribeNewFileDialog.show(context);
              if (r != null) result = r;
            },
            child: const Text('open dialog'),
          );
        }),
      ));

      await tester.tap(find.text('open dialog'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'query.sql');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      expect(result.language, 'sql');
    });

    testWidgets('empty name does not create', (tester) async {
      await tester.pumpWidget(wrap(
        Builder(builder: (context) {
          return ElevatedButton(
            onPressed: () async {
              await ScribeNewFileDialog.show(context);
            },
            child: const Text('open dialog'),
          );
        }),
      ));

      await tester.tap(find.text('open dialog'));
      await tester.pumpAndSettle();

      // Leave text field empty, tap Create.
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      // Dialog should still be open.
      expect(find.text('New File'), findsOneWidget);
    });

    testWidgets('defaults to plaintext when no extension', (tester) async {
      late ScribeNewFileResult result;

      await tester.pumpWidget(wrap(
        Builder(builder: (context) {
          return ElevatedButton(
            onPressed: () async {
              final r = await ScribeNewFileDialog.show(context);
              if (r != null) result = r;
            },
            child: const Text('open dialog'),
          );
        }),
      ));

      await tester.tap(find.text('open dialog'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'README');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      expect(result.fileName, 'README');
      expect(result.language, 'plaintext');
    });
  });
}
