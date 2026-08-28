import 'package:flutter/material.dart';

/// Fades + slides [child] into place the first time it scrolls into view,
/// so the long landing page doesn't feel like a static wall of sections.
///
/// No extra package needed: it listens directly to the enclosing
/// [Scrollable]'s [ScrollPosition] (a [ChangeNotifier] that fires on every
/// pixel of scroll) and re-checks its own on-screen position via
/// [RenderBox.localToGlobal]. Once visible it stays visible — this is a
/// one-shot entrance, not a repeating scroll-linked effect.
class ScrollReveal extends StatefulWidget {
  final Widget child;
  final double slideFraction;
  final Duration duration;

  const ScrollReveal({
    super.key,
    required this.child,
    this.slideFraction = 0.06,
    this.duration = const Duration(milliseconds: 650),
  });

  @override
  State<ScrollReveal> createState() => _ScrollRevealState();
}

class _ScrollRevealState extends State<ScrollReveal> {
  bool _visible = false;
  ScrollPosition? _position;

  void _checkVisibility() {
    if (_visible || !mounted) return;
    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.attached) return;
    final viewportHeight = MediaQuery.of(context).size.height;
    final dy = renderObject.localToGlobal(Offset.zero).dy;
    // Reveal once the top of the section has scrolled into the lower
    // ~88% of the viewport, so it animates in just before it's fully seen.
    if (dy < viewportHeight * 0.88) {
      setState(() => _visible = true);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Listening straight to the Scrollable's ScrollPosition (rather than
    // NotificationListener<ScrollNotification>) is the more direct route:
    // it's the same ChangeNotifier a ScrollController would observe, so
    // it fires reliably on every scroll update regardless of how the
    // scroll gesture was driven.
    final newPosition = Scrollable.maybeOf(context)?.position;
    if (!identical(newPosition, _position)) {
      _position?.removeListener(_checkVisibility);
      _position = newPosition;
      _position?.addListener(_checkVisibility);
    }
    // Catches sections that are already on-screen on first paint (no
    // scroll event fires for those).
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkVisibility());
  }

  @override
  void dispose() {
    _position?.removeListener(_checkVisibility);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: _visible ? Offset.zero : Offset(0, widget.slideFraction),
      duration: widget.duration,
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: _visible ? 1 : 0,
        duration: widget.duration,
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
