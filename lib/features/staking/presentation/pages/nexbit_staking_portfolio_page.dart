import 'package:flutter/material.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/auth/session.dart';
import '../../../../core/i18n/app_locale.dart';
import '../../../../core/i18n/strings.dart';
import '../../../../core/market_data/live_pricing.dart';
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
  // Guests see the deterministic seeded demo stakes (local-only, never
  // touches the backend); a logged-in user's real stakes/reward are
  // fetched from the backend in initState instead — same guest-vs-real
  // split Futures and Spot use for their own balances/positions.
  late List<ActiveStake> _stakes = isLoggedIn.value ? [] : List.of(kSeedActiveStakes);
  double _realizedReward = 0;

  @override
  void initState() {
    super.initState();
    if (isLoggedIn.value) _loadStakingData();
  }

  // Loads the logged-in user's real stakes/realized reward from the
  // backend. Left at the guest-mode empty state on any failure (offline,
  // backend down) rather than showing an error — the page still works
  // fine for browsing even without this succeeding.
  Future<void> _loadStakingData() async {
    try {
      final token = authToken.value;
      final results = await Future.wait([
        ApiClient.getStakingAccount(token),
        ApiClient.getStakingPositions(token),
      ]);
      final account = results[0] as Map<String, dynamic>;
      final positionsJson = results[1] as List<dynamic>;
      if (!mounted) return;
      setState(() {
        _realizedReward = (account['realized_reward'] as num).toDouble();
        _stakes = positionsJson
            .map((j) => j as Map<String, dynamic>)
            .where((j) => j['status'] == 'active')
            .map(_stakeFromJson)
            .toList();
      });
    } catch (_) {
      // Stays on the empty-but-logged-in state set in the field
      // initializer above — no seeded demo stake shown to a real
      // account even if the fetch fails.
    }
  }

  ActiveStake _stakeFromJson(Map<String, dynamic> json) {
    final assetId = json['asset_id'] as String;
    final asset = kStakingAssets.firstWhere((a) => a.id == assetId, orElse: () => kStakingAssets.first);
    return ActiveStake(
      backendId: json['id'] as String,
      id: assetId,
      name: asset.name,
      color: asset.iconColor,
      amount: (json['amount'] as num).toDouble(),
      amountDecimals: (json['amount'] as num).toDouble() < 10 ? 4 : 0,
      apy: (json['apy'] as num).toDouble(),
      durationId: json['duration_id'] as String,
      startedAt: DateTime.parse(json['started_at'] as String),
    );
  }

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

    // Only a backend-persisted stake (backendId != null) needs a server
    // round-trip — the guest-mode seeded stake unstakes purely locally,
    // same as before this page had a backend at all.
    if (stake.backendId != null) {
      try {
        // StakingAccount.realized_reward is a single USD-denominated
        // accumulator shared across every asset a user has ever staked
        // (see its docstring) — reward has to be converted from the
        // stake's own asset unit (e.g. ETH) to USD before sending it,
        // or unstaking two different assets would just add raw ETH and
        // raw SOL quantities together as if they were the same currency.
        final rewardUsd = stake.reward * approxUsdPriceFor(stake.id);
        final result = await ApiClient.unstakeStakingPosition(authToken.value, stake.backendId!, rewardUsd);
        if (!mounted) return;
        setState(() {
          _realizedReward = ((result['account'] as Map<String, dynamic>)['realized_reward'] as num).toDouble();
          _stakes = _stakes.where((s) => s.backendId != stake.backendId).toList();
        });
      } on ApiException catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message), duration: const Duration(seconds: 3)));
        return;
      }
    } else {
      setState(() => _stakes = _stakes.where((s) => s != stake).toList());
    }

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
                    realizedReward: _realizedReward,
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
  final double realizedReward;
  final VoidCallback onOpenMarketplace;
  final ValueChanged<ActiveStake> onDetail;
  final ValueChanged<ActiveStake> onUnstake;

  const _MainContent({
    required this.isMobile,
    required this.stakes,
    required this.realizedReward,
    required this.onOpenMarketplace,
    required this.onDetail,
    required this.onUnstake,
  });

  @override
  Widget build(BuildContext context) {
    final totalStakedUsd = stakes.fold<double>(0, (sum, s) => sum + s.amount * approxUsdPriceFor(s.id));
    final weightedApy = totalStakedUsd == 0
        ? 0.0
        : stakes.fold<double>(0, (sum, s) => sum + s.amount * approxUsdPriceFor(s.id) * s.apy) / totalStakedUsd;
    // Total Rewards = reward already realized from past unstakes (a
    // running accumulator, like Futures' realized_pnl) plus whatever's
    // still accruing on currently-active stakes — mirrors how Futures'
    // Account Info card adds startingBalance + realizedPnl + unrealizedPnl.
    final unrealizedRewardUsd = stakes.fold<double>(0, (sum, s) => sum + s.reward * approxUsdPriceFor(s.id));
    final totalRewardsUsd = realizedReward + unrealizedRewardUsd;

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
              // Total Staked/Active Stakes reflect the live table —
              // unstaking updates them immediately. Total Rewards
              // includes both realized (past unstakes) and unrealized
              // (currently accruing) reward, so it keeps moving even
              // between unstakes.
              _StatCard(label: S.stakingStatTotalStaked, value: '\$${formatStakeAmount(totalStakedUsd)}'),
              _StatCard(label: S.stakingStatTotalRewards, value: '\$${formatStakeAmount(totalRewardsUsd)}', valueColor: NexbitColors.accent),
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
              final donut = _RewardDonutCard(stakes: stakes, totalRewardsUsd: totalRewardsUsd);
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
    final amountUsd = stake.amount * approxUsdPriceFor(stake.id);
    final rewardUsd = stake.reward * approxUsdPriceFor(stake.id);
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
                Text('= \$${formatStakeAmount(amountUsd)}', style: NexbitText.body(fontSize: 10.5, color: NexbitColors.muted2)),
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
                Text('= \$${formatStakeAmount(rewardUsd)}', style: NexbitText.body(fontSize: 10.5, color: NexbitColors.muted2)),
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
  final List<ActiveStake> stakes;
  final double totalRewardsUsd;
  const _RewardDonutCard({required this.stakes, required this.totalRewardsUsd});

  @override
  Widget build(BuildContext context) {
    // Composition of reward-so-far by asset — falls back to an even
    // illustrative split if nothing's accrued anything yet (avoids a
    // divide-by-zero donut with no active stakes at all).
    final byAsset = <String, double>{};
    for (final s in stakes) {
      byAsset[s.id] = (byAsset[s.id] ?? 0) + s.reward * approxUsdPriceFor(s.id);
    }
    final totalUnrealized = byAsset.values.fold<double>(0, (a, b) => a + b);
    final slices = totalUnrealized > 0
        ? byAsset.entries
            .map((e) => DonutSlice(
                  label: e.key,
                  color: kStakingAssets.firstWhere((a) => a.id == e.key, orElse: () => kStakingAssets.first).iconColor,
                  percent: e.value / totalUnrealized * 100,
                ))
            .toList()
        : const [DonutSlice(label: '—', color: NexbitColors.muted2, percent: 100)];

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
            child: StakingRewardDonut(slices: slices, centerValue: '\$${formatStakeAmount(totalRewardsUsd)}', centerLabel: S.stakingTotal),
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
