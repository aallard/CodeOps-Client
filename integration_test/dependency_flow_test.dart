/// Integration test: Dependency Scan page flow.
///
/// Verifies the dependency scan page renders correctly with mocked providers.
library;

import 'package:codeops/models/dependency_scan.dart';
import 'package:codeops/models/enums.dart';
import 'package:codeops/models/health_snapshot.dart';
import 'package:codeops/models/project.dart';
import 'package:codeops/pages/dependency_scan_page.dart';
import 'package:codeops/providers/dependency_providers.dart';
import 'package:codeops/providers/project_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final testProject = Project(
    id: 'proj-1',
    teamId: 'team-1',
    name: 'Dep Scan Test Project',
    repoUrl: 'https://github.com/test/test',
  );

  final testScan = DependencyScan(
    id: 'scan-1',
    projectId: 'proj-1',
    totalDependencies: 120,
    outdatedCount: 8,
    vulnerableCount: 4,
    createdAt: DateTime(2025, 6, 15),
  );

  final testVulns = PageResponse<DependencyVulnerability>(
    content: [
      DependencyVulnerability(
        id: 'v-1',
        scanId: 'scan-1',
        dependencyName: 'lodash',
        currentVersion: '4.17.15',
        fixedVersion: '4.17.21',
        cveId: 'CVE-2021-23337',
        severity: Severity.critical,
        status: VulnerabilityStatus.open,
      ),
      DependencyVulnerability(
        id: 'v-2',
        scanId: 'scan-1',
        dependencyName: 'express',
        currentVersion: '4.17.1',
        fixedVersion: '4.18.2',
        severity: Severity.high,
        status: VulnerabilityStatus.open,
      ),
      DependencyVulnerability(
        id: 'v-3',
        scanId: 'scan-1',
        dependencyName: 'axios',
        currentVersion: '0.21.0',
        fixedVersion: '0.21.1',
        severity: Severity.medium,
        status: VulnerabilityStatus.updating,
      ),
    ],
    page: 0,
    size: 20,
    totalElements: 3,
    totalPages: 1,
    isLast: true,
  );

  testWidgets('dependency scan page renders with mocked data', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 900));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          teamProjectsProvider.overrideWith(
            (ref) => Future.value([testProject]),
          ),
          latestScanProvider(testProject.id).overrideWith(
            (ref) => Future.value(testScan),
          ),
          scanVulnerabilitiesProvider(testScan.id).overrideWith(
            (ref) => Future.value(testVulns),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(body: DependencyScanPage()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify the page loaded with the project name.
    expect(find.text('Dep Scan Test Project'), findsOneWidget);

    // Verify all three tabs are rendered.
    expect(find.text('All Vulnerabilities'), findsOneWidget);
    expect(find.text('CVE Alerts'), findsOneWidget);
    expect(find.text('Update Plan'), findsOneWidget);

    // Verify scan metadata is displayed.
    expect(find.textContaining('120 dependencies'), findsOneWidget);

    // Verify Run Dependency Scan button is present.
    expect(find.text('Run Dependency Scan'), findsOneWidget);
  });

  testWidgets('dependency scan page shows empty state with no projects',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 900));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          teamProjectsProvider.overrideWith(
            (ref) => Future.value(<Project>[]),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(body: DependencyScanPage()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No projects'), findsOneWidget);
    expect(
      find.text('Create a project to scan dependencies.'),
      findsOneWidget,
    );
  });
}
