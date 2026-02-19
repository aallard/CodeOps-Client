// Widget tests for RotationPolicyPanel.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/health_snapshot.dart';
import 'package:codeops/models/vault_enums.dart';
import 'package:codeops/models/vault_models.dart';
import 'package:codeops/providers/vault_providers.dart';
import 'package:codeops/widgets/vault/rotation_policy_panel.dart';

void main() {
  final testPolicy = RotationPolicyResponse(
    id: 'rp1',
    secretId: 's1',
    secretPath: '/services/my-app/db',
    strategy: RotationStrategy.randomGenerate,
    rotationIntervalHours: 24,
    randomLength: 32,
    randomCharset: 'alphanumeric',
    isActive: true,
    failureCount: 0,
    maxFailures: 5,
    lastRotatedAt: DateTime.now().subtract(const Duration(hours: 3)),
    nextRotationAt: DateTime.now().add(const Duration(hours: 2, minutes: 15)),
    createdAt: DateTime(2026, 1, 1),
  );

  final testHistory = RotationHistoryResponse(
    id: 'rh1',
    secretId: 's1',
    strategy: RotationStrategy.randomGenerate,
    previousVersion: 3,
    newVersion: 4,
    success: true,
    durationMs: 245,
    createdAt: DateTime.now().subtract(const Duration(hours: 3)),
  );

  final testFailedHistory = RotationHistoryResponse(
    id: 'rh2',
    secretId: 's1',
    strategy: RotationStrategy.randomGenerate,
    previousVersion: 2,
    success: false,
    errorMessage: 'Connection timeout',
    durationMs: 5000,
    createdAt: DateTime.now().subtract(const Duration(hours: 51)),
  );

  final testHistoryPage = PageResponse<RotationHistoryResponse>(
    content: [testHistory, testFailedHistory],
    page: 0,
    size: 20,
    totalElements: 2,
    totalPages: 1,
    isLast: true,
  );

  Widget createWidget({
    RotationPolicyResponse? policy,
    bool policyError = false,
  }) {
    return ProviderScope(
      overrides: [
        vaultRotationPolicyProvider.overrideWith((ref, id) {
          if (policyError) return Future.error(Exception('Not found'));
          return Future.value(policy ?? testPolicy);
        }),
        vaultRotationHistoryProvider.overrideWith(
          (ref, id) => Future.value(testHistoryPage),
        ),
        vaultRotationStatsProvider.overrideWith(
          (ref, id) => Future.value(<String, int>{
            'activePolicies': 1,
            'totalRotations': 10,
            'failedRotations': 2,
          }),
        ),
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: RotationPolicyPanel(secretId: 's1'),
        ),
      ),
    );
  }

  group('RotationPolicyPanel', () {
    testWidgets('shows no policy state with setup button', (tester) async {
      await tester.pumpWidget(createWidget(policyError: true));
      await tester.pumpAndSettle();

      expect(find.text('No rotation policy configured'), findsOneWidget);
      expect(find.text('Set Up Rotation'), findsOneWidget);
    });

    testWidgets('shows policy details when exists', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Rotation Policy'), findsOneWidget);
      expect(find.text('Random Generate'), findsWidgets);
      expect(find.text('Every 24 hours'), findsOneWidget);
    });

    testWidgets('shows status field', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Active'), findsWidgets);
    });

    testWidgets('shows failure count', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('0 / 5'), findsOneWidget);
    });

    testWidgets('shows action buttons', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Rotate Now'), findsOneWidget);
      expect(find.text('Pause'), findsOneWidget);
      expect(find.text('Delete Policy'), findsOneWidget);
    });

    testWidgets('shows Resume when paused', (tester) async {
      final paused = RotationPolicyResponse(
        id: 'rp1',
        secretId: 's1',
        strategy: RotationStrategy.randomGenerate,
        rotationIntervalHours: 24,
        isActive: false,
        failureCount: 3,
        maxFailures: 5,
        createdAt: DateTime(2026, 1, 1),
      );

      await tester.pumpWidget(createWidget(policy: paused));
      await tester.pumpAndSettle();

      expect(find.text('Resume'), findsOneWidget);
      expect(find.text('Paused'), findsOneWidget);
    });

    testWidgets('shows Edit button', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Edit'), findsOneWidget);
    });

    testWidgets('shows rotation history header', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Rotation History'), findsOneWidget);
    });

    testWidgets('shows history entries with version transitions',
        (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.textContaining('v3\u2192v4'), findsOneWidget);
      expect(find.textContaining('v2\u2192FAILED'), findsOneWidget);
    });

    testWidgets('shows duration in history entries', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('245ms'), findsOneWidget);
      expect(find.text('5000ms'), findsOneWidget);
    });

    testWidgets('shows strategy badges in history', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      // Both entries use randomGenerate strategy
      expect(find.text('Random Generate'), findsWidgets);
    });

    testWidgets('shows trigger source in history', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      // Both entries have no triggeredByUserId → auto
      expect(find.text('auto'), findsWidgets);
    });
  });
}
