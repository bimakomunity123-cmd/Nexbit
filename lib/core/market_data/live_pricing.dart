import '../../features/futures/domain/models/futures_contract.dart';
import '../../features/trading/domain/models/trading_pair.dart';
import 'live_price_service.dart';

/// Formats a live 24h-change percentage into this app's "+1.23%" /
/// "-1.23%" convention, matching every mock [TradingPair.change] /
/// [FuturesContract.change] string already in the codebase.
String _formatChange(double percent) {
  final sign = percent >= 0 ? '+' : '';
  return '$sign${percent.toStringAsFixed(2)}%';
}

/// Returns [pair] unchanged if no live price has come in yet for its id
/// (first load, or the id isn't a coin CoinGecko tracks — the forex/gold
/// pairs), otherwise a copy with `base`/`change`/`isUp` replaced by the
/// live IDR price. Everything else (icon, symbol, TradingView mapping)
/// stays identical, so this is safe to substitute anywhere a [TradingPair]
/// is used.
TradingPair withLivePrice(TradingPair pair) {
  final live = LivePriceService.prices.value[pair.id];
  if (live == null) return pair;
  return TradingPair(
    id: pair.id,
    name: pair.name,
    category: pair.category,
    quote: pair.quote,
    base: live.priceIdr,
    decimals: pair.decimals,
    change: _formatChange(live.changePercent24h),
    isUp: live.changePercent24h >= 0,
    tvSymbol: pair.tvSymbol,
    iconColor: pair.iconColor,
    iconLabel: pair.iconLabel,
  );
}

/// Same idea as [withLivePrice], for Futures' USDT-quoted crypto
/// contracts — uses the USD price (USDT ≈ USD), matching how
/// [kFuturesCryptoContracts] is already priced.
FuturesContract withLiveContractPrice(FuturesContract contract) {
  final live = LivePriceService.prices.value[contract.id];
  if (live == null) return contract;
  return FuturesContract(
    id: contract.id,
    name: contract.name,
    quote: contract.quote,
    price: live.priceUsd,
    change: _formatChange(live.changePercent24h),
    isUp: live.changePercent24h >= 0,
    iconColor: contract.iconColor,
    iconLabel: contract.iconLabel,
    tvSymbol: contract.tvSymbol,
    decimals: contract.decimals,
    assetClass: contract.assetClass,
  );
}

/// [kTradingPairs] with every crypto entry's price/change live-overridden
/// where available (forex/gold pairs pass through unchanged — CoinGecko
/// doesn't track those, and this app's forex data is illustrative mock
/// data by design, see trading_pair.dart).
List<TradingPair> liveTradingPairs() => kTradingPairs.map(withLivePrice).toList();

/// [kFuturesCryptoContracts] with live USD prices where available.
List<FuturesContract> liveFuturesCryptoContracts() => kFuturesCryptoContracts.map(withLiveContractPrice).toList();

/// A fixed, approximate USD price for staking assets CoinGecko doesn't
/// happen to be tracked for under this id elsewhere in the app (or
/// hasn't loaded yet) — purely cosmetic (the Staking pages' "= $X"
/// lines), never sent to the backend, so accuracy beyond "plausible
/// order of magnitude" doesn't matter here the way it would for an
/// actual trade.
const _kApproxUsdPriceFallback = <String, double>{
  'ETH': 3560, 'SOL': 144, 'USDT': 1, 'ADA': 0.75, 'BNB': 600, 'DOT': 7,
};

/// Best-effort USD price for a Staking asset id — live where
/// [LivePriceService] tracks it, [_kApproxUsdPriceFallback] otherwise.
double approxUsdPriceFor(String assetId) {
  final live = LivePriceService.prices.value[assetId];
  if (live != null) return live.priceUsd;
  return _kApproxUsdPriceFallback[assetId] ?? 0;
}

/// Fallback IDR-per-USDT rate for when [LivePriceService] hasn't loaded
/// yet — a mid-2020s ballpark, purely cosmetic (only used if the live
/// feed is unavailable), never treated as a real FX quote.
const _kApproxIdrPerUsdtFallback = 15600.0;

/// Best-effort IDR-per-USDT exchange rate, used by the Spot<->Futures
/// Exchange dialog to convert between the two wallets' different quote
/// currencies. USDT's own live IDR price (from [LivePriceService]) IS
/// the IDR/USD rate, since USDT tracks USD ~1:1 — same "trust the live
/// feed, fall back to a fixed approximation" pattern as
/// [approxUsdPriceFor].
double approxIdrPerUsdt() {
  final live = LivePriceService.prices.value['USDT'];
  if (live != null && live.priceIdr > 0) return live.priceIdr;
  return _kApproxIdrPerUsdtFallback;
}
