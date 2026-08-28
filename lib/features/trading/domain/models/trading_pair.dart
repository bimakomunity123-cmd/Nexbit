import 'package:flutter/material.dart';

enum AssetCategory { crypto, forex }

enum OrderType { limit, instant, stopLimit }

extension OrderTypeLabel on OrderType {
  String get label => switch (this) {
        OrderType.limit => 'Limit',
        OrderType.instant => 'Instant',
        OrderType.stopLimit => 'Stop-Limit',
      };
}

class TradingPair {
  final String id; // e.g. 'BTC', 'XAU'
  final String name; // e.g. 'Bitcoin', 'Gold Spot'
  final AssetCategory category;
  final String quote; // e.g. 'IDR', 'USD', 'JPY'
  final double base; // reference/mock price
  final int decimals; // display precision for this pair
  final String change; // e.g. '+0.01%'
  final bool isUp;
  final String tvSymbol; // TradingView symbol, e.g. 'BINANCE:BTCIDR'
  final Color iconColor;
  final String iconLabel;

  const TradingPair({
    required this.id,
    required this.name,
    required this.category,
    required this.quote,
    required this.base,
    required this.decimals,
    required this.change,
    required this.isUp,
    required this.tvSymbol,
    required this.iconColor,
    required this.iconLabel,
  });

  String get label => '$id/$quote';
}

