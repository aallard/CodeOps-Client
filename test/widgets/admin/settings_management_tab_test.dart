// Widget tests for SettingsManagementTab.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/health_snapshot.dart';
import 'package:codeops/providers/admin_providers.dart';
import 'package:codeops/widgets/admin/settings_management_tab.dart';

void main() {
  const testSetting = SystemSetting(key: 'max_users', value: '100');

  Widget createWidget({
    List<SystemSetting>? settings,
    List<Override> overrides = const [],
  }) {
    return ProviderScope(
      overrides: [
        systemSettingsProvider.overrideWith(
          (ref) => Future.value(settings ?? [testSetting]),
        ),
        ...overrides,
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: SettingsManagementTab()),
        ),
      ),
    );
  }

  group('SettingsManagementTab', () {
    testWidgets('shows setting key and value', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('max_users'), findsOneWidget);
      expect(find.text('100'), findsOneWidget);
    });

    testWidgets('shows empty message when no settings', (tester) async {
      await tester.pumpWidget(createWidget(settings: []));
      await tester.pumpAndSettle();

      expect(find.text('No system settings found.'), findsOneWidget);
    });

    testWidgets('shows multiple settings', (tester) async {
      await tester.pumpWidget(createWidget(
        settings: [
          const SystemSetting(key: 'max_users', value: '100'),
          const SystemSetting(key: 'retention_days', value: '90'),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.text('max_users'), findsOneWidget);
      expect(find.text('100'), findsOneWidget);
      expect(find.text('retention_days'), findsOneWidget);
      expect(find.text('90'), findsOneWidget);
    });
  });
}
