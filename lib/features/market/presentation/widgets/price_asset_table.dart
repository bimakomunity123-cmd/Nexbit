import 'package:flutter/material.dart';
import '../../../../core/i18n/strings.dart';
import '../../../../core/theme/nexbit_theme.dart';
import '../../../trading/domain/models/trading_pair.dart';
import 'mini_sparkline.dart';

/// The Beli/Jual (bid/ask) price table — icon, name, buy/sell price,
/// 24h change, a small trend sparkline, and a "Trade" action per row.
///
/// Columns stretch to fill the available width whenever there's room for
/// it, so the table doesn't leave a dead empty gap on wide screens; below
/// [_tableMinWidth] it falls back to a fixed-width table that scrolls
/// horizontally instead of squeezing/overflowing.
class PriceAssetTable extends StatelessWidget {
  final List<TradingPair> pairs;
  final ValueChanged<TradingPair> onTrade;

  const PriceAssetTable({super.key, required this.pairs, required this.onTrade});

  static const _colAsset = 190.0;
  static const _colPrice = 150.0;
  static const _colChange = 90.0;
  static const _colTrend = 100.0;
  static const _colAction = 90.0;
  static const _rowPadding = 32.0; // 16px horizontal padding on each row Container
  static const _tableMinWidth = _colAsset + _colPrice * 2 + _colChange + _colTrend + _colAction + _rowPadding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final flexible = constraints.maxWidth >= _tableMinWidth;
        final table = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: NexbitColors.line))),
              child: Row(
                children: [
                  _cell(_colAsset, flexible, _HeaderLabel(S.priceColAsset)),
                  _cell(_colPrice, flexible, _HeaderLabel(S.priceColBuy, alignEnd: true)),
                  _cell(_colPrice, flexible, _HeaderLabel(S.priceColSell, alignEnd: true)),
                  _cell(_colChange, flexible, _HeaderLabel(S.priceColChange, alignEnd: true)),
                  _cell(_colTrend, flexible, _HeaderLabel(S.priceColTrend, alignEnd: true)),
                  _cell(_colAction, flexible, _HeaderLabel(S.priceColAction, alignEnd: true)),
                ],
              ),
            ),
            for (final p in pairs) _AssetRow(pair: p, onTrade: onTrade, flexible: flexible),
          ],
        );

        if (flexible) return table;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(width: _tableMinWidth, child: table),
        );
      },
    );
  }
}

/// A column cell: a proportional [Expanded] when the table has room to
/// stretch, or a fixed-width [SizedBox] when it's scrolling horizontally.
Widget _cell(double width, bool flexible, Widget child) {
  if (flexible) return Expanded(flex: width.round(), child: child);
  return SizedBox(width: width, child: child);
}

class _HeaderLabel extends StatelessWidget {
  final String text;
  final bool alignEnd;
  const _HeaderLabel(this.text, {this.alignEnd = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: alignEnd ? TextAlign.end : TextAlign.start,
      style: NexbitText.body(fontSize: 11.5, weight: FontWeight.w600, color: NexbitColors.muted2),
    );
  }
}

class _AssetRow extends StatelessWidget {
  final TradingPair pair;
  final ValueChanged<TradingPair> onTrade;
  final bool flexible;
  const _AssetRow({required this.pair, required this.onTrade, required this.flexible});

  // Small illustrative bid/ask spread around the pair's reference price —
  // there's no real order book feed behind this page, just like the rest
  // of the mock market data in this app.
  double get _beli => pair.base * 1.0007;
  double get _jual => pair.base * 0.9993;

  @override
  Widget build(BuildContext context) {
    final color = pair.isUp ? NexbitColors.up : NexbitColors.down;
    return InkWell(
      onTap: () => onTrade(pair),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: NexbitColors.lineSoft))),
        child: Row(
          children: [
            _cell(
              PriceAssetTable._colAsset,
              flexible,
              Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: pair.iconColor, shape: BoxShape.circle),
                    child: Text(pair.iconLabel,
                        style: NexbitText.mono(fontSize: 12, weight: FontWeight.w700, color: const Color(0xFF04120E))),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(pair.name,
                            overflow: TextOverflow.ellipsis,
                            style: NexbitText.body(fontSize: 13, weight: FontWeight.w600, color: NexbitColors.text)),
                        Text(pair.id, style: NexbitText.mono(fontSize: 11, color: NexbitColors.muted2)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _cell(
              PriceAssetTable._colPrice,
              flexible,
              Text(formatPrice(_beli, pair.decimals), textAlign: TextAlign.end, style: NexbitText.mono(fontSize: 12.5)),
            ),
            _cell(
              PriceAssetTable._colPrice,
              flexible,
              Text(formatPrice(_jual, pair.decimals), textAlign: TextAlign.end, style: NexbitText.mono(fontSize: 12.5)),
            ),
            _cell(
              PriceAssetTable._colChange,
              flexible,
              Text(pair.change,
                  textAlign: TextAlign.end, style: NexbitText.mono(fontSize: 12.5, weight: FontWeight.w600, color: color)),
            ),
            _cell(
              PriceAssetTable._colTrend,
              flexible,
              Align(
                alignment: Alignment.centerRight,
                child: MiniSparkline(isUp: pair.isUp, seed: pair.id.hashCode),
              ),
            ),
            _cell(
              PriceAssetTable._colAction,
              flexible,
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton(
                  onPressed: () => onTrade(pair),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: NexbitColors.accent,
                    side: const BorderSide(color: NexbitColors.accent),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  child: Text(S.priceTradeButton),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
