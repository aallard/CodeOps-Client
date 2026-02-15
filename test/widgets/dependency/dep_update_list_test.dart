// Widget tests for DepUpdateList.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/dependency_scan.dart';
import 'package:codeops/models/enums.dart';
import 'package:codeops/widgets/dependency/dep_update_list.dart';

/// Helper to build a [DependencyVulnerability] with sensible defaults.
DependencyVulnerability _vuln({
  String id = 'v-1',
  String scanId = 's-1',
  String dependencyName = 'lodash',
  String? currentVersion = '4.17.15',
  String? fixedVersion = '4.17.21',
  String? cveId,
  Severity severity = Severity.high,
  VulnerabilityStatus status = VulnerabilityStatus.open,
}) {
  return DependencyVulnerability(
    id: id,
    scanId: scanId,
    dependencyName: dependencyName,
    currentVersion: currentVersion,
    fixedVersion: fixedVersion,
    cveId: cveId,
    severity: severity,
    status: status,
  );
}

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  group('DepUpdateList', () {
    testWidgets('groups vulnerabilities by dependency name', (tester) async {
      final vulns = [
        _vuln(
          id: 'v-1',
          dependencyName: 'lodash',
          currentVersion: '4.17.15',
          fixedVersion: '4.17.21',
          cveId: 'CVE-2021-23337',
        ),
        _vuln(
          id: 'v-2',
          dependencyName: 'lodash',
          currentVersion: '4.17.15',
          fixedVersion: '4.17.21',
          cveId: 'CVE-2020-28500',
        ),
        _vuln(
          id: 'v-3',
          dependencyName: 'axios',
          currentVersion: '0.21.0',
          fixedVersion: '0.21.1',
        ),
      ];

      await tester.pumpWidget(wrap(
        DepUpdateList(vulnerabilities: vulns),
      ));
      await tester.pumpAndSettle();

      // Both dependency names should appear as group headers.
      expect(find.text('lodash'), findsOneWidget);
      expect(find.text('axios'), findsOneWidget);
    });

    testWidgets('shows current to fixed version', (tester) async {
      final vulns = [
        _vuln(
          dependencyName: 'express',
          currentVersion: '4.17.1',
          fixedVersion: '4.18.2',
        ),
      ];

      await tester.pumpWidget(wrap(
        DepUpdateList(vulnerabilities: vulns),
      ));
      await tester.pumpAndSettle();

      expect(find.text('4.17.1'), findsOneWidget);
      expect(find.text('4.18.2'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
    });

    testWidgets('Mark Resolved button exists for each group', (tester) async {
      final vulns = [
        _vuln(
          id: 'v-1',
          dependencyName: 'lodash',
          fixedVersion: '4.17.21',
        ),
        _vuln(
          id: 'v-2',
          dependencyName: 'axios',
          fixedVersion: '0.21.1',
        ),
      ];

      await tester.pumpWidget(wrap(
        DepUpdateList(
          vulnerabilities: vulns,
          onMarkResolved: (_) {},
        ),
      ));
      await tester.pumpAndSettle();

      // Each group gets a Mark Resolved button showing the count.
      expect(find.textContaining('Mark Resolved'), findsNWidgets(2));
    });

    testWidgets('Export Plan button triggers callback', (tester) async {
      var exportCalled = false;

      final vulns = [
        _vuln(fixedVersion: '4.17.21'),
      ];

      await tester.pumpWidget(wrap(
        DepUpdateList(
          vulnerabilities: vulns,
          onExport: () => exportCalled = true,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Export Update Plan'), findsOneWidget);
      await tester.tap(find.text('Export Update Plan'));
      await tester.pump();

      expect(exportCalled, isTrue);
    });

    testWidgets('shows empty state when no actionable updates',
        (tester) async {
      // All resolved -- not actionable.
      final vulns = [
        _vuln(
          status: VulnerabilityStatus.resolved,
          fixedVersion: '4.17.21',
        ),
      ];

      await tester.pumpWidget(wrap(
        DepUpdateList(vulnerabilities: vulns),
      ));
      await tester.pumpAndSettle();

      expect(find.text('No actionable updates'), findsOneWidget);
    });

    testWidgets('shows empty state when vulnerabilities list is empty',
        (tester) async {
      await tester.pumpWidget(wrap(
        const DepUpdateList(vulnerabilities: []),
      ));
      await tester.pumpAndSettle();

      expect(find.text('No actionable updates'), findsOneWidget);
    });

    testWidgets(
        'excludes vulnerabilities without fixed version from actionable list',
        (tester) async {
      final vulns = [
        _vuln(
          id: 'v-no-fix',
          dependencyName: 'no-fix-pkg',
          fixedVersion: null,
          status: VulnerabilityStatus.open,
        ),
      ];

      await tester.pumpWidget(wrap(
        DepUpdateList(vulnerabilities: vulns),
      ));
      await tester.pumpAndSettle();

      // No fixed version means not actionable -> empty state.
      expect(find.text('No actionable updates'), findsOneWidget);
    });
  });
}
