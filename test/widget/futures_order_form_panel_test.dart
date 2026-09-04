import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/core/auth/session.dart';
import 'package:flutter_application_1/core/i18n/strings.dart';
import 'package:flutter_application_1/features/futures/domain/models/futures_contract.dart';
import 'package:flutter_application_1/features/futures/domain/models/futures_order.dart';
import 'package:flutter_application_1/features/futures/domain/models/futures_position.dart';
import 'package:flutter_application_1/features/futures/presentation/widgets/futures_order_form_panel.dart';

void main() {
  final btc = kFuturesCryptoContracts.first; // id 'BTC'

  tearDown(() => clearSession());

  Widget wrap(Widget child) => MaterialApp(
        home: Scaffold(body: SizedBox(width: 900, height: 800, child: child)),
      );

  testWidgets('a guest tapping Long sees the login-required snackbar and onSubmitOrder is never called', (
    tester,
  ) async {
    isLoggedIn.value = false;
    var called = false;

    await tester.pumpWidget(wrap(FuturesOrderFormPanel(
      contract: btc,
      availableBalance: 0,
      onSubmitOrder: (s) async {
        called = true;
        return true;
      },
    )));
    await tester.pump();

    await tester.tap(find.text(S.futuresLongBuy(btc.id)));
    await tester.pump();

    expect(find.text(S.futuresLoginRequiredSnack), findsOneWidget);
    expect(called, false);
  });

  testWidgets('a logged-in user tapping Long with no amount typed sees the amount-required snackbar', (tester) async {
    isLoggedIn.value = true;
    var called = false;

    await tester.pumpWidget(wrap(FuturesOrderFormPanel(
      contract: btc,
      availableBalance: 1250,
      onSubmitOrder: (s) async {
        called = true;
        return true;
      },
    )));
    await tester.pump();

    await tester.tap(find.text(S.futuresLongBuy(btc.id)));
    await tester.pump();

    expect(find.text(S.futuresAmountRequired), findsOneWidget);
    expect(called, false);
  });

  testWidgets('submitting a valid Long calls onSubmitOrder with the typed size and side, and clears on success', (
    tester,
  ) async {
    isLoggedIn.value = true;
    FuturesOrderSubmission? captured;

    await tester.pumpWidget(wrap(FuturesOrderFormPanel(
      contract: btc,
      availableBalance: 1250,
      onSubmitOrder: (s) async {
        captured = s;
        return true;
      },
    )));
    await tester.pump();

    // Default tab is Limit, whose only text field before the amount
    // field is the shared Price field — index 1 is Amount.
    final amountField = find.byType(TextField).at(1);
    await tester.enterText(amountField, '0.1');
    await tester.pump();

    await tester.tap(find.text(S.futuresLongBuy(btc.id)));
    await tester.pump();
    await tester.pump();

    expect(captured, isNotNull);
    expect(captured!.side, OrderSide.long);
    expect(captured!.size, 0.1);
    expect(captured!.orderType, FuturesOrderType.limit);
    expect(captured!.contract.id, btc.id);

    final cleared = tester.widget<TextField>(amountField);
    expect(cleared.controller!.text, '');
  });

  testWidgets('does not clear the amount field when the submission fails', (tester) async {
    isLoggedIn.value = true;

    await tester.pumpWidget(wrap(FuturesOrderFormPanel(
      contract: btc,
      availableBalance: 1250,
      onSubmitOrder: (s) async => false,
    )));
    await tester.pump();

    final amountField = find.byType(TextField).at(1);
    await tester.enterText(amountField, '0.1');
    await tester.pump();

    await tester.tap(find.text(S.futuresLongBuy(btc.id)));
    await tester.pump();
    await tester.pump();

    final stillFilled = tester.widget<TextField>(amountField);
    expect(stillFilled.controller!.text, '0.1');
  });

  testWidgets('switching to the Market tab and submitting sends orderType market', (tester) async {
    isLoggedIn.value = true;
    FuturesOrderSubmission? captured;

    await tester.pumpWidget(wrap(FuturesOrderFormPanel(
      contract: btc,
      availableBalance: 1250,
      onSubmitOrder: (s) async {
        captured = s;
        return true;
      },
    )));
    await tester.pump();

    await tester.tap(find.text(S.futuresTabMarket));
    await tester.pump();

    // Market hides the Price field, so Amount is now the first TextField.
    final amountField = find.byType(TextField).first;
    await tester.enterText(amountField, '0.1');
    await tester.pump();

    await tester.tap(find.text(S.futuresLongBuy(btc.id)));
    await tester.pump();
    await tester.pump();

    expect(captured, isNotNull);
    expect(captured!.orderType, FuturesOrderType.market);
    expect(captured!.price, btc.price);
  });
}
