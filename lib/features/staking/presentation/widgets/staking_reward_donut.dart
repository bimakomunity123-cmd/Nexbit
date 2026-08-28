import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/nexbit_theme.dart';

class DonutSlice {
  final String label;
  final Color color;
  final double percent; // 0-100
  const DonutSlice({required this.label, required this.color, required this.percent});
}

/// A plain [CustomPainter] ring chart — zero extra chart-library
/// dependencies, matching the rest of this app's "no intl / no heavy
/// packages" stance.
class StakingRewardDonut extends StatelessWidget {
  final List<DonutSlice> slices;
  final String centerValue;
  final String centerLabel;
  final double size;

  const StakingRewardDonut({
    super.key,
    required this.slices,
    required this.centerValue,
    required this.centerLabel,
    this.size = 160,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(size: Size(size, size), painter: _DonutPainter(slices)),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(centerValue, style: NexbitText.display(fontSize: size * 0.14, weight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(centerLabel, style: NexbitText.body(fontSize: size * 0.075, color: NexbitColors.muted)),
            ],
          ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<DonutSlice> slices;
  _DonutPainter(this.slices);

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.width * 0.16;
    final rect = Rect.fromLTWH(strokeWidth / 2, strokeWidth / 2, size.width - strokeWidth, size.height - strokeWidth);
    var start = -pi / 2;
    for (final s in slices) {
      final sweep = (s.percent / 100) * 2 * pi;
      final paint = Paint()
        ..color = s.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(rect, start, sweep - 0.03, false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) => oldDelegate.slices != slices;
}
