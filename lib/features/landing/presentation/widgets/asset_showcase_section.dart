import 'package:flutter/material.dart';
import '../../../../core/i18n/strings.dart';
import '../../../../core/theme/nexbit_theme.dart';
import 'max_width_box.dart';
import 'nexbit_buttons.dart';

/// One entry in the supported-assets grid — a crypto asset or a payment
/// method category, shown as a small badge card. The "+50 Lainnya" tile
/// uses a text-only style instead of an icon.
class _AssetBadgeData {
  final String label;
  final IconData icon;
  final Color color;
  final bool big;
  const _AssetBadgeData(this.label, this.icon, this.color, {this.big = false});
}

const _kAssetColumns = <List<_AssetBadgeData>>[
  [
    _AssetBadgeData('Bitcoin', Icons.currency_bitcoin, Color(0xFFF7931A)),
    _AssetBadgeData('Perfect Money', Icons.account_balance_wallet_outlined, Color(0xFF1E7A46)),
    _AssetBadgeData('Neteller', Icons.account_circle_outlined, Color(0xFF6FCF3C)),
  ],
  [
    _AssetBadgeData('Ethereum', Icons.diamond_outlined, Color(0xFF627EEA)),
    _AssetBadgeData('PayPal', Icons.account_balance_outlined, Color(0xFF2790C3)),
    _AssetBadgeData('Polkadot', Icons.hub_outlined, Color(0xFFE6007A)),
    _AssetBadgeData('Ripple', Icons.change_history_outlined, Color(0xFF345D9D)),
  ],
  [
    _AssetBadgeData('Stellar', Icons.blur_circular_outlined, Color(0xFF7D00FF)),
    _AssetBadgeData('Skrill', Icons.credit_card_outlined, Color(0xFF862165)),
    _AssetBadgeData('+50 Lainnya', Icons.apps, NexbitColors.accent, big: true),
  ],
];

/// "700+ Aset Kripto Tersedia" section: a staggered grid of supported
/// assets/payment categories on one side, trust copy + CTA on the other —
/// mirrors the classic exchange-landing-page pattern.
class AssetShowcaseSection extends StatelessWidget {
  final bool isMobile;
  const AssetShowcaseSection({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    // Not `const` — its subtree renders locale-dependent text (S.xxx),
    // so it must stay eligible to rebuild when appLocale changes.
    final grid = _AssetGrid();

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          S.assetShowcaseHeading,
          style: NexbitText.display(fontSize: isMobile ? 26 : 32, color: NexbitColors.accent, height: 1.25),
        ),
        const SizedBox(height: 18),
        Text(
          S.assetShowcaseSubheading,
          style: NexbitText.body(fontSize: 15, height: 1.65),
        ),
        const SizedBox(height: 32),
        Wrap(
          spacing: 40,
          runSpacing: 24,
          children: [
            _TrustFeature(
              icon: Icons.shield_outlined,
              title: S.assetShowcaseFeature1Title,
              description: S.assetShowcaseFeature1Desc,
            ),
            _TrustFeature(
              icon: Icons.verified_outlined,
              title: S.assetShowcaseFeature2Title,
              description: S.assetShowcaseFeature2Desc,
            ),
          ],
        ),
        const SizedBox(height: 32),
        PrimaryButton(label: S.assetShowcaseCta, onTap: () {}),
      ],
    );

    return Container(
      width: double.infinity,
      // Transparent so the animated constellation background (fixed behind
      // the whole page, same as the hero) stays consistent through every
      // section instead of being interrupted by a solid color block.
      color: Colors.transparent,
      padding: EdgeInsets.fromLTRB(isMobile ? 22 : 56, 70, isMobile ? 22 : 56, 70),
      child: MaxWidthBox(
        child: isMobile
            ? Column(children: [Center(child: grid), const SizedBox(height: 44), content])
            : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(flex: 90, child: Center(child: grid)),
                  const SizedBox(width: 60),
                  Expanded(flex: 110, child: content),
                ],
              ),
      ),
    );
  }
}

class _AssetGrid extends StatelessWidget {
  const _AssetGrid();

  @override
  Widget build(BuildContext context) {
    const topOffsets = [40.0, 0.0, 40.0];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < _kAssetColumns.length; i++) ...[
          if (i > 0) const SizedBox(width: 14),
          Padding(
            padding: EdgeInsets.only(top: topOffsets[i]),
            child: Column(
              children: [
                for (final data in _kAssetColumns[i]) ...[
                  _AssetBadge(data: data),
                  const SizedBox(height: 14),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _AssetBadge extends StatelessWidget {
  final _AssetBadgeData data;
  const _AssetBadge({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 104,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      decoration: BoxDecoration(
        color: NexbitColors.surface2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: NexbitColors.line),
      ),
      child: data.big
          ? Center(
              child: Text(
                S.assetShowcaseMore,
                textAlign: TextAlign.center,
                style: NexbitText.body(fontSize: 13, weight: FontWeight.w700, color: NexbitColors.accent),
              ),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: data.color.withOpacity(0.16), shape: BoxShape.circle),
                  child: Icon(data.icon, color: data.color, size: 20),
                ),
                const SizedBox(height: 10),
                Text(data.label,
                    textAlign: TextAlign.center,
                    style: NexbitText.body(fontSize: 12, weight: FontWeight.w500, color: NexbitColors.text)),
              ],
            ),
    );
  }
}

class _TrustFeature extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  const _TrustFeature({required this.icon, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 230,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration:
                BoxDecoration(color: NexbitColors.accent.withOpacity(0.14), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: NexbitColors.accent, size: 22),
          ),
          const SizedBox(height: 12),
          Text(title, style: NexbitText.body(fontSize: 15, weight: FontWeight.w700, color: NexbitColors.text)),
          const SizedBox(height: 6),
          Text(description, style: NexbitText.body(fontSize: 13, height: 1.55)),
        ],
      ),
    );
  }
}
