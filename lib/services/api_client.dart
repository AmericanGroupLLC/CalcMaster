import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class ApiClient {
  ApiClient._();
  static final instance = ApiClient._();

  // Fail fast when the backend is unreachable/unresponsive rather than hanging
  // the UI. On timeout the underlying call throws [TimeoutException], which
  // callers treat as a connectivity failure.
  static const Duration _timeout = Duration(seconds: 20);

  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.safecodeg.com/api/v1',
  );

  // Auth is owned by Supabase; gateway calls carry the current Supabase JWT.
  Session? get _session => Supabase.instance.client.auth.currentSession;
  String? get _accessToken => _session?.accessToken;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
      };

  bool get isAuthenticated => _accessToken != null;

  Future<Map<String, dynamic>> getProfile() async =>
      (await _get('/users/me')) as Map<String, dynamic>;

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> updates) async =>
      (await _patch('/users/me', updates)) as Map<String, dynamic>;

  // ─── AI ───

  Future<Map<String, dynamic>> sendAiMessage({
    required String message,
    String? conversationId,
    String? context,
  }) async =>
      (await _post('/ai/chat', {
        'message': message,
        if (conversationId != null) 'conversationId': conversationId,
        if (context != null) 'context': context,
      })) as Map<String, dynamic>;

  Future<List<dynamic>> getConversations() async {
    final data = await _get('/ai/conversations');
    return data['conversations'] ?? data as List;
  }

  Future<Map<String, dynamic>> getConversation(String id) async =>
      (await _get('/ai/conversations/$id')) as Map<String, dynamic>;

  Future<void> deleteConversation(String id) =>
      _delete('/ai/conversations/$id');

  Future<List<dynamic>> getRecommendations({
    required String category,
    String? context,
    String? locale,
    String? region,
  }) async {
    final data = await _post('/ai/recommendations', {
      'category': category,
      if (context != null) 'context': context,
      if (locale != null) 'locale': locale,
      if (region != null) 'region': region,
    });
    return data as List;
  }

  Future<Map<String, dynamic>> getAiInsights(Map<String, dynamic> data,
          {String? insightType}) async =>
      (await _post('/ai/insights', {
        'data': data,
        if (insightType != null) 'insightType': insightType,
      })) as Map<String, dynamic>;

  Future<List<dynamic>> aiSearch(String query, {String? scope}) async {
    final data = await _post('/ai/search', {
      'query': query,
      if (scope != null) 'scope': scope,
    });
    return data as List;
  }

  // ─── Subscriptions ───

  Future<Map<String, dynamic>?> getActiveSubscription() async {
    try {
      return await _get('/subscriptions/active');
    } catch (_) {
      return null;
    }
  }

  // ─── Analytics ───

  Future<void> trackEvent(String event, {Map<String, dynamic>? properties}) {
    return _post('/analytics/track', {
      'event': event,
      if (properties != null) 'properties': properties,
    }).catchError((_) {});
  }

  // ─── Internal HTTP ───

  Future<dynamic> _get(String path) async {
    final res = await http
        .get(
          Uri.parse('$_baseUrl$path'),
          headers: _headers,
        )
        .timeout(_timeout);
    return _handleResponse(res, method: 'GET');
  }

  Future<dynamic> _post(String path, Map<String, dynamic> body) async {
    final encoded = jsonEncode(body);
    final res = await http
        .post(
          Uri.parse('$_baseUrl$path'),
          headers: _headers,
          body: encoded,
        )
        .timeout(_timeout);
    return _handleResponse(res, method: 'POST', requestBody: encoded);
  }

  Future<dynamic> _patch(String path, Map<String, dynamic> body) async {
    final encoded = jsonEncode(body);
    final res = await http
        .patch(
          Uri.parse('$_baseUrl$path'),
          headers: _headers,
          body: encoded,
        )
        .timeout(_timeout);
    return _handleResponse(res, method: 'PATCH', requestBody: encoded);
  }

  Future<dynamic> _delete(String path) async {
    final res = await http
        .delete(
          Uri.parse('$_baseUrl$path'),
          headers: _headers,
        )
        .timeout(_timeout);
    if (res.statusCode == 204) return null;
    return _handleResponse(res, method: 'DELETE');
  }

  dynamic _handleResponse(http.Response res, {String method = 'GET', String? requestBody}) {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (res.body.isEmpty) return {};
      return jsonDecode(res.body);
    }

    if (res.statusCode == 401 && _session != null) {
      return _refreshAndRetry(res.request!.url, method: method, body: requestBody);
    }

    final body = res.body.isNotEmpty ? jsonDecode(res.body) : {};
    throw ApiException(
      statusCode: res.statusCode,
      message: body['message'] ?? 'Request failed',
    );
  }

  Future<dynamic> _refreshAndRetry(Uri url, {String method = 'GET', String? body}) async {
    try {
      // Let Supabase mint a fresh JWT, then replay the request with it.
      final refreshed = await Supabase.instance.client.auth.refreshSession();
      if (refreshed.session != null) {
        http.Response retryRes;
        switch (method) {
          case 'POST':
            retryRes = await http.post(url, headers: _headers, body: body);
          case 'PATCH':
            retryRes = await http.patch(url, headers: _headers, body: body);
          case 'DELETE':
            retryRes = await http.delete(url, headers: _headers);
          default:
            retryRes = await http.get(url, headers: _headers);
        }
        return _handleRetryResponse(retryRes);
      }
    } catch (_) {}

    throw ApiException(statusCode: 401, message: 'Session expired');
  }

  dynamic _handleRetryResponse(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (res.body.isEmpty) return {};
      return jsonDecode(res.body);
    }
    final body = res.body.isNotEmpty ? jsonDecode(res.body) : {};
    throw ApiException(statusCode: res.statusCode, message: body['message'] ?? 'Request failed');
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException($statusCode): $message';
}
