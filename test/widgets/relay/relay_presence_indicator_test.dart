/// Tests for [RelayPresenceIndicator] — colored presence dot.
///
/// Verifies correct color mapping for each [PresenceStatus] value,
/// default and custom sizing, and container shape.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/relay_enums.dart';
import 'package:codeops/widgets/relay/relay_presence_indicator.dart';

Widget _createIndicator(PresenceStatus status, {double size = 8}) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: RelayPresenceIndicator(status: status, size: size),
      ),
    ),
  );
}

void main() {
  group('RelayPresenceIndicator', () {
    testWidgets('online renders green dot', (tester) async {
      await tester.pumpWidget(_createIndicator(PresenceStatus.online));
      await tester.pumpAndSettle();

      final container = tester.widget<Container>(
        find.byType(Container).last,
      );
      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.color, Colors.green);
      expect(decoration.shape, BoxShape.circle);
    });

    testWidgets('away renders amber dot', (tester) async {
      await tester.pumpWidget(_createIndicator(PresenceStatus.away));
      await tester.pumpAndSettle();

      final container = tester.widget<Container>(
        find.byType(Container).last,
      );
      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.color, Colors.amber);
    });

    testWidgets('dnd renders red dot', (tester) async {
      await tester.pumpWidget(_createIndicator(PresenceStatus.dnd));
      await tester.pumpAndSettle();

      final container = tester.widget<Container>(
        find.byType(Container).last,
      );
      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.color, Colors.red);
    });

    testWidgets('offline renders grey dot', (tester) async {
      await tester.pumpWidget(_createIndicator(PresenceStatus.offline));
      await tester.pumpAndSettle();

      final container = tester.widget<Container>(
        find.byType(Container).last,
      );
      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.color, Colors.grey);
    });

    testWidgets('respects custom size', (tester) async {
      await tester.pumpWidget(_createIndicator(PresenceStatus.online, size: 16));
      await tester.pumpAndSettle();

      final container = tester.widget<Container>(
        find.byType(Container).last,
      );
      expect(container.constraints?.maxWidth, 16);
      expect(container.constraints?.maxHeight, 16);
    });

    test('colorForStatus returns correct colors', () {
      expect(
        RelayPresenceIndicator.colorForStatus(PresenceStatus.online),
        Colors.green,
      );
      expect(
        RelayPresenceIndicator.colorForStatus(PresenceStatus.away),
        Colors.amber,
      );
      expect(
        RelayPresenceIndicator.colorForStatus(PresenceStatus.dnd),
        Colors.red,
      );
      expect(
        RelayPresenceIndicator.colorForStatus(PresenceStatus.offline),
        Colors.grey,
      );
    });
  });
}
