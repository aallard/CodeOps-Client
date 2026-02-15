// Widget tests for DependencyScanPage.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/dependency_scan.dart';
import 'package:codeops/models/enums.dart';
import 'package:codeops/models/health_snapshot.dart';
import 'package:codeops/models/project.dart';
import 'package:codeops/pages/dependency_scan_page.dart';
import 'package:codeops/providers/dependency_providers.dart';
import 'package:codeops/providers/project_providers.dart';

final _testProject = Project(
  id: 'proj-1',
  teamId: 'team-1',
  name: 'Test Project',
  repoUrl: 'https://github.com/test/test',
);

final _testScan = DependencyScan(
  id: 'scan-1',
  projectId: 'proj-1',
  totalDependencies: 42,
  outdatedCount: 5,
  vulnerableCount: 3,
  createdAt: DateTime(2025, 6, 15),
);

final _testVulnerabilities = PageResponse<DependencyVulnerability>(
  content: [
    DependencyVulnerability(
      id: 'v-1',
      scanId: 'scan-1',
      dependencyName: 'lodash',
      currentVersion: '4.17.15',
      fixedVersion: '4.17.21',
      cveId: 'CVE-2021-23337',
      severity: Severity.high,
      status: VulnerabilityStatus.open,
    ),
    DependencyVulnerability(
      id: 'v-2',
      scanId: 'scan-1',
      dependencyName: 'axios',
      currentVersion: '0.21.0',
      fixedVersion: '0.21.1',
      severity: Severity.medium,
      status: VulnerabilityStatus.open,
    ),
  ],
  page: 0,
  size: 20,
  totalElements: 2,
  totalPages: 1,
  isLast: true,
);

void main() {
  Widget createWidget({
    List<Project> projects = const [],
    DependencyScan? scan,
    PageResponse<DependencyVulnerability>? vulns,
    List<Override> overrides = const [],
  }) {
    return ProviderScope(
      overrides: [
        teamProjectsProvider.overrideWith(
          (ref) => Future.value(projects),
        ),
        if (projects.isNotEmpty && scan != null)
          latestScanProvider(projects.first.id).overrideWith(
            (ref) => Future.value(scan),
          ),
        if (scan != null && vulns != null)
          scanVulnerabilitiesProvider(scan.id).overrideWith(
            (ref) => Future.value(vulns),
          ),
        ...overrides,
      ],
      child: const MaterialApp(home: Scaffold(body: DependencyScanPage())),
    );
  }

  group('DependencyScanPage', () {
    testWidgets('tab bar with 3 tabs renders', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidget(
        projects: [_testProject],
        scan: _testScan,
        vulns: _testVulnerabilities,
      ));
      await tester.pumpAndSettle();

      expect(find.byType(Tab), findsNWidgets(3));
      expect(find.text('All Vulnerabilities'), findsOneWidget);
      expect(find.text('CVE Alerts'), findsOneWidget);
      expect(find.text('Update Plan'), findsOneWidget);
    });

    testWidgets('renders Run Dependency Scan button with provider overrides',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidget(
        projects: [_testProject],
        scan: _testScan,
        vulns: _testVulnerabilities,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Run Dependency Scan'), findsOneWidget);
    });

    testWidgets('project selector exists when projects are loaded',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidget(
        projects: [_testProject],
        scan: _testScan,
        vulns: _testVulnerabilities,
      ));
      await tester.pumpAndSettle();

      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
      expect(find.text('Test Project'), findsOneWidget);
    });

    testWidgets('empty state shows when no projects', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidget(projects: []));
      await tester.pumpAndSettle();

      expect(find.text('No projects'), findsOneWidget);
      expect(
        find.text('Create a project to scan dependencies.'),
        findsOneWidget,
      );
    });

    testWidgets('shows last scanned date when scan has timestamp',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidget(
        projects: [_testProject],
        scan: _testScan,
        vulns: _testVulnerabilities,
      ));
      await tester.pumpAndSettle();

      expect(find.textContaining('Last scanned'), findsOneWidget);
    });

    testWidgets('shows scan metadata when scan data is loaded',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidget(
        projects: [_testProject],
        scan: _testScan,
        vulns: _testVulnerabilities,
      ));
      await tester.pumpAndSettle();

      // Scan metadata should show dependency counts.
      expect(
        find.textContaining('42 dependencies'),
        findsOneWidget,
      );
    });
  });
}
