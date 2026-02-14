// Tests for FindingStatusActions.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:codeops/models/enums.dart';
import 'package:codeops/models/finding.dart';
import 'package:codeops/services/cloud/api_client.dart';
import 'package:codeops/services/cloud/finding_api.dart';
import 'package:codeops/providers/finding_providers.dart';
import 'package:codeops/widgets/findings/finding_status_actions.dart';

class MockApiClient extends Mock implements ApiClient {}

class MockFindingApi extends Mock implements FindingApi {}

void main() {
  late MockFindingApi mockFindingApi;

  const openFinding = Finding(
    id: 'f1',
    jobId: 'j1',
    agentType: AgentType.security,
    severity: Severity.high,
    title: 'SQL Injection Risk',
    status: FindingStatus.open,
  );

  const acknowledgedFinding = Finding(
    id: 'f2',
    jobId: 'j1',
    agentType: AgentType.codeQuality,
    severity: Severity.medium,
    title: 'Complex method',
    status: FindingStatus.acknowledged,
  );

  setUp(() {
    mockFindingApi = MockFindingApi();
  });

  Widget createWidget({
    Finding? finding,
    Set<String> selectedIds = const {},
    List<Override> overrides = const [],
  }) {
    return ProviderScope(
      overrides: [
        selectedFindingIdsProvider.overrideWith((ref) => <String>{}),
        ...overrides,
      ],
      child: MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 800,
            child: FindingStatusActions(
              finding: finding,
              selectedIds: selectedIds,
              findingApi: mockFindingApi,
              jobId: 'j1',
            ),
          ),
        ),
      ),
    );
  }

  group('FindingStatusActions — single finding', () {
    testWidgets('renders status buttons excluding current status for open finding',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidget(finding: openFinding));
      await tester.pumpAndSettle();

      // Open finding should show all statuses except Open
      expect(find.text('Acknowledged'), findsOneWidget);
      expect(find.text('False Positive'), findsOneWidget);
      expect(find.text('Fixed'), findsOneWidget);
      expect(find.text("Won't Fix"), findsOneWidget);
    });

    testWidgets('excludes current status from buttons', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidget(finding: acknowledgedFinding));
      await tester.pumpAndSettle();

      // Acknowledged finding should not show Acknowledged button
      expect(find.text('Acknowledged'), findsNothing);
      // But should show other statuses
      expect(find.text('Open'), findsOneWidget);
      expect(find.text('False Positive'), findsOneWidget);
      expect(find.text('Fixed'), findsOneWidget);
      expect(find.text("Won't Fix"), findsOneWidget);
    });

    testWidgets('does not show selection count for single finding',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidget(finding: openFinding));
      await tester.pumpAndSettle();

      expect(find.textContaining('selected'), findsNothing);
    });
  });

  group('FindingStatusActions — bulk mode', () {
    testWidgets('shows all non-open statuses in bulk mode', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidget(
        finding: null,
        selectedIds: {'f1', 'f2', 'f3'},
      ));
      await tester.pumpAndSettle();

      expect(find.text('Acknowledged'), findsOneWidget);
      expect(find.text('False Positive'), findsOneWidget);
      expect(find.text('Fixed'), findsOneWidget);
      expect(find.text("Won't Fix"), findsOneWidget);
    });

    testWidgets('shows selection count in bulk mode', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidget(
        finding: null,
        selectedIds: {'f1', 'f2', 'f3'},
      ));
      await tester.pumpAndSettle();

      expect(find.text('3 selected'), findsOneWidget);
    });
  });

  group('FindingStatusActions — icons', () {
    testWidgets('renders status icons', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidget(finding: openFinding));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.visibility), findsOneWidget);
      expect(find.byIcon(Icons.do_not_disturb), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
      expect(find.byIcon(Icons.block), findsOneWidget);
    });
  });
}
