import 'package:flutter/material.dart';
import '../../../../core/i18n/app_locale.dart';
import '../../../../core/i18n/strings.dart';
import '../../../../core/market_data/live_price_service.dart';
import '../../../../core/market_data/live_pricing.dart';
import '../../../../core/theme/nexbit_theme.dart';
import '../../../auth/presentation/pages/nexbit_login_page.dart';
import '../../../auth/presentation/pages/nexbit_register_page.dart';
import '../../../blog/presentation/pages/nexbit_blog_page.dart';
import '../../../landing/presentation/widgets/footer_section.dart';
import '../../../landing/presentation/widgets/max_width_box.dart';
import '../../../landing/presentation/widgets/network_background.dart';
import '../../../landing/presentation/widgets/nexbit_navbar.dart';
import '../../../landing/presentation/widgets/scroll_reveal.dart';
import '../../../staking/presentation/pages/nexbit_staking_landing_page.dart';
import '../../../trading/domain/models/trading_pair.dart';
import '../../../trading/presentation/pages/nexbit_trading_page.dart';
import '../../../futures/presentation/pages/nexbit_futures_page.dart';
import '../widgets/market_highlight_card.dart';
import '../widgets/price_asset_table.dart';
import 'nexbit_market_page.dart';

/// "Harga" page — a market overview: highlight cards, category tabs,
/// search, and a Beli/Jual price table for every pair, mirroring the
/// classic exchange market-price page layout.
class NexbitPricePage extends StatefulWidget {
  const NexbitPricePage({super.key});

  @override
  State<NexbitPricePage> createState() => _NexbitPricePageState();
}

class _NexbitPricePageState extends State<NexbitPricePage> {
  AssetCategory? _category; // null = Semua
  String _search = '';

  @override
  void initState() {
    super.initState();
    LivePriceService.prices.addListener(_onLiveUpdate);
  }

  @override
  void dispose() {
    LivePriceService.prices.removeListener(_onLiveUpdate);
    super.dispose();
  }

  void _onLiveUpdate() {
    if (mounted) setState(() {});
  }

  List<TradingPair> get _filtered {
    final term = _search.trim().toLowerCase();
    return liveTradingPairs().where((p) {
      final matchCat = _category == null || p.category == _category;
      final matchTerm =
          term.isEmpty || p.id.toLowerCase().contains(term) || p.name.toLowerCase().contains(term);
      return matchCat && matchTerm;
    }).toList();
  }

  double _changeValue(String change) => double.tryParse(change.replaceAll('%', '').replaceAll('+', '')) ?? 0;

  // No real 24h-volume feed behind this page — a small deterministic
  // stand-in (seeded by id) so the "Highest Volume" card has something
  // stable to show, consistent with the other mock data in this app.
  double _pseudoVolume(TradingPair p) => ((p.id.hashCode.abs() % 9000000) + 1000000).toDouble();

  void _openTrading(TradingPair pair) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => NexbitTradingPage(initialPair: pair)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final livePairs = liveTradingPairs();
    final topGainer = livePairs.reduce((a, b) => _changeValue(a.change) >= _changeValue(b.change) ? a : b);
    final highestVolume = livePairs.reduce((a, b) => _pseudoVolume(a) >= _pseudoVolume(b) ? a : b);
    final mostPopular = livePairs.firstWhere((p) => p.id == 'BTC', orElse: () => livePairs.first);

