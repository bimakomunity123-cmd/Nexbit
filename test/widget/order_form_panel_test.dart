import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/core/auth/session.dart';
import 'package:flutter_application_1/core/i18n/strings.dart';
import 'package:flutter_application_1/features/trading/domain/models/spot_order.dart';
import 'package:flutter_application_1/features/trading/domain/models/trading_pair.dart';
import 'package:flutter_application_1/features/trading/presentation/widgets/order_form_panel.dart';

void main() {
  final btc = kTradingPairs.first; // id 'BTC'

  tearDown(() => clearSession());

  Widget wrap(Widget child) => MaterialApp(
        home: Scaffold(body: SizedBox(width: 900, height: 800, child: child)),
      );

  testWidgets('a guest tapping Beli sees the login-required snackbar, no matter the amount', (tester) async {
    isLoggedIn.value = false;
    var submitCalled = false;

    await tester.pumpWidget(wrap(OrderFormPanel(
      pair: btc,
      idrBalance: 0,
      holdingQuantityOf: (_) => 0,
      onSubmitOrder: (side, type, price, amount) async {
        submitCalled = true;
        return true;
      },
    )));
    await tester.pump();

    await tester.tap(find.widgetWithText(ElevatedButton, S.buyAction(btc.id)));
    await tester.pump();

    expect(find.text(S.tradingLoginRequiredSnack), findsOneWidget);
    expect(submitCalled, false);
  });

  testWidgets('a logged-in user tapping Beli with no amount typed sees the amount-required snackbar', (tester) async {
    isLoggedIn.value = true;
    var submitCalled = false;

    await tester.pumpWidget(wrap(OrderFormPanel(
      pair: btc,
      idrBalance: 50000000,
      holdingQuantityOf: (_) => 0,
      onSubmitOrder: (side, type, price, amount) async {
        submitCalled = true;
        return true;
      },
    )));
    await tester.pump();

    await tester.tap(find.widgetWithText(ElevatedButton, S.buyAction(btc.id)));
    await tester.pump();

    expect(find.text(S.tradingAmountRequired), findsOneWidget);
    expect(submitCalled, false);
  });

  testWidgets('submitting a valid buy calls onSubmitOrder with the typed amount and clears the field on success', (
    tester,
  ) async {
    isLoggedIn.value = true;
    SpotOrderSide? capturedSide;
    double? capturedAmount;

    await tester.pumpWidget(wrap(OrderFormPanel(
      pair: btc,
      idrBalance: 50000000,
      holdingQuantityOf: (_) => 0,
      onSubmitOrder: (side, type, price, amount) async {
        capturedSide = side;
        capturedAmount = amount;
        return true;
      },
    )));
    await tester.pump();

    // Default tab is Limit, which renders [Harga, Jumlah] for both the
    // Buy (left/first) and Sell (right/second) columns in that order —
    // index 1 is Buy's Jumlah field.
    final amountField = find.byType(TextField).at(1);
    await tester.enterText(amountField, '0.5');
    await tester.pump();

    await tester.tap(find.widgetWithText(ElevatedButton, S.buyAction(btc.id)));
    await tester.pump(); // starts the async onSubmitOrder
    await tester.pump(); // lets its returned Future resolve

    expect(capturedSide, SpotOrderSide.buy);
    expect(capturedAmount, 0.5);

    final clearedField = tester.widget<TextField>(amountField);
    expect(clearedField.controller!.text, '');
  });

  testWidgets('does not clear the amount field when the submission fails', (tester) async {
    isLoggedIn.value = true;

    await tester.pumpWidget(wrap(OrderFormPanel(
      pair: btc,
      idrBalance: 50000000,
      holdingQuantityOf: (_) => 0,
      onSubmitOrder: (side, type, price, amount) async => false,
    )));
    await tester.pump();

    final amountField = find.byType(TextField).at(1);
    await tester.enterText(amountField, '0.5');
    await tester.pump();

    await tester.tap(find.widgetWithText(ElevatedButton, S.buyAction(btc.id)));
    await tester.pump();
    await tester.pump();

    final stillFilled = tester.widget<TextField>(amountField);
    expect(stillFilled.controller!.text, '0.5');
  });
}
