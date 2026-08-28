import 'package:flutter/material.dart';
import '../../../../core/i18n/strings.dart';
import '../../../../core/theme/nexbit_theme.dart';
import '../../../trading/domain/models/trading_pair.dart';
import '../../domain/market_mock_data.dart';
import 'mini_sparkline.dart';

/// The richer asset table on the Market page — price, 24h change, market
/// cap, 24h volume, a 7-day area sparkline, and a Trade action — unlike
/// [PriceAssetTable] (Harga page) which is Beli/Jual-price focused, this
/// one reads as a market-cap/volume/ranking exploration table.
class MarketOverviewTable extends StatelessWidget {
  final List<MarketMockStats> rows;
  final ValueChanged<TradingPair> onTrade;

  const MarketOverviewTable({super.key, required this.rows, required this.onTrade});

  static const _colAsset = 190.0;
  static const _colPrice = 110.0;
  static const _colChange = 90.0;
  static const _colCap = 110.0;
  static const _colVolume = 110.0;
  static const _colTrend = 110.0;
  static const _colAction = 90.0;
  static const _rowPadding = 32.0;
  static const _tableMinWidth =
      _colAsset + _colPrice + _colChange + _colCap + _colVolume + _colTrend + _colAction + _rowPadding;

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
                  _cell(_colAsset, flexible, _HeaderLabel(S.marketColAsset)),
                  _cell(_colPrice, flexible, _HeaderLabel(S.marketColPrice, alignEnd: true)),
                  _cell(_colChange, flexible, _HeaderLabel(S.marketColChange24h, alignEnd: true)),
                  _cell(_colCap, flexible, _HeaderLabel(S.marketColMarketCap, alignEnd: true)),
                  _cell(_colVolume, flexible, _HeaderLabel(S.marketColVolume24h, alignEnd: true)),
                  _cell(_colTrend, flexible, _HeaderLabel(S.marketColChart7d, alignEnd: true)),
                  _cell(_colAction, flexible, const SizedBox.shrink()),
                ],
              ),
            ),
            for (final r in rows) _AssetRow(stats: r, onTrade: onTrade, flexible: flexible),
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
  final MarketMockStats stats;
  final ValueChanged<TradingPair> onTrade;
  final bool flexible;
  const _AssetRow({required this.stats, required this.onTrade, required this.flexible});

  @override
  Widget build(BuildContext context) {
    final pair = stats.pair;
    final color = pair.isUp ? NexbitColors.up : NexbitColors.down;
    return InkWell(
      onTap: () => onTrade(pair),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: NexbitColors.lineSoft))),
        child: Row(
          children: [
            _cell(
              MarketOverviewTable._colAsset,
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
              MarketOverviewTable._colPrice,
              flexible,
              Text(formatPrice(pair.base, pair.decimals),
                  textAlign: TextAlign.end, overflow: TextOverflow.ellipsis, style: NexbitText.mono(fontSize: 12.5)),
            ),
            _cell(
              MarketOverviewTable._colChange,
              flexible,
              Text(pair.change,
                  textAlign: TextAlign.end, style: NexbitText.mono(fontSize: 12.5, weight: FontWeight.w600, color: color)),
            ),
            _cell(
              MarketOverviewTable._colCap,
              flexible,
              Text(compactIdr(stats.marketCap),
                  textAlign: TextAlign.end, overflow: TextOverflow.ellipsis, style: NexbitText.mono(fontSize: 12)),
            ),
            _cell(
              MarketOverviewTable._colVolume,
              flexible,
              Text(compactIdr(stats.volume24h),
                  textAlign: TextAlign.end, overflow: TextOverflow.ellipsis, style: NexbitText.mono(fontSize: 12)),
            ),
            _cell(
              MarketOverviewTable._colTrend,
              flexible,
              Align(
                alignment: Alignment.centerRight,
                child: MiniSparkline(isUp: pair.isUp, seed: pair.id.hashCode, width: 76, height: 28, filled: true),
              ),
            ),
            _cell(
              MarketOverviewTable._colAction,
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
