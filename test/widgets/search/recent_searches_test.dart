// Tests for recent searches functionality.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/services/search/global_search_service.dart';
import 'package:codeops/widgets/search/global_search_dialog.dart';

void main() {
  Widget createApp({List<Override> overrides = const []}) {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showGlobalSearchDialog(context),
              child: const Text('Open Search'),
            ),
          ),
        ),
      ),
    );
  }

  group('Recent Searches', () {
    testWidgets('shows recent searches with history icon', (tester) async {
      await tester.pumpWidget(createApp(
        overrides: [
          recentSearchesProvider.overrideWith((ref) {
            final notifier = RecentSearchesNotifier();
            notifier.add('my query');
            return notifier;
          }),
        ],
      ));
      await tester.tap(find.text('Open Search'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.history), findsOneWidget);
      expect(find.text('my query'), findsOneWidget);
    });

    testWidgets('clear button removes all recent searches', (tester) async {
      await tester.pumpWidget(createApp(
        overrides: [
          recentSearchesProvider.overrideWith((ref) {
            final notifier = RecentSearchesNotifier();
            notifier.add('query 1');
            notifier.add('query 2');
            return notifier;
          }),
        ],
      ));
      await tester.tap(find.text('Open Search'));
      await tester.pumpAndSettle();

      expect(find.text('Recent Searches'), findsOneWidget);

      // Tap Clear.
      await tester.tap(find.text('Clear'));
      await tester.pumpAndSettle();

      expect(find.text('Recent Searches'), findsNothing);
      expect(find.text('Type to search across all modules'),
          findsOneWidget);
    });

    testWidgets('tapping recent search fills input', (tester) async {
      await tester.pumpWidget(createApp(
        overrides: [
          recentSearchesProvider.overrideWith((ref) {
            final notifier = RecentSearchesNotifier();
            notifier.add('previous search');
            return notifier;
          }),
        ],
      ));
      await tester.tap(find.text('Open Search'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('previous search'));
      await tester.pump();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, 'previous search');
    });

    testWidgets('shows no recent when list is empty', (tester) async {
      await tester.pumpWidget(createApp());
      await tester.tap(find.text('Open Search'));
      await tester.pumpAndSettle();

      expect(find.text('Recent Searches'), findsNothing);
      expect(find.text('Type to search across all modules'),
          findsOneWidget);
    });

    testWidgets('remove button removes individual search', (tester) async {
      await tester.pumpWidget(createApp(
        overrides: [
          recentSearchesProvider.overrideWith((ref) {
            final notifier = RecentSearchesNotifier();
            notifier.add('keep this');
            notifier.add('remove me');
            return notifier;
          }),
        ],
      ));
      await tester.tap(find.text('Open Search'));
      await tester.pumpAndSettle();

      // Each recent item has a close button — find the one next to 'remove me'.
      final closeFinders = find.byIcon(Icons.close);
      // First close icon should be for 'remove me' (listed first since it was added last).
      await tester.tap(closeFinders.first);
      await tester.pumpAndSettle();

      expect(find.text('remove me'), findsNothing);
      expect(find.text('keep this'), findsOneWidget);
    });
  });
}
