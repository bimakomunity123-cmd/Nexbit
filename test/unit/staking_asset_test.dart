import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/features/staking/domain/models/staking_asset.dart';

void main() {
  group('formatStakeAmount', () {
    test('defaults to 2 decimals with comma thousands separators', () {
      expect(formatStakeAmount(1000), '1,000.00');
    });

    test('honors a custom decimals count', () {
      expect(formatStakeAmount(0.5, decimals: 4), '0.5000');
    });

    test('formats zero decimals when asked', () {
      expect(formatStakeAmount(1000, decimals: 0), '1,000');
    });

    test('formats a negative value with a leading minus', () {
      expect(formatStakeAmount(-42.5), '-42.50');
    });
  });

  group('StakingAsset.listApy / defaultDurationOption', () {
    test("every seed asset's listApy matches its own default duration's apy", () {
      for (final asset in kStakingAssets) {
        expect(asset.listApy, asset.defaultDurationOption.apy, reason: 'mismatch for ${asset.id}');
      }
    });

    test('durationById finds the right tier', () {
      final eth = kStakingAssets.firstWhere((a) => a.id == 'ETH');
      expect(eth.durationById('90d').id, '90d');
    });
  });
}
