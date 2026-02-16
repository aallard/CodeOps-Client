/// Bug Investigator wizard page.
///
/// 3-step wizard: Select Bug (Jira issue), Configure (source + agents),
/// Review & Launch. Uses [BugInvestigationOrchestrator] to fire the job
/// and navigates to `/jobs/{jobId}` on success.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/enums.dart';
import '../models/jira_models.dart';
import '../providers/agent_providers.dart';
import '../providers/jira_providers.dart';
import '../providers/project_providers.dart';
import '../providers/wizard_providers.dart';
import '../services/orchestration/agent_dispatcher.dart';
import '../theme/colors.dart';
import '../widgets/jira/issue_detail_panel.dart';
import '../widgets/jira/issue_picker.dart';
import '../widgets/shared/notification_toast.dart';
import '../widgets/wizard/agent_selector_step.dart';
import '../widgets/wizard/source_step.dart';
import '../widgets/wizard/wizard_scaffold.dart';

/// The Bug Investigator page — a 3-step wizard for launching investigations.
class BugInvestigatorPage extends ConsumerStatefulWidget {
  /// Optional initial Jira issue key (from query parameter).
  final String? initialJiraKey;

  /// Creates a [BugInvestigatorPage].
  const BugInvestigatorPage({super.key, this.initialJiraKey});

  @override
  ConsumerState<BugInvestigatorPage> createState() =>
      _BugInvestigatorPageState();
}

class _BugInvestigatorPageState extends ConsumerState<BugInvestigatorPage> {
  @override
  void initState() {
    super.initState();
    // Reset wizard state on page entry.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bugInvestigatorWizardStateProvider.notifier).reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final wizardState = ref.watch(bugInvestigatorWizardStateProvider);
    final notifier = ref.read(bugInvestigatorWizardStateProvider.notifier);

    final steps = [
      WizardStepDef(
        title: 'Select Bug',
        subtitle: wizardState.selectedIssue != null
            ? wizardState.selectedIssue!.key
            : 'Jira issue',
        icon: Icons.bug_report_outlined,
        isValid: wizardState.selectedIssue != null,
        content: _BugSelectionStep(
          selectedIssue: wizardState.selectedIssue,
          initialIssueKey: widget.initialJiraKey,
          onIssueSelected: (issue) async {
            // Fetch comments for the selected issue.
            List<JiraComment> comments = [];
            try {
              comments =
                  await ref.read(jiraCommentsProvider(issue.key).future);
            } catch (_) {
              // Best-effort comment fetch.
            }
            notifier.selectIssue(issue, comments);

            // Auto-detect project from Jira project key.
            _autoDetectProject(issue.key.split('-').first, notifier);
          },
        ),
      ),
      WizardStepDef(
        title: 'Configure',
        subtitle: 'Source & agents',
        icon: Icons.settings_outlined,
        isValid: wizardState.selectedProject != null &&
            wizardState.selectedBranch != null &&
            wizardState.localPath != null &&
            wizardState.selectedAgents.isNotEmpty,
        content: _ConfigureStep(
          wizardState: wizardState,
          notifier: notifier,
        ),
      ),
      WizardStepDef(
        title: 'Review & Launch',
        subtitle: 'Confirm',
        icon: Icons.rocket_launch,
        isValid: true,
        content: _ReviewStep(wizardState: wizardState),
      ),
    ];

    return WizardScaffold(
      title: 'Bug Investigator',
      steps: steps,
      currentStep: wizardState.currentStep,
      isLaunching: wizardState.isLaunching,
      launchLabel: 'Launch Investigation',
      onBack: () => notifier.previousStep(),
      onNext: () => notifier.nextStep(),
      onLaunch: () => _launchInvestigation(wizardState),
      onCancel: () {
        notifier.reset();
        context.go('/');
      },
    );
  }

  /// Attempts to auto-detect the project from a Jira project key prefix.
  void _autoDetectProject(
      String jiraProjectKey, BugInvestigatorWizardNotifier notifier) {
    try {
      final projectsAsync = ref.read(teamProjectsProvider);
      projectsAsync.whenData((projects) {
        final match = projects.cast().firstWhere(
              (p) =>
                  p.jiraProjectKey?.toUpperCase() ==
                  jiraProjectKey.toUpperCase(),
              orElse: () => null,
            );
        if (match != null) {
          notifier.selectProject(match);
        }
      });
    } catch (_) {
      // Silent — user can select manually.
    }
  }

