// Widget tests for DepHealthGauge.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/theme/colors.dart';
import 'package:codeops/widgets/dependency/dep_health_gauge.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  group('DepHealthGauge', () {
    testWidgets('renders gauge with score value displayed', (tester) async {
      await tester.pumpWidget(wrap(
        const DepHealthGauge(score: 75),
      ));

      expect(find.text('75'), findsOneWidget);
    });

    testWidgets('score 100 uses green (success) color', (tester) async {
      await tester.pumpWidget(wrap(
        const DepHealthGauge(score: 100),
      ));

      expect(find.text('100'), findsOneWidget);

      // The score text should use the success color.
      final scoreText = tester.widget<Text>(find.text('100'));
      expect(scoreText.style?.color, equals(CodeOpsColors.success));
    });

    testWidgets('score 50 uses yellow (warning) color', (tester) async {
      await tester.pumpWidget(wrap(
        const DepHealthGauge(score: 50),
      ));

      expect(find.text('50'), findsOneWidget);

      // Score below 80 but >= 60 is warning, but 50 < 60 so it's error.
      // Actually: >= 80 = green, >= 60 = yellow, < 60 = red.
      // 50 < 60 => error color.
      final scoreText = tester.widget<Text>(find.text('50'));
      expect(scoreText.style?.color, equals(CodeOpsColors.error));
    });

    testWidgets('score 70 uses yellow (warning) color', (tester) async {
      await tester.pumpWidget(wrap(
        const DepHealthGauge(score: 70),
      ));

      expect(find.text('70'), findsOneWidget);

      // 70 >= 60 and < 80 => warning.
      final scoreText = tester.widget<Text>(find.text('70'));
      expect(scoreText.style?.color, equals(CodeOpsColors.warning));
    });

    testWidgets('score 20 uses red (error) color', (tester) async {
      await tester.pumpWidget(wrap(
        const DepHealthGauge(score: 20),
      ));

      expect(find.text('20'), findsOneWidget);

      final scoreText = tester.widget<Text>(find.text('20'));
      expect(scoreText.style?.color, equals(CodeOpsColors.error));
    });

    testWidgets('label shows Health text', (tester) async {
      await tester.pumpWidget(wrap(
        const DepHealthGauge(score: 85),
      ));

      expect(find.text('Health'), findsOneWidget);
    });

    testWidgets('renders with custom size', (tester) async {
      await tester.pumpWidget(wrap(
        const DepHealthGauge(score: 90, size: 200),
      ));

      expect(find.text('90'), findsOneWidget);
      expect(find.text('Health'), findsOneWidget);

      // Verify the SizedBox dimensions match the custom size.
      final sizedBox = tester.widget<SizedBox>(
        find.byType(SizedBox).first,
      );
      expect(sizedBox.width, equals(200.0));
      expect(sizedBox.height, equals(200.0));
    });

    testWidgets('score 0 renders correctly', (tester) async {
      await tester.pumpWidget(wrap(
        const DepHealthGauge(score: 0),
      ));

      expect(find.text('0'), findsOneWidget);
      final scoreText = tester.widget<Text>(find.text('0'));
      expect(scoreText.style?.color, equals(CodeOpsColors.error));
    });

    testWidgets('score 80 threshold uses green (success) color',
        (tester) async {
      await tester.pumpWidget(wrap(
        const DepHealthGauge(score: 80),
      ));

      expect(find.text('80'), findsOneWidget);
      final scoreText = tester.widget<Text>(find.text('80'));
      expect(scoreText.style?.color, equals(CodeOpsColors.success));
    });
  });
}
