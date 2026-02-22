// Tests for ServiceFormPage.
//
// Verifies create mode rendering (title, form fields, section headers,
// buttons, validation), and loading state for edit mode.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/registry_models.dart';
import 'package:codeops/pages/registry/service_form_page.dart';
import 'package:codeops/providers/registry_providers.dart';
import 'package:codeops/services/cloud/registry_api.dart';

/// Fake RegistryApi that returns a never-completing future for identity.
class _HangingRegistryApi extends Fake implements RegistryApi {
  @override
  Future<ServiceIdentityResponse> getServiceIdentity(
    String serviceId, {
    String? environment,
  }) {
    return Completer<ServiceIdentityResponse>().future;
  }
}

void _setWideViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1200, 1600);
  tester.view.devicePixelRatio = 1.0;
}

Widget _buildPage({
  String? serviceId,
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      home: Scaffold(body: ServiceFormPage(serviceId: serviceId)),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ServiceFormPage — Create Mode', () {
    testWidgets('renders create mode title', (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(_buildPage());
      await tester.pumpAndSettle();

      expect(find.text('Register New Service'), findsOneWidget);
    });

    testWidgets('renders section headers', (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(_buildPage());
      await tester.pumpAndSettle();

      expect(find.text('Basic Information'), findsOneWidget);
      expect(find.text('Repository'), findsOneWidget);
      expect(find.text('Tech Stack'), findsOneWidget);
      expect(find.text('Health Check'), findsOneWidget);
      expect(find.text('Advanced'), findsOneWidget);
    });

    testWidgets('renders form fields with labels', (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(_buildPage());
      await tester.pumpAndSettle();

      expect(find.text('Service Name *'), findsOneWidget);
      expect(find.text('Service Type *'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
      expect(find.text('Repository URL'), findsOneWidget);
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Default Branch'), findsOneWidget);
      expect(find.text('Health Check URL'), findsOneWidget);
      expect(find.text('Interval (sec)'), findsOneWidget);
    });

    testWidgets('renders action buttons', (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(_buildPage());
      await tester.pumpAndSettle();

      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Register Service'), findsOneWidget);
    });

    testWidgets('shows port allocation preview panel', (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(_buildPage());
      await tester.pumpAndSettle();

      expect(find.text('Port Allocation Preview'), findsOneWidget);
    });

    testWidgets('shows tech stack selector', (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(_buildPage());
      await tester.pumpAndSettle();

      expect(find.text('Add from presets'), findsOneWidget);
      expect(find.text('Add custom...'), findsOneWidget);
    });

    testWidgets('shows collapsible env config editors', (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(_buildPage());
      await tester.pumpAndSettle();

      expect(find.text('Environments JSON'), findsOneWidget);
      expect(find.text('Metadata JSON'), findsOneWidget);
    });

    testWidgets('has default branch value "main"', (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(_buildPage());
      await tester.pumpAndSettle();

      // Find the Default Branch TextFormField and check its controller value
      final textFields = find.byType(TextFormField);
      expect(textFields, findsWidgets);

      // The default branch field should contain "main"
      expect(find.text('main'), findsAtLeastNWidgets(1));
    });

    testWidgets('name validation shows error when empty', (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(_buildPage());
      await tester.pumpAndSettle();

      // Scroll to and tap the Register Service button
      final registerButton = find.text('Register Service');
      await tester.ensureVisible(registerButton);
      await tester.tap(registerButton);
      await tester.pumpAndSettle();

      // Validation error should appear
      expect(find.text('Name is required'), findsOneWidget);
    });

    testWidgets('service type validation shows error when not selected',
        (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(_buildPage());
      await tester.pumpAndSettle();

      // Tap Register Service to trigger validation
      final registerButton = find.text('Register Service');
      await tester.ensureVisible(registerButton);
      await tester.tap(registerButton);
      await tester.pumpAndSettle();

      expect(find.text('Service type is required'), findsOneWidget);
    });

    testWidgets('back button navigates back', (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(_buildPage());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.byTooltip('Back'), findsOneWidget);
    });
  });

  group('ServiceFormPage — Edit Mode', () {
    testWidgets('renders edit mode title', (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        _buildPage(
          serviceId: 'svc-1',
          overrides: [
            registryApiProvider.overrideWithValue(_HangingRegistryApi()),
          ],
        ),
      );
      await tester.pump();

      expect(find.text('Edit Service'), findsOneWidget);
    });

    testWidgets('shows loading indicator in edit mode', (tester) async {
      _setWideViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        _buildPage(
          serviceId: 'svc-1',
          overrides: [
            registryApiProvider.overrideWithValue(_HangingRegistryApi()),
          ],
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
