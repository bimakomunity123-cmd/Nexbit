import 'package:flutter/material.dart';
import '../../../../core/i18n/strings.dart';
import '../../../../core/theme/nexbit_theme.dart';
import '../../../auth/presentation/pages/nexbit_login_page.dart';
import '../../../auth/presentation/pages/nexbit_register_page.dart';
import '../../../blog/presentation/pages/nexbit_blog_page.dart';
import '../../../landing/presentation/widgets/max_width_box.dart';
import '../../../landing/presentation/widgets/network_background.dart';
import '../../../landing/presentation/widgets/nexbit_buttons.dart';
import '../../../landing/presentation/widgets/nexbit_navbar.dart';
import '../../../futures/presentation/pages/nexbit_futures_page.dart';
import '../../../market/presentation/pages/nexbit_market_page.dart';
import '../../../market/presentation/pages/nexbit_price_page.dart';
import '../../domain/models/staking_asset.dart';
import '../widgets/staking_confirm_dialog.dart';
import 'nexbit_staking_portfolio_page.dart';

/// Staking detail/checkout page for a single asset — amount input,
/// duration picker, live summary, and the confirm step.
class NexbitStakingDetailPage extends StatefulWidget {
  final StakingAsset asset;
  const NexbitStakingDetailPage({super.key, required this.asset});

  @override
  State<NexbitStakingDetailPage> createState() => _NexbitStakingDetailPageState();
}

class _NexbitStakingDetailPageState extends State<NexbitStakingDetailPage> {
  late String _durationId = widget.asset.defaultDuration;
  late final _amountController = TextEditingController(text: formatStakeAmount(_defaultAmount, decimals: 0));

  double get _defaultAmount => widget.asset.minStake * 100 < widget.asset.availableBalance
      ? (widget.asset.minStake * 100).clamp(widget.asset.minStake, widget.asset.availableBalance)
      : widget.asset.minStake;

  double get _amount {
    final raw = _amountController.text.replaceAll(',', '');
    return double.tryParse(raw) ?? 0;
  }

  StakingDuration get _duration => widget.asset.durationById(_durationId);

  double get _reward => _amount * _duration.apy / 100 * (_duration.days / 365);
  double get _total => _amount + _reward;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    if (_amount < widget.asset.minStake) return;
    final ok = await showStakingConfirmDialog(
      context: context,
      asset: widget.asset,
      amount: _amount,
      duration: _duration,
    );
    if (ok == true && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const NexbitStakingPortfolioPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final asset = widget.asset;
    return Scaffold(
      backgroundColor: NexbitColors.bg,
      body: Stack(
        children: [
          const Positioned.fill(child: NetworkBackground()),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < kNexbitMobileBreakpoint;
                return Column(
                  children: [
                    NexbitNavbar(
                      isMobile: isMobile,
                      activeId: 'staking',
                      onLogoTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
                      onHargaTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const NexbitPricePage()),
                      ),
                      onMarketTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const NexbitMarketPage()),
                      ),
                      onStakingTap: () => Navigator.of(context).popUntil((r) => r.isFirst),
                      onFuturesTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const NexbitFuturesPage()),
                      ),
                      onBlogTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const NexbitBlogPage()),
                      ),
                      onLoginTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const NexbitLoginPage()),
                      ),
                      onRegisterTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const NexbitRegisterPage()),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 56, vertical: 32),
                        child: MaxWidthBox(
                          maxWidth: 720,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Hoverable(
                                hoverScale: 1.03,
                                builder: (context, hovered) => InkWell(
                                  onTap: () => Navigator.of(context).pop(),
                                  child: Text(S.stakingBack,
                                      style: NexbitText.body(
                                          fontSize: 13.5,
                                          weight: FontWeight.w600,
                                          color: hovered ? NexbitColors.text : NexbitColors.muted)),
                                ),
                              ),
                              const SizedBox(height: 18),
                              _HeaderCard(asset: asset, apy: _duration.apy),
                              const SizedBox(height: 24),
                              _AmountField(asset: asset, controller: _amountController, onChanged: () => setState(() {})),
                              const SizedBox(height: 24),
                              Text(S.stakingChooseDuration,
                                  style: NexbitText.body(fontSize: 13, weight: FontWeight.w600, color: NexbitColors.text)),
                              const SizedBox(height: 10),
                              _DurationGrid(
                                asset: asset,
                                selected: _durationId,
                                onSelect: (id) => setState(() => _durationId = id),
                              ),
                              const SizedBox(height: 24),
                              _SummaryCard(asset: asset, amount: _amount, duration: _duration, reward: _reward, total: _total),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                child: PrimaryButton(label: S.stakingConfirmButton, onTap: _confirm),
                              ),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final StakingAsset asset;
  final double apy;
  const _HeaderCard({required this.asset, required this.apy});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: NexbitColors.panel,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: NexbitColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: asset.iconColor, borderRadius: BorderRadius.circular(12)),
                child: Text(asset.iconLabel,
                    style: NexbitText.mono(fontSize: 17, weight: FontWeight.w700, color: const Color(0xFF04120E))),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(S.stakingPageTitle(asset.id),
                        style: NexbitText.display(fontSize: 18, weight: FontWeight.w700)),
                    Text(asset.name, style: NexbitText.body(fontSize: 12.5, color: NexbitColors.muted)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: NexbitColors.accent.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('${apy.toStringAsFixed(2)}% APY',
                    style: NexbitText.mono(fontSize: 12, weight: FontWeight.w700, color: NexbitColors.accent)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(S.stakingEarnUpTo(apy, asset.id), style: NexbitText.body(fontSize: 13, height: 1.5)),
        ],
      ),
    );
  }
}