  Future<void> _launchInvestigation(
      BugInvestigatorWizardState wizardState) async {
    final notifier = ref.read(bugInvestigatorWizardStateProvider.notifier);
    final orchestrator = ref.read(bugInvestigationOrchestratorProvider);
    final project = wizardState.selectedProject;
    final issue = wizardState.selectedIssue;

    if (project == null || issue == null) return;

    notifier.setLaunching(true);

    try {
      final dispatchConfig = AgentDispatchConfig(
        maxConcurrent: wizardState.config.maxConcurrentAgents,
        agentTimeout:
            Duration(minutes: wizardState.config.agentTimeoutMinutes),
        claudeModel: wizardState.config.claudeModel,
        maxTurns: wizardState.config.maxTurns,
      );

      final jobId = await orchestrator.launchInvestigation(
        project: project,
        branch: wizardState.selectedBranch ?? 'main',
        projectPath: wizardState.localPath!,
        issue: issue,
        comments: wizardState.selectedComments,
        selectedAgents: wizardState.selectedAgents.toList(),
        config: dispatchConfig,
        additionalContext: wizardState.additionalContext.isNotEmpty
            ? wizardState.additionalContext
            : null,
      );

      if (mounted) {
        notifier.setLaunching(false);
        notifier.reset();

        if (jobId != null) {
          context.go('/jobs/$jobId');
        } else {
          context.go('/history');
        }
      }
    } catch (e) {
      if (mounted) {
        notifier.setLaunchError(e.toString());
        showToast(context,
            message: 'Failed to launch investigation: $e',
            type: ToastType.error);
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Step 1: Bug Selection
// ---------------------------------------------------------------------------

class _BugSelectionStep extends StatelessWidget {
  final JiraIssue? selectedIssue;
  final String? initialIssueKey;
  final ValueChanged<JiraIssue> onIssueSelected;

  const _BugSelectionStep({
    this.selectedIssue,
    this.initialIssueKey,
    required this.onIssueSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Issue picker (left).
        Expanded(
          flex: 2,
          child: IssuePicker(
            onIssueSelected: onIssueSelected,
            initialIssueKey: initialIssueKey,
          ),
        ),
        const SizedBox(width: 16),
        // Issue detail preview (right).
        Expanded(
          flex: 3,
          child: selectedIssue != null
              ? IssueDetailPanel(
                  issueKey: selectedIssue!.key,
                )
              : Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: CodeOpsColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: CodeOpsColors.border, width: 1),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.bug_report_outlined,
                            size: 48, color: CodeOpsColors.textTertiary),
                        SizedBox(height: 12),
                        Text(
                          'Select a Jira issue to investigate',
                          style: TextStyle(
                            color: CodeOpsColors.textTertiary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Step 2: Configure
// ---------------------------------------------------------------------------

class _ConfigureStep extends StatelessWidget {
  final BugInvestigatorWizardState wizardState;
  final BugInvestigatorWizardNotifier notifier;

  const _ConfigureStep({
    required this.wizardState,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Source selection.
          SourceStep(
            selectedProject: wizardState.selectedProject,
            selectedBranch: wizardState.selectedBranch,
            localPath: wizardState.localPath,
            onProjectSelected: notifier.selectProject,
            onBranchSelected: notifier.selectBranch,
            onLocalPathSelected: notifier.setLocalPath,
          ),
          const SizedBox(height: 24),

          // Agent selection.
          AgentSelectorStep(
            selectedAgents: wizardState.selectedAgents,
            onToggle: notifier.toggleAgent,
            onSelectAll: () {
              // Select all agents by toggling each unselected one.
              for (final agent in AgentType.values) {
                if (!wizardState.selectedAgents.contains(agent)) {
                  notifier.toggleAgent(agent);
                }
              }
            },
            onSelectNone: () {
              for (final agent in wizardState.selectedAgents.toList()) {
                notifier.toggleAgent(agent);
              }
            },
            onSelectRecommended: notifier.selectRecommendedAgents,
          ),
          const SizedBox(height: 24),

          // Additional context.
          const Text(
            'Additional Context',
            style: TextStyle(
              color: CodeOpsColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            maxLines: 4,
            onChanged: notifier.setAdditionalContext,
            style: const TextStyle(
              color: CodeOpsColors.textPrimary,
              fontSize: 13,
            ),
            decoration: InputDecoration(
              hintText:
                  'Any additional context to help agents investigate this bug...',
              hintStyle: const TextStyle(
                color: CodeOpsColors.textTertiary,
                fontSize: 12,
              ),
              filled: true,
              fillColor: CodeOpsColors.surfaceVariant,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(
                  color: CodeOpsColors.primary,
                  width: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step 3: Review
// ---------------------------------------------------------------------------

class _ReviewStep extends StatelessWidget {
  final BugInvestigatorWizardState wizardState;

  const _ReviewStep({required this.wizardState});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: CodeOpsColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: CodeOpsColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Investigation Summary',
              style: TextStyle(
                color: CodeOpsColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            _SummaryRow(
              label: 'Jira Issue',
              value: wizardState.selectedIssue != null
                  ? '${wizardState.selectedIssue!.key}: ${wizardState.selectedIssue!.fields.summary}'
                  : 'None selected',
            ),
            _SummaryRow(
              label: 'Project',
              value: wizardState.selectedProject?.name ?? 'None selected',
            ),
            _SummaryRow(
              label: 'Branch',
              value: wizardState.selectedBranch ?? 'main',
            ),
            _SummaryRow(
              label: 'Agents',
              value:
                  '${wizardState.selectedAgents.length} selected',
            ),
            if (wizardState.additionalContext.isNotEmpty)
              _SummaryRow(
                label: 'Context',
                value: wizardState.additionalContext.length > 80
                    ? '${wizardState.additionalContext.substring(0, 80)}...'
                    : wizardState.additionalContext,
              ),

            if (wizardState.launchError != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: CodeOpsColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        color: CodeOpsColors.error, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        wizardState.launchError!,
                        style: const TextStyle(
                          color: CodeOpsColors.error,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: CodeOpsColors.textTertiary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: CodeOpsColors.textPrimary,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
