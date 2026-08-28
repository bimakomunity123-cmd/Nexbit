import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/i18n/strings.dart';
import '../../../../core/theme/nexbit_theme.dart';
import '../../domain/models/trading_pair.dart';

class MarketTradesPanel extends StatefulWidget {
  final TradingPair pair;
  const MarketTradesPanel({super.key, required this.pair});

  @override
  State<MarketTradesPanel> createState() => _MarketTradesPanelState();
}

class _Trade {
  final double price;
  final double amount;
  final bool isUp;
  final DateTime time;
  _Trade(this.price, this.amount, this.isUp, this.time);
}

class _MarketTradesPanelState extends State<MarketTradesPanel> {
  final _rng = Random();
  bool _showMine = false;
  List<_Trade> _trades = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _regenerate();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => setState(_regenerate));
  }

  @override
  void didUpdateWidget(covariant MarketTradesPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pair.id != widget.pair.id) setState(_regenerate);
  }

  void _regenerate() {
    var price = widget.pair.base;
    final step = widget.pair.base * 0.00006;
    // A generous count so the list still fills tall/large monitors instead
    // of running dry and leaving empty (if correctly-coloured) space below.
    _trades = List.generate(60, (i) {
      price += (_rng.nextDouble() - 0.5) * step;
      return _Trade(
        price,
        _rng.nextDouble() * 0.3,
        _rng.nextBool(),
        DateTime.now().subtract(Duration(seconds: i * 7)),
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _time(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:${t.second.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
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
              children: [
                _TradesTab(label: S.marketTradesTab, active: !_showMine, onTap: () => setState(() => _showMine = false)),
                const SizedBox(width: 18),
                _TradesTab(label: S.myTradesTab, active: _showMine, onTap: () => setState(() => _showMine = true)),
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
                Text(S.timeCol, style: NexbitText.mono(fontSize: 10.5, color: NexbitColors.muted2)),
              ],
            ),
          ),
          Expanded(
            child: _showMine
                ? Center(
                    child: Text(S.noTradesYet, style: NexbitText.body(fontSize: 12, color: NexbitColors.muted2)),
                  )
                : ListView.builder(
                    itemCount: _trades.length,
                    itemBuilder: (context, i) {
                      final t = _trades[i];
                      final color = t.isUp ? NexbitColors.up : NexbitColors.down;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3.5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(formatPrice(t.price, decimals), style: NexbitText.mono(fontSize: 11.5, color: color)),
                            Text(t.amount.toStringAsFixed(decimals >= 3 ? 3 : 5), style: NexbitText.mono(fontSize: 11.5)),
                            Text(_time(t.time), style: NexbitText.mono(fontSize: 11.5, color: NexbitColors.muted2)),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _TradesTab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _TradesTab({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          border: active ? const Border(bottom: BorderSide(color: NexbitColors.accent, width: 2)) : null,
        ),
        child: Text(
          label,
          style: NexbitText.body(
            fontSize: 12.5,
            weight: active ? FontWeight.w600 : FontWeight.w400,
            color: active ? NexbitColors.text : NexbitColors.muted,
          ),
        ),
      ),
    );
  }
}
