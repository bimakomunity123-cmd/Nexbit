import 'package:flutter/material.dart';
import '../../../../core/i18n/strings.dart';
import '../../../../core/theme/nexbit_theme.dart';
import '../../domain/models/futures_contract.dart';

/// The "Contract Details" card at the bottom of the order-form column —
/// Expiration Date/Index Price/Mark Price always visible, with a
/// Show/Hide toggle revealing a couple more specs, same shape as every
/// real exchange's per-contract info panel.
class FuturesContractDetailsCard extends StatefulWidget {
  final FuturesContract contract;
  const FuturesContractDetailsCard({super.key, required this.contract});

  @override
  State<FuturesContractDetailsCard> createState() => _FuturesContractDetailsCardState();
}

class _FuturesContractDetailsCardState extends State<FuturesContractDetailsCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.contract;
    // Index price tracks the underlying spot market rather than this
    // contract's own last trade, so it drifts a hair from Mark Price —
    // same as on a real exchange (no live spot feed behind it here, just
    // a small stable offset seeded by the contract id).
    final indexPrice = c.price * (1 - ((c.id.hashCode % 7) - 3) / 10000);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NexbitColors.panel,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: NexbitColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${S.futuresContractDetails} ${c.label}', style: NexbitText.body(fontSize: 13.5, weight: FontWeight.w700)),
          const SizedBox(height: 12),
          _row(S.futuresExpirationDate, S.futuresPerpetualValue),
          _row(S.futuresIndexPrice, formatUsdt(indexPrice, c.decimals)),
          _row(S.futuresMarkPrice, formatUsdt(c.price, c.decimals)),
          if (_expanded) ...[
            _row(S.futuresContractSize, '1 ${c.id}'),
            _row(S.futuresMaintenanceMargin, '0.50%'),
            _row(S.futuresStatFundingRate, '0.01%'),
          ],
          const SizedBox(height: 4),
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_expanded ? S.futuresShowLess : S.futuresShowMore,
                      style: NexbitText.body(fontSize: 12, weight: FontWeight.w600, color: NexbitColors.accent)),
                  Icon(_expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, size: 16, color: NexbitColors.accent),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: NexbitText.body(fontSize: 12, color: NexbitColors.muted)),
          Text(value, style: NexbitText.mono(fontSize: 12.5, weight: FontWeight.w600)),
        ],
      ),
    );
  }
}
