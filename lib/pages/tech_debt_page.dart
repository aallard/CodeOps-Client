/// Tech Debt page (Mode 5) — three-column layout.
///
/// Left: summary panel (project selector, debt score gauge, status summary,
/// category breakdown, resolution rate, quick actions).
/// Center: debt inventory (filterable, paginated list).
/// Right: detail panel (selected item detail, status workflow, related actions).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/enums.dart';
import '../services/logging/log_service.dart';
import '../models/project.dart';
import '../models/tech_debt_item.dart';
import '../providers/project_providers.dart';
import '../providers/tech_debt_providers.dart';
import '../services/analysis/tech_debt_tracker.dart';
import '../theme/colors.dart';
import '../widgets/shared/confirm_dialog.dart';
import '../widgets/shared/empty_state.dart';
import '../widgets/tech_debt/debt_category_breakdown.dart';
import '../widgets/tech_debt/debt_inventory.dart';

/// The Tech Debt tracking page.
///
/// Route: `/tech-debt`
/// Navigation: "Maintain" sidebar section.
class TechDebtPage extends ConsumerStatefulWidget {
  /// Creates a [TechDebtPage].
  const TechDebtPage({super.key});

  @override
  ConsumerState<TechDebtPage> createState() => _TechDebtPageState();
}

