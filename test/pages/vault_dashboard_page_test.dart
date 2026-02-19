// Widget tests for VaultDashboardPage.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/health_snapshot.dart';
import 'package:codeops/models/vault_enums.dart';
import 'package:codeops/models/vault_models.dart';
import 'package:codeops/pages/vault_dashboard_page.dart';
import 'package:codeops/providers/vault_providers.dart';

void main() {
  // Shared test data
  final unsealedStatus = SealStatusResponse(
    status: SealStatus.unsealed,
    totalShares: 5,
    threshold: 3,
    sharesProvided: 3,
    autoUnsealEnabled: false,
  );

  final sealedStatus = SealStatusResponse(
    status: SealStatus.sealed,
    totalShares: 5,
    threshold: 3,
    sharesProvided: 0,
    autoUnsealEnabled: false,
  );

  final expiringSecret = SecretResponse(
    id: 's1',
    teamId: 't1',
    path: '/app/db-pass',
    name: 'db-pass',
    secretType: SecretType.static_,
    currentVersion: 1,
    isActive: true,
    expiresAt: DateTime.now().add(const Duration(hours: 12)),
  );

  final auditEntry = AuditEntryResponse(
    id: 1,
    operation: 'WRITE',
    success: true,
    path: '/app/db-pass',
    resourceType: 'SECRET',
    createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
  );

  Widget createWidget({
    SealStatusResponse? sealStatus,
    Map<String, int> secretStats = const {'STATIC': 5, 'DYNAMIC': 3},
    Map<String, int> policyStats = const {'allow': 4},
    Map<String, int> transitStats = const {'AES': 2},
    int leaseCount = 7,
    List<SecretResponse> expiringSecrets = const [],
    PageResponse<AuditEntryResponse>? auditPage,
  }) {
    return ProviderScope(
      overrides: [
        sealStatusProvider.overrideWith(
          (ref) => Future.value(sealStatus ?? unsealedStatus),
        ),
        vaultSecretStatsProvider.overrideWith(
          (ref) => Future.value(secretStats),
        ),
        vaultPolicyStatsProvider.overrideWith(
          (ref) => Future.value(policyStats),
        ),
        vaultTransitStatsProvider.overrideWith(
          (ref) => Future.value(transitStats),
        ),
        vaultActiveLeaseCountProvider.overrideWith(
          (ref) => Future.value(leaseCount),
        ),
        vaultExpiringSecretsProvider.overrideWith(
          (ref) => Future.value(expiringSecrets),
        ),
        vaultAuditLogProvider.overrideWith(
          (ref) => Future.value(
            auditPage ?? PageResponse<AuditEntryResponse>.empty(),
          ),
        ),
      ],
      child: const MaterialApp(home: Scaffold(body: VaultDashboardPage())),
    );
  }

  group('VaultDashboardPage', () {
    testWidgets('shows Vault Dashboard title', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Vault Dashboard'), findsOneWidget);
    });

    testWidgets('shows seal status badge when unsealed', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Unsealed'), findsOneWidget);
      expect(find.byIcon(Icons.lock_open), findsOneWidget);
    });

    testWidgets('shows seal status badge when sealed', (tester) async {
      await tester.pumpWidget(createWidget(sealStatus: sealedStatus));
      await tester.pumpAndSettle();

      expect(find.text('Sealed'), findsOneWidget);
      expect(find.byIcon(Icons.lock), findsWidgets);
    });

    testWidgets('shows sealed warning banner when sealed', (tester) async {
      await tester.pumpWidget(createWidget(sealStatus: sealedStatus));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Vault is sealed. All operations are blocked until it is unsealed.',
        ),
        findsOneWidget,
      );
      expect(find.text('Unseal Vault'), findsOneWidget);
    });

    testWidgets('does not show sealed warning when unsealed', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Vault is sealed. All operations are blocked until it is unsealed.',
        ),
        findsNothing,
      );
    });

    testWidgets('shows four stat cards with correct totals', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      // Secrets: 5 + 3 = 8
      expect(find.text('8'), findsOneWidget);
      expect(find.text('Secrets'), findsOneWidget);

      // Policies: 4
      expect(find.text('4'), findsOneWidget);
      expect(find.text('Policies'), findsOneWidget);

      // Transit Keys: 2
      expect(find.text('2'), findsOneWidget);
      expect(find.text('Transit Keys'), findsOneWidget);

      // Active Leases: 7
      expect(find.text('7'), findsOneWidget);
      expect(find.text('Active Leases'), findsOneWidget);
    });

    testWidgets('shows quick action cards', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('New Secret'), findsOneWidget);
      expect(find.text('Encrypt Data'), findsOneWidget);
      expect(find.text('Manage Policies'), findsOneWidget);
      expect(find.text('View Audit Log'), findsOneWidget);
      expect(find.text('Seal Status'), findsOneWidget);
    });

    testWidgets('shows expiring secrets list header', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Expiring Secrets (72h)'), findsOneWidget);
    });

    testWidgets('shows empty state for no expiring secrets', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('No secrets expiring soon'), findsOneWidget);
    });

    testWidgets('shows expiring secret entries', (tester) async {
      await tester.pumpWidget(
        createWidget(expiringSecrets: [expiringSecret]),
      );
      await tester.pumpAndSettle();

      expect(find.text('db-pass'), findsOneWidget);
      expect(find.text('/app/db-pass'), findsOneWidget);
    });

    testWidgets('shows audit feed header', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Recent Audit Activity'), findsOneWidget);
    });

    testWidgets('shows empty state for no audit entries', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('No audit activity yet'), findsOneWidget);
    });

    testWidgets('shows audit entries when data exists', (tester) async {
      await tester.pumpWidget(
        createWidget(
          auditPage: PageResponse<AuditEntryResponse>(
            content: [auditEntry],
            page: 0,
            size: 10,
            totalElements: 1,
            totalPages: 1,
            isLast: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('WRITE'), findsOneWidget);
      expect(find.text('/app/db-pass'), findsWidgets);
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    });

    testWidgets('shows dash values while loading', (tester) async {
      // Use Completers that never complete to simulate loading state
      final widget = ProviderScope(
        overrides: [
          sealStatusProvider.overrideWith(
            (ref) => Completer<SealStatusResponse>().future,
          ),
          vaultSecretStatsProvider.overrideWith(
            (ref) => Completer<Map<String, int>>().future,
          ),
          vaultPolicyStatsProvider.overrideWith(
            (ref) => Completer<Map<String, int>>().future,
          ),
          vaultTransitStatsProvider.overrideWith(
            (ref) => Completer<Map<String, int>>().future,
          ),
          vaultActiveLeaseCountProvider.overrideWith(
            (ref) => Completer<int>().future,
          ),
          vaultExpiringSecretsProvider.overrideWith(
            (ref) => Completer<List<SecretResponse>>().future,
          ),
          vaultAuditLogProvider.overrideWith(
            (ref) => Completer<PageResponse<AuditEntryResponse>>().future,
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: VaultDashboardPage())),
      );

      await tester.pumpWidget(widget);
      await tester.pump();

      // All four stat cards should show dash (em-dash)
      expect(find.text('\u2014'), findsWidgets);
    });
  });
}
