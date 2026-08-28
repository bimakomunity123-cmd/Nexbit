import 'package:flutter/material.dart';
import '../../../../core/i18n/app_locale.dart';
import '../../../../core/i18n/strings.dart';
import '../../../../core/theme/nexbit_theme.dart';
import '../../../landing/presentation/widgets/network_background.dart';
import '../../../landing/presentation/widgets/nexbit_buttons.dart';
import '../../domain/models/active_stake.dart';
import '../../domain/models/staking_asset.dart';
import '../widgets/staking_page_header.dart';
import '../widgets/staking_reward_donut.dart';
import '../widgets/staking_sidebar.dart';
import '../widgets/staking_stake_detail_dialog.dart';
import '../widgets/staking_unstake_dialog.dart';
import 'nexbit_staking_dashboard_page.dart';
import 'nexbit_staking_marketplace_page.dart';
import 'nexbit_staking_settings_page.dart';
import 'nexbit_staking_transaction_history_page.dart';

/// The "My Staking Portfolio" dashboard reached after a successful stake
/// confirmation — a distinct sidebar layout from the rest of the site
/// (matching the reference design), but reusing the same design tokens.
class NexbitStakingPortfolioPage extends StatefulWidget {
  const NexbitStakingPortfolioPage({super.key});

  @override
  State<NexbitStakingPortfolioPage> createState() => _NexbitStakingPortfolioPageState();
}

class _NexbitStakingPortfolioPageState extends State<NexbitStakingPortfolioPage> {
  // Mutable copy of the seed data so Unstake can actually remove a row —
  // this is the source of truth for both the table and the stat cards.
  late final List<ActiveStake> _stakes = List.of(kSeedActiveStakes);

  Future<void> _handleDetail(ActiveStake stake) {
    return showStakeDetailDialog(
      context: context,
      stake: stake,
      onUnstake: () => _handleUnstake(stake),
    );
  }

  Future<void> _handleUnstake(ActiveStake stake) async {
    final confirmed = await showUnstakeConfirmDialog(context: context, stake: stake);
    if (confirmed != true || !mounted) return;
    setState(() => _stakes.removeWhere((s) => s.id == stake.id));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: NexbitColors.surface2,
        behavior: SnackBarBehavior.floating,
        content: Text(
          S.stakingUnstakeSuccessMessage(formatStakeAmount(stake.amount, decimals: stake.amountDecimals), stake.id),
          style: NexbitText.body(fontSize: 13, color: NexbitColors.text),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    void openDashboard() {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const NexbitStakingDashboardPage()),
      );
    }

    void openTxHistory() {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const NexbitStakingTransactionHistoryPage()),
      );
    }

    void openSettings() {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const NexbitStakingSettingsPage()),
      );
    }

    void openMarketplace() {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const NexbitStakingMarketplacePage()),
      );
    }

    return ValueListenableBuilder<AppLocale>(
      valueListenable: appLocale,
      builder: (context, locale, _) => Scaffold(
        backgroundColor: NexbitColors.bg,
        body: Stack(
          children: [
            const Positioned.fill(child: NetworkBackground()),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < kNexbitMobileBreakpoint;
                  final sidebar = StakingSidebar(
                    isMobile: isMobile,
                    activeId: 'myStaking',
                    onLogoTap: () => Navigator.of(context).popUntil((r) => r.isFirst),
                    onDashboardTap: openDashboard,
                    onMyStakingTap: () {},
                    onTxHistoryTap: openTxHistory,
                    onSettingsTap: openSettings,
                  );
                  final content = _MainContent(
                    isMobile: isMobile,
                    stakes: _stakes,
                    onOpenMarketplace: openMarketplace,
                    onDetail: _handleDetail,
                    onUnstake: _handleUnstake,
                  );
                  return isMobile
                      ? SingleChildScrollView(child: Column(children: [sidebar, content]))
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            sidebar,
                            Expanded(child: SingleChildScrollView(child: content)),
                          ],
                        );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MainContent extends StatelessWidget {
  final bool isMobile;
  final List<ActiveStake> stakes;
  final VoidCallback onOpenMarketplace;
  final ValueChanged<ActiveStake> onDetail;
  final ValueChanged<ActiveStake> onUnstake;

  const _MainContent({
    required this.isMobile,
    required this.stakes,
    required this.onOpenMarketplace,
    required this.onDetail,
    required this.onUnstake,
  });

  @override
  Widget build(BuildContext context) {
    final totalStakedUsd = stakes.fold<double>(0, (sum, s) => sum + s.amountUsd);
    final weightedApy = totalStakedUsd == 0
        ? 0.0
        : stakes.fold<double>(0, (sum, s) => sum + s.amountUsd * s.apy) / totalStakedUsd;

    return Padding(
      padding: EdgeInsets.all(isMobile ? 18 : 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StakingPageHeader(title: S.stakingPortfolioHeading, subtitle: S.stakingPortfolioSubheading, isMobile: isMobile),
          const SizedBox(height: 22),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              // Total Staked and Active Stakes reflect the live table —
              // unstaking updates them immediately. Total Rewards is a
              // separate historical figure (reward already paid out over
              // time), so it stays put when a stake is closed.
              _StatCard(label: S.stakingStatTotalStaked, value: '\$${formatStakeAmount(totalStakedUsd)}'),
              _StatCard(label: S.stakingStatTotalRewards, value: r'$184.52', valueColor: NexbitColors.accent),
              _StatCard(label: S.stakingStatEstimatedApy, value: '${weightedApy.toStringAsFixed(2)}%'),
              _StatCard(label: S.stakingStatActiveStakes, value: '${stakes.length}'),
            ],
          ),
          const SizedBox(height: 26),
          Text(S.stakingActiveListHeading, style: NexbitText.body(fontSize: 15, weight: FontWeight.w700, color: NexbitColors.text)),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 900;
              final table = _ActiveStakesTable(
                stakes: stakes,
                onOpenMarketplace: onOpenMarketplace,
                onDetail: onDetail,
                onUnstake: onUnstake,
              );
              const donut = _RewardDonutCard();
              if (!wide) {
                return Column(children: [table, const SizedBox(height: 18), donut]);
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 7, child: table),
                  const SizedBox(width: 18),
                  Expanded(flex: 3, child: donut),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _StatCard({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NexbitColors.panel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: NexbitColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: NexbitText.body(fontSize: 12, color: NexbitColors.muted)),
          const SizedBox(height: 8),
          Text(value, style: NexbitText.display(fontSize: 21, weight: FontWeight.w700, color: valueColor ?? NexbitColors.text)),
        ],
      ),
    );
  }
}

