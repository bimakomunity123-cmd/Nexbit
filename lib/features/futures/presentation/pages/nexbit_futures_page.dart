import 'package:flutter/material.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/auth/session.dart';
import '../../../../core/i18n/app_locale.dart';
import '../../../../core/i18n/strings.dart';
import '../../../../core/market_data/live_price_service.dart';
import '../../../../core/market_data/live_pricing.dart';
import '../../../../core/theme/nexbit_theme.dart';
import '../../../../core/widgets/amount_input_dialog.dart';
import '../../../../core/widgets/exchange_dialog.dart';
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
import '../../domain/models/futures_order.dart';
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

  // Guests see a seeded demo position (local-only, never touches the
  // backend); a logged-in user's real positions/balance are fetched from
  // the backend in initState instead — see _loadAccountData.
  late List<FuturesPosition> _positions = isLoggedIn.value ? [] : _seedGuestPosition();
  // Trade History tab data — stays empty for a guest, same as every
  // other backend-only list this page has.
  List<ClosedFuturesPosition> _closedPositions = [];
  // Open Orders/Order History tab data — a small seeded list for guests
  // (never touches the backend, same purpose as _seedGuestPosition), the
  // real backend list for a logged-in user (see _loadAccountData).
  late List<FuturesOrder> _futuresOrders = isLoggedIn.value ? [] : _seedGuestOrders();
  double _realizedPnl = 0;
  double _balance = 1250.0;
  // True only while a logged-in user's real balance/positions are still
  // in flight — see FuturesAccountInfoCard's own doc for why this
  // exists (avoids flashing the startingBalance default before the
  // real figures arrive).
  late bool _loadingAccount = isLoggedIn.value;

  // Entry price is a small offset below whatever BTC's current price
  // is (live if LivePriceService has already fetched, the static mock
  // otherwise) so the demo position shows a modest unrealized profit
  // regardless of how far real BTC has since moved from the old fixed
  // 111200 this used to hardcode — that number only made sense back
  // when this page had no live price feed at all.
  List<FuturesPosition> _seedGuestPosition() {
    final btc = withLiveContractPrice(kFuturesCryptoContracts.first);
    return [
      FuturesPosition(contract: btc, side: OrderSide.long, size: 0.05, entryPrice: btc.price * 0.996, leverage: 10),
    ];
  }

  /// One open limit order, one filled market order, one cancelled stop —
  /// enough to show every status the Open Orders/Order History tabs can
  /// render, without needing the backend.
  List<FuturesOrder> _seedGuestOrders() {
    final btc = withLiveContractPrice(kFuturesCryptoContracts.first);
    final now = DateTime.now();
    return [
      FuturesOrder(
        id: 'guest-open',
        contract: btc,
        side: OrderSide.long,
        orderType: FuturesOrderType.limit,
        price: btc.price * 0.98,
        size: 0.02,
        leverage: 10,
        marginMode: MarginMode.isolated,
        status: FuturesOrderStatus.open,
        createdAt: now.subtract(const Duration(minutes: 12)),
      ),
      FuturesOrder(
        id: 'guest-filled',
        contract: btc,
        side: OrderSide.long,
        orderType: FuturesOrderType.market,
        price: btc.price * 0.996,
        size: 0.05,
        leverage: 10,
        marginMode: MarginMode.isolated,
        status: FuturesOrderStatus.filled,
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
      FuturesOrder(
        id: 'guest-cancelled',
        contract: btc,
        side: OrderSide.short,
        orderType: FuturesOrderType.stopMarket,
        price: btc.price * 1.03,
        size: 0.03,
        leverage: 5,
        marginMode: MarginMode.cross,
        status: FuturesOrderStatus.cancelled,
        createdAt: now.subtract(const Duration(hours: 8)),
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    LivePriceService.prices.addListener(_onLiveUpdate);
    if (isLoggedIn.value) _loadAccountData();
  }

  @override
  void dispose() {
    LivePriceService.prices.removeListener(_onLiveUpdate);
    super.dispose();
  }

  // Loads the logged-in user's real balance/positions from the backend.
  // Left as the guest-mode empty state on any failure (offline, backend
  // down) rather than showing an error — the page still works fine for
  // browsing/pricing even without this succeeding.
  Future<void> _loadAccountData() async {
    try {
      final token = authToken.value;
      final results = await Future.wait([
        ApiClient.getAccount(token),
        ApiClient.getPositions(token),
        ApiClient.getPositionHistory(token),
        ApiClient.getFuturesOrders(token),
      ]);
      final account = results[0] as Map<String, dynamic>;
      final positionsJson = results[1] as List<dynamic>;
      final historyJson = results[2] as List<dynamic>;
      final ordersJson = results[3] as List<dynamic>;
      if (!mounted) return;
      setState(() {
        _balance = (account['balance'] as num).toDouble();
        _realizedPnl = (account['realized_pnl'] as num).toDouble();
        _positions = positionsJson.map((j) => _positionFromJson(j as Map<String, dynamic>)).toList();
        _closedPositions = historyJson.map((j) => _closedPositionFromJson(j as Map<String, dynamic>)).toList();
        _futuresOrders = ordersJson.map((j) => _futuresOrderFromJson(j as Map<String, dynamic>)).toList();
        _loadingAccount = false;
      });
    } catch (_) {
      // Stays on the empty-but-logged-in state set in the field
      // initializer above — no seeded fake position is shown to a real
      // account even if the fetch fails. Still clears the loading flag
      // so the card doesn't spin forever on a failed fetch.
      if (mounted) setState(() => _loadingAccount = false);
    }
  }

  FuturesPosition _positionFromJson(Map<String, dynamic> json) {
    final contract = kAllFuturesContracts.firstWhere(
      (c) => c.id == json['contract_id'],
      orElse: () => kFuturesCryptoContracts.first,
    );
    return FuturesPosition(
      id: json['id'] as String,
      contract: contract,
      side: json['side'] == 'short' ? OrderSide.short : OrderSide.long,
      size: (json['size'] as num).toDouble(),
      entryPrice: (json['entry_price'] as num).toDouble(),
      leverage: (json['leverage'] as num).toInt(),
      marginMode: json['margin_mode'] == 'cross' ? MarginMode.cross : MarginMode.isolated,
    );
  }

  FuturesOrder _futuresOrderFromJson(Map<String, dynamic> json) {
    final contract = kAllFuturesContracts.firstWhere(
      (c) => c.id == json['contract_id'],
      orElse: () => kFuturesCryptoContracts.first,
    );
    return FuturesOrder.fromJson(json, contract);
  }

  ClosedFuturesPosition _closedPositionFromJson(Map<String, dynamic> json) {
    final contract = kAllFuturesContracts.firstWhere(
      (c) => c.id == json['contract_id'],
      orElse: () => kFuturesCryptoContracts.first,
    );
    return ClosedFuturesPosition(
      id: json['id'] as String,
      contract: contract,
      side: json['side'] == 'short' ? OrderSide.short : OrderSide.long,
      size: (json['size'] as num).toDouble(),
      entryPrice: (json['entry_price'] as num).toDouble(),
      exitPrice: (json['exit_price'] as num).toDouble(),
      realizedPnl: (json['realized_pnl'] as num).toDouble(),
      closedAt: DateTime.parse(json['closed_at'] as String),
    );
  }

  // Just triggers a rebuild — build() itself re-derives the live-priced
  // contract fresh every time (see `live` in build()), so a plain
  // setState is enough; no need to mutate _selected here.
  void _onLiveUpdate() {
    if (mounted) setState(() {});
  }

  double _markPriceOf(String contractId) => withLiveContractPrice(
        kAllFuturesContracts.firstWhere((c) => c.id == contractId, orElse: () => _selected),
      ).price;

  double get _availableBalance {
    final usedMargin = _positions.fold(0.0, (sum, p) => sum + p.margin);
    final unrealizedPnl = _positions.fold(0.0, (sum, p) => sum + p.pnl(_markPriceOf(p.contract.id)));
    final marginBalance = _balance + _realizedPnl + unrealizedPnl;
    return marginBalance - usedMargin;
  }

  Future<void> _closePosition(FuturesPosition p) async {
    final exitPrice = _markPriceOf(p.contract.id);
    final pnl = p.pnl(exitPrice);

    // Only a backend-persisted position (id != null) needs a server
    // round-trip — the guest-mode seeded position closes purely locally,
    // same as before this page had a backend at all.
    if (p.id != null) {
      try {
        final account = await ApiClient.closePosition(authToken.value, p.id!, pnl, exitPrice);
        if (!mounted) return;
        setState(() {
          _realizedPnl = (account['realized_pnl'] as num).toDouble();
          _positions = _positions.where((e) => e != p).toList();
          // Prepended locally so Trade History reflects the close
          // immediately, without waiting on a full page reload.
          _closedPositions = [
            ClosedFuturesPosition(
              id: p.id!,
              contract: p.contract,
              side: p.side,
              size: p.size,
              entryPrice: p.entryPrice,
              exitPrice: exitPrice,
              realizedPnl: pnl,
              closedAt: DateTime.now(),
            ),
            ..._closedPositions,
          ];
        });
      } on ApiException catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message), duration: const Duration(seconds: 3)));
        return;
      }
    } else {
      setState(() {
        _realizedPnl += pnl;
        _positions = _positions.where((e) => e != p).toList();
      });
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(S.futuresPositionClosedSnack), duration: const Duration(seconds: 2)),
    );
  }

  // FuturesOrderFormPanel only ever calls this once the user is actually
  // logged in (it gates submission on isLoggedIn itself), so this can
  // unconditionally hit the backend rather than branching on guest mode.
  // Returns whether it actually succeeded — FuturesOrderFormPanel uses
  // that to decide whether to clear its amount field, not to re-derive
  // its own success/error messaging (this is the only place that shows
  // either). A 'market' order fills immediately (the response carries a
  // 'position' too, so it's appended to _positions alongside the order);
  // the other order types are just recorded as open — see
  // backend/app/routers/trading.py's create_order() docstring.
  Future<bool> _submitOrder(FuturesOrderSubmission s) async {
    try {
      final json = await ApiClient.createFuturesOrder(authToken.value, {
        'contract_id': s.contract.id,
        'side': s.side == OrderSide.short ? 'short' : 'long',
        'order_type': futuresOrderTypeToJson(s.orderType),
        'price': s.price,
        'size': s.size,
        'leverage': s.leverage,
        'margin_mode': s.marginMode == MarginMode.cross ? 'cross' : 'isolated',
      });
      if (!mounted) return true;
      final newOrder = _futuresOrderFromJson(json['order'] as Map<String, dynamic>);
      final filled = json.containsKey('position');
      setState(() {
        _futuresOrders = [newOrder, ..._futuresOrders];
        if (filled) {
          _positions = [..._positions, _positionFromJson(json['position'] as Map<String, dynamic>)];
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(filled ? S.futuresOrderPlacedSnack : S.futuresOrderQueuedSnack),
          duration: const Duration(seconds: 2),
        ),
      );
      return true;
    } on ApiException catch (e) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message), duration: const Duration(seconds: 3)));
      return false;
    }
  }

  Future<void> _cancelOrder(FuturesOrder order) async {
    try {
      final json = await ApiClient.cancelFuturesOrder(authToken.value, order.id);
      if (!mounted) return;
      final updated = _futuresOrderFromJson(json);
      setState(() {
        _futuresOrders = _futuresOrders.map((o) => o.id == order.id ? updated : o).toList();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.orderCancelledSnack), duration: const Duration(seconds: 2)),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message), duration: const Duration(seconds: 3)));
    }
  }

  void _openDepositDialog() {
    if (!isLoggedIn.value) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.depositLoginRequiredSnack),
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: S.navLogin,
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NexbitLoginPage())),
          ),
        ),
      );
      return;
    }
    showDepositWithdrawDialog(
      context: context,
      depositTitle: S.depositFuturesTitle,
      withdrawTitle: S.withdrawFuturesTitle,
      unit: 'USDT',
      depositNotice: S.depositDemoNotice,
      withdrawNotice: S.withdrawDemoNotice,
      onDeposit: (amount) async {
        try {
          final json = await ApiClient.depositFutures(authToken.value, amount);
          if (!mounted) return null;
          setState(() => _balance = (json['balance'] as num).toDouble());
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.depositSuccessSnack), duration: const Duration(seconds: 2)),
          );
          return null;
        } on ApiException catch (e) {
          return e.message;
        }
      },
      onWithdraw: (amount) async {
        try {
          final json = await ApiClient.withdrawFutures(authToken.value, amount);
          if (!mounted) return null;
          setState(() => _balance = (json['balance'] as num).toDouble());
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.withdrawSuccessSnack), duration: const Duration(seconds: 2)),
          );
          return null;
        } on ApiException catch (e) {
          return e.message;
        }
      },
    );
  }

  void _openExchangeDialog() {
    if (!isLoggedIn.value) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.exchangeLoginRequiredSnack),
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: S.navLogin,
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NexbitLoginPage())),
          ),
        ),
      );
      return;
    }
    showExchangeDialog(
      context: context,
      onExchangeToFutures: (idrAmount, rate) async {
        try {
          final json = await ApiClient.exchangeToFutures(authToken.value, idrAmount, rate);
          if (!mounted) return null;
          final account = json['futures_account'] as Map<String, dynamic>;
          setState(() => _balance = (account['balance'] as num).toDouble());
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.exchangeSuccessSnack), duration: const Duration(seconds: 2)),
          );
          return null;
        } on ApiException catch (e) {
          return e.message;
        }
      },
      onExchangeToSpot: (usdtAmount, rate) async {
        try {
          final json = await ApiClient.exchangeToSpot(authToken.value, usdtAmount, rate);
          if (!mounted) return null;
          final account = json['futures_account'] as Map<String, dynamic>;
          setState(() => _balance = (account['balance'] as num).toDouble());
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.exchangeSuccessSnack), duration: const Duration(seconds: 2)),
          );
          return null;
        } on ApiException catch (e) {
          return e.message;
        }
      },
    );
  }

  void _selectAssetClass(FuturesAssetClass assetClass) {
    setState(() {
      _assetClass = assetClass;
      // Stored unwrapped — build() applies withLiveContractPrice fresh on
      // every read, so this doesn't need to pre-apply it here.
      _selected = contractsFor(assetClass).first;
    });
  }

  List<FuturesContract> get _filteredContracts {
    // withLiveContractPrice is a no-op for forex/saham ids (CoinGecko
    // doesn't track them) — only the crypto tab actually changes here.
    final all = contractsFor(_assetClass).map(withLiveContractPrice).toList();
    final term = _search.trim().toLowerCase();
    if (term.isEmpty) return all;
    return all.where((c) => c.id.toLowerCase().contains(term) || c.name.toLowerCase().contains(term)).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Re-derived fresh on every build (not cached in state) — see
    // _onLiveUpdate — so the very first render already reflects whatever
    // LivePriceService has cached, not just ticks that arrive after this
    // page has mounted.
    final liveSelected = withLiveContractPrice(_selected);
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
                                  selected: liveSelected,
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
                                    Expanded(child: _chartColumn(liveSelected)),
                                    const SizedBox(width: 16),
                                    SizedBox(width: 280, child: _orderBookColumn(liveSelected)),
                                    const SizedBox(width: 16),
                                    SizedBox(width: 320, child: _orderFormColumn(liveSelected)),
                                  ],
                                )
                              else
                                Column(
                                  children: [
                                    _chartColumn(liveSelected),
                                    const SizedBox(height: 16),
                                    _orderFormColumn(liveSelected),
                                    const SizedBox(height: 16),
                                    _orderBookColumn(liveSelected),
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

  Widget _orderBookColumn(FuturesContract selected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: NexbitColors.line),
          ),
          clipBehavior: Clip.antiAlias,
          child: FuturesOrderBookPanel(contract: selected),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: NexbitColors.line),
          ),
          clipBehavior: Clip.antiAlias,
          child: FuturesRecentTradesPanel(contract: selected),
        ),
      ],
    );
  }

  Widget _chartColumn(FuturesContract selected) {
    final mark = selected.price;
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
                          decoration: BoxDecoration(color: selected.iconColor, shape: BoxShape.circle),
                          child: Text(selected.iconLabel,
                              style: NexbitText.mono(fontSize: 11, weight: FontWeight.w700, color: const Color(0xFF04120E))),
                        ),
                        const SizedBox(width: 8),
                        Text('${selected.label} ${S.futuresPerpetual}',
                            style: NexbitText.body(fontSize: 15, weight: FontWeight.w700)),
                        const SizedBox(width: 12),
                        Text(formatUsdt(mark, selected.decimals),
                            style: NexbitText.mono(
                                fontSize: 16,
                                weight: FontWeight.w700,
                                color: selected.isUp ? NexbitColors.up : NexbitColors.down)),
                        const SizedBox(width: 8),
                        Text(selected.change,
                            style: NexbitText.mono(
                                fontSize: 13,
                                weight: FontWeight.w600,
                                color: selected.isUp ? NexbitColors.up : NexbitColors.down)),
                      ],
                    ),
                    _stat(S.futuresMarkPrice, formatUsdt(mark, selected.decimals)),
                    _stat(S.futures24hHigh, formatUsdt(high, selected.decimals)),
                    _stat(S.futures24hLow, formatUsdt(low, selected.decimals)),
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
                  child: TradingViewChart(symbol: selected.tvSymbol, interval: '60'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        FuturesPositionsPanel(
          positions: _positions,
          markPriceOf: _markPriceOf,
          onClose: _closePosition,
          closedPositions: _closedPositions,
          orders: _futuresOrders,
          onCancelOrder: _cancelOrder,
        ),
      ],
    );
  }

  Widget _orderFormColumn(FuturesContract selected) {
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
            contract: selected,
            availableBalance: _availableBalance,
            onSubmitOrder: _submitOrder,
          ),
        ),
        const SizedBox(height: 16),
        FuturesAccountInfoCard(
          positions: _positions,
          markPriceOf: _markPriceOf,
          startingBalance: _balance,
          realizedPnl: _realizedPnl,
          loading: _loadingAccount,
          onDeposit: _openDepositDialog,
          onExchange: _openExchangeDialog,
        ),
        const SizedBox(height: 16),
        FuturesContractDetailsCard(contract: selected),
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
