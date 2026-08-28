import 'package:flutter/material.dart';
import '../../../trading/domain/models/trading_pair.dart' show kTradingPairs, AssetCategory;

enum FuturesAssetClass { crypto, forex, saham }

/// A tradable futures/CFD contract — crypto perpetuals (USDT-margined),
/// forex majors, or US stock CFDs. One shared shape across all three asset
/// classes so the rest of the Futures page (order book, chart, positions,
/// order form) doesn't need to know which class it's looking at.
class FuturesContract {
  final String id; // 'BTC', 'EUR', 'AAPL', ...
  final String name;
  final String quote; // 'USDT', 'USD', 'JPY', ...
  final double price;
  final String change; // '+2.84%'
  final bool isUp;
  final Color iconColor;
  final String iconLabel;
  final String tvSymbol;
  final int decimals;
  final FuturesAssetClass assetClass;

  const FuturesContract({
    required this.id,
    required this.name,
    required this.quote,
    required this.price,
    required this.change,
    required this.isUp,
    required this.iconColor,
    required this.iconLabel,
    required this.tvSymbol,
    required this.decimals,
    required this.assetClass,
  });

  String get label => '$id/$quote';
}

/// USDT-margined crypto perpetuals. Deliberately a separate, USDT-priced
/// dataset from [kTradingPairs] (which is IDR-quoted for spot) — real
/// exchanges price perpetual futures in USDT globally regardless of which
/// fiat their spot market quotes in, so this isn't an inconsistency, it's
/// how the product actually works.
const kFuturesCryptoContracts = <FuturesContract>[
  FuturesContract(
    id: 'BTC', name: 'Bitcoin', quote: 'USDT', price: 112450, change: '+2.84%', isUp: true,
    iconColor: Color(0xFFF7931A), iconLabel: '₿', tvSymbol: 'BINANCE:BTCUSDT', decimals: 0, assetClass: FuturesAssetClass.crypto,
  ),
  FuturesContract(
    id: 'ETH', name: 'Ethereum', quote: 'USDT', price: 3248.32, change: '+3.12%', isUp: true,
    iconColor: Color(0xFF627EEA), iconLabel: 'Ξ', tvSymbol: 'BINANCE:ETHUSDT', decimals: 2, assetClass: FuturesAssetClass.crypto,
  ),
  FuturesContract(
    id: 'SOL', name: 'Solana', quote: 'USDT', price: 198.54, change: '+4.21%', isUp: true,
    iconColor: Color(0xFF14F195), iconLabel: 'S', tvSymbol: 'BINANCE:SOLUSDT', decimals: 2, assetClass: FuturesAssetClass.crypto,
  ),
  FuturesContract(
    id: 'XRP', name: 'Ripple', quote: 'USDT', price: 0.5212, change: '+1.76%', isUp: true,
    iconColor: Color(0xFF345D9D), iconLabel: 'X', tvSymbol: 'BINANCE:XRPUSDT', decimals: 4, assetClass: FuturesAssetClass.crypto,
  ),
  FuturesContract(
    id: 'BNB', name: 'BNB', quote: 'USDT', price: 688.90, change: '+2.33%', isUp: true,
    iconColor: Color(0xFFF0B90B), iconLabel: 'B', tvSymbol: 'BINANCE:BNBUSDT', decimals: 2, assetClass: FuturesAssetClass.crypto,
  ),
  FuturesContract(
    id: 'ADA', name: 'Cardano', quote: 'USDT', price: 0.3721, change: '+1.29%', isUp: true,
    iconColor: Color(0xFF0033AD), iconLabel: 'A', tvSymbol: 'BINANCE:ADAUSDT', decimals: 4, assetClass: FuturesAssetClass.crypto,
  ),
  FuturesContract(
    id: 'DOGE', name: 'Doge Coin', quote: 'USDT', price: 0.1567, change: '+2.14%', isUp: true,
    iconColor: Color(0xFFC2A633), iconLabel: 'D', tvSymbol: 'BINANCE:DOGEUSDT', decimals: 4, assetClass: FuturesAssetClass.crypto,
  ),
];

