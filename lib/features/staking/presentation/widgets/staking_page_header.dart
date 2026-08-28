import 'package:flutter/material.dart';
import '../../../../core/theme/nexbit_theme.dart';

/// Per-page header used inside the staking shell's main content area —
/// title + subtitle on the left, a notification bell and user avatar on
/// the right. Replaces a site-wide top navbar for these pages, matching
/// the reference design's dashboard-style layout.
class StakingPageHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isMobile;
  const StakingPageHeader({super.key, required this.title, required this.subtitle, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: NexbitText.display(fontSize: isMobile ? 21 : 25, weight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(subtitle, style: NexbitText.body(fontSize: 13.5)),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: NexbitColors.panel,
                shape: BoxShape.circle,
                border: Border.all(color: NexbitColors.line),
              ),
              child: const Icon(Icons.notifications_none_rounded, size: 18, color: NexbitColors.muted),
            ),
            const SizedBox(width: 10),
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(gradient: NexbitColors.accentGradient, shape: BoxShape.circle),
              child: Icon(Icons.person_outline, size: 19, color: const Color(0xFF04120E).withOpacity(0.65)),
            ),
          ],
        ),
      ],
    );
  }
}
