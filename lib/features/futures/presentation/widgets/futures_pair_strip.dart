import 'package:flutter/material.dart';
import '../../../../core/theme/nexbit_theme.dart';
import '../../domain/models/futures_contract.dart';

/// The horizontal quick-select strip of contracts under the category
/// tabs — click one to switch the whole page (order book, chart,
/// positions mark price, order form) to that contract.
class FuturesPairStrip extends StatelessWidget {
  final List<FuturesContract> contracts;
  final FuturesContract selected;
  final ValueChanged<FuturesContract> onSelect;

  const FuturesPairStrip({super.key, required this.contracts, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final c in contracts) _chip(c),
        ],
      ),
    );
  }

  Widget _chip(FuturesContract c) {
    final active = c.id == selected.id;
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(9),
        onTap: () => onSelect(c),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: active ? NexbitColors.accent.withOpacity(0.08) : Colors.transparent,
            border: Border.all(color: active ? NexbitColors.accent : NexbitColors.line),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: c.iconColor, shape: BoxShape.circle),
                child: Text(c.iconLabel,
                    style: NexbitText.mono(fontSize: 11, weight: FontWeight.w700, color: const Color(0xFF04120E))),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(c.label, style: NexbitText.body(fontSize: 12.5, weight: FontWeight.w700, color: NexbitColors.text)),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(formatUsdt(c.price, c.decimals), style: NexbitText.mono(fontSize: 11.5, color: NexbitColors.muted)),
                      const SizedBox(width: 6),
                      Text(c.change,
                          style: NexbitText.mono(
                              fontSize: 11, weight: FontWeight.w600, color: c.isUp ? NexbitColors.up : NexbitColors.down)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
