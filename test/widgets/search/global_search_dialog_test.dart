// Widget tests for GlobalSearchDialog.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  Future<void> openDialog(WidgetTester tester) async {
    await tester.pumpWidget(createApp());
    await tester.tap(find.text('Open Search'));
    await tester.pumpAndSettle();
  }

  group('GlobalSearchDialog', () {
    testWidgets('renders search field with hint text', (tester) async {
      await openDialog(tester);

      expect(find.byType(TextField), findsOneWidget);
      expect(
          find.text('Search across all modules...'), findsOneWidget);
    });

    testWidgets('renders keyboard hints', (tester) async {
      await openDialog(tester);

      expect(find.text('navigate'), findsOneWidget);
      expect(find.text('open'), findsOneWidget);
      expect(find.text('filter'), findsOneWidget);
      expect(find.text('close'), findsOneWidget);
    });

    testWidgets('renders module filter chips', (tester) async {
      await openDialog(tester);

      // First few chips are visible; others are scrollable.
      expect(find.byType(FilterChip), findsAtLeastNWidgets(3));
      expect(find.text('Registry'), findsOneWidget);
      expect(find.text('Vault'), findsOneWidget);
    });

    testWidgets('shows empty state when no query', (tester) async {
      await openDialog(tester);

      expect(find.text('Type to search across all modules'),
          findsOneWidget);
    });

    testWidgets('shows recent searches when available', (tester) async {
      await tester.pumpWidget(createApp(
        overrides: [
          recentSearchesProvider.overrideWith((ref) {
            final notifier = RecentSearchesNotifier();
            notifier.add('test query');
            notifier.add('another search');
            return notifier;
          }),
        ],
      ));
      await tester.tap(find.text('Open Search'));
      await tester.pumpAndSettle();

      expect(find.text('Recent Searches'), findsOneWidget);
      expect(find.text('another search'), findsOneWidget);
      expect(find.text('test query'), findsOneWidget);
      expect(find.text('Clear'), findsOneWidget);
    });

    testWidgets('shows loading indicator when searching', (tester) async {
      await openDialog(tester);

      // Type a query — should show loading before debounce completes.
      await tester.enterText(find.byType(TextField), 'test');
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Escape key closes dialog', (tester) async {
      await openDialog(tester);

      expect(find.byType(GlobalSearchDialog), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(find.byType(GlobalSearchDialog), findsNothing);
    });

    testWidgets('shows clear button when text entered', (tester) async {
      await openDialog(tester);

      // Initially no clear button.
      expect(find.byIcon(Icons.close), findsNothing);

      await tester.enterText(find.byType(TextField), 'test');
      await tester.pump();

      // Clear button should appear.
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('search icon is visible', (tester) async {
      await openDialog(tester);

      expect(find.byIcon(Icons.search), findsOneWidget);
    });
  });
}
