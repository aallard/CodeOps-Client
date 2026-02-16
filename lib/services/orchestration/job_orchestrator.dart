/// End-to-end job lifecycle orchestrator.
///
/// Coordinates the full QA job lifecycle: server-side job creation, agent
/// dispatch, output monitoring, report parsing, Vera consolidation, findings
/// upload, and final status sync. Emits [JobLifecycleEvent]s on a broadcast
/// stream so the UI can track every phase transition.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../models/enums.dart';
import '../../providers/agent_progress_notifier.dart';
import '../agent/report_parser.dart';
import '../cloud/finding_api.dart';
import '../cloud/job_api.dart';
import '../cloud/report_api.dart';
import '../logging/log_service.dart';
import 'agent_dispatcher.dart';
import 'agent_monitor.dart';
import 'progress_aggregator.dart';
import 'vera_manager.dart';

// ---------------------------------------------------------------------------
// JobLifecycleEvent hierarchy
// ---------------------------------------------------------------------------

/// Base class for events emitted during the job lifecycle.
sealed class JobLifecycleEvent {}

/// The job record has been created on the server.
class JobCreated extends JobLifecycleEvent {
  /// The server-assigned job UUID.
  final String jobId;

  /// Creates a [JobCreated] event.
  JobCreated({required this.jobId});
}

/// The job has transitioned to the RUNNING status on the server.
class JobStarted extends JobLifecycleEvent {
  /// The job UUID.
  final String jobId;

  /// Creates a [JobStarted] event.
  JobStarted({required this.jobId});
}

/// The agent dispatch phase has begun.
class AgentPhaseStarted extends JobLifecycleEvent {
  /// The job UUID.
  final String jobId;

  /// The total number of agents that will be dispatched.
  final int totalAgents;

  /// Creates an [AgentPhaseStarted] event.
  AgentPhaseStarted({required this.jobId, required this.totalAgents});
}

/// An incremental progress update from the agent dispatch/monitoring phase.
class AgentPhaseProgress extends JobLifecycleEvent {
  /// The current aggregated job progress snapshot.
  final JobProgress progress;

  /// Creates an [AgentPhaseProgress] event.
  AgentPhaseProgress({required this.progress});
}

/// The Vera consolidation phase has begun.
class ConsolidationStarted extends JobLifecycleEvent {
  /// The job UUID.
  final String jobId;

  /// Creates a [ConsolidationStarted] event.
  ConsolidationStarted({required this.jobId});
}

/// The server sync phase has begun (uploading findings and reports).
class SyncStarted extends JobLifecycleEvent {
  /// The job UUID.
  final String jobId;

  /// Creates a [SyncStarted] event.
  SyncStarted({required this.jobId});
}

/// The job completed successfully.
class JobCompleted extends JobLifecycleEvent {
  /// The job UUID.
  final String jobId;

  /// The consolidated Vera report.
  final VeraReport report;

  /// Creates a [JobCompleted] event.
  JobCompleted({required this.jobId, required this.report});
}

/// The job failed due to an unrecoverable error.
class JobFailed extends JobLifecycleEvent {
  /// The job UUID.
  final String jobId;

  /// A human-readable description of the failure.
  final String error;

  /// Creates a [JobFailed] event.
  JobFailed({required this.jobId, required this.error});
}

/// The job was cancelled by the user.
class JobCancelled extends JobLifecycleEvent {
  /// The job UUID.
  final String jobId;

  /// Creates a [JobCancelled] event.
  JobCancelled({required this.jobId});
}

// ---------------------------------------------------------------------------
// JobOrchestrator
// ---------------------------------------------------------------------------

/// Orchestrates the complete lifecycle of a QA job.
///
/// Coordinates [AgentDispatcher], [AgentMonitor], [VeraManager],
/// [ProgressAggregator], [ReportParser], [JobApi], [FindingApi], and
/// [ReportApi] through a 10-step lifecycle:
///
/// 1. Create job on server (PENDING)
/// 2. Create agent runs on server (batch)
/// 3. Update job status to RUNNING
/// 4. Dispatch all agents concurrently
/// 5. For each completed agent: parse report, upload, update agent run
/// 6. Run Vera consolidation
/// 7. Upload findings in batch
/// 8. Upload summary report
/// 9. Update job with final status, score, and counts
/// 10. Emit [JobCompleted] lifecycle event
class JobOrchestrator {
  final AgentDispatcher _dispatcher;
  // ignore: unused_field — part of the constructor contract for future use.
  final AgentMonitor _monitor;
  final VeraManager _vera;
  final ProgressAggregator _progress;
  final ReportParser _parser;
  final JobApi _jobApi;
  final FindingApi _findingApi;
  final ReportApi _reportApi;
  final AgentProgressNotifier? _agentProgress;

