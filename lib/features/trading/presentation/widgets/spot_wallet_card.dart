import 'package:flutter/material.dart';
import '../../../../core/i18n/strings.dart';
import '../../../../core/theme/nexbit_theme.dart';
import '../../domain/models/trading_pair.dart';

/// A single asset holding — asset id + quantity held. Estimated IDR
/// value is computed by the card itself via [SpotWalletCard.priceOf].
class SpotHoldingEntry {
  final String assetId;
  final double quantity;
  const SpotHoldingEntry({required this.assetId, required this.quantity});
}

/// Compact wallet card for the Trading (Spot) page — real IDR balance and
/// holdings fetched from the backend for a logged-in user, with an eye
/// toggle to hide the figures (same pattern as Futures' Account Info
/// card). Guests never see this at all — the page only renders it once
/// logged in, same as Futures gates its own Account Info card.
class SpotWalletCard extends StatefulWidget {
  final double idrBalance;
  final List<SpotHoldingEntry> holdings;
  final double Function(String assetId) priceOf;

  const SpotWalletCard({
    super.key,
    required this.idrBalance,
    required this.holdings,
    required this.priceOf,
  });

  @override
  State<SpotWalletCard> createState() => _SpotWalletCardState();
}

class _SpotWalletCardState extends State<SpotWalletCard> {
  bool _hidden = false;

  @override
  Widget build(BuildContext context) {
    final holdingsValue = widget.holdings.fold<double>(0, (sum, h) => sum + h.quantity * widget.priceOf(h.assetId));
    final portfolioValue = widget.idrBalance + holdingsValue;
    String fmt(double v) => _hidden ? '••••••' : 'Rp${formatPrice(v, 0)}';

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(S.spotWalletHeading, style: NexbitText.body(fontSize: 13.5, weight: FontWeight.w700)),
              InkWell(
                onTap: () => setState(() => _hidden = !_hidden),
                child: Icon(_hidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    size: 16, color: NexbitColors.muted),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _row(S.spotWalletBalance, fmt(widget.idrBalance)),
          _row(S.spotWalletPortfolioValue, fmt(portfolioValue)),
          const SizedBox(height: 10),
          const Divider(height: 1, color: NexbitColors.lineSoft),
          const SizedBox(height: 10),
          Text(S.spotWalletHoldingsHeading, style: NexbitText.body(fontSize: 11.5, color: NexbitColors.muted2)),
          const SizedBox(height: 8),
          if (widget.holdings.isEmpty)
            Text(S.spotWalletNoHoldings, style: NexbitText.body(fontSize: 12, color: NexbitColors.muted2))
          else
            ...widget.holdings.map((h) => _holdingRow(h)),
        ],
      ),
    );
  }

  Widget _holdingRow(SpotHoldingEntry h) {
    final value = h.quantity * widget.priceOf(h.assetId);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(h.assetId, style: NexbitText.body(fontSize: 12.5, weight: FontWeight.w600)),
          Text(
            _hidden ? '••••••' : '${h.quantity.toStringAsFixed(h.quantity < 1 ? 6 : 4)}  ·  Rp${formatPrice(value, 0)}',
            style: NexbitText.mono(fontSize: 11.5, color: NexbitColors.muted),
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
          Text(value, style: NexbitText.mono(fontSize: 12.5, weight: FontWeight.w600, color: NexbitColors.text)),
        ],
      ),
    );
  }
}
