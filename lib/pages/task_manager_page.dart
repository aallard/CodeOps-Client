/// Global Task Manager page.
///
/// Tabbed view with "My Tasks" (from [filteredMyTasksProvider]) and
/// "By Job" (recent jobs linking to `/jobs/:id/tasks`). Provides
/// the same filter bar and master-detail layout as [TaskListPage].
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/enums.dart';
import '../models/remediation_task.dart';
import '../providers/task_providers.dart';
import '../providers/wizard_providers.dart';
import '../theme/colors.dart';
import '../widgets/shared/empty_state.dart';
import '../widgets/shared/error_panel.dart';
import '../widgets/tasks/task_detail.dart';
import '../widgets/tasks/task_export_dialog.dart';
import '../widgets/tasks/task_list.dart';

/// Global task manager with "My Tasks" and "By Job" tabs.
class TaskManagerPage extends ConsumerStatefulWidget {
  /// Creates a [TaskManagerPage].
  const TaskManagerPage({super.key});

  @override
  ConsumerState<TaskManagerPage> createState() => _TaskManagerPageState();
}

class _TaskManagerPageState extends ConsumerState<TaskManagerPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  RemediationTask? _activeTask;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Reset filter/selection state on page entry.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(taskFilterProvider.notifier).state = const TaskFilter();
      ref.read(selectedTaskIdsProvider.notifier).state = {};
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedIds = ref.watch(selectedTaskIdsProvider);
    final filter = ref.watch(taskFilterProvider);

    return Column(
      children: [
        // Header.
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: CodeOpsColors.divider),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.task_alt,
                  size: 20, color: CodeOpsColors.primary),
              const SizedBox(width: 10),
              const Text(
                'Task Manager',
                style: TextStyle(
                  color: CodeOpsColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              // Tab bar.
              SizedBox(
                width: 240,
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: CodeOpsColors.primary,
                  labelColor: CodeOpsColors.primary,
                  unselectedLabelColor: CodeOpsColors.textSecondary,
                  labelStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  tabs: const [
                    Tab(text: 'My Tasks'),
                    Tab(text: 'By Job'),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Filter bar (only for My Tasks tab).
        AnimatedBuilder(
          animation: _tabController,
          builder: (context, _) {
            if (_tabController.index == 0) {
              return _buildFilterBar(filter);
            }
            return const SizedBox.shrink();
          },
        ),

        // Bulk toolbar.
        if (selectedIds.isNotEmpty && _tabController.index == 0)
          _buildBulkToolbar(selectedIds),

        // Tab content.
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildMyTasksTab(),
              _buildByJobTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMyTasksTab() {
    final tasksAsync = ref.watch(filteredMyTasksProvider);
    final selectedIds = ref.watch(selectedTaskIdsProvider);

    return tasksAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: CodeOpsColors.primary),
      ),
      error: (error, _) => ErrorPanel.fromException(
        error,
        onRetry: () => ref.invalidate(myTasksProvider),
      ),
      data: (tasks) {
        if (tasks.isEmpty) {
          return const EmptyState(
            icon: Icons.task_alt,
            title: 'No Tasks Assigned',
            subtitle: 'Tasks assigned to you will appear here.',
          );
        }

        return Row(
          children: [
            // Task list.
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
                  onSelectionChanged: (ids) =>
                      ref.read(selectedTaskIdsProvider.notifier).state = ids,
                ),
              ),
            ),

            // Detail panel.
            if (_activeTask != null)
              TaskDetailPanel(
                task: _activeTask!,
                jobId: _activeTask!.jobId,
                onClose: () => setState(() => _activeTask = null),
                onTaskUpdated: () {
                  ref.invalidate(myTasksProvider);
                  setState(() => _activeTask = null);
                },
              ),
          ],
        );
      },
    );
  }

  Widget _buildByJobTab() {
    final jobsAsync = ref.watch(jobHistoryProvider);

    return jobsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: CodeOpsColors.primary),
      ),
      error: (error, _) => ErrorPanel.fromException(
        error,
        onRetry: () => ref.invalidate(jobHistoryProvider),
      ),
      data: (jobs) {
        if (jobs.isEmpty) {
          return const EmptyState(
            icon: Icons.work_outline,
            title: 'No Jobs Found',
            subtitle: 'Run an audit or investigation to generate tasks.',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: jobs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final job = jobs[index];
            return InkWell(
              onTap: () => context.go('/jobs/${job.id}/tasks'),
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: CodeOpsColors.surface,
                  borderRadius: BorderRadius.circular(6),
                  border:
                      Border.all(color: CodeOpsColors.border, width: 1),
                ),
                child: Row(
                  children: [
                    Icon(
                      _modeIcon(job.mode),
                      size: 18,
                      color: CodeOpsColors.textTertiary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job.name ?? job.mode.displayName,
                            style: const TextStyle(
                              color: CodeOpsColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (job.projectName != null)
                            Text(
                              job.projectName!,
                              style: const TextStyle(
                                color: CodeOpsColors.textTertiary,
                                fontSize: 11,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (job.overallResult != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _resultColor(job.overallResult!)
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          job.overallResult!.displayName,
                          style: TextStyle(
                            color: _resultColor(job.overallResult!),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right,
                        size: 16, color: CodeOpsColors.textTertiary),
                  ],
                ),
              ),
            );
          },
        );
      },
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

  Widget _buildBulkToolbar(Set<String> selectedIds) {
    final tasksAsync = ref.watch(filteredMyTasksProvider);

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

  IconData _modeIcon(JobMode mode) {
    return switch (mode) {
      JobMode.audit => Icons.security,
      JobMode.compliance => Icons.verified_user,
      JobMode.bugInvestigate => Icons.bug_report,
      JobMode.remediate => Icons.build,
      JobMode.techDebt => Icons.construction,
      JobMode.dependency => Icons.link,
      JobMode.healthMonitor => Icons.monitor_heart,
    };
  }

  Color _resultColor(JobResult result) {
    return switch (result) {
      JobResult.pass => CodeOpsColors.success,
      JobResult.warn => CodeOpsColors.warning,
      JobResult.fail => CodeOpsColors.error,
    };
  }
}
