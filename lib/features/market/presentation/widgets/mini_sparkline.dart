import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/nexbit_theme.dart';

/// Small "trend" sparkline for a price table row — deterministically
/// seeded (by the asset id's hash) so it stays stable across rebuilds
/// instead of jumping around randomly, without needing real historical
/// price data.
class MiniSparkline extends StatelessWidget {
  final bool isUp;
  final int seed;
  final double width;
  final double height;
  /// When true, draws a soft gradient area under the line (used for the
  /// "Grafik (7H)" column on the Market page) instead of a bare line.
  final bool filled;
  final int points;

  const MiniSparkline({
    super.key,
    required this.isUp,
    required this.seed,
    this.width = 84,
    this.height = 26,
    this.filled = false,
    this.points = 9,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _SparklinePainter(isUp: isUp, seed: seed, filled: filled, points: points),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final bool isUp;
  final int seed;
  final bool filled;
  final int points;
  _SparklinePainter({required this.isUp, required this.seed, required this.filled, required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(seed);
    final color = isUp ? NexbitColors.up : NexbitColors.down;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final ys = <double>[];
    double y = size.height * 0.5;
    final dx = size.width / (points - 1);
    final drift = isUp ? -0.16 : 0.16; // gentle overall up/down bias
    for (var i = 0; i < points; i++) {
      y += (rng.nextDouble() - 0.5 + drift) * size.height * 0.32;
      y = y.clamp(2.0, size.height - 2.0);
      ys.add(y);
      final x = dx * i;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    if (filled) {
      final areaPath = Path.from(path)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();
      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withOpacity(0.28), color.withOpacity(0.0)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
      canvas.drawPath(areaPath, fillPaint);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) => false;
}
