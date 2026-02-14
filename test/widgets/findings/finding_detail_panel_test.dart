// Tests for FindingDetailPanel.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:codeops/models/enums.dart';
import 'package:codeops/models/finding.dart';
import 'package:codeops/services/cloud/api_client.dart';
import 'package:codeops/services/cloud/finding_api.dart';
import 'package:codeops/widgets/findings/finding_detail_panel.dart';

class MockApiClient extends Mock implements ApiClient {}

class MockFindingApi extends Mock implements FindingApi {}

void main() {
  late MockFindingApi mockFindingApi;

  const finding = Finding(
    id: 'f1',
    jobId: 'j1',
    agentType: AgentType.security,
    severity: Severity.high,
    title: 'Hardcoded credentials in config',
    description: 'Database password is hardcoded in application.yml.',
    filePath: 'src/main/resources/application.yml',
    lineNumber: 15,
    recommendation: 'Use environment variables for secrets.',
    evidence: '```yaml\npassword: admin123\n```',
    effortEstimate: Effort.s,
    status: FindingStatus.open,
  );

  setUp(() {
    mockFindingApi = MockFindingApi();
  });

  Widget createWidget({
    Finding findingData = finding,
    VoidCallback? onClose,
  }) {
    return ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 700,
            height: 900,
            child: FindingDetailPanel(
              finding: findingData,
              findingApi: mockFindingApi,
              jobId: 'j1',
              onClose: onClose,
            ),
          ),
        ),
      ),
    );
  }

  group('FindingDetailPanel', () {
    testWidgets('shows finding title', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Hardcoded credentials in config'), findsOneWidget);
    });

    testWidgets('shows severity badge', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('High'), findsOneWidget);
    });

    testWidgets('shows agent display name', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Security'), findsOneWidget);
    });

    testWidgets('shows status display name', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      // Status shown in detail row and in status actions
      expect(find.text('Open'), findsWidgets);
    });

    testWidgets('shows file path', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(
        find.text('src/main/resources/application.yml'),
        findsOneWidget,
      );
    });

    testWidgets('shows line number', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('15'), findsOneWidget);
    });

    testWidgets('shows effort estimate', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Small'), findsOneWidget);
    });

    testWidgets('shows description section', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Description'), findsOneWidget);
    });

    testWidgets('shows recommendation section', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Recommendation'), findsOneWidget);
    });

    testWidgets('shows evidence section', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Evidence'), findsOneWidget);
    });

    testWidgets('shows close button when onClose is provided',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidget(onClose: () {}));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('shows detail row labels', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Agent'), findsOneWidget);
      expect(find.text('Status'), findsOneWidget);
      expect(find.text('File'), findsOneWidget);
      expect(find.text('Line'), findsOneWidget);
      expect(find.text('Effort'), findsOneWidget);
    });
  });
}
