/// Riverpod providers for the Compliance Wizard and compliance result data.
///
/// Contains the wizard state machine, API provider, compliance items/specs
/// providers, summary/score providers, and filter state providers.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/compliance_item.dart';
import '../models/enums.dart';
import '../models/health_snapshot.dart';
import '../models/project.dart';
import '../models/specification.dart';
import '../services/cloud/compliance_api.dart';
import '../services/logging/log_service.dart';
import 'auth_providers.dart';
import 'wizard_providers.dart';

// ---------------------------------------------------------------------------
// ComplianceApi provider
// ---------------------------------------------------------------------------

/// Provides [ComplianceApi] for compliance endpoints.
final complianceApiProvider = Provider<ComplianceApi>(
  (ref) => ComplianceApi(ref.watch(apiClientProvider)),
);

// ---------------------------------------------------------------------------
// ComplianceWizardState
// ---------------------------------------------------------------------------

/// Immutable state for the Compliance Wizard multi-step flow.
class ComplianceWizardState {
  /// The current step index (0-based).
  final int currentStep;

  /// The selected project, or `null` if none.
  final Project? selectedProject;

  /// The selected branch name.
  final String? selectedBranch;

  /// Local filesystem path to the project repository.
  final String? localPath;

  /// Specification files uploaded for this compliance job.
  final List<SpecFile> specFiles;

  /// The set of selected agent types.
  final Set<AgentType> selectedAgents;

  /// Job configuration.
  final JobConfig config;

  /// Free-form additional context for agents.
  final String additionalContext;

  /// Whether the wizard is currently launching a job.
  final bool isLaunching;

  /// Error message from a failed launch attempt.
  final String? launchError;

  /// Creates a [ComplianceWizardState].
  const ComplianceWizardState({
    this.currentStep = 0,
    this.selectedProject,
    this.selectedBranch,
    this.localPath,
    this.specFiles = const [],
    this.selectedAgents = const {},
    this.config = const JobConfig(),
    this.additionalContext = '',
    this.isLaunching = false,
    this.launchError,
  });

  /// Creates a copy with the given fields replaced.
  ComplianceWizardState copyWith({
    int? currentStep,
    Project? selectedProject,
    String? selectedBranch,
    String? localPath,
    List<SpecFile>? specFiles,
    Set<AgentType>? selectedAgents,
    JobConfig? config,
    String? additionalContext,
    bool? isLaunching,
    String? launchError,
    bool clearLaunchError = false,
    bool clearLocalPath = false,
  }) {
    return ComplianceWizardState(
      currentStep: currentStep ?? this.currentStep,
      selectedProject: selectedProject ?? this.selectedProject,
      selectedBranch: selectedBranch ?? this.selectedBranch,
      localPath: clearLocalPath ? null : (localPath ?? this.localPath),
      specFiles: specFiles ?? this.specFiles,
      selectedAgents: selectedAgents ?? this.selectedAgents,
      config: config ?? this.config,
      additionalContext: additionalContext ?? this.additionalContext,
      isLaunching: isLaunching ?? this.isLaunching,
      launchError:
          clearLaunchError ? null : (launchError ?? this.launchError),
    );
  }
}

/// Default recommended agents for compliance mode per COC-012 spec.
const Set<AgentType> _complianceRecommendedAgents = {
  AgentType.security,
  AgentType.completeness,
  AgentType.apiContract,
  AgentType.testCoverage,
  AgentType.uiUx,
};

/// StateNotifier for managing the Compliance Wizard flow.
class ComplianceWizardNotifier extends StateNotifier<ComplianceWizardState> {
  /// Creates a [ComplianceWizardNotifier] with compliance recommended agents.
  ComplianceWizardNotifier()
      : super(const ComplianceWizardState(
          selectedAgents: _complianceRecommendedAgents,
        ));

  /// Moves to the next step.
  void nextStep() {
    state = state.copyWith(currentStep: state.currentStep + 1);
  }

  /// Moves to the previous step.
  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  /// Jumps to a specific step.
  void goToStep(int step) {
    state = state.copyWith(currentStep: step);
  }

  /// Sets the local filesystem path for the project repository.
  void setLocalPath(String path) {
    state = state.copyWith(localPath: path);
  }

  /// Sets the selected project and initializes the branch.
  ///
  /// Also attempts to auto-detect the local repository path.
  void selectProject(Project project) {
    state = state.copyWith(
      selectedProject: project,
      selectedBranch: project.defaultBranch ?? 'main',
      localPath: detectLocalProjectPath(project.name),
    );
  }

