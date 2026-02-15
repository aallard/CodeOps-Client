/// Specification list panel for compliance job reports.
///
/// Displays uploaded specifications with type badges, upload timestamps,
/// and download actions.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/enums.dart';
import '../../models/specification.dart';
import '../../providers/compliance_providers.dart';
import '../../theme/colors.dart';
import '../shared/error_panel.dart';
import '../shared/loading_overlay.dart';
import '../shared/notification_toast.dart';

/// Displays the list of specifications uploaded for a compliance job.
class SpecListPanel extends ConsumerWidget {
  /// The job UUID.
  final String jobId;

  /// Creates a [SpecListPanel].
  const SpecListPanel({super.key, required this.jobId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final specsAsync = ref.watch(complianceJobSpecsProvider(jobId));

    return specsAsync.when(
      loading: () =>
          const LoadingOverlay(message: 'Loading specifications...'),
      error: (e, _) => ErrorPanel.fromException(e,
          onRetry: () =>
              ref.invalidate(complianceJobSpecsProvider(jobId))),
      data: (specsPage) {
        if (specsPage.content.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.description_outlined,
                    size: 48, color: CodeOpsColors.textTertiary),
                SizedBox(height: 12),
                Text(
                  'No specifications uploaded',
                  style: TextStyle(
                    color: CodeOpsColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${specsPage.content.length} specification(s)',
                style: const TextStyle(
                  color: CodeOpsColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 12),

              // Spec table
              Container(
                decoration: BoxDecoration(
                  color: CodeOpsColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: CodeOpsColors.border),
                ),
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(
                    CodeOpsColors.surfaceVariant,
                  ),
                  columns: const [
                    DataColumn(
                      label: Text('Name',
                          style: TextStyle(
                              color: CodeOpsColors.textPrimary)),
                    ),
                    DataColumn(
                      label: Text('Type',
                          style: TextStyle(
                              color: CodeOpsColors.textPrimary)),
                    ),
                    DataColumn(
                      label: Text('Uploaded',
                          style: TextStyle(
                              color: CodeOpsColors.textPrimary)),
                    ),
                    DataColumn(
                      label: Text('Actions',
                          style: TextStyle(
                              color: CodeOpsColors.textPrimary)),
                    ),
                  ],
                  rows: specsPage.content
                      .map((spec) => _buildRow(context, ref, spec))
                      .toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  DataRow _buildRow(
      BuildContext context, WidgetRef ref, Specification spec) {
    return DataRow(cells: [
      DataCell(
        Text(
          spec.name,
          style: const TextStyle(
            color: CodeOpsColors.textPrimary,
            fontSize: 12,
          ),
        ),
      ),
      DataCell(_SpecTypeBadge(specType: spec.specType)),
      DataCell(
        Text(
          spec.createdAt != null
              ? _formatDate(spec.createdAt!)
              : 'N/A',
          style: const TextStyle(
            color: CodeOpsColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ),
      DataCell(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.download,
                  size: 16, color: CodeOpsColors.textSecondary),
              tooltip: 'Download',
              onPressed: () => _downloadSpec(context, ref, spec),
            ),
          ],
        ),
      ),
    ]);
  }

  void _downloadSpec(
      BuildContext context, WidgetRef ref, Specification spec) {
    showToast(context,
        message: 'Download started for ${spec.name}',
        type: ToastType.info);
    // Actual download via reportApi.downloadSpecReport would
    // be invoked here with a file save dialog.
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}

class _SpecTypeBadge extends StatelessWidget {
  final SpecType? specType;

  const _SpecTypeBadge({this.specType});

  @override
  Widget build(BuildContext context) {
    final color = switch (specType) {
      SpecType.openapi => CodeOpsColors.secondary,
      SpecType.markdown => CodeOpsColors.primary,
      SpecType.screenshot => CodeOpsColors.warning,
      SpecType.figma => const Color(0xFFF24E1E),
      null => CodeOpsColors.textTertiary,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        specType?.displayName ?? 'Unknown',
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