  final StreamController<JobLifecycleEvent> _lifecycleController =
      StreamController<JobLifecycleEvent>.broadcast();

  String? _activeJobId;
  bool _cancelling = false;

  /// Creates a [JobOrchestrator].
  JobOrchestrator({
    required AgentDispatcher dispatcher,
    required AgentMonitor monitor,
    required VeraManager vera,
    required ProgressAggregator progress,
    required ReportParser parser,
    required JobApi jobApi,
    required FindingApi findingApi,
    required ReportApi reportApi,
    AgentProgressNotifier? agentProgressNotifier,
  })  : _dispatcher = dispatcher,
        _monitor = monitor,
        _vera = vera,
        _progress = progress,
        _parser = parser,
        _jobApi = jobApi,
        _findingApi = findingApi,
        _reportApi = reportApi,
        _agentProgress = agentProgressNotifier;

  /// The UUID of the currently running job, or `null` if no job is active.
  String? get activeJobId => _activeJobId;

  /// Broadcast stream of [JobLifecycleEvent]s for the current job.
  Stream<JobLifecycleEvent> get lifecycleStream => _lifecycleController.stream;

  /// Executes the full job lifecycle from creation through completion.
  ///
  /// [projectId] is the UUID of the project to analyze.
  /// [projectName] is a human-readable label for reports and summaries.
  /// [projectPath] is the local filesystem path for agent working directories.
  /// [teamId] scopes persona and directive lookups.
  /// [branch] is the git branch being analyzed.
  /// [mode] determines which agents run and how prompts are assembled.
  /// [selectedAgents] is the list of agents to dispatch for this job.
  /// [config] governs concurrency, timeout, model, and turn limits.
  /// [jobName] is an optional human-readable job name.
  /// [additionalContext] is free-form text appended to agent prompts.
  /// [jiraTicketKey] is the Jira ticket key for bug-investigate mode.
  /// [jiraTicketData] is raw Jira ticket content for prompt injection.
  /// [specReferences] is a list of specification names/paths for compliance.
  ///
  /// Returns the overall [JobResult] after all phases complete.
  Future<JobResult> executeJob({
    required String projectId,
    required String projectName,
    required String projectPath,
    required String teamId,
    required String branch,
    required JobMode mode,
    required List<AgentType> selectedAgents,
    required AgentDispatchConfig config,
    String? jobName,
    String? additionalContext,
    String? jiraTicketKey,
    String? jiraTicketData,
    List<String>? specReferences,
  }) async {
    _cancelling = false;
    String? jobId;

    // Validate projectPath before starting the job lifecycle.
    if (!Directory(projectPath).existsSync()) {
      final error = 'Project directory does not exist: $projectPath';
      log.e('JobOrchestrator', error);
      throw StateError(error);
    }

    try {
      // Step 1: Create job on server.
      final job = await _jobApi.createJob(
        projectId: projectId,
        mode: mode,
        name: jobName,
        branch: branch,
        jiraTicketKey: jiraTicketKey,
      );
      jobId = job.id;
      _activeJobId = jobId;
      log.i('JobOrchestrator', 'Job created (jobId=$jobId, project=$projectId, agents=${selectedAgents.length})');
      _lifecycleController.add(JobCreated(jobId: jobId));

      if (_cancelling) {
        await _handleCancellation(jobId);
        return JobResult.fail;
      }

      // Step 2: Create agent runs on server.
      final agentRuns =
          await _jobApi.createAgentRunsBatch(jobId, selectedAgents);

      // Build a lookup map from AgentType to agent run ID.
      final agentRunIdsByType = <AgentType, String>{};
      for (final run in agentRuns) {
        agentRunIdsByType[run.agentType] = run.id;
      }

      // Initialize the agent progress notifier with created runs.
      _agentProgress?.initializeAgents(
        agentRuns,
        maxTurns: config.maxTurns,
        modelId: config.claudeModel,
      );

      // Step 3: Update job status to RUNNING.
      await _jobApi.updateJob(
        jobId,
        status: JobStatus.running,
        startedAt: DateTime.now(),
      );
      log.i('JobOrchestrator', 'Job started (jobId=$jobId)');
      _lifecycleController.add(JobStarted(jobId: jobId));

      if (_cancelling) {
        await _handleCancellation(jobId);
        return JobResult.fail;
      }

      // Step 4: Dispatch all agents.
      _progress.reset(selectedAgents);
      _lifecycleController.add(
        AgentPhaseStarted(jobId: jobId, totalAgents: selectedAgents.length),
      );

      final agentReports = <AgentType, ParsedReport>{};
      final agentStartTimes = <AgentType, DateTime>{};
      final agentTurnCounts = <AgentType, int>{};
      final agentResultTexts = <AgentType, String>{};

      // Subscribe to progress updates and forward them.
      final progressSubscription = _progress.progressStream.listen((snapshot) {
        _lifecycleController.add(AgentPhaseProgress(progress: snapshot));
      });

      // Periodic timer to update elapsed times for running agents.
      final elapsedTimer = Timer.periodic(
        const Duration(seconds: 1),
        (_) {
          for (final entry in agentStartTimes.entries) {
            final runId = agentRunIdsByType[entry.key];
            if (runId != null) {
              _agentProgress?.updateElapsed(
                runId,
                DateTime.now().difference(entry.value),
              );
            }
          }
        },
      );

      // Listen for dispatch events.
      final dispatchStream = _dispatcher.dispatchAll(
        agentTypes: selectedAgents,
        teamId: teamId,
        projectId: projectId,
        projectPath: projectPath,
        branch: branch,
        mode: mode,
        projectName: projectName,
        config: config,
        additionalContext: additionalContext,
        jiraTicketData: jiraTicketData,
        specReferences: specReferences,
      );

      await for (final event in dispatchStream) {
        if (_cancelling) break;

        switch (event) {
          case AgentQueued(:final agentType):
            _progress.updateAgentStatus(
              agentType,
              AgentProgressStatus(
                agentType: agentType,
                phase: AgentPhase.queued,
                elapsed: Duration.zero,
              ),
            );
            _agentProgress?.updateQueuePositions();

          case AgentStarted(:final agentType):
            agentStartTimes[agentType] = DateTime.now();
            _progress.updateAgentStatus(
              agentType,
              AgentProgressStatus(
                agentType: agentType,
                phase: AgentPhase.running,
                elapsed: Duration.zero,
              ),
            );
            // Update agent progress notifier.
            final startRunId = agentRunIdsByType[agentType];
            if (startRunId != null) {
              _agentProgress?.markStarted(startRunId);
              _agentProgress?.updateQueuePositions();
            }
            // Update agent run status on server.
            final runId = agentRunIdsByType[agentType];
            if (runId != null) {
              await _jobApi.updateAgentRun(
                runId,
                status: AgentStatus.running,
                startedAt: agentStartTimes[agentType],
              );
            }

          case AgentOutput(:final agentType, :final line):
            _progress.updateAgentStatus(
              agentType,
              AgentProgressStatus(
                agentType: agentType,
                phase: AgentPhase.running,
                elapsed: _elapsedSince(agentStartTimes[agentType]),
                lastOutputLine: line,
              ),
            );
            // Parse stream-json NDJSON events for real-time progress.
            final outputRunId = agentRunIdsByType[agentType];
            if (outputRunId != null) {
              _parseStreamJsonEvent(
                line,
                agentType: agentType,
                runId: outputRunId,
                turnCounts: agentTurnCounts,
                resultTexts: agentResultTexts,
                startTimes: agentStartTimes,
              );
            }

          case AgentCompleted(
              :final agentType,
              :final exitCode,
              :final output
            ):
            // Step 5: Parse report.
            _progress.updateAgentStatus(
              agentType,
              AgentProgressStatus(
                agentType: agentType,
                phase: AgentPhase.parsing,
                elapsed: _elapsedSince(agentStartTimes[agentType]),
              ),
            );

            // Extract the result markdown from stream-json output.
            final resultText = agentResultTexts[agentType] ??
                extractResultFromStreamJson(output);
            final parsedReport = _parser.parseReport(resultText);
            agentReports[agentType] = parsedReport;

            // Report live findings for real-time UI.
            for (final finding in parsedReport.findings) {
              _progress.reportLiveFinding(agentType, finding);
            }

            // Determine agent result.
            final agentResult = _agentResultFromExitCode(
              exitCode,
              parsedReport.findings,
            );

            // Upload agent report to server.
            final runId = agentRunIdsByType[agentType];
            if (runId != null) {
              final reportResponse = await _reportApi.uploadAgentReport(
                jobId,
                agentType,
                resultText,
              );
              final s3Key = reportResponse['s3Key'] as String?;

              final criticalCount = parsedReport.findings
                  .where((f) => f.severity == Severity.critical)
                  .length;
              final highCount = parsedReport.findings
                  .where((f) => f.severity == Severity.high)
                  .length;

              await _jobApi.updateAgentRun(
                runId,
                status: AgentStatus.completed,
                result: agentResult,
                reportS3Key: s3Key,
                score: parsedReport.metrics?.score,
                findingsCount: parsedReport.findings.length,
                criticalCount: criticalCount,
                highCount: highCount,
                completedAt: DateTime.now(),
              );
            }

            _progress.updateAgentStatus(
              agentType,
              AgentProgressStatus(
                agentType: agentType,
                phase: AgentPhase.completed,
                elapsed: _elapsedSince(agentStartTimes[agentType]),
                findingsCount: parsedReport.findings.length,
              ),
            );

            // Update agent progress notifier with completion data.
            if (runId != null) {
              final completedCritical = parsedReport.findings
                  .where((f) => f.severity == Severity.critical)
                  .length;
              final completedHigh = parsedReport.findings
                  .where((f) => f.severity == Severity.high)
                  .length;
              final completedMedium = parsedReport.findings
                  .where((f) => f.severity == Severity.medium)
                  .length;
              final completedLow = parsedReport.findings
                  .where((f) => f.severity == Severity.low)
                  .length;
              _agentProgress?.markCompleted(
                runId,
                agentResult,
                score: parsedReport.metrics?.score,
                findingsCount: parsedReport.findings.length,
                criticalCount: completedCritical,
                highCount: completedHigh,
                mediumCount: completedMedium,
                lowCount: completedLow,
              );
            }

          case AgentFailed(:final agentType, :final error):
            _progress.updateAgentStatus(
              agentType,
              AgentProgressStatus(
                agentType: agentType,
                phase: AgentPhase.failed,
                elapsed: _elapsedSince(agentStartTimes[agentType]),
              ),
            );
            final failedRunId = agentRunIdsByType[agentType];
            if (failedRunId != null) {
              _agentProgress?.markFailed(failedRunId, error: error);
              await _jobApi.updateAgentRun(
                failedRunId,
                status: AgentStatus.failed,
                result: AgentResult.fail,
                completedAt: DateTime.now(),
              );
            }

          case AgentTimedOut(:final agentType):
            _progress.updateAgentStatus(
              agentType,
              AgentProgressStatus(
                agentType: agentType,
                phase: AgentPhase.timedOut,
                elapsed: config.agentTimeout,
              ),
            );
            final timedOutRunId = agentRunIdsByType[agentType];
            if (timedOutRunId != null) {
              _agentProgress?.markFailed(
                timedOutRunId,
                error: 'Agent timed out after ${config.agentTimeout.inMinutes} minutes',
              );
              await _jobApi.updateAgentRun(
                timedOutRunId,
                status: AgentStatus.failed,
                result: AgentResult.fail,
                completedAt: DateTime.now(),
              );
            }
        }
      }

      elapsedTimer.cancel();
      await progressSubscription.cancel();

      if (_cancelling) {
        await _handleCancellation(jobId);
        return JobResult.fail;
      }

      // Step 6: Vera consolidation.
      log.d('JobOrchestrator', 'Agent phase complete, starting Vera consolidation (jobId=$jobId)');
      _lifecycleController.add(ConsolidationStarted(jobId: jobId));

      // Tag all findings with their source agent type before consolidation.
      final taggedReports = <AgentType, ParsedReport>{};
      for (final entry in agentReports.entries) {
        final agentType = entry.key;
        final report = entry.value;
        taggedReports[agentType] = ParsedReport(
          metadata: report.metadata,
          executiveSummary: report.executiveSummary,
          findings: report.findings
              .map((f) => f.withAgentType(agentType))
              .toList(),
          metrics: report.metrics,
          rawMarkdown: report.rawMarkdown,
        );
      }

      final veraReport = await _vera.consolidate(
        jobId: jobId,
        projectName: projectName,
        agentReports: taggedReports,
        mode: mode,
      );

      // Step 7: Upload findings in batch.
      _lifecycleController.add(SyncStarted(jobId: jobId));

      if (veraReport.deduplicatedFindings.isNotEmpty) {
        final findingMaps = veraReport.deduplicatedFindings.map((f) {
          final map = <String, dynamic>{
            'jobId': jobId,
            'agentType': (f.agentType ?? AgentType.codeQuality).toJson(),
            'severity': f.severity.toJson(),
            'title': f.title,
          };
          if (f.description != null) map['description'] = f.description;
          if (f.filePath != null) map['filePath'] = f.filePath;
          if (f.lineNumber != null) map['lineNumber'] = f.lineNumber;
          if (f.recommendation != null) {
            map['recommendation'] = f.recommendation;
          }
          if (f.evidence != null) map['evidence'] = f.evidence;
          if (f.effortEstimate != null) {
            map['effortEstimate'] = f.effortEstimate!.toJson();
          }
          if (f.debtCategory != null) {
            map['debtCategory'] = f.debtCategory!.toJson();
          }
          return map;
        }).toList();

        await _findingApi.createFindingsBatch(findingMaps);
      }

      // Step 8: Upload summary report.
      await _reportApi.uploadSummaryReport(
        jobId,
        veraReport.executiveSummaryMd,
      );

      // Step 9: Update job with final status, score, and counts.
      await _jobApi.updateJob(
        jobId,
        status: JobStatus.completed,
        summaryMd: veraReport.executiveSummaryMd,
        overallResult: veraReport.overallResult,
        healthScore: veraReport.healthScore,
        totalFindings: veraReport.totalFindings,
        criticalCount: veraReport.criticalCount,
        highCount: veraReport.highCount,
        mediumCount: veraReport.mediumCount,
        lowCount: veraReport.lowCount,
        completedAt: DateTime.now(),
      );

      // Step 10: Emit completion event.
      log.i('JobOrchestrator', 'Job completed (jobId=$jobId, score=${veraReport.healthScore}, findings=${veraReport.totalFindings})');
      _lifecycleController.add(
        JobCompleted(jobId: jobId, report: veraReport),
      );
      _activeJobId = null;

      return veraReport.overallResult;
    } catch (e) {
      log.e('JobOrchestrator', 'Job failed (jobId=$jobId)', e);
      // Wrap entire flow in error handling.
      if (jobId != null) {
        try {
          await _jobApi.updateJob(
            jobId,
            status: JobStatus.failed,
            completedAt: DateTime.now(),
          );
        } catch (_) {
          // Best-effort server update; swallow secondary errors.
        }
        _lifecycleController.add(
          JobFailed(jobId: jobId, error: e.toString()),
        );
      }
      _activeJobId = null;
      rethrow;
    }
  }

