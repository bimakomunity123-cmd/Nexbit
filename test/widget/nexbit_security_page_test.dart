import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/core/i18n/strings.dart';
import 'package:flutter_application_1/core/prefs/app_prefs.dart';
import 'package:flutter_application_1/features/account/presentation/pages/nexbit_security_page.dart';
import 'package:flutter_application_1/features/account/presentation/widgets/account_widgets.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppPrefs.init();
  });

  Widget wrap(Widget child) => MaterialApp(home: child);

  Finder switchInRowLabeled(String label) => find.descendant(
        of: find.ancestor(of: find.text(label), matching: find.byType(AccountInfoRow)),
        matching: find.byType(Switch),
      );

  testWidgets('2FA defaults to off and biometric defaults to on', (tester) async {
    await tester.pumpWidget(wrap(const NexbitSecurityPage()));
    await tester.pump();

    expect(tester.widget<Switch>(switchInRowLabeled(S.security2fa)).value, false);
    expect(tester.widget<Switch>(switchInRowLabeled(S.securityBiometric)).value, true);
  });

  testWidgets('toggling 2FA updates the switch immediately and persists across a fresh mount', (tester) async {
    await tester.pumpWidget(wrap(const NexbitSecurityPage()));
    await tester.pump();

    await tester.tap(switchInRowLabeled(S.security2fa));
    await tester.pump();
    expect(tester.widget<Switch>(switchInRowLabeled(S.security2fa)).value, true);

    // Remount as a fresh page (like a real navigate-away-and-back) —
    // AppPrefs should be what makes the toggle survive that.
    await tester.pumpWidget(wrap(const SizedBox()));
    await tester.pump();
    await tester.pumpWidget(wrap(const NexbitSecurityPage()));
    await tester.pump();

    expect(tester.widget<Switch>(switchInRowLabeled(S.security2fa)).value, true);
  });

  testWidgets('toggling biometric off persists independently of 2FA', (tester) async {
    await tester.pumpWidget(wrap(const NexbitSecurityPage()));
    await tester.pump();

    await tester.tap(switchInRowLabeled(S.securityBiometric));
    await tester.pump();
    expect(tester.widget<Switch>(switchInRowLabeled(S.securityBiometric)).value, false);

    await tester.pumpWidget(wrap(const SizedBox()));
    await tester.pump();
    await tester.pumpWidget(wrap(const NexbitSecurityPage()));
    await tester.pump();

    expect(tester.widget<Switch>(switchInRowLabeled(S.securityBiometric)).value, false);
    // 2FA (untouched) should still be at its own default.
    expect(tester.widget<Switch>(switchInRowLabeled(S.security2fa)).value, false);
  });
}
