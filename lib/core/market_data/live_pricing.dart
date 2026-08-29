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
