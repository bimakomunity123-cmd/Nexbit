import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/core/auth/session.dart';

void main() {
  group('displayNameFromEmail', () {
    test('capitalizes the first letter of the local part', () {
      expect(displayNameFromEmail('budi.santoso@gmail.com'), 'Budi.santoso');
    });

    test('handles an already-capitalized local part', () {
      expect(displayNameFromEmail('Ani@example.com'), 'Ani');
    });

    test('handles a single-character local part', () {
      expect(displayNameFromEmail('a@example.com'), 'A');
    });

    test('returns an empty string for an email with no local part', () {
      expect(displayNameFromEmail('@example.com'), '');
    });
  });

  group('clearSession', () {
    test('resets every session ValueNotifier to its logged-out default', () {
      isLoggedIn.value = true;
      currentUserName.value = 'Budi';
      currentUserEmail.value = 'budi@example.com';
      authToken.value = 'some-jwt-token';

      clearSession();

      expect(isLoggedIn.value, false);
      expect(currentUserName.value, '');
      expect(currentUserEmail.value, '');
      expect(authToken.value, '');
    });
  });
}
