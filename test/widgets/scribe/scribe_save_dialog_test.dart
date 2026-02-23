// Tests for ScribeSaveDialog.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/scribe_models.dart';
import 'package:codeops/theme/app_theme.dart';
import 'package:codeops/widgets/scribe/scribe_save_dialog.dart';

void main() {
  final now = DateTime(2026, 2, 23);

  ScribeTab makeTab(int n, {bool isDirty = true}) {
    return ScribeTab(
      id: 'tab-$n',
      title: 'File-$n.dart',
      isDirty: isDirty,
      createdAt: now,
      lastModifiedAt: now,
    );
  }

  Widget wrap(Widget child) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(body: child),
    );
  }

  group('ScribeSaveDialog.show (single)', () {
    testWidgets('shows tab title in dialog', (tester) async {
      final tab = makeTab(1);
      late ScribeSaveAction result;

      await tester.pumpWidget(wrap(
        Builder(builder: (context) {
          return ElevatedButton(
            onPressed: () async {
              result = await ScribeSaveDialog.show(context, tab: tab);
            },
            child: const Text('show dialog'),
          );
        }),
      ));

      await tester.tap(find.text('show dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Unsaved Changes'), findsOneWidget);
      expect(find.text("'File-1.dart' has unsaved changes."), findsOneWidget);
    });

    testWidgets('Save button returns save action', (tester) async {
      final tab = makeTab(1);
      late ScribeSaveAction result;

      await tester.pumpWidget(wrap(
        Builder(builder: (context) {
          return ElevatedButton(
            onPressed: () async {
              result = await ScribeSaveDialog.show(context, tab: tab);
            },
            child: const Text('show dialog'),
          );
        }),
      ));

      await tester.tap(find.text('show dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(result, ScribeSaveAction.save);
    });

    testWidgets('Don\'t Save button returns dontSave action', (tester) async {
      final tab = makeTab(1);
      late ScribeSaveAction result;

      await tester.pumpWidget(wrap(
        Builder(builder: (context) {
          return ElevatedButton(
            onPressed: () async {
              result = await ScribeSaveDialog.show(context, tab: tab);
            },
            child: const Text('show dialog'),
          );
        }),
      ));

      await tester.tap(find.text('show dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text("Don't Save"));
      await tester.pumpAndSettle();

      expect(result, ScribeSaveAction.dontSave);
    });

    testWidgets('Cancel button returns cancel action', (tester) async {
      final tab = makeTab(1);
      late ScribeSaveAction result;

      await tester.pumpWidget(wrap(
        Builder(builder: (context) {
          return ElevatedButton(
            onPressed: () async {
              result = await ScribeSaveDialog.show(context, tab: tab);
            },
            child: const Text('show dialog'),
          );
        }),
      ));

      await tester.tap(find.text('show dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(result, ScribeSaveAction.cancel);
    });
  });

  group('ScribeSaveDialog.showBatch', () {
    testWidgets('lists all dirty tab titles', (tester) async {
      final tabs = [makeTab(1), makeTab(2), makeTab(3)];

      await tester.pumpWidget(wrap(
        Builder(builder: (context) {
          return ElevatedButton(
            onPressed: () async {
              await ScribeSaveDialog.showBatch(context, dirtyTabs: tabs);
            },
            child: const Text('show batch'),
          );
        }),
      ));

      await tester.tap(find.text('show batch'));
      await tester.pumpAndSettle();

      expect(find.text('Unsaved Changes'), findsOneWidget);
      expect(find.text('File-1.dart'), findsOneWidget);
      expect(find.text('File-2.dart'), findsOneWidget);
      expect(find.text('File-3.dart'), findsOneWidget);
    });

    testWidgets('Save Selected returns checked tab ids', (tester) async {
      final tabs = [makeTab(1), makeTab(2)];
      late ScribeBatchSaveResult result;

      await tester.pumpWidget(wrap(
        Builder(builder: (context) {
          return ElevatedButton(
            onPressed: () async {
              result = await ScribeSaveDialog.showBatch(
                context,
                dirtyTabs: tabs,
              );
            },
            child: const Text('show batch'),
          );
        }),
      ));

      await tester.tap(find.text('show batch'));
      await tester.pumpAndSettle();

      // Both checkboxes start checked by default.
      // Uncheck tab-2 by tapping its checkbox.
      final checkboxes = find.byType(CheckboxListTile);
      expect(checkboxes, findsNWidgets(2));

      await tester.tap(checkboxes.last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save Selected'));
      await tester.pumpAndSettle();

      expect(result.action, ScribeSaveAction.save);
      expect(result.selectedTabIds, ['tab-1']);
    });

    testWidgets('Don\'t Save returns dontSave action', (tester) async {
      final tabs = [makeTab(1)];
      late ScribeBatchSaveResult result;

      await tester.pumpWidget(wrap(
        Builder(builder: (context) {
          return ElevatedButton(
            onPressed: () async {
              result = await ScribeSaveDialog.showBatch(
                context,
                dirtyTabs: tabs,
              );
            },
            child: const Text('show batch'),
          );
        }),
      ));

      await tester.tap(find.text('show batch'));
      await tester.pumpAndSettle();

      await tester.tap(find.text("Don't Save"));
      await tester.pumpAndSettle();

      expect(result.action, ScribeSaveAction.dontSave);
    });

    testWidgets('Cancel returns cancel action', (tester) async {
      final tabs = [makeTab(1)];
      late ScribeBatchSaveResult result;

      await tester.pumpWidget(wrap(
        Builder(builder: (context) {
          return ElevatedButton(
            onPressed: () async {
              result = await ScribeSaveDialog.showBatch(
                context,
                dirtyTabs: tabs,
              );
            },
            child: const Text('show batch'),
          );
        }),
      ));

      await tester.tap(find.text('show batch'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(result.action, ScribeSaveAction.cancel);
    });
  });
}
