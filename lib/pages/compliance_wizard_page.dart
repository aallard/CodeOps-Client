/// Compliance Wizard page.
///
/// Composes [WizardScaffold] with 4 steps: Source, Specifications, Agents,
/// and Review. On launch: creates job via [JobOrchestrator.executeJob],
/// uploads spec files via [ReportApi.uploadSpecification], creates spec
/// records via [ComplianceApi.createSpecification], and navigates to
/// `/jobs/{jobId}`.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/enums.dart';
import '../providers/agent_providers.dart';
import '../providers/compliance_providers.dart';
import '../providers/job_providers.dart';
import '../providers/wizard_providers.dart';
import '../services/cloud/compliance_api.dart';
import '../services/cloud/report_api.dart';
import '../services/orchestration/agent_dispatcher.dart';
import '../services/orchestration/job_orchestrator.dart';
import '../theme/colors.dart';
import '../widgets/shared/notification_toast.dart';
import '../widgets/wizard/agent_selector_step.dart';
import '../widgets/wizard/review_step.dart';
import '../widgets/wizard/source_step.dart';
import '../widgets/wizard/spec_upload_step.dart';
import '../widgets/wizard/wizard_scaffold.dart';

/// The Compliance Wizard page for launching a specification compliance check.
class ComplianceWizardPage extends ConsumerStatefulWidget {
  /// Creates a [ComplianceWizardPage].
  const ComplianceWizardPage({super.key});

  @override
  ConsumerState<ComplianceWizardPage> createState() =>
      _ComplianceWizardPageState();
}

class _ComplianceWizardPageState extends ConsumerState<ComplianceWizardPage> {
  @override
  Widget build(BuildContext context) {
    final wizardState = ref.watch(complianceWizardStateProvider);
    final notifier = ref.read(complianceWizardStateProvider.notifier);

    final steps = [
      WizardStepDef(
        title: 'Source',
        subtitle: 'Project & branch',
        icon: Icons.folder_outlined,
        isValid: wizardState.selectedProject != null &&
            wizardState.selectedBranch != null &&
            wizardState.localPath != null,
        content: SourceStep(
          selectedProject: wizardState.selectedProject,
          selectedBranch: wizardState.selectedBranch,
          localPath: wizardState.localPath,
          onProjectSelected: notifier.selectProject,
          onBranchSelected: notifier.selectBranch,
          onLocalPathSelected: notifier.setLocalPath,
        ),
      ),
      WizardStepDef(
        title: 'Specifications',
        subtitle: '${wizardState.specFiles.length} file(s)',
        icon: Icons.description_outlined,
        isValid: wizardState.specFiles.isNotEmpty,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SpecUploadStep(
                files: wizardState.specFiles,
                onFilesAdded: notifier.addSpecFiles,
                onFileRemoved: notifier.removeSpec,
              ),
            ),
            const SizedBox(height: 12),
            _SpecTypeExplanation(),
          ],
        ),
      ),
      WizardStepDef(
        title: 'Agents',
        subtitle: '${wizardState.selectedAgents.length} selected',
        icon: Icons.smart_toy_outlined,
        isValid: wizardState.selectedAgents.isNotEmpty,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AgentSelectorStep(
                selectedAgents: wizardState.selectedAgents,
                onToggle: notifier.toggleAgent,
                onSelectAll: notifier.selectAllAgents,
                onSelectNone: notifier.selectNoAgents,
                onSelectRecommended: notifier.selectRecommendedAgents,
              ),
            ),
            const SizedBox(height: 12),
            _AdditionalContextField(
              value: wizardState.additionalContext,
              onChanged: notifier.setAdditionalContext,
            ),
          ],
        ),
      ),
      WizardStepDef(
        title: 'Review',
        subtitle: 'Confirm & launch',
        icon: Icons.rocket_launch,
        content: ReviewStep(
          project: wizardState.selectedProject,
          branch: wizardState.selectedBranch,
          selectedAgents: wizardState.selectedAgents,
          config: wizardState.config,
          additionalInfo: _SpecSummaryCard(
            specFiles: wizardState.specFiles,
            additionalContext: wizardState.additionalContext,
          ),
        ),
      ),
    ];

    return WizardScaffold(
      title: 'Compliance Wizard',
      steps: steps,
      currentStep: wizardState.currentStep,
      isLaunching: wizardState.isLaunching,
      launchLabel: 'Launch Compliance Check',
      onBack: () => notifier.previousStep(),
      onNext: () => notifier.nextStep(),
      onLaunch: () => _launchCompliance(wizardState),
      onCancel: () {
        notifier.reset();
        context.go('/');
      },
    );
  }

  Future<void> _launchCompliance(ComplianceWizardState wizardState) async {
    final notifier = ref.read(complianceWizardStateProvider.notifier);
    final orchestrator = ref.read(jobOrchestratorProvider);
    final reportApi = ref.read(reportApiProvider);
    final complianceApi = ref.read(complianceApiProvider);
    final project = wizardState.selectedProject;

    if (project == null) return;

    notifier.setLaunching(true);

    try {
      // Build config
      final dispatchConfig = AgentDispatchConfig(
        maxConcurrent: wizardState.config.maxConcurrentAgents,
        agentTimeout:
            Duration(minutes: wizardState.config.agentTimeoutMinutes),
        claudeModel: wizardState.config.claudeModel,
        maxTurns: wizardState.config.maxTurns,
      );

      // Collect spec names for the job record.
      final specNames =
          wizardState.specFiles.map((f) => f.name).toList();

      // Listen for the job created event to get the job ID.
      String? jobId;
      final subscription = orchestrator.lifecycleStream.listen((event) {
        if (event is JobCreated) {
          jobId = event.jobId;
        }
      });

      // Fire-and-forget the job execution.
      orchestrator.executeJob(
        projectId: project.id,
        projectName: project.name,
        projectPath: wizardState.localPath ?? project.name,
        teamId: project.teamId,
        branch: wizardState.selectedBranch ?? 'main',
        mode: JobMode.compliance,
        selectedAgents: wizardState.selectedAgents.toList(),
        config: dispatchConfig,
        specReferences: specNames,
        additionalContext: wizardState.additionalContext.isNotEmpty
            ? wizardState.additionalContext
            : null,
      );

      // Wait briefly for the JobCreated event.
      await Future.delayed(const Duration(seconds: 2));
      await subscription.cancel();

      if (jobId != null) {
        // Upload spec files and create specification records.
        for (final specFile in wizardState.specFiles) {
          try {
            final uploadResult = await reportApi.uploadSpecification(
              jobId!,
              specFile.path,
            );
            final s3Key = uploadResult['s3Key'] as String? ?? '';

            // Infer spec type from content type.
            final specType = _inferSpecType(specFile.contentType);

            await complianceApi.createSpecification(
              jobId: jobId!,
              name: specFile.name,
              s3Key: s3Key,
              specType: specType,
            );
          } catch (_) {
            // Spec upload failure is non-fatal; job continues.
          }
        }
      }

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
            message: 'Failed to launch compliance check: $e',
            type: ToastType.error);
      }
    }
  }

  /// Infers the [SpecType] from a MIME content type string.
  SpecType? _inferSpecType(String contentType) {
    if (contentType.contains('yaml') || contentType.contains('json')) {
      return SpecType.openapi;
    }
    if (contentType.contains('markdown') || contentType.contains('text/plain')) {
      return SpecType.markdown;
    }
    if (contentType.startsWith('image/')) {
      return SpecType.screenshot;
    }
    if (contentType.contains('pdf')) {
      return SpecType.markdown;
    }
    return null;
  }
}

