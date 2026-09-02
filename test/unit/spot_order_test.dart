import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/features/trading/domain/models/spot_order.dart';
import 'package:flutter_application_1/features/trading/domain/models/trading_pair.dart';

void main() {
  final btc = kTradingPairs.first; // id 'BTC'

  group('orderTypeToJson', () {
    test('maps each OrderType to the string the backend expects', () {
      expect(orderTypeToJson(OrderType.instant), 'market');
      expect(orderTypeToJson(OrderType.limit), 'limit');
      expect(orderTypeToJson(OrderType.stopLimit), 'stop_limit');
    });
  });

  group('SpotOrder.fromJson', () {
    test('parses a filled market buy order', () {
      final order = SpotOrder.fromJson({
        'id': 'abc123',
        'asset_id': 'BTC',
        'side': 'buy',
        'order_type': 'market',
        'price': 1150000000.0,
        'amount': 0.01,
        'status': 'filled',
        'created_at': '2026-01-01T00:00:00',
      }, btc);

      expect(order.id, 'abc123');
      expect(order.pair, btc);
      expect(order.side, SpotOrderSide.buy);
      expect(order.orderType, OrderType.instant);
      expect(order.price, 1150000000.0);
      expect(order.amount, 0.01);
      expect(order.status, SpotOrderStatus.filled);
      expect(order.total, closeTo(11500000.0, 0.01));
    });

    test('parses a sell side', () {
      final order = SpotOrder.fromJson({
        'id': 'x',
        'asset_id': 'BTC',
        'side': 'sell',
        'order_type': 'limit',
        'price': 1000.0,
        'amount': 1.0,
        'status': 'open',
        'created_at': '2026-01-01T00:00:00',
      }, btc);
      expect(order.side, SpotOrderSide.sell);
      expect(order.orderType, OrderType.limit);
      expect(order.status, SpotOrderStatus.open);
    });

    test('parses a cancelled stop_limit order', () {
      final order = SpotOrder.fromJson({
        'id': 'x',
        'asset_id': 'BTC',
        'side': 'buy',
        'order_type': 'stop_limit',
        'price': 1000.0,
        'amount': 1.0,
        'status': 'cancelled',
        'created_at': '2026-01-01T00:00:00',
      }, btc);
      expect(order.orderType, OrderType.stopLimit);
      expect(order.status, SpotOrderStatus.cancelled);
    });

    test('defaults an unrecognized status string to open rather than throwing', () {
      final order = SpotOrder.fromJson({
        'id': 'x',
        'asset_id': 'BTC',
        'side': 'buy',
        'order_type': 'market',
        'price': 1000.0,
        'amount': 1.0,
        'status': 'something-unexpected',
        'created_at': '2026-01-01T00:00:00',
      }, btc);
      expect(order.status, SpotOrderStatus.open);
    });
  });
}
