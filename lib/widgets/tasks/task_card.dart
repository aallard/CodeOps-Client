/// Compact card widget for displaying a remediation task in a list.
///
/// Shows priority dot, task number, title, status chip, and optional
/// Jira badge. Supports selection state via checkbox and active
/// highlight via accent left border.
library;

import 'package:flutter/material.dart';

import '../../models/enums.dart';
import '../../models/remediation_task.dart';
import '../../theme/colors.dart';

/// A compact card representing a single [RemediationTask].
class TaskCard extends StatelessWidget {
  /// The task to display.
  final RemediationTask task;

  /// Whether the card is selected (checkbox checked).
  final bool isSelected;

  /// Whether the card is the active/detail task.
  final bool isActive;

  /// Called when the card body is tapped.
  final VoidCallback? onTap;

  /// Called when the selection checkbox changes.
  final ValueChanged<bool?>? onCheckboxChanged;

  /// Creates a [TaskCard].
  const TaskCard({
    super.key,
    required this.task,
    this.isSelected = false,
    this.isActive = false,
    this.onTap,
    this.onCheckboxChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? CodeOpsColors.primary.withValues(alpha: 0.08)
              : CodeOpsColors.surface,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isActive ? CodeOpsColors.primary : CodeOpsColors.border,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Selection checkbox.
            if (onCheckboxChanged != null)
              SizedBox(
                width: 20,
                height: 20,
                child: Checkbox(
                  value: isSelected,
                  onChanged: onCheckboxChanged,
                  activeColor: CodeOpsColors.primary,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            if (onCheckboxChanged != null) const SizedBox(width: 8),

            // Priority dot.
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: _priorityColor(task.priority),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),

            // Task number.
            Text(
              '#${task.taskNumber}',
              style: const TextStyle(
                color: CodeOpsColors.textTertiary,
                fontSize: 11,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(width: 10),

            // Title.
            Expanded(
              child: Text(
                task.title,
                style: const TextStyle(
                  color: CodeOpsColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),

            // Jira badge.
            if (task.jiraKey != null) ...[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: CodeOpsColors.secondary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  task.jiraKey!,
                  style: const TextStyle(
                    color: CodeOpsColors.secondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],

            // Status chip.
            _StatusChip(status: task.status),
          ],
        ),
      ),
    );
  }

  /// Returns the color for a given priority level.
  static Color _priorityColor(Priority? priority) {
    return switch (priority) {
      Priority.p0 => CodeOpsColors.critical,
      Priority.p1 => CodeOpsColors.error,
      Priority.p2 => CodeOpsColors.warning,
      Priority.p3 => CodeOpsColors.secondary,
      null => CodeOpsColors.textTertiary,
    };
  }
}

class _StatusChip extends StatelessWidget {
  final TaskStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static Color _statusColor(TaskStatus status) {
    return switch (status) {
      TaskStatus.pending => CodeOpsColors.textTertiary,
      TaskStatus.assigned => CodeOpsColors.primary,
      TaskStatus.exported => CodeOpsColors.warning,
      TaskStatus.jiraCreated => CodeOpsColors.secondary,
      TaskStatus.completed => CodeOpsColors.success,
    };
  }
}
