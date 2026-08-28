import 'package:flutter/material.dart';
import '../../../../core/i18n/strings.dart';
import '../../../../core/theme/nexbit_theme.dart';

/// The three-feature strip at the bottom of the Futures page (Leverage
/// Fleksibel / Likuiditas Tinggi / Keamanan Terjamin) — plain marketing
/// copy, same spirit as the trust-badge rows on the landing page.
class FuturesFeatureRow extends StatelessWidget {
  const FuturesFeatureRow({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final items = [
          (Icons.hourglass_bottom_outlined, S.futuresFeatureLeverageTitle, S.futuresFeatureLeverageDesc),
          (Icons.show_chart, S.futuresFeatureLiquidityTitle, S.futuresFeatureLiquidityDesc),
          (Icons.shield_outlined, S.futuresFeatureSecurityTitle, S.futuresFeatureSecurityDesc),
        ];
        final narrow = constraints.maxWidth < 720;
        final cards = items.map((e) => _FeatureCard(icon: e.$1, title: e.$2, desc: e.$3)).toList();
        if (narrow) {
          return Column(children: [for (final c in cards) Padding(padding: const EdgeInsets.only(bottom: 12), child: c)]);
        }
        return Row(
          children: [
            for (var i = 0; i < cards.length; i++) ...[
              if (i > 0) const SizedBox(width: 16),
              Expanded(child: cards[i]),
            ],
          ],
        );
      },
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  const _FeatureCard({required this.icon, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NexbitColors.panel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: NexbitColors.line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: NexbitColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 20, color: NexbitColors.accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: NexbitText.body(fontSize: 13.5, weight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text(desc, style: NexbitText.body(fontSize: 12, color: NexbitColors.muted, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
