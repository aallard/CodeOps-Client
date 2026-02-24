// Tests for VaultSecretTypeBadge widget (CVF-002).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/vault_enums.dart';
import 'package:codeops/theme/colors.dart';
import 'package:codeops/widgets/vault/vault_secret_type_badge.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  group('VaultSecretTypeBadge', () {
    testWidgets('renders Static label for static_ type', (tester) async {
      await tester.pumpWidget(wrap(
        const VaultSecretTypeBadge(type: SecretType.static_),
      ));

      expect(find.text('Static'), findsOneWidget);
    });

    testWidgets('renders Dynamic label for dynamic_ type', (tester) async {
      await tester.pumpWidget(wrap(
        const VaultSecretTypeBadge(type: SecretType.dynamic_),
      ));

      expect(find.text('Dynamic'), findsOneWidget);
    });

    testWidgets('renders Reference label for reference type', (tester) async {
      await tester.pumpWidget(wrap(
        const VaultSecretTypeBadge(type: SecretType.reference),
      ));

      expect(find.text('Reference'), findsOneWidget);
    });

    testWidgets('does not show icon by default', (tester) async {
      await tester.pumpWidget(wrap(
        const VaultSecretTypeBadge(type: SecretType.static_),
      ));

      expect(find.byIcon(Icons.key_outlined), findsNothing);
    });

    testWidgets('shows icon when showIcon is true', (tester) async {
      await tester.pumpWidget(wrap(
        const VaultSecretTypeBadge(type: SecretType.static_, showIcon: true),
      ));

      expect(find.byIcon(Icons.key_outlined), findsOneWidget);
    });

    testWidgets('shows refresh icon for dynamic type with showIcon',
        (tester) async {
      await tester.pumpWidget(wrap(
        const VaultSecretTypeBadge(type: SecretType.dynamic_, showIcon: true),
      ));

      expect(find.byIcon(Icons.refresh_outlined), findsOneWidget);
    });

    testWidgets('shows link icon for reference type with showIcon',
        (tester) async {
      await tester.pumpWidget(wrap(
        const VaultSecretTypeBadge(type: SecretType.reference, showIcon: true),
      ));

      expect(find.byIcon(Icons.link_outlined), findsOneWidget);
    });

    testWidgets('uses correct color from theme for static type',
        (tester) async {
      await tester.pumpWidget(wrap(
        const VaultSecretTypeBadge(type: SecretType.static_, showIcon: true),
      ));

      final icon = tester.widget<Icon>(find.byIcon(Icons.key_outlined));
      expect(icon.color, CodeOpsColors.secretTypeColors[SecretType.static_]);
    });
  });
}
