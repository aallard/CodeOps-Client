// Tests for TechStackSelector widget.
//
// Verifies preset selection, chip display, removal, custom input,
// and comma-separated output via onChanged callback.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/widgets/registry/tech_stack_selector.dart';

Widget _buildWidget({
  String? initialValue,
  ValueChanged<String>? onChanged,
}) {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        child: TechStackSelector(
          initialValue: initialValue,
          onChanged: onChanged ?? (_) {},
        ),
      ),
    ),
  );
}

void main() {
  group('TechStackSelector', () {
    testWidgets('renders preset dropdown and custom input', (tester) async {
      await tester.pumpWidget(_buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('Add from presets'), findsOneWidget);
      expect(find.text('Add custom...'), findsOneWidget);
    });

    testWidgets('renders initial values as chips', (tester) async {
      await tester.pumpWidget(
        _buildWidget(initialValue: 'Java 21, Flutter, PostgreSQL'),
      );
      await tester.pumpAndSettle();

      expect(find.text('Java 21'), findsOneWidget);
      expect(find.text('Flutter'), findsOneWidget);
      expect(find.text('PostgreSQL'), findsOneWidget);
    });

    testWidgets('chip removal triggers onChanged', (tester) async {
      String? lastValue;
      await tester.pumpWidget(
        _buildWidget(
          initialValue: 'Java 21, Flutter',
          onChanged: (v) => lastValue = v,
        ),
      );
      await tester.pumpAndSettle();

      // Each chip has a delete icon (Icons.close)
      final deleteIcons = find.byIcon(Icons.close);
      expect(deleteIcons, findsNWidgets(2));

      // Remove first chip (Java 21)
      await tester.tap(deleteIcons.first);
      await tester.pumpAndSettle();

      expect(find.text('Java 21'), findsNothing);
      expect(lastValue, 'Flutter');
    });

    testWidgets('custom input adds chip on submit', (tester) async {
      String? lastValue;
      await tester.pumpWidget(
        _buildWidget(onChanged: (v) => lastValue = v),
      );
      await tester.pumpAndSettle();

      // Type custom value
      await tester.enterText(find.byType(TextField), 'CustomTech');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(find.text('CustomTech'), findsOneWidget);
      expect(lastValue, 'CustomTech');
    });

    testWidgets('custom input clears after adding', (tester) async {
      await tester.pumpWidget(_buildWidget());
      await tester.pumpAndSettle();

      final textField = find.byType(TextField);
      await tester.enterText(textField, 'MyLib');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Text field should be cleared
      final controller =
          (tester.widget<TextField>(textField)).controller!;
      expect(controller.text, isEmpty);
      // Chip should exist
      expect(find.text('MyLib'), findsOneWidget);
    });

    testWidgets('empty custom input does not add chip', (tester) async {
      String? lastValue;
      await tester.pumpWidget(
        _buildWidget(onChanged: (v) => lastValue = v),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '   ');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // No chip should be added, onChanged not called
      expect(lastValue, isNull);
    });
  });
}
