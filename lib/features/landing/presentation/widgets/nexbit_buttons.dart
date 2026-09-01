import 'package:flutter/material.dart';
import '../../../../core/theme/nexbit_theme.dart';

/// Wraps [builder] with a smooth hover/press scale animation and exposes
/// the current hover flag so the child can animate its own color too —
/// shared by every clickable label/button on the landing page.
class Hoverable extends StatefulWidget {
  final Widget Function(BuildContext context, bool hovered) builder;
  final double hoverScale;
  final double pressScale;

  const Hoverable({
    super.key,
    required this.builder,
    this.hoverScale = 1.05,
    this.pressScale = 0.96,
  });

  @override
  State<Hoverable> createState() => _HoverableState();
}

class _HoverableState extends State<Hoverable> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final scale = _pressed ? widget.pressScale : (_hovered ? widget.hoverScale : 1.0);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() {
        _hovered = false;
        _pressed = false;
      }),
      child: Listener(
        onPointerDown: (_) => setState(() => _pressed = true),
        onPointerUp: (_) => setState(() => _pressed = false),
        onPointerCancel: (_) => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          child: widget.builder(context, _hovered),
        ),
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  /// Shows a spinner instead of the label and ignores taps — for a
  /// button that kicks off a real network request (staking, etc.), so
  /// a slow backend can't be double-submitted and the tap has visible
  /// feedback instead of appearing to do nothing.
  final bool loading;
  const PrimaryButton({super.key, required this.label, required this.onTap, this.loading = false});

  @override
  Widget build(BuildContext context) {
    return Hoverable(
      pressScale: 0.95,
      builder: (context, hovered) => AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          gradient: NexbitColors.accentGradient,
          borderRadius: BorderRadius.circular(10),
          boxShadow: hovered
              ? [
                  BoxShadow(
                    color: NexbitColors.accent.withOpacity(0.45),
                    blurRadius: 24,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: loading ? null : onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 15),
              child: loading
                  ? const Center(
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2.4, color: Color(0xFF04120E)),
                      ),
                    )
                  : Text(label,
                      textAlign: TextAlign.center,
                      style: NexbitText.body(fontSize: 15, weight: FontWeight.w700, color: const Color(0xFF04120E))),
            ),
          ),
        ),
      ),
    );
  }
}

class OutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const OutlineButton({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Hoverable(
      builder: (context, hovered) => AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: hovered ? NexbitColors.accent : NexbitColors.line),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 160),
                curve: Curves.easeOut,
                style: NexbitText.body(
                  fontSize: 15,
                  weight: FontWeight.w600,
                  color: hovered ? NexbitColors.accent : NexbitColors.text,
                ),
                child: Text(label),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
