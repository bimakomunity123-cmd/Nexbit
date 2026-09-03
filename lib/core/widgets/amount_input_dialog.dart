import 'package:flutter/material.dart';
import '../i18n/strings.dart';
import '../theme/nexbit_theme.dart';

/// Which direction showDepositWithdrawDialog is currently set to.
enum DepositWithdrawDirection { deposit, withdraw }

/// A small reusable "type an amount, confirm" dialog with a Deposit/
/// Withdraw direction toggle — used by the demo top-up/take-out flows
/// (Futures margin balance, Spot IDR wallet; see NexbitFuturesPage/
/// NexbitTradingPage). Shows a spinner on Confirm while the active
/// direction's callback is in flight, and surfaces the error message it
/// returns inline instead of closing; a null return means success,
/// closing the dialog itself.
Future<void> showDepositWithdrawDialog({
  required BuildContext context,
  required String depositTitle,
  required String withdrawTitle,
  required String unit,
  String? depositNotice,
  String? withdrawNotice,
  required Future<String?> Function(double amount) onDeposit,
  required Future<String?> Function(double amount) onWithdraw,
}) {
  final controller = TextEditingController();
  var direction = DepositWithdrawDirection.deposit;
  bool loading = false;
  String? error;

  Future<void> submit(StateSetter setDialogState, BuildContext dialogContext) async {
    final amount = double.tryParse(controller.text.replaceAll(',', '')) ?? 0;
    if (amount <= 0) {
      setDialogState(() => error = S.depositAmountRequired);
      return;
    }
    setDialogState(() {
      loading = true;
      error = null;
    });
    final failureMessage = direction == DepositWithdrawDirection.deposit
        ? await onDeposit(amount)
        : await onWithdraw(amount);
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
        final isDeposit = direction == DepositWithdrawDirection.deposit;
        final title = isDeposit ? depositTitle : withdrawTitle;
        final notice = isDeposit ? depositNotice : withdrawNotice;

        Widget directionTab(DepositWithdrawDirection value, String label) {
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: NexbitColors.line)),
          title: Text(title, style: NexbitText.body(fontSize: 16, weight: FontWeight.w700, color: NexbitColors.text)),
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
                      directionTab(DepositWithdrawDirection.deposit, S.futuresDeposit),
                      const SizedBox(width: 3),
                      directionTab(DepositWithdrawDirection.withdraw, S.withdrawLabel),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                if (notice != null) ...[
                  Text(notice, style: NexbitText.body(fontSize: 12, height: 1.4, color: NexbitColors.muted)),
                  const SizedBox(height: 14),
                ],
                Text(S.formAmount, style: NexbitText.body(fontSize: 12.5, color: NexbitColors.muted)),
                const SizedBox(height: 6),
                TextField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  autofocus: true,
                  style: NexbitText.mono(fontSize: 14, color: NexbitColors.text),
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: NexbitText.mono(fontSize: 14, color: NexbitColors.muted2),
                    suffixText: unit,
                    suffixStyle: NexbitText.body(fontSize: 12.5, color: NexbitColors.muted2),
                    filled: true,
                    fillColor: NexbitColors.surface2,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: const BorderSide(color: NexbitColors.line)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: const BorderSide(color: NexbitColors.line)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: const BorderSide(color: NexbitColors.accent)),
                  ),
                ),
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
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: NexbitColors.accent),
                    )
                  : Text(
                      isDeposit ? S.futuresDeposit : S.withdrawLabel,
                      style: NexbitText.body(fontSize: 13.5, weight: FontWeight.w700, color: NexbitColors.accent),
                    ),
            ),
          ],
        );
      },
    ),
  );
}