class _ActiveStakesTable extends StatelessWidget {
  final List<ActiveStake> stakes;
  final VoidCallback onOpenMarketplace;
  final ValueChanged<ActiveStake> onDetail;
  final ValueChanged<ActiveStake> onUnstake;

  const _ActiveStakesTable({
    required this.stakes,
    required this.onOpenMarketplace,
    required this.onDetail,
    required this.onUnstake,
  });

  @override
  Widget build(BuildContext context) {
    if (stakes.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
        decoration: BoxDecoration(
          color: NexbitColors.panel,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: NexbitColors.line),
        ),
        child: Column(
          children: [
            Icon(Icons.savings_outlined, size: 34, color: NexbitColors.muted2),
            const SizedBox(height: 14),
            Text(S.stakingEmptyActiveStakes, style: NexbitText.body(fontSize: 13, color: NexbitColors.muted)),
            const SizedBox(height: 18),
            PrimaryButton(label: S.stakingCtaPrimary, onTap: onOpenMarketplace),
          ],
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: NexbitColors.panel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: NexbitColors.line),
      ),
      // The horizontal scroller must hand its child a *bounded* width
      // (SingleChildScrollView otherwise offers infinite width along its
      // scroll axis) — LayoutBuilder + a fixed SizedBox at max(available,
      // 720) gives the inner Row/Expanded columns something concrete to
      // lay out against, while still scrolling on narrow viewports.
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tableWidth = constraints.maxWidth > 720 ? constraints.maxWidth : 720.0;
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: tableWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                    child: Row(
                      children: [
                        Expanded(flex: 3, child: _h(S.stakingColAsset)),
                        Expanded(flex: 3, child: _h(S.stakingColStakeAmount)),
                        Expanded(flex: 2, child: _h(S.stakingSummaryApy)),
                        Expanded(flex: 3, child: _h(S.stakingColRewardRunning)),
                        Expanded(flex: 3, child: _h(S.stakingColRewardDate)),
                        Expanded(flex: 2, child: _h(S.stakingColStatus)),
                        Expanded(flex: 3, child: _h(S.stakingColAction)),
                      ],
                    ),
                  ),
                  for (final s in stakes)
                    _StakeRow(stake: s, onDetail: () => onDetail(s), onUnstake: () => onUnstake(s)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _h(String text) => Text(text, style: NexbitText.body(fontSize: 11, weight: FontWeight.w600, color: NexbitColors.muted2));
}

class _StakeRow extends StatelessWidget {
  final ActiveStake stake;
  final VoidCallback onDetail;
  final VoidCallback onUnstake;
  const _StakeRow({required this.stake, required this.onDetail, required this.onUnstake});

