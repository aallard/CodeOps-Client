// Widget tests for VaultDynamicPage.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/health_snapshot.dart';
import 'package:codeops/models/vault_enums.dart';
import 'package:codeops/models/vault_models.dart';
import 'package:codeops/pages/vault_dynamic_page.dart';
import 'package:codeops/providers/vault_providers.dart';

void main() {
  final testSecret = SecretResponse(
    id: 's1',
    teamId: 't1',
    path: '/services/my-app/db',
    name: 'my-app-db',
    secretType: SecretType.dynamic_,
    currentVersion: 1,
    isActive: true,
    createdAt: DateTime(2026, 1, 1),
  );

  final testSecret2 = SecretResponse(
    id: 's2',
    teamId: 't1',
    path: '/services/api/redis',
    name: 'api-redis',
    secretType: SecretType.dynamic_,
    currentVersion: 1,
    isActive: true,
    createdAt: DateTime(2026, 1, 10),
  );

  final testSecretPage = PageResponse<SecretResponse>(
    content: [testSecret, testSecret2],
    page: 0,
    size: 20,
    totalElements: 2,
    totalPages: 1,
    isLast: true,
  );

  Widget createWidget({
    PageResponse<SecretResponse>? secretPage,
    int activeCount = 3,
  }) {
    return ProviderScope(
      overrides: [
        dynamicSecretsProvider.overrideWith(
          (ref) => Future.value(secretPage ?? testSecretPage),
        ),
        vaultActiveLeaseCountProvider.overrideWith(
          (ref) => Future.value(activeCount),
        ),
        vaultLeaseStatsProvider.overrideWith(
          (ref, id) => Future.value(<String, int>{
            'active': 2,
            'expired': 5,
            'revoked': 1,
          }),
        ),
        vaultLeasesProvider.overrideWith(
          (ref, id) => Future.value(PageResponse<DynamicLeaseResponse>(
            content: [],
            page: 0,
            size: 20,
            totalElements: 0,
            totalPages: 1,
            isLast: true,
          )),
        ),
      ],
      child: const MaterialApp(home: Scaffold(body: VaultDynamicPage())),
    );
  }

  group('VaultDynamicPage', () {
    testWidgets('shows Dynamic Secrets header', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Dynamic Secrets'), findsOneWidget);
    });

    testWidgets('shows active lease count badge', (tester) async {
      await tester.pumpWidget(createWidget(activeCount: 5));
      await tester.pumpAndSettle();

      expect(find.text('Active Leases: 5'), findsOneWidget);
    });

    testWidgets('shows secret list items', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('my-app-db'), findsOneWidget);
      expect(find.text('api-redis'), findsOneWidget);
    });

    testWidgets('shows secret paths', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('/services/my-app/db'), findsOneWidget);
      expect(find.text('/services/api/redis'), findsOneWidget);
    });

    testWidgets('shows active lease count on list items', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('2 active'), findsWidgets);
    });

    testWidgets('shows pagination info', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('2 secrets'), findsOneWidget);
      expect(find.text('Page 1 of 1'), findsOneWidget);
    });

    testWidgets('shows loading state', (tester) async {
      final widget = ProviderScope(
        overrides: [
          dynamicSecretsProvider.overrideWith(
            (ref) => Completer<PageResponse<SecretResponse>>().future,
          ),
          vaultActiveLeaseCountProvider.overrideWith(
            (ref) => Completer<int>().future,
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: VaultDynamicPage())),
      );

      await tester.pumpWidget(widget);
      await tester.pump();

      expect(find.text('Loading dynamic secrets...'), findsOneWidget);
    });

    testWidgets('shows empty state when no dynamic secrets', (tester) async {
      await tester.pumpWidget(createWidget(
        secretPage: PageResponse<SecretResponse>.empty(),
      ));
      await tester.pumpAndSettle();

      expect(find.text('No dynamic secrets found'), findsOneWidget);
    });
  });
}
