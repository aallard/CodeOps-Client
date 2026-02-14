/// Task detail side panel widget.
///
/// Displays full task information including metadata, description,
/// prompt (collapsible markdown), and action buttons for assign,
/// Jira creation, export, and completion.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/enums.dart';
import '../../models/remediation_task.dart';
import '../../providers/task_providers.dart';
import '../../theme/colors.dart';
import '../../utils/date_utils.dart';
import '../reports/markdown_renderer.dart';
import '../shared/notification_toast.dart';

/// Detail panel for viewing a single [RemediationTask].
class TaskDetailPanel extends ConsumerStatefulWidget {
  /// The task to display.
  final RemediationTask task;

  /// The parent job ID.
  final String jobId;

  /// Called to close the panel.
  final VoidCallback? onClose;

  /// Called after the task is updated.
  final VoidCallback? onTaskUpdated;

  /// Creates a [TaskDetailPanel].
  const TaskDetailPanel({
    super.key,
    required this.task,
    required this.jobId,
    this.onClose,
    this.onTaskUpdated,
  });

  @override
  ConsumerState<TaskDetailPanel> createState() => _TaskDetailPanelState();
}

class _TaskDetailPanelState extends ConsumerState<TaskDetailPanel> {
  bool _promptExpanded = false;

  @override
  Widget build(BuildContext context) {
    final priorityColor = _priorityColor(widget.task.priority);

    return Container(
      width: 400,
      decoration: const BoxDecoration(
        color: CodeOpsColors.surface,
        border: Border(
          left: BorderSide(color: CodeOpsColors.border),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: CodeOpsColors.divider),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: priorityColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    widget.task.priority?.displayName ?? 'No Priority',
                    style: TextStyle(
                      color: priorityColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '#${widget.task.taskNumber}',
                  style: const TextStyle(
                    color: CodeOpsColors.textTertiary,
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.task.title,
                    style: const TextStyle(
                      color: CodeOpsColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (widget.onClose != null)
                  IconButton(
                    icon: const Icon(Icons.close,
                        size: 16, color: CodeOpsColors.textTertiary),
                    onPressed: widget.onClose,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                  ),
              ],
            ),
          ),

          // Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Metadata rows.
                  _DetailRow(
                      label: 'Status',
                      value: widget.task.status.displayName),
                  _DetailRow(
                      label: 'Task #',
                      value: '${widget.task.taskNumber}'),
                  if (widget.task.assignedToName != null)
                    _DetailRow(
                        label: 'Assignee',
                        value: widget.task.assignedToName!),
                  if (widget.task.jiraKey != null)
                    _DetailRow(
                        label: 'Jira Key', value: widget.task.jiraKey!),
                  if (widget.task.createdAt != null)
                    _DetailRow(
                        label: 'Created',
                        value: formatTimeAgo(widget.task.createdAt)),

                  const SizedBox(height: 12),
                  const Divider(color: CodeOpsColors.divider, height: 1),
                  const SizedBox(height: 12),

                  // Description.
                  if (widget.task.description != null) ...[
                    const Text(
                      'Description',
                      style: TextStyle(
                        color: CodeOpsColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    MarkdownRenderer(
                      content: widget.task.description!,
                      shrinkWrap: true,
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Prompt (collapsible).
                  if (widget.task.promptMd != null) ...[
                    InkWell(
                      onTap: () => setState(
                          () => _promptExpanded = !_promptExpanded),
                      child: Row(
                        children: [
                          Icon(
                            _promptExpanded
                                ? Icons.expand_less
                                : Icons.expand_more,
                            size: 16,
                            color: CodeOpsColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Remediation Prompt',
                            style: TextStyle(
                              color: CodeOpsColors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_promptExpanded) ...[
                      const SizedBox(height: 4),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: CodeOpsColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: MarkdownRenderer(
                          content: widget.task.promptMd!,
                          shrinkWrap: true,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                  ],

                  // Related findings.
                  if (widget.task.findingIds != null &&
                      widget.task.findingIds!.isNotEmpty) ...[
                    const Divider(color: CodeOpsColors.divider, height: 1),
                    const SizedBox(height: 12),
                    Text(
                      'Related Findings (${widget.task.findingIds!.length})',
                      style: const TextStyle(
                        color: CodeOpsColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: widget.task.findingIds!.map((id) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: CodeOpsColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                                color: CodeOpsColors.border, width: 1),
                          ),
                          child: Text(
                            id.substring(0, 8),
                            style: const TextStyle(
                              color: CodeOpsColors.textTertiary,
                              fontSize: 10,
                              fontFamily: 'monospace',
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Actions footer.
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: CodeOpsColors.divider),
              ),
            ),
            child: Row(
              children: [
                // Copy prompt.
                if (widget.task.promptMd != null)
                  _ActionButton(
                    icon: Icons.copy,
                    label: 'Copy Prompt',
                    onTap: () {
                      Clipboard.setData(
                          ClipboardData(text: widget.task.promptMd!));
                      showToast(context,
                          message: 'Prompt copied to clipboard.',
                          type: ToastType.success);
                    },
                  ),
                const Spacer(),
                // Mark complete.
                if (widget.task.status != TaskStatus.completed)
                  _ActionButton(
                    icon: Icons.check_circle_outline,
                    label: 'Complete',
                    color: CodeOpsColors.success,
                    onTap: () => _markComplete(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _markComplete() async {
    try {
      final taskApi = ref.read(taskApiProvider);
      await taskApi.updateTask(widget.task.id, status: TaskStatus.completed);
      ref.invalidate(jobTasksProvider(widget.jobId));
      ref.invalidate(myTasksProvider);
      widget.onTaskUpdated?.call();
      if (mounted) {
        showToast(context,
            message: 'Task #${widget.task.taskNumber} marked complete.',
            type: ToastType.success);
      }
    } catch (e) {
      if (mounted) {
        showToast(context,
            message: 'Failed to update task: $e', type: ToastType.error);
      }
    }
  }

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

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(
                color: CodeOpsColors.textTertiary,
                fontSize: 11,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: CodeOpsColors.textPrimary,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color? color;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? CodeOpsColors.textSecondary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: c),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
