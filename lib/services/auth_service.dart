import 'package:shared_preferences/shared_preferences.dart';

/// Local, offline session + guest-mode persistence.
///
/// CalcMaster does NOT require an account — it opens straight to the calculator
/// as a guest. This service persists two independent bits across launches via
/// [SharedPreferences], with no network required:
///   * the guest choice, so the app never re-prompts for sign-in, and
///   * an offline "demo" session for a bundled test account, used only as a
///     no-network fallback when Supabase is unreachable (see [AuthProvider]).
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  /// Human-friendly name shown for the offline demo session.
  static const String testDisplayName = 'Test User';

  static const String _kEmailKey = 'local_auth_email';
  static const String _kGuestKey = 'guest_mode';

  String? _email;
  String? get email => _email;

  bool _guest = false;

  /// True when the user has chosen to continue as a guest.
  bool get isGuest => _guest;

  /// True when an offline demo session is active.
  bool get isAuthenticated => _email != null;

  /// Restores any persisted local session/guest flag. Safe to call once at
  /// startup.
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _email = prefs.getString(_kEmailKey);
    _guest = prefs.getBool(_kGuestKey) ?? false;
  }

  /// Persists the guest choice so relaunches never re-prompt for sign-in.
  Future<void> setGuest() async {
    _guest = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kGuestKey, true);
  }

  /// Persists an offline demo session for [email]. Used as the no-network
  /// fallback for a SupabaseConfig test account.
  Future<void> saveOfflineSession(String email) async {
    _email = email;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kEmailKey, email);
  }

  /// Clears the persisted offline demo session (used on sign-out).
  Future<void> signOut() async {
    _email = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kEmailKey);
  }
}
