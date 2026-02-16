// Tests for compliance providers.
//
// Verifies ComplianceWizardState defaults, copyWith, ComplianceWizardNotifier
// step navigation, project/branch selection, spec file management, agent
// toggling, additional context, launch state, reset, and derived score/filter
// providers.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:codeops/models/enums.dart';
import 'package:codeops/models/project.dart';
import 'package:codeops/providers/compliance_providers.dart';
import 'package:codeops/providers/wizard_providers.dart';

void main() {
  group('ComplianceWizardState', () {
    test('has correct defaults', () {
      const state = ComplianceWizardState();

      expect(state.currentStep, 0);
      expect(state.selectedProject, isNull);
      expect(state.selectedBranch, isNull);
      expect(state.localPath, isNull);
      expect(state.specFiles, isEmpty);
      expect(state.additionalContext, '');
      expect(state.isLaunching, isFalse);
      expect(state.launchError, isNull);
    });

    test('default selectedAgents is empty set', () {
      const state = ComplianceWizardState();
      expect(state.selectedAgents, isEmpty);
    });

    test('copyWith replaces specified fields', () {
      const state = ComplianceWizardState();
      final updated = state.copyWith(
        currentStep: 3,
        additionalContext: 'test context',
        isLaunching: true,
        localPath: '/tmp/test',
      );

      expect(updated.currentStep, 3);
      expect(updated.additionalContext, 'test context');
      expect(updated.isLaunching, isTrue);
      expect(updated.localPath, '/tmp/test');
      expect(updated.selectedProject, isNull);
      expect(updated.specFiles, isEmpty);
    });

    test('copyWith clearLocalPath clears the path', () {
      final state = const ComplianceWizardState().copyWith(
        localPath: '/tmp/project',
      );
      final updated = state.copyWith(clearLocalPath: true);

      expect(updated.localPath, isNull);
    });

    test('copyWith clearLaunchError clears the error', () {
      const state = ComplianceWizardState(launchError: 'something broke');
      final updated = state.copyWith(clearLaunchError: true);

      expect(updated.launchError, isNull);
    });

    test('copyWith preserves launchError when not cleared', () {
      const state = ComplianceWizardState(launchError: 'something broke');
      final updated = state.copyWith(currentStep: 1);

      expect(updated.launchError, 'something broke');
    });
  });

  group('ComplianceWizardNotifier', () {
    test('initial state has recommended compliance agents', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(complianceWizardStateProvider);

      expect(state.currentStep, 0);
      expect(state.selectedAgents, contains(AgentType.security));
      expect(state.selectedAgents, contains(AgentType.completeness));
      expect(state.selectedAgents, contains(AgentType.apiContract));
      expect(state.selectedAgents, contains(AgentType.testCoverage));
      expect(state.selectedAgents, contains(AgentType.uiUx));
      expect(state.selectedAgents.length, 5);
    });

    test('nextStep increments step', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(complianceWizardStateProvider.notifier).nextStep();

      expect(container.read(complianceWizardStateProvider).currentStep, 1);
    });

    test('previousStep decrements step', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(complianceWizardStateProvider.notifier);
      notifier.nextStep();
      notifier.nextStep();
      notifier.previousStep();

      expect(container.read(complianceWizardStateProvider).currentStep, 1);
    });

    test('previousStep does not go below 0', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container
          .read(complianceWizardStateProvider.notifier)
          .previousStep();

      expect(container.read(complianceWizardStateProvider).currentStep, 0);
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
      container
          .read(complianceWizardStateProvider.notifier)
          .selectProject(project);

      final state = container.read(complianceWizardStateProvider);

      expect(state.selectedProject?.id, 'p1');
      expect(state.selectedBranch, 'develop');
    });

    test('setLocalPath updates localPath', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container
          .read(complianceWizardStateProvider.notifier)
          .setLocalPath('/tmp/compliance-project');

      expect(
          container.read(complianceWizardStateProvider).localPath,
          '/tmp/compliance-project');
    });

    test('selectProject defaults branch to main when null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      const project = Project(
        id: 'p2',
        teamId: 't1',
        name: 'No Branch Project',
      );
      container
          .read(complianceWizardStateProvider.notifier)
          .selectProject(project);

      final state = container.read(complianceWizardStateProvider);

      expect(state.selectedBranch, 'main');
    });

    test('selectBranch sets the branch', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container
          .read(complianceWizardStateProvider.notifier)
          .selectBranch('feature/test');

      expect(container.read(complianceWizardStateProvider).selectedBranch,
          'feature/test');
    });

    test('addSpecFiles appends files', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(complianceWizardStateProvider.notifier);

      notifier.addSpecFiles([
        const SpecFile(
          name: 'spec1.yaml',
          path: '/tmp/spec1.yaml',
          sizeBytes: 1024,
          contentType: 'application/yaml',
        ),
      ]);
      notifier.addSpecFiles([
        const SpecFile(
          name: 'spec2.md',
          path: '/tmp/spec2.md',
          sizeBytes: 2048,
          contentType: 'text/markdown',
        ),
      ]);

      final state = container.read(complianceWizardStateProvider);

      expect(state.specFiles, hasLength(2));
      expect(state.specFiles[0].name, 'spec1.yaml');
      expect(state.specFiles[1].name, 'spec2.md');
    });

    test('removeSpec removes file at index', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(complianceWizardStateProvider.notifier);

      notifier.addSpecFiles([
        const SpecFile(
          name: 'a.yaml',
          path: '/tmp/a.yaml',
          sizeBytes: 100,
          contentType: 'application/yaml',
        ),
        const SpecFile(
          name: 'b.yaml',
          path: '/tmp/b.yaml',
          sizeBytes: 200,
          contentType: 'application/yaml',
        ),
      ]);
      notifier.removeSpec(0);

      final state = container.read(complianceWizardStateProvider);

      expect(state.specFiles, hasLength(1));
      expect(state.specFiles[0].name, 'b.yaml');
    });

    test('toggleAgent toggles selection on and off', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(complianceWizardStateProvider.notifier);

      // Security is initially selected, toggle it off.
      notifier.toggleAgent(AgentType.security);

      expect(
          container.read(complianceWizardStateProvider).selectedAgents,
          isNot(contains(AgentType.security)));

      // Toggle it back on.
      notifier.toggleAgent(AgentType.security);

      expect(
          container.read(complianceWizardStateProvider).selectedAgents,
          contains(AgentType.security));
    });

    test('selectAllAgents selects every agent type', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(complianceWizardStateProvider.notifier);
      notifier.selectNoAgents();
      notifier.selectAllAgents();

      expect(
          container
              .read(complianceWizardStateProvider)
              .selectedAgents
              .length,
          AgentType.values.length);
    });

    test('selectNoAgents clears all agents', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container
          .read(complianceWizardStateProvider.notifier)
          .selectNoAgents();

      expect(
          container.read(complianceWizardStateProvider).selectedAgents,
          isEmpty);
    });

    test('selectRecommendedAgents restores the 5 recommended agents', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(complianceWizardStateProvider.notifier);
      notifier.selectNoAgents();
      notifier.selectRecommendedAgents();

      final agents =
          container.read(complianceWizardStateProvider).selectedAgents;

      expect(agents.length, 5);
      expect(agents, contains(AgentType.security));
      expect(agents, contains(AgentType.completeness));
      expect(agents, contains(AgentType.apiContract));
      expect(agents, contains(AgentType.testCoverage));
      expect(agents, contains(AgentType.uiUx));
    });

    test('setAdditionalContext updates context', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container
          .read(complianceWizardStateProvider.notifier)
          .setAdditionalContext('Check HIPAA requirements');

      expect(
          container
              .read(complianceWizardStateProvider)
              .additionalContext,
          'Check HIPAA requirements');
    });

    test('setLaunching sets flag and clears error', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(complianceWizardStateProvider.notifier);
      notifier.setLaunchError('failed');
      notifier.setLaunching(true);

      final state = container.read(complianceWizardStateProvider);

      expect(state.isLaunching, isTrue);
      expect(state.launchError, isNull);
    });

    test('setLaunchError sets error and clears launching', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(complianceWizardStateProvider.notifier);
      notifier.setLaunching(true);
      notifier.setLaunchError('API timeout');

      final state = container.read(complianceWizardStateProvider);

      expect(state.isLaunching, isFalse);
      expect(state.launchError, 'API timeout');
    });

    test('reset restores initial state with recommended agents', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(complianceWizardStateProvider.notifier);
      notifier.nextStep();
      notifier.nextStep();
      notifier.selectNoAgents();
      notifier.setAdditionalContext('context');
      notifier.setLaunching(true);
      notifier.reset();

      final state = container.read(complianceWizardStateProvider);

      expect(state.currentStep, 0);
      expect(state.selectedAgents.length, 5);
      expect(state.additionalContext, '');
      expect(state.isLaunching, isFalse);
      expect(state.specFiles, isEmpty);
    });
  });

  group('complianceScoreProvider', () {
    test('10 met, 0 partial, 0 missing = 100%', () async {
      final container = ProviderContainer(
        overrides: [
          complianceSummaryProvider('j1').overrideWith(
            (ref) => Future.value({
              'met': 10,
              'partial': 0,
              'missing': 0,
              'notApplicable': 0,
              'total': 10,
            }),
          ),
        ],
      );
      addTearDown(container.dispose);

      final score =
          await container.read(complianceScoreProvider('j1').future);

      expect(score, 100.0);
    });

    test('0 met, 10 partial, 0 missing = 50%', () async {
      final container = ProviderContainer(
        overrides: [
          complianceSummaryProvider('j1').overrideWith(
            (ref) => Future.value({
              'met': 0,
              'partial': 10,
              'missing': 0,
              'notApplicable': 0,
              'total': 10,
            }),
          ),
        ],
      );
      addTearDown(container.dispose);

      final score =
          await container.read(complianceScoreProvider('j1').future);

      expect(score, 50.0);
    });

    test('5 met, 4 partial, 1 missing = 70%', () async {
      final container = ProviderContainer(
        overrides: [
          complianceSummaryProvider('j1').overrideWith(
            (ref) => Future.value({
              'met': 5,
              'partial': 4,
              'missing': 1,
              'notApplicable': 0,
              'total': 10,
            }),
          ),
        ],
      );
      addTearDown(container.dispose);

      final score =
          await container.read(complianceScoreProvider('j1').future);

      // (5 + 4*0.5) / 10 * 100 = 70
      expect(score, 70.0);
    });

    test('0 met, 0 partial, 10 missing = 0%', () async {
      final container = ProviderContainer(
        overrides: [
          complianceSummaryProvider('j1').overrideWith(
            (ref) => Future.value({
              'met': 0,
              'partial': 0,
              'missing': 10,
              'notApplicable': 0,
              'total': 10,
            }),
          ),
        ],
      );
      addTearDown(container.dispose);

      final score =
          await container.read(complianceScoreProvider('j1').future);

      expect(score, 0.0);
    });

    test('0 total = 0%', () async {
      final container = ProviderContainer(
        overrides: [
          complianceSummaryProvider('j1').overrideWith(
            (ref) => Future.value({
              'met': 0,
              'partial': 0,
              'missing': 0,
              'notApplicable': 0,
              'total': 0,
            }),
          ),
        ],
      );
      addTearDown(container.dispose);

      final score =
          await container.read(complianceScoreProvider('j1').future);

      expect(score, 0.0);
    });
  });

  group('complianceStatusFilterProvider', () {
    test('defaults to null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(complianceStatusFilterProvider), isNull);
    });

    test('can be updated', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(complianceStatusFilterProvider.notifier).state =
          ComplianceStatus.met;

      expect(container.read(complianceStatusFilterProvider),
          ComplianceStatus.met);
    });
  });

  group('complianceAgentFilterProvider', () {
    test('defaults to null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(complianceAgentFilterProvider), isNull);
    });

    test('can be updated', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(complianceAgentFilterProvider.notifier).state =
          AgentType.security;

      expect(container.read(complianceAgentFilterProvider),
          AgentType.security);
    });
  });
}
