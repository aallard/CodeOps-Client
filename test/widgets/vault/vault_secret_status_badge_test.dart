// Tests for VaultSecretStatusBadge widget (CVF-002).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/widgets/vault/vault_secret_status_badge.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  group('VaultSecretStatusBadge', () {
    testWidgets('shows Active for active secret without expiry',
        (tester) async {
      await tester.pumpWidget(wrap(
        const VaultSecretStatusBadge(isActive: true),
      ));

      expect(find.text('Active'), findsOneWidget);
      expect(find.byIcon(Icons.circle), findsOneWidget);
    });

    testWidgets('shows Inactive for non-active secret', (tester) async {
      await tester.pumpWidget(wrap(
        const VaultSecretStatusBadge(isActive: false),
      ));

      expect(find.text('Inactive'), findsOneWidget);
      expect(find.byIcon(Icons.cancel_outlined), findsOneWidget);
    });

    testWidgets('shows Expiring when within 72 hours', (tester) async {
      final expiresAt = DateTime.now().add(const Duration(hours: 48));
      await tester.pumpWidget(wrap(
        VaultSecretStatusBadge(isActive: true, expiresAt: expiresAt),
      ));

      expect(find.text('Expiring'), findsOneWidget);
      expect(find.byIcon(Icons.schedule), findsOneWidget);
    });

    testWidgets('shows Urgent when within 24 hours', (tester) async {
      final expiresAt = DateTime.now().add(const Duration(hours: 12));
      await tester.pumpWidget(wrap(
        VaultSecretStatusBadge(isActive: true, expiresAt: expiresAt),
      ));

      expect(find.text('Urgent'), findsOneWidget);
      expect(find.byIcon(Icons.schedule), findsOneWidget);
    });

    testWidgets('shows Active when expiry is far away', (tester) async {
      final expiresAt = DateTime.now().add(const Duration(days: 30));
      await tester.pumpWidget(wrap(
        VaultSecretStatusBadge(isActive: true, expiresAt: expiresAt),
      ));

      expect(find.text('Active'), findsOneWidget);
    });

    testWidgets('inactive overrides expiry status', (tester) async {
      final expiresAt = DateTime.now().add(const Duration(hours: 12));
      await tester.pumpWidget(wrap(
        VaultSecretStatusBadge(isActive: false, expiresAt: expiresAt),
      ));

      expect(find.text('Inactive'), findsOneWidget);
      expect(find.text('Urgent'), findsNothing);
    });
  });
}
