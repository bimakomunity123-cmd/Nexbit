import 'package:flutter/material.dart';
import '../../../../core/theme/nexbit_theme.dart';
import '../../../trading/domain/models/trading_pair.dart';
import 'mini_sparkline.dart';

/// One of the three "Top Gainer / Highest Volume / Most Popular" cards
/// at the top of the price page.
class MarketHighlightCard extends StatelessWidget {
  final String title;
  final TradingPair pair;
  final String valueLabel;

  const MarketHighlightCard({
    super.key,
    required this.title,
    required this.pair,
    required this.valueLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NexbitColors.panel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: NexbitColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: NexbitText.body(fontSize: 12.5, weight: FontWeight.w600, color: NexbitColors.accent)),
          const SizedBox(height: 12),
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
                        style: NexbitText.body(fontSize: 13.5, weight: FontWeight.w700, color: NexbitColors.text)),
                    Text(valueLabel, style: NexbitText.mono(fontSize: 12, color: NexbitColors.muted2)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(pair.change,
                      style: NexbitText.mono(
                          fontSize: 12.5,
                          weight: FontWeight.w600,
                          color: pair.isUp ? NexbitColors.up : NexbitColors.down)),
                  const SizedBox(height: 4),
                  MiniSparkline(isUp: pair.isUp, seed: pair.id.hashCode, width: 56, height: 18),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
