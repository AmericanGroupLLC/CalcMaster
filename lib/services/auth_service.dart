import 'package:shared_preferences/shared_preferences.dart';

/// Local, offline authentication for the bundled test account.
///
/// CalcMaster ships with Supabase auth flag-gated off (the app is fully
/// offline). This service provides a self-contained sign-in that validates a
/// single bundled test account and persists the session across launches via
/// [SharedPreferences] — no network required. Reviewers/testers can therefore
/// sign in and land in the app with one tap.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  /// Bundled reviewer/test credentials. Documented in the README.
  static const String testEmail = 'test@americangroupllc.com';
  static const String testPassword = 'Test1234!';
  static const String testDisplayName = 'Test User';

  static const String _kEmailKey = 'local_auth_email';

  String? _email;
  String? get email => _email;

  /// True when a local session is active (test account signed in).
  bool get isAuthenticated => _email != null;

  /// Restores any persisted local session. Safe to call once at startup.
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _email = prefs.getString(_kEmailKey);
  }

  /// Validates [email]/[password] against the bundled test account. On success
  /// the session is persisted and `true` is returned. Comparison is
  /// case-insensitive on the email and tolerant of surrounding whitespace.
  Future<bool> signIn(String email, String password) async {
    if (email.trim().toLowerCase() != testEmail || password != testPassword) {
      return false;
    }
    return _persist(testEmail);
  }

  /// One-tap sign-in with the bundled test account.
  Future<bool> signInWithTestAccount() => _persist(testEmail);

  Future<bool> _persist(String email) async {
    _email = email;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kEmailKey, email);
    return true;
  }

  /// Clears the persisted local session.
  Future<void> signOut() async {
    _email = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kEmailKey);
  }
}
