import 'package:flutter/material.dart';
import '../../../../core/i18n/strings.dart';
import '../../../../core/theme/nexbit_theme.dart';
import '../../../landing/presentation/widgets/nexbit_buttons.dart';
import '../../domain/models/active_stake.dart';
import '../../domain/models/staking_asset.dart';

/// Read-only detail view for one active stake, with a direct path into
/// the Unstake flow — closing this dialog and immediately opening the
/// confirm dialog, same as the reference design's "Detail" action would.
Future<void> showStakeDetailDialog({
  required BuildContext context,
  required ActiveStake stake,
  required VoidCallback onUnstake,
}) {
  final periodLabel = stake.isLocked ? S.stakingDaysBadge(stake.lockDays) : S.stakingFlexible;
  final totalAmount = stake.amount + stake.reward;

  return showDialog<void>(
    context: context,
    barrierColor: Colors.black.withOpacity(0.6),
    builder: (dialogContext) => Dialog(
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: stake.color, borderRadius: BorderRadius.circular(12)),
                    child: Text(stake.id[0],
                        style: NexbitText.mono(fontSize: 17, weight: FontWeight.w700, color: const Color(0xFF04120E))),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(S.stakingPageTitle(stake.id), style: NexbitText.display(fontSize: 17, weight: FontWeight.w700)),
                        Text(stake.name, style: NexbitText.body(fontSize: 12.5, color: NexbitColors.muted)),
                      ],
                    ),
                  ),
                  Hoverable(
                    hoverScale: 1.1,
                    builder: (context, hovered) => InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => Navigator.of(dialogContext).pop(),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(Icons.close_rounded, size: 20, color: hovered ? NexbitColors.text : NexbitColors.muted),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 6, height: 6, decoration: const BoxDecoration(color: NexbitColors.up, shape: BoxShape.circle)),
                  const SizedBox(width: 5),
                  Text(S.stakingStatusActive, style: NexbitText.body(fontSize: 12, weight: FontWeight.w600, color: NexbitColors.up)),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: NexbitColors.surface2, borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    _row(S.stakingSummaryAmount, '${formatStakeAmount(stake.amount, decimals: stake.amountDecimals)} ${stake.id}'),
                    _row(S.stakingSummaryApy, '${stake.apy.toStringAsFixed(2)}%'),
                    _row(S.stakingSummaryDuration, periodLabel),
                    _row(S.stakingColRewardRunning, '${formatStakeAmount(stake.reward, decimals: stake.rewardDecimals)} ${stake.id}',
                        valueColor: NexbitColors.up),
                    _row(S.stakingSummaryRewardDate, '${S.stakingSummaryRewardDaily} · 12:00 WIB'),
                    if (stake.isLocked) _row(S.stakingColStatus, S.stakingDaysLeft(stake.daysRemaining)),
                    _row(S.stakingSummaryTotal, '${formatStakeAmount(totalAmount, decimals: stake.rewardDecimals)} ${stake.id}',
                        isLast: true, bold: true),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlineButton(label: S.stakingDetailClose, onTap: () => Navigator.of(dialogContext).pop()),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Hoverable(
                      pressScale: 0.97,
                      builder: (context, hovered) => AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        decoration: BoxDecoration(
                          color: NexbitColors.down.withOpacity(hovered ? 0.24 : 0.14),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: NexbitColors.down),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () {
                              Navigator.of(dialogContext).pop();
                              onUnstake();
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              child: Text(S.stakingUnstakeButton,
                                  textAlign: TextAlign.center,
                                  style: NexbitText.body(fontSize: 15, weight: FontWeight.w700, color: NexbitColors.down)),
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

Widget _row(String label, String value, {Color? valueColor, bool isLast = false, bool bold = false}) {
  if (value.isEmpty) return const SizedBox.shrink();
  return Padding(
    padding: EdgeInsets.only(bottom: isLast ? 0 : 10, top: isLast ? 10 : 0),
    child: Column(
      children: [
        if (isLast) const Divider(color: NexbitColors.line, height: 1),
        if (isLast) const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: NexbitText.body(fontSize: 12.5, color: NexbitColors.muted)),
            Text(value,
                style: NexbitText.mono(
                  fontSize: bold ? 14 : 12.5,
                  weight: bold ? FontWeight.w700 : FontWeight.w700,
                  color: valueColor ?? NexbitColors.text,
                )),
          ],
        ),
      ],
    ),
  );
}
