import 'package:flutter/material.dart';
import '../../../../core/i18n/strings.dart';
import '../../../../core/theme/nexbit_theme.dart';
import 'max_width_box.dart';
import 'nexbit_buttons.dart';

class _FooterColumn {
  final String title;
  final List<String> items;
  const _FooterColumn(this.title, this.items);
}

// Built at render time (not `const`) since the titles/items read the live
// [S] strings. Proper nouns — crypto/stock tickers, brand names — are
// intentionally left untranslated.
List<_FooterColumn> get _kLinkColumns => [
      _FooterColumn(S.footerMarketPrice, [S.footerLiveRate, S.navMarket]),
      _FooterColumn(S.footerNexbitFeatures, [S.navStaking, S.navMarket, S.footerAffiliate, S.footerGiftCard, S.navFutures]),
      _FooterColumn(S.footerProduct, [S.footerMobileCredit, S.footerElectricityToken, S.footerPayBills]),
      _FooterColumn(S.footerCompany, [S.footerContactUs, S.footerAboutUs]),
    ];

List<_FooterColumn> get _kAssetColumns => [
      _FooterColumn(S.footerOtherAssets, ['Paypal', 'Solana']),
      const _FooterColumn('', ['Bitcoin', 'Ethereum', 'Stellar', 'Ripple', 'Cardano']),
      const _FooterColumn('', ['Eos', 'Dash', 'Tether', 'Litecoin', 'Polkadot']),
      const _FooterColumn('', ['BNB', 'DogeCoin', 'Chainlink', 'MaticPolygon']),
      _FooterColumn('', ['Shiba Inu', 'AxieInfinity', S.navSahamAS, 'Saham Tesla', 'Saham SpaceX']),
    ];

const _kSocialIcons = <IconData>[
  Icons.smart_display_outlined,
  Icons.facebook_outlined,
  Icons.music_note_outlined,
  Icons.alternate_email,
  Icons.camera_alt_outlined,
  Icons.send_outlined,
  Icons.article_outlined,
];

/// Closing footer — brand mark, link columns, and a copyright/social bar.
class FooterSection extends StatelessWidget {
  final bool isMobile;
  const FooterSection({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.transparent,
      padding: EdgeInsets.fromLTRB(isMobile ? 22 : 56, 56, isMobile ? 22 : 56, 32),
      child: MaxWidthBox(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(gradient: NexbitColors.accentGradient, shape: BoxShape.circle),
                  child: const Icon(Icons.bolt_rounded, size: 16, color: Color(0xFF04120E)),
                ),
                const SizedBox(width: 8),
                Text('Nexbit',
                    style: NexbitText.display(fontSize: 18, weight: FontWeight.w700, color: NexbitColors.muted)),
              ],
            ),
            const SizedBox(height: 40),
            Wrap(
              spacing: 60,
              runSpacing: 32,
              children: [for (final c in _kLinkColumns) _FooterColumnView(column: c)],
            ),
            const SizedBox(height: 36),
            Wrap(
              spacing: 60,
              runSpacing: 24,
              children: [for (final c in _kAssetColumns) _FooterColumnView(column: c)],
            ),
            const SizedBox(height: 40),
            const Divider(color: NexbitColors.line),
            const SizedBox(height: 20),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.spaceBetween,
              spacing: 16,
              runSpacing: 16,
              children: [
                Text(S.footerCopyright,
                    style: NexbitText.body(fontSize: 12.5)),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [for (final icon in _kSocialIcons) _SocialIcon(icon: icon)],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FooterColumnView extends StatelessWidget {
  final _FooterColumn column;
  const _FooterColumnView({required this.column});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (column.title.isNotEmpty) ...[
            Text(column.title, style: NexbitText.body(fontSize: 13.5, weight: FontWeight.w700, color: NexbitColors.text)),
            const SizedBox(height: 14),
          ],
          for (final item in column.items)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _FooterLink(label: item),
            ),
        ],
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String label;
  const _FooterLink({required this.label});

  @override
  Widget build(BuildContext context) {
    return Hoverable(
      builder: (context, hovered) => InkWell(
        onTap: () {},
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          style: NexbitText.body(fontSize: 13, color: hovered ? NexbitColors.accent : NexbitColors.muted),
          child: Text(label),
        ),
      ),
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final IconData icon;
  const _SocialIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: Hoverable(
        hoverScale: 1.12,
        builder: (context, hovered) => AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: hovered ? NexbitColors.accent : NexbitColors.line),
          ),
          child: Icon(icon, size: 16, color: hovered ? NexbitColors.accent : NexbitColors.muted),
        ),
      ),
    );
  }
}
