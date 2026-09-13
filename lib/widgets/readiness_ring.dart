import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class ReadinessRing extends StatelessWidget {
  const ReadinessRing({
    super.key,
    required this.score,
    required this.label,
  });

  final int score;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 168,
      height: 168,
      child: CustomPaint(
        painter: _RingPainter(score / 100),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$score',
                style: const TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  color: AppColors.lime,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.t);

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 10;
    final track = Paint()
      ..color = AppColors.surfaceMuted
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, track);

    final sweep = 2 * math.pi * t.clamp(0, 1);
    final rect = Rect.fromCircle(center: center, radius: radius);
    final shader = SweepGradient(
      startAngle: -math.pi / 2,
      endAngle: 3 * math.pi / 2,
      colors: const [AppColors.electric, AppColors.lime],
    ).createShader(rect);
    final glow = Paint()
      ..shader = shader
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawArc(rect, -math.pi / 2, sweep, false, glow);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      sweep,
      false,
      Paint()
        ..shader = shader
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) => oldDelegate.t != t;
}
