import 'trading_pair.dart';

enum SpotOrderSide { buy, sell }

enum SpotOrderStatus { open, filled, cancelled }

SpotOrderStatus _statusFromJson(String s) => switch (s) {
      'filled' => SpotOrderStatus.filled,
      'cancelled' => SpotOrderStatus.cancelled,
      _ => SpotOrderStatus.open,
    };

OrderType _orderTypeFromJson(String s) => switch (s) {
      'market' => OrderType.instant,
      'stop_limit' => OrderType.stopLimit,
      _ => OrderType.limit,
    };

String orderTypeToJson(OrderType t) => switch (t) {
      OrderType.instant => 'market',
      OrderType.stopLimit => 'stop_limit',
      OrderType.limit => 'limit',
    };

/// A Spot buy/sell order — mirrors backend/app/models.py's SpotOrder.
/// [id] is null only for the brief moment between a submit and the
/// backend's response (same convention as FuturesPosition.id).
class SpotOrder {
  final String? id;
  final TradingPair pair;
  final SpotOrderSide side;
  final OrderType orderType;
  final double price;
  final double amount;
  final SpotOrderStatus status;
  final DateTime createdAt;

  const SpotOrder({
    this.id,
    required this.pair,
    required this.side,
    required this.orderType,
    required this.price,
    required this.amount,
    required this.status,
    required this.createdAt,
  });

  double get total => price * amount;

  factory SpotOrder.fromJson(Map<String, dynamic> json, TradingPair pair) {
    return SpotOrder(
      id: json['id'] as String,
      pair: pair,
      side: json['side'] == 'sell' ? SpotOrderSide.sell : SpotOrderSide.buy,
      orderType: _orderTypeFromJson(json['order_type'] as String),
      price: (json['price'] as num).toDouble(),
      amount: (json['amount'] as num).toDouble(),
      status: _statusFromJson(json['status'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
