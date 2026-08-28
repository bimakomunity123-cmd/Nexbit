import 'package:flutter/foundation.dart';

/// App-wide "am I signed in" flag — no real backend/token behind it, just
/// enough state so the navbar shows Masuk/Daftar vs. an account menu
/// consistently on every page, instead of every page pretending you're
/// always logged out even right after a successful login/register. A
/// plain [ValueNotifier] (same "keep dependencies light" spirit as
/// [appLocale] in core/i18n/app_locale.dart).
final ValueNotifier<bool> isLoggedIn = ValueNotifier(false);

/// The signed-in account's display name/email, so the navbar's account
/// menu shows the name/email actually typed at login or registration
/// instead of a hardcoded placeholder like "John Doe". Login only
/// collects an email, so it derives a display name from it; Register
/// sets both from what was actually typed in the form.
final ValueNotifier<String> currentUserName = ValueNotifier('');
final ValueNotifier<String> currentUserEmail = ValueNotifier('');

/// The JWT issued by the real backend (see backend/) on register/login.
/// Kept in memory only — a reload loses it and the user is logged out,
/// same as [isLoggedIn] itself; there's no "remember me" persistence yet.
final ValueNotifier<String> authToken = ValueNotifier('');

/// Best-effort display name from an email's local part when only an
/// email was collected (the login form, unlike Register, has no separate
/// name field) — "budi.santoso@gmail.com" → "Budi.santoso".
String displayNameFromEmail(String email) {
  final local = email.split('@').first;
  if (local.isEmpty) return local;
  return local[0].toUpperCase() + local.substring(1);
}

/// Clears all session state — used by every logout/deactivate/delete
/// flow in the account pages and the navbar's account menu.
void clearSession() {
  isLoggedIn.value = false;
  currentUserName.value = '';
  currentUserEmail.value = '';
  authToken.value = '';
}
