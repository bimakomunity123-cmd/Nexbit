import 'package:flutter/material.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/auth/session.dart';
import '../../../../core/i18n/app_locale.dart';
import '../../../../core/i18n/strings.dart';
import '../../../../core/market_data/live_price_service.dart';
import '../../../../core/market_data/live_pricing.dart';
import '../../../../core/theme/nexbit_theme.dart';
import '../../domain/models/spot_order.dart';
import '../../domain/models/trading_pair.dart';
import '../widgets/trading_topbar.dart';
import '../widgets/pairs_panel.dart';
import '../widgets/tradingview_chart.dart';
import '../widgets/order_book_panel.dart';
import '../widgets/market_trades_panel.dart';
import '../widgets/order_form_panel.dart';
import '../widgets/open_orders_panel.dart';
import '../widgets/spot_wallet_card.dart';

class NexbitTradingPage extends StatefulWidget {
  final TradingPair? initialPair;
  const NexbitTradingPage({super.key, this.initialPair});

  @override
  State<NexbitTradingPage> createState() => _NexbitTradingPageState();
}

class _NexbitTradingPageState extends State<NexbitTradingPage> {
  late TradingPair _selected = widget.initialPair ?? kTradingPairs.first;

  // Guests see a fixed demo balance and a deterministic per-pair seeded
  // order history (local-only, never touches the backend) — a logged-in
  // user's real wallet/holdings/orders are fetched from the backend in
  // initState instead, same split Futures uses for balance/positions.
  double _idrBalance = 50000000.0;
  Map<String, double> _holdingsByAsset = {};
  late List<SpotOrder> _orders = isLoggedIn.value ? [] : seedGuestOrders(_selected);

  static const _hairline = BoxDecoration(border: Border(right: BorderSide(color: NexbitColors.line)));

