import 'package:flutter/material.dart';
import '../i18n/strings.dart';
import '../theme/nexbit_theme.dart';

/// A small reusable "type an amount, confirm" dialog — currently used
/// by the demo Deposit flows (Futures margin balance, Spot IDR wallet
/// top-up; see NexbitFuturesPage/NexbitTradingPage). Shows a spinner on
/// Confirm while [onConfirm] is in flight and surfaces the error
/// message it returns inline instead of closing; a null return means
/// success, closing the dialog itself.
Future<void> showAmountInputDialog({
  required BuildContext context,
  required String title,
  required String unit,
  String? demoNotice,
  required Future<String?> Function(double amount) onConfirm,
}) {
  final controller = TextEditingController();
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
    final failureMessage = await onConfirm(amount);
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
      builder: (dialogContext, setDialogState) => AlertDialog(
        backgroundColor: NexbitColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: NexbitColors.line)),
        title: Text(title, style: NexbitText.body(fontSize: 16, weight: FontWeight.w700, color: NexbitColors.text)),
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (demoNotice != null) ...[
                Text(demoNotice, style: NexbitText.body(fontSize: 12, height: 1.4, color: NexbitColors.muted)),
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
                : Text(S.futuresDeposit, style: NexbitText.body(fontSize: 13.5, weight: FontWeight.w700, color: NexbitColors.accent)),
          ),
        ],
      ),
    ),
  );
}
