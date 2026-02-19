// Widget tests for CreateLeaseDialog.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/widgets/vault/create_lease_dialog.dart';

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
                  child: const CreateLeaseDialog(
                    secretId: 's1',
                    secretName: 'my-app-db',
                  ),
                ),
              ),
              child: const Text('Open Dialog'),
            ),
          ),
        ),
      ),
    );
  }

  group('CreateLeaseDialog', () {
    testWidgets('shows dialog title', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Title + button both show "Create Lease"
      expect(find.text('Create Lease'), findsWidgets);
    });

    testWidgets('shows secret name', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Secret: my-app-db'), findsOneWidget);
    });

    testWidgets('shows TTL label', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('TTL'), findsOneWidget);
    });

    testWidgets('shows preset buttons', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // 1h appears as TTL display + preset chip
      expect(find.text('1h'), findsWidgets);
      expect(find.text('4h'), findsOneWidget);
      expect(find.text('8h'), findsOneWidget);
      expect(find.text('24h'), findsOneWidget);
    });

    testWidgets('shows slider', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.byType(Slider), findsOneWidget);
    });

    testWidgets('shows min and max labels', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('1 min'), findsOneWidget);
      expect(find.text('24 hours'), findsOneWidget);
    });

    testWidgets('shows Create Lease button', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Create Lease'), findsWidgets);
    });

    testWidgets('shows Cancel button', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('default TTL is 1h', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Default TTL display (1h) + preset chip (1h)
      expect(find.text('1h'), findsWidgets);
    });
  });
}