  void _selectPair(TradingPair p) {
    setState(() {
      _selected = p;
      if (!isLoggedIn.value) _orders = seedGuestOrders(p);
    });
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

  void _onLiveUpdate() {
    if (mounted) setState(() {});
  }

  // Loads the logged-in user's real wallet/holdings/orders from the
  // backend. Left at the guest-mode defaults on any failure (offline,
  // backend down) rather than showing an error — the page still works
  // fine for browsing/pricing even without this succeeding.
  Future<void> _loadAccountData() async {
    try {
      final token = authToken.value;
      final results = await Future.wait([
        ApiClient.getSpotWallet(token),
        ApiClient.getSpotHoldings(token),
        ApiClient.getSpotOrders(token),
      ]);
      final wallet = results[0] as Map<String, dynamic>;
      final holdingsJson = results[1] as List<dynamic>;
      final ordersJson = results[2] as List<dynamic>;
      if (!mounted) return;
      setState(() {
        _idrBalance = (wallet['idr_balance'] as num).toDouble();
        _holdingsByAsset = {
          for (final h in holdingsJson) (h as Map<String, dynamic>)['asset_id'] as String: (h['quantity'] as num).toDouble(),
        };
        _orders = ordersJson.map((j) => _orderFromJson(j as Map<String, dynamic>)).toList();
      });
    } catch (_) {
      // Stays on the guest-mode defaults set in the field initializers
      // above — no fake orders shown to a real account even if the
      // fetch fails.
    }
  }

  SpotOrder _orderFromJson(Map<String, dynamic> json) {
    final assetId = json['asset_id'] as String;
    final pair = kTradingPairs.firstWhere((p) => p.id == assetId, orElse: () => _selected);
    return SpotOrder.fromJson(json, pair);
  }

  double _holdingQuantityOf(String assetId) => _holdingsByAsset[assetId] ?? 0;

  Future<void> _submitOrder(SpotOrderSide side, OrderType orderType, double price, double amount) async {
    try {
      final json = await ApiClient.createSpotOrder(authToken.value, {
        'asset_id': _selected.id,
        'side': side == SpotOrderSide.sell ? 'sell' : 'buy',
        'order_type': orderTypeToJson(orderType),
        'price': price,
        'amount': amount,
      });
      final newOrder = _orderFromJson(json['order'] as Map<String, dynamic>);
      final walletJson = json['wallet'] as Map<String, dynamic>;
      if (!mounted) return;
      setState(() {
        _idrBalance = (walletJson['idr_balance'] as num).toDouble();
        if (newOrder.status == SpotOrderStatus.filled) {
          final delta = side == SpotOrderSide.buy ? amount : -amount;
          final next = (_holdingsByAsset[_selected.id] ?? 0) + delta;
          if (next <= 0) {
            _holdingsByAsset.remove(_selected.id);
          } else {
            _holdingsByAsset[_selected.id] = next;
          }
        }
        _orders = [newOrder, ..._orders];
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(newOrder.status == SpotOrderStatus.filled ? S.tradingOrderFilledSnack : S.tradingOrderPlacedSnack),
        duration: const Duration(seconds: 2),
      ));
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message), duration: const Duration(seconds: 3)));
    }
  }

  Future<void> _cancelOrder(SpotOrder o) async {
    // Only a backend-persisted order (id != null) needs a server round-
    // trip — a guest-mode seeded order cancels purely locally, same as
    // before this page had a backend at all.
    if (o.id != null) {
      try {
        await ApiClient.cancelSpotOrder(authToken.value, o.id!);
      } on ApiException catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message), duration: const Duration(seconds: 3)));
        return;
      }
    }
    if (!mounted) return;
    setState(() {
      _orders = _orders
          .map((e) => identical(e, o)
              ? SpotOrder(
                  id: e.id,
                  pair: e.pair,
                  side: e.side,
                  orderType: e.orderType,
                  price: e.price,
                  amount: e.amount,
                  status: SpotOrderStatus.cancelled,
                  createdAt: e.createdAt,
                )
              : e)
          .toList();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(S.orderCancelledSnack), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Live-priced copy of whatever's selected — falls back to _selected's
    // own (mock) values for anything CoinGecko doesn't track, e.g. forex.
    final live = withLivePrice(_selected);

    // Listens to appLocale directly so this page rebuilds with fresh text
    // whenever the ID/EN toggle flips — independent of Navigator/route
    // mechanics, which don't automatically re-invoke a route's builder.
    return ValueListenableBuilder<AppLocale>(
      valueListenable: appLocale,
      builder: (context, locale, _) => Scaffold(
        backgroundColor: NexbitColors.bg,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TradingTopbar(
                pair: live,
                onLogoTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth >= 1180;
                    return wide ? _wideLayout(live) : _narrowLayout(live);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _orderForm(TradingPair live) {
    return OrderFormPanel(
      pair: live,
      idrBalance: _idrBalance,
      holdingQuantityOf: _holdingQuantityOf,
      onSubmitOrder: _submitOrder,
    );
  }

  Widget _walletCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: SpotWalletCard(
        idrBalance: _idrBalance,
        holdings: _holdingsByAsset.entries.map((e) => SpotHoldingEntry(assetId: e.key, quantity: e.value)).toList(),
        priceOf: (assetId) {
          final pair = kTradingPairs.firstWhere((p) => p.id == assetId, orElse: () => _selected);
          return withLivePrice(pair).base;
        },
      ),
    );
  }

  /// Desktop/tablet: 3-column grid — pairs+trades | chart+panel | orderbook.
  Widget _wideLayout(TradingPair live) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 268,
          child: DecoratedBox(
            decoration: _hairline,
            child: Column(
              children: [
                SizedBox(height: 460, child: PairsPanel(selected: live, onSelect: _selectPair)),
                const Divider(height: 1, color: NexbitColors.line),
                Expanded(child: MarketTradesPanel(pair: live)),
              ],
            ),
          ),
        ),
        Expanded(
          child: DecoratedBox(
            decoration: _hairline,
            child: Column(
              children: [
                // Given a generous flex share so the chart grows into the
                // available height instead of sitting squashed at a fixed
                // size with empty space left underneath it.
                Expanded(flex: 5, child: TradingViewChart(symbol: live.tvSymbol)),
                const Divider(height: 1, color: NexbitColors.line),
                // A bit of top breathing room so Beli/Jual doesn't sit
                // flush against the chart divider.
                Padding(
                  padding: const EdgeInsets.only(top: 18),
                  child: _orderForm(live),
                ),
                _walletCard(),
                const Divider(height: 1, color: NexbitColors.line),
                // Fills what would otherwise be empty space below the
                // order form with a real Open Orders / Order History table.
                Expanded(flex: 4, child: OpenOrdersPanel(orders: _orders, onCancel: _cancelOrder)),
              ],
            ),
          ),
        ),
        SizedBox(width: 296, child: OrderBookPanel(pair: live)),
      ],
    );
  }

  /// Mobile: everything stacked and scrollable.
  Widget _narrowLayout(TradingPair live) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 420, child: TradingViewChart(symbol: live.tvSymbol)),
          const Divider(height: 1, color: NexbitColors.line),
          _orderForm(live),
          _walletCard(),
          const Divider(height: 1, color: NexbitColors.line),
          SizedBox(height: 360, child: PairsPanel(selected: live, onSelect: _selectPair)),
          const Divider(height: 1, color: NexbitColors.line),
          SizedBox(height: 320, child: OrderBookPanel(pair: live)),
          const Divider(height: 1, color: NexbitColors.line),
          SizedBox(height: 300, child: MarketTradesPanel(pair: live)),
          const Divider(height: 1, color: NexbitColors.line),
          SizedBox(height: 280, child: OpenOrdersPanel(orders: _orders, onCancel: _cancelOrder)),
        ],
      ),
    );
  }
}
