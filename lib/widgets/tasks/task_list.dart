/// Scrollable task card list widget with select-all header.
///
/// Renders a list of [RemediationTask] items as [TaskCard] widgets
/// with a select-all checkbox header, count badge, empty state,
/// loading state, and optional "load more" support.
library;

import 'package:flutter/material.dart';

import '../../models/remediation_task.dart';
import '../../theme/colors.dart';
import '../shared/empty_state.dart';
import 'task_card.dart';

/// A scrollable list of task cards with selection support.
class TaskListWidget extends StatelessWidget {
  /// The tasks to display.
  final List<RemediationTask> tasks;

  /// The currently active (detail-panel) task, if any.
  final RemediationTask? activeTask;

  /// The set of selected task IDs.
  final Set<String> selectedIds;

  /// Called when a task card is tapped.
  final ValueChanged<RemediationTask>? onTaskTap;

  /// Called when the selection set changes.
  final ValueChanged<Set<String>>? onSelectionChanged;

  /// Whether the list is loading.
  final bool isLoading;

  /// Creates a [TaskListWidget].
  const TaskListWidget({
    super.key,
    required this.tasks,
    this.activeTask,
    this.selectedIds = const {},
    this.onTaskTap,
    this.onSelectionChanged,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: CodeOpsColors.primary),
      );
    }

    if (tasks.isEmpty) {
      return const EmptyState(
        icon: Icons.task_alt,
        title: 'No Tasks',
        subtitle: 'No tasks match the current filters.',
      );
    }

    final allSelected =
        tasks.isNotEmpty && tasks.every((t) => selectedIds.contains(t.id));

    return Column(
      children: [
        // Select-all header.
        if (onSelectionChanged != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: Checkbox(
                    value: allSelected,
                    onChanged: (v) {
                      if (v == true) {
                        onSelectionChanged!(tasks.map((t) => t.id).toSet());
                      } else {
                        onSelectionChanged!({});
                      }
                    },
                    activeColor: CodeOpsColors.primary,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${tasks.length} task${tasks.length == 1 ? '' : 's'}',
                  style: const TextStyle(
                    color: CodeOpsColors.textTertiary,
                    fontSize: 12,
                  ),
                ),
                if (selectedIds.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: CodeOpsColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${selectedIds.length} selected',
                      style: const TextStyle(
                        color: CodeOpsColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

        // Task cards.
        Expanded(
          child: ListView.separated(
            itemCount: tasks.length,
            separatorBuilder: (_, __) => const SizedBox(height: 6),
            itemBuilder: (context, index) {
              final task = tasks[index];
              return TaskCard(
                task: task,
                isSelected: selectedIds.contains(task.id),
                isActive: activeTask?.id == task.id,
                onTap: () => onTaskTap?.call(task),
                onCheckboxChanged: onSelectionChanged != null
                    ? (v) {
                        final updated = Set<String>.from(selectedIds);
                        if (v == true) {
                          updated.add(task.id);
                        } else {
                          updated.remove(task.id);
                        }
                        onSelectionChanged!(updated);
                      }
                    : null,
              );
            },
          ),
        ),
      ],
    );
  }
}
