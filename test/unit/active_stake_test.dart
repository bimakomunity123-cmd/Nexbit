import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/features/staking/domain/models/active_stake.dart';

ActiveStake _stake({
  required double amount,
  required double apy,
  required String durationId,
  required int daysAgo,
}) {
  return ActiveStake(
    id: 'ETH',
    name: 'Ethereum',
    color: const Color(0xFF627EEA),
    amount: amount,
    amountDecimals: 2,
    apy: apy,
    durationId: durationId,
    startedAt: DateTime.now().subtract(Duration(days: daysAgo)),
  );
}

void main() {
  group('ActiveStake.isLocked / lockDays', () {
    test('flexible duration is not locked and has 0 lock days', () {
      final s = _stake(amount: 100, apy: 5, durationId: 'flexible', daysAgo: 1);
      expect(s.isLocked, false);
      expect(s.lockDays, 0);
    });

    test('30d/60d/90d durations are locked with matching lockDays', () {
      expect(_stake(amount: 100, apy: 5, durationId: '30d', daysAgo: 1).lockDays, 30);
      expect(_stake(amount: 100, apy: 5, durationId: '60d', daysAgo: 1).lockDays, 60);
      expect(_stake(amount: 100, apy: 5, durationId: '90d', daysAgo: 1).lockDays, 90);
      expect(_stake(amount: 100, apy: 5, durationId: '30d', daysAgo: 1).isLocked, true);
    });
  });

  group('ActiveStake.daysRemaining', () {
    test('flexible stakes always report 0 days remaining', () {
      final s = _stake(amount: 100, apy: 5, durationId: 'flexible', daysAgo: 500);
      expect(s.daysRemaining, 0);
    });

    test('a 30d stake started 10 days ago has ~20 days remaining', () {
      final s = _stake(amount: 100, apy: 5, durationId: '30d', daysAgo: 10);
      expect(s.daysRemaining, 20);
    });

    test('a 30d stake started 40 days ago (past maturity) clamps to 0, not negative', () {
      final s = _stake(amount: 100, apy: 5, durationId: '30d', daysAgo: 40);
      expect(s.daysRemaining, 0);
    });

    test('a freshly-started 90d stake reports ~90 days remaining', () {
      final s = _stake(amount: 100, apy: 5, durationId: '90d', daysAgo: 0);
      expect(s.daysRemaining, 90);
    });
  });

  group('ActiveStake.reward', () {
    test('accrues proportionally to amount, apy, and elapsed time', () {
      // 1000 * 8.5% * (10/365 years) ≈ 2.3288
      final s = _stake(amount: 1000, apy: 8.5, durationId: 'flexible', daysAgo: 10);
      expect(s.reward, closeTo(2.3288, 0.01));
    });

    test('doubling the elapsed time roughly doubles the reward', () {
      final s10 = _stake(amount: 1000, apy: 8.5, durationId: 'flexible', daysAgo: 10);
      final s20 = _stake(amount: 1000, apy: 8.5, durationId: 'flexible', daysAgo: 20);
      expect(s20.reward, closeTo(s10.reward * 2, 0.01));
    });

    test('a stake with zero elapsed time has ~zero reward', () {
      final s = _stake(amount: 1000, apy: 8.5, durationId: 'flexible', daysAgo: 0);
      expect(s.reward, closeTo(0, 0.001));
    });

    test('reward is never negative for a stake started in the past', () {
      final s = _stake(amount: 1000, apy: 8.5, durationId: 'flexible', daysAgo: 5);
      expect(s.reward, greaterThanOrEqualTo(0));
    });
  });

  group('ActiveStake.rewardDecimals', () {
    test('picks more decimals for a tiny reward so it does not display as 0', () {
      // A brand-new, small stake accrues a reward well under 1 unit.
      final s = _stake(amount: 0.01, apy: 2, durationId: 'flexible', daysAgo: 1);
      expect(s.rewardDecimals, greaterThanOrEqualTo(4));
    });

    test('picks fewer decimals for a large, mature reward', () {
      final s = _stake(amount: 100000, apy: 8.5, durationId: 'flexible', daysAgo: 365);
      expect(s.rewardDecimals, 2);
    });
  });
}
