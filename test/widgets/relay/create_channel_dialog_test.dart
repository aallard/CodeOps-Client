/// Tests for [CreateChannelDialog] — channel creation form dialog.
///
/// Verifies form fields, slug preview, validation, type selector,
/// create button state, API call on submit, success/error handling.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:codeops/models/health_snapshot.dart';
import 'package:codeops/models/relay_enums.dart';
import 'package:codeops/models/relay_models.dart';
import 'package:codeops/providers/relay_providers.dart';
import 'package:codeops/services/cloud/relay_api.dart';
import 'package:codeops/widgets/relay/create_channel_dialog.dart';

class MockRelayApiService extends Mock implements RelayApiService {}

class FakeCreateChannelRequest extends Fake implements CreateChannelRequest {}

Widget _createDialog({
  String teamId = 'team-1',
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) => ProviderScope(
                parent: ProviderScope.containerOf(context),
                child: CreateChannelDialog(teamId: teamId),
              ),
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    ),
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeCreateChannelRequest());
  });

  group('CreateChannelDialog', () {
    testWidgets('renders name field', (tester) async {
      await tester.pumpWidget(_createDialog());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Name *'), findsOneWidget);
    });

    testWidgets('renders description field', (tester) async {
      await tester.pumpWidget(_createDialog());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Description'), findsOneWidget);
    });

    testWidgets('renders type selector (public/private)', (tester) async {
      await tester.pumpWidget(_createDialog());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Public'), findsOneWidget);
      expect(find.text('Private'), findsOneWidget);
    });

    testWidgets('renders topic field', (tester) async {
      await tester.pumpWidget(_createDialog());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Topic'), findsOneWidget);
    });

    testWidgets('shows slug preview below name', (tester) async {
      await tester.pumpWidget(_createDialog());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Enter a channel name
      final nameFields = find.byType(TextFormField);
      await tester.enterText(nameFields.first, 'My Channel');
      await tester.pumpAndSettle();

      expect(find.textContaining('my-channel'), findsOneWidget);
    });

    testWidgets('create button disabled when name empty', (tester) async {
      await tester.pumpWidget(_createDialog());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Create button should be present but disabled
      final createButton = find.widgetWithText(FilledButton, 'Create');
      expect(createButton, findsOneWidget);

      final button = tester.widget<FilledButton>(createButton);
      expect(button.onPressed, isNull);
    });

    testWidgets('create button enabled when name valid', (tester) async {
      await tester.pumpWidget(_createDialog());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Enter valid name
      final nameFields = find.byType(TextFormField);
      await tester.enterText(nameFields.first, 'engineering');
      await tester.pumpAndSettle();

      final createButton = find.widgetWithText(FilledButton, 'Create');
      final button = tester.widget<FilledButton>(createButton);
      expect(button.onPressed, isNotNull);
    });

    testWidgets('calls createChannel API on submit', (tester) async {
      final mockApi = MockRelayApiService();
      when(() => mockApi.createChannel(any(), any())).thenAnswer(
        (_) async => const ChannelResponse(
          id: 'new-ch',
          name: 'engineering',
          slug: 'engineering',
          channelType: ChannelType.public,
        ),
      );

      await tester.pumpWidget(_createDialog(
        overrides: [
          relayApiProvider.overrideWithValue(mockApi),
          teamChannelsProvider('team-1').overrideWith(
            (ref) async => PageResponse<ChannelSummaryResponse>(
              content: [],
              page: 0,
              size: 50,
              totalElements: 0,
              totalPages: 0,
              isLast: true,
            ),
          ),
        ],
      ));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Enter name and submit
      final nameFields = find.byType(TextFormField);
      await tester.enterText(nameFields.first, 'engineering');
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Create'));
      await tester.pumpAndSettle();

      verify(() => mockApi.createChannel('team-1', any())).called(1);
    });

    testWidgets('closes dialog on success', (tester) async {
      final mockApi = MockRelayApiService();
      when(() => mockApi.createChannel(any(), any())).thenAnswer(
        (_) async => const ChannelResponse(
          id: 'new-ch',
          name: 'engineering',
          slug: 'engineering',
          channelType: ChannelType.public,
        ),
      );

      await tester.pumpWidget(_createDialog(
        overrides: [
          relayApiProvider.overrideWithValue(mockApi),
          teamChannelsProvider('team-1').overrideWith(
            (ref) async => PageResponse<ChannelSummaryResponse>(
              content: [],
              page: 0,
              size: 50,
              totalElements: 0,
              totalPages: 0,
              isLast: true,
            ),
          ),
        ],
      ));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      final nameFields = find.byType(TextFormField);
      await tester.enterText(nameFields.first, 'engineering');
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Create'));
      await tester.pumpAndSettle();

      // Dialog should be closed
      expect(find.text('Create Channel'), findsNothing);
    });

    testWidgets('shows error on API failure', (tester) async {
      final mockApi = MockRelayApiService();
      when(() => mockApi.createChannel(any(), any()))
          .thenThrow(Exception('already exists'));

      await tester.pumpWidget(_createDialog(
        overrides: [
          relayApiProvider.overrideWithValue(mockApi),
          teamChannelsProvider('team-1').overrideWith(
            (ref) async => PageResponse<ChannelSummaryResponse>(
              content: [],
              page: 0,
              size: 50,
              totalElements: 0,
              totalPages: 0,
              isLast: true,
            ),
          ),
        ],
      ));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      final nameFields = find.byType(TextFormField);
      await tester.enterText(nameFields.first, 'engineering');
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Create'));
      await tester.pumpAndSettle();

      expect(find.text('Channel name already exists'), findsOneWidget);
    });
  });
}
