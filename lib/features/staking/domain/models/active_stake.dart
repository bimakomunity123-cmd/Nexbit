import 'package:flutter/material.dart';

/// A single currently-active (or historical) stake shown in the "My
/// Staking Portfolio" table — enough detail to support the Detail and
/// Unstake actions, and to compute a live-accruing reward the same way
/// Futures computes unrealized PnL: from stored facts (amount, apy,
/// startedAt) rather than a stored number that would go stale the
/// moment time passes.
class ActiveStake {
  /// The backend's row id for a real stake (see
  /// backend/app/models.py's StakingPosition) — null only for a guest-
  /// seeded demo stake, which never touches the backend at all (see
  /// kSeedActiveStakes below and NexbitStakingPortfolioPage, which is
  /// the only place that constructs one of those).
  final String? backendId;
  final String id; // asset ticker, e.g. 'ETH'
  final String name;
  final Color color;
  final double amount;
  final int amountDecimals;
  final double apy; // locked in at the moment of staking
  final String durationId; // 'flexible' | '30d' | '60d' | '90d'
  final DateTime startedAt;

  const ActiveStake({
    this.backendId,
    required this.id,
    required this.name,
    required this.color,
    required this.amount,
    required this.amountDecimals,
    required this.apy,
    required this.durationId,
    required this.startedAt,
  });

  bool get isLocked => durationId != 'flexible';

  int get lockDays => switch (durationId) {
        '30d' => 30,
        '60d' => 60,
        '90d' => 90,
        _ => 0,
      };

  double get _elapsedDays => DateTime.now().difference(startedAt).inSeconds / 86400;

  int get daysRemaining => isLocked ? (lockDays - _elapsedDays).clamp(0, lockDays).ceil() : 0;

  /// Reward accrued since staking — like Futures' unrealized PnL, this
  /// depends on the current time, so it's computed fresh on every read
  /// rather than stored anywhere.
  double get reward => amount * apy / 100 * (_elapsedDays / 365);

  /// A reasonable display precision for [reward], which can be a very
  /// small number (a fraction of a coin, freshly staked) or a larger
  /// one (a big USDT stake, weeks in) — picked from its own magnitude
  /// rather than a fixed per-asset constant.
  int get rewardDecimals {
    final r = reward;
    if (r >= 100) return 2;
    if (r >= 1) return 4;
    return 6;
  }
}

/// Deterministic guest-only seed data — never touches the backend. Only
/// NexbitStakingPortfolioPage constructs this, and only when signed
/// out; a logged-in user's real stakes come from the backend instead.
final kSeedActiveStakes = <ActiveStake>[
  ActiveStake(
    id: 'USDT', name: 'Tether', color: const Color(0xFF26A17B),
    amount: 1000, amountDecimals: 0, apy: 8.50,
    durationId: '30d', startedAt: DateTime.now().subtract(const Duration(days: 10)),
  ),
  ActiveStake(
    id: 'ETH', name: 'Ethereum', color: const Color(0xFF627EEA),
    amount: 0.5, amountDecimals: 1, apy: 4.50,
    durationId: 'flexible', startedAt: DateTime.now().subtract(const Duration(days: 60)),
  ),
  ActiveStake(
    id: 'SOL', name: 'Solana', color: const Color(0xFF14F195),
    amount: 5, amountDecimals: 0, apy: 7.20,
    durationId: 'flexible', startedAt: DateTime.now().subtract(const Duration(days: 20)),
  ),
  ActiveStake(
    id: 'ADA', name: 'Cardano', color: const Color(0xFF0033AD),
    amount: 200, amountDecimals: 0, apy: 5.80,
    durationId: 'flexible', startedAt: DateTime.now().subtract(const Duration(days: 3)),
  ),
];
