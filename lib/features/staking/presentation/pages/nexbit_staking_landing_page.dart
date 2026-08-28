import 'package:flutter/material.dart';
import '../../../../core/i18n/strings.dart';
import '../../../../core/theme/nexbit_theme.dart';
import '../../../auth/presentation/pages/nexbit_login_page.dart';
import '../../../auth/presentation/pages/nexbit_register_page.dart';
import '../../../blog/presentation/pages/nexbit_blog_page.dart';
import '../../../landing/presentation/widgets/max_width_box.dart';
import '../../../landing/presentation/widgets/network_background.dart';
import '../../../landing/presentation/widgets/nexbit_buttons.dart';
import '../../../landing/presentation/widgets/nexbit_navbar.dart';
import '../../../landing/presentation/widgets/scroll_reveal.dart';
import '../../../futures/presentation/pages/nexbit_futures_page.dart';
import '../../../market/presentation/pages/nexbit_market_page.dart';
import '../../../market/presentation/pages/nexbit_price_page.dart';
import '../../domain/models/staking_asset.dart';
import 'nexbit_staking_detail_page.dart';
import 'nexbit_staking_marketplace_page.dart';

/// Staking landing page — the entry point reached from the navbar's
/// "Staking" link: a hero pitch plus a quick-pick grid of the most
/// popular assets, each jumping straight into the staking flow.
class NexbitStakingLandingPage extends StatelessWidget {
  const NexbitStakingLandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    void openMarketplace() {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NexbitStakingMarketplacePage()));
    }

    void openDetail(StakingAsset asset) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => NexbitStakingDetailPage(asset: asset)));
    }

    return Scaffold(
      backgroundColor: NexbitColors.bg,
      body: Stack(
        children: [
          const Positioned.fill(child: NetworkBackground()),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < kNexbitMobileBreakpoint;
                return Column(
                  children: [
                    NexbitNavbar(
                      isMobile: isMobile,
                      activeId: 'staking',
                      onLogoTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
                      onHargaTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const NexbitPricePage()),
                      ),
                      onMarketTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const NexbitMarketPage()),
                      ),
                      onStakingTap: openMarketplace,
                      onFuturesTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const NexbitFuturesPage()),
                      ),
                      onBlogTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const NexbitBlogPage()),
                      ),
                      onLoginTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const NexbitLoginPage()),
                      ),
                      onRegisterTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const NexbitRegisterPage()),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            _Hero(isMobile: isMobile, onStakeNow: openMarketplace, onLearnMore: openMarketplace),
                            ScrollReveal(
                              child: _AssetsSection(isMobile: isMobile, onSeeAll: openMarketplace, onStake: openDetail),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  final bool isMobile;
  final VoidCallback onStakeNow;
  final VoidCallback onLearnMore;
  const _Hero({required this.isMobile, required this.onStakeNow, required this.onLearnMore});

  @override
  Widget build(BuildContext context) {
    final textColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        RichText(
          text: TextSpan(
            style: NexbitText.display(fontSize: isMobile ? 32 : 48, height: 1.1),
            children: [
              TextSpan(text: '${S.stakingHeroLine1}\n'),
              TextSpan(
                text: S.stakingHeroLine2,
                style: TextStyle(
                  foreground: Paint()
                    ..shader = NexbitColors.accentGradient.createShader(const Rect.fromLTWH(0, 0, 260, 60)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Text(S.stakingHeroSubtitle, style: NexbitText.body(fontSize: 15.5, height: 1.6)),
        ),
        const SizedBox(height: 28),
        Wrap(
          spacing: 14,
          runSpacing: 12,
          children: [
            PrimaryButton(label: S.stakingCtaPrimary, onTap: onStakeNow),
            OutlineButton(label: S.stakingCtaSecondary, onTap: onLearnMore),
          ],
        ),
        const SizedBox(height: 30),
        Wrap(
          spacing: 22,
          runSpacing: 12,
          children: [
            _FeatureBullet(icon: Icons.verified_outlined, label: S.stakingFeatureSafe),
            _FeatureBullet(icon: Icons.speed_outlined, label: S.stakingFeatureApy),
            _FeatureBullet(icon: Icons.bolt_rounded, label: S.stakingFeatureDaily),
          ],
        ),
      ],
    );

    final illustration = const _StakingIllustration();

    return Padding(
      padding: EdgeInsets.fromLTRB(isMobile ? 22 : 56, 34, isMobile ? 22 : 56, 56),
      child: MaxWidthBox(
        child: isMobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [textColumn, const SizedBox(height: 40), Center(child: illustration)],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(flex: 110, child: textColumn),
                  const SizedBox(width: 40),
                  Expanded(flex: 90, child: Align(alignment: Alignment.centerRight, child: illustration)),
                ],
              ),
      ),
    );
  }
}

class _FeatureBullet extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FeatureBullet({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 17, color: NexbitColors.accent),
        const SizedBox(width: 7),
        Text(label, style: NexbitText.body(fontSize: 13.5, weight: FontWeight.w500, color: NexbitColors.text)),
      ],
    );
  }
}

