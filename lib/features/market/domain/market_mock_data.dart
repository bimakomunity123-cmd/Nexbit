import 'dart:math';
import '../../trading/domain/models/trading_pair.dart';

/// Deterministic (seeded by pair id — stable across rebuilds, not
/// re-randomized) pseudo market-cap and 24h-volume figures for the Market
/// page's exploration dashboard. There's no real market-cap feed behind
/// this app, same spirit as the other mock data throughout it.
class MarketMockStats {
  final TradingPair pair;
  final double marketCap;
  final double volume24h;
  const MarketMockStats({required this.pair, required this.marketCap, required this.volume24h});
}

// Rough real-world circulating-supply orders of magnitude — not live data,
// just enough so a ~$1.15B-IDR BTC and a ~Rp1,350 DOGE land in the same
// believable market-cap ballpark (and BTC dominance comes out in the 50-70%
// range real markets actually sit in) instead of every asset using the same
// random supply multiplier regardless of how differently priced they are.
const _approxSupply = <String, double>{
  'BTC': 19800000,
  'ETH': 120000000,
  'USDT': 110000000000,
  'XRP': 55000000000,
  'DOGE': 145000000000,
  'XLM': 30000000000,
  'LTC': 74000000,
  'SOL': 470000000,
  'ADA': 35000000000,
};

List<MarketMockStats> buildMarketMockStats(List<TradingPair> pairs) {
  return pairs.map((p) {
    final rng = Random(p.id.hashCode);
    final supply = _approxSupply[p.id] ?? (p.base * 1000 < 1 ? 5e10 : 1e8);
    final marketCap = p.base * supply;
    final volume24h = marketCap * (0.02 + rng.nextDouble() * 0.12);
    return MarketMockStats(pair: p, marketCap: marketCap, volume24h: volume24h);
  }).toList();
}

/// Forex pairs don't have a "market cap", so their [MarketMockStats] only
/// carries a plausible pseudo 24h-volume figure — used for the Market
/// page's "Top Volume · Fiat" tab.
List<MarketMockStats> buildForexVolumeStats(List<TradingPair> pairs) {
  return pairs.map((p) {
    final rng = Random(p.id.hashCode ^ 0x5AFE);
    final volume24h = (2e12 + rng.nextDouble() * 6e12); // a few trillion IDR/day, varies per pair
    return MarketMockStats(pair: p, marketCap: 0, volume24h: volume24h);
  }).toList();
}

/// "Rp1,23 T" / "Rp45,6 M" / "Rp7,8 Jt" style compact formatting for the
/// large cap/volume figures on the Market page (Triliun/Miliar/Juta —
/// Indonesian financial-media convention — instead of a raw 15-digit
/// number), consistent with the rest of the app never pulling in `intl`.
String compactIdr(double value) {
  String fmt(double v) {
    final s = v.toStringAsFixed(2);
    return s.endsWith('.00') ? s.substring(0, s.length - 3) : s.replaceAll('.', ',');
  }

  if (value >= 1e12) return 'Rp${fmt(value / 1e12)} T';
  if (value >= 1e9) return 'Rp${fmt(value / 1e9)} M';
  if (value >= 1e6) return 'Rp${fmt(value / 1e6)} Jt';
  return 'Rp${value.toStringAsFixed(0)}';
}
