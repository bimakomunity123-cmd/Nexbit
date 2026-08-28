import 'package:flutter/material.dart';
import '../../../../core/i18n/strings.dart';
import '../../../../core/theme/nexbit_theme.dart';
import '../../../landing/presentation/widgets/nexbit_buttons.dart';
import '../../domain/models/staking_asset.dart';

/// The "Konfirmasi Staking" modal — summarizes the stake before it's
/// submitted. Returns `true` via [Navigator.pop] if the user confirms.
Future<bool?> showStakingConfirmDialog({
  required BuildContext context,
  required StakingAsset asset,
  required double amount,
  required StakingDuration duration,
}) {
  final reward = amount * duration.apy / 100 * (duration.days / 365);
  final periodLabel = duration.id == 'flexible' ? S.stakingFlexible : S.stakingDaysBadge(duration.days);

  return showDialog<bool>(
    context: context,
    barrierColor: Colors.black.withOpacity(0.6),
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      // Tighter insets than the Material default (40px/side) so the
      // dialog still has room to breathe on narrow phone widths instead
      // of squeezing its buttons' text onto two lines.
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: NexbitColors.panel,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: NexbitColors.line),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 60, offset: const Offset(0, 24))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Hoverable(
                  hoverScale: 1.1,
                  builder: (context, hovered) => InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => Navigator.of(context).pop(false),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(Icons.close_rounded, size: 20, color: hovered ? NexbitColors.text : NexbitColors.muted),
                    ),
                  ),
                ),
              ),
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(gradient: NexbitColors.accentGradient, shape: BoxShape.circle),
                child: Icon(Icons.fact_check_outlined, size: 26, color: const Color(0xFF04120E).withOpacity(0.65)),
              ),
              const SizedBox(height: 16),
              Text(S.stakingConfirmTitle, style: NexbitText.display(fontSize: 19, weight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(S.stakingConfirmSubtitle,
                  textAlign: TextAlign.center, style: NexbitText.body(fontSize: 13, height: 1.5)),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: NexbitColors.surface2, borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    _row(S.stakingColAsset, asset.id),
                    _row(S.stakingSummaryAmount, '${formatStakeAmount(amount)} ${asset.id}'),
                    _row(S.stakingSummaryDuration, periodLabel),
                    _row(S.stakingSummaryApy, '${duration.apy.toStringAsFixed(2)}%'),
                    _row(S.stakingSummaryReward, '${formatStakeAmount(reward)} ${asset.id}', valueColor: NexbitColors.accent),
                    _row(S.stakingSummaryRewardDate, S.stakingSummaryRewardDaily, isLast: true),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: NexbitColors.accent.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: NexbitColors.accent.withOpacity(0.25)),
                ),
                child: Text(S.stakingConfirmNote,
                    style: NexbitText.body(fontSize: 12, height: 1.5, color: NexbitColors.text)),
              ),
              const SizedBox(height: 22),
              // Side-by-side normally, but the buttons' fixed horizontal
              // padding doesn't leave enough room for their labels once
              // the dialog itself is squeezed on narrow phone widths —
              // stack them instead of letting the text wrap in that case.
              LayoutBuilder(
                builder: (context, constraints) {
                  final cancelBtn = OutlineButton(label: S.stakingCancel, onTap: () => Navigator.of(context).pop(false));
                  final confirmBtn = PrimaryButton(label: S.stakingConfirm, onTap: () => Navigator.of(context).pop(true));
                  if (constraints.maxWidth < 300) {
                    return Column(
                      children: [
                        SizedBox(width: double.infinity, child: confirmBtn),
                        const SizedBox(height: 10),
                        SizedBox(width: double.infinity, child: cancelBtn),
                      ],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(child: cancelBtn),
                      const SizedBox(width: 12),
                      Expanded(child: confirmBtn),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _row(String label, String value, {Color? valueColor, bool isLast = false}) {
  return Padding(
    padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: NexbitText.body(fontSize: 12.5, color: NexbitColors.muted)),
        Text(value,
            style: NexbitText.mono(fontSize: 12.5, weight: FontWeight.w700, color: valueColor ?? NexbitColors.text)),
      ],
    ),
  );
}
