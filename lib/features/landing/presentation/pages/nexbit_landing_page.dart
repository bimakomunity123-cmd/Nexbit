import 'package:flutter/material.dart';
import '../../../../core/i18n/app_locale.dart';
import '../../../../core/i18n/strings.dart';
import '../../../../core/theme/nexbit_theme.dart';
import '../../../auth/presentation/pages/nexbit_login_page.dart';
import '../../../auth/presentation/pages/nexbit_register_page.dart';
import '../../../blog/presentation/pages/nexbit_blog_page.dart';
import '../../../futures/presentation/pages/nexbit_futures_page.dart';
import '../../../market/presentation/pages/nexbit_market_page.dart';
import '../../../market/presentation/pages/nexbit_price_page.dart';
import '../../../staking/presentation/pages/nexbit_staking_landing_page.dart';
import '../../../trading/presentation/pages/nexbit_trading_page.dart';
import '../widgets/app_download_section.dart';
import '../widgets/asset_showcase_section.dart';
import '../widgets/footer_section.dart';
import '../widgets/max_width_box.dart';
import '../widgets/network_background.dart';
import '../widgets/nexbit_buttons.dart';
import '../widgets/nexbit_navbar.dart';
import '../widgets/payment_support_section.dart';
import '../widgets/press_section.dart';
import '../widgets/price_ticker_card.dart';
import '../widgets/scroll_reveal.dart';
import '../widgets/trust_section.dart';

class NexbitLandingPage extends StatelessWidget {
  const NexbitLandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    void openTrading() {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const NexbitTradingPage()),
      );
    }

    void openHarga() {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const NexbitPricePage()),
      );
    }

    void openMarket() {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const NexbitMarketPage()),
      );
    }

    void openFutures() {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const NexbitFuturesPage()),
      );
    }

    void openLogin() {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const NexbitLoginPage()),
      );
    }

    void openRegister() {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const NexbitRegisterPage()),
      );
    }

    void openStaking() {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const NexbitStakingLandingPage()),
      );
    }

    void openBlog() {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const NexbitBlogPage()),
      );
    }

    // Listens to appLocale directly so this page rebuilds with fresh text
    // whenever the ID/EN toggle flips — independent of Navigator/route
    // mechanics, which don't automatically re-invoke a route's builder.
    return ValueListenableBuilder<AppLocale>(
      valueListenable: appLocale,
      builder: (context, locale, _) => Scaffold(
      backgroundColor: NexbitColors.bg,
      body: Stack(
        children: [
          // Animated constellation background, sits behind everything.
          const Positioned.fill(child: NetworkBackground()),

          // Soft glow blobs (same spirit as the CSS radial-gradient glows).
          Positioned(
            top: -200,
            right: -150,
            child: _Glow(color: NexbitColors.accent.withOpacity(.16), size: 600),
          ),
          Positioned(
            bottom: -250,
            left: -200,
            child: _Glow(color: NexbitColors.accent2.withOpacity(.13), size: 700),
          ),

          // Foreground content.
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < kNexbitMobileBreakpoint;
                return Column(
                  children: [
                    NexbitNavbar(
                      isMobile: isMobile,
                      onLogoTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
                      onHargaTap: openHarga,
                      onMarketTap: openMarket,
                      onFuturesTap: openFutures,
                      onStakingTap: openStaking,
                      onBlogTap: openBlog,
                      onLoginTap: openLogin,
                      onRegisterTap: openRegister,
                    ),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, remaining) {
                          return SingleChildScrollView(
                            child: Column(
                              children: [
                                // Hero fills the rest of the first screen and is
                                // centered vertically within it, instead of
                                // hugging the navbar — the sections below just
                                // follow in normal scroll flow underneath it.
                                ConstrainedBox(
                                  constraints: BoxConstraints(minHeight: remaining.maxHeight),
                                  child: Center(
                                    child: _Hero(isMobile: isMobile, onMarketTap: openTrading, onHargaTap: openHarga),
                                  ),
                                ),
                                ScrollReveal(child: AssetShowcaseSection(isMobile: isMobile)),
                                ScrollReveal(child: PressSection(isMobile: isMobile)),
                                ScrollReveal(child: PaymentSupportSection(isMobile: isMobile)),
                                ScrollReveal(child: TrustSection(isMobile: isMobile)),
                                ScrollReveal(child: AppDownloadSection(isMobile: isMobile)),
                                ScrollReveal(child: FooterSection(isMobile: isMobile)),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  final Color color;
  final double size;
  const _Glow({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withOpacity(0)]),
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  final bool isMobile;
  final VoidCallback onMarketTap;
  final VoidCallback onHargaTap;
  const _Hero({required this.isMobile, required this.onMarketTap, required this.onHargaTap});

  @override
  Widget build(BuildContext context) {
    final textColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        RichText(
          text: TextSpan(
            style: NexbitText.display(fontSize: isMobile ? 38 : 56, height: 1.08),
            children: [
              TextSpan(text: '${S.heroTitleLine1}\n'),
              TextSpan(
                text: S.heroTitleLine2,
                style: TextStyle(
                  foreground: Paint()
                    ..shader = NexbitColors.accentGradient.createShader(
                      const Rect.fromLTWH(0, 0, 300, 70),
                    ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Text(
            S.heroSubtitle,
            style: NexbitText.body(fontSize: 16.5, height: 1.65),
          ),
        ),
        const SizedBox(height: 34),
        Wrap(
          spacing: 14,
          runSpacing: 12,
          children: [
            PrimaryButton(label: S.heroCtaPrimary, onTap: onMarketTap),
            OutlineButton(label: S.heroCtaSecondary, onTap: onMarketTap),
          ],
        ),
        const SizedBox(height: 46),
        Wrap(
          spacing: 28,
          runSpacing: 16,
          children: [
            _TrustStat(value: '2.4jt+', label: S.heroStatUsersLabel),
            _TrustStat(value: '150+', label: S.heroStatAssetsLabel),
            _TrustStat(value: '99.98%', label: S.heroStatUptimeLabel),
          ],
        ),
      ],
    );

    final priceCard = PriceTickerCard(onViewAll: onHargaTap);

    return Padding(
      padding: EdgeInsets.fromLTRB(isMobile ? 22 : 56, 30, isMobile ? 22 : 56, 60),
      child: MaxWidthBox(
        child: isMobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  textColumn,
                  const SizedBox(height: 40),
                  Center(child: priceCard),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(flex: 115, child: textColumn),
                  const SizedBox(width: 40),
                  Expanded(flex: 85, child: Align(alignment: Alignment.centerRight, child: priceCard)),
                ],
              ),
      ),
    );
  }
}

class _TrustStat extends StatelessWidget {
  final String value;
  final String label;
  const _TrustStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: NexbitText.mono(fontSize: 15, weight: FontWeight.w700, color: NexbitColors.text)),
        const SizedBox(height: 2),
        Text(label, style: NexbitText.body(fontSize: 13, color: NexbitColors.muted)),
      ],
    );
  }
}
