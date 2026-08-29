import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/i18n/app_locale.dart';
import '../../../../core/i18n/strings.dart';
import '../../../../core/market_data/live_price_service.dart';
import '../../../../core/market_data/live_pricing.dart';
import '../../../../core/theme/nexbit_theme.dart';
import '../../../auth/presentation/pages/nexbit_login_page.dart';
import '../../../auth/presentation/pages/nexbit_register_page.dart';
import '../../../blog/presentation/pages/nexbit_blog_page.dart';
import '../../../landing/presentation/widgets/network_background.dart';
import '../../../landing/presentation/widgets/nexbit_navbar.dart';
import '../../../staking/presentation/pages/nexbit_staking_landing_page.dart';
import '../../../trading/domain/models/trading_pair.dart';
import '../../../trading/presentation/pages/nexbit_trading_page.dart';
import '../../../futures/presentation/pages/nexbit_futures_page.dart';
import '../../domain/market_mock_data.dart';
import 'nexbit_price_page.dart';
import '../widgets/market_chart_card.dart';
import '../widgets/market_fear_greed_card.dart';
import '../widgets/market_insights_card.dart';
import '../widgets/market_overview_table.dart';
import '../widgets/market_ranked_list_card.dart';
import '../widgets/market_stat_card.dart';

enum _MarketTab { all, crypto, defi, nft, gamefi, more }

/// "Market" page — the exploration dashboard reached from the navbar's
/// "Market" link: total-market stat cards, a cap/volume/ranking asset
/// table, an embedded chart, and a sidebar of trending assets, top
/// volume, and market insights. This is deliberately a different page
/// from "Harga" (a simple Beli/Jual price list) — Market is where you
/// read the state of the market, Harga is where you check a buy/sell
/// price before trading.
class NexbitMarketPage extends StatefulWidget {
  const NexbitMarketPage({super.key});

  @override
  State<NexbitMarketPage> createState() => _NexbitMarketPageState();
}

class _NexbitMarketPageState extends State<NexbitMarketPage> {
  _MarketTab _tab = _MarketTab.all;
  String _search = '';

  // Regular getters (not `static final`) so every read reflects whatever
  // LivePriceService last fetched — recomputed on each build, which the
  // _onLiveUpdate listener below triggers whenever a new price tick lands.
  List<TradingPair> get _cryptoPairs => liveTradingPairs().where((p) => p.category == AssetCategory.crypto).toList();
  List<TradingPair> get _forexPairs => liveTradingPairs().where((p) => p.category == AssetCategory.forex).toList();
  List<MarketMockStats> get _allStats => buildMarketMockStats(_cryptoPairs);
  List<MarketMockStats> get _forexStats => buildForexVolumeStats(_forexPairs);

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

  double _changeValue(String change) => double.tryParse(change.replaceAll('%', '').replaceAll('+', '')) ?? 0;

  List<MarketMockStats> get _filteredStats {
    // Only "Semua"/"Kripto" map to real data here — DeFi/NFT/GameFi/Lainnya
    // are sub-categories this app's mock asset list doesn't actually model,
    // so they honestly show an empty state instead of faking a split.
    if (_tab != _MarketTab.all && _tab != _MarketTab.crypto) return const [];
    final term = _search.trim().toLowerCase();
    if (term.isEmpty) return _allStats;
    return _allStats.where((s) => s.pair.id.toLowerCase().contains(term) || s.pair.name.toLowerCase().contains(term)).toList();
  }

  double get _totalMarketCap => _allStats.fold(0.0, (sum, s) => sum + s.marketCap);
  double get _totalVolume24h => _allStats.fold(0.0, (sum, s) => sum + s.volume24h);
  double get _btcDominance {
    final btc = _allStats.firstWhere((s) => s.pair.id == 'BTC', orElse: () => _allStats.first);
    final total = _totalMarketCap;
    return total == 0 ? 0 : (btc.marketCap / total * 100);
  }

  // Derived from the same mock 24h-change data already on this page (a
  // net-positive market nudges the index toward "Greed", net-negative
  // toward "Fear") rather than being an unrelated random number, then
  // given small stable seeded offsets for the yesterday/last-week reads.
  int get _fearGreedIndex {
    final avg = _cryptoPairs.map((p) => _changeValue(p.change)).reduce((a, b) => a + b) / _cryptoPairs.length;
    return (50 + avg * 18).clamp(0, 100).round();
  }

  int _fearGreedOffset(int seed) => (Random(seed).nextDouble() * 24 - 12).round();
  int get _fearGreedYesterday => (_fearGreedIndex + _fearGreedOffset(101)).clamp(0, 100);
  int get _fearGreedLastWeek => (_fearGreedIndex + _fearGreedOffset(102)).clamp(0, 100);

