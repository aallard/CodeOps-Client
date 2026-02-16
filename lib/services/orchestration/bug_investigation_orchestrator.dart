/// Orchestrator for launching bug investigation jobs from Jira issues.
///
/// Coordinates Jira data extraction, job orchestration, and bug
/// investigation record creation on the server.
library;

import 'dart:async';

import '../../models/enums.dart';
import '../../models/jira_models.dart';
import '../../models/project.dart';
import '../../services/jira/jira_mapper.dart';
import '../cloud/job_api.dart';
import '../logging/log_service.dart';
import 'agent_dispatcher.dart';
import 'job_orchestrator.dart';

/// Launches a bug investigation job from a Jira issue.
///
/// Converts Jira issue data into investigation fields, fires
/// [JobOrchestrator.executeJob] in bug-investigate mode, and
/// creates a [BugInvestigation] record on the server.
class BugInvestigationOrchestrator {
  final JobApi _jobApi;
  final JobOrchestrator _jobOrchestrator;

  /// Creates a [BugInvestigationOrchestrator].
  BugInvestigationOrchestrator({
    required JobApi jobApi,
    required JobOrchestrator jobOrchestrator,
  })  : _jobApi = jobApi,
        _jobOrchestrator = jobOrchestrator;

  /// Launches a bug investigation and returns the created job ID.
  ///
  /// Builds the Jira ticket data string from the issue and comments,
  /// fires the job orchestrator, waits for the [JobCreated] event,
  /// and creates a [BugInvestigation] record.
  Future<String?> launchInvestigation({
    required Project project,
    required String branch,
    required String projectPath,
    required JiraIssue issue,
    required List<JiraComment> comments,
    required List<AgentType> selectedAgents,
    required AgentDispatchConfig config,
    String? additionalContext,
  }) async {
    // Build markdown from Jira ADF content for prompt injection.
    final descriptionMd = JiraMapper.adfToMarkdown(issue.fields.description);
    final commentsMd = comments.map((c) {
      final author = c.author?.displayName ?? 'Unknown';
      final body = JiraMapper.adfToMarkdown(c.body);
      return '**$author:**\n$body';
    }).join('\n\n---\n\n');

    final ticketData = StringBuffer();
    ticketData.writeln('# ${issue.key}: ${issue.fields.summary}');
    ticketData.writeln();
    ticketData.writeln('**Status:** ${issue.fields.status.name}');
    if (issue.fields.priority != null) {
      ticketData.writeln('**Priority:** ${issue.fields.priority!.name}');
    }
    ticketData.writeln();
    if (descriptionMd.isNotEmpty) {
      ticketData.writeln('## Description');
      ticketData.writeln(descriptionMd);
      ticketData.writeln();
    }
    if (commentsMd.isNotEmpty) {
      ticketData.writeln('## Comments');
      ticketData.writeln(commentsMd);
    }

    // Listen for JobCreated to capture the job ID.
    String? jobId;
    final completer = Completer<String?>();
    final subscription = _jobOrchestrator.lifecycleStream.listen((event) {
      if (event is JobCreated && !completer.isCompleted) {
        jobId = event.jobId;
        completer.complete(event.jobId);
      }
    });

    log.i('BugInvestigationOrchestrator', 'Investigation started (jiraKey=${issue.key}, project=${project.name})');

    // Fire-and-forget the job execution.
    _jobOrchestrator.executeJob(
      projectId: project.id,
      projectName: project.name,
      projectPath: projectPath,
      teamId: project.teamId,
      branch: branch,
      mode: JobMode.bugInvestigate,
      selectedAgents: selectedAgents,
      config: config,
      jobName: 'Bug Investigation: ${issue.key}',
      additionalContext: additionalContext,
      jiraTicketKey: issue.key,
      jiraTicketData: ticketData.toString(),
    );

    // Wait up to 5 seconds for the JobCreated event.
    jobId = await completer.future
        .timeout(const Duration(seconds: 5), onTimeout: () => null);
    await subscription.cancel();

    if (jobId == null) {
      log.w('BugInvestigationOrchestrator', 'JobCreated event not received within timeout');
      return null;
    }

    // Create the BugInvestigation record on the server.
    final fields = JiraMapper.toInvestigationFields(
      jobId: jobId!,
      issue: issue,
      comments: comments,
      additionalContext: additionalContext,
    );

    try {
      await _jobApi.createInvestigation(
        jobId!,
        jiraKey: fields['jiraKey'] as String?,
        jiraSummary: fields['jiraSummary'] as String?,
        jiraDescription: fields['jiraDescription'] as String?,
        jiraCommentsJson: fields['jiraCommentsJson'] as String?,
        jiraAttachmentsJson: fields['jiraAttachmentsJson'] as String?,
        jiraLinkedIssues: fields['jiraLinkedIssues'] as String?,
        additionalContext: fields['additionalContext'] as String?,
      );
    } catch (e) {
      log.w('BugInvestigationOrchestrator', 'Failed to create investigation record', e);
    }

    log.i('BugInvestigationOrchestrator', 'Investigation launched (jobId=$jobId)');
    return jobId;
  }
}
