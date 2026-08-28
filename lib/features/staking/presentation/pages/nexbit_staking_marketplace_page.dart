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

/// "Pilih Aset untuk Staking" — the full asset list, table-style, with an
/// explainer card underneath. Reached from the staking landing page's
/// "Lihat Semua" link or the navbar's "Staking" link directly.
class NexbitStakingMarketplacePage extends StatelessWidget {
  const NexbitStakingMarketplacePage({super.key});

  @override
  Widget build(BuildContext context) {
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
                      onStakingTap: () {},
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
                        padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 56, vertical: 40),
                        child: MaxWidthBox(
                          maxWidth: 980,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(S.stakingMarketplaceHeading,
                                  style: NexbitText.display(fontSize: isMobile ? 22 : 28, color: NexbitColors.accent)),
                              const SizedBox(height: 10),
                              Text(S.stakingMarketplaceSubheading, style: NexbitText.body(fontSize: 14.5, height: 1.6)),
                              const SizedBox(height: 28),
                              _AssetTable(onSelect: openDetail),
                              const SizedBox(height: 32),
                              ScrollReveal(child: const _WhatIsStakingCard()),
                            ],
                          ),
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

class _AssetTable extends StatelessWidget {
  final ValueChanged<StakingAsset> onSelect;
  const _AssetTable({required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: NexbitColors.panel,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: NexbitColors.line),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 560;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (wide)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Row(
                    children: [
                      Expanded(flex: 3, child: _HeaderLabel(S.stakingColAsset)),
                      Expanded(flex: 2, child: _HeaderLabel(S.stakingColApy, end: true)),
                      Expanded(flex: 2, child: _HeaderLabel(S.stakingColMinimum, end: true)),
                      Expanded(flex: 2, child: _HeaderLabel(S.stakingColPeriode, end: true)),
                      const SizedBox(width: 28),
                    ],
                  ),
                ),
              for (final a in kStakingAssets) _AssetRow(asset: a, wide: wide, onTap: () => onSelect(a)),
            ],
          );
        },
      ),
    );
  }
}

class _HeaderLabel extends StatelessWidget {
  final String text;
  final bool end;
  const _HeaderLabel(this.text, {this.end = false});

  @override
  Widget build(BuildContext context) {
    return Text(text,
        textAlign: end ? TextAlign.end : TextAlign.start,
        style: NexbitText.body(fontSize: 11.5, weight: FontWeight.w600, color: NexbitColors.muted2));
  }
}

class _AssetRow extends StatelessWidget {
  final StakingAsset asset;
  final bool wide;
  final VoidCallback onTap;
  const _AssetRow({required this.asset, required this.wide, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDefaultLocked = asset.defaultDuration != 'flexible';
    return Hoverable(
      hoverScale: 1.0,
      builder: (context, hovered) => InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: hovered ? NexbitColors.surface2 : (isDefaultLocked ? NexbitColors.accent.withOpacity(0.05) : null),
            border: Border(
              top: const BorderSide(color: NexbitColors.lineSoft),
              left: isDefaultLocked
                  ? const BorderSide(color: NexbitColors.accent, width: 2)
                  : const BorderSide(color: Colors.transparent, width: 2),
            ),
          ),
          child: wide ? _wideRow() : _narrowRow(),
        ),
      ),
    );
  }

  Widget _assetLabel() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: asset.iconColor, borderRadius: BorderRadius.circular(9)),
          child: Text(asset.iconLabel,
              style: NexbitText.mono(fontSize: 13, weight: FontWeight.w700, color: const Color(0xFF04120E))),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(asset.id, style: NexbitText.body(fontSize: 13.5, weight: FontWeight.w600, color: NexbitColors.text)),
            Text(asset.name, style: NexbitText.body(fontSize: 11.5, color: NexbitColors.muted2)),
          ],
        ),
      ],
    );
  }

  Widget _wideRow() {
    final d = asset.defaultDurationOption;
    return Row(
      children: [
        Expanded(flex: 3, child: _assetLabel()),
        Expanded(
          flex: 2,
          child: Text('${d.apy.toStringAsFixed(2)}%',
              textAlign: TextAlign.end, style: NexbitText.mono(fontSize: 13.5, weight: FontWeight.w700, color: NexbitColors.up)),
        ),
        Expanded(
          flex: 2,
          child: Text('${formatStakeAmount(asset.minStake, decimals: asset.minStake < 1 ? 2 : 0)} ${asset.id}',
              textAlign: TextAlign.end, style: NexbitText.mono(fontSize: 12.5)),
        ),
        Expanded(
          flex: 2,
          child: Align(
            alignment: Alignment.centerRight,
            child: _PeriodTag(isFlexible: asset.defaultDuration == 'flexible', days: d.days),
          ),
        ),
        const SizedBox(width: 8),
        const Icon(Icons.chevron_right, size: 18, color: NexbitColors.muted2),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _narrowRow() {
    final d = asset.defaultDurationOption;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _assetLabel(),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${d.apy.toStringAsFixed(2)}%',
                    style: NexbitText.mono(fontSize: 13.5, weight: FontWeight.w700, color: NexbitColors.up)),
                _PeriodTag(isFlexible: asset.defaultDuration == 'flexible', days: d.days),
              ],
            ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right, size: 18, color: NexbitColors.muted2),
          ],
        ),
      ],
    );
  }
}

class _PeriodTag extends StatelessWidget {
  final bool isFlexible;
  final int days;
  const _PeriodTag({required this.isFlexible, required this.days});

  @override
  Widget build(BuildContext context) {
    const amber = Color(0xFFF3BA2F);
    return Container(
      margin: const EdgeInsets.only(top: 3),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isFlexible ? Colors.transparent : amber,
        borderRadius: BorderRadius.circular(20),
        border: isFlexible ? Border.all(color: NexbitColors.accent) : null,
      ),
      child: Text(
        isFlexible ? S.stakingFlexible : S.stakingDaysBadge(days),
        style: NexbitText.body(
          fontSize: 10,
          weight: FontWeight.w700,
          color: isFlexible ? NexbitColors.accent : const Color(0xFF1A1300),
        ),
      ),
    );
  }
}

class _WhatIsStakingCard extends StatelessWidget {
  const _WhatIsStakingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [NexbitColors.accent.withOpacity(0.08), NexbitColors.accent2.withOpacity(0.06)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: NexbitColors.line),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 480;
          final text = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(S.stakingWhatIsHeading, style: NexbitText.display(fontSize: 19, weight: FontWeight.w700)),
              const SizedBox(height: 10),
              Text(S.stakingWhatIsParagraph, style: NexbitText.body(fontSize: 13.5, height: 1.65)),
              const SizedBox(height: 14),
              Hoverable(
                hoverScale: 1.03,
                builder: (context, hovered) => InkWell(
                  onTap: () {},
                  child: Text(S.stakingLearnMore,
                      style: NexbitText.body(
                          fontSize: 13, weight: FontWeight.w700, color: hovered ? NexbitColors.text : NexbitColors.accent)),
                ),
              ),
            ],
          );
          final graphic = Container(
            width: 72,
            height: 72,
            alignment: Alignment.center,
            decoration: BoxDecoration(gradient: NexbitColors.accentGradient, borderRadius: BorderRadius.circular(18)),
            child: Icon(Icons.data_object_rounded, size: 34, color: const Color(0xFF04120E).withOpacity(0.6)),
          );
          if (narrow) {
            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [graphic, const SizedBox(height: 16), text]);
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Expanded(child: text), const SizedBox(width: 20), graphic],
          );
        },
      ),
    );
  }
}
