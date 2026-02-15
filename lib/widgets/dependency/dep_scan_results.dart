/// Dependency scan results widget showing a filterable vulnerability data table.
///
/// Displays columns: Dependency, Current Version, Fixed Version, CVE ID,
/// Severity, Status, Actions. Supports search, severity/status filtering,
/// sorting, and pagination.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/dependency_scan.dart';
import '../../models/enums.dart';
import '../../providers/dependency_providers.dart';
import '../../theme/colors.dart';
import '../../utils/constants.dart';
import '../shared/empty_state.dart';

/// Color mapping for [Severity] badges.
const Map<Severity, Color> _sevColors = {
  Severity.critical: Color(0xFFDC2626),
  Severity.high: Color(0xFFF97316),
  Severity.medium: Color(0xFFFBBF24),
  Severity.low: Color(0xFF64748B),
};

/// Color mapping for [VulnerabilityStatus] badges.
const Map<VulnerabilityStatus, Color> _statusColors = {
  VulnerabilityStatus.open: Color(0xFFEF4444),
  VulnerabilityStatus.updating: Color(0xFF3B82F6),
  VulnerabilityStatus.suppressed: Color(0xFF64748B),
  VulnerabilityStatus.resolved: Color(0xFF4ADE80),
};

/// Filterable, paginated data table of vulnerabilities.
///
/// Renders all columns from the spec: dependency name, current/fixed version,
/// CVE ID (tappable), severity badge, status badge, and action dropdown.
class DepScanResults extends ConsumerStatefulWidget {
  /// Scan ID to load vulnerabilities for.
  final String scanId;

  /// Callback when a vulnerability status is updated.
  final void Function(DependencyVulnerability vuln, VulnerabilityStatus status)?
      onStatusUpdate;

  /// Creates a [DepScanResults].
  const DepScanResults({
    super.key,
    required this.scanId,
    this.onStatusUpdate,
  });

  @override
  ConsumerState<DepScanResults> createState() => _DepScanResultsState();
}

class _DepScanResultsState extends ConsumerState<DepScanResults> {
  final _searchController = TextEditingController();
  int _currentPage = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredAsync =
        ref.watch(filteredVulnerabilitiesProvider(widget.scanId));

