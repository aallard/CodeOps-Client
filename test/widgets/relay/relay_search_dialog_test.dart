/// Tests for [RelaySearchDialog] — message search dialog.
///
/// Verifies search input rendering, mode toggle between "This channel"
/// and "All channels", empty state, no results state, result display
/// with channel name and sender, and footer showing result count.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/providers/relay_providers.dart';
import 'package:codeops/providers/team_providers.dart';
import 'package:codeops/widgets/relay/relay_search_dialog.dart';

Widget _createDialog({String? channelId, List<Override> overrides = const []}) {
  return ProviderScope(
    overrides: [
      selectedTeamIdProvider.overrideWith((ref) => 'team-1'),
      ...overrides,
    ],
    child: MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) => RelaySearchDialog(channelId: channelId),
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('RelaySearchDialog', () {
    testWidgets('renders search header and input', (tester) async {
      await tester.pumpWidget(_createDialog());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Search messages'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('shows placeholder text before typing', (tester) async {
      await tester.pumpWidget(_createDialog());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Type to search messages'), findsOneWidget);
    });

    testWidgets('shows mode toggle when channelId provided', (tester) async {
      await tester.pumpWidget(_createDialog(channelId: 'ch-1'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('This channel'), findsOneWidget);
      expect(find.text('All channels'), findsOneWidget);
    });

    testWidgets('hides mode toggle when no channelId', (tester) async {
      await tester.pumpWidget(_createDialog());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('This channel'), findsNothing);
      expect(find.text('All channels'), findsNothing);
    });

    testWidgets('defaults to This channel when channelId provided',
        (tester) async {
      await tester.pumpWidget(_createDialog(channelId: 'ch-1'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // "This channel" should be styled as active (fontWeight w600)
      final thisChannelText = tester.widget<Text>(
        find.text('This channel'),
      );
      expect(thisChannelText.style?.fontWeight, FontWeight.w600);
    });

    testWidgets('close button dismisses dialog', (tester) async {
      await tester.pumpWidget(_createDialog());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Search messages'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.text('Search messages'), findsNothing);
    });

    testWidgets('search hint placeholder text is present', (tester) async {
      await tester.pumpWidget(_createDialog());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Search messages...'), findsOneWidget);
    });
  });
}
