import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:codeops/pages/compliance_wizard_page.dart';
import 'package:codeops/providers/project_providers.dart';
import 'package:codeops/widgets/wizard/wizard_scaffold.dart';

void main() {
  Widget createWidget({List<Override> overrides = const []}) {
    final router = GoRouter(
      initialLocation: '/compliance',
      routes: [
        GoRoute(
          path: '/compliance',
          builder: (_, __) => const Scaffold(body: ComplianceWizardPage()),
        ),
        GoRoute(
          path: '/',
          builder: (_, __) => const Scaffold(body: Text('Home')),
        ),
        GoRoute(
          path: '/jobs/:id',
          builder: (_, state) =>
              Scaffold(body: Text('Job ${state.pathParameters['id']}')),
        ),
        GoRoute(
          path: '/history',
          builder: (_, __) => const Scaffold(body: Text('History')),
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        teamProjectsProvider.overrideWith((ref) => Future.value([])),
        ...overrides,
      ],
      child: MaterialApp.router(
        routerConfig: router,
      ),
    );
  }

  group('ComplianceWizardPage', () {
    testWidgets('renders wizard with Compliance Wizard title', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Compliance Wizard'), findsOneWidget);
    });

    testWidgets('shows WizardScaffold', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.byType(WizardScaffold), findsOneWidget);
    });

    testWidgets('shows 4 step titles: Source, Specifications, Agents, Review',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Source'), findsOneWidget);
      expect(find.text('Specifications'), findsOneWidget);
      expect(find.text('Agents'), findsOneWidget);
      expect(find.text('Review'), findsOneWidget);
    });

    testWidgets('initial step is Source (shows Select Source content)',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      // SourceStep renders 'Select Source' as its title.
      expect(find.text('Select Source'), findsOneWidget);
    });

    testWidgets('initial step shows Next button (not Launch)',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      // On step 0 the bottom nav shows "Next", not the launch label.
      // The launch label ("Launch Compliance Check") only appears on the
      // final step (Review). Verify "Next" is present on step 0.
      expect(find.text('Next'), findsOneWidget);
    });

    testWidgets('shows Cancel button', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Cancel'), findsOneWidget);
    });
  });
}
