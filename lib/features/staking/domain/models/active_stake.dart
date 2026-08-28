import 'package:flutter/material.dart';

/// A single currently-active stake shown in the "My Staking Portfolio"
/// table — enough detail (raw numeric amounts, lock state) to actually
/// support the Detail and Unstake actions, not just render display text.
class ActiveStake {
  final String id; // 'USDT'
  final String name; // 'Tether'
  final Color color;
  final double amount;
  final int amountDecimals;
  final double amountUsd;
  final double apy;
  final double reward;
  final int rewardDecimals;
  final double rewardUsd;
  final String durationId; // 'flexible' | '30d' | '60d' | '90d'
  final int daysRemaining; // 0 for flexible

  const ActiveStake({
    required this.id,
    required this.name,
    required this.color,
    required this.amount,
    required this.amountDecimals,
    required this.amountUsd,
    required this.apy,
    required this.reward,
    required this.rewardDecimals,
    required this.rewardUsd,
    required this.durationId,
    this.daysRemaining = 0,
  });

  bool get isLocked => durationId != 'flexible';

  int get lockDays => switch (durationId) {
        '30d' => 30,
        '60d' => 60,
        '90d' => 90,
        _ => 0,
      };
}

/// Seed data for a freshly-loaded portfolio — matches the reference
/// design's initial table exactly. The portfolio page copies this into
/// mutable state so Unstake can actually remove an entry.
final kSeedActiveStakes = <ActiveStake>[
  const ActiveStake(
    id: 'USDT', name: 'Tether', color: Color(0xFF26A17B),
    amount: 1000, amountDecimals: 0, amountUsd: 1000.00, apy: 8.50,
    reward: 2.45, rewardDecimals: 2, rewardUsd: 2.45,
    durationId: '30d', daysRemaining: 30,
  ),
  const ActiveStake(
    id: 'ETH', name: 'Ethereum', color: Color(0xFF627EEA),
    amount: 0.5, amountDecimals: 1, amountUsd: 1780.00, apy: 4.50,
    reward: 0.0032, rewardDecimals: 4, rewardUsd: 11.36,
    durationId: 'flexible',
  ),
  const ActiveStake(
    id: 'SOL', name: 'Solana', color: Color(0xFF14F195),
    amount: 5, amountDecimals: 0, amountUsd: 720.00, apy: 7.20,
    reward: 0.12, rewardDecimals: 2, rewardUsd: 17.28,
    durationId: 'flexible',
  ),
  const ActiveStake(
    id: 'ADA', name: 'Cardano', color: Color(0xFF0033AD),
    amount: 200, amountDecimals: 0, amountUsd: 150.00, apy: 5.80,
    reward: 1.25, rewardDecimals: 2, rewardUsd: 0.94,
    durationId: 'flexible',
  ),
];
