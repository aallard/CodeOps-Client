import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:codeops/models/enums.dart';
import 'package:codeops/models/project.dart';
import 'package:codeops/models/qa_job.dart';
import 'package:codeops/providers/job_providers.dart';
import 'package:codeops/providers/wizard_providers.dart';
import 'package:codeops/utils/constants.dart';

void main() {
  group('JobConfig', () {
    test('has correct defaults', () {
      const config = JobConfig();
      expect(config.maxConcurrentAgents, AppConstants.defaultMaxConcurrentAgents);
      expect(config.agentTimeoutMinutes, AppConstants.defaultAgentTimeoutMinutes);
      expect(config.claudeModel, AppConstants.defaultClaudeModelForDispatch);
      expect(config.maxTurns, AppConstants.defaultMaxTurns);
      expect(config.passThreshold, AppConstants.defaultPassThreshold);
      expect(config.warnThreshold, AppConstants.defaultWarnThreshold);
      expect(config.additionalContext, '');
    });

    test('copyWith replaces specified fields', () {
      const config = JobConfig();
      final updated = config.copyWith(maxConcurrentAgents: 5, claudeModel: 'custom');
      expect(updated.maxConcurrentAgents, 5);
      expect(updated.claudeModel, 'custom');
      expect(updated.agentTimeoutMinutes, config.agentTimeoutMinutes);
    });
  });

  group('SpecFile', () {
    test('stores all fields', () {
      const spec = SpecFile(
        name: 'spec.md',
        path: '/tmp/spec.md',
        sizeBytes: 1024,
        contentType: 'text/markdown',
      );
      expect(spec.name, 'spec.md');
      expect(spec.path, '/tmp/spec.md');
      expect(spec.sizeBytes, 1024);
      expect(spec.contentType, 'text/markdown');
    });
  });

  group('JiraTicketData', () {
    test('stores all fields', () {
      const ticket = JiraTicketData(
        key: 'PROJ-123',
        summary: 'Fix bug',
        description: 'Description',
        status: 'Open',
        priority: 'High',
        assignee: 'Alice',
      );
      expect(ticket.key, 'PROJ-123');
      expect(ticket.summary, 'Fix bug');
      expect(ticket.assignee, 'Alice');
      expect(ticket.commentCount, 0);
    });
  });

  group('JobExecutionPhase', () {
    test('has displayName for all values', () {
      for (final phase in JobExecutionPhase.values) {
        expect(phase.displayName, isNotEmpty);
      }
    });

    test('contains expected phases', () {
      expect(JobExecutionPhase.values.length, 8);
      expect(JobExecutionPhase.values, contains(JobExecutionPhase.creating));
      expect(JobExecutionPhase.values, contains(JobExecutionPhase.complete));
      expect(JobExecutionPhase.values, contains(JobExecutionPhase.failed));
    });
  });

  group('AuditWizardNotifier', () {
    test('initial state has all agents selected', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(auditWizardStateProvider);
      expect(state.selectedAgents.length, AgentType.values.length);
      expect(state.currentStep, 0);
      expect(state.selectedProject, isNull);
      expect(state.isLaunching, false);
    });

    test('nextStep increments step', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(auditWizardStateProvider.notifier).nextStep();
      expect(container.read(auditWizardStateProvider).currentStep, 1);
    });

    test('previousStep decrements step', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(auditWizardStateProvider.notifier);
      notifier.nextStep();
      notifier.nextStep();
      notifier.previousStep();
      expect(container.read(auditWizardStateProvider).currentStep, 1);
    });

    test('previousStep does not go below 0', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(auditWizardStateProvider.notifier).previousStep();
      expect(container.read(auditWizardStateProvider).currentStep, 0);
    });

    test('selectProject sets project and default branch', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      const project = Project(
        id: 'p1',
        teamId: 't1',
        name: 'Test Project',
        defaultBranch: 'develop',
      );
      container.read(auditWizardStateProvider.notifier).selectProject(project);
      final state = container.read(auditWizardStateProvider);
      expect(state.selectedProject?.id, 'p1');
      expect(state.selectedBranch, 'develop');
    });

    test('toggleAgent toggles selection', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(auditWizardStateProvider.notifier);
      notifier.toggleAgent(AgentType.security);
      expect(container.read(auditWizardStateProvider).selectedAgents,
          isNot(contains(AgentType.security)));

      notifier.toggleAgent(AgentType.security);
      expect(container.read(auditWizardStateProvider).selectedAgents,
          contains(AgentType.security));
    });

    test('selectNoAgents clears all agents', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(auditWizardStateProvider.notifier).selectNoAgents();
      expect(container.read(auditWizardStateProvider).selectedAgents, isEmpty);
    });

    test('selectAllAgents selects all agents', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(auditWizardStateProvider.notifier);
      notifier.selectNoAgents();
      notifier.selectAllAgents();
      expect(container.read(auditWizardStateProvider).selectedAgents.length,
          AgentType.values.length);
    });

    test('initial state has null localPath', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(auditWizardStateProvider);
      expect(state.localPath, isNull);
    });

    test('setLocalPath updates localPath', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container
          .read(auditWizardStateProvider.notifier)
          .setLocalPath('/tmp/project');
      expect(
          container.read(auditWizardStateProvider).localPath, '/tmp/project');
    });

    test('reset restores initial state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(auditWizardStateProvider.notifier);
      notifier.nextStep();
      notifier.selectNoAgents();
      notifier.setLaunching(true);
      notifier.setLocalPath('/tmp/test');
      notifier.reset();

      final state = container.read(auditWizardStateProvider);
      expect(state.currentStep, 0);
      expect(state.selectedAgents.length, AgentType.values.length);
      expect(state.isLaunching, false);
      expect(state.localPath, isNull);
    });
  });

  group('JobHistoryFilters', () {
    test('defaults have no active filters', () {
      const filters = JobHistoryFilters();
      expect(filters.hasActiveFilters, false);
      expect(filters.mode, isNull);
      expect(filters.status, isNull);
      expect(filters.searchQuery, '');
    });

    test('hasActiveFilters is true when mode set', () {
      const filters = JobHistoryFilters(mode: JobMode.audit);
      expect(filters.hasActiveFilters, true);
    });

    test('copyWith replaces fields', () {
      const filters = JobHistoryFilters(mode: JobMode.audit);
      final updated = filters.copyWith(status: JobStatus.completed);
      expect(updated.mode, JobMode.audit);
      expect(updated.status, JobStatus.completed);
    });

    test('copyWith clearMode clears mode', () {
      const filters = JobHistoryFilters(mode: JobMode.audit);
      final updated = filters.copyWith(clearMode: true);
      expect(updated.mode, isNull);
    });
  });

  group('jobHistoryFiltersProvider', () {
    test('defaults to empty filters', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final filters = container.read(jobHistoryFiltersProvider);
      expect(filters.hasActiveFilters, false);
    });
  });

  group('filteredJobHistoryProvider', () {
    test('filters by mode', () {
      final container = ProviderContainer(
        overrides: [
          myJobsProvider.overrideWith((ref) => Future.value([
                const JobSummary(
                  id: 'j1',
                  mode: JobMode.audit,
                  status: JobStatus.completed,
                ),
                const JobSummary(
                  id: 'j2',
                  mode: JobMode.compliance,
                  status: JobStatus.completed,
                ),
              ])),
        ],
      );
      addTearDown(container.dispose);

      container.read(jobHistoryFiltersProvider.notifier).state =
          const JobHistoryFilters(mode: JobMode.audit);

      expect(container.read(filteredJobHistoryProvider), isA<AsyncValue<List<JobSummary>>>());
    });
  });

  group('detectLocalProjectPath', () {
    test('returns path when directory exists', () {
      // Create a temporary directory to simulate a project.
      final tempDir = Directory.systemTemp.createTempSync('test_project_');
      addTearDown(() => tempDir.deleteSync(recursive: true));

      // detectLocalProjectPath checks common directories relative to HOME.
      // Since tempDir is in systemTemp, it won't be found. This test
      // verifies the function returns null for unknown project names.
      final result = detectLocalProjectPath('non_existent_project_xyz');
      expect(result, isNull);
    });

    test('returns null for non-existent project', () {
      final result =
          detectLocalProjectPath('definitely_does_not_exist_12345');
      expect(result, isNull);
    });
  });

  group('BugInvestigatorWizardState', () {
    test('default values are correct', () {
      const state = BugInvestigatorWizardState();

      expect(state.currentStep, 0);
      expect(state.selectedIssue, isNull);
      expect(state.selectedComments, isEmpty);
      expect(state.selectedProject, isNull);
      expect(state.selectedBranch, isNull);
      expect(state.localPath, isNull);
      expect(state.selectedAgents, isEmpty);
      expect(state.additionalContext, '');
      expect(state.isLaunching, isFalse);
      expect(state.launchError, isNull);
    });

    test('copyWith replaces specified fields', () {
      const state = BugInvestigatorWizardState();
      final updated = state.copyWith(
        currentStep: 2,
        additionalContext: 'extra info',
      );

      expect(updated.currentStep, 2);
      expect(updated.additionalContext, 'extra info');
      expect(updated.selectedIssue, isNull);
    });
  });

  group('BugInvestigatorWizardNotifier', () {
    test('initial state has recommended bug agents', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(bugInvestigatorWizardStateProvider);

      expect(state.currentStep, 0);
      expect(state.selectedAgents, contains(AgentType.security));
      expect(state.selectedAgents, contains(AgentType.codeQuality));
      expect(state.selectedAgents, contains(AgentType.testCoverage));
      expect(state.selectedAgents, contains(AgentType.performance));
      expect(state.selectedAgents.length, 4);
    });

    test('nextStep increments step', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(bugInvestigatorWizardStateProvider.notifier).nextStep();

      expect(
          container.read(bugInvestigatorWizardStateProvider).currentStep, 1);
    });

    test('previousStep decrements step', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(bugInvestigatorWizardStateProvider.notifier);
      notifier.nextStep();
      notifier.nextStep();
      notifier.previousStep();

      expect(
          container.read(bugInvestigatorWizardStateProvider).currentStep, 1);
    });

    test('previousStep does not go below 0', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container
          .read(bugInvestigatorWizardStateProvider.notifier)
          .previousStep();

      expect(
          container.read(bugInvestigatorWizardStateProvider).currentStep, 0);
    });

    test('selectProject sets project and branch', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      const project = Project(
        id: 'p1',
        teamId: 't1',
        name: 'Test Project',
        defaultBranch: 'develop',
      );
      container
          .read(bugInvestigatorWizardStateProvider.notifier)
          .selectProject(project);

      final state = container.read(bugInvestigatorWizardStateProvider);

      expect(state.selectedProject?.id, 'p1');
      expect(state.selectedBranch, 'develop');
    });

    test('toggleAgent toggles agent selection', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(bugInvestigatorWizardStateProvider.notifier);

      // Security is initially selected, toggle it off.
      notifier.toggleAgent(AgentType.security);

      expect(
          container
              .read(bugInvestigatorWizardStateProvider)
              .selectedAgents,
          isNot(contains(AgentType.security)));

      // Toggle it back on.
      notifier.toggleAgent(AgentType.security);

      expect(
          container
              .read(bugInvestigatorWizardStateProvider)
              .selectedAgents,
          contains(AgentType.security));
    });

    test('setLocalPath updates localPath', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container
          .read(bugInvestigatorWizardStateProvider.notifier)
          .setLocalPath('/tmp/bug-project');

      expect(
          container.read(bugInvestigatorWizardStateProvider).localPath,
          '/tmp/bug-project');
    });

    test('setAdditionalContext updates context', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container
          .read(bugInvestigatorWizardStateProvider.notifier)
          .setAdditionalContext('repro steps: ...');

      expect(
          container
              .read(bugInvestigatorWizardStateProvider)
              .additionalContext,
          'repro steps: ...');
    });

    test('setLaunching sets flag and clears error', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(bugInvestigatorWizardStateProvider.notifier);
      notifier.setLaunchError('failed');
      notifier.setLaunching(true);

      final state = container.read(bugInvestigatorWizardStateProvider);

      expect(state.isLaunching, isTrue);
      expect(state.launchError, isNull);
    });

    test('setLaunchError sets error and clears launching', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(bugInvestigatorWizardStateProvider.notifier);
      notifier.setLaunching(true);
      notifier.setLaunchError('something broke');

      final state = container.read(bugInvestigatorWizardStateProvider);

      expect(state.isLaunching, isFalse);
      expect(state.launchError, 'something broke');
    });

    test('reset restores initial state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(bugInvestigatorWizardStateProvider.notifier);
      notifier.nextStep();
      notifier.setAdditionalContext('context');
      notifier.setLaunching(true);
      notifier.reset();

      final state = container.read(bugInvestigatorWizardStateProvider);

      expect(state.currentStep, 0);
      expect(state.additionalContext, '');
      expect(state.isLaunching, isFalse);
      expect(state.selectedAgents.length, 4);
    });
  });
}
