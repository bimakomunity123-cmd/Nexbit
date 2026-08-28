import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/i18n/app_locale.dart';
import '../../../../core/i18n/strings.dart';
import '../../../../core/theme/nexbit_theme.dart';
import '../../../../core/widgets/nexbit_logo_mark.dart';
import '../../domain/models/trading_pair.dart';

class TradingTopbar extends StatefulWidget {
  final TradingPair pair;
  final VoidCallback? onLogoTap;
  const TradingTopbar({super.key, required this.pair, this.onLogoTap});

  @override
  State<TradingTopbar> createState() => _TradingTopbarState();
}

class _TradingTopbarState extends State<TradingTopbar> {
  final _rng = Random();
  late double _price;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _price = widget.pair.base;
    _startTicker();
    // React immediately to the ID/EN toggle instead of waiting for the
    // next cosmetic price tick to happen to rebuild this widget.
    appLocale.addListener(_onLocaleChanged);
  }

  void _onLocaleChanged() {
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(covariant TradingTopbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pair.id != widget.pair.id) {
      _price = widget.pair.base;
      _startTicker();
    }
  }

  void _startTicker() {
    _timer?.cancel();
    // Cosmetic tick so the header price feels "alive" — swap for a real
    // ticker feed (websocket/REST) alongside the order book / trades data.
    _timer = Timer.periodic(const Duration(milliseconds: 2500), (_) {
      setState(() => _price += (_rng.nextDouble() - 0.5) * widget.pair.base * 0.0004);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    appLocale.removeListener(_onLocaleChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.pair;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: const BoxDecoration(
        color: NexbitColors.surface,
        border: Border(bottom: BorderSide(color: NexbitColors.line)),
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 36,
        runSpacing: 12,
        children: [
          InkWell(
            onTap: widget.onLogoTap,
            child: const NexbitLogoLockup(markSize: 26, borderRadius: 7, wordmarkFontSize: 17, spacing: 9),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 24,
                height: 24,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(color: p.iconColor, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text(p.iconLabel, style: NexbitText.mono(fontSize: 11, weight: FontWeight.w700, color: const Color(0xFF04120E))),
              ),
              Text(p.label, style: NexbitText.display(fontSize: 17, weight: FontWeight.w700)),
            ],
          ),
          Text(
            formatPrice(_price, p.decimals),
            style: NexbitText.mono(fontSize: 19, weight: FontWeight.w700, color: p.isUp ? NexbitColors.up : NexbitColors.down),
          ),
          _Stat(label: S.tradingChange24h, value: p.change, valueColor: p.isUp ? NexbitColors.up : NexbitColors.down),
          _Stat(label: S.tradingHigh24h, value: formatPrice(p.base * 1.012, p.decimals)),
          _Stat(label: S.tradingLow24h, value: formatPrice(p.base * 0.987, p.decimals)),
          _Stat(label: '${S.tradingVolume} (${p.id})', value: '9.897,28806'),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _Stat({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: NexbitText.body(fontSize: 11, color: NexbitColors.muted2)),
        const SizedBox(height: 3),
        Text(value, style: NexbitText.mono(fontSize: 13, weight: FontWeight.w600, color: valueColor ?? NexbitColors.text)),
      ],
    );
  }
}
