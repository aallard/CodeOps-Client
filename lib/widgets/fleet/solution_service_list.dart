/// Ordered service list widget for the solution profile detail page.
///
/// Displays services sorted by [startOrder] in a table with
/// reorder handles, add, and remove actions.
library;

import 'package:flutter/material.dart';

import '../../models/fleet_models.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';

/// Displays the ordered list of services in a solution profile.
class SolutionServiceList extends StatelessWidget {
  /// The services to display, sorted by [startOrder].
  final List<FleetSolutionService> services;

  /// Callback invoked when the user requests adding a service.
  final VoidCallback onAdd;

  /// Callback invoked when the user requests removing a service.
  final void Function(FleetSolutionService service) onRemove;

  /// Creates a [SolutionServiceList].
  const SolutionServiceList({
    super.key,
    required this.services,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final sorted = List<FleetSolutionService>.from(services)
      ..sort((a, b) =>
          (a.startOrder ?? 999).compareTo(b.startOrder ?? 999));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Toolbar
        Row(
          children: [
            Text(
              'Services (${services.length})',
              style: CodeOpsTypography.titleMedium,
            ),
            const Spacer(),
            OutlinedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Service'),
              style: OutlinedButton.styleFrom(
                foregroundColor: CodeOpsColors.primary,
                side: const BorderSide(color: CodeOpsColors.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (sorted.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: CodeOpsColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: CodeOpsColors.border),
            ),
            child: const Center(
              child: Text(
                'No services added yet',
                style: TextStyle(color: CodeOpsColors.textSecondary),
              ),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: CodeOpsColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: CodeOpsColors.border),
            ),
            child: Table(
              columnWidths: const {
                0: FixedColumnWidth(60), // Order
                1: FlexColumnWidth(2), // Service Name
                2: FlexColumnWidth(1.5), // Image
                3: FixedColumnWidth(70), // Enabled
                4: FixedColumnWidth(50), // Remove
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                // Header
                TableRow(
                  decoration: BoxDecoration(
                    color: CodeOpsColors.surfaceVariant,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  children: const [
                    _HeaderCell('#'),
                    _HeaderCell('Service'),
                    _HeaderCell('Image'),
                    _HeaderCell('Enabled'),
                    _HeaderCell(''),
                  ],
                ),
                ...sorted.map(_buildRow),
              ],
            ),
          ),
      ],
    );
  }

  /// Builds a single service row.
  TableRow _buildRow(FleetSolutionService svc) {
    return TableRow(
      decoration: BoxDecoration(
        border: Border(
          bottom:
              BorderSide(color: CodeOpsColors.border.withValues(alpha: 0.5)),
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Text(
            '${svc.startOrder ?? "\u2014"}',
            style: CodeOpsTypography.bodySmall,
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Text(
            svc.serviceProfileName ?? '\u2014',
            style: CodeOpsTypography.bodyMedium,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Text(
            svc.imageName ?? '\u2014',
            style: CodeOpsTypography.code.copyWith(fontSize: 11),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Icon(
            svc.isEnabled == true
                ? Icons.check_circle
                : Icons.cancel,
            size: 16,
            color: svc.isEnabled == true
                ? CodeOpsColors.success
                : CodeOpsColors.textTertiary,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          child: IconButton(
            icon: const Icon(Icons.remove_circle_outline, size: 16),
            color: CodeOpsColors.error,
            onPressed: () => onRemove(svc),
            tooltip: 'Remove',
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
            style: IconButton.styleFrom(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ),
      ],
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String label;

  const _HeaderCell(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Text(label, style: CodeOpsTypography.labelMedium),
    );
  }
}
