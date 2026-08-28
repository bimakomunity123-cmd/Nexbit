import 'package:flutter/material.dart';
import '../../../../core/i18n/strings.dart';
import '../../../../core/theme/nexbit_theme.dart';
import '../../../../core/widgets/nexbit_logo_mark.dart';
import '../../../landing/presentation/widgets/nexbit_buttons.dart';

/// The left sidebar shared by every page in the "staking shell" —
/// Dashboard, My Staking, Transaction History, and Settings — plus the
/// brand mark and a referral card at the bottom, matching the reference
/// design.
class StakingSidebar extends StatelessWidget {
  final bool isMobile;
  final String activeId; // 'dashboard' | 'myStaking' | 'txHistory' | 'settings'
  final VoidCallback onLogoTap;
  final VoidCallback onDashboardTap;
  final VoidCallback onMyStakingTap;
  final VoidCallback? onTxHistoryTap;
  final VoidCallback? onSettingsTap;

  const StakingSidebar({
    super.key,
    required this.isMobile,
    required this.activeId,
    required this.onLogoTap,
    required this.onDashboardTap,
    required this.onMyStakingTap,
    this.onTxHistoryTap,
    this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    final items = <(String, IconData, String, VoidCallback?)>[
      ('dashboard', Icons.dashboard_outlined, S.stakingSidebarDashboard, onDashboardTap),
      ('myStaking', Icons.savings_outlined, S.stakingSidebarMyStaking, onMyStakingTap),
      ('txHistory', Icons.receipt_long_outlined, S.stakingSidebarTxHistory, onTxHistoryTap),
      ('settings', Icons.settings_outlined, S.stakingSidebarSettings, onSettingsTap),
    ];

    final content = SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 4),
          Hoverable(
            hoverScale: 1.03,
            builder: (context, hovered) => InkWell(
              onTap: onLogoTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                child: const NexbitLogoLockup(markSize: 30, borderRadius: 9, wordmarkFontSize: 19, spacing: 10),
              ),
            ),
          ),
          const SizedBox(height: 16),
          for (final item in items)
            _SidebarItem(icon: item.$2, label: item.$3, active: item.$1 == activeId, onTap: item.$4 ?? () {}),
          const SizedBox(height: 28),
          const _ReferralCard(),
          const SizedBox(height: 12),
        ],
      ),
    );

    if (isMobile) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: NexbitColors.line))),
        child: content,
      );
    }
    return Container(
      width: 240,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(border: Border(right: BorderSide(color: NexbitColors.line))),
      child: content,
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _SidebarItem({required this.icon, required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Hoverable(
        hoverScale: 1.0,
        builder: (context, hovered) => InkWell(
          borderRadius: BorderRadius.circular(9),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: active ? NexbitColors.accent.withOpacity(0.12) : (hovered ? NexbitColors.surface2 : null),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Row(
              children: [
                Icon(icon, size: 18, color: active ? NexbitColors.accent : NexbitColors.muted),
                const SizedBox(width: 12),
                Text(label,
                    style: NexbitText.body(
                        fontSize: 13.5, weight: active ? FontWeight.w600 : FontWeight.w500, color: active ? NexbitColors.text : NexbitColors.muted)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReferralCard extends StatelessWidget {
  const _ReferralCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NexbitColors.accent.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: NexbitColors.accent.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(S.stakingReferralHeading, style: NexbitText.body(fontSize: 13.5, weight: FontWeight.w700, color: NexbitColors.accent)),
          const SizedBox(height: 4),
          Text(S.stakingReferralSubtitle, style: NexbitText.body(fontSize: 11.5, height: 1.4)),
          const SizedBox(height: 14),
          Center(
            child: Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(gradient: NexbitColors.accentGradient, borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.card_giftcard_rounded, size: 24, color: const Color(0xFF04120E).withOpacity(0.65)),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: Hoverable(
              hoverScale: 1.0,
              pressScale: 0.97,
              builder: (context, hovered) => InkWell(
                borderRadius: BorderRadius.circular(9),
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: hovered ? NexbitColors.accent.withOpacity(0.16) : Colors.transparent,
                    border: Border.all(color: NexbitColors.accent),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Text(S.stakingReferralButton,
                      textAlign: TextAlign.center,
                      style: NexbitText.body(fontSize: 12.5, weight: FontWeight.w700, color: NexbitColors.accent)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
