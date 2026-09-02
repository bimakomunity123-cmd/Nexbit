import 'package:flutter/material.dart';
import '../../features/trading/domain/models/trading_pair.dart' show formatPrice;
import '../i18n/strings.dart';
import '../market_data/live_pricing.dart';
import '../theme/nexbit_theme.dart';

/// Which direction the Exchange dialog currently moves balance.
enum ExchangeDirection { toFutures, toSpot }

/// The Spot<->Futures Exchange dialog — lets a logged-in user move
/// virtual balance between the Spot IDR wallet and the Futures USDT
/// margin account, converted at the live IDR/USDT rate (see
/// live_pricing.dart's approxIdrPerUsdt). Both onConfirm callbacks
/// return null on success or an error message string on failure — same
/// pattern as showAmountInputDialog.
Future<void> showExchangeDialog({
  required BuildContext context,
  required Future<String?> Function(double idrAmount, double rate) onExchangeToFutures,
  required Future<String?> Function(double usdtAmount, double rate) onExchangeToSpot,
}) {
  final controller = TextEditingController();
  var direction = ExchangeDirection.toFutures;
  bool loading = false;
  String? error;

  Future<void> submit(StateSetter setDialogState, BuildContext dialogContext) async {
    final amount = double.tryParse(controller.text.replaceAll(',', '')) ?? 0;
    if (amount <= 0) {
      setDialogState(() => error = S.exchangeAmountRequired);
      return;
    }
    setDialogState(() {
      loading = true;
      error = null;
    });
    final rate = approxIdrPerUsdt();
    final failureMessage = direction == ExchangeDirection.toFutures
        ? await onExchangeToFutures(amount, rate)
        : await onExchangeToSpot(amount, rate);
    if (!dialogContext.mounted) return;
    if (failureMessage == null) {
      Navigator.of(dialogContext).pop();
    } else {
      setDialogState(() {
        loading = false;
        error = failureMessage;
      });
    }
  }

  return showDialog<void>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setDialogState) {
        final rate = approxIdrPerUsdt();
        final amount = double.tryParse(controller.text.replaceAll(',', '')) ?? 0;
        final toFutures = direction == ExchangeDirection.toFutures;
        final fromUnit = toFutures ? 'IDR' : 'USDT';
        final toUnit = toFutures ? 'USDT' : 'IDR';
        final convertedText = amount <= 0
            ? '—'
            : toFutures
                ? (rate > 0 ? (amount / rate).toStringAsFixed(2) : '—')
                : formatPrice(amount * rate, 0);

        Widget directionTab(ExchangeDirection value, String label) {
          final selected = direction == value;
          return Expanded(
            child: GestureDetector(
              onTap: loading
                  ? null
                  : () => setDialogState(() {
                        direction = value;
                        error = null;
                      }),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: selected ? NexbitColors.accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(7),
                ),
                alignment: Alignment.center,
                child: Text(
                  label,
                  style: NexbitText.body(
                    fontSize: 12,
                    weight: FontWeight.w700,
                    color: selected ? const Color(0xFF04120E) : NexbitColors.muted,
                  ),
                ),
              ),
            ),
          );
        }

        return AlertDialog(
          backgroundColor: NexbitColors.surface,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14), side: const BorderSide(color: NexbitColors.line)),
          title: Text(S.exchangeTitle,
              style: NexbitText.body(fontSize: 16, weight: FontWeight.w700, color: NexbitColors.text)),
          content: SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: NexbitColors.surface2,
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(color: NexbitColors.line),
                  ),
                  child: Row(
                    children: [
                      directionTab(ExchangeDirection.toFutures, S.exchangeToFutures),
                      const SizedBox(width: 3),
                      directionTab(ExchangeDirection.toSpot, S.exchangeToSpot),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text('${S.formAmount} ($fromUnit)', style: NexbitText.body(fontSize: 12.5, color: NexbitColors.muted)),
                const SizedBox(height: 6),
                TextField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  autofocus: true,
                  style: NexbitText.mono(fontSize: 14, color: NexbitColors.text),
                  onChanged: (_) => setDialogState(() {}),
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: NexbitText.mono(fontSize: 14, color: NexbitColors.muted2),
                    suffixText: fromUnit,
                    suffixStyle: NexbitText.body(fontSize: 12.5, color: NexbitColors.muted2),
                    filled: true,
                    fillColor: NexbitColors.surface2,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: const BorderSide(color: NexbitColors.line)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: const BorderSide(color: NexbitColors.line)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: const BorderSide(color: NexbitColors.accent)),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(S.exchangeYouReceive, style: NexbitText.body(fontSize: 12, color: NexbitColors.muted)),
                    Text('$convertedText $toUnit',
                        style: NexbitText.mono(fontSize: 13, weight: FontWeight.w700, color: NexbitColors.accent)),
                  ],
                ),
                const SizedBox(height: 10),
                Text(S.exchangeRateNotice, style: NexbitText.body(fontSize: 11, height: 1.4, color: NexbitColors.muted2)),
                if (error != null) ...[
                  const SizedBox(height: 10),
                  Text(error!, style: NexbitText.body(fontSize: 12.5, color: NexbitColors.down)),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: loading ? null : () => Navigator.of(dialogContext).pop(),
              child: Text(S.accountCancel, style: NexbitText.body(fontSize: 13.5, color: NexbitColors.muted)),
            ),
            TextButton(
              onPressed: loading ? null : () => submit(setDialogState, dialogContext),
              child: loading
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: NexbitColors.accent))
                  : Text(S.futuresExchange, style: NexbitText.body(fontSize: 13.5, weight: FontWeight.w700, color: NexbitColors.accent)),
            ),
          ],
        );
      },
    ),
  );
}
