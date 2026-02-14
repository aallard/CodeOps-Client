/// Wrapper for creating Jira issues from remediation tasks.
///
/// Resolves the [Project] from the job ID, then delegates to
/// [CreateIssueDialog] (single task) or [BulkCreateDialog] (multiple tasks).
/// On success, updates task status to JIRA_CREATED via [TaskApi].
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/enums.dart';
import '../../models/jira_models.dart';
import '../../models/project.dart';
import '../../models/remediation_task.dart';
import '../../providers/job_providers.dart';
import '../../providers/project_providers.dart';
import '../../providers/task_providers.dart';
import '../jira/bulk_create_dialog.dart';
import '../jira/create_issue_dialog.dart';
import '../shared/notification_toast.dart';

/// Shows a Jira issue creation dialog for one or more tasks.
///
/// For a single task, opens [CreateIssueDialog]. For multiple tasks,
/// opens [BulkCreateDialog]. After successful creation, updates each
/// task's status to [TaskStatus.jiraCreated] and stores the Jira key.
///
/// Returns `true` if at least one issue was created.
Future<bool?> showJiraCreateTaskDialog(
  BuildContext context,
  WidgetRef ref, {
  RemediationTask? singleTask,
  List<RemediationTask>? tasks,
  required String jobId,
}) async {
  // Resolve the project from the job.
  final Project project;
  try {
    final job = await ref.read(jobDetailProvider(jobId).future);
    project = await ref.read(projectProvider(job.projectId).future);
  } catch (e) {
    if (context.mounted) {
      showToast(context,
          message: 'Failed to load project: $e', type: ToastType.error);
    }
    return false;
  }

  if (!context.mounted) return false;

  if (singleTask != null) {
    // Single task → CreateIssueDialog.
    final result = await showDialog<JiraIssue>(
      context: context,
      builder: (_) => CreateIssueDialog(
        task: singleTask,
        project: project,
      ),
    );

    if (result != null) {
      // Update task with Jira key.
      try {
        final taskApi = ref.read(taskApiProvider);
        await taskApi.updateTask(
          singleTask.id,
          status: TaskStatus.jiraCreated,
          jiraKey: result.key,
        );
        ref.invalidate(jobTasksProvider(jobId));
        ref.invalidate(myTasksProvider);
      } catch (_) {
        // Best-effort status update.
      }
      return true;
    }
    return false;
  }

  if (tasks != null && tasks.isNotEmpty) {
    // Bulk → BulkCreateDialog.
    final result = await showDialog<List<JiraIssue>>(
      context: context,
      builder: (_) => BulkCreateDialog(
        tasks: tasks,
        project: project,
      ),
    );

    if (result != null && result.isNotEmpty) {
      // Match created issues back to tasks by summary prefix.
      final taskApi = ref.read(taskApiProvider);
      for (final issue in result) {
        // Find the matching task by title → summary correspondence.
        final matchingTask = tasks.cast<RemediationTask?>().firstWhere(
              (t) => t!.title == issue.fields.summary,
              orElse: () => null,
            );
        if (matchingTask != null) {
          try {
            await taskApi.updateTask(
              matchingTask.id,
              status: TaskStatus.jiraCreated,
              jiraKey: issue.key,
            );
          } catch (_) {
            // Best-effort.
          }
        }
      }
      ref.invalidate(jobTasksProvider(jobId));
      ref.invalidate(myTasksProvider);
      return true;
    }
    return false;
  }

  return false;
}
