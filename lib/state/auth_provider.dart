import 'package:flutter/foundation.dart';
import '../services/api_client.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.unknown;
  Map<String, dynamic>? _user;
  String? _error;

  AuthStatus get status => _status;
  Map<String, dynamic>? get user => _user;
  String? get error => _error;
  bool get isLoggedIn => _status == AuthStatus.authenticated;

  final _api = ApiClient.instance;

  Future<void> init() async {
    await _api.loadTokens();
    if (_api.isAuthenticated) {
      try {
        _user = await _api.getProfile();
        _status = AuthStatus.authenticated;
      } catch (_) {
        _status = AuthStatus.unauthenticated;
      }
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    _error = null;
    try {
      final data = await _api.register(
        email: email,
        password: password,
        displayName: displayName,
      );
      _user = data['user'];
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    _error = null;
    try {
      final data = await _api.login(email: email, password: password);
      if (data['requiresMfa'] == true) {
        return data;
      }
      _user = data['user'];
      _status = AuthStatus.authenticated;
      notifyListeners();
      return data;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return {'error': e.message};
    }
  }

  Future<bool> verifyMfa({
    required String tempToken,
    required String code,
  }) async {
    _error = null;
    try {
      final data = await _api.verifyMfa(tempToken: tempToken, code: code);
      _user = data['user'];
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _api.logout();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> refreshProfile() async {
    try {
      _user = await _api.getProfile();
      notifyListeners();
    } catch (_) {}
  }
}