  /// Sets the selected branch.
  void selectBranch(String branch) {
    state = state.copyWith(selectedBranch: branch);
  }

  /// Adds specification files.
  void addSpecFiles(List<SpecFile> files) {
    state = state.copyWith(
      specFiles: [...state.specFiles, ...files],
    );
  }

  /// Removes a specification file by index.
  void removeSpec(int index) {
    final updated = List<SpecFile>.from(state.specFiles)..removeAt(index);
    state = state.copyWith(specFiles: updated);
  }

  /// Toggles a single agent type selection.
  void toggleAgent(AgentType agent) {
    final updated = Set<AgentType>.from(state.selectedAgents);
    if (updated.contains(agent)) {
      updated.remove(agent);
    } else {
      updated.add(agent);
    }
    state = state.copyWith(selectedAgents: updated);
  }

  /// Selects all agent types.
  void selectAllAgents() {
    state = state.copyWith(selectedAgents: AgentType.values.toSet());
  }

  /// Deselects all agent types.
  void selectNoAgents() {
    state = state.copyWith(selectedAgents: <AgentType>{});
  }

  /// Sets the recommended agents for compliance mode.
  void selectRecommendedAgents() {
    state = state.copyWith(selectedAgents: _complianceRecommendedAgents);
  }

  /// Updates the job configuration.
  void updateConfig(JobConfig config) {
    state = state.copyWith(config: config);
  }

  /// Sets additional context text.
  void setAdditionalContext(String context) {
    state = state.copyWith(additionalContext: context);
  }

  /// Marks the wizard as launching.
  void setLaunching(bool launching) {
    state = state.copyWith(isLaunching: launching, clearLaunchError: true);
  }

  /// Records a launch error.
  void setLaunchError(String error) {
    log.w('ComplianceWizard', 'Launch failed: $error');
    state = state.copyWith(isLaunching: false, launchError: error);
  }

  /// Resets the wizard to its initial state.
  void reset() {
    state = const ComplianceWizardState(
      selectedAgents: _complianceRecommendedAgents,
    );
  }
}

/// Provider for the Compliance Wizard state.
final complianceWizardStateProvider =
    StateNotifierProvider<ComplianceWizardNotifier, ComplianceWizardState>(
  (ref) => ComplianceWizardNotifier(),
);

// ---------------------------------------------------------------------------
// Compliance data providers
// ---------------------------------------------------------------------------

/// Fetches paginated specifications for a compliance job.
final complianceJobSpecsProvider = FutureProvider.autoDispose
    .family<PageResponse<Specification>, String>((ref, jobId) async {
  final api = ref.watch(complianceApiProvider);
  return api.getSpecificationsForJob(jobId);
});

/// Fetches paginated compliance items for a job.
final complianceJobItemsProvider = FutureProvider.autoDispose
    .family<PageResponse<ComplianceItem>, String>((ref, jobId) async {
  log.d('ComplianceProviders', 'Loading compliance items for jobId=$jobId');
  final api = ref.watch(complianceApiProvider);
  return api.getComplianceItemsForJob(jobId);
});

/// Fetches compliance items for a job filtered by status.
final complianceJobItemsByStatusProvider = FutureProvider.autoDispose
    .family<PageResponse<ComplianceItem>,
        ({String jobId, ComplianceStatus status})>((ref, params) async {
  final api = ref.watch(complianceApiProvider);
  return api.getComplianceItemsByStatus(params.jobId, params.status);
});

/// Fetches the compliance summary for a job.
final complianceSummaryProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, String>((ref, jobId) async {
  log.d('ComplianceProviders', 'Loading compliance summary for jobId=$jobId');
  final api = ref.watch(complianceApiProvider);
  return api.getComplianceSummary(jobId);
});

/// Derives a compliance score (0-100) from the summary.
///
/// Formula: (met + partial * 0.5) / total * 100
final complianceScoreProvider =
    FutureProvider.autoDispose.family<double, String>((ref, jobId) async {
  final summary = await ref.watch(complianceSummaryProvider(jobId).future);
  final met = (summary['met'] as num?)?.toDouble() ?? 0;
  final partial = (summary['partial'] as num?)?.toDouble() ?? 0;
  final total = (summary['total'] as num?)?.toDouble() ?? 0;
  if (total == 0) return 0;
  return (met + partial * 0.5) / total * 100;
});

/// Filter state for compliance status on the results panel.
final complianceStatusFilterProvider = StateProvider<ComplianceStatus?>(
  (ref) => null,
);

/// Filter state for agent type on the results panel.
final complianceAgentFilterProvider = StateProvider<AgentType?>(
  (ref) => null,
);