/// Explains spec types below the upload step.
class _SpecTypeExplanation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CodeOpsColors.secondary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: CodeOpsColors.secondary.withValues(alpha: 0.2),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Supported Specification Types',
            style: TextStyle(
              color: CodeOpsColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'OpenAPI/Swagger (YAML, JSON) \u2022 '
            'Markdown requirements \u2022 '
            'Screenshots/Figma (PNG, JPG, GIF) \u2022 '
            'PDF documents \u2022 '
            'CSV data \u2022 XML schemas',
            style: TextStyle(
              color: CodeOpsColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

/// Additional context text field shown below the agent selector.
class _AdditionalContextField extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _AdditionalContextField({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CodeOpsColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: CodeOpsColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Additional Context (optional)',
            style: TextStyle(
              color: CodeOpsColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: TextEditingController(text: value),
            onChanged: onChanged,
            maxLines: 3,
            style: const TextStyle(
              color: CodeOpsColors.textPrimary,
              fontSize: 12,
            ),
            decoration: const InputDecoration(
              hintText: 'Add context about your compliance requirements...',
              hintStyle: TextStyle(
                color: CodeOpsColors.textTertiary,
                fontSize: 12,
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}

/// Summary card showing uploaded specs in the review step.
class _SpecSummaryCard extends StatelessWidget {
  final List<SpecFile> specFiles;
  final String additionalContext;

  const _SpecSummaryCard({
    required this.specFiles,
    required this.additionalContext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CodeOpsColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: CodeOpsColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.description_outlined,
                  size: 16, color: CodeOpsColors.primary),
              SizedBox(width: 8),
              Text(
                'Specifications',
                style: TextStyle(
                  color: CodeOpsColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                const SizedBox(
                  width: 140,
                  child: Text(
                    'Files',
                    style: TextStyle(
                      color: CodeOpsColors.textTertiary,
                      fontSize: 12,
                    ),
                  ),
                ),
                Text(
                  '${specFiles.length} specification(s)',
                  style: const TextStyle(
                    color: CodeOpsColors.textPrimary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          ...specFiles.map((f) => Padding(
                padding: const EdgeInsets.only(left: 140, bottom: 2),
                child: Text(
                  f.name,
                  style: const TextStyle(
                    color: CodeOpsColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              )),
          if (additionalContext.isNotEmpty) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    width: 140,
                    child: Text(
                      'Additional Context',
                      style: TextStyle(
                        color: CodeOpsColors.textTertiary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      additionalContext,
                      style: const TextStyle(
                        color: CodeOpsColors.textPrimary,
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
    );
  }
}
