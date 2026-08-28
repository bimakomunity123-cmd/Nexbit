import 'package:flutter/material.dart';
import '../../../../core/i18n/strings.dart';
import '../../../../core/theme/nexbit_theme.dart';
import '../../../trading/domain/models/trading_pair.dart';
import '../../../trading/presentation/widgets/tradingview_chart.dart';

/// The "Market Chart" card at the bottom of the Market page's main
/// column — a real embedded chart (same TradingView widget the Trading
/// page uses) with an OHLC summary line. Timeframe switching is handled
/// by the embedded chart's own toolbar, so this card doesn't duplicate it
/// with a second set of tabs.
class MarketChartCard extends StatelessWidget {
  final TradingPair pair;
  const MarketChartCard({super.key, required this.pair});

  @override
  Widget build(BuildContext context) {
    final color = pair.isUp ? NexbitColors.up : NexbitColors.down;
    // Pseudo OHLC around the pair's reference price — there's no real
    // candle feed behind this summary line, same spirit as the rest of
    // the mock market data in this app; the embedded chart below it is
    // the real (if delayed/demo) TradingView feed.
    final open = pair.base * 0.9993;
    final high = pair.base * 1.0028;
    final low = pair.base * 0.9971;
    final close = pair.base;
    final diff = close - open;
    final diffPct = (diff / open * 100);

    return Container(
      decoration: BoxDecoration(
        color: NexbitColors.panel,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: NexbitColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16,
              runSpacing: 8,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.show_chart, size: 16, color: NexbitColors.accent),
                    const SizedBox(width: 8),
                    Text(S.marketChartHeading, style: NexbitText.body(fontSize: 13.5, weight: FontWeight.w700)),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: pair.iconColor, shape: BoxShape.circle),
                      child: Text(pair.iconLabel,
                          style: NexbitText.mono(fontSize: 10, weight: FontWeight.w700, color: const Color(0xFF04120E))),
                    ),
                    const SizedBox(width: 8),
                    Text(pair.label, style: NexbitText.body(fontSize: 13, weight: FontWeight.w700)),
                    const SizedBox(width: 8),
                    Text(formatPrice(pair.base, pair.decimals),
                        style: NexbitText.mono(fontSize: 13, weight: FontWeight.w700)),
                    const SizedBox(width: 6),
                    Text(pair.change, style: NexbitText.mono(fontSize: 12, weight: FontWeight.w600, color: color)),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                _ohlc('O', open, pair.decimals),
                _ohlc('H', high, pair.decimals),
                _ohlc('L', low, pair.decimals),
                _ohlc('C', close, pair.decimals),
                Text('${diff >= 0 ? '+' : ''}${formatPrice(diff, pair.decimals)} (${diffPct.toStringAsFixed(2)}%)',
                    style: NexbitText.mono(fontSize: 12, weight: FontWeight.w600, color: color)),
              ],
            ),
          ),
          const Divider(height: 1, color: NexbitColors.line),
          SizedBox(
            height: 540,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
              child: TradingViewChart(symbol: pair.tvSymbol, interval: '60'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ohlc(String label, double value, int decimals) {
    return RichText(
      text: TextSpan(
        style: NexbitText.mono(fontSize: 11.5, color: NexbitColors.muted2),
        children: [
          TextSpan(text: label),
          TextSpan(text: formatPrice(value, decimals), style: const TextStyle(color: NexbitColors.muted)),
        ],
      ),
    );
  }
}
