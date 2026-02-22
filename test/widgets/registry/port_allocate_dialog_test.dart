// Tests for PortAllocateDialog.
//
// Verifies dialog rendering, tab switching, form fields, validation,
// and manual mode port number input.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/registry_enums.dart';
import 'package:codeops/models/registry_models.dart';
import 'package:codeops/models/health_snapshot.dart';
import 'package:codeops/providers/registry_providers.dart';
import 'package:codeops/widgets/registry/port_allocate_dialog.dart';

void _setWideViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1200, 1000);
  tester.view.devicePixelRatio = 1.0;
}

Widget _buildDialog({
  String? preselectedServiceId,
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: [
      registryServicesProvider.overrideWith(
        (ref) async => PageResponse<ServiceRegistrationResponse>(
          content: const [
            ServiceRegistrationResponse(
              id: 'svc-1',
              teamId: 'team-1',
              name: 'CodeOps Server',
              slug: 'codeops-server',
              serviceType: ServiceType.springBootApi,
              status: ServiceStatus.active,
            ),
            ServiceRegistrationResponse(
              id: 'svc-2',
              teamId: 'team-1',
              name: 'Auth Service',
              slug: 'auth-service',
              serviceType: ServiceType.springBootApi,
              status: ServiceStatus.active,
            ),
          ],
          totalElements: 2,
          totalPages: 1,
          page: 0,
          size: 20,
          isLast: true,
        ),
      ),
      ...overrides,
    ],
    child: MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showPortAllocateDialog(
              context,
              preselectedServiceId: preselectedServiceId,
            ),
            child: const Text('Open Dialog'),
          ),
        ),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PortAllocateDialog', () {
    testWidgets('opens dialog with title and tabs', (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(_buildDialog());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Allocate Port'), findsOneWidget);
      expect(find.text('Auto-Allocate'), findsAtLeastNWidgets(1));
      expect(find.text('Manual'), findsOneWidget);
    });

    testWidgets('auto tab shows form fields', (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(_buildDialog());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Service *'), findsOneWidget);
      expect(find.text('Port Type *'), findsOneWidget);
      expect(find.text('Environment *'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
    });

    testWidgets('manual tab shows port number field', (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(_buildDialog());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Switch to Manual tab
      await tester.tap(find.text('Manual'));
      await tester.pumpAndSettle();

      expect(find.text('Port Number *'), findsOneWidget);
    });

    testWidgets('close button dismisses dialog', (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(_buildDialog());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Allocate Port'), findsOneWidget);

      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();

      expect(find.text('Allocate Port'), findsNothing);
    });

    testWidgets('environment field defaults to current environment',
        (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(_buildDialog());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Default environment is 'local'
      expect(find.text('local'), findsAtLeastNWidgets(1));
    });

    testWidgets('auto-allocate button exists in auto tab', (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(_buildDialog());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Find the submit button in auto tab
      expect(find.widgetWithText(FilledButton, 'Auto-Allocate'), findsOneWidget);
    });
  });
}
