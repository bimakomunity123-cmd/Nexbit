import 'futures_contract.dart';
import 'futures_position.dart';

/// Mirrors backend/app/models.py's FuturesOrder.order_type — the same
/// four tabs FuturesOrderFormPanel already exposed, just now actually
/// sent to the backend instead of being a purely cosmetic toggle.
enum FuturesOrderType { limit, market, stopLimit, stopMarket }

enum FuturesOrderStatus { open, filled, cancelled }

FuturesOrderType futuresOrderTypeFromJson(String s) => switch (s) {
      'market' => FuturesOrderType.market,
      'stop_limit' => FuturesOrderType.stopLimit,
      'stop_market' => FuturesOrderType.stopMarket,
      _ => FuturesOrderType.limit,
    };

String futuresOrderTypeToJson(FuturesOrderType t) => switch (t) {
      FuturesOrderType.market => 'market',
      FuturesOrderType.stopLimit => 'stop_limit',
      FuturesOrderType.stopMarket => 'stop_market',
      FuturesOrderType.limit => 'limit',
    };

FuturesOrderStatus _statusFromJson(String s) => switch (s) {
      'filled' => FuturesOrderStatus.filled,
      'cancelled' => FuturesOrderStatus.cancelled,
      _ => FuturesOrderStatus.open,
    };

/// A Futures order — mirrors backend/app/models.py's FuturesOrder.
/// Separate from [FuturesPosition]: a 'market' order fills immediately
/// (status filled, and a position opens alongside it), while 'limit'/
/// 'stopLimit'/'stopMarket' orders are just recorded as open and never
/// auto-fill (this demo has no real matching engine — same accepted
/// limitation as Spot's SpotOrder). Backs the Futures page's Open
/// Orders/Order History tabs.
class FuturesOrder {
  final String id;
  final FuturesContract contract;
  final OrderSide side;
  final FuturesOrderType orderType;
  final double price;
  final double size;
  final int leverage;
  final MarginMode marginMode;
  final FuturesOrderStatus status;
  final DateTime createdAt;

  const FuturesOrder({
    required this.id,
    required this.contract,
    required this.side,
    required this.orderType,
    required this.price,
    required this.size,
    required this.leverage,
    required this.marginMode,
    required this.status,
    required this.createdAt,
  });

  FuturesOrder copyWith({FuturesOrderStatus? status}) => FuturesOrder(
        id: id,
        contract: contract,
        side: side,
        orderType: orderType,
        price: price,
        size: size,
        leverage: leverage,
        marginMode: marginMode,
        status: status ?? this.status,
        createdAt: createdAt,
      );

  factory FuturesOrder.fromJson(Map<String, dynamic> json, FuturesContract contract) {
    return FuturesOrder(
      id: json['id'] as String,
      contract: contract,
      side: json['side'] == 'short' ? OrderSide.short : OrderSide.long,
      orderType: futuresOrderTypeFromJson(json['order_type'] as String),
      price: (json['price'] as num).toDouble(),
      size: (json['size'] as num).toDouble(),
      leverage: (json['leverage'] as num).toInt(),
      marginMode: json['margin_mode'] == 'cross' ? MarginMode.cross : MarginMode.isolated,
      status: _statusFromJson(json['status'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

/// Everything FuturesOrderFormPanel needs to hand back to the page on
/// submit — bundled into one object instead of a long positional-args
/// callback.
class FuturesOrderSubmission {
  final FuturesContract contract;
  final OrderSide side;
  final FuturesOrderType orderType;
  final double price;
  final double size;
  final int leverage;
  final MarginMode marginMode;

  const FuturesOrderSubmission({
    required this.contract,
    required this.side,
    required this.orderType,
    required this.price,
    required this.size,
    required this.leverage,
    required this.marginMode,
  });
}