/// Forex majors, built straight from the same seed data as the spot
/// Harga/Trading pages' forex pairs (already USD/JPY-quoted, not IDR — no
/// conversion needed) so the numbers stay consistent across the app.
final kFuturesForexContracts = kTradingPairs
    .where((p) => p.category == AssetCategory.forex)
    .map((p) => FuturesContract(
          id: p.id,
          name: p.name,
          quote: p.quote,
          price: p.base,
          change: p.change,
          isUp: p.isUp,
          iconColor: p.iconColor,
          iconLabel: p.iconLabel,
          tvSymbol: p.tvSymbol,
          decimals: p.decimals,
          assetClass: FuturesAssetClass.forex,
        ))
    .toList();

/// US stock CFDs — illustrative mock prices, not a live feed, same spirit
/// as every other mock dataset in this app.
const kFuturesStockContracts = <FuturesContract>[
  FuturesContract(
    id: 'AAPL', name: 'Apple Inc.', quote: 'USD', price: 229.54, change: '+1.24%', isUp: true,
    iconColor: Color(0xFFA3AAAE), iconLabel: 'A', tvSymbol: 'NASDAQ:AAPL', decimals: 2, assetClass: FuturesAssetClass.saham,
  ),
  FuturesContract(
    id: 'MSFT', name: 'Microsoft Corp.', quote: 'USD', price: 425.68, change: '+0.52%', isUp: true,
    iconColor: Color(0xFF00A4EF), iconLabel: 'M', tvSymbol: 'NASDAQ:MSFT', decimals: 2, assetClass: FuturesAssetClass.saham,
  ),
  FuturesContract(
    id: 'GOOGL', name: 'Alphabet Inc.', quote: 'USD', price: 178.24, change: '+0.91%', isUp: true,
    iconColor: Color(0xFF4285F4), iconLabel: 'G', tvSymbol: 'NASDAQ:GOOGL', decimals: 2, assetClass: FuturesAssetClass.saham,
  ),
  FuturesContract(
    id: 'AMZN', name: 'Amazon.com Inc.', quote: 'USD', price: 205.42, change: '+1.48%', isUp: true,
    iconColor: Color(0xFFFF9900), iconLabel: 'A', tvSymbol: 'NASDAQ:AMZN', decimals: 2, assetClass: FuturesAssetClass.saham,
  ),
  FuturesContract(
    id: 'TSLA', name: 'Tesla Inc.', quote: 'USD', price: 248.32, change: '-1.87%', isUp: false,
    iconColor: Color(0xFFE31937), iconLabel: 'T', tvSymbol: 'NASDAQ:TSLA', decimals: 2, assetClass: FuturesAssetClass.saham,
  ),
  FuturesContract(
    id: 'NVDA', name: 'NVIDIA Corp.', quote: 'USD', price: 135.18, change: '+3.14%', isUp: true,
    iconColor: Color(0xFF76B900), iconLabel: 'N', tvSymbol: 'NASDAQ:NVDA', decimals: 2, assetClass: FuturesAssetClass.saham,
  ),
  FuturesContract(
    id: 'META', name: 'Meta Platforms', quote: 'USD', price: 590.12, change: '+1.75%', isUp: true,
    iconColor: Color(0xFF0866FF), iconLabel: 'M', tvSymbol: 'NASDAQ:META', decimals: 2, assetClass: FuturesAssetClass.saham,
  ),
];

List<FuturesContract> contractsFor(FuturesAssetClass assetClass) => switch (assetClass) {
      FuturesAssetClass.crypto => kFuturesCryptoContracts,
      FuturesAssetClass.forex => kFuturesForexContracts,
      FuturesAssetClass.saham => kFuturesStockContracts,
    };

/// Every contract across all three asset classes — used to resolve a mark
/// price for an existing position even if the page has since switched to
/// a different asset-class tab.
List<FuturesContract> get kAllFuturesContracts =>
    [...kFuturesCryptoContracts, ...kFuturesForexContracts, ...kFuturesStockContracts];

/// "112,450" / "0.5212" style thousands-separated formatting — same spirit
/// as [formatPrice] in the spot trading model, just US-style (comma
/// thousands, dot decimal) since this page is USD/USDT-denominated.
String formatUsdt(double value, int decimals) {
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