/// Original "vault + floating assets" graphic — plain shapes and Material
/// icons, not a copy of any real site's artwork.
class _StakingIllustration extends StatelessWidget {
  const _StakingIllustration();

  @override
  Widget build(BuildContext context) {
    const size = 320.0;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size * 0.62,
            height: size * 0.62,
            decoration: BoxDecoration(
              gradient: NexbitColors.accentGradient,
              borderRadius: BorderRadius.circular(size * 0.1),
              boxShadow: [
                BoxShadow(color: NexbitColors.accent.withOpacity(0.28), blurRadius: 60, spreadRadius: -8),
              ],
            ),
            alignment: Alignment.center,
            child: Icon(Icons.lock_outline_rounded, size: size * 0.22, color: const Color(0xFF04120E).withOpacity(0.6)),
          ),
          Positioned(
            top: size * 0.02,
            left: size * 0.06,
            child: _FloatingCoin(label: 'Ξ', color: const Color(0xFF627EEA), size: size * 0.2),
          ),
          Positioned(
            top: size * 0.1,
            right: size * 0.0,
            child: _FloatingCoin(label: 'T', color: const Color(0xFF26A17B), size: size * 0.17),
          ),
          Positioned(
            bottom: size * 0.06,
            left: size * 0.0,
            child: _FloatingCoin(label: '₿', color: const Color(0xFFF7931A), size: size * 0.18),
          ),
          Positioned(
            bottom: size * 0.0,
            right: size * 0.1,
            child: Container(
              width: size * 0.14,
              height: size * 0.14,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: NexbitColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: NexbitColors.line),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 6))],
              ),
              child: Icon(Icons.autorenew_rounded, size: size * 0.07, color: NexbitColors.accent),
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingCoin extends StatelessWidget {
  final String label;
  final Color color;
  final double size;
  const _FloatingCoin({required this.label, required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Text(label,
          style: NexbitText.mono(fontSize: size * 0.4, weight: FontWeight.w700, color: const Color(0xFF04120E))),
    );
  }
}

class _AssetsSection extends StatelessWidget {
  final bool isMobile;
  final VoidCallback onSeeAll;
  final ValueChanged<StakingAsset> onStake;
  const _AssetsSection({required this.isMobile, required this.onSeeAll, required this.onStake});

