import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/core/auth/session.dart';
import 'package:flutter_application_1/core/i18n/strings.dart';
import 'package:flutter_application_1/features/futures/domain/models/futures_contract.dart';
import 'package:flutter_application_1/features/futures/domain/models/futures_position.dart';
import 'package:flutter_application_1/features/futures/presentation/widgets/futures_order_form_panel.dart';

void main() {
  final btc = kFuturesCryptoContracts.first; // id 'BTC'

  tearDown(() => clearSession());

  Widget wrap(Widget child) => MaterialApp(
        home: Scaffold(body: SizedBox(width: 900, height: 800, child: child)),
      );

  testWidgets('a guest tapping Long sees the login-required snackbar and onOpenPosition is never called', (
    tester,
  ) async {
    isLoggedIn.value = false;
    var called = false;

    await tester.pumpWidget(wrap(FuturesOrderFormPanel(
      contract: btc,
      availableBalance: 0,
      onOpenPosition: (p) async {
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
      onOpenPosition: (p) async {
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

  testWidgets('submitting a valid Long calls onOpenPosition with the typed size and side, and clears on success', (
    tester,
  ) async {
    isLoggedIn.value = true;
    FuturesPosition? captured;

    await tester.pumpWidget(wrap(FuturesOrderFormPanel(
      contract: btc,
      availableBalance: 1250,
      onOpenPosition: (p) async {
        captured = p;
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
    expect(captured!.contract.id, btc.id);

    final cleared = tester.widget<TextField>(amountField);
    expect(cleared.controller!.text, '');
  });

  testWidgets('does not clear the amount field when the submission fails', (tester) async {
    isLoggedIn.value = true;

    await tester.pumpWidget(wrap(FuturesOrderFormPanel(
      contract: btc,
      availableBalance: 1250,
      onOpenPosition: (p) async => false,
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
}
