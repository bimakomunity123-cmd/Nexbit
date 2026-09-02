import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/core/market_data/live_pricing.dart';
import 'package:flutter_application_1/core/market_data/live_price_service.dart';

void main() {
  // LivePriceService.start() (the CoinGecko poller) is never called in
  // these tests, so LivePriceService.prices.value stays the empty map
  // it's initialized with — every lookup below exercises
  // approxUsdPriceFor's fallback path, never the live one.
  setUp(() {
    LivePriceService.prices.value = {};
  });

  group('approxUsdPriceFor', () {
    test('returns a positive fallback price for a known staking asset', () {
      expect(approxUsdPriceFor('ETH'), greaterThan(0));
      expect(approxUsdPriceFor('SOL'), greaterThan(0));
      expect(approxUsdPriceFor('USDT'), closeTo(1, 0.01));
    });

    test('returns 0 for a completely unknown asset id', () {
      expect(approxUsdPriceFor('NOT_A_REAL_ASSET'), 0);
    });

    test('prefers the live price over the fallback once one is cached', () {
      LivePriceService.prices.value = {
        'ETH': const LiveCoinPrice(priceIdr: 60000000, priceUsd: 3999.0, changePercent24h: 1.2),
      };
      expect(approxUsdPriceFor('ETH'), 3999.0);
    });
  });
}
