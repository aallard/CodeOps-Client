/// Dependency Scan page (Mode 6) — top-bottom split layout.
///
/// Top: scan overview (project selector, scan metadata, health gauge,
/// vulnerability/status summary cards).
/// Bottom: tabbed view (All Vulnerabilities, CVE Alerts, Update Plan).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/dependency_scan.dart';
import '../services/logging/log_service.dart';
import '../models/enums.dart';
import '../models/project.dart';
import '../providers/dependency_providers.dart';
import '../providers/project_providers.dart';
import '../services/analysis/dependency_scanner.dart';
import '../theme/colors.dart';
import '../widgets/dependency/cve_alert_card.dart';
import '../widgets/dependency/dep_health_gauge.dart';
import '../widgets/dependency/dep_scan_results.dart';
import '../widgets/dependency/dep_update_list.dart';
import '../widgets/shared/empty_state.dart';

/// The Dependency Scan page.
///
/// Route: `/dependencies`
/// Navigation: "Analyze" sidebar section.
class DependencyScanPage extends ConsumerStatefulWidget {
  /// Creates a [DependencyScanPage].
  const DependencyScanPage({super.key});

  @override
  ConsumerState<DependencyScanPage> createState() =>
      _DependencyScanPageState();
}

class _DependencyScanPageState extends ConsumerState<DependencyScanPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(teamProjectsProvider);
    final selectedProjectId = ref.watch(selectedProjectIdProvider);

    return Container(
      color: CodeOpsColors.background,
      child: projectsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Text(
            'Error: $err',
            style: const TextStyle(color: CodeOpsColors.error),
          ),
        ),
        data: (projects) {
          if (projects.isEmpty) {
            return const EmptyState(
              icon: Icons.folder_off_outlined,
              title: 'No projects',
              subtitle: 'Create a project to scan dependencies.',
            );
          }

          final projectId = selectedProjectId ?? projects.first.id;

          return Column(
            children: [
              // Top: Scan overview
              _ScanOverview(
                projects: projects,
                selectedProjectId: projectId,
              ),
              const Divider(height: 1, color: CodeOpsColors.border),
              // Bottom: Tabbed vulnerability details
              _buildTabBar(),
              Expanded(
                child: _buildTabContent(projectId),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: CodeOpsColors.surface,
      child: TabBar(
        controller: _tabController,
        indicatorColor: CodeOpsColors.primary,
        labelColor: CodeOpsColors.textPrimary,
        unselectedLabelColor: CodeOpsColors.textTertiary,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        tabs: const [
          Tab(text: 'All Vulnerabilities'),
          Tab(text: 'CVE Alerts'),
          Tab(text: 'Update Plan'),
        ],
      ),
    );
  }

  Widget _buildTabContent(String projectId) {
    final scanAsync = ref.watch(latestScanProvider(projectId));

    return scanAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => const EmptyState(
        icon: Icons.inventory_2_outlined,
        title: 'No scan data',
        subtitle: 'Run a dependency scan to see results.',
      ),
      data: (scan) {
        final vulnsAsync =
            ref.watch(scanVulnerabilitiesProvider(scan.id));

        return vulnsAsync.when(
          loading: () =>
              const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(
            child: Text(
              'Error: $err',
              style: const TextStyle(color: CodeOpsColors.error),
            ),
          ),
          data: (vulnPage) {
            final vulns = vulnPage.content;

            return TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: All Vulnerabilities
                DepScanResults(
                  scanId: scan.id,
                  onStatusUpdate: (vuln, status) =>
                      _updateVulnStatus(vuln, status),
                ),
                // Tab 2: CVE Alerts
                CveAlertCard(
                  vulnerabilities: vulns,
                  onUpdate: (vuln) => _updateVulnStatus(
                    vuln,
                    VulnerabilityStatus.updating,
                  ),
                  onSuppress: (vuln) => _updateVulnStatus(
                    vuln,
                    VulnerabilityStatus.suppressed,
                  ),
                ),
                // Tab 3: Update Plan
                DepUpdateList(
                  vulnerabilities: vulns,
                  scan: scan,
                  onMarkResolved: (group) => _bulkResolve(group),
                  onExport: () => _exportUpdatePlan(scan, vulns),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _updateVulnStatus(
    DependencyVulnerability vuln,
    VulnerabilityStatus status,
  ) async {
    try {
      final api = ref.read(dependencyApiProvider);
      await api.updateVulnerabilityStatus(vuln.id, status);
      // Refresh data
      final projectId = ref.read(selectedProjectIdProvider);
      if (projectId != null) {
        ref.invalidate(latestScanProvider(projectId));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status: $e')),
        );
      }
    }
  }

  Future<void> _bulkResolve(List<DependencyVulnerability> group) async {
    try {
      final api = ref.read(dependencyApiProvider);
      for (final vuln in group) {
        await api.updateVulnerabilityStatus(
          vuln.id,
          VulnerabilityStatus.resolved,
        );
      }
      final projectId = ref.read(selectedProjectIdProvider);
      if (projectId != null) {
        ref.invalidate(latestScanProvider(projectId));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to resolve: $e')),
        );
      }
    }
  }

  void _exportUpdatePlan(
    DependencyScan scan,
    List<DependencyVulnerability> vulns,
  ) {
    final report = DependencyScanner.formatDepReport(scan, vulns);
    log.d('DependencyScanPage', 'Export plan generated (${report.length} chars)');
  }
}

// ---------------------------------------------------------------------------
// Scan Overview (Top section)
// ---------------------------------------------------------------------------

class _ScanOverview extends ConsumerWidget {
  final List<Project> projects;
  final String selectedProjectId;

  const _ScanOverview({
    required this.projects,
    required this.selectedProjectId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scanAsync = ref.watch(latestScanProvider(selectedProjectId));
    final healthAsync = ref.watch(depHealthScoreProvider(selectedProjectId));

    return Container(
      color: CodeOpsColors.surface,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Project selector + scan actions
          Row(
            children: [
              SizedBox(
                width: 250,
                child: DropdownButtonFormField<String>(
                  initialValue: selectedProjectId,
                  decoration: const InputDecoration(
                    labelText: 'Project',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  items: projects.map((p) {
                    return DropdownMenuItem(
                      value: p.id,
                      child: Text(p.name),
                    );
                  }).toList(),
                  onChanged: (id) {
                    if (id != null) {
                      ref.read(selectedProjectIdProvider.notifier).state = id;
                    }
                  },
                  dropdownColor: CodeOpsColors.surface,
                  style: const TextStyle(
                    fontSize: 13,
                    color: CodeOpsColors.textPrimary,
                  ),
                ),
              ),
              const Spacer(),
              OutlinedButton.icon(
                icon: const Icon(Icons.play_arrow, size: 16),
                label: const Text('Run Dependency Scan'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: CodeOpsColors.primary,
                  side: const BorderSide(color: CodeOpsColors.primary),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  textStyle: const TextStyle(fontSize: 12),
                ),
                onPressed: () => context.go('/audit'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Scan metadata + Health gauge + Summary cards
          scanAsync.when(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Text(
              'No scan data available',
              style: TextStyle(color: CodeOpsColors.textTertiary),
            ),
            data: (scan) {
              final vulnsAsync =
                  ref.watch(scanVulnerabilitiesProvider(scan.id));

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Scan metadata
                  Text(
                    '${scan.totalDependencies ?? 0} dependencies, '
                    '${scan.outdatedCount ?? 0} outdated, '
                    '${scan.vulnerableCount ?? 0} vulnerable',
                    style: const TextStyle(
                      fontSize: 13,
                      color: CodeOpsColors.textSecondary,
                    ),
                  ),
                  if (scan.createdAt != null)
                    Text(
                      'Last scanned: ${_formatDate(scan.createdAt!)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: CodeOpsColors.textTertiary,
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Health gauge + summary cards row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Health gauge
                      healthAsync.when(
                        loading: () => const SizedBox(
                          width: 100,
                          height: 100,
                          child: CircularProgressIndicator(),
                        ),
                        error: (_, __) => const DepHealthGauge(
                          score: 0,
                          size: 100,
                        ),
                        data: (score) => DepHealthGauge(
                          score: score,
                          size: 100,
                        ),
                      ),
                      const SizedBox(width: 24),

                      // Vulnerability severity summary
                      vulnsAsync.when(
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                        data: (vulnPage) {
                          final vulns = vulnPage.content;
                          final bySeverity =
                              DependencyScanner.groupBySeverity(vulns);
                          final byStatus =
                              DependencyScanner.groupByStatus(vulns);

                          return Expanded(
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _SummaryCard(
                                  label: 'Critical',
                                  count: bySeverity[Severity.critical]
                                          ?.length ??
                                      0,
                                  color: CodeOpsColors.critical,
                                ),
                                _SummaryCard(
                                  label: 'High',
                                  count:
                                      bySeverity[Severity.high]?.length ?? 0,
                                  color: CodeOpsColors.error,
                                ),
                                _SummaryCard(
                                  label: 'Medium',
                                  count: bySeverity[Severity.medium]
                                          ?.length ??
                                      0,
                                  color: CodeOpsColors.warning,
                                ),
                                _SummaryCard(
                                  label: 'Low',
                                  count:
                                      bySeverity[Severity.low]?.length ?? 0,
                                  color: CodeOpsColors.textTertiary,
                                ),
                                _SummaryCard(
                                  label: 'Open',
                                  count: byStatus[
                                              VulnerabilityStatus.open]
                                          ?.length ??
                                      0,
                                  color: CodeOpsColors.error,
                                ),
                                _SummaryCard(
                                  label: 'Updating',
                                  count: byStatus[
                                              VulnerabilityStatus.updating]
                                          ?.length ??
                                      0,
                                  color: const Color(0xFF3B82F6),
                                ),
                                _SummaryCard(
                                  label: 'Suppressed',
                                  count: byStatus[VulnerabilityStatus
                                              .suppressed]
                                          ?.length ??
                                      0,
                                  color: CodeOpsColors.textTertiary,
                                ),
                                _SummaryCard(
                                  label: 'Resolved',
                                  count: byStatus[
                                              VulnerabilityStatus.resolved]
                                          ?.length ??
                                      0,
                                  color: CodeOpsColors.success,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _SummaryCard({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
