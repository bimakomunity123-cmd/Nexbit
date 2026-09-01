import 'package:flutter/material.dart';
import '../../../../core/i18n/strings.dart';
import '../../../../core/theme/nexbit_theme.dart';
import '../../domain/models/futures_position.dart';

/// The Account Info card — Futures Balance (with an eye toggle to hide
/// the figures) and a margin-ratio bar, all recomputed live from the
/// actual open positions instead of static placeholder numbers.
class FuturesAccountInfoCard extends StatefulWidget {
  final List<FuturesPosition> positions;
  final double Function(String contractId) markPriceOf;
  final double startingBalance;
  final double realizedPnl;
  /// True while the real balance/positions are still being fetched for
  /// a logged-in user (see NexbitFuturesPage._loadAccountData) — shows
  /// placeholders instead of startingBalance's default figures, which
  /// would otherwise flash briefly before the real numbers arrive.
  final bool loading;

  const FuturesAccountInfoCard({
    super.key,
    required this.positions,
    required this.markPriceOf,
    this.startingBalance = 1250.0,
    this.realizedPnl = 0,
    this.loading = false,
  });

  @override
  State<FuturesAccountInfoCard> createState() => _FuturesAccountInfoCardState();
}

class _FuturesAccountInfoCardState extends State<FuturesAccountInfoCard> {
  bool _hidden = false;

  @override
  Widget build(BuildContext context) {
    final usedMargin = widget.positions.fold(0.0, (sum, p) => sum + p.margin);
    final unrealizedPnl = widget.positions.fold(0.0, (sum, p) => sum + p.pnl(widget.markPriceOf(p.contract.id)));
    final marginBalance = widget.startingBalance + widget.realizedPnl + unrealizedPnl;
    final availableBalance = marginBalance - usedMargin;
    final marginRatio = marginBalance == 0 ? 0.0 : (usedMargin / marginBalance).clamp(0.0, 1.0);

    String fmt(double v) => widget.loading ? '···' : (_hidden ? '••••••' : '\$${v.toStringAsFixed(2)}');

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
          Text(S.futuresAccountInfo, style: NexbitText.body(fontSize: 13.5, weight: FontWeight.w700)),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(S.futuresBalance, style: NexbitText.body(fontSize: 11.5, color: NexbitColors.muted2)),
              InkWell(
                onTap: () => setState(() => _hidden = !_hidden),
                child: Icon(_hidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    size: 16, color: NexbitColors.muted),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _row(S.futuresAvailableBalance, fmt(availableBalance)),
          _row(S.futuresMarginBalance, fmt(marginBalance)),
          _row(S.futuresUsedMargin, fmt(usedMargin)),
          _row(S.futuresUnrealizedPnl, fmt(unrealizedPnl), color: unrealizedPnl >= 0 ? NexbitColors.up : NexbitColors.down),
          _row(S.futuresRealizedPnl, fmt(widget.realizedPnl)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(S.futuresMarginRatio, style: NexbitText.body(fontSize: 11.5, color: NexbitColors.muted2)),
              Text(widget.loading ? '···' : '${(marginRatio * 100).toStringAsFixed(2)}%',
                  style: NexbitText.mono(fontSize: 12, weight: FontWeight.w600, color: NexbitColors.text)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              // null (indeterminate) while loading doubles as a visible
              // "still fetching" cue instead of a static, possibly-wrong 0%.
              value: widget.loading ? null : marginRatio,
              minHeight: 6,
              backgroundColor: NexbitColors.line,
              valueColor: AlwaysStoppedAnimation(marginRatio > 0.7 ? NexbitColors.down : NexbitColors.accent),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _actionButton(context, S.futuresDeposit)),
              const SizedBox(width: 8),
              Expanded(child: _actionButton(context, S.futuresExchange)),
              const SizedBox(width: 8),
              Expanded(child: _actionButton(context, S.futuresBuy, filled: true)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButton(BuildContext context, String label, {bool filled = false}) {
    return OutlinedButton(
      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.futuresComingSoonSnack), duration: const Duration(seconds: 2)),
      ),
      style: OutlinedButton.styleFrom(
        backgroundColor: filled ? NexbitColors.accent : Colors.transparent,
        foregroundColor: filled ? const Color(0xFF04120E) : NexbitColors.text,
        side: filled ? BorderSide.none : const BorderSide(color: NexbitColors.line),
        padding: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
        textStyle: NexbitText.body(fontSize: 12, weight: FontWeight.w600),
      ),
      child: Text(label),
    );
  }

  Widget _row(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: NexbitText.body(fontSize: 12, color: NexbitColors.muted)),
          Text(value, style: NexbitText.mono(fontSize: 12.5, weight: FontWeight.w600, color: color ?? NexbitColors.text)),
        ],
      ),
    );
  }
}
