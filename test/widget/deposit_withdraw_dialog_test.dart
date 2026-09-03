import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/core/i18n/strings.dart';
import 'package:flutter_application_1/core/widgets/amount_input_dialog.dart';

void main() {
  // The Deposit/Withdraw label appears twice once a direction is active
  // (the selected tab and the confirm button both show it) — the tab
  // sits in a GestureDetector, the confirm action is a TextButton, so
  // this disambiguates the same way the order-form-panel tests do.
  Finder confirmButton(String label) => find.widgetWithText(TextButton, label);

  Future<void> openDialog(
    WidgetTester tester, {
    required Future<String?> Function(double) onDeposit,
    required Future<String?> Function(double) onWithdraw,
  }) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showDepositWithdrawDialog(
              context: context,
              depositTitle: 'Deposit Title',
              withdrawTitle: 'Withdraw Title',
              unit: 'USDT',
              onDeposit: onDeposit,
              onWithdraw: onWithdraw,
            ),
            child: const Text('open'),
          ),
        ),
      ),
    ));
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
  }

  testWidgets('defaults to the Deposit tab and calls onDeposit', (tester) async {
    double? captured;
    await openDialog(
      tester,
      onDeposit: (amount) async {
        captured = amount;
        return null;
      },
      onWithdraw: (_) async => 'should not be called',
    );

    expect(find.text('Deposit Title'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '100');
    await tester.pump();
    await tester.tap(confirmButton(S.futuresDeposit));
    await tester.pump();
    await tester.pump();

    expect(captured, 100);
    expect(find.text('Deposit Title'), findsNothing); // dialog closed on success
  });

  testWidgets('switching to the Withdraw tab changes the title and calls onWithdraw', (tester) async {
    double? captured;
    await openDialog(
      tester,
      onDeposit: (_) async => 'should not be called',
      onWithdraw: (amount) async {
        captured = amount;
        return null;
      },
    );

    // Only the tab shows this label before switching — unambiguous.
    await tester.tap(find.text(S.withdrawLabel));
    await tester.pump();
    expect(find.text('Withdraw Title'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '50');
    await tester.pump();
    await tester.tap(confirmButton(S.withdrawLabel));
    await tester.pump();
    await tester.pump();

    expect(captured, 50);
  });

  testWidgets('shows the inline error and keeps the dialog open on failure', (tester) async {
    await openDialog(
      tester,
      onDeposit: (_) async => 'Saldo tidak cukup',
      onWithdraw: (_) async => 'should not be called',
    );

    await tester.enterText(find.byType(TextField), '100');
    await tester.pump();
    await tester.tap(confirmButton(S.futuresDeposit));
    await tester.pump();
    await tester.pump();

    expect(find.text('Saldo tidak cukup'), findsOneWidget);
    expect(find.text('Deposit Title'), findsOneWidget); // still open
  });
}
