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

/// Thin wrapper around the auth endpoints in backend/app/routers/auth.py.
/// Deliberately minimal — no retry/backoff/interceptor machinery, this
/// app doesn't need it yet.
class ApiClient {
  ApiClient._();

  static Uri _uri(String path) => Uri.parse('$kApiBaseUrl$path');

  static Map<String, String> get _jsonHeaders => const {'Content-Type': 'application/json'};

  static Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> body, {String? token}) async {
    http.Response res;
    try {
      res = await http.post(
        _uri(path),
        headers: {
          ..._jsonHeaders,
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );
    } catch (_) {
      // Covers connection refused / DNS failure / CORS-blocked — the
      // backend not running or not reachable from wherever this is
      // loaded, which is the common case until it's actually deployed.
      throw ApiException(0, 'Tidak bisa terhubung ke server. Pastikan backend berjalan.');
    }

    final decoded = res.body.isEmpty ? <String, dynamic>{} : jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode >= 200 && res.statusCode < 300) return decoded;

    final detail = decoded['detail'];
    throw ApiException(res.statusCode, detail is String ? detail : 'Terjadi kesalahan (${res.statusCode})');
  }

  static Future<Map<String, dynamic>> register({required String name, required String email, required String password}) {
    return _post('/auth/register', {'name': name, 'email': email, 'password': password});
  }

  static Future<Map<String, dynamic>> login({required String email, required String password}) {
    return _post('/auth/login', {'email': email, 'password': password});
  }

  static Future<Map<String, dynamic>> me(String token) async {
    http.Response res;
    try {
      res = await http.get(_uri('/auth/me'), headers: {'Authorization': 'Bearer $token'});
    } catch (_) {
      throw ApiException(0, 'Tidak bisa terhubung ke server.');
    }
    final decoded = res.body.isEmpty ? <String, dynamic>{} : jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode >= 200 && res.statusCode < 300) return decoded;
    final detail = decoded['detail'];
    throw ApiException(res.statusCode, detail is String ? detail : 'Sesi tidak valid');
  }
}
