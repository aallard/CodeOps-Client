// Tests for the service name badge in FindingDetailPanel.
//
// Verifies that the derived service name badge appears when a file path
// contains a recognizable project directory, and does not appear when
// the file path cannot be parsed.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/enums.dart';
import 'package:codeops/models/finding.dart';
import 'package:codeops/services/cloud/finding_api.dart';
import 'package:codeops/widgets/findings/finding_detail_panel.dart';

/// Fake [FindingApi] that returns canned responses.
class _FakeFindingApi implements FindingApi {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

Finding _testFinding({String? filePath}) {
  return Finding(
    id: 'f-1',
    jobId: 'j-1',
    agentType: AgentType.security,
    severity: Severity.high,
    title: 'Test Finding',
    status: FindingStatus.open,
    filePath: filePath,
    lineNumber: 42,
  );
}

Widget _createWidget({String? filePath}) {
  return ProviderScope(
    child: MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 700,
          height: 800,
          child: FindingDetailPanel(
            finding: _testFinding(filePath: filePath),
            findingApi: _FakeFindingApi(),
            jobId: 'j-1',
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('Finding Service Badge', () {
    testWidgets('shows service badge when file path has project directory',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(700, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        _createWidget(filePath: 'CodeOps-Server/src/main/java/Foo.java'),
      );
      await tester.pumpAndSettle();

      expect(find.text('Service'), findsOneWidget);
      expect(find.text('CodeOps-Server'), findsOneWidget);
    });

    testWidgets('does not show service badge when file path is null',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(700, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_createWidget(filePath: null));
      await tester.pumpAndSettle();

      expect(find.text('Service'), findsNothing);
    });

    testWidgets('derives service name from lib/ marker', (tester) async {
      await tester.binding.setSurfaceSize(const Size(700, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester
          .pumpWidget(_createWidget(filePath: 'MyApp/lib/main.dart'));
      await tester.pumpAndSettle();

      expect(find.text('MyApp'), findsOneWidget);
    });
  });
}
