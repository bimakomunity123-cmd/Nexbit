import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../../../../core/theme/nexbit_theme.dart';

/// Animated dot-and-line "constellation" background, equivalent to the
/// canvas particle effect in the HTML prototype. Points drift slowly and
/// draw a connecting line to nearby neighbours.
class NetworkBackground extends StatefulWidget {
  const NetworkBackground({super.key});

  @override
  State<NetworkBackground> createState() => _NetworkBackgroundState();
}

class _NetworkBackgroundState extends State<NetworkBackground>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  List<_Point> _points = [];
  Size _lastSize = Size.zero;
  final _rng = Random();

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((_) => setState(_step));
    _ticker.start();
  }

  void _seed(Size size) {
    final count = min(90, ((size.width * size.height) / 22000).floor());
    _points = List.generate(count, (_) {
      return _Point(
        position: Offset(
          _rng.nextDouble() * size.width,
          _rng.nextDouble() * size.height,
        ),
        velocity: Offset(
          (_rng.nextDouble() - 0.5) * 0.5,
          (_rng.nextDouble() - 0.5) * 0.5,
        ),
      );
    });
    _lastSize = size;
  }

  void _step() {
    if (_points.isEmpty) return;
    for (final p in _points) {
      p.position += p.velocity;
      if (p.position.dx < 0 || p.position.dx > _lastSize.width) {
        p.velocity = Offset(-p.velocity.dx, p.velocity.dy);
      }
      if (p.position.dy < 0 || p.position.dy > _lastSize.height) {
        p.velocity = Offset(p.velocity.dx, -p.velocity.dy);
      }
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          if (size != _lastSize) {
            // Re-seed on size change (e.g. rotation, resize).
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) setState(() => _seed(size));
            });
            if (_points.isEmpty) _seed(size);
          }
          return CustomPaint(
            size: size,
            painter: _NetworkPainter(points: _points),
          );
        },
      ),
    );
  }
}

class _Point {
  Offset position;
  Offset velocity;
  _Point({required this.position, required this.velocity});
}

class _NetworkPainter extends CustomPainter {
  final List<_Point> points;
  static const double _linkDistance = 130;

  _NetworkPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()..strokeWidth = 1;
    final dotPaint = Paint()..color = NexbitColors.accent.withOpacity(0.55);

    for (var i = 0; i < points.length; i++) {
      for (var j = i + 1; j < points.length; j++) {
        final a = points[i].position;
        final b = points[j].position;
        final dist = (a - b).distance;
        if (dist < _linkDistance) {
          linePaint.color =
              NexbitColors.accent.withOpacity(0.14 * (1 - dist / _linkDistance));
          canvas.drawLine(a, b, linePaint);
        }
      }
    }
    for (final p in points) {
      canvas.drawCircle(p.position, 1.6, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _NetworkPainter oldDelegate) => true;
}
