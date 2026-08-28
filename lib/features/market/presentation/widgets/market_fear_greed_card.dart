import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/i18n/strings.dart';
import '../../../../core/theme/nexbit_theme.dart';

/// The classic "Fear & Greed Index" gauge every crypto market dashboard
/// has — a 0-100 sentiment score, plus yesterday/last-week for context.
/// There's no real sentiment feed behind this app, so the score is derived
/// from the same mock 24h-change data already on this page (see
/// [NexbitMarketPage._fearGreedIndex]) rather than being an unrelated
/// random number.
class MarketFearGreedCard extends StatelessWidget {
  final int value; // 0..100
  final int yesterday;
  final int lastWeek;

  const MarketFearGreedCard({super.key, required this.value, required this.yesterday, required this.lastWeek});

  static (String, Color) _band(int v) {
    if (v < 25) return (S.marketFearGreedExtremeFear, NexbitColors.down);
    if (v < 45) return (S.marketFearGreedFear, const Color(0xFFFF9F5A));
    if (v < 56) return (S.marketFearGreedNeutral, NexbitColors.muted);
    if (v < 76) return (S.marketFearGreedGreed, const Color(0xFFA8E05F));
    return (S.marketFearGreedExtremeGreed, NexbitColors.up);
  }

  @override
  Widget build(BuildContext context) {
    final (label, color) = _band(value);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NexbitColors.panel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: NexbitColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.speed_outlined, size: 16, color: NexbitColors.accent),
              const SizedBox(width: 8),
              Text(S.marketFearGreedHeading, style: NexbitText.body(fontSize: 13.5, weight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 4),
          Center(
            child: SizedBox(
              width: 200,
              height: 118,
              child: CustomPaint(painter: _GaugePainter(value: value, needleColor: color)),
            ),
          ),
          Center(
            child: Column(
              children: [
                Text('$value', style: NexbitText.display(fontSize: 30, weight: FontWeight.w700, color: color)),
                Text(label, style: NexbitText.body(fontSize: 12.5, weight: FontWeight.w600, color: color)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: NexbitColors.lineSoft),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _miniStat(S.marketFearGreedYesterday, yesterday),
              _miniStat(S.marketFearGreedLastWeek, lastWeek),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, int v) {
    final (bandLabel, color) = _band(v);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: NexbitText.body(fontSize: 11, color: NexbitColors.muted2)),
        const SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$v', style: NexbitText.mono(fontSize: 13, weight: FontWeight.w700, color: color)),
            const SizedBox(width: 5),
            Text(bandLabel, style: NexbitText.body(fontSize: 11, color: NexbitColors.muted)),
          ],
        ),
      ],
    );
  }
}

class _GaugePainter extends CustomPainter {
  final int value;
  final Color needleColor;
  _GaugePainter({required this.value, required this.needleColor});

  static const _bandColors = [
    NexbitColors.down,
    Color(0xFFFF9F5A),
    NexbitColors.muted2,
    Color(0xFFA8E05F),
    NexbitColors.up,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height - 14);
    final radius = size.width / 2 - 10;
    const strokeWidth = 10.0;

    // Five discrete colour bands (0-20, 20-40, ..., 80-100), same spirit
    // as the real index's published gauge.
    const segSweep = pi / 5;
    for (var i = 0; i < 5; i++) {
      final paint = Paint()
        ..color = _bandColors[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        pi + segSweep * i,
        segSweep,
        false,
        paint,
      );
    }

    // Needle.
    final angle = pi + (value.clamp(0, 100) / 100) * pi;
    final needleLen = radius - strokeWidth - 4;
    final tip = center + Offset(cos(angle), sin(angle)) * needleLen;
    final needlePaint = Paint()
      ..color = NexbitColors.text
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, tip, needlePaint);
    canvas.drawCircle(center, 5.5, Paint()..color = needleColor);
    canvas.drawCircle(center, 2.5, Paint()..color = NexbitColors.text);
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) => oldDelegate.value != value;
}
