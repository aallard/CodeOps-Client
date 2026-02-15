/// Gap analysis panel for compliance job reports.
///
/// Focused view of MISSING and PARTIAL compliance items grouped by
/// specification name with collapsible sections and Markdown export.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/compliance_item.dart';
import '../../models/enums.dart';
import '../../providers/compliance_providers.dart';
import '../../theme/colors.dart';
import '../shared/error_panel.dart';
import '../shared/loading_overlay.dart';
import '../shared/notification_toast.dart';

/// Displays MISSING and PARTIAL compliance items grouped by specification.
class GapAnalysisPanel extends ConsumerWidget {
  /// The job UUID.
  final String jobId;

  /// Creates a [GapAnalysisPanel].
  const GapAnalysisPanel({super.key, required this.jobId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(complianceJobItemsProvider(jobId));

    return itemsAsync.when(
      loading: () =>
          const LoadingOverlay(message: 'Loading gap analysis...'),
      error: (e, _) => ErrorPanel.fromException(e,
          onRetry: () =>
              ref.invalidate(complianceJobItemsProvider(jobId))),
      data: (itemsPage) {
        // Filter to only MISSING and PARTIAL items.
        final gaps = itemsPage.content
            .where((i) =>
                i.status == ComplianceStatus.missing ||
                i.status == ComplianceStatus.partial)
            .toList();

        if (gaps.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_outline,
                    size: 48, color: CodeOpsColors.success),
                SizedBox(height: 12),
                Text(
                  'No compliance gaps found',
                  style: TextStyle(
                    color: CodeOpsColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'All requirements are met.',
                  style: TextStyle(
                    color: CodeOpsColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          );
        }

        // Group by spec name.
        final grouped = <String, List<ComplianceItem>>{};
        for (final item in gaps) {
          final key = item.specName ?? 'Unspecified';
          grouped.putIfAbsent(key, () => []).add(item);
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gap summary
              Row(
                children: [
                  const Icon(Icons.warning_amber,
                      size: 20, color: CodeOpsColors.warning),
                  const SizedBox(width: 8),
                  Text(
                    '${gaps.length} compliance gap(s) found',
                    style: const TextStyle(
                      color: CodeOpsColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  OutlinedButton.icon(
                    onPressed: () =>
                        _exportGapReport(context, grouped),
                    icon: const Icon(Icons.content_copy, size: 14),
                    label: const Text('Copy as Markdown'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: CodeOpsColors.textSecondary,
                      side:
                          const BorderSide(color: CodeOpsColors.border),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Collapsible sections
              ...grouped.entries.map((entry) => _SpecGapSection(
                    specName: entry.key,
                    items: entry.value,
                  )),
            ],
          ),
        );
      },
    );
  }

  void _exportGapReport(
    BuildContext context,
    Map<String, List<ComplianceItem>> grouped,
  ) {
    final buffer = StringBuffer();
    buffer.writeln('# Compliance Gap Report\n');

    for (final entry in grouped.entries) {
      buffer.writeln('## ${entry.key}\n');
      for (final item in entry.value) {
        final statusLabel = item.status == ComplianceStatus.missing
            ? 'MISSING'
            : 'PARTIAL';
        buffer.writeln('- **[$statusLabel]** ${item.requirement}');
        if (item.evidence != null && item.evidence!.isNotEmpty) {
          buffer.writeln('  - Evidence: ${item.evidence}');
        }
        if (item.notes != null && item.notes!.isNotEmpty) {
          buffer.writeln('  - Notes: ${item.notes}');
        }
      }
      buffer.writeln();
    }

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    showToast(context,
        message: 'Gap report copied to clipboard', type: ToastType.success);
  }
}

class _SpecGapSection extends StatefulWidget {
  final String specName;
  final List<ComplianceItem> items;

  const _SpecGapSection({required this.specName, required this.items});

  @override
  State<_SpecGapSection> createState() => _SpecGapSectionState();
}

class _SpecGapSectionState extends State<_SpecGapSection> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: CodeOpsColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: CodeOpsColors.border),
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8)),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    _isExpanded
                        ? Icons.expand_less
                        : Icons.expand_more,
                    size: 18,
                    color: CodeOpsColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.specName,
                      style: const TextStyle(
                        color: CodeOpsColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: CodeOpsColors.warning.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${widget.items.length} gap(s)',
                      style: const TextStyle(
                        color: CodeOpsColors.warning,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Items
          if (_isExpanded)
            ...widget.items.map((item) => _GapItemTile(item: item)),
        ],
      ),
    );
  }
}

class _GapItemTile extends StatelessWidget {
  final ComplianceItem item;

  const _GapItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final statusColor = item.status == ComplianceStatus.missing
        ? CodeOpsColors.error
        : CodeOpsColors.warning;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: CodeOpsColors.border),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  item.status.displayName,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (item.agentType != null)
                Text(
                  item.agentType!.displayName,
                  style: const TextStyle(
                    color: CodeOpsColors.textTertiary,
                    fontSize: 10,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            item.requirement,
            style: const TextStyle(
              color: CodeOpsColors.textPrimary,
              fontSize: 12,
            ),
          ),
          if (item.evidence != null && item.evidence!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Evidence: ${item.evidence}',
              style: const TextStyle(
                color: CodeOpsColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
          if (item.notes != null && item.notes!.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              'Notes: ${item.notes}',
              style: const TextStyle(
                color: CodeOpsColors.textTertiary,
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