  @override
  Widget build(BuildContext context) {
    final featured = kStakingAssets.take(4).toList();
    return Container(
      width: double.infinity,
      color: Colors.transparent,
      padding: EdgeInsets.fromLTRB(isMobile ? 22 : 56, 8, isMobile ? 22 : 56, 60),
      child: MaxWidthBox(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(S.stakingAvailableAssets, style: NexbitText.display(fontSize: isMobile ? 20 : 24, weight: FontWeight.w700)),
                Hoverable(
                  hoverScale: 1.04,
                  builder: (context, hovered) => InkWell(
                    onTap: onSeeAll,
                    child: Text('${S.stakingSeeAll} →',
                        style: NexbitText.body(
                            fontSize: 13.5, weight: FontWeight.w600, color: hovered ? NexbitColors.text : NexbitColors.accent)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 18,
              runSpacing: 18,
              children: [for (final a in featured) _StakingAssetCard(asset: a, onStake: () => onStake(a))],
            ),
          ],
        ),
      ),
    );
  }
}

class _StakingAssetCard extends StatelessWidget {
  final StakingAsset asset;
  final VoidCallback onStake;
  const _StakingAssetCard({required this.asset, required this.onStake});

  @override
  Widget build(BuildContext context) {
    final isFlexible = asset.defaultDuration == 'flexible';
    return Container(
      width: 260,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: NexbitColors.panel,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: NexbitColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: asset.iconColor, borderRadius: BorderRadius.circular(10)),
                child: Text(asset.iconLabel,
                    style: NexbitText.mono(fontSize: 15, weight: FontWeight.w700, color: const Color(0xFF04120E))),
              ),
              _DurationBadge(isFlexible: isFlexible, days: asset.defaultDurationOption.days),
            ],
          ),
          const SizedBox(height: 12),
          Text(asset.id, style: NexbitText.body(fontSize: 15, weight: FontWeight.w700, color: NexbitColors.text)),
          Text(asset.name, style: NexbitText.body(fontSize: 12, color: NexbitColors.muted)),
          const SizedBox(height: 16),
          Text(S.stakingApyLabel, style: NexbitText.body(fontSize: 11, color: NexbitColors.muted2)),
          const SizedBox(height: 2),
          Text('${asset.listApy.toStringAsFixed(2)}%',
              style: NexbitText.mono(fontSize: 22, weight: FontWeight.w700, color: NexbitColors.accent)),
          const SizedBox(height: 12),
          Text(S.stakingMinimumLabel, style: NexbitText.body(fontSize: 11, color: NexbitColors.muted2)),
          const SizedBox(height: 2),
          Text('${formatStakeAmount(asset.minStake, decimals: asset.minStake < 1 ? 2 : 0)} ${asset.id}',
              style: NexbitText.mono(fontSize: 13, weight: FontWeight.w600)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: Hoverable(
              pressScale: 0.97,
              builder: (context, hovered) => AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                curve: Curves.easeOut,
                decoration: BoxDecoration(
                  gradient: NexbitColors.accentGradient,
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: hovered
                      ? [BoxShadow(color: NexbitColors.accent.withOpacity(0.4), blurRadius: 18, spreadRadius: 1)]
                      : [],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(9),
                    onTap: onStake,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(S.stakingStakeNow,
                          textAlign: TextAlign.center,
                          style: NexbitText.body(fontSize: 13.5, weight: FontWeight.w700, color: const Color(0xFF04120E))),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// "Flexible" (mint outline) or "N Hari"/"N Days" (amber fill) tag, shown
/// on asset cards/rows to indicate the pre-selected staking duration.
class _DurationBadge extends StatelessWidget {
  final bool isFlexible;
  final int days;
  const _DurationBadge({required this.isFlexible, required this.days});

  @override
  Widget build(BuildContext context) {
    const amber = Color(0xFFF3BA2F);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: isFlexible ? Colors.transparent : amber,
        borderRadius: BorderRadius.circular(20),
        border: isFlexible ? Border.all(color: NexbitColors.accent) : null,
      ),
      child: Text(
        isFlexible ? S.stakingFlexible : S.stakingDaysBadge(days),
        style: NexbitText.body(
          fontSize: 10.5,
          weight: FontWeight.w700,
          color: isFlexible ? NexbitColors.accent : const Color(0xFF1A1300),
        ),
      ),
    );
  }
}
