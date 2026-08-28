import 'package:flutter/material.dart';

import '../theme/nexbit_theme.dart';

/// The small gradient "N" mark used everywhere the Nexbit wordmark appears
/// (landing navbar, trading topbar, staking sidebar, login page). Kept as a
/// single widget so every spot renders the exact same letterform instead of
/// four hand-tuned copies drifting apart.
class NexbitLogoMark extends StatelessWidget {
  final double size;
  final double borderRadius;

  const NexbitLogoMark({super.key, this.size = 30, this.borderRadius = 8});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: NexbitColors.accentGradient,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Text(
        'N',
        style: NexbitText.display(
          fontSize: size * 0.56,
          weight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

/// Full lockup: the gradient mark plus the "Nexbit" wordmark next to it.
class NexbitLogoLockup extends StatelessWidget {
  final double markSize;
  final double? borderRadius;
  final double wordmarkFontSize;
  final double spacing;

  const NexbitLogoLockup({
    super.key,
    this.markSize = 30,
    this.borderRadius,
    this.wordmarkFontSize = 20,
    this.spacing = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        NexbitLogoMark(size: markSize, borderRadius: borderRadius ?? markSize * 0.27),
        SizedBox(width: spacing),
        Text('Nexbit', style: NexbitText.display(fontSize: wordmarkFontSize, weight: FontWeight.w700)),
      ],
    );
  }
}
