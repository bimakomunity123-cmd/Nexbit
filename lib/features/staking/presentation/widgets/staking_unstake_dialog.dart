import 'package:flutter/material.dart';
import '../../../../core/i18n/strings.dart';
import '../../../../core/theme/nexbit_theme.dart';
import '../../../landing/presentation/widgets/nexbit_buttons.dart';
import '../../domain/models/active_stake.dart';
import '../../domain/models/staking_asset.dart';

/// Confirms unstaking one active stake. Locked (non-flexible) stakes get
/// an early-unstake penalty warning instead of the plain flexible note —
/// a real staking product would apply this, so the demo models it too.
/// Returns `true` via [Navigator.pop] if the user confirms.
Future<bool?> showUnstakeConfirmDialog({
  required BuildContext context,
  required ActiveStake stake,
}) {
  return showDialog<bool>(
    context: context,
    barrierColor: Colors.black.withOpacity(0.6),
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
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
                decoration: BoxDecoration(color: NexbitColors.down.withOpacity(0.14), shape: BoxShape.circle),
                child: const Icon(Icons.logout_rounded, size: 26, color: NexbitColors.down),
              ),
              const SizedBox(height: 16),
              Text(S.stakingUnstakeConfirmTitle, style: NexbitText.display(fontSize: 19, weight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(S.stakingUnstakeConfirmSubtitle,
                  textAlign: TextAlign.center, style: NexbitText.body(fontSize: 13, height: 1.5)),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: NexbitColors.surface2, borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    _row(S.stakingColAsset, stake.id),
                    _row(S.stakingSummaryAmount, '${formatStakeAmount(stake.amount, decimals: stake.amountDecimals)} ${stake.id}'),
                    _row(S.stakingColRewardRunning, '${formatStakeAmount(stake.reward, decimals: stake.rewardDecimals)} ${stake.id}',
                        isLast: true, valueColor: NexbitColors.up),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (stake.isLocked ? const Color(0xFFF3BA2F) : NexbitColors.accent).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: (stake.isLocked ? const Color(0xFFF3BA2F) : NexbitColors.accent).withOpacity(0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(stake.isLocked ? Icons.warning_amber_rounded : Icons.info_outline,
                        size: 17, color: stake.isLocked ? const Color(0xFFF3BA2F) : NexbitColors.accent),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        stake.isLocked ? S.stakingUnstakeWarningLocked(stake.daysRemaining) : S.stakingUnstakeInfoFlexible,
                        style: NexbitText.body(fontSize: 12, height: 1.5, color: NexbitColors.text),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(child: OutlineButton(label: S.stakingCancel, onTap: () => Navigator.of(context).pop(false))),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Hoverable(
                      pressScale: 0.97,
                      builder: (context, hovered) => AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        decoration: BoxDecoration(
                          color: hovered ? NexbitColors.down.withOpacity(0.85) : NexbitColors.down,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () => Navigator.of(context).pop(true),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              child: Text(S.stakingUnstakeConfirmCta,
                                  textAlign: TextAlign.center,
                                  style: NexbitText.body(fontSize: 14, weight: FontWeight.w700, color: Colors.white)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
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
