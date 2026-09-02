import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/core/i18n/strings.dart';
import 'package:flutter_application_1/features/futures/domain/models/futures_contract.dart';
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
}