  /// Cancels the currently running job.
  ///
  /// Kills all running agent processes via [AgentDispatcher.cancelAll] and
  /// updates the job status to CANCELLED on the server.
  Future<void> cancelJob(String jobId) async {
    log.w('JobOrchestrator', 'Job cancellation requested (jobId=$jobId)');
    _cancelling = true;
    await _dispatcher.cancelAll();

    try {
      await _jobApi.updateJob(
        jobId,
        status: JobStatus.cancelled,
        completedAt: DateTime.now(),
      );
    } catch (_) {
      // Best-effort server update.
    }

    _agentProgress?.reset();
    _lifecycleController.add(JobCancelled(jobId: jobId));
    _activeJobId = null;
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Handles the cancellation flow during an in-progress job.
  Future<void> _handleCancellation(String jobId) async {
    await _dispatcher.cancelAll();
    try {
      await _jobApi.updateJob(
        jobId,
        status: JobStatus.cancelled,
        completedAt: DateTime.now(),
      );
    } catch (_) {
      // Best-effort.
    }
    _lifecycleController.add(JobCancelled(jobId: jobId));
    _activeJobId = null;
  }

  /// Calculates the elapsed duration since [startTime], or [Duration.zero]
  /// if [startTime] is `null`.
  Duration _elapsedSince(DateTime? startTime) {
    if (startTime == null) return Duration.zero;
    return DateTime.now().difference(startTime);
  }

  /// Derives an [AgentResult] from the process exit code and parsed findings.
  AgentResult _agentResultFromExitCode(
    int exitCode,
    List<ParsedFinding> findings,
  ) {
    if (exitCode != 0) return AgentResult.fail;
    if (findings.any((f) => f.severity == Severity.critical)) {
      return AgentResult.fail;
    }
    if (findings.any((f) => f.severity == Severity.high)) {
      return AgentResult.warn;
    }
    return AgentResult.pass;
  }

  /// Parses a single stream-json NDJSON line and updates agent progress.
  ///
  /// Each line is expected to be a JSON object with a `type` field.
  /// Recognized types: `assistant` (turn counting), `tool_use` (activity
  /// tracking), and `result` (final output text extraction).
  void _parseStreamJsonEvent(
    String line, {
    required AgentType agentType,
    required String runId,
    required Map<AgentType, int> turnCounts,
    required Map<AgentType, String> resultTexts,
    required Map<AgentType, DateTime> startTimes,
  }) {
    try {
      final json = jsonDecode(line.trim()) as Map<String, dynamic>;
      final type = json['type'] as String?;

      switch (type) {
        case 'assistant':
          // Each assistant message represents one agentic turn.
          final count = (turnCounts[agentType] ?? 0) + 1;
          turnCounts[agentType] = count;
          _agentProgress?.updateProgress(runId, currentTurn: count);
          _agentProgress?.updateActivity(runId, 'Thinking...');
          _agentProgress?.appendOutput(runId, '[Turn $count] Assistant responding');

        case 'tool_use':
          // Extract tool name for activity display.
          String? toolName;
          if (json['tool'] is Map) {
            toolName = (json['tool'] as Map)['name'] as String?;
          }
          toolName ??= json['name'] as String?;

          if (toolName != null) {
            final activity = toolDisplayName(toolName);
            _agentProgress?.updateActivity(runId, activity);
            _agentProgress?.appendOutput(runId, '  → $activity');

            // Track file analysis from Read/Glob tool calls.
            if (toolName == 'Read' || toolName == 'Glob') {
              String? filePath;
              final input = (json['tool'] is Map)
                  ? (json['tool'] as Map)['input']
                  : json['input'];
              if (input is Map) {
                filePath = (input['file_path'] ?? input['pattern']) as String?;
              }
              if (filePath != null) {
                _agentProgress?.incrementFilesAnalyzed(runId, filePath);
              }
            }
          }

        case 'tool_result':
          _agentProgress?.updateActivity(runId, 'Processing result...');

        case 'result':
          // Store the final result text for report parsing.
          final resultText = json['result'] as String?;
          if (resultText != null) {
            resultTexts[agentType] = resultText;
          }
          // Use num_turns from the result event for accurate final count.
          final numTurns = json['num_turns'] as int?;
          if (numTurns != null) {
            turnCounts[agentType] = numTurns;
            _agentProgress?.updateProgress(runId, currentTurn: numTurns);
          }
          _agentProgress?.updateActivity(runId, 'Finalizing...');
      }

      _agentProgress?.updateElapsed(
        runId,
        _elapsedSince(startTimes[agentType]),
      );
    } catch (_) {
      // Non-JSON line or parse error — skip silently.
      // Append raw line to output for debugging.
      _agentProgress?.appendOutput(runId, line);
      _agentProgress?.updateElapsed(
        runId,
        _elapsedSince(startTimes[agentType]),
      );
    }
  }

  /// Extracts the final result text from stream-json NDJSON output.
  ///
  /// Scans backwards through the output lines looking for a `result` event.
  /// Falls back to the raw output if no result event is found (for backwards
  /// compatibility with non-stream-json output).
  static String extractResultFromStreamJson(String output) {
    final lines = output.split('\n');
    for (final line in lines.reversed) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      try {
        final json = jsonDecode(trimmed) as Map<String, dynamic>;
        if (json['type'] == 'result') {
          return json['result'] as String? ?? output;
        }
      } catch (_) {
        continue;
      }
    }
    // Fallback: not stream-json format or no result event found.
    return output;
  }

  /// Maps a Claude Code tool name to a human-readable activity description.
  static String toolDisplayName(String toolName) => switch (toolName) {
        'Read' => 'Reading file...',
        'Write' => 'Writing file...',
        'Edit' => 'Editing file...',
        'Bash' => 'Running command...',
        'Glob' => 'Searching files...',
        'Grep' => 'Searching code...',
        'Task' => 'Delegating task...',
        'WebFetch' => 'Fetching web content...',
        'WebSearch' => 'Searching web...',
        'NotebookEdit' => 'Editing notebook...',
        _ => 'Using $toolName...',
      };
}
