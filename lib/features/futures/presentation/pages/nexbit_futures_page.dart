import 'package:flutter/material.dart';
import '../../../../core/i18n/app_locale.dart';
import '../../../../core/i18n/strings.dart';
import '../../../../core/theme/nexbit_theme.dart';
import '../../../auth/presentation/pages/nexbit_login_page.dart';
import '../../../auth/presentation/pages/nexbit_register_page.dart';
import '../../../blog/presentation/pages/nexbit_blog_page.dart';
import '../../../landing/presentation/widgets/network_background.dart';
import '../../../landing/presentation/widgets/nexbit_navbar.dart';
import '../../../market/presentation/pages/nexbit_market_page.dart';
import '../../../market/presentation/pages/nexbit_price_page.dart';
import '../../../staking/presentation/pages/nexbit_staking_landing_page.dart';
import '../../../trading/presentation/widgets/tradingview_chart.dart';
import '../../domain/models/futures_contract.dart';
import '../../domain/models/futures_position.dart';
import '../widgets/futures_account_info_card.dart';
import '../widgets/futures_contract_details_card.dart';
import '../widgets/futures_feature_row.dart';
import '../widgets/futures_order_book_panel.dart';
import '../widgets/futures_order_form_panel.dart';
import '../widgets/futures_pair_strip.dart';
import '../widgets/futures_positions_panel.dart';
import '../widgets/futures_recent_trades_panel.dart';

/// "Futures" page — the perpetual-contracts/CFD trading dashboard reached
/// from the navbar's "Futures" link (and, once logged in, the page a
/// successful login lands on): quick market stats, Crypto/Forex/Saham
/// contract lists, order book + recent trades, an embedded chart with a
/// real Positions/Open Orders/History tab strip, and a fully working
/// Long/Short order form wired to a live Account Info card.
class NexbitFuturesPage extends StatefulWidget {
  const NexbitFuturesPage({super.key});

  @override
  State<NexbitFuturesPage> createState() => _NexbitFuturesPageState();
}

class _NexbitFuturesPageState extends State<NexbitFuturesPage> {
  FuturesAssetClass _assetClass = FuturesAssetClass.crypto;
  String _search = '';
  FuturesContract _selected = kFuturesCryptoContracts.first;
  late List<FuturesPosition> _positions = seedFuturesPositions();
  double _realizedPnl = 0;

  // Kept in sync with FuturesAccountInfoCard's own calc (same starting
  // balance, same formula) so the order form's %-of-buying-power buttons
  // are sized against the same number the Account Info card shows.
  static const _startingBalance = 1250.0;

  double _markPriceOf(String contractId) =>
      kAllFuturesContracts.firstWhere((c) => c.id == contractId, orElse: () => _selected).price;

  double get _availableBalance {
    final usedMargin = _positions.fold(0.0, (sum, p) => sum + p.margin);
    final unrealizedPnl = _positions.fold(0.0, (sum, p) => sum + p.pnl(_markPriceOf(p.contract.id)));
    final marginBalance = _startingBalance + _realizedPnl + unrealizedPnl;
    return marginBalance - usedMargin;
  }

  void _closePosition(FuturesPosition p) {
    setState(() {
      _realizedPnl += p.pnl(_markPriceOf(p.contract.id));
      _positions = _positions.where((e) => e != p).toList();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(S.futuresPositionClosedSnack), duration: const Duration(seconds: 2)),
    );
  }

  void _openPosition(FuturesPosition p) {
    setState(() => _positions = [..._positions, p]);
  }

  void _selectAssetClass(FuturesAssetClass assetClass) {
    setState(() {
      _assetClass = assetClass;
      _selected = contractsFor(assetClass).first;
    });
  }

