// Tests for ScribePreviewControls widget.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/widgets/scribe/scribe_preview_controls.dart';
import 'package:codeops/theme/app_theme.dart';

void main() {
  Widget createWidget({
    required ScribePreviewMode mode,
    required ValueChanged<ScribePreviewMode> onModeChanged,
  }) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(
        body: Center(
          child: ScribePreviewControls(
            mode: mode,
            onModeChanged: onModeChanged,
          ),
        ),
      ),
    );
  }

  group('ScribePreviewControls', () {
    testWidgets('renders three segment buttons', (tester) async {
      await tester.pumpWidget(createWidget(
        mode: ScribePreviewMode.editor,
        onModeChanged: (_) {},
      ));

      // Three icons: edit, vertical_split, visibility.
      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.byIcon(Icons.vertical_split), findsOneWidget);
      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('fires onModeChanged with split when split tapped',
        (tester) async {
      ScribePreviewMode? selected;
      await tester.pumpWidget(createWidget(
        mode: ScribePreviewMode.editor,
        onModeChanged: (m) => selected = m,
      ));

      await tester.tap(find.byIcon(Icons.vertical_split));
      expect(selected, ScribePreviewMode.split);
    });

    testWidgets('fires onModeChanged with preview when preview tapped',
        (tester) async {
      ScribePreviewMode? selected;
      await tester.pumpWidget(createWidget(
        mode: ScribePreviewMode.editor,
        onModeChanged: (m) => selected = m,
      ));

      await tester.tap(find.byIcon(Icons.visibility));
      expect(selected, ScribePreviewMode.preview);
    });

    testWidgets('fires onModeChanged with editor when editor tapped',
        (tester) async {
      ScribePreviewMode? selected;
      await tester.pumpWidget(createWidget(
        mode: ScribePreviewMode.split,
        onModeChanged: (m) => selected = m,
      ));

      await tester.tap(find.byIcon(Icons.edit));
      expect(selected, ScribePreviewMode.editor);
    });
  });
}
