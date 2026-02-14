/// Job-scoped Task List page.
///
/// Master-detail layout with filter bar, bulk actions toolbar,
/// scrollable task list, and task detail side panel.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/enums.dart';
import '../models/remediation_task.dart';
import '../providers/job_providers.dart';
import '../providers/task_providers.dart';
import '../theme/colors.dart';
import '../widgets/shared/empty_state.dart';
import '../widgets/shared/error_panel.dart';
import '../widgets/tasks/jira_create_dialog.dart';
import '../widgets/tasks/task_detail.dart';
import '../widgets/tasks/task_export_dialog.dart';
import '../widgets/tasks/task_list.dart';

/// Task list page for a specific job.
class TaskListPage extends ConsumerStatefulWidget {
  /// The job UUID from the route.
  final String jobId;

  /// Creates a [TaskListPage].
  const TaskListPage({super.key, required this.jobId});

  @override
  ConsumerState<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends ConsumerState<TaskListPage> {
  RemediationTask? _activeTask;

  @override
  void initState() {
    super.initState();
    // Reset filter/selection state on page entry.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(taskFilterProvider.notifier).state = const TaskFilter();
      ref.read(selectedTaskIdsProvider.notifier).state = {};
    });
  }

  @override
  Widget build(BuildContext context) {
    final jobAsync = ref.watch(jobDetailProvider(widget.jobId));
    final tasksAsync = ref.watch(filteredJobTasksProvider(widget.jobId));
    final selectedIds = ref.watch(selectedTaskIdsProvider);
    final filter = ref.watch(taskFilterProvider);

    return Column(
      children: [
        // Header bar.
        _buildHeader(jobAsync),

        // Filter bar.
        _buildFilterBar(filter),

        // Bulk actions toolbar (when items selected).
        if (selectedIds.isNotEmpty) _buildBulkToolbar(selectedIds, tasksAsync),

        // Body: list + detail panel.
        Expanded(
          child: tasksAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: CodeOpsColors.primary),
            ),
            error: (error, _) => ErrorPanel.fromException(
              error,
              onRetry: () =>
                  ref.invalidate(jobTasksProvider(widget.jobId)),
            ),
            data: (tasks) {
              if (tasks.isEmpty && !filter.hasActiveFilters) {
                return const EmptyState(
                  icon: Icons.task_alt,
                  title: 'No Tasks Yet',
                  subtitle:
                      'Tasks will appear here once the job generates them.',
                );
              }

              return Row(
                children: [
                  // Task list (left).
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: TaskListWidget(
                        tasks: tasks,
                        activeTask: _activeTask,
                        selectedIds: selectedIds,
                        onTaskTap: (task) =>
                            setState(() => _activeTask = task),
                        onSelectionChanged: (ids) => ref
                            .read(selectedTaskIdsProvider.notifier)
                            .state = ids,
                      ),
                    ),
                  ),

                  // Detail panel (right).
                  if (_activeTask != null)
                    TaskDetailPanel(
                      task: _activeTask!,
                      jobId: widget.jobId,
                      onClose: () => setState(() => _activeTask = null),
                      onTaskUpdated: () {
                        ref.invalidate(
                            jobTasksProvider(widget.jobId));
                        setState(() => _activeTask = null);
                      },
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(AsyncValue jobAsync) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: CodeOpsColors.divider),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back,
                size: 18, color: CodeOpsColors.textSecondary),
            onPressed: () =>
                context.go('/jobs/${widget.jobId}/report'),
            tooltip: 'Back to report',
          ),
          const SizedBox(width: 8),
          Expanded(
            child: jobAsync.when(
              loading: () => const Text(
                'Tasks',
                style: TextStyle(
                  color: CodeOpsColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              error: (_, __) => const Text(
                'Tasks',
                style: TextStyle(
                  color: CodeOpsColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              data: (job) => Text(
                'Tasks — ${job.name ?? job.mode.displayName}',
                style: const TextStyle(
                  color: CodeOpsColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(TaskFilter filter) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Wrap(
        spacing: 10,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // Status filter chips.
          _buildFilterChip(
            label: 'All',
            isActive: filter.status == null,
            onTap: () => ref.read(taskFilterProvider.notifier).state =
                filter.copyWith(clearStatus: true),
          ),
          ...TaskStatus.values.map((status) => _buildFilterChip(
                label: status.displayName,
                isActive: filter.status == status,
                onTap: () => ref.read(taskFilterProvider.notifier).state =
                    filter.copyWith(status: status),
              )),
          const SizedBox(width: 8),

          // Priority filter.
          _buildPriorityDropdown(filter),

          // Search field.
          SizedBox(
            width: 200,
            height: 32,
            child: TextField(
              onChanged: (query) =>
                  ref.read(taskFilterProvider.notifier).state =
                      filter.copyWith(searchQuery: query),
              style: const TextStyle(
                color: CodeOpsColors.textPrimary,
                fontSize: 12,
              ),
              decoration: InputDecoration(
                hintText: 'Search tasks...',
                hintStyle: const TextStyle(
                  color: CodeOpsColors.textTertiary,
                  fontSize: 12,
                ),
                prefixIcon: const Icon(Icons.search,
                    size: 16, color: CodeOpsColors.textTertiary),
                prefixIconConstraints:
                    const BoxConstraints(minWidth: 32),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 8),
                filled: true,
                fillColor: CodeOpsColors.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Clear filters.
          if (filter.hasActiveFilters)
            TextButton.icon(
              onPressed: () =>
                  ref.read(taskFilterProvider.notifier).state =
                      const TaskFilter(),
              icon: const Icon(Icons.clear, size: 14),
              label: const Text('Clear'),
              style: TextButton.styleFrom(
                foregroundColor: CodeOpsColors.textTertiary,
                textStyle: const TextStyle(fontSize: 11),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? CodeOpsColors.primary.withValues(alpha: 0.15)
              : CodeOpsColors.surfaceVariant,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color:
                isActive ? CodeOpsColors.primary : CodeOpsColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive
                ? CodeOpsColors.primary
                : CodeOpsColors.textSecondary,
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityDropdown(TaskFilter filter) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: filter.priority != null
            ? CodeOpsColors.primary.withValues(alpha: 0.15)
            : CodeOpsColors.surfaceVariant,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: filter.priority != null
              ? CodeOpsColors.primary
              : CodeOpsColors.border,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Priority?>(
          value: filter.priority,
          hint: const Text(
            'Priority',
            style: TextStyle(
              color: CodeOpsColors.textSecondary,
              fontSize: 12,
            ),
          ),
          icon: const Icon(Icons.arrow_drop_down,
              size: 18, color: CodeOpsColors.textTertiary),
          dropdownColor: CodeOpsColors.surfaceVariant,
          style: const TextStyle(
            color: CodeOpsColors.textPrimary,
            fontSize: 12,
          ),
          items: [
            const DropdownMenuItem<Priority?>(
              value: null,
              child: Text(
                'All Priorities',
                style: TextStyle(
                  color: CodeOpsColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ),
            ...Priority.values.map((p) => DropdownMenuItem(
                  value: p,
                  child: Text(p.displayName),
                )),
          ],
          onChanged: (v) =>
              ref.read(taskFilterProvider.notifier).state = v == null
                  ? filter.copyWith(clearPriority: true)
                  : filter.copyWith(priority: v),
        ),
      ),
    );
  }

  Widget _buildBulkToolbar(
      Set<String> selectedIds, AsyncValue<List<RemediationTask>> tasksAsync) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      color: CodeOpsColors.primary.withValues(alpha: 0.08),
      child: Row(
        children: [
          Text(
            '${selectedIds.length} selected',
            style: const TextStyle(
              color: CodeOpsColors.primary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 16),
          OutlinedButton.icon(
            onPressed: () {
              final tasks = tasksAsync.valueOrNull
                      ?.where((t) => selectedIds.contains(t.id))
                      .toList() ??
                  [];
              if (tasks.isNotEmpty) {
                showJiraCreateTaskDialog(
                  context,
                  ref,
                  tasks: tasks,
                  jobId: widget.jobId,
                );
              }
            },
            icon: const Icon(Icons.add_task, size: 14),
            label: const Text('Create Jira Issues'),
            style: OutlinedButton.styleFrom(
              foregroundColor: CodeOpsColors.primary,
              side: const BorderSide(color: CodeOpsColors.primary),
              textStyle: const TextStyle(fontSize: 12),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: () {
              final tasks = tasksAsync.valueOrNull
                      ?.where((t) => selectedIds.contains(t.id))
                      .toList() ??
                  [];
              if (tasks.isNotEmpty) {
                showTaskExportDialog(context, tasks: tasks);
              }
            },
            icon: const Icon(Icons.file_download_outlined, size: 14),
            label: const Text('Export'),
            style: OutlinedButton.styleFrom(
              foregroundColor: CodeOpsColors.textSecondary,
              side: const BorderSide(color: CodeOpsColors.border),
              textStyle: const TextStyle(fontSize: 12),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () =>
                ref.read(selectedTaskIdsProvider.notifier).state = {},
            child: const Text(
              'Clear selection',
              style: TextStyle(
                color: CodeOpsColors.textTertiary,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
