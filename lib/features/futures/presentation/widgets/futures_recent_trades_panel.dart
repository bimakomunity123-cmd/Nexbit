import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/i18n/strings.dart';
import '../../../../core/theme/nexbit_theme.dart';
import '../../domain/models/futures_contract.dart';

class _Trade {
  final double price;
  final double size;
  final bool isUp;
  final DateTime time;
  _Trade(this.price, this.size, this.isUp, this.time);
}

class FuturesRecentTradesPanel extends StatefulWidget {
  final FuturesContract contract;
  const FuturesRecentTradesPanel({super.key, required this.contract});

  @override
  State<FuturesRecentTradesPanel> createState() => _FuturesRecentTradesPanelState();
}

class _FuturesRecentTradesPanelState extends State<FuturesRecentTradesPanel> {
  final _rng = Random();
  List<_Trade> _trades = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _regenerate();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => setState(_regenerate));
  }

  @override
  void didUpdateWidget(covariant FuturesRecentTradesPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.contract.id != widget.contract.id) setState(_regenerate);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _regenerate() {
    var price = widget.contract.price;
    final step = widget.contract.price * 0.0003;
    _trades = List.generate(20, (i) {
      price += (_rng.nextDouble() - 0.5) * step;
      return _Trade(price, _rng.nextDouble() * 0.5, _rng.nextBool(), DateTime.now().subtract(Duration(seconds: i * 6)));
    });
  }

  String _time(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:${t.second.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final decimals = widget.contract.decimals;
    return Container(
      color: NexbitColors.panel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Text(S.futuresRecentTrades, style: NexbitText.body(fontSize: 13, weight: FontWeight.w700)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(S.futuresColPrice, style: NexbitText.mono(fontSize: 10.5, color: NexbitColors.muted2)),
                Text(S.futuresColSize, style: NexbitText.mono(fontSize: 10.5, color: NexbitColors.muted2)),
                Text(S.futuresColTime, style: NexbitText.mono(fontSize: 10.5, color: NexbitColors.muted2)),
              ],
            ),
          ),
          for (final t in _trades)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3.5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(formatUsdt(t.price, decimals),
                      style: NexbitText.mono(fontSize: 11.5, color: t.isUp ? NexbitColors.up : NexbitColors.down)),
                  Text(t.size.toStringAsFixed(2), style: NexbitText.mono(fontSize: 11.5)),
                  Text(_time(t.time), style: NexbitText.mono(fontSize: 11.5, color: NexbitColors.muted2)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
