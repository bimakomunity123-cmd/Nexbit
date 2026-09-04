import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/core/i18n/strings.dart';
import 'package:flutter_application_1/features/futures/domain/models/futures_contract.dart';
import 'package:flutter_application_1/features/futures/domain/models/futures_order.dart';
import 'package:flutter_application_1/features/futures/domain/models/futures_position.dart';
import 'package:flutter_application_1/features/futures/presentation/widgets/futures_positions_panel.dart';

void main() {
  final btc = kFuturesCryptoContracts.first; // id 'BTC'

  Widget wrap(Widget child) => MaterialApp(
        home: Scaffold(body: SizedBox(width: 900, height: 800, child: child)),
      );

  testWidgets('Trade History tab shows the empty state when there is no closed position', (tester) async {
    await tester.pumpWidget(wrap(FuturesPositionsPanel(
      positions: const [],
      markPriceOf: (_) => 70000,
      onClose: (_) {},
      onCancelOrder: (_) {},
    )));
    await tester.pump();

    await tester.tap(find.text(S.futuresTabTradeHistory));
    await tester.pump();

    expect(find.text(S.futuresNoHistory), findsOneWidget);
  });

  testWidgets('Trade History tab renders a real closed position row', (tester) async {
    final closed = ClosedFuturesPosition(
      id: 'p1',
      contract: btc,
      side: OrderSide.long,
      size: 0.1,
      entryPrice: 70000,
      exitPrice: 71000,
      realizedPnl: 100,
      closedAt: DateTime(2026, 1, 15, 9, 30),
    );

    await tester.pumpWidget(wrap(FuturesPositionsPanel(
      positions: const [],
      markPriceOf: (_) => 70000,
      onClose: (_) {},
      onCancelOrder: (_) {},
      closedPositions: [closed],
    )));
    await tester.pump();

    await tester.tap(find.text(S.futuresTabTradeHistory));
    await tester.pump();

    expect(find.text(S.futuresNoHistory), findsNothing);
    expect(find.text(S.futuresLong), findsOneWidget);
    expect(find.textContaining('+100.00'), findsOneWidget);
    expect(find.textContaining('15/01'), findsOneWidget);
  });

  FuturesOrder buildOrder({required FuturesOrderStatus status, FuturesOrderType type = FuturesOrderType.limit}) {
    return FuturesOrder(
      id: 'o1',
      contract: btc,
      side: OrderSide.long,
      orderType: type,
      price: 65000,
      size: 0.2,
      leverage: 10,
      marginMode: MarginMode.isolated,
      status: status,
      createdAt: DateTime(2026, 1, 15, 9, 30),
    );
  }

  testWidgets('Open Orders tab shows the empty state when there is no open order', (tester) async {
    await tester.pumpWidget(wrap(FuturesPositionsPanel(
      positions: const [],
      markPriceOf: (_) => 70000,
      onClose: (_) {},
      onCancelOrder: (_) {},
    )));
    await tester.pump();

    await tester.tap(find.text(S.futuresTabOpenOrders(0)));
    await tester.pump();

    expect(find.text(S.futuresNoOpenOrders), findsOneWidget);
  });

  testWidgets('Open Orders tab renders an open order and its Cancel action', (tester) async {
    FuturesOrder? cancelled;
    final order = buildOrder(status: FuturesOrderStatus.open);

    await tester.pumpWidget(wrap(FuturesPositionsPanel(
      positions: const [],
      markPriceOf: (_) => 70000,
      onClose: (_) {},
      orders: [order],
      onCancelOrder: (o) => cancelled = o,
    )));
    await tester.pump();

    await tester.tap(find.text(S.futuresTabOpenOrders(1)));
    await tester.pump();

    expect(find.text(S.orderStatusOpen), findsOneWidget);
    expect(find.text(S.orderCancelAction), findsOneWidget);

    await tester.tap(find.text(S.orderCancelAction));
    expect(cancelled, order);
  });

  testWidgets('Order History tab shows a cancelled order without a Cancel action', (tester) async {
    final order = buildOrder(status: FuturesOrderStatus.cancelled);

    await tester.pumpWidget(wrap(FuturesPositionsPanel(
      positions: const [],
      markPriceOf: (_) => 70000,
      onClose: (_) {},
      orders: [order],
      onCancelOrder: (_) {},
    )));
    await tester.pump();

    await tester.tap(find.text(S.futuresTabOrderHistory));
    await tester.pump();

    expect(find.text(S.orderStatusCancelled), findsOneWidget);
    expect(find.text(S.orderCancelAction), findsNothing);
  });
}
