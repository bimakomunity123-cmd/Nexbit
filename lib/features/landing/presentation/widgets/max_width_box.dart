import 'package:flutter/material.dart';

/// Caps content to a sane reading width and centers it, so sections don't
/// stretch edge-to-edge (leaving a big empty gap in the middle) on very
/// wide/ultra-wide screens. Section backgrounds can stay full-width —
/// just wrap the inner Row/Column content that should be capped.
class MaxWidthBox extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const MaxWidthBox({super.key, required this.child, this.maxWidth = 1280});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
