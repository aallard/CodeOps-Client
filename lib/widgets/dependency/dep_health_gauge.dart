/// Dependency health gauge widget showing a circular score indicator.
///
/// Displays a 0-100 health score with color coding:
/// green (80+), yellow (60-79), red (<60).
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/colors.dart';
import '../../utils/constants.dart';

/// Circular gauge displaying a dependency health score (0-100).
///
/// Color ranges: green (80+), yellow (60-79), red (<60).
class DepHealthGauge extends StatelessWidget {
  /// The health score value (0-100).
  final int score;

  /// Size of the gauge widget.
  final double size;

  /// Creates a [DepHealthGauge].
  const DepHealthGauge({
    super.key,
    required this.score,
    this.size = AppConstants.gaugeDefaultSize,
  });

  Color get _color {
    if (score >= AppConstants.healthScoreGreenThreshold) {
      return CodeOpsColors.success;
    }
    if (score >= AppConstants.healthScoreYellowThreshold) {
      return CodeOpsColors.warning;
    }
    return CodeOpsColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GaugePainter(
          score: score,
          color: _color,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$score',
                style: TextStyle(
                  fontSize: size * 0.25,
                  fontWeight: FontWeight.w700,
                  color: _color,
                ),
              ),
              Text(
                'Health',
                style: TextStyle(
                  fontSize: size * 0.1,
                  color: CodeOpsColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final int score;
  final Color color;

  _GaugePainter({required this.score, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 8;
    const startAngle = -math.pi * 0.75;
    const sweepRange = math.pi * 1.5;

    // Background arc
    final bgPaint = Paint()
      ..color = CodeOpsColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepRange,
      false,
      bgPaint,
    );

    // Value arc
    final valuePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final valueSweep = sweepRange * (score / 100);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      valueSweep,
      false,
      valuePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) =>
      oldDelegate.score != score || oldDelegate.color != color;
}
