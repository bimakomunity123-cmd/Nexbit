import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/i18n/app_locale.dart';
import '../../../../core/i18n/strings.dart';
import '../../../../core/theme/nexbit_theme.dart';
import '../models/ticker_asset.dart';

class PriceTickerCard extends StatefulWidget {
  final List<TickerAsset> tickers;
  final VoidCallback? onViewAll;

  const PriceTickerCard({super.key, this.tickers = kSampleTickers, this.onViewAll});

  @override
  State<PriceTickerCard> createState() => _PriceTickerCardState();
}

class _PriceTickerCardState extends State<PriceTickerCard> {
  Timer? _timer;
  int _basePrice = 1147629543;
  final _idFormat = _IdrFormatter();
  final _rng = Random();

  @override
  void initState() {
    super.initState();
    // Cosmetic live-price flicker so the card doesn't look static —
    // swap this for a real feed (websocket/REST) in production.
    _timer = Timer.periodic(const Duration(milliseconds: 2200), (_) {
      setState(() {
        _basePrice += ((_rng.nextDouble() - 0.5) * 40000).round();
      });
    });
    // React immediately to the ID/EN toggle instead of waiting for the
    // next cosmetic price tick to happen to rebuild this card.
    appLocale.addListener(_onLocaleChanged);
  }

  void _onLocaleChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _timer?.cancel();
    appLocale.removeListener(_onLocaleChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 380,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: NexbitColors.line),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [NexbitColors.surface, NexbitColors.surface2],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.45),
            blurRadius: 80,
            offset: const Offset(0, 30),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          for (final t in widget.tickers) _buildRow(t),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            NexbitColors.accent.withOpacity(0.12),
            NexbitColors.accent2.withOpacity(0.10),
          ],
        ),
        border: const Border(bottom: BorderSide(color: NexbitColors.line)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BITCOIN · BTC/IDR',
            style: NexbitText.mono(
              fontSize: 11.5,
              color: NexbitColors.muted,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _idFormat.format(_basePrice),
                style: NexbitText.mono(fontSize: 28, weight: FontWeight.w700),
              ),
              const SizedBox(width: 8),
              Text('IDR', style: NexbitText.mono(fontSize: 13, color: NexbitColors.muted)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '▲ 0.01% · ${S.tickerPeriod}',
            style: NexbitText.mono(fontSize: 13, color: NexbitColors.up),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(TickerAsset t) {
    final isLast = widget.tickers.last == t;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: NexbitColors.line)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: t.iconColor,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  t.iconLabel,
                  style: NexbitText.mono(
                    fontSize: 13,
                    weight: FontWeight.w700,
                    color: const Color(0xFF04120E),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.name,
                      style: NexbitText.body(fontSize: 14, weight: FontWeight.w600, color: NexbitColors.text)),
                  Text(t.symbol, style: NexbitText.mono(fontSize: 11.5, color: NexbitColors.muted)),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(t.price, style: NexbitText.mono(fontSize: 14, weight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(
                t.change,
                style: NexbitText.mono(
                  fontSize: 12,
                  color: t.isUp ? NexbitColors.up : NexbitColors.down,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: NexbitColors.line)),
      ),
      alignment: Alignment.center,
      child: InkWell(
        onTap: widget.onViewAll,
        child: Text(
          S.tickerViewAll,
          style: NexbitText.body(fontSize: 13, weight: FontWeight.w600, color: NexbitColors.accent),
        ),
      ),
    );
  }
}

/// Minimal "1.147.629.543" style thousands-separator formatter
/// so this file has zero extra package dependencies (no `intl`).
class _IdrFormatter {
  String format(int value) {
    final s = value.abs().toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      final posFromEnd = s.length - i;
      buf.write(s[i]);
      if (posFromEnd > 1 && posFromEnd % 3 == 1) buf.write('.');
    }
    return (value < 0 ? '-' : '') + buf.toString();
  }
}