  List<FuturesContract> get _filteredContracts {
    final all = contractsFor(_assetClass);
    final term = _search.trim().toLowerCase();
    if (term.isEmpty) return all;
    return all.where((c) => c.id.toLowerCase().contains(term) || c.name.toLowerCase().contains(term)).toList();
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
                  final wide = constraints.maxWidth >= 1180;
                  return Column(
                    children: [
                      NexbitNavbar(
                        isMobile: isMobile,
                        activeId: 'futures',
                        onLogoTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
                        onHargaTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const NexbitPricePage()),
                        ),
                        onMarketTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const NexbitMarketPage()),
                        ),
                        onStakingTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const NexbitStakingLandingPage()),
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _Header(isMobile: isMobile),
                              const SizedBox(height: 20),
                              _categoryAndSearch(),
                              const SizedBox(height: 16),
                              if (_filteredContracts.isEmpty)
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: NexbitColors.panel,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: NexbitColors.line),
                                  ),
                                  child: Text(S.noMatchingAssets,
                                      style: NexbitText.body(fontSize: 12.5, color: NexbitColors.muted2)),
                                )
                              else
                                FuturesPairStrip(
                                  contracts: _filteredContracts,
                                  selected: _selected,
                                  onSelect: (c) => setState(() => _selected = c),
                                ),
                              const SizedBox(height: 20),
                              // Plain Row (not IntrinsicHeight) — none of
                              // these three columns need to match heights,
                              // and the embedded WebView chart doesn't
                              // support intrinsic-size queries anyway.
                              if (wide)
                                // Chart first and widest, order book/trades
                                // as a narrower middle column, order form
                                // on the right — the layout every real
                                // perpetuals exchange (Bybit, Binance, OKX)
                                // uses; the chart is the thing you actually
                                // watch, so it gets the most room, not the
                                // order book.
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(child: _chartColumn()),
                                    const SizedBox(width: 16),
                                    SizedBox(width: 280, child: _orderBookColumn()),
                                    const SizedBox(width: 16),
                                    SizedBox(width: 320, child: _orderFormColumn()),
                                  ],
                                )
                              else
                                Column(
                                  children: [
                                    _chartColumn(),
                                    const SizedBox(height: 16),
                                    _orderFormColumn(),
                                    const SizedBox(height: 16),
                                    _orderBookColumn(),
                                  ],
                                ),
                              const SizedBox(height: 24),
                              const FuturesFeatureRow(),
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

  Widget _categoryAndSearch() {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 16,
      runSpacing: 12,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ModeTab(S.futuresAssetCrypto, active: _assetClass == FuturesAssetClass.crypto, onTap: () => _selectAssetClass(FuturesAssetClass.crypto)),
            const SizedBox(width: 20),
            _ModeTab(S.futuresAssetForex, active: _assetClass == FuturesAssetClass.forex, onTap: () => _selectAssetClass(FuturesAssetClass.forex)),
            const SizedBox(width: 20),
            _ModeTab(S.futuresAssetSaham, active: _assetClass == FuturesAssetClass.saham, onTap: () => _selectAssetClass(FuturesAssetClass.saham)),
          ],
        ),
        SizedBox(
          width: 260,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: NexbitColors.surface2,
              border: Border.all(color: NexbitColors.line),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              style: NexbitText.body(fontSize: 12.5, color: NexbitColors.text),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                hintText: S.futuresSearchHint,
                hintStyle: NexbitText.body(fontSize: 12.5, color: NexbitColors.muted),
                prefixIcon: const Icon(Icons.search, size: 17, color: NexbitColors.muted),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _orderBookColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: NexbitColors.line),
          ),
          clipBehavior: Clip.antiAlias,
          child: FuturesOrderBookPanel(contract: _selected),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: NexbitColors.line),
          ),
          clipBehavior: Clip.antiAlias,
          child: FuturesRecentTradesPanel(contract: _selected),
        ),
      ],
    );
  }

  Widget _chartColumn() {
    final mark = _selected.price;
    final high = mark * 1.0067;
    final low = mark * 0.9861;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 20,
                  runSpacing: 8,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: _selected.iconColor, shape: BoxShape.circle),
                          child: Text(_selected.iconLabel,
                              style: NexbitText.mono(fontSize: 11, weight: FontWeight.w700, color: const Color(0xFF04120E))),
                        ),
                        const SizedBox(width: 8),
                        Text('${_selected.label} ${S.futuresPerpetual}',
                            style: NexbitText.body(fontSize: 15, weight: FontWeight.w700)),
                        const SizedBox(width: 12),
                        Text(formatUsdt(mark, _selected.decimals),
                            style: NexbitText.mono(
                                fontSize: 16,
                                weight: FontWeight.w700,
                                color: _selected.isUp ? NexbitColors.up : NexbitColors.down)),
                        const SizedBox(width: 8),
                        Text(_selected.change,
                            style: NexbitText.mono(
                                fontSize: 13,
                                weight: FontWeight.w600,
                                color: _selected.isUp ? NexbitColors.up : NexbitColors.down)),
                      ],
                    ),
                    _stat(S.futuresMarkPrice, formatUsdt(mark, _selected.decimals)),
                    _stat(S.futures24hHigh, formatUsdt(high, _selected.decimals)),
                    _stat(S.futures24hLow, formatUsdt(low, _selected.decimals)),
                    _stat(S.futures24hVolume, '\$2.4B'),
                    _stat(S.futuresStatFundingRate, '0.01%'),
                  ],
                ),
              ),
              const Divider(height: 1, color: NexbitColors.line),
              SizedBox(
                height: 460,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
                  child: TradingViewChart(symbol: _selected.tvSymbol, interval: '60'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        FuturesPositionsPanel(positions: _positions, markPriceOf: _markPriceOf, onClose: _closePosition),
      ],
    );
  }

  Widget _orderFormColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: NexbitColors.line),
          ),
          clipBehavior: Clip.antiAlias,
          child: FuturesOrderFormPanel(
            contract: _selected,
            availableBalance: _availableBalance,
            onOpenPosition: _openPosition,
          ),
        ),
        const SizedBox(height: 16),
        FuturesAccountInfoCard(
          positions: _positions,
          markPriceOf: _markPriceOf,
          startingBalance: _startingBalance,
          realizedPnl: _realizedPnl,
        ),
        const SizedBox(height: 16),
        FuturesContractDetailsCard(contract: _selected),
      ],
    );
  }

  Widget _stat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: NexbitText.body(fontSize: 10.5, color: NexbitColors.muted2)),
        const SizedBox(height: 2),
        Text(value, style: NexbitText.mono(fontSize: 12.5, weight: FontWeight.w600)),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final bool isMobile;
  const _Header({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final titleBlock = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 460),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          RichText(
            text: TextSpan(
              style: NexbitText.display(fontSize: isMobile ? 24 : 30, weight: FontWeight.w700),
              children: [
                TextSpan(text: S.futuresHeading.substring(0, 1), style: const TextStyle(color: NexbitColors.accent)),
                TextSpan(text: S.futuresHeading.substring(1)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(S.futuresSubtitle1, style: NexbitText.body(fontSize: 13.5, height: 1.5)),
          Text(S.futuresSubtitle2, style: NexbitText.body(fontSize: 13.5, height: 1.5)),
        ],
      ),
    );
    final statCards = [
      _StatCard(title: S.futuresStatVolume24h, value: '\$12.4B', change: '+8.32%'),
      _StatCard(title: S.futuresStatOpenInterest, value: '\$5.6B', change: '+4.21%'),
      _StatCard(title: S.futuresStatFundingRate, value: '0.01%', footer: S.futuresNextFunding('01:00:00')),
    ];

    if (isMobile) {
      return Wrap(
        spacing: 24,
        runSpacing: 20,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [titleBlock, Wrap(spacing: 14, runSpacing: 14, children: statCards)],
      );
    }

    // On wide screens, anchor the stat cards to the right edge (instead of
    // letting a Wrap leave them stranded right next to the title) so the
    // header actually uses the same full width as the trading row below
    // it, rather than looking like it's floating in a mostly-empty strip.
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        titleBlock,
        const Spacer(),
        for (var i = 0; i < statCards.length; i++) ...[
          if (i > 0) const SizedBox(width: 14),
          statCards[i],
        ],
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? change;
  final String? footer;
  const _StatCard({required this.title, required this.value, this.change, this.footer});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 190,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NexbitColors.panel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: NexbitColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: NexbitText.body(fontSize: 12, color: NexbitColors.muted)),
          const SizedBox(height: 6),
          Text(value, style: NexbitText.display(fontSize: 19, weight: FontWeight.w700)),
          const SizedBox(height: 4),
          if (change != null)
            Text(change!, style: NexbitText.mono(fontSize: 11.5, weight: FontWeight.w600, color: NexbitColors.up))
          else if (footer != null)
            Text(footer!, style: NexbitText.body(fontSize: 11, color: NexbitColors.muted2)),
        ],
      ),
    );
  }
}

class _ModeTab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _ModeTab(this.label, {required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          border: active ? const Border(bottom: BorderSide(color: NexbitColors.accent, width: 2)) : null,
        ),
        child: Text(
          label,
          style: NexbitText.body(
            fontSize: 13.5,
            weight: active ? FontWeight.w700 : FontWeight.w500,
            color: active ? NexbitColors.accent : NexbitColors.muted,
          ),
        ),
      ),
    );
  }
}