  @override
  Widget build(BuildContext context) {
    final periodLabel = stake.isLocked ? S.stakingDaysBadge(stake.lockDays) : S.stakingFlexible;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: NexbitColors.lineSoft))),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: stake.color, borderRadius: BorderRadius.circular(8)),
                  child: Text(stake.id[0],
                      style: NexbitText.mono(fontSize: 12, weight: FontWeight.w700, color: const Color(0xFF04120E))),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(stake.id, style: NexbitText.body(fontSize: 12.5, weight: FontWeight.w600, color: NexbitColors.text)),
                    Text(stake.name, style: NexbitText.body(fontSize: 10.5, color: NexbitColors.muted2)),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${formatStakeAmount(stake.amount, decimals: stake.amountDecimals)} ${stake.id}',
                    style: NexbitText.mono(fontSize: 12.5, weight: FontWeight.w600)),
                Text('= \$${formatStakeAmount(stake.amountUsd)}', style: NexbitText.body(fontSize: 10.5, color: NexbitColors.muted2)),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text('${stake.apy.toStringAsFixed(2)}%', style: NexbitText.mono(fontSize: 12.5, weight: FontWeight.w600)),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('+${formatStakeAmount(stake.reward, decimals: stake.rewardDecimals)} ${stake.id}',
                    style: NexbitText.mono(fontSize: 12.5, weight: FontWeight.w600, color: NexbitColors.up)),
                Text('= \$${formatStakeAmount(stake.rewardUsd)}', style: NexbitText.body(fontSize: 10.5, color: NexbitColors.muted2)),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(S.stakingSummaryRewardDaily, style: NexbitText.body(fontSize: 12, color: NexbitColors.text)),
                Text('12:00 WIB', style: NexbitText.body(fontSize: 10.5, color: NexbitColors.muted2)),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 6, height: 6, decoration: const BoxDecoration(color: NexbitColors.up, shape: BoxShape.circle)),
                    const SizedBox(width: 5),
                    Text(S.stakingStatusActive, style: NexbitText.body(fontSize: 12, weight: FontWeight.w600, color: NexbitColors.up)),
                  ],
                ),
                Text(stake.isLocked ? S.stakingDaysLeft(stake.daysRemaining) : periodLabel,
                    style: NexbitText.body(fontSize: 10.5, color: NexbitColors.muted2)),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _SmallButton(label: S.stakingDetailButton, onTap: onDetail),
                _SmallButton(label: S.stakingUnstakeButton, danger: true, onTap: onUnstake),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallButton extends StatelessWidget {
  final String label;
  final bool danger;
  final VoidCallback onTap;
  const _SmallButton({required this.label, required this.onTap, this.danger = false});

  @override
  Widget build(BuildContext context) {
    final color = danger ? NexbitColors.down : NexbitColors.text;
    return Hoverable(
      hoverScale: 1.0,
      builder: (context, hovered) => InkWell(
        borderRadius: BorderRadius.circular(7),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7),
            border: Border.all(color: danger ? NexbitColors.down.withOpacity(0.5) : NexbitColors.line),
            color: hovered ? (danger ? NexbitColors.down.withOpacity(0.08) : NexbitColors.surface2) : null,
          ),
          child: Text(label, style: NexbitText.body(fontSize: 11.5, weight: FontWeight.w600, color: color)),
        ),
      ),
    );
  }
}

class _RewardDonutCard extends StatelessWidget {
  const _RewardDonutCard();

  @override
  Widget build(BuildContext context) {
    const slices = [
      DonutSlice(label: 'USDT', color: Color(0xFF26A17B), percent: 40),
      DonutSlice(label: 'ETH', color: Color(0xFF627EEA), percent: 30),
      DonutSlice(label: 'SOL', color: Color(0xFF14F195), percent: 20),
      DonutSlice(label: 'ADA', color: Color(0xFF0033AD), percent: 10),
    ];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: NexbitColors.panel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: NexbitColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(S.stakingRewardThisMonth, style: NexbitText.body(fontSize: 13.5, weight: FontWeight.w700, color: NexbitColors.text)),
          const SizedBox(height: 18),
          Center(
            child: StakingRewardDonut(slices: slices, centerValue: r'$184.52', centerLabel: S.stakingTotal),
          ),
          const SizedBox(height: 18),
          for (final s in slices)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(width: 8, height: 8, decoration: BoxDecoration(color: s.color, shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Text(s.label, style: NexbitText.body(fontSize: 12.5, color: NexbitColors.text)),
                    ],
                  ),
                  Text('${s.percent.toStringAsFixed(0)}%', style: NexbitText.mono(fontSize: 12, color: NexbitColors.muted)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
