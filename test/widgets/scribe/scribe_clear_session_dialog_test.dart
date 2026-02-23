// Tests for ScribeClearSessionDialog.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/theme/app_theme.dart';
import 'package:codeops/widgets/scribe/scribe_clear_session_dialog.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(body: child),
    );
  }

  group('ScribeClearSessionDialog', () {
    testWidgets('displays title and description', (tester) async {
      await tester.pumpWidget(wrap(
        Builder(builder: (context) {
          return ElevatedButton(
            onPressed: () => ScribeClearSessionDialog.show(context),
            child: const Text('open'),
          );
        }),
      ));

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('Clear Session'), findsNWidgets(2));
      expect(
        find.textContaining('close all open tabs'),
        findsOneWidget,
      );
    });

    testWidgets('Cancel returns cancel action', (tester) async {
      ScribeClearSessionAction? result;
      await tester.pumpWidget(wrap(
        Builder(builder: (context) {
          return ElevatedButton(
            onPressed: () async {
              result = await ScribeClearSessionDialog.show(context);
            },
            child: const Text('open'),
          );
        }),
      ));

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(result, ScribeClearSessionAction.cancel);
    });

    testWidgets('Clear Session returns clear action', (tester) async {
      ScribeClearSessionAction? result;
      await tester.pumpWidget(wrap(
        Builder(builder: (context) {
          return ElevatedButton(
            onPressed: () async {
              result = await ScribeClearSessionDialog.show(context);
            },
            child: const Text('open'),
          );
        }),
      ));

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      // The FilledButton with "Clear Session" text.
      await tester.tap(find.widgetWithText(FilledButton, 'Clear Session'));
      await tester.pumpAndSettle();

      expect(result, ScribeClearSessionAction.clear);
    });

    testWidgets('shows warning about unsaved changes', (tester) async {
      await tester.pumpWidget(wrap(
        Builder(builder: (context) {
          return ElevatedButton(
            onPressed: () => ScribeClearSessionDialog.show(context),
            child: const Text('open'),
          );
        }),
      ));

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Unsaved changes will be lost'), findsOneWidget);
    });
  });
}
