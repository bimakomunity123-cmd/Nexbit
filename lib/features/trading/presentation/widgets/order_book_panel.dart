import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/i18n/strings.dart';
import '../../../../core/theme/nexbit_theme.dart';
import '../../domain/models/trading_pair.dart';

class OrderBookPanel extends StatefulWidget {
  final TradingPair pair;
  const OrderBookPanel({super.key, required this.pair});

  @override
  State<OrderBookPanel> createState() => _OrderBookPanelState();
}

class _OrderBookRow {
  final double price;
  final double amount;
  _OrderBookRow(this.price, this.amount);
}

class _OrderBookPanelState extends State<OrderBookPanel> {
  final _rng = Random();
  List<_OrderBookRow> _asks = [];
  List<_OrderBookRow> _bids = [];
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _regenerate();
    // Cosmetic periodic refresh — swap for a real order book feed later.
    _refreshTimer = Timer.periodic(const Duration(seconds: 4), (_) => setState(_regenerate));
  }

  @override
  void didUpdateWidget(covariant OrderBookPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pair.id != widget.pair.id) setState(_regenerate);
  }

  void _regenerate() {
    _asks = _genBook(widget.pair.base * 1.00005, side: 1);
    _bids = _genBook(widget.pair.base * 0.99995, side: -1);
  }

  List<_OrderBookRow> _genBook(double base, {required int side}) {
    final step = widget.pair.base * 0.00008;
    var price = base;
    final rows = <_OrderBookRow>[];
    // Generous depth so the book still fills tall/large monitors instead of
    // running dry and leaving empty (if correctly-coloured) space below.
    for (var i = 0; i < 30; i++) {
      price += side * _rng.nextDouble() * step;
      final amount = _rng.nextDouble() * 1.2;
      rows.add(_OrderBookRow(price, amount));
    }
    if (side > 0) rows.sort((a, b) => b.price.compareTo(a.price));
    return rows;
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxAmt = [..._asks, ..._bids].map((r) => r.amount).fold(0.0001, max);
    final decimals = widget.pair.decimals;

    return Container(
      color: NexbitColors.panel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: NexbitColors.lineSoft))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(S.orderBookTitle, style: NexbitText.body(fontSize: 12.5, weight: FontWeight.w600, color: NexbitColors.text)),
                Text('20 ▾', style: NexbitText.mono(fontSize: 11.5, color: NexbitColors.muted)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(S.orderBookPriceCol(widget.pair.quote), style: NexbitText.mono(fontSize: 10.5, color: NexbitColors.muted2)),
                Text(S.orderBookAmountCol(widget.pair.id), style: NexbitText.mono(fontSize: 10.5, color: NexbitColors.muted2)),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: _asks.map((r) => _BookRow(row: r, isAsk: true, maxAmt: maxAmt, decimals: decimals)).toList(),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: NexbitColors.accent.withOpacity(.04),
              border: const Border.symmetric(
                horizontal: BorderSide(color: NexbitColors.lineSoft),
              ),
            ),
            child: Text(
              formatPrice(widget.pair.base, decimals),
              style: NexbitText.mono(fontSize: 17, weight: FontWeight.w700, color: NexbitColors.up),
            ),
          ),
          Expanded(
            child: ListView(
              children: _bids.map((r) => _BookRow(row: r, isAsk: false, maxAmt: maxAmt, decimals: decimals)).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookRow extends StatelessWidget {
  final _OrderBookRow row;
  final bool isAsk;
  final double maxAmt;
  final int decimals;
  const _BookRow({required this.row, required this.isAsk, required this.maxAmt, required this.decimals});

  @override
  Widget build(BuildContext context) {
    final color = isAsk ? NexbitColors.down : NexbitColors.up;
    final widthFraction = (row.amount / maxAmt).clamp(0.0, 1.0);
    return Stack(
      children: [
        Positioned.fill(
          child: Align(
            alignment: Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: widthFraction,
              child: Container(color: color.withOpacity(.12)),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3.5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(formatPrice(row.price, decimals), style: NexbitText.mono(fontSize: 11.5, color: color)),
              Text(row.amount.toStringAsFixed(decimals >= 3 ? 3 : 5), style: NexbitText.mono(fontSize: 11.5)),
            ],
          ),
        ),
      ],
    );
  }
}
