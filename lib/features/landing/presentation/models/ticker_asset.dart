import 'package:flutter/material.dart';

class TickerAsset {
  final String name;
  final String symbol;
  final String iconLabel;
  final Color iconColor;
  final String price;
  final String change;
  final bool isUp;

  const TickerAsset({
    required this.name,
    required this.symbol,
    required this.iconLabel,
    required this.iconColor,
    required this.price,
    required this.change,
    required this.isUp,
  });
}

/// Sample data — swap for your live feed (websocket/REST) later.
const kSampleTickers = <TickerAsset>[
  TickerAsset(
    name: 'Bitcoin',
    symbol: 'BTC',
    iconLabel: '₿',
    iconColor: Color(0xFFF7931A),
    price: '1.147.629.543',
    change: '▲ 0.01%',
    isUp: true,
  ),
  TickerAsset(
    name: 'Ethereum',
    symbol: 'ETH',
    iconLabel: 'Ξ',
    iconColor: Color(0xFF627EEA),
    price: '34.194.451',
    change: '▲ 0.67%',
    isUp: true,
  ),
  TickerAsset(
    name: 'Tether USD',
    symbol: 'USDT',
    iconLabel: 'T',
    iconColor: Color(0xFF26A17B),
    price: '17.871',
    change: '▼ 0.15%',
    isUp: false,
  ),
  TickerAsset(
    name: 'Ripple',
    symbol: 'XRP',
    iconLabel: 'X',
    iconColor: Color(0xFF345D9D),
    price: '17.990',
    change: '▲ 0.48%',
    isUp: true,
  ),
];
