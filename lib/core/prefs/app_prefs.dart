import 'package:shared_preferences/shared_preferences.dart';
import '../i18n/app_locale.dart';

/// Small persistence layer for the handful of settings that should
/// survive a page reload: the ID/EN language toggle, and the local
/// settings on the account menu's Preferensi/Keamanan pages. Everything
/// else in this demo — the login session, mock trading/positions data —
/// is deliberately kept in-memory only, same as before.
///
/// [init] must be awaited once, before [runApp], so [appLocale] already
/// carries its persisted value by the first frame. The Preferensi/
/// Keamanan pages then read/write their own keys directly through the
/// [getBool]/[setBool]/[getString]/[setString] helpers.
class AppPrefs {
  AppPrefs._();

  static SharedPreferences? _prefs;
  static const _kLocale = 'app_locale';

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    if (_prefs!.getString(_kLocale) == 'en') {
      appLocale.value = AppLocale.en;
    }
    appLocale.addListener(() {
      _prefs?.setString(_kLocale, appLocale.value == AppLocale.en ? 'en' : 'id');
    });
  }

  static bool getBool(String key, bool defaultValue) => _prefs?.getBool(key) ?? defaultValue;
  static Future<void> setBool(String key, bool value) async => _prefs?.setBool(key, value);
  static String getString(String key, String defaultValue) => _prefs?.getString(key) ?? defaultValue;
  static Future<void> setString(String key, String value) async => _prefs?.setString(key, value);
}
