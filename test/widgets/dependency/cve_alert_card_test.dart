// Widget tests for CveAlertCard.
//
// Verifies that only OPEN + CRITICAL/HIGH vulnerabilities are shown,
// action buttons exist, and empty state appears when no critical alerts.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/dependency_scan.dart';
import 'package:codeops/models/enums.dart';
import 'package:codeops/widgets/dependency/cve_alert_card.dart';

/// Builds a [DependencyVulnerability] with sensible defaults.
DependencyVulnerability _vuln({
  String id = 'v1',
  String scanId = 'scan-1',
  String dependencyName = 'some-lib',
  String? cveId,
  Severity severity = Severity.medium,
  VulnerabilityStatus status = VulnerabilityStatus.open,
  String? description,
  String? fixedVersion,
}) {
  return DependencyVulnerability(
    id: id,
    scanId: scanId,
    dependencyName: dependencyName,
    cveId: cveId,
    severity: severity,
    status: status,
    description: description,
    fixedVersion: fixedVersion,
  );
}

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 600,
          height: 600,
          child: child,
        ),
      ),
    );
  }

  group('CveAlertCard', () {
    testWidgets('shows only OPEN + CRITICAL/HIGH vulns', (tester) async {
      final vulns = [
        // Should show: OPEN + CRITICAL
        _vuln(
          id: 'v1',
          dependencyName: 'log4j-core',
          cveId: 'CVE-2021-44228',
          severity: Severity.critical,
          status: VulnerabilityStatus.open,
        ),
        // Should show: OPEN + HIGH
        _vuln(
          id: 'v2',
          dependencyName: 'spring-web',
          cveId: 'CVE-2023-1234',
          severity: Severity.high,
          status: VulnerabilityStatus.open,
        ),
        // Should NOT show: OPEN + MEDIUM (not critical/high)
        _vuln(
          id: 'v3',
          dependencyName: 'commons-io',
          severity: Severity.medium,
          status: VulnerabilityStatus.open,
        ),
        // Should NOT show: RESOLVED + CRITICAL (not open)
        _vuln(
          id: 'v4',
          dependencyName: 'jackson-core',
          severity: Severity.critical,
          status: VulnerabilityStatus.resolved,
        ),
        // Should NOT show: SUPPRESSED + HIGH (not open)
        _vuln(
          id: 'v5',
          dependencyName: 'guava',
          severity: Severity.high,
          status: VulnerabilityStatus.suppressed,
        ),
        // Should NOT show: OPEN + LOW (not critical/high)
        _vuln(
          id: 'v6',
          dependencyName: 'joda-time',
          severity: Severity.low,
          status: VulnerabilityStatus.open,
        ),
      ];

      await tester.pumpWidget(wrap(CveAlertCard(vulnerabilities: vulns)));
      await tester.pumpAndSettle();

      // v1 and v2 should be visible
      expect(find.text('CVE-2021-44228'), findsOneWidget);
      expect(find.text('log4j-core'), findsOneWidget);
      expect(find.text('CVE-2023-1234'), findsOneWidget);
      expect(find.text('spring-web'), findsOneWidget);

      // v3-v6 should NOT be visible as alert cards
      expect(find.text('commons-io'), findsNothing);
      expect(find.text('jackson-core'), findsNothing);
      expect(find.text('guava'), findsNothing);
      expect(find.text('joda-time'), findsNothing);
    });

    testWidgets('Update Now button exists for each alert', (tester) async {
      final vulns = [
        _vuln(
          id: 'v1',
          dependencyName: 'log4j',
          severity: Severity.critical,
          status: VulnerabilityStatus.open,
        ),
      ];

      await tester.pumpWidget(wrap(CveAlertCard(vulnerabilities: vulns)));
      await tester.pumpAndSettle();

      expect(find.text('Update Now'), findsOneWidget);
    });

    testWidgets('Suppress button exists for each alert', (tester) async {
      final vulns = [
        _vuln(
          id: 'v1',
          dependencyName: 'log4j',
          severity: Severity.critical,
          status: VulnerabilityStatus.open,
        ),
      ];

      await tester.pumpWidget(wrap(CveAlertCard(vulnerabilities: vulns)));
      await tester.pumpAndSettle();

      expect(find.text('Suppress'), findsOneWidget);
    });

    testWidgets('View CVE button exists when cveId is present',
        (tester) async {
      final vulns = [
        _vuln(
          id: 'v1',
          dependencyName: 'log4j',
          cveId: 'CVE-2021-44228',
          severity: Severity.critical,
          status: VulnerabilityStatus.open,
        ),
      ];

      await tester.pumpWidget(wrap(CveAlertCard(vulnerabilities: vulns)));
      await tester.pumpAndSettle();

      expect(find.text('View CVE'), findsOneWidget);
    });

    testWidgets('View CVE button hidden when cveId is null', (tester) async {
      final vulns = [
        _vuln(
          id: 'v1',
          dependencyName: 'log4j',
          cveId: null,
          severity: Severity.critical,
          status: VulnerabilityStatus.open,
        ),
      ];

      await tester.pumpWidget(wrap(CveAlertCard(vulnerabilities: vulns)));
      await tester.pumpAndSettle();

      expect(find.text('View CVE'), findsNothing);
      // "No CVE" text should appear instead of the CVE ID
      expect(find.text('No CVE'), findsOneWidget);
    });

    testWidgets('empty state when no critical alerts', (tester) async {
      final vulns = [
        _vuln(
          id: 'v1',
          severity: Severity.medium,
          status: VulnerabilityStatus.open,
        ),
        _vuln(
          id: 'v2',
          severity: Severity.low,
          status: VulnerabilityStatus.open,
        ),
      ];

      await tester.pumpWidget(wrap(CveAlertCard(vulnerabilities: vulns)));
      await tester.pumpAndSettle();

      expect(find.text('No critical alerts'), findsOneWidget);
      expect(
        find.text(
            'No open critical or high severity vulnerabilities found.'),
        findsOneWidget,
      );
    });

    testWidgets('empty state when all vulns are resolved', (tester) async {
      final vulns = [
        _vuln(
          id: 'v1',
          severity: Severity.critical,
          status: VulnerabilityStatus.resolved,
        ),
        _vuln(
          id: 'v2',
          severity: Severity.high,
          status: VulnerabilityStatus.suppressed,
        ),
      ];

      await tester.pumpWidget(wrap(CveAlertCard(vulnerabilities: vulns)));
      await tester.pumpAndSettle();

      expect(find.text('No critical alerts'), findsOneWidget);
    });

    testWidgets('empty state when vulnerabilities list is empty',
        (tester) async {
      await tester
          .pumpWidget(wrap(const CveAlertCard(vulnerabilities: [])));
      await tester.pumpAndSettle();

      expect(find.text('No critical alerts'), findsOneWidget);
    });

    testWidgets('Update Now button fires onUpdate callback',
        (tester) async {
      DependencyVulnerability? updatedVuln;
      final vulns = [
        _vuln(
          id: 'v1',
          dependencyName: 'log4j',
          severity: Severity.critical,
          status: VulnerabilityStatus.open,
        ),
      ];

      await tester.pumpWidget(wrap(
        CveAlertCard(
          vulnerabilities: vulns,
          onUpdate: (vuln) => updatedVuln = vuln,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Update Now'));
      await tester.pumpAndSettle();

      expect(updatedVuln, isNotNull);
      expect(updatedVuln!.id, 'v1');
    });

    testWidgets('shows description when present', (tester) async {
      final vulns = [
        _vuln(
          id: 'v1',
          dependencyName: 'log4j',
          severity: Severity.critical,
          status: VulnerabilityStatus.open,
          description: 'Remote code execution via JNDI lookup.',
        ),
      ];

      await tester.pumpWidget(wrap(CveAlertCard(vulnerabilities: vulns)));
      await tester.pumpAndSettle();

      expect(
        find.text('Remote code execution via JNDI lookup.'),
        findsOneWidget,
      );
    });

    testWidgets('shows fix available when fixedVersion present',
        (tester) async {
      final vulns = [
        _vuln(
          id: 'v1',
          dependencyName: 'log4j',
          severity: Severity.critical,
          status: VulnerabilityStatus.open,
          fixedVersion: '2.17.1',
        ),
      ];

      await tester.pumpWidget(wrap(CveAlertCard(vulnerabilities: vulns)));
      await tester.pumpAndSettle();

      expect(find.text('Fix available: 2.17.1'), findsOneWidget);
    });

    testWidgets('renders multiple alert cards', (tester) async {
      final vulns = [
        _vuln(
          id: 'v1',
          dependencyName: 'log4j',
          cveId: 'CVE-2021-44228',
          severity: Severity.critical,
          status: VulnerabilityStatus.open,
        ),
        _vuln(
          id: 'v2',
          dependencyName: 'spring-web',
          cveId: 'CVE-2023-1234',
          severity: Severity.high,
          status: VulnerabilityStatus.open,
        ),
      ];

      await tester.pumpWidget(wrap(CveAlertCard(vulnerabilities: vulns)));
      await tester.pumpAndSettle();

      expect(find.text('Update Now'), findsNWidgets(2));
      expect(find.text('Suppress'), findsNWidgets(2));
    });
  });
}