  void _openTrading(TradingPair pair) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => NexbitTradingPage(initialPair: pair)));
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLocale>(
      valueListenable: appLocale,
      builder: (context, locale, _) => Scaffold(
        backgroundColor: NexbitColors.bg,
        body: Stack(
          children: [
            const Positioned.fill(child: NetworkBackground()),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < kNexbitMobileBreakpoint;
                  final wide = constraints.maxWidth >= 1100;
                  return Column(
                    children: [
                      NexbitNavbar(
                        isMobile: isMobile,
                        activeId: 'market',
                        onLogoTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
                        onHargaTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const NexbitPricePage()),
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
                          padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 32, vertical: 24),
                          // Deliberately no MaxWidthBox here — unlike the
                          // marketing pages, this is a data dashboard, so it
                          // fills the whole viewport edge-to-edge instead of
                          // capping out and leaving empty margins on wide
                          // monitors.
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _Header(isMobile: isMobile, stats: _statCards()),
                              const SizedBox(height: 20),
                              if (wide)
                                // Plain Row, deliberately NOT wrapped in
                                // IntrinsicHeight: the embedded WebView
                                // chart inside _mainColumn() doesn't
                                // support intrinsic-size queries, which
                                // throws during layout and silently blanks
                                // the whole page in release web builds.
                                // Neither column needs to match the
                                // other's height, so no intrinsic sizing
                                // is actually needed here.
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(flex: 7, child: _mainColumn()),
                                    const SizedBox(width: 24),
                                    SizedBox(width: 320, child: _sidebar()),
                                  ],
                                )
                              else
                                Column(
                                  children: [
                                    _mainColumn(),
                                    const SizedBox(height: 24),
                                    _sidebar(),
                                  ],
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
      ),
    );
  }

  List<Widget> _statCards() {
    final topGainer = _cryptoPairs.reduce((a, b) => _changeValue(a.change) >= _changeValue(b.change) ? a : b);
    return [
      MarketStatCard(
        title: S.marketStatTotalCap,
        value: compactIdr(_totalMarketCap),
        change: topGainer.change,
        isUp: true,
        visual: MarketLineTrend(isUp: true, seed: 1),
      ),
      MarketStatCard(
        title: S.marketStatVolume24h,
        value: compactIdr(_totalVolume24h),
        change: '+12.34%',
        isUp: true,
        visual: const MarketBarTrend(isUp: true, seed: 2),
      ),
      MarketStatCard(
        title: S.marketStatBtcDominance,
        value: '${_btcDominance.toStringAsFixed(1)}%',
        change: '+0.32%',
        isUp: true,
        visual: MarketDonutRing(percent: _btcDominance),
      ),
    ];
  }

  Widget _mainColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MarketChartCard(pair: _cryptoPairs.first),
        const SizedBox(height: 24),
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
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _CategoryPill(label: S.marketTabAll, active: _tab == _MarketTab.all, onTap: () => setState(() => _tab = _MarketTab.all)),
                    _CategoryPill(label: S.marketTabCrypto, active: _tab == _MarketTab.crypto, onTap: () => setState(() => _tab = _MarketTab.crypto)),
                    _CategoryPill(label: S.marketTabDefi, active: _tab == _MarketTab.defi, onTap: () => setState(() => _tab = _MarketTab.defi)),
                    _CategoryPill(label: S.marketTabNft, active: _tab == _MarketTab.nft, onTap: () => setState(() => _tab = _MarketTab.nft)),
                    _CategoryPill(label: S.marketTabGamefi, active: _tab == _MarketTab.gamefi, onTap: () => setState(() => _tab = _MarketTab.gamefi)),
                    _CategoryPill(label: S.marketTabMore, active: _tab == _MarketTab.more, onTap: () => setState(() => _tab = _MarketTab.more)),
                  ],
                ),
              ),
              _filteredStats.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(S.noMatchingAssets, style: NexbitText.body(fontSize: 12.5, color: NexbitColors.muted2)),
                    )
                  : MarketOverviewTable(rows: _filteredStats, onTrade: _openTrading),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sidebar() {
    final gainers = [..._cryptoPairs]..sort((a, b) => _changeValue(b.change).compareTo(_changeValue(a.change)));
    final losers = [..._cryptoPairs]..sort((a, b) => _changeValue(a.change).compareTo(_changeValue(b.change)));
    final byVolume = [..._allStats]..sort((a, b) => b.volume24h.compareTo(a.volume24h));
    final byVolumeFiat = [..._forexStats]..sort((a, b) => b.volume24h.compareTo(a.volume24h));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: NexbitColors.surface2,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: NexbitColors.line),
          ),
          child: TextField(
            onChanged: (v) => setState(() => _search = v),
            style: NexbitText.body(fontSize: 13, color: NexbitColors.text),
            decoration: InputDecoration(
              hintText: S.marketSearchHint,
              hintStyle: NexbitText.body(fontSize: 13, color: NexbitColors.muted),
              prefixIcon: const Icon(Icons.search, size: 18, color: NexbitColors.muted),
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 16),
        MarketRankedListCard(
          title: S.marketTrendingHeading,
          icon: Icons.local_fire_department_outlined,
          tabs: [S.marketTabGainers, S.marketTabLosers],
          itemsForTab: (tab) {
            final list = tab == 0 ? gainers.take(5) : losers.take(5);
            return list
                .map((p) => MarketRankedItem(
                      primary: p.id,
                      secondary: p.name,
                      trailing: p.change,
                      trailingColor: p.isUp ? NexbitColors.up : NexbitColors.down,
                    ))
                .toList();
          },
        ),
        const SizedBox(height: 16),
        MarketRankedListCard(
          title: S.marketTopVolumeHeading,
          icon: Icons.bar_chart_rounded,
          tabs: [S.marketTabVolCrypto, S.marketTabVolFiat],
          itemsForTab: (tab) {
            final list = tab == 0 ? byVolume.take(5) : byVolumeFiat.take(5);
            return list
                .map((s) => MarketRankedItem(
                      primary: '${s.pair.id}/${tab == 0 ? 'USDT' : s.pair.quote}',
                      trailing: compactIdr(s.volume24h),
                      trailingColor: NexbitColors.text,
                    ))
                .toList();
          },
        ),
        const SizedBox(height: 16),
        MarketInsightsCard(
          title: S.marketInsightsHeading,
          icon: Icons.lightbulb_outline,
          tabs: [S.marketTabNews, S.marketTabAnalysis, S.marketTabResearch],
          itemsForTab: (tab) {
            switch (tab) {
              case 1:
                return [
                  MarketInsightItem(icon: Icons.candlestick_chart, iconColor: NexbitColors.accent, title: S.marketAnalysis1, timeLabel: S.marketHoursAgo(1)),
                  MarketInsightItem(icon: Icons.trending_up, iconColor: NexbitColors.up, title: S.marketAnalysis2, timeLabel: S.marketHoursAgo(5)),
                  MarketInsightItem(icon: Icons.pie_chart_outline, iconColor: NexbitColors.accent2, title: S.marketAnalysis3, timeLabel: S.marketHoursAgo(9)),
                ];
              case 2:
                return [
                  MarketInsightItem(icon: Icons.description_outlined, iconColor: NexbitColors.accent2, title: S.marketResearch1, timeLabel: S.marketHoursAgo(3)),
                  MarketInsightItem(icon: Icons.query_stats, iconColor: NexbitColors.up, title: S.marketResearch2, timeLabel: S.marketHoursAgo(7)),
                  MarketInsightItem(icon: Icons.insights, iconColor: NexbitColors.accent, title: S.marketResearch3, timeLabel: S.marketHoursAgo(12)),
                ];
              default:
                return [
                  MarketInsightItem(icon: Icons.currency_bitcoin, iconColor: const Color(0xFFF7931A), title: S.marketNews1, timeLabel: S.marketHoursAgo(2)),
                  MarketInsightItem(icon: Icons.hub_outlined, iconColor: const Color(0xFF627EEA), title: S.marketNews2, timeLabel: S.marketHoursAgo(4)),
                  MarketInsightItem(icon: Icons.public, iconColor: NexbitColors.accent, title: S.marketNews3, timeLabel: S.marketHoursAgo(6)),
                ];
            }
          },
        ),
        const SizedBox(height: 16),
        MarketFearGreedCard(
          value: _fearGreedIndex,
          yesterday: _fearGreedYesterday,
          lastWeek: _fearGreedLastWeek,
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final bool isMobile;
  final List<Widget> stats;
  const _Header({required this.isMobile, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 24,
      runSpacing: 20,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              RichText(
                text: TextSpan(
                  style: NexbitText.display(fontSize: isMobile ? 24 : 30, weight: FontWeight.w700),
                  children: [
                    TextSpan(text: S.marketHeadingAccent, style: const TextStyle(color: NexbitColors.accent)),
                    TextSpan(text: S.marketHeadingRest),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(S.marketSubheading, style: NexbitText.body(fontSize: 13.5, height: 1.6)),
            ],
          ),
        ),
        Wrap(spacing: 14, runSpacing: 14, children: stats),
      ],
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: active ? NexbitColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: NexbitText.body(
            fontSize: 12.5,
            weight: FontWeight.w600,
            color: active ? const Color(0xFF04120E) : NexbitColors.muted,
          ),
        ),
      ),
    );
  }
}
