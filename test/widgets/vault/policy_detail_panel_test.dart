// Widget tests for PolicyDetailPanel.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/health_snapshot.dart';
import 'package:codeops/models/vault_enums.dart';
import 'package:codeops/models/vault_models.dart';
import 'package:codeops/providers/vault_providers.dart';
import 'package:codeops/widgets/vault/policy_detail_panel.dart';

void main() {
  final testPolicy = AccessPolicyResponse(
    id: 'p1',
    teamId: 't1',
    name: 'read-db-secrets',
    description: 'Allow reading DB secrets',
    pathPattern: '/services/*/db-*',
    permissions: [PolicyPermission.read, PolicyPermission.list],
    isDenyPolicy: false,
    isActive: true,
    createdByUserId: '12345678-abcd-efgh-ijkl-123456789abc',
    bindingCount: 2,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 2, 1),
  );

  final testDenyPolicy = AccessPolicyResponse(
    id: 'p2',
    teamId: 't1',
    name: 'deny-delete-all',
    pathPattern: '/services/*',
    permissions: [PolicyPermission.delete],
    isDenyPolicy: true,
    isActive: false,
    bindingCount: 0,
    createdAt: DateTime(2026, 1, 15),
  );

  final testBindings = [
    PolicyBindingResponse(
      id: 'b1',
      policyId: 'p1',
      policyName: 'read-db-secrets',
      bindingType: BindingType.user,
      bindingTargetId: 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee',
      createdAt: DateTime(2026, 1, 10),
    ),
    PolicyBindingResponse(
      id: 'b2',
      policyId: 'p1',
      policyName: 'read-db-secrets',
      bindingType: BindingType.team,
      bindingTargetId: 'ffffffff-1111-2222-3333-444444444444',
      createdAt: DateTime(2026, 1, 20),
    ),
  ];

  Widget createWidget({
    AccessPolicyResponse? policy,
    VoidCallback? onClose,
    List<PolicyBindingResponse>? bindings,
  }) {
    final p = policy ?? testPolicy;
    return ProviderScope(
      overrides: [
        vaultPolicyBindingsProvider.overrideWith(
          (ref, id) => Future.value(bindings ?? testBindings),
        ),
        vaultPoliciesProvider.overrideWith(
          (ref) => Future.value(PageResponse<AccessPolicyResponse>(
            content: [p],
            page: 0,
            size: 20,
            totalElements: 1,
            totalPages: 1,
            isLast: true,
          )),
        ),
        vaultPolicyDetailProvider.overrideWith(
          (ref, id) => Future.value(p),
        ),
        vaultPolicyStatsProvider.overrideWith(
          (ref) => Future.value(<String, int>{'total': 1}),
        ),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: PolicyDetailPanel(
            policy: p,
            onClose: onClose,
          ),
        ),
      ),
    );
  }

  group('PolicyDetailPanel', () {
    testWidgets('shows policy name in header', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('read-db-secrets'), findsWidgets);
    });

    testWidgets('shows path pattern', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('/services/*/db-*'), findsWidgets);
    });

    testWidgets('shows action buttons', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Deactivate'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
      expect(find.text('Add Binding'), findsOneWidget);
    });

    testWidgets('shows Activate button for inactive policy', (tester) async {
      await tester.pumpWidget(createWidget(policy: testDenyPolicy));
      await tester.pumpAndSettle();

      expect(find.text('Activate'), findsOneWidget);
    });

    testWidgets('shows DENY badge for deny policy', (tester) async {
      await tester.pumpWidget(createWidget(policy: testDenyPolicy));
      await tester.pumpAndSettle();

      expect(find.text('DENY'), findsOneWidget);
    });

    testWidgets('shows permission badges', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('READ'), findsOneWidget);
      expect(find.text('LIST'), findsOneWidget);
    });

    testWidgets('shows info fields', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Path Pattern'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
      expect(find.text('Allow reading DB secrets'), findsOneWidget);
    });

    testWidgets('shows bindings section', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Bindings'), findsWidgets);
      expect(find.text('USER'), findsOneWidget);
      expect(find.text('TEAM'), findsOneWidget);
    });

    testWidgets('shows close button when onClose provided', (tester) async {
      var closed = false;
      await tester.pumpWidget(
        createWidget(onClose: () => closed = true),
      );
      await tester.pumpAndSettle();

      final closeButton = find.byIcon(Icons.close);
      expect(closeButton, findsWidgets);

      await tester.tap(closeButton.first);
      expect(closed, isTrue);
    });

    testWidgets('shows no bindings message when empty', (tester) async {
      await tester.pumpWidget(createWidget(bindings: []));
      await tester.pumpAndSettle();

      expect(find.text('No bindings'), findsOneWidget);
    });
  });
}
