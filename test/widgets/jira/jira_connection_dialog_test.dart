// Tests for JiraConnectionDialog widget.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import 'package:codeops/providers/auth_providers.dart';
import 'package:codeops/providers/task_providers.dart';
import 'package:codeops/providers/team_providers.dart';
import 'package:codeops/services/auth/secure_storage.dart';
import 'package:codeops/services/cloud/integration_api.dart';
import 'package:codeops/widgets/jira/jira_connection_dialog.dart';

class MockIntegrationApi extends Mock implements IntegrationApi {}

class MockSecureStorageService extends Mock implements SecureStorageService {}

void main() {
  late MockIntegrationApi mockIntegrationApi;
  late MockSecureStorageService mockSecureStorage;

  setUp(() {
    mockIntegrationApi = MockIntegrationApi();
    mockSecureStorage = MockSecureStorageService();
  });

  Widget wrap(Widget child, {List<Override>? overrides}) {
    return ProviderScope(
      overrides: [
        integrationApiProvider.overrideWithValue(mockIntegrationApi),
        secureStorageProvider.overrideWithValue(mockSecureStorage),
        selectedTeamIdProvider.overrideWith((ref) => 'team-1'),
        ...?overrides,
      ],
      child: MaterialApp(home: Scaffold(body: child)),
    );
  }

  group('JiraConnectionDialog', () {
    testWidgets('renders title "New Jira Connection" when no existingConnection',
        (tester) async {
      await tester.pumpWidget(wrap(const JiraConnectionDialog()));
      await tester.pumpAndSettle();

      expect(find.text('New Jira Connection'), findsOneWidget);
    });

    testWidgets('shows form fields: name, URL, email, API token',
        (tester) async {
      await tester.pumpWidget(wrap(const JiraConnectionDialog()));
      await tester.pumpAndSettle();

      expect(find.text('Connection Name'), findsOneWidget);
      expect(find.text('Instance URL'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('API Token'), findsOneWidget);
    });

    testWidgets('Cancel button closes dialog', (tester) async {
      bool dialogClosed = false;

      await tester.pumpWidget(ProviderScope(
        overrides: [
          integrationApiProvider.overrideWithValue(mockIntegrationApi),
          secureStorageProvider.overrideWithValue(mockSecureStorage),
          selectedTeamIdProvider.overrideWith((ref) => 'team-1'),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                final result = await showDialog(
                  context: context,
                  builder: (_) => const JiraConnectionDialog(),
                );
                dialogClosed = result == null;
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('New Jira Connection'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('New Jira Connection'), findsNothing);
      expect(dialogClosed, isTrue);
    });

    testWidgets('Test Connection button is present', (tester) async {
      await tester.pumpWidget(wrap(const JiraConnectionDialog()));
      await tester.pumpAndSettle();

      expect(find.text('Test Connection'), findsOneWidget);
    });
  });
}
