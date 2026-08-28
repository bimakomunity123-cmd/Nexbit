import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/nexbit_theme.dart';
import 'mini_sparkline.dart';

/// One of the three top-of-page stat cards on the Market page (Total
/// Market Cap / 24h Volume / BTC Dominance) — a label, a big value, a
/// change badge, and a small trend visual on the right.
class MarketStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String change;
  final bool isUp;
  final Widget visual;

  const MarketStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.change,
    required this.isUp,
    required this.visual,
  });

  @override
  Widget build(BuildContext context) {
    final color = isUp ? NexbitColors.up : NexbitColors.down;
    return Container(
      width: 230,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NexbitColors.panel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: NexbitColors.line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: NexbitText.body(fontSize: 12.5, color: NexbitColors.muted)),
                const SizedBox(height: 8),
                Text(value, style: NexbitText.display(fontSize: 21, weight: FontWeight.w700)),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(isUp ? Icons.arrow_drop_up : Icons.arrow_drop_down, size: 16, color: color),
                    Text(change, style: NexbitText.mono(fontSize: 12, weight: FontWeight.w600, color: color)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          visual,
        ],
      ),
    );
  }
}

/// A tiny ascending-bar visual (used for the 24h Volume card).
class MarketBarTrend extends StatelessWidget {
  final bool isUp;
  final int seed;
  final double width;
  final double height;

  const MarketBarTrend({super.key, required this.isUp, required this.seed, this.width = 56, this.height = 34});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size(width, height), painter: _BarTrendPainter(isUp: isUp, seed: seed));
  }
}

class _BarTrendPainter extends CustomPainter {
  final bool isUp;
  final int seed;
  _BarTrendPainter({required this.isUp, required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(seed);
    final color = isUp ? NexbitColors.up : NexbitColors.down;
    const bars = 6;
    final barWidth = size.width / (bars * 1.6);
    final gap = barWidth * 0.6;
    var x = 0.0;
    for (var i = 0; i < bars; i++) {
      // Gentle ascending bias so it visually reads as "growing".
      final t = i / (bars - 1);
      final h = (0.28 + t * 0.55 + rng.nextDouble() * 0.17).clamp(0.15, 1.0) * size.height;
      final rect = Rect.fromLTWH(x, size.height - h, barWidth, h);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(barWidth * 0.3)),
        Paint()..color = color.withOpacity(0.35 + t * 0.5),
      );
      x += barWidth + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _BarTrendPainter oldDelegate) => false;
}

/// A partial ring showing a percentage (used for BTC Dominance).
class MarketDonutRing extends StatelessWidget {
  final double percent; // 0..100
  final double size;

  const MarketDonutRing({super.key, required this.percent, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: _DonutRingPainter(percent: percent));
  }
}

class _DonutRingPainter extends CustomPainter {
  final double percent;
  _DonutRingPainter({required this.percent});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 3;
    final track = Paint()
      ..color = NexbitColors.line
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    final arc = Paint()
      ..color = NexbitColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, track);
    final sweep = 2 * pi * (percent / 100).clamp(0.0, 1.0);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -pi / 2, sweep, false, arc);
  }

  @override
  bool shouldRepaint(covariant _DonutRingPainter oldDelegate) => oldDelegate.percent != percent;
}

/// A short up-trending line visual (used for the Total Market Cap card) —
/// thin wrapper so callers don't need to know it's really a [MiniSparkline].
class MarketLineTrend extends StatelessWidget {
  final bool isUp;
  final int seed;
  const MarketLineTrend({super.key, required this.isUp, required this.seed});

  @override
  Widget build(BuildContext context) {
    return MiniSparkline(isUp: isUp, seed: seed, width: 56, height: 34, filled: true, points: 10);
  }
}
