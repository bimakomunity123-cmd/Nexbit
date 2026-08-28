import 'package:flutter/material.dart';
import '../../../../core/i18n/app_locale.dart';
import '../../../../core/theme/nexbit_theme.dart';
import '../../domain/models/trading_pair.dart';
import '../widgets/trading_topbar.dart';
import '../widgets/pairs_panel.dart';
import '../widgets/tradingview_chart.dart';
import '../widgets/order_book_panel.dart';
import '../widgets/market_trades_panel.dart';
import '../widgets/order_form_panel.dart';
import '../widgets/open_orders_panel.dart';

class NexbitTradingPage extends StatefulWidget {
  final TradingPair? initialPair;
  const NexbitTradingPage({super.key, this.initialPair});

  @override
  State<NexbitTradingPage> createState() => _NexbitTradingPageState();
}

class _NexbitTradingPageState extends State<NexbitTradingPage> {
  late TradingPair _selected = widget.initialPair ?? kTradingPairs.first;

  void _selectPair(TradingPair p) => setState(() => _selected = p);

  static const _hairline = BoxDecoration(border: Border(right: BorderSide(color: NexbitColors.line)));

  @override
  Widget build(BuildContext context) {
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
                pair: _selected,
                onLogoTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth >= 1180;
                    return wide ? _wideLayout() : _narrowLayout();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Desktop/tablet: 3-column grid — pairs+trades | chart+panel | orderbook.
  Widget _wideLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 268,
          child: DecoratedBox(
            decoration: _hairline,
            child: Column(
              children: [
                SizedBox(height: 460, child: PairsPanel(selected: _selected, onSelect: _selectPair)),
                const Divider(height: 1, color: NexbitColors.line),
                Expanded(child: MarketTradesPanel(pair: _selected)),
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
                Expanded(flex: 5, child: TradingViewChart(symbol: _selected.tvSymbol)),
                const Divider(height: 1, color: NexbitColors.line),
                // A bit of top breathing room so Beli/Jual doesn't sit
                // flush against the chart divider.
                Padding(
                  padding: const EdgeInsets.only(top: 18),
                  child: OrderFormPanel(pair: _selected),
                ),
                const Divider(height: 1, color: NexbitColors.line),
                // Fills what would otherwise be empty space below the
                // order form with a real Open Orders / Order History table.
                Expanded(flex: 4, child: OpenOrdersPanel(pair: _selected)),
              ],
            ),
          ),
        ),
        SizedBox(width: 296, child: OrderBookPanel(pair: _selected)),
      ],
    );
  }

  /// Mobile: everything stacked and scrollable.
  Widget _narrowLayout() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 420, child: TradingViewChart(symbol: _selected.tvSymbol)),
          const Divider(height: 1, color: NexbitColors.line),
          OrderFormPanel(pair: _selected),
          const Divider(height: 1, color: NexbitColors.line),
          SizedBox(height: 360, child: PairsPanel(selected: _selected, onSelect: _selectPair)),
          const Divider(height: 1, color: NexbitColors.line),
          SizedBox(height: 320, child: OrderBookPanel(pair: _selected)),
          const Divider(height: 1, color: NexbitColors.line),
          SizedBox(height: 300, child: MarketTradesPanel(pair: _selected)),
          const Divider(height: 1, color: NexbitColors.line),
          SizedBox(height: 280, child: OpenOrdersPanel(pair: _selected)),
        ],
      ),
    );
  }
}
