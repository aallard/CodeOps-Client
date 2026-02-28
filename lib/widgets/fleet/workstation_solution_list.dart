/// Ordered solution list widget for the workstation profile detail page.
///
/// Displays solutions sorted by [startOrder] in a table with
/// add and remove actions. Shows env var overrides when present.
library;

import 'package:flutter/material.dart';

import '../../models/fleet_models.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';

/// Displays the ordered list of solutions in a workstation profile.
class WorkstationSolutionList extends StatelessWidget {
  /// The solutions to display, sorted by [startOrder].
  final List<FleetWorkstationSolution> solutions;

  /// Callback invoked when the user requests adding a solution.
  final VoidCallback onAdd;

  /// Callback invoked when the user requests removing a solution.
  final void Function(FleetWorkstationSolution solution) onRemove;

  /// Creates a [WorkstationSolutionList].
  const WorkstationSolutionList({
    super.key,
    required this.solutions,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final sorted = List<FleetWorkstationSolution>.from(solutions)
      ..sort(
          (a, b) => (a.startOrder ?? 999).compareTo(b.startOrder ?? 999));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Toolbar
        Row(
          children: [
            Text(
              'Solutions (${solutions.length})',
              style: CodeOpsTypography.titleMedium,
            ),
            const Spacer(),
            OutlinedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Solution'),
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
                'No solutions added yet',
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
                1: FlexColumnWidth(2), // Solution Name
                2: FlexColumnWidth(2), // Env Overrides
                3: FixedColumnWidth(50), // Remove
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
                    _HeaderCell('Solution'),
                    _HeaderCell('Env Overrides'),
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

  /// Builds a single solution row.
  TableRow _buildRow(FleetWorkstationSolution sol) {
    final hasOverrides = sol.overrideEnvVarsJson != null &&
        sol.overrideEnvVarsJson!.isNotEmpty &&
        sol.overrideEnvVarsJson != '{}';

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
            '${sol.startOrder ?? "\u2014"}',
            style: CodeOpsTypography.bodySmall,
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Text(
            sol.solutionProfileName ?? '\u2014',
            style: CodeOpsTypography.bodyMedium,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: hasOverrides
              ? Text(
                  sol.overrideEnvVarsJson!,
                  style: CodeOpsTypography.code.copyWith(fontSize: 11),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                )
              : Text(
                  '\u2014',
                  style: CodeOpsTypography.bodySmall
                      .copyWith(color: CodeOpsColors.textTertiary),
                ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          child: IconButton(
            icon: const Icon(Icons.remove_circle_outline, size: 16),
            color: CodeOpsColors.error,
            onPressed: () => onRemove(sol),
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
