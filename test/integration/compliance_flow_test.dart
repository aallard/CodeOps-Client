import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import 'package:codeops/models/enums.dart';
import 'package:codeops/models/project.dart';
import 'package:codeops/providers/compliance_providers.dart';
import 'package:codeops/providers/wizard_providers.dart';
import 'package:codeops/services/cloud/compliance_api.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockComplianceApi extends Mock implements ComplianceApi {}

void main() {
  late MockComplianceApi mockComplianceApi;

  setUp(() {
    mockComplianceApi = MockComplianceApi();
  });

  /// Creates a [ProviderContainer] with mocked API providers.
  ProviderContainer createContainer() {
    final container = ProviderContainer(
      overrides: [
        complianceApiProvider.overrideWithValue(mockComplianceApi),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  const testProject = Project(id: 'p1', teamId: 't1', name: 'Test');
  const testSpec =
      SpecFile(name: 'spec.md', path: '/tmp/spec.md', sizeBytes: 1024, contentType: 'text/markdown');
  const testSpec2 =
      SpecFile(name: 'api.yaml', path: '/tmp/api.yaml', sizeBytes: 2048, contentType: 'application/yaml');

  group('ComplianceWizardNotifier — step transitions', () {
    test('initial state is step 0 with recommended agents', () {
      final container = createContainer();

      final state = container.read(complianceWizardStateProvider);
      expect(state.currentStep, 0);
      expect(state.selectedProject, isNull);
      expect(state.selectedBranch, isNull);
      expect(state.specFiles, isEmpty);
      expect(state.isLaunching, isFalse);
      expect(state.launchError, isNull);
      expect(state.additionalContext, isEmpty);

      // Default recommended agents for compliance.
      expect(state.selectedAgents, contains(AgentType.security));
      expect(state.selectedAgents, contains(AgentType.completeness));
      expect(state.selectedAgents, contains(AgentType.apiContract));
      expect(state.selectedAgents, contains(AgentType.testCoverage));
      expect(state.selectedAgents, contains(AgentType.uiUx));
    });

    test('nextStep increments currentStep', () {
      final container = createContainer();
      final notifier = container.read(complianceWizardStateProvider.notifier);

      notifier.nextStep();
      expect(container.read(complianceWizardStateProvider).currentStep, 1);

      notifier.nextStep();
      expect(container.read(complianceWizardStateProvider).currentStep, 2);

      notifier.nextStep();
      expect(container.read(complianceWizardStateProvider).currentStep, 3);
    });

    test('previousStep decrements currentStep but not below 0', () {
      final container = createContainer();
      final notifier = container.read(complianceWizardStateProvider.notifier);

      // Go to step 2.
      notifier.nextStep();
      notifier.nextStep();
      expect(container.read(complianceWizardStateProvider).currentStep, 2);

      notifier.previousStep();
      expect(container.read(complianceWizardStateProvider).currentStep, 1);

      notifier.previousStep();
      expect(container.read(complianceWizardStateProvider).currentStep, 0);

      // Should not go below 0.
      notifier.previousStep();
      expect(container.read(complianceWizardStateProvider).currentStep, 0);
    });

    test('goToStep jumps to the given step', () {
      final container = createContainer();
      final notifier = container.read(complianceWizardStateProvider.notifier);

      notifier.goToStep(3);
      expect(container.read(complianceWizardStateProvider).currentStep, 3);

      notifier.goToStep(1);
      expect(container.read(complianceWizardStateProvider).currentStep, 1);
    });
  });

  group('ComplianceWizardNotifier — project & branch selection', () {
    test('selectProject sets project and default branch', () {
      final container = createContainer();
      final notifier = container.read(complianceWizardStateProvider.notifier);

      notifier.selectProject(testProject);

      final state = container.read(complianceWizardStateProvider);
      expect(state.selectedProject?.id, 'p1');
      expect(state.selectedProject?.name, 'Test');
      // defaultBranch is null on testProject, so it defaults to 'main'.
      expect(state.selectedBranch, 'main');
    });

    test('selectProject with defaultBranch uses that branch', () {
      final container = createContainer();
      final notifier = container.read(complianceWizardStateProvider.notifier);

      const projectWithBranch = Project(
        id: 'p3',
        teamId: 't1',
        name: 'Branched',
        defaultBranch: 'develop',
      );
      notifier.selectProject(projectWithBranch);

      final state = container.read(complianceWizardStateProvider);
      expect(state.selectedBranch, 'develop');
    });

    test('selectBranch overrides branch', () {
      final container = createContainer();
      final notifier = container.read(complianceWizardStateProvider.notifier);

      notifier.selectProject(testProject);
      notifier.selectBranch('feature/new');

      expect(container.read(complianceWizardStateProvider).selectedBranch,
          'feature/new');
    });
  });

  group('ComplianceWizardNotifier — spec file operations', () {
    test('addSpecFiles appends files to the list', () {
      final container = createContainer();
      final notifier = container.read(complianceWizardStateProvider.notifier);

      notifier.addSpecFiles([testSpec]);
      expect(container.read(complianceWizardStateProvider).specFiles.length, 1);
      expect(
          container.read(complianceWizardStateProvider).specFiles[0].name, 'spec.md');

      notifier.addSpecFiles([testSpec2]);
      expect(container.read(complianceWizardStateProvider).specFiles.length, 2);
      expect(
          container.read(complianceWizardStateProvider).specFiles[1].name, 'api.yaml');
    });

    test('removeSpec removes file at the given index', () {
      final container = createContainer();
      final notifier = container.read(complianceWizardStateProvider.notifier);

      notifier.addSpecFiles([testSpec, testSpec2]);
      expect(container.read(complianceWizardStateProvider).specFiles.length, 2);

      notifier.removeSpec(0);
      final remaining = container.read(complianceWizardStateProvider).specFiles;
      expect(remaining.length, 1);
      expect(remaining[0].name, 'api.yaml');
    });

    test('removeSpec of last item leaves empty list', () {
      final container = createContainer();
      final notifier = container.read(complianceWizardStateProvider.notifier);

      notifier.addSpecFiles([testSpec]);
      notifier.removeSpec(0);
      expect(container.read(complianceWizardStateProvider).specFiles, isEmpty);
    });
  });

  group('ComplianceWizardNotifier — agent selection', () {
    test('toggleAgent adds an agent not in the set', () {
      final container = createContainer();
      final notifier = container.read(complianceWizardStateProvider.notifier);

      // Start with recommended agents. Documentation is NOT in the recommended set.
      final initialState = container.read(complianceWizardStateProvider);
      expect(initialState.selectedAgents.contains(AgentType.documentation),
          isFalse);

      notifier.toggleAgent(AgentType.documentation);
      expect(
          container
              .read(complianceWizardStateProvider)
              .selectedAgents
              .contains(AgentType.documentation),
          isTrue);
    });

    test('toggleAgent removes an agent already in the set', () {
      final container = createContainer();
      final notifier = container.read(complianceWizardStateProvider.notifier);

      // Security is in the recommended set.
      expect(
          container
              .read(complianceWizardStateProvider)
              .selectedAgents
              .contains(AgentType.security),
          isTrue);

      notifier.toggleAgent(AgentType.security);
      expect(
          container
              .read(complianceWizardStateProvider)
              .selectedAgents
              .contains(AgentType.security),
          isFalse);
    });

    test('selectAllAgents selects every AgentType', () {
      final container = createContainer();
      final notifier = container.read(complianceWizardStateProvider.notifier);

      notifier.selectAllAgents();

      final agents = container.read(complianceWizardStateProvider).selectedAgents;
      expect(agents.length, AgentType.values.length);
      for (final agent in AgentType.values) {
        expect(agents.contains(agent), isTrue, reason: '$agent should be selected');
      }
    });

    test('selectNoAgents clears all agents', () {
      final container = createContainer();
      final notifier = container.read(complianceWizardStateProvider.notifier);

      notifier.selectNoAgents();
      expect(
          container.read(complianceWizardStateProvider).selectedAgents, isEmpty);
    });

    test('selectRecommendedAgents restores recommended set', () {
      final container = createContainer();
      final notifier = container.read(complianceWizardStateProvider.notifier);

      // Clear all first.
      notifier.selectNoAgents();
      expect(
          container.read(complianceWizardStateProvider).selectedAgents, isEmpty);

      // Restore recommended.
      notifier.selectRecommendedAgents();
      final agents = container.read(complianceWizardStateProvider).selectedAgents;
      expect(agents, contains(AgentType.security));
      expect(agents, contains(AgentType.completeness));
      expect(agents, contains(AgentType.apiContract));
      expect(agents, contains(AgentType.testCoverage));
      expect(agents, contains(AgentType.uiUx));
    });
  });

  group('ComplianceWizardNotifier — additional context', () {
    test('setAdditionalContext stores free-form text', () {
      final container = createContainer();
      final notifier = container.read(complianceWizardStateProvider.notifier);

      notifier.setAdditionalContext('Must comply with GDPR');
      expect(container.read(complianceWizardStateProvider).additionalContext,
          'Must comply with GDPR');
    });
  });

  group('ComplianceWizardNotifier — launching', () {
    test('setLaunching(true) sets isLaunching and clears error', () {
      final container = createContainer();
      final notifier = container.read(complianceWizardStateProvider.notifier);

      // Set an error first.
      notifier.setLaunchError('some error');
      expect(container.read(complianceWizardStateProvider).launchError,
          'some error');

      notifier.setLaunching(true);
      final state = container.read(complianceWizardStateProvider);
      expect(state.isLaunching, isTrue);
      expect(state.launchError, isNull);
    });

    test('setLaunchError records error and clears isLaunching', () {
      final container = createContainer();
      final notifier = container.read(complianceWizardStateProvider.notifier);

      notifier.setLaunching(true);
      notifier.setLaunchError('Connection timeout');

      final state = container.read(complianceWizardStateProvider);
      expect(state.isLaunching, isFalse);
      expect(state.launchError, 'Connection timeout');
    });
  });

  group('ComplianceWizardNotifier — reset', () {
    test('reset clears all state back to initial', () {
      final container = createContainer();
      final notifier = container.read(complianceWizardStateProvider.notifier);

      // Modify everything.
      notifier.selectProject(testProject);
      notifier.selectBranch('feature/x');
      notifier.addSpecFiles([testSpec, testSpec2]);
      notifier.selectAllAgents();
      notifier.setAdditionalContext('Custom context');
      notifier.nextStep();
      notifier.nextStep();

      // Verify state is modified.
      final beforeReset = container.read(complianceWizardStateProvider);
      expect(beforeReset.currentStep, 2);
      expect(beforeReset.selectedProject, isNotNull);
      expect(beforeReset.specFiles.length, 2);
      expect(beforeReset.additionalContext, 'Custom context');

      // Reset.
      notifier.reset();

      final afterReset = container.read(complianceWizardStateProvider);
      expect(afterReset.currentStep, 0);
      expect(afterReset.selectedProject, isNull);
      expect(afterReset.selectedBranch, isNull);
      expect(afterReset.specFiles, isEmpty);
      expect(afterReset.additionalContext, isEmpty);
      expect(afterReset.isLaunching, isFalse);
      expect(afterReset.launchError, isNull);

      // Should have recommended agents restored.
      expect(afterReset.selectedAgents, contains(AgentType.security));
      expect(afterReset.selectedAgents, contains(AgentType.completeness));
      expect(afterReset.selectedAgents, contains(AgentType.apiContract));
    });
  });

  group('ComplianceWizardNotifier — full wizard flow', () {
    test('simulates select project -> add specs -> select agents -> ready',
        () {
      final container = createContainer();
      final notifier = container.read(complianceWizardStateProvider.notifier);

      // Step 0: Select project.
      notifier.selectProject(testProject);
      notifier.selectBranch('main');
      var state = container.read(complianceWizardStateProvider);
      expect(state.selectedProject?.id, 'p1');
      expect(state.selectedBranch, 'main');

      // Advance to Step 1.
      notifier.nextStep();
      expect(container.read(complianceWizardStateProvider).currentStep, 1);

      // Step 1: Add spec files.
      notifier.addSpecFiles([testSpec]);
      notifier.addSpecFiles([testSpec2]);
      state = container.read(complianceWizardStateProvider);
      expect(state.specFiles.length, 2);

      // Advance to Step 2.
      notifier.nextStep();
      expect(container.read(complianceWizardStateProvider).currentStep, 2);

      // Step 2: Select agents.
      notifier.selectNoAgents();
      notifier.toggleAgent(AgentType.security);
      notifier.toggleAgent(AgentType.apiContract);
      state = container.read(complianceWizardStateProvider);
      expect(state.selectedAgents.length, 2);
      expect(state.selectedAgents, contains(AgentType.security));
      expect(state.selectedAgents, contains(AgentType.apiContract));

      // Set additional context.
      notifier.setAdditionalContext('Focus on API compliance');

      // Advance to Step 3 (Review).
      notifier.nextStep();
      expect(container.read(complianceWizardStateProvider).currentStep, 3);

      // Verify final state before launch.
      state = container.read(complianceWizardStateProvider);
      expect(state.selectedProject?.name, 'Test');
      expect(state.selectedBranch, 'main');
      expect(state.specFiles.length, 2);
      expect(state.selectedAgents.length, 2);
      expect(state.additionalContext, 'Focus on API compliance');
      expect(state.isLaunching, isFalse);
    });
  });
}
