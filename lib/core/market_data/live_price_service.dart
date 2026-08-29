import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// One coin's live snapshot — price in both IDR (for the app's IDR-quoted
/// spot pairs) and USD (for Futures, which prices crypto in USDT ≈ USD,
/// same convention already used by [kFuturesCryptoContracts]).
class LiveCoinPrice {
  final double priceIdr;
  final double priceUsd;
  final double changePercent24h;
  const LiveCoinPrice({required this.priceIdr, required this.priceUsd, required this.changePercent24h});
}

/// Real crypto prices from CoinGecko's free public API — no key required,
/// CORS-enabled, called directly from the browser (no backend involved).
/// This is the one genuinely "live" data source in the app; everything
/// else (order books, trade tapes, forex, stocks) stays mock, seeded off
/// whatever price this service last reported.
///
/// Graceful by design: a failed/rate-limited/CORS-blocked fetch just
/// keeps whatever was last known (or nothing, on first load) — every
/// consumer of [prices] falls back to its own static mock value when a
/// coin isn't in the map yet, so a flaky feed never blanks the UI.
class LivePriceService {
  LivePriceService._();

  static final ValueNotifier<Map<String, LiveCoinPrice>> prices = ValueNotifier<Map<String, LiveCoinPrice>>({});

  /// Our own ticker id -> CoinGecko's coin id.
  static const Map<String, String> geckoIds = {
    'BTC': 'bitcoin',
    'ETH': 'ethereum',
    'USDT': 'tether',
    'XRP': 'ripple',
    'DOGE': 'dogecoin',
    'XLM': 'stellar',
    'LTC': 'litecoin',
    'SOL': 'solana',
    'ADA': 'cardano',
    'BNB': 'binancecoin',
  };

  static Timer? _timer;
  static bool _started = false;

  static void start() {
    if (_started) return;
    _started = true;
    _fetch();
    _timer = Timer.periodic(const Duration(seconds: 45), (_) => _fetch());
  }

  /// Not called in the running app (this is a process-lifetime singleton)
  /// — exists so tests can tear it down between runs.
  @visibleForTesting
  static void stop() {
    _timer?.cancel();
    _timer = null;
    _started = false;
  }

  static Future<void> _fetch() async {
    try {
      final ids = geckoIds.values.join(',');
      final uri = Uri.parse(
        'https://api.coingecko.com/api/v3/simple/price'
        '?ids=$ids&vs_currencies=idr,usd&include_24hr_change=true',
      );
      final res = await http.get(uri).timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) return;

      final decoded = jsonDecode(res.body) as Map<String, dynamic>;
      final next = <String, LiveCoinPrice>{};
      for (final entry in geckoIds.entries) {
        final data = decoded[entry.value] as Map<String, dynamic>?;
        if (data == null) continue;
        final idr = (data['idr'] as num?)?.toDouble();
        final usd = (data['usd'] as num?)?.toDouble();
        if (idr == null || usd == null) continue;
        next[entry.key] = LiveCoinPrice(
          priceIdr: idr,
          priceUsd: usd,
          changePercent24h: (data['usd_24h_change'] as num?)?.toDouble() ?? 0,
        );
      }
      if (next.isNotEmpty) prices.value = next;
    } catch (_) {
      // Network hiccup, CORS block, or CoinGecko's free-tier rate limit —
      // silently keep showing the last good value (see class doc).
    }
  }
}
