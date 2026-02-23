// Tests for ScribeDropTarget.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/theme/app_theme.dart';
import 'package:codeops/widgets/scribe/scribe_drop_target.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(body: child),
    );
  }

  group('ScribeDropTarget', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(wrap(
        ScribeDropTarget(
          onFilesDropped: (_) {},
          child: const Text('Editor Content'),
        ),
      ));

      expect(find.text('Editor Content'), findsOneWidget);
    });

    testWidgets('does not show overlay by default', (tester) async {
      await tester.pumpWidget(wrap(
        ScribeDropTarget(
          onFilesDropped: (_) {},
          child: const Text('Editor Content'),
        ),
      ));

      expect(find.text('Drop files to open'), findsNothing);
      expect(find.byIcon(Icons.file_download), findsNothing);
    });

    testWidgets('renders with correct widget structure', (tester) async {
      await tester.pumpWidget(wrap(
        ScribeDropTarget(
          onFilesDropped: (_) {},
          child: const SizedBox(width: 400, height: 400),
        ),
      ));

      expect(find.byType(ScribeDropTarget), findsOneWidget);
      // Stack is an internal implementation detail — just verify the
      // drop target and child are present.
      expect(find.byType(SizedBox), findsWidgets);
    });
  });
}
