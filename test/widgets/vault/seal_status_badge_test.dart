// Widget tests for SealStatusBadge.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/vault_enums.dart';
import 'package:codeops/models/vault_models.dart';
import 'package:codeops/providers/vault_providers.dart';
import 'package:codeops/theme/colors.dart';
import 'package:codeops/widgets/vault/seal_status_badge.dart';

void main() {
  Widget createWidget({
    required SealStatusResponse status,
  }) {
    return ProviderScope(
      overrides: [
        sealStatusProvider.overrideWith(
          (ref) => Future.value(status),
        ),
      ],
      child: const MaterialApp(home: Scaffold(body: SealStatusBadge())),
    );
  }

  group('SealStatusBadge', () {
    testWidgets('shows Sealed with lock icon when sealed', (tester) async {
      await tester.pumpWidget(createWidget(
        status: const SealStatusResponse(
          status: SealStatus.sealed,
          totalShares: 5,
          threshold: 3,
          sharesProvided: 0,
          autoUnsealEnabled: false,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Sealed'), findsOneWidget);
      expect(find.byIcon(Icons.lock), findsOneWidget);
    });

    testWidgets('shows Unsealed with lock_open icon when unsealed',
        (tester) async {
      await tester.pumpWidget(createWidget(
        status: const SealStatusResponse(
          status: SealStatus.unsealed,
          totalShares: 5,
          threshold: 3,
          sharesProvided: 3,
          autoUnsealEnabled: false,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Unsealed'), findsOneWidget);
      expect(find.byIcon(Icons.lock_open), findsOneWidget);
    });

    testWidgets('shows Unsealing with hourglass icon when unsealing',
        (tester) async {
      await tester.pumpWidget(createWidget(
        status: const SealStatusResponse(
          status: SealStatus.unsealing,
          totalShares: 5,
          threshold: 3,
          sharesProvided: 1,
          autoUnsealEnabled: false,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Unsealing'), findsOneWidget);
      expect(find.byIcon(Icons.hourglass_bottom), findsOneWidget);
    });

    testWidgets('shows loading spinner while fetching', (tester) async {
      final widget = ProviderScope(
        overrides: [
          sealStatusProvider.overrideWith(
            (ref) => Completer<SealStatusResponse>().future,
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: SealStatusBadge())),
      );

      await tester.pumpWidget(widget);
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows Unknown on error', (tester) async {
      final widget = ProviderScope(
        overrides: [
          sealStatusProvider.overrideWith(
            (ref) => Future<SealStatusResponse>.error('Network error'),
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: SealStatusBadge())),
      );

      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      expect(find.text('Unknown'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('uses correct color for sealed state', (tester) async {
      await tester.pumpWidget(createWidget(
        status: const SealStatusResponse(
          status: SealStatus.sealed,
          totalShares: 5,
          threshold: 3,
          sharesProvided: 0,
          autoUnsealEnabled: false,
        ),
      ));
      await tester.pumpAndSettle();

      final icon = tester.widget<Icon>(find.byIcon(Icons.lock));
      expect(icon.color, equals(CodeOpsColors.error));
    });

    testWidgets('uses correct color for unsealed state', (tester) async {
      await tester.pumpWidget(createWidget(
        status: const SealStatusResponse(
          status: SealStatus.unsealed,
          totalShares: 5,
          threshold: 3,
          sharesProvided: 3,
          autoUnsealEnabled: false,
        ),
      ));
      await tester.pumpAndSettle();

      final icon = tester.widget<Icon>(find.byIcon(Icons.lock_open));
      expect(icon.color, equals(CodeOpsColors.success));
    });

    testWidgets('badge is tappable', (tester) async {
      await tester.pumpWidget(createWidget(
        status: const SealStatusResponse(
          status: SealStatus.unsealed,
          totalShares: 5,
          threshold: 3,
          sharesProvided: 3,
          autoUnsealEnabled: false,
        ),
      ));
      await tester.pumpAndSettle();

      // Verify InkWell exists (tappable)
      expect(find.byType(InkWell), findsOneWidget);
    });
  });
}
