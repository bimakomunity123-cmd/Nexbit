import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/i18n/strings.dart';
import '../../../../core/theme/nexbit_theme.dart';
import '../../domain/models/futures_contract.dart';

class _BookRow {
  final double price;
  final double size;
  double total;
  _BookRow(this.price, this.size, this.total);
}

/// The Order Book panel on the Futures page — same bid/ask + running-total
/// shape as the spot Trading page's order book, rebuilt against
/// [FuturesContract] (USDT prices) instead of the IDR-quoted [TradingPair].
class FuturesOrderBookPanel extends StatefulWidget {
  final FuturesContract contract;
  const FuturesOrderBookPanel({super.key, required this.contract});

  @override
  State<FuturesOrderBookPanel> createState() => _FuturesOrderBookPanelState();
}

class _FuturesOrderBookPanelState extends State<FuturesOrderBookPanel> {
  final _rng = Random();
  List<_BookRow> _asks = [];
  List<_BookRow> _bids = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _regenerate();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) => setState(_regenerate));
  }

  @override
  void didUpdateWidget(covariant FuturesOrderBookPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.contract.id != widget.contract.id) setState(_regenerate);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _regenerate() {
    final tick = widget.contract.price * 0.0002;
    var runningTotal = 0.0;
    _asks = List.generate(5, (i) {
      final price = widget.contract.price + tick * (5 - i);
      final size = _rng.nextDouble() * 0.8 + 0.1;
      return _BookRow(price, size, size);
    });
    for (var i = _asks.length - 1; i >= 0; i--) {
      runningTotal += _asks[i].size;
      _asks[i].total = runningTotal;
    }
    runningTotal = 0;
    _bids = List.generate(5, (i) {
      final price = widget.contract.price - tick * (i + 1);
      final size = _rng.nextDouble() * 0.8 + 0.1;
      runningTotal += size;
      return _BookRow(price, size, runningTotal);
    });
  }

  @override
  Widget build(BuildContext context) {
    final decimals = widget.contract.decimals;
    final maxTotal = [..._asks, ..._bids].map((r) => r.total).fold(0.0001, max);

    return Container(
      color: NexbitColors.panel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(S.futuresOrderBook, style: NexbitText.body(fontSize: 13, weight: FontWeight.w700)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    border: Border.all(color: NexbitColors.line),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('0.01', style: NexbitText.mono(fontSize: 11, color: NexbitColors.muted)),
                      const Icon(Icons.keyboard_arrow_down, size: 14, color: NexbitColors.muted),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(S.futuresColPrice, style: NexbitText.mono(fontSize: 10.5, color: NexbitColors.muted2)),
                Text(S.futuresColSize, style: NexbitText.mono(fontSize: 10.5, color: NexbitColors.muted2)),
                Text(S.futuresColTotal, style: NexbitText.mono(fontSize: 10.5, color: NexbitColors.muted2)),
              ],
            ),
          ),
          for (final r in _asks.reversed) _row(r, isAsk: true, maxTotal: maxTotal, decimals: decimals),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: NexbitColors.accent.withOpacity(.04),
              border: const Border.symmetric(horizontal: BorderSide(color: NexbitColors.lineSoft)),
            ),
            child: Row(
              children: [
                Text(formatUsdt(widget.contract.price, decimals),
                    style: NexbitText.mono(
                        fontSize: 15,
                        weight: FontWeight.w700,
                        color: widget.contract.isUp ? NexbitColors.up : NexbitColors.down)),
                const SizedBox(width: 6),
                Icon(widget.contract.isUp ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 13, color: widget.contract.isUp ? NexbitColors.up : NexbitColors.down),
                const SizedBox(width: 4),
                Text(widget.contract.change,
                    style: NexbitText.mono(
                        fontSize: 12,
                        weight: FontWeight.w600,
                        color: widget.contract.isUp ? NexbitColors.up : NexbitColors.down)),
              ],
            ),
          ),
          for (final r in _bids) _row(r, isAsk: false, maxTotal: maxTotal, decimals: decimals),
        ],
      ),
    );
  }

  Widget _row(_BookRow r, {required bool isAsk, required double maxTotal, required int decimals}) {
    final color = isAsk ? NexbitColors.down : NexbitColors.up;
    final widthFraction = (r.total / maxTotal).clamp(0.0, 1.0);
    return Stack(
      children: [
        Positioned.fill(
          child: Align(
            alignment: Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: widthFraction,
              child: Container(color: color.withOpacity(.10)),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3.5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(formatUsdt(r.price, decimals), style: NexbitText.mono(fontSize: 11.5, color: color)),
              Text(r.size.toStringAsFixed(2), style: NexbitText.mono(fontSize: 11.5)),
              Text(r.total.toStringAsFixed(2), style: NexbitText.mono(fontSize: 11.5, color: NexbitColors.muted2)),
            ],
          ),
        ),
      ],
    );
  }
}
