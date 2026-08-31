import 'dart:convert';
import 'package:http/http.dart' as http;

/// Base URL for the backend in backend/ — live on PythonAnywhere's free
/// tier (see backend/DEPLOY_PYTHONANYWHERE.md). Override for local dev
/// against `python -m app.main` with
/// `flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8020`.
const String kApiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://morphy.pythonanywhere.com',
);

/// Thrown for any non-2xx response, carrying the backend's own error
/// message (Flask's `{"detail": "..."}` shape) so callers can show it
/// directly instead of a generic "something went wrong".
class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);

  @override
  String toString() => message;
}

/// Thin wrapper around backend/app/routers/{auth,trading}.py. Deliberately
/// minimal — no retry/backoff/interceptor machinery, this app doesn't
/// need it yet.
class ApiClient {
  ApiClient._();

  static Uri _uri(String path) => Uri.parse('$kApiBaseUrl$path');

  static Map<String, String> _headers({String? token}) => {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  /// Decodes a response body that's expected to be either a JSON object
  /// or array, throwing [ApiException] for any non-2xx status (reading
  /// the `{"detail": ...}` shape Flask's error handlers always send) or
  /// for a request that never reached the server at all (offline,
  /// backend down, CORS-blocked).
  static Future<dynamic> _send(Future<http.Response> Function() request) async {
    http.Response res;
    try {
      res = await request();
    } catch (_) {
      throw ApiException(0, 'Tidak bisa terhubung ke server. Pastikan backend berjalan.');
    }

    final dynamic decoded = res.body.isEmpty ? null : jsonDecode(res.body);
    if (res.statusCode >= 200 && res.statusCode < 300) return decoded;

    final detail = decoded is Map<String, dynamic> ? decoded['detail'] : null;
    throw ApiException(res.statusCode, detail is String ? detail : 'Terjadi kesalahan (${res.statusCode})');
  }

  static Future<Map<String, dynamic>> _postJson(String path, Map<String, dynamic> body, {String? token}) async {
    final decoded = await _send(() => http.post(_uri(path), headers: _headers(token: token), body: jsonEncode(body)));
    return decoded as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> _patchJson(String path, Map<String, dynamic> body, {String? token}) async {
    final decoded = await _send(() => http.patch(_uri(path), headers: _headers(token: token), body: jsonEncode(body)));
    return decoded as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> _getJson(String path, {String? token}) async {
    final decoded = await _send(() => http.get(_uri(path), headers: _headers(token: token)));
    return decoded as Map<String, dynamic>;
  }

  static Future<List<dynamic>> _getList(String path, {String? token}) async {
    final decoded = await _send(() => http.get(_uri(path), headers: _headers(token: token)));
    return decoded as List<dynamic>;
  }

  // ---- Auth ----

  static Future<Map<String, dynamic>> register({required String name, required String email, required String password}) {
    return _postJson('/auth/register', {'name': name, 'email': email, 'password': password});
  }

  static Future<Map<String, dynamic>> login({required String email, required String password}) {
    return _postJson('/auth/login', {'email': email, 'password': password});
  }

  static Future<Map<String, dynamic>> me(String token) => _getJson('/auth/me', token: token);

  static Future<Map<String, dynamic>> changePassword(String token, {required String oldPassword, required String newPassword}) {
    return _postJson('/auth/change-password', {'old_password': oldPassword, 'new_password': newPassword}, token: token);
  }

  static Future<Map<String, dynamic>> updateProfile(String token, {required String name}) {
    return _patchJson('/auth/profile', {'name': name}, token: token);
  }

  static Future<Map<String, dynamic>> forgotPassword(String email) {
    return _postJson('/auth/forgot-password', {'email': email});
  }

  static Future<Map<String, dynamic>> resetPassword({required String token, required String newPassword}) {
    return _postJson('/auth/reset-password', {'token': token, 'new_password': newPassword});
  }

  // ---- Trading (Futures balance/positions) ----

  static Future<Map<String, dynamic>> getAccount(String token) => _getJson('/trading/account', token: token);

  static Future<List<dynamic>> getPositions(String token) => _getList('/trading/positions', token: token);

  static Future<Map<String, dynamic>> openPosition(String token, Map<String, dynamic> body) {
    return _postJson('/trading/positions', body, token: token);
  }

  static Future<Map<String, dynamic>> closePosition(String token, String positionId, double realizedPnl) {
    return _postJson('/trading/positions/$positionId/close', {'realized_pnl': realizedPnl}, token: token);
  }
}