class _TechDebtPageState extends ConsumerState<TechDebtPage> {
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
            'Error loading projects: $err',
            style: const TextStyle(color: CodeOpsColors.error),
          ),
        ),
        data: (projects) {
          if (projects.isEmpty) {
            return const EmptyState(
              icon: Icons.folder_off_outlined,
              title: 'No projects',
              subtitle: 'Create a project first to track tech debt.',
            );
          }

          // Auto-select first project if none selected
          final projectId = selectedProjectId ?? projects.first.id;

          return Row(
            children: [
              // Left column (25%) — Summary
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.20,
                child: _SummaryPanel(
                  projects: projects,
                  selectedProjectId: projectId,
                ),
              ),
              const VerticalDivider(width: 1, color: CodeOpsColors.border),
              // Center column (50%) — Inventory
              Expanded(
                flex: 2,
                child: DebtInventory(
                  projectId: projectId,
                  onItemSelected: (item) {
                    ref.read(selectedTechDebtItemProvider.notifier).state =
                        item;
                  },
                  onDelete: (item) => _deleteItem(item),
                  onStatusUpdate: (item, status) =>
                      _updateStatus(item, status),
                ),
              ),
              const VerticalDivider(width: 1, color: CodeOpsColors.border),
              // Right column (25%) — Detail
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.20,
                child: const _DetailPanel(),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _deleteItem(TechDebtItem item) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete Tech Debt Item',
      message: 'Are you sure you want to delete "${item.title}"?',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (confirmed != true || !mounted) return;

    try {
      final api = ref.read(techDebtApiProvider);
      await api.deleteTechDebtItem(item.id);
      ref.read(selectedTechDebtItemProvider.notifier).state = null;
      final projectId = ref.read(selectedProjectIdProvider);
      if (projectId != null) {
        ref.invalidate(projectTechDebtProvider(projectId));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete: $e')),
        );
      }
    }
  }

  Future<void> _updateStatus(TechDebtItem item, DebtStatus status) async {
    try {
      final api = ref.read(techDebtApiProvider);
      final updated =
          await api.updateTechDebtStatus(item.id, status: status);
      ref.read(selectedTechDebtItemProvider.notifier).state = updated;
      final projectId = ref.read(selectedProjectIdProvider);
      if (projectId != null) {
        ref.invalidate(projectTechDebtProvider(projectId));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status: $e')),
        );
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Summary Panel (Left)
// ---------------------------------------------------------------------------

class _SummaryPanel extends ConsumerWidget {
  final List<Project> projects;
  final String selectedProjectId;

  const _SummaryPanel({
    required this.projects,
    required this.selectedProjectId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debtAsync =
        ref.watch(filteredTechDebtProvider(selectedProjectId));

    return Container(
      color: CodeOpsColors.surface,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // Project selector
          DropdownButtonFormField<String>(
            initialValue: selectedProjectId,
            decoration: const InputDecoration(
              labelText: 'Project',
              isDense: true,
              border: OutlineInputBorder(),
            ),
            items: projects.map((p) {
              return DropdownMenuItem(value: p.id, child: Text(p.name));
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
          const SizedBox(height: 16),

          // Debt score, status summary, category breakdown
          debtAsync.when(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (err, _) => Text(
              'Error: $err',
              style: const TextStyle(color: CodeOpsColors.error),
            ),
            data: (items) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Debt Score
                _DebtScoreGauge(items: items),
                const SizedBox(height: 16),
                // Status Summary
                _StatusSummary(items: items),
                const SizedBox(height: 16),
                // Category Breakdown
                DebtCategoryBreakdown(items: items),
                const SizedBox(height: 12),
                // Resolution Rate
                Text(
                  '${TechDebtTracker.computeResolutionRate(items).toStringAsFixed(1)}% of items resolved',
                  style: const TextStyle(
                    fontSize: 13,
                    color: CodeOpsColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          // Quick actions
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: CodeOpsColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.play_arrow, size: 16),
            label: const Text('Run Tech Debt Scan'),
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
          const SizedBox(height: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.download, size: 16),
            label: const Text('Export Debt Report'),
            style: OutlinedButton.styleFrom(
              foregroundColor: CodeOpsColors.textSecondary,
              side: const BorderSide(color: CodeOpsColors.border),
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              textStyle: const TextStyle(fontSize: 12),
            ),
            onPressed: () => _exportReport(ref),
          ),
        ],
      ),
    );
  }

  void _exportReport(WidgetRef ref) {
    final items =
        ref.read(filteredTechDebtProvider(selectedProjectId)).valueOrNull;
    final summary =
        ref.read(debtSummaryProvider(selectedProjectId)).valueOrNull;
    if (items != null) {
      final report =
          TechDebtTracker.formatDebtReport(items, summary ?? {});
      log.d('TechDebtPage', 'Report generated (${report.length} chars)');
    }
  }
}

class _DebtScoreGauge extends StatelessWidget {
  final List<TechDebtItem> items;

  const _DebtScoreGauge({required this.items});

  @override
  Widget build(BuildContext context) {
    final score = TechDebtTracker.computeDebtScore(items);
    final color = score <= 30
        ? CodeOpsColors.success
        : score <= 60
            ? CodeOpsColors.warning
            : CodeOpsColors.error;

    return Column(
      children: [
        SizedBox(
          width: 100,
          height: 100,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: (score / 100).clamp(0, 1).toDouble(),
                  strokeWidth: 8,
                  backgroundColor: CodeOpsColors.border,
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
              Text(
                '$score',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Debt Score: $score',
          style: const TextStyle(
            fontSize: 13,
            color: CodeOpsColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _StatusSummary extends StatelessWidget {
  final List<TechDebtItem> items;

  const _StatusSummary({required this.items});

  @override
  Widget build(BuildContext context) {
    final byStatus = TechDebtTracker.computeDebtByStatus(items);
    final total = items.isEmpty ? 1 : items.length;

    final statusColors = {
      DebtStatus.identified: const Color(0xFFF97316),
      DebtStatus.planned: const Color(0xFF3B82F6),
      DebtStatus.inProgress: const Color(0xFFA855F7),
      DebtStatus.resolved: const Color(0xFF4ADE80),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Status Summary',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: CodeOpsColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        ...byStatus.entries.map((entry) {
          final pct = entry.value / total;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key.displayName,
                      style: const TextStyle(
                        fontSize: 12,
                        color: CodeOpsColors.textSecondary,
                      ),
                    ),
                    Text(
                      '${entry.value} (${(pct * 100).round()}%)',
                      style: const TextStyle(
                        fontSize: 12,
                        color: CodeOpsColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                LinearProgressIndicator(
                  value: pct,
                  backgroundColor: CodeOpsColors.border,
                  valueColor: AlwaysStoppedAnimation(
                    statusColors[entry.key] ?? CodeOpsColors.primary,
                  ),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Detail Panel (Right)
// ---------------------------------------------------------------------------

class _DetailPanel extends ConsumerWidget {
  const _DetailPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final item = ref.watch(selectedTechDebtItemProvider);

    if (item == null) {
      return const EmptyState(
        icon: Icons.info_outline,
        title: 'Select a tech debt item',
        subtitle: 'Click an item to view details.',
      );
    }

    return Container(
      color: CodeOpsColors.surface,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // Title
          Text(
            item.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: CodeOpsColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          // Description
          if (item.description != null) ...[
            Text(
              item.description!,
              style: const TextStyle(
                fontSize: 13,
                color: CodeOpsColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
          ],
          // File path
          if (item.filePath != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: CodeOpsColors.background,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                item.filePath!,
                style: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'monospace',
                  color: CodeOpsColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          // Metadata
          _metaRow('Category', item.category.displayName),
          _metaRow('Status', item.status.displayName),
          _metaRow(
            'Effort',
            item.effortEstimate?.displayName ?? 'Not set',
          ),
          _metaRow(
            'Impact',
            item.businessImpact?.displayName ?? 'Not set',
          ),
          if (item.createdAt != null)
            _metaRow('Created', _formatDate(item.createdAt!)),
          if (item.updatedAt != null)
            _metaRow('Updated', _formatDate(item.updatedAt!)),
          if (item.firstDetectedJobId != null)
            _metaRow('Detected by', item.firstDetectedJobId!.substring(0, 8)),
          const SizedBox(height: 16),
          // Status workflow buttons
          const Text(
            'Actions',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: CodeOpsColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          _buildStatusButtons(context, ref, item),
          const SizedBox(height: 16),
          // Related actions
          OutlinedButton.icon(
            icon: const Icon(Icons.source, size: 16),
            label: const Text('View Source Job'),
            style: OutlinedButton.styleFrom(
              foregroundColor: CodeOpsColors.textSecondary,
              side: const BorderSide(color: CodeOpsColors.border),
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              textStyle: const TextStyle(fontSize: 12),
            ),
            onPressed: item.firstDetectedJobId != null
                ? () => context.go('/jobs/${item.firstDetectedJobId}/report')
                : null,
          ),
        ],
      ),
    );
  }

  Widget _metaRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: CodeOpsColors.textTertiary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: CodeOpsColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusButtons(
    BuildContext context,
    WidgetRef ref,
    TechDebtItem item,
  ) {
    switch (item.status) {
      case DebtStatus.identified:
        return Wrap(
          spacing: 8,
          children: [
            _actionBtn(
              'Plan',
              Icons.event_note,
              CodeOpsColors.primary,
              () => _update(ref, item, DebtStatus.planned),
            ),
            _actionBtn(
              'Start',
              Icons.play_arrow,
              CodeOpsColors.warning,
              () => _update(ref, item, DebtStatus.inProgress),
            ),
          ],
        );
      case DebtStatus.planned:
        return Wrap(
          spacing: 8,
          children: [
            _actionBtn(
              'Start',
              Icons.play_arrow,
              CodeOpsColors.warning,
              () => _update(ref, item, DebtStatus.inProgress),
            ),
            _actionBtn(
              'Back to Identified',
              Icons.undo,
              CodeOpsColors.textTertiary,
              () => _update(ref, item, DebtStatus.identified),
            ),
          ],
        );
      case DebtStatus.inProgress:
        return Wrap(
          spacing: 8,
          children: [
            _actionBtn(
              'Resolve',
              Icons.check_circle,
              CodeOpsColors.success,
              () => _update(ref, item, DebtStatus.resolved),
            ),
            _actionBtn(
              'Back to Planned',
              Icons.undo,
              CodeOpsColors.textTertiary,
              () => _update(ref, item, DebtStatus.planned),
            ),
          ],
        );
      case DebtStatus.resolved:
        return _actionBtn(
          'Reopen',
          Icons.replay,
          CodeOpsColors.warning,
          () => _update(ref, item, DebtStatus.identified),
        );
    }
  }

  Widget _actionBtn(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return OutlinedButton.icon(
      icon: Icon(icon, size: 14),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color),
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        textStyle: const TextStyle(fontSize: 12),
      ),
      onPressed: onPressed,
    );
  }

  Future<void> _update(
    WidgetRef ref,
    TechDebtItem item,
    DebtStatus status,
  ) async {
    try {
      final api = ref.read(techDebtApiProvider);
      final updated =
          await api.updateTechDebtStatus(item.id, status: status);
      ref.read(selectedTechDebtItemProvider.notifier).state = updated;
      final projectId = ref.read(selectedProjectIdProvider);
      if (projectId != null) {
        ref.invalidate(projectTechDebtProvider(projectId));
      }
    } catch (e) {
      log.w('TechDebtPage', 'Failed to update status', e);
    }
  }

  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
