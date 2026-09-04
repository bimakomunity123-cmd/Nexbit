import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/core/i18n/strings.dart';
import 'package:flutter_application_1/core/prefs/app_prefs.dart';
import 'package:flutter_application_1/features/account/presentation/pages/nexbit_security_page.dart';
import 'package:flutter_application_1/features/account/presentation/widgets/account_widgets.dart';

// 2FA is now real backend state (see NexbitSecurityPage's own doc
// comment) fetched from /auth/me in initState, so — same convention as
// every other page in this app that fetches on init (Profil Saya,
// Verifikasi Identitas) — its actual on/off value isn't asserted here;
// that would mean either mocking the network or letting a real request
// fire during `flutter test`, neither of which this codebase does.
// Biometric stays a local-only preference (no real device biometric to
// back it — see the page's doc comment), so its persistence is still
// directly testable.
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

  testWidgets('renders a 2FA row and biometric defaults to on', (tester) async {
    await tester.pumpWidget(wrap(const NexbitSecurityPage()));
    await tester.pump();

    expect(switchInRowLabeled(S.security2fa), findsOneWidget);
    expect(tester.widget<Switch>(switchInRowLabeled(S.securityBiometric)).value, true);
  });

  testWidgets('toggling biometric off persists across a fresh mount', (tester) async {
    await tester.pumpWidget(wrap(const NexbitSecurityPage()));
    await tester.pump();

    await tester.tap(switchInRowLabeled(S.securityBiometric));
    await tester.pump();
    expect(tester.widget<Switch>(switchInRowLabeled(S.securityBiometric)).value, false);

    // Remount as a fresh page (like a real navigate-away-and-back) —
    // AppPrefs should be what makes the toggle survive that.
    await tester.pumpWidget(wrap(const SizedBox()));
    await tester.pump();
    await tester.pumpWidget(wrap(const NexbitSecurityPage()));
    await tester.pump();

    expect(tester.widget<Switch>(switchInRowLabeled(S.securityBiometric)).value, false);
  });
}
