/// Tests for [RelayStatusSelector] — presence status popup.
///
/// Verifies dialog header, status option rendering, current status
/// highlighting, status message field with max length, update button,
/// and close button behavior.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/relay_enums.dart';
import 'package:codeops/models/relay_models.dart';
import 'package:codeops/providers/relay_providers.dart';
import 'package:codeops/providers/team_providers.dart';
import 'package:codeops/widgets/relay/relay_presence_indicator.dart';
import 'package:codeops/widgets/relay/relay_status_selector.dart';

const _defaultPresence = UserPresenceResponse(
  userId: 'user-1',
  userDisplayName: 'Adam Allard',
  teamId: 'team-1',
  status: PresenceStatus.online,
  statusMessage: 'Working on RLF-009',
);

Widget _createSelector({
  UserPresenceResponse presence = _defaultPresence,
}) {
  return ProviderScope(
    overrides: [
      selectedTeamIdProvider.overrideWith((ref) => 'team-1'),
      myPresenceProvider('team-1')
          .overrideWith((ref) async => presence),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) => const RelayStatusSelector(),
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('RelayStatusSelector', () {
    testWidgets('renders header and status options', (tester) async {
      await tester.pumpWidget(_createSelector());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Set your status'), findsOneWidget);
      expect(find.text('Online'), findsOneWidget);
      expect(find.text('Away'), findsOneWidget);
      expect(find.text('Do Not Disturb'), findsOneWidget);
      expect(find.text('Offline'), findsOneWidget);
    });

    testWidgets('highlights current status', (tester) async {
      await tester.pumpWidget(_createSelector());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Online should be highlighted with a check icon
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('shows existing status message', (tester) async {
      await tester.pumpWidget(_createSelector());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // The existing status message should be pre-filled
      final textField = tester.widget<TextField>(
        find.byType(TextField),
      );
      expect(textField.controller?.text, 'Working on RLF-009');
    });

    testWidgets('renders update button', (tester) async {
      await tester.pumpWidget(_createSelector());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Update status'), findsOneWidget);
    });

    testWidgets('shows presence indicators for each option', (tester) async {
      await tester.pumpWidget(_createSelector());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Four status options, each with a presence indicator
      expect(find.byType(RelayPresenceIndicator), findsNWidgets(4));
    });

    testWidgets('close button dismisses dialog', (tester) async {
      await tester.pumpWidget(_createSelector());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Set your status'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.text('Set your status'), findsNothing);
    });

    testWidgets('status message field has max length counter',
        (tester) async {
      await tester.pumpWidget(_createSelector());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(
        find.byType(TextField),
      );
      expect(textField.maxLength, 200);
    });

    testWidgets('tapping a different status shows check on new selection',
        (tester) async {
      await tester.pumpWidget(_createSelector());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Initially Online has the check
      expect(find.byIcon(Icons.check), findsOneWidget);

      // Tap "Away"
      await tester.tap(find.text('Away'));
      await tester.pumpAndSettle();

      // Check should still appear once (now on Away)
      expect(find.byIcon(Icons.check), findsOneWidget);
    });
  });
}
