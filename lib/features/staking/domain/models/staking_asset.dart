import 'package:flutter/material.dart';

/// A stakeable duration option — 'flexible' has no lock-up period (reward
/// is estimated per day), the others lock funds for the given number of
/// days in exchange for a (usually) higher APY.
class StakingDuration {
  final String id; // 'flexible' | '30d' | '60d' | '90d'
  final int days; // used for reward-estimate math; flexible uses 1 (daily)
  final double apy;
  const StakingDuration({required this.id, required this.days, required this.apy});
}

class StakingAsset {
  final String id; // 'ETH'
  final String name; // 'Ethereum'
  final String iconLabel;
  final Color iconColor;
  final double minStake;
  final double availableBalance; // mock wallet balance for the "Maks" shortcut
  final String defaultDuration; // duration id pre-selected on the detail page
  final List<StakingDuration> durations;

  const StakingAsset({
    required this.id,
    required this.name,
    required this.iconLabel,
    required this.iconColor,
    required this.minStake,
    required this.availableBalance,
    required this.defaultDuration,
    required this.durations,
  });

  StakingDuration get defaultDurationOption => durations.firstWhere((d) => d.id == defaultDuration);

  /// The APY shown in list/card views — the default duration's APY.
  double get listApy => defaultDurationOption.apy;

  StakingDuration durationById(String durationId) => durations.firstWhere((d) => d.id == durationId);
}

/// Builds the 4 standard duration tiers for an asset from its "list" APY
/// (the 30-day tier), following the same relative spread across every
/// asset: Flexible is lower (no lock-up), 60d dips slightly, 90d pays the
/// most for the longest lock-up.
List<StakingDuration> _tiers(double apy30) => [
      StakingDuration(id: 'flexible', days: 1, apy: apy30 - 2.5),
      StakingDuration(id: '30d', days: 30, apy: apy30),
      StakingDuration(id: '60d', days: 60, apy: apy30 - 0.3),
      StakingDuration(id: '90d', days: 90, apy: apy30 + 1.5),
    ];

final kStakingAssets = <StakingAsset>[
  StakingAsset(
    id: 'ETH',
    name: 'Ethereum',
    iconLabel: 'E',
    iconColor: const Color(0xFF627EEA),
    minStake: 0.01,
    availableBalance: 1.8548,
    defaultDuration: 'flexible',
    durations: _tiers(4.50),
  ),
  StakingAsset(
    id: 'SOL',
    name: 'Solana',
    iconLabel: 'S',
    iconColor: const Color(0xFF14F195),
    minStake: 0.1,
    availableBalance: 42.3,
    defaultDuration: 'flexible',
    durations: _tiers(7.20),
  ),
  StakingAsset(
    id: 'USDT',
    name: 'Tether',
    iconLabel: 'T',
    iconColor: const Color(0xFF26A17B),
    minStake: 10,
    availableBalance: 2450,
    defaultDuration: '30d',
    durations: _tiers(8.50),
  ),
  StakingAsset(
    id: 'ADA',
    name: 'Cardano',
    iconLabel: 'A',
    iconColor: const Color(0xFF0033AD),
    minStake: 10,
    availableBalance: 5200,
    defaultDuration: 'flexible',
    durations: _tiers(5.80),
  ),
  StakingAsset(
    id: 'BNB',
    name: 'BNB Chain',
    iconLabel: 'B',
    iconColor: const Color(0xFFF3BA2F),
    minStake: 0.01,
    availableBalance: 3.2,
    defaultDuration: 'flexible',
    durations: _tiers(6.20),
  ),
  StakingAsset(
    id: 'DOT',
    name: 'Polkadot',
    iconLabel: 'D',
    iconColor: const Color(0xFFE6007A),
    minStake: 1,
    availableBalance: 150,
    defaultDuration: 'flexible',
    durations: _tiers(6.00),
  ),
];

/// "1,000.5" style US/comma thousands formatting — the staking screens
/// mirror the reference design's $-denominated look, distinct from the
/// dot-separated IDR formatting used elsewhere in the app. Zero extra
/// dependencies (no `intl`), same spirit as the rest of the codebase.
String formatStakeAmount(double value, {int decimals = 2}) {
  final isNeg = value < 0;
  final fixed = value.abs().toStringAsFixed(decimals);
  final parts = fixed.split('.');
  final intPart = parts[0];
  final buf = StringBuffer();
  for (var i = 0; i < intPart.length; i++) {
    final posFromEnd = intPart.length - i;
    buf.write(intPart[i]);
    if (posFromEnd > 1 && posFromEnd % 3 == 1) buf.write(',');
  }
  final result = decimals > 0 ? '${buf.toString()}.${parts[1]}' : buf.toString();
  return isNeg ? '-$result' : result;
}
