// Widget tests for RotationPolicyDialog.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/widgets/vault/rotation_policy_dialog.dart';

void main() {
  Widget createWidget() {
    return ProviderScope(
      overrides: [],
      child: MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => ProviderScope(
                  overrides: [],
                  child: const RotationPolicyDialog(secretId: 's1'),
                ),
              ),
              child: const Text('Open Dialog'),
            ),
          ),
        ),
      ),
    );
  }

  group('RotationPolicyDialog', () {
    testWidgets('shows dialog title for create', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Set Up Rotation'), findsOneWidget);
    });

    testWidgets('shows strategy selector', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Strategy'), findsOneWidget);
      expect(find.text('Random Generate'), findsOneWidget);
      expect(find.text('External API'), findsOneWidget);
      expect(find.text('Custom Script'), findsOneWidget);
    });

    testWidgets('shows interval field', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(
        find.text('Rotation Interval (hours)'),
        findsOneWidget,
      );
    });

    testWidgets('shows max failures field', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Max Failures Before Pause'), findsOneWidget);
    });

    testWidgets('shows Random Generate fields by default', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(
        find.text('Random Length (8\u20131024)'),
        findsOneWidget,
      );
      expect(find.text('Character Set'), findsOneWidget);
    });

    testWidgets('shows External API fields when selected', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Tap External API segment
      await tester.tap(find.text('External API'));
      await tester.pumpAndSettle();

      expect(find.text('API URL'), findsOneWidget);
      expect(find.text('API Headers (JSON)'), findsOneWidget);
    });

    testWidgets('shows Custom Script fields when selected', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Tap Custom Script segment
      await tester.tap(find.text('Custom Script'));
      await tester.pumpAndSettle();

      expect(find.text('Script Command'), findsOneWidget);
    });

    testWidgets('shows Create and Cancel buttons', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Create'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });
  });
}
