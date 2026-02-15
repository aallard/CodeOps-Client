// Widget tests for DepScanResults.
//
// Verifies vulnerability table rendering, column headers,
// severity/status filter dropdowns, and search functionality.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/dependency_scan.dart';
import 'package:codeops/models/enums.dart';
import 'package:codeops/models/health_snapshot.dart';
import 'package:codeops/providers/dependency_providers.dart';
import 'package:codeops/widgets/dependency/dep_scan_results.dart';

/// Builds a [DependencyVulnerability] with sensible defaults.
DependencyVulnerability _vuln({
  String id = 'v1',
  String scanId = 'scan-1',
  String dependencyName = 'some-lib',
  String? currentVersion,
  String? fixedVersion,
  String? cveId,
  Severity severity = Severity.medium,
  VulnerabilityStatus status = VulnerabilityStatus.open,
  String? description,
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
    description: description,
  );
}

PageResponse<DependencyVulnerability> _vulnPage(
    List<DependencyVulnerability> vulns) {
  return PageResponse<DependencyVulnerability>(
    content: vulns,
    page: 0,
    size: vulns.length,
    totalElements: vulns.length,
    totalPages: 1,
    isLast: true,
  );
}

void main() {
  Widget buildWidget({
    required List<Override> overrides,
    String scanId = 'scan-1',
  }) {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 1200,
            height: 600,
            child: DepScanResults(scanId: scanId),
          ),
        ),
      ),
    );
  }

  group('DepScanResults', () {
    testWidgets('renders vulnerability table with correct columns',
        (tester) async {
      final vulns = [
        _vuln(
          id: 'v1',
          dependencyName: 'log4j-core',
          currentVersion: '2.14.0',
          fixedVersion: '2.17.1',
          cveId: 'CVE-2021-44228',
          severity: Severity.critical,
          status: VulnerabilityStatus.open,
        ),
      ];

      await tester.pumpWidget(buildWidget(
        overrides: [
          scanVulnerabilitiesProvider('scan-1')
              .overrideWith((ref) async => _vulnPage(vulns)),
        ],
      ));
      await tester.pumpAndSettle();

      // Column headers
      expect(find.text('Dependency'), findsOneWidget);
      expect(find.text('Current'), findsOneWidget);
      expect(find.text('Fixed'), findsOneWidget);
      expect(find.text('CVE ID'), findsOneWidget);
      expect(find.text('Severity'), findsOneWidget);
      // "Status" appears as both a column header and a filter hint.
      expect(find.text('Status'), findsWidgets);
      expect(find.text('Actions'), findsOneWidget);

      // Data cell content
      expect(find.text('log4j-core'), findsOneWidget);
      expect(find.text('2.14.0'), findsOneWidget);
      expect(find.text('2.17.1'), findsOneWidget);
      expect(find.text('CVE-2021-44228'), findsOneWidget);
      expect(find.text('Critical'), findsOneWidget);
      expect(find.text('Open'), findsOneWidget);
    });

    testWidgets('severity and status filter dropdowns exist', (tester) async {
      final vulns = [
        _vuln(id: 'v1', dependencyName: 'test-lib'),
      ];

      await tester.pumpWidget(buildWidget(
        overrides: [
          scanVulnerabilitiesProvider('scan-1')
              .overrideWith((ref) async => _vulnPage(vulns)),
        ],
      ));
      await tester.pumpAndSettle();

      // The filter bar contains search field + 2 dropdown buttons
      // (severity, status).
      expect(find.byType(DropdownButtonHideUnderline), findsWidgets);

      // At minimum, 2 filter dropdowns + action dropdown per row.
      // DropdownButtonHideUnderline count should be >= 2.
      final hideUnderlineCount =
          find.byType(DropdownButtonHideUnderline).evaluate().length;
      expect(hideUnderlineCount, greaterThanOrEqualTo(2));
    });

    testWidgets('search field exists', (tester) async {
      await tester.pumpWidget(buildWidget(
        overrides: [
          scanVulnerabilitiesProvider('scan-1')
              .overrideWith((ref) async => _vulnPage([])),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search dependency or CVE...'), findsOneWidget);
    });

    testWidgets('search filters by dependency name', (tester) async {
      final vulns = [
        _vuln(id: 'v1', dependencyName: 'log4j-core'),
        _vuln(id: 'v2', dependencyName: 'spring-web'),
        _vuln(id: 'v3', dependencyName: 'log4j-api'),
      ];

      await tester.pumpWidget(buildWidget(
        overrides: [
          scanVulnerabilitiesProvider('scan-1')
              .overrideWith((ref) async => _vulnPage(vulns)),
        ],
      ));
      await tester.pumpAndSettle();

      // All 3 visible initially
      expect(find.text('log4j-core'), findsOneWidget);
      expect(find.text('spring-web'), findsOneWidget);
      expect(find.text('log4j-api'), findsOneWidget);

      // Type in search
      await tester.enterText(find.byType(TextField), 'log4j');
      await tester.pumpAndSettle();

      expect(find.text('log4j-core'), findsOneWidget);
      expect(find.text('log4j-api'), findsOneWidget);
      expect(find.text('spring-web'), findsNothing);
    });

    testWidgets('search filters by CVE ID', (tester) async {
      final vulns = [
        _vuln(
            id: 'v1',
            dependencyName: 'log4j',
            cveId: 'CVE-2021-44228'),
        _vuln(
            id: 'v2',
            dependencyName: 'jackson',
            cveId: 'CVE-2023-9999'),
      ];

      await tester.pumpWidget(buildWidget(
        overrides: [
          scanVulnerabilitiesProvider('scan-1')
              .overrideWith((ref) async => _vulnPage(vulns)),
        ],
      ));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'CVE-2021');
      await tester.pumpAndSettle();

      expect(find.text('log4j'), findsOneWidget);
      expect(find.text('jackson'), findsNothing);
    });

    testWidgets('shows empty state when no vulnerabilities', (tester) async {
      await tester.pumpWidget(buildWidget(
        overrides: [
          scanVulnerabilitiesProvider('scan-1')
              .overrideWith((ref) async => _vulnPage([])),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.text('No vulnerabilities'), findsOneWidget);
    });

    testWidgets('shows loading spinner while data loads', (tester) async {
      final completer = Completer<PageResponse<DependencyVulnerability>>();

      await tester.pumpWidget(buildWidget(
        overrides: [
          scanVulnerabilitiesProvider('scan-1')
              .overrideWith((ref) => completer.future),
        ],
      ));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Complete the completer to avoid pending timer errors.
      completer.complete(_vulnPage([]));
      await tester.pumpAndSettle();
    });

    testWidgets('renders multiple vulnerability rows', (tester) async {
      final vulns = [
        _vuln(id: 'v1', dependencyName: 'lib-a', severity: Severity.critical),
        _vuln(id: 'v2', dependencyName: 'lib-b', severity: Severity.high),
        _vuln(id: 'v3', dependencyName: 'lib-c', severity: Severity.low),
      ];

      await tester.pumpWidget(buildWidget(
        overrides: [
          scanVulnerabilitiesProvider('scan-1')
              .overrideWith((ref) async => _vulnPage(vulns)),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.text('lib-a'), findsOneWidget);
      expect(find.text('lib-b'), findsOneWidget);
      expect(find.text('lib-c'), findsOneWidget);
    });
  });
}