    // Listens to appLocale directly so this page rebuilds with fresh text
    // whenever the ID/EN toggle flips — independent of Navigator/route
    // mechanics, which don't automatically re-invoke a route's builder.
    return ValueListenableBuilder<AppLocale>(
      valueListenable: appLocale,
      builder: (context, locale, _) => Scaffold(
      backgroundColor: NexbitColors.bg,
      body: Stack(
        children: [
          const Positioned.fill(child: NetworkBackground()),
          Positioned(
            top: -200,
            right: -150,
            child: IgnorePointer(
              child: Container(
                width: 600,
                height: 600,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [NexbitColors.accent.withValues(alpha: .14), NexbitColors.accent.withValues(alpha: 0)],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < kNexbitMobileBreakpoint;
                return Column(
                  children: [
                    NexbitNavbar(
                      isMobile: isMobile,
                      activeId: 'harga',
                      onLogoTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
                      onMarketTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const NexbitMarketPage()),
                      ),
                      onStakingTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const NexbitStakingLandingPage()),
                      ),
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                S.priceHeading,
                                style: NexbitText.display(fontSize: isMobile ? 22 : 30, color: NexbitColors.accent, height: 1.3),
                              ),
                              const SizedBox(height: 12),
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 640),
                                child: Text(
                                  S.priceSubheading,
                                  style: NexbitText.body(fontSize: 14.5, height: 1.6),
                                ),
                              ),
                              const SizedBox(height: 28),
                              Wrap(
                                spacing: 16,
                                runSpacing: 16,
                                children: [
                                  MarketHighlightCard(
                                    title: S.priceTopGainer,
                                    pair: topGainer,
                                    valueLabel: 'IDR ${formatPrice(topGainer.base, topGainer.decimals)}',
                                  ),
                                  MarketHighlightCard(
                                    title: S.priceHighestVolume,
                                    pair: highestVolume,
                                    valueLabel: 'IDR ${formatPrice(highestVolume.base, highestVolume.decimals)}',
                                  ),
                                  MarketHighlightCard(
                                    title: S.priceMostPopular,
                                    pair: mostPopular,
                                    valueLabel: 'IDR ${formatPrice(mostPopular.base, mostPopular.decimals)}',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),
                              Container(
                                decoration: BoxDecoration(
                                  color: NexbitColors.panel,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: NexbitColors.line),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                                      child: Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: [
                                          _CategoryPill(
                                            label: S.tabAll,
                                            active: _category == null,
                                            onTap: () => setState(() => _category = null),
                                          ),
                                          _CategoryPill(
                                            label: S.tabCrypto,
                                            active: _category == AssetCategory.crypto,
                                            onTap: () => setState(() => _category = AssetCategory.crypto),
                                          ),
                                          _CategoryPill(
                                            label: S.tabForex,
                                            active: _category == AssetCategory.forex,
                                            onTap: () => setState(() => _category = AssetCategory.forex),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: TextField(
                                        onChanged: (v) => setState(() => _search = v),
                                        style: NexbitText.body(fontSize: 13, color: NexbitColors.text),
                                        decoration: InputDecoration(
                                          hintText: S.priceSearchAssetHint,
                                          hintStyle: NexbitText.body(fontSize: 13, color: NexbitColors.muted),
                                          prefixIcon: const Icon(Icons.search, size: 18, color: NexbitColors.muted),
                                          filled: true,
                                          fillColor: NexbitColors.surface2,
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                            borderSide: const BorderSide(color: NexbitColors.line),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                            borderSide: const BorderSide(color: NexbitColors.line),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                            borderSide: const BorderSide(color: NexbitColors.accent),
                                          ),
                                        ),
                                      ),
                                    ),
                                    _filtered.isEmpty
                                        ? Padding(
                                            padding: const EdgeInsets.all(24),
                                            child: Text(S.noMatchingAssets,
                                                style: NexbitText.body(fontSize: 12.5, color: NexbitColors.muted2)),
                                          )
                                        : PriceAssetTable(pairs: _filtered, onTrade: _openTrading),
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: TextButton.icon(
                                          onPressed: null,
                                          icon: Text(S.priceNextButton),
                                          label: const Icon(Icons.chevron_right, size: 16),
                                          style: TextButton.styleFrom(
                                            foregroundColor: NexbitColors.muted2,
                                            disabledForegroundColor: NexbitColors.muted2,
                                            textStyle: NexbitText.body(fontSize: 12.5, weight: FontWeight.w600),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 56),
                              ScrollReveal(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(S.priceWhatIsCryptoHeading,
                                        style: NexbitText.display(fontSize: isMobile ? 19 : 23, height: 1.3)),
                                    const SizedBox(height: 12),
                                    ConstrainedBox(
                                      constraints: const BoxConstraints(maxWidth: 760),
                                      child: Text(
                                        S.priceWhatIsCryptoParagraph,
                                        style: NexbitText.body(fontSize: 14, height: 1.75),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 56),
                              ScrollReveal(child: FooterSection(isMobile: isMobile)),
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
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _CategoryPill({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: active ? NexbitColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: NexbitText.body(
            fontSize: 13,
            weight: FontWeight.w600,
            color: active ? const Color(0xFF04120E) : NexbitColors.muted,
          ),
        ),
      ),
    );
  }
}