/// Sample pairs — crypto priced in IDR + common forex majors.
/// Forex base prices are illustrative placeholders for the mockup;
/// wire these to a real feed (REST/WebSocket) in production.
const kTradingPairs = <TradingPair>[
  // --- crypto ---
  TradingPair(
    id: 'BTC', name: 'Bitcoin', category: AssetCategory.crypto, quote: 'IDR',
    base: 1149869827, decimals: 0, change: '+0.01%', isUp: true,
    tvSymbol: 'BINANCE:BTCIDR', iconColor: Color(0xFFF7931A), iconLabel: '₿',
  ),
  TradingPair(
    id: 'ETH', name: 'Ethereum', category: AssetCategory.crypto, quote: 'IDR',
    base: 34194451, decimals: 0, change: '+0.67%', isUp: true,
    tvSymbol: 'BINANCE:ETHIDR', iconColor: Color(0xFF627EEA), iconLabel: 'Ξ',
  ),
  TradingPair(
    id: 'USDT', name: 'Tether USD', category: AssetCategory.crypto, quote: 'IDR',
    base: 17871, decimals: 0, change: '-0.15%', isUp: false,
    tvSymbol: 'USDTIDR', iconColor: Color(0xFF26A17B), iconLabel: 'T',
  ),
  TradingPair(
    id: 'XRP', name: 'Ripple', category: AssetCategory.crypto, quote: 'IDR',
    base: 17990, decimals: 0, change: '+0.48%', isUp: true,
    tvSymbol: 'XRPIDR', iconColor: Color(0xFF345D9D), iconLabel: 'X',
  ),
  TradingPair(
    id: 'DOGE', name: 'Doge Coin', category: AssetCategory.crypto, quote: 'IDR',
    base: 1350, decimals: 0, change: '+0.16%', isUp: true,
    tvSymbol: 'DOGEIDR', iconColor: Color(0xFFC2A633), iconLabel: 'D',
  ),
  TradingPair(
    id: 'XLM', name: 'Stellar', category: AssetCategory.crypto, quote: 'IDR',
    base: 2904, decimals: 0, change: '+1.52%', isUp: true,
    tvSymbol: 'XLMIDR', iconColor: Color(0xFF7D00FF), iconLabel: 'X',
  ),
  TradingPair(
    id: 'LTC', name: 'Litecoin', category: AssetCategory.crypto, quote: 'IDR',
    base: 794414, decimals: 0, change: '-0.05%', isUp: false,
    tvSymbol: 'LTCIDR', iconColor: Color(0xFF345D9D), iconLabel: 'L',
  ),
  TradingPair(
    id: 'SOL', name: 'Solana', category: AssetCategory.crypto, quote: 'IDR',
    base: 3412900, decimals: 0, change: '+2.10%', isUp: true,
    tvSymbol: 'SOLIDR', iconColor: Color(0xFF14F195), iconLabel: 'S',
  ),
  TradingPair(
    id: 'ADA', name: 'Cardano', category: AssetCategory.crypto, quote: 'IDR',
    base: 12408, decimals: 0, change: '-0.32%', isUp: false,
    tvSymbol: 'ADAIDR', iconColor: Color(0xFF0033AD), iconLabel: 'A',
  ),
  // --- forex majors + gold ---
  TradingPair(
    id: 'XAU', name: 'Gold Spot', category: AssetCategory.forex, quote: 'USD',
    base: 2650.40, decimals: 2, change: '+0.42%', isUp: true,
    tvSymbol: 'OANDA:XAUUSD', iconColor: Color(0xFFF0B429), iconLabel: 'Au',
  ),
  TradingPair(
    id: 'EUR', name: 'Euro', category: AssetCategory.forex, quote: 'USD',
    base: 1.0850, decimals: 4, change: '+0.12%', isUp: true,
    tvSymbol: 'OANDA:EURUSD', iconColor: Color(0xFF2F5FD6), iconLabel: 'EU',
  ),
  TradingPair(
    id: 'USD', name: 'US Dollar / Yen', category: AssetCategory.forex, quote: 'JPY',
    base: 151.20, decimals: 3, change: '-0.18%', isUp: false,
    tvSymbol: 'OANDA:USDJPY', iconColor: Color(0xFFC62839), iconLabel: 'JP',
  ),
  TradingPair(
    id: 'GBP', name: 'British Pound', category: AssetCategory.forex, quote: 'USD',
    base: 1.2650, decimals: 4, change: '+0.24%', isUp: true,
    tvSymbol: 'OANDA:GBPUSD', iconColor: Color(0xFF0B3D91), iconLabel: 'GB',
  ),
  TradingPair(
    id: 'AUD', name: 'Australian Dollar', category: AssetCategory.forex, quote: 'USD',
    base: 0.6520, decimals: 4, change: '-0.09%', isUp: false,
    tvSymbol: 'OANDA:AUDUSD', iconColor: Color(0xFF1F8A45), iconLabel: 'AU',
  ),
  TradingPair(
    id: 'CHF', name: 'Swiss Franc', category: AssetCategory.forex, quote: 'USD',
    base: 0.8850, decimals: 4, change: '+0.06%', isUp: true,
    tvSymbol: 'OANDA:USDCHF', iconColor: Color(0xFFC62839), iconLabel: 'CH',
  ),
  TradingPair(
    id: 'CAD', name: 'Canadian Dollar', category: AssetCategory.forex, quote: 'USD',
    base: 1.3750, decimals: 4, change: '-0.14%', isUp: false,
    tvSymbol: 'OANDA:USDCAD', iconColor: Color(0xFFC62839), iconLabel: 'CA',
  ),
  TradingPair(
    id: 'NZD', name: 'New Zealand Dollar', category: AssetCategory.forex, quote: 'USD',
    base: 0.5980, decimals: 4, change: '+0.31%', isUp: true,
    tvSymbol: 'OANDA:NZDUSD', iconColor: Color(0xFF1F5FD6), iconLabel: 'NZ',
  ),
];

/// "1.149.869.827" style formatting (Indonesian thousands separator,
/// comma decimal) with zero extra dependencies (no `intl` package).
String formatPrice(double value, int decimals) {
  final isNeg = value < 0;
  final fixed = value.abs().toStringAsFixed(decimals);
  final parts = fixed.split('.');
  final intPart = parts[0];
  final buf = StringBuffer();
  for (var i = 0; i < intPart.length; i++) {
    final posFromEnd = intPart.length - i;
    buf.write(intPart[i]);
    if (posFromEnd > 1 && posFromEnd % 3 == 1) buf.write('.');
  }
  final result = decimals > 0 ? '${buf.toString()},${parts[1]}' : buf.toString();
  return isNeg ? '-$result' : result;
}
