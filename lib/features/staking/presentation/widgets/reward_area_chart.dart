import 'package:flutter/material.dart';
import '../../../../core/theme/nexbit_theme.dart';

class RewardPoint {
  final String day; // short day label, e.g. 'Sen'
  final String dateLabel; // full label shown in the tooltip, e.g. 'Jum, 18 Mei'
  final double value;
  const RewardPoint({required this.day, required this.dateLabel, required this.value});
}

/// A plain [CustomPainter] area/line chart with a hover tooltip — zero
/// extra chart-library dependencies, matching the rest of this app's
/// stance on keeping dependencies light. Hover (or, on touch, tap-drag)
/// over the chart to see a point's exact value, same as a real chart lib.
class RewardAreaChart extends StatefulWidget {
  final List<RewardPoint> points;
  final double maxY;
  const RewardAreaChart({super.key, required this.points, this.maxY = 50});

  @override
  State<RewardAreaChart> createState() => _RewardAreaChartState();
}

class _RewardAreaChartState extends State<RewardAreaChart> {
  int? _hoverIndex;
  static const _leftAxisWidth = 34.0;
  static const _chartHeight = 200.0;
  static const _bottomAxisHeight = 24.0;

  double _xFor(int i, double chartWidth) =>
      _leftAxisWidth + (widget.points.length > 1 ? chartWidth * i / (widget.points.length - 1) : 0.0);

  double _yFor(int i) => _chartHeight * (1 - (widget.points[i].value / widget.maxY).clamp(0.0, 1.0));

  void _updateHover(Offset local, double chartWidth) {
    final relX = (local.dx - _leftAxisWidth).clamp(0.0, chartWidth);
    final idx = widget.points.length > 1 ? (relX / chartWidth * (widget.points.length - 1)).round() : 0;
    final clamped = idx.clamp(0, widget.points.length - 1);
    if (clamped != _hoverIndex) setState(() => _hoverIndex = clamped);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final chartWidth = constraints.maxWidth - _leftAxisWidth;
        final totalHeight = _chartHeight + _bottomAxisHeight;
        final tooltip = _hoverIndex == null
            ? null
            : _TooltipBubble(point: widget.points[_hoverIndex!]);

        return MouseRegion(
          onHover: (e) => _updateHover(e.localPosition, chartWidth),
          onExit: (_) => setState(() => _hoverIndex = null),
          child: GestureDetector(
            onPanUpdate: (d) => _updateHover(d.localPosition, chartWidth),
            onPanDown: (d) => _updateHover(d.localPosition, chartWidth),
            child: SizedBox(
              width: constraints.maxWidth,
              height: totalHeight,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  CustomPaint(
                    size: Size(constraints.maxWidth, totalHeight),
                    painter: _AreaChartPainter(
                      points: widget.points,
                      maxY: widget.maxY,
                      leftAxisWidth: _leftAxisWidth,
                      chartHeight: _chartHeight,
                      hoverIndex: _hoverIndex,
                    ),
                  ),
                  if (tooltip != null)
                    Positioned(
                      left: (_xFor(_hoverIndex!, chartWidth) - 55).clamp(0.0, constraints.maxWidth - 112),
                      top: (_yFor(_hoverIndex!) - 58).clamp(-10.0, totalHeight.toDouble()),
                      child: tooltip,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TooltipBubble extends StatelessWidget {
  final RewardPoint point;
  const _TooltipBubble({required this.point});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: NexbitColors.surface2,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: NexbitColors.line),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 14, offset: const Offset(0, 6))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(point.dateLabel, style: NexbitText.body(fontSize: 10.5, color: NexbitColors.muted)),
            Text('\$${point.value.toStringAsFixed(2)}',
                style: NexbitText.mono(fontSize: 13, weight: FontWeight.w700, color: NexbitColors.accent)),
          ],
        ),
      ),
    );
  }
}

class _AreaChartPainter extends CustomPainter {
  final List<RewardPoint> points;
  final double maxY;
  final double leftAxisWidth;
  final double chartHeight;
  final int? hoverIndex;

  _AreaChartPainter({
    required this.points,
    required this.maxY,
    required this.leftAxisWidth,
    required this.chartHeight,
    required this.hoverIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final chartWidth = size.width - leftAxisWidth;

    // Grid lines + $ axis labels.
    final gridPaint = Paint()
      ..color = NexbitColors.lineSoft
      ..strokeWidth = 1;
    const steps = 5;
    for (var i = 0; i <= steps; i++) {
      final y = chartHeight * i / steps;
      canvas.drawLine(Offset(leftAxisWidth, y), Offset(size.width, y), gridPaint);
      final label = '\$${(maxY * (steps - i) / steps).round()}';
      final tp = TextPainter(
        text: TextSpan(text: label, style: NexbitText.body(fontSize: 9.5, color: NexbitColors.muted2)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(0, y - tp.height / 2));
    }

    if (points.isEmpty) return;

    Offset offsetFor(int i) {
      final dx = leftAxisWidth + (points.length > 1 ? chartWidth * i / (points.length - 1) : 0.0);
      final dy = chartHeight * (1 - (points[i].value / maxY).clamp(0.0, 1.0));
      return Offset(dx, dy);
    }

    // Gradient-filled area under the line.
    final areaPath = Path()..moveTo(offsetFor(0).dx, chartHeight);
    for (var i = 0; i < points.length; i++) {
      areaPath.lineTo(offsetFor(i).dx, offsetFor(i).dy);
    }
    areaPath.lineTo(offsetFor(points.length - 1).dx, chartHeight);
    areaPath.close();
    final areaPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [NexbitColors.accent.withOpacity(0.28), NexbitColors.accent.withOpacity(0.0)],
      ).createShader(Rect.fromLTWH(leftAxisWidth, 0, chartWidth, chartHeight));
    canvas.drawPath(areaPath, areaPaint);

    // Stroke line.
    final linePath = Path()..moveTo(offsetFor(0).dx, offsetFor(0).dy);
    for (var i = 1; i < points.length; i++) {
      linePath.lineTo(offsetFor(i).dx, offsetFor(i).dy);
    }
    canvas.drawPath(
      linePath,
      Paint()
        ..color = NexbitColors.accent
        ..strokeWidth = 2.2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Point dots — bigger + a vertical guide line for the hovered index.
    for (var i = 0; i < points.length; i++) {
      final o = offsetFor(i);
      final isHover = i == hoverIndex;
      if (isHover) {
        canvas.drawLine(
          Offset(o.dx, 0),
          Offset(o.dx, chartHeight),
          Paint()
            ..color = NexbitColors.accent.withOpacity(0.25)
            ..strokeWidth = 1,
        );
      }
      canvas.drawCircle(o, isHover ? 5 : 2.6, Paint()..color = NexbitColors.bg);
      canvas.drawCircle(
        o,
        isHover ? 5 : 2.6,
        Paint()
          ..color = NexbitColors.accent
          ..style = PaintingStyle.stroke
          ..strokeWidth = isHover ? 2.4 : 1.6,
      );
    }

    // X-axis day labels.
    for (var i = 0; i < points.length; i++) {
      final tp = TextPainter(
        text: TextSpan(text: points[i].day, style: NexbitText.body(fontSize: 10.5, color: NexbitColors.muted2)),
        textDirection: TextDirection.ltr,
      )..layout();
      final x = offsetFor(i).dx - tp.width / 2;
      tp.paint(canvas, Offset(x, chartHeight + 6));
    }
  }

  @override
  bool shouldRepaint(covariant _AreaChartPainter oldDelegate) =>
      oldDelegate.hoverIndex != hoverIndex || oldDelegate.points != points;
}