    return Column(
      children: [
        _buildFilters(),
        const Divider(height: 1, color: CodeOpsColors.border),
        Expanded(
          child: filteredAsync.when(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(
              child: Text(
                'Error: $err',
                style: const TextStyle(color: CodeOpsColors.error),
              ),
            ),
            data: (vulns) {
              if (vulns.isEmpty) {
                return const EmptyState(
                  icon: Icons.shield_outlined,
                  title: 'No vulnerabilities',
                  subtitle: 'No vulnerabilities match the current filters.',
                );
              }

              final pageSize = AppConstants.defaultPageSize;
              final totalPages = (vulns.length / pageSize).ceil();
              final pageItems = vulns
                  .skip(_currentPage * pageSize)
                  .take(pageSize)
                  .toList();

              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowHeight: 36,
                        dataRowMinHeight: 40,
                        dataRowMaxHeight: 56,
                        columnSpacing: 16,
                        columns: const [
                          DataColumn(label: Text('Dependency')),
                          DataColumn(label: Text('Current')),
                          DataColumn(label: Text('Fixed')),
                          DataColumn(label: Text('CVE ID')),
                          DataColumn(label: Text('Severity')),
                          DataColumn(label: Text('Status')),
                          DataColumn(label: Text('Actions')),
                        ],
                        rows: pageItems.map((vuln) {
                          return DataRow(cells: [
                            DataCell(Text(
                              vuln.dependencyName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            )),
                            DataCell(Text(
                              vuln.currentVersion ?? '—',
                              style: const TextStyle(fontSize: 13),
                            )),
                            DataCell(Text(
                              vuln.fixedVersion ?? '—',
                              style: TextStyle(
                                fontSize: 13,
                                color: vuln.fixedVersion != null
                                    ? CodeOpsColors.success
                                    : CodeOpsColors.textTertiary,
                              ),
                            )),
                            DataCell(
                              vuln.cveId != null
                                  ? InkWell(
                                      onTap: () => _openCve(vuln.cveId!),
                                      child: Text(
                                        vuln.cveId!,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: CodeOpsColors.secondary,
                                          decoration:
                                              TextDecoration.underline,
                                        ),
                                      ),
                                    )
                                  : const Text(
                                      '—',
                                      style: TextStyle(fontSize: 13),
                                    ),
                            ),
                            DataCell(_badge(
                              vuln.severity.displayName,
                              _sevColors[vuln.severity]!,
                            )),
                            DataCell(_badge(
                              vuln.status.displayName,
                              _statusColors[vuln.status]!,
                            )),
                            DataCell(_buildActionDropdown(vuln)),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ),
                  if (totalPages > 1)
                    _buildPagination(totalPages),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: CodeOpsColors.surface,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          SizedBox(
            width: 200,
            height: 36,
            child: TextField(
              controller: _searchController,
              style: const TextStyle(
                fontSize: 13,
                color: CodeOpsColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Search dependency or CVE...',
                hintStyle: const TextStyle(
                  color: CodeOpsColors.textTertiary,
                  fontSize: 13,
                ),
                prefixIcon: const Icon(Icons.search, size: 16),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: CodeOpsColors.border),
                ),
              ),
              onChanged: (value) {
                ref.read(vulnSearchQueryProvider.notifier).state = value;
              },
            ),
          ),
          _buildDropdown<Severity?>(
            value: ref.watch(vulnSeverityFilterProvider),
            hint: 'Severity',
            items: [
              const DropdownMenuItem(value: null, child: Text('All')),
              ...Severity.values.map(
                (s) => DropdownMenuItem(
                  value: s,
                  child: Text(s.displayName),
                ),
              ),
            ],
            onChanged: (v) =>
                ref.read(vulnSeverityFilterProvider.notifier).state = v,
          ),
          _buildDropdown<VulnerabilityStatus?>(
            value: ref.watch(vulnStatusFilterProvider),
            hint: 'Status',
            items: [
              const DropdownMenuItem(value: null, child: Text('All')),
              ...VulnerabilityStatus.values.map(
                (s) => DropdownMenuItem(
                  value: s,
                  child: Text(s.displayName),
                ),
              ),
            ],
            onChanged: (v) =>
                ref.read(vulnStatusFilterProvider.notifier).state = v,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T value,
    required String hint,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return SizedBox(
      height: 36,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(
            hint,
            style: const TextStyle(
              fontSize: 13,
              color: CodeOpsColors.textTertiary,
            ),
          ),
          items: items,
          onChanged: onChanged,
          style: const TextStyle(
            fontSize: 13,
            color: CodeOpsColors.textPrimary,
          ),
          dropdownColor: CodeOpsColors.surface,
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildActionDropdown(DependencyVulnerability vuln) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<VulnerabilityStatus>(
        hint: const Text(
          'Update',
          style: TextStyle(fontSize: 12, color: CodeOpsColors.textTertiary),
        ),
        items: VulnerabilityStatus.values
            .where((s) => s != vuln.status)
            .map(
              (s) => DropdownMenuItem(
                value: s,
                child: Text(s.displayName, style: const TextStyle(fontSize: 12)),
              ),
            )
            .toList(),
        onChanged: (newStatus) {
          if (newStatus != null) {
            widget.onStatusUpdate?.call(vuln, newStatus);
          }
        },
        style: const TextStyle(fontSize: 12, color: CodeOpsColors.textPrimary),
        dropdownColor: CodeOpsColors.surface,
        isDense: true,
      ),
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _openCve(String cveId) {
    final url = Uri.parse('https://nvd.nist.gov/vuln/detail/$cveId');
    launchUrl(url, mode: LaunchMode.externalApplication);
  }

  Widget _buildPagination(int totalPages) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, size: 18),
            onPressed: _currentPage > 0
                ? () => setState(() => _currentPage--)
                : null,
          ),
          Text(
            'Page ${_currentPage + 1} of $totalPages',
            style: const TextStyle(
              fontSize: 13,
              color: CodeOpsColors.textSecondary,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, size: 18),
            onPressed: _currentPage < totalPages - 1
                ? () => setState(() => _currentPage++)
                : null,
          ),
        ],
      ),
    );
  }
}
