import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/core/auth/session.dart';
import 'package:flutter_application_1/core/i18n/app_locale.dart';
import 'package:flutter_application_1/core/i18n/strings.dart';
import 'package:flutter_application_1/features/auth/presentation/pages/nexbit_login_page.dart';

/// NetworkBackground (behind every auth page) runs an infinite Ticker,
/// so pumpAndSettle() would time out waiting for it to stop animating —
/// every test here uses a single pump() (or a short bounded one) instead.
Widget _wrap(Widget child) => MaterialApp(home: child);

void main() {
  tearDown(() {
    clearSession();
    appLocale.value = AppLocale.id;
  });

  testWidgets('submitting with both fields empty shows the required-fields snackbar', (tester) async {
    await tester.pumpWidget(_wrap(const NexbitLoginPage()));
    await tester.pump();

    await tester.tap(find.text(S.loginSubmit));
    await tester.pump(); // lets the SnackBar start animating in

    expect(find.text(S.loginRequiredFields), findsOneWidget);
  });

  testWidgets('submitting with only an email filled in still shows the required-fields snackbar', (tester) async {
    await tester.pumpWidget(_wrap(const NexbitLoginPage()));
    await tester.pump();

    await tester.enterText(find.byType(TextField).first, 'someone@example.com');
    await tester.pump();
    await tester.tap(find.text(S.loginSubmit));
    await tester.pump();

    expect(find.text(S.loginRequiredFields), findsOneWidget);
  });

  testWidgets('renders the English heading when appLocale is en', (tester) async {
    appLocale.value = AppLocale.en;
    await tester.pumpWidget(_wrap(const NexbitLoginPage()));
    await tester.pump();

    expect(find.text(S.loginWelcomeBack), findsOneWidget);
    expect(find.text('Welcome Back to Nexbit'), findsOneWidget);
  });

  testWidgets('renders the Indonesian heading when appLocale is id', (tester) async {
    appLocale.value = AppLocale.id;
    await tester.pumpWidget(_wrap(const NexbitLoginPage()));
    await tester.pump();

    expect(find.text('Selamat Datang Kembali di Nexbit'), findsOneWidget);
  });

  testWidgets('the password field starts obscured and toggles when the eye icon is tapped', (tester) async {
    await tester.pumpWidget(_wrap(const NexbitLoginPage()));
    await tester.pump();

    TextField passwordField() => tester.widget<TextField>(find.byType(TextField).last);
    expect(passwordField().obscureText, true);

    await tester.tap(find.byIcon(Icons.visibility_off_outlined));
    await tester.pump();

    expect(passwordField().obscureText, false);
  });
}