class _AmountField extends StatelessWidget {
  final StakingAsset asset;
  final TextEditingController controller;
  final VoidCallback onChanged;
  const _AmountField({required this.asset, required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(S.stakingAmountLabel, style: NexbitText.body(fontSize: 13, weight: FontWeight.w600, color: NexbitColors.text)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: NexbitColors.surface2,
            border: Border.all(color: NexbitColors.line),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: NexbitText.mono(fontSize: 15, weight: FontWeight.w600),
                  decoration: const InputDecoration(isDense: true, border: InputBorder.none),
                  onChanged: (_) => onChanged(),
                ),
              ),
              Text(asset.id, style: NexbitText.mono(fontSize: 12.5, color: NexbitColors.muted2)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(S.stakingAvailable(formatStakeAmount(asset.availableBalance, decimals: asset.availableBalance < 10 ? 4 : 2), asset.id),
                style: NexbitText.body(fontSize: 12, color: NexbitColors.muted2)),
            Hoverable(
              hoverScale: 1.05,
              builder: (context, hovered) => InkWell(
                onTap: () {
                  controller.text = formatStakeAmount(asset.availableBalance, decimals: asset.availableBalance < 10 ? 4 : 0);
                  onChanged();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: hovered ? NexbitColors.accent.withOpacity(0.16) : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: NexbitColors.accent),
                  ),
                  child: Text(S.stakingMax,
                      style: NexbitText.body(fontSize: 11.5, weight: FontWeight.w700, color: NexbitColors.accent)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DurationGrid extends StatelessWidget {
  final StakingAsset asset;
  final String selected;
  final ValueChanged<String> onSelect;
  const _DurationGrid({required this.asset, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final perRow = constraints.maxWidth >= 520 ? 4 : 2;
        final gap = 10.0;
        final w = (constraints.maxWidth - gap * (perRow - 1)) / perRow;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final d in asset.durations)
              SizedBox(
                width: w,
                child: _DurationChip(duration: d, active: d.id == selected, onTap: () => onSelect(d.id)),
              ),
          ],
        );
      },
    );
  }
}

class _DurationChip extends StatelessWidget {
  final StakingDuration duration;
  final bool active;
  final VoidCallback onTap;
  const _DurationChip({required this.duration, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final label = duration.id == 'flexible' ? S.stakingFlexible : S.stakingDaysBadge(duration.days);
    return Hoverable(
      hoverScale: 1.0,
      builder: (context, hovered) => InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? NexbitColors.accent.withOpacity(0.14) : NexbitColors.surface2,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: active ? NexbitColors.accent : NexbitColors.line, width: active ? 1.5 : 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label,
                  style: NexbitText.body(
                      fontSize: 12.5, weight: FontWeight.w600, color: active ? NexbitColors.accent : NexbitColors.text)),
              const SizedBox(height: 3),
              Text('APY ${duration.apy.toStringAsFixed(2)}%',
                  style: NexbitText.mono(fontSize: 11, color: active ? NexbitColors.accent : NexbitColors.muted2)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final StakingAsset asset;
  final double amount;
  final StakingDuration duration;
  final double reward;
  final double total;
  const _SummaryCard({
    required this.asset,
    required this.amount,
    required this.duration,
    required this.reward,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final periodLabel = duration.id == 'flexible' ? S.stakingFlexible : S.stakingDaysBadge(duration.days);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: NexbitColors.surface2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: NexbitColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(S.stakingSummaryHeading, style: NexbitText.body(fontSize: 13.5, weight: FontWeight.w700, color: NexbitColors.accent)),
          const SizedBox(height: 14),
          _line(S.stakingSummaryAmount, '${formatStakeAmount(amount)} ${asset.id}'),
          _line(S.stakingSummaryApy, '${duration.apy.toStringAsFixed(2)}%'),
          _line(S.stakingSummaryDuration, periodLabel),
          _line(S.stakingSummaryReward, '${formatStakeAmount(reward)} ${asset.id}', valueColor: NexbitColors.accent),
          _line(S.stakingSummaryRewardDate, S.stakingSummaryRewardDaily),
          const Divider(color: NexbitColors.line, height: 22),
          _line(S.stakingSummaryTotal, '${formatStakeAmount(total)} ${asset.id}', bold: true),
        ],
      ),
    );
  }

  Widget _line(String label, String value, {Color? valueColor, bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: NexbitText.body(fontSize: 13, color: NexbitColors.muted)),
          Text(value,
              style: NexbitText.mono(
                fontSize: bold ? 14.5 : 13,
                weight: bold ? FontWeight.w700 : FontWeight.w600,
                color: valueColor ?? (bold ? NexbitColors.text : NexbitColors.text),
              )),
        ],
      ),
    );
  }
}
