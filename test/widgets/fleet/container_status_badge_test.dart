// Widget tests for ContainerStatusBadge.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/fleet_enums.dart';
import 'package:codeops/theme/colors.dart';
import 'package:codeops/widgets/fleet/container_status_badge.dart';

void main() {
  Widget wrap(ContainerStatus status) {
    return MaterialApp(
      home: Scaffold(body: ContainerStatusBadge(status: status)),
    );
  }

  group('ContainerStatusBadge', () {
    testWidgets('running shows green dot and Running label', (tester) async {
      await tester.pumpWidget(wrap(ContainerStatus.running));

      expect(find.text('Running'), findsOneWidget);
      expect(
        ContainerStatusBadge.colorFor(ContainerStatus.running),
        CodeOpsColors.success,
      );
    });

    testWidgets('exited shows gray dot and Exited label', (tester) async {
      await tester.pumpWidget(wrap(ContainerStatus.exited));

      expect(find.text('Exited'), findsOneWidget);
      expect(
        ContainerStatusBadge.colorFor(ContainerStatus.exited),
        CodeOpsColors.textTertiary,
      );
    });

    testWidgets('dead shows red dot and Dead label', (tester) async {
      await tester.pumpWidget(wrap(ContainerStatus.dead));

      expect(find.text('Dead'), findsOneWidget);
      expect(
        ContainerStatusBadge.colorFor(ContainerStatus.dead),
        CodeOpsColors.error,
      );
    });

    testWidgets('paused shows yellow dot and Paused label', (tester) async {
      await tester.pumpWidget(wrap(ContainerStatus.paused));

      expect(find.text('Paused'), findsOneWidget);
      expect(
        ContainerStatusBadge.colorFor(ContainerStatus.paused),
        CodeOpsColors.warning,
      );
    });
  });
}
