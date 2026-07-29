import 'dart:convert';
import 'dart:math' show Random;

import 'package:crypto/crypto.dart' show sha256;
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/auth_service.dart';
import '../services/supabase_config.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

/// Auth backed by Supabase (GoTrue). Supabase persists/refreshes the session
/// automatically; we mirror its state into [AuthStatus] for the UI.
class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.unknown;
  Map<String, dynamic>? _user;
  String? _error;
  String? _notice;
  bool _awaitingEmailConfirmation = false;
  String? _pendingEmail;

  AuthStatus get status => _status;
  Map<String, dynamic>? get user => _user;
  String? get error => _error;

  /// Non-error informational message (e.g. "confirmation email sent").
  String? get notice => _notice;

  /// True after a sign-up that needs the user to confirm their email before
  /// they can sign in.
  bool get awaitingEmailConfirmation => _awaitingEmailConfirmation;
  String? get pendingEmail => _pendingEmail;

  bool get isLoggedIn => _status == AuthStatus.authenticated;

  bool _isDemo = false;

  /// True when the user is browsing as a guest (no Supabase account).
  bool get isDemo => _isDemo;

  /// True when the user has explicitly chosen guest mode (persisted).
  bool get isGuest => _localAuth.isGuest;

  SupabaseClient get _client => Supabase.instance.client;

  final AuthService _localAuth = AuthService.instance;

  /// Enters the app as a guest (no account) and persists that choice so the app
  /// never re-prompts for sign-in on relaunch. Calculators/converters work
  /// fully offline; signed-in-only features can check [isDemo]/[isLoggedIn] to
  /// offer an optional sign-in later.
  Future<void> continueAsGuest() async {
    await _localAuth.setGuest();
    _isDemo = true;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> init() async {
    // Restore the offline demo session first — it takes precedence and works
    // even when Supabase failed to initialize (e.g. the device is offline).
    await _localAuth.init();
    if (_localAuth.isAuthenticated) {
      _applyLocalTestUser(_localAuth.email!);
    } else {
      // Reflect any restored Supabase session, then keep in sync with changes.
      try {
        _applySession(_client.auth.currentSession);
      } catch (_) {
        _status = AuthStatus.unauthenticated;
      }
    }
    try {
      _client.auth.onAuthStateChange.listen((data) {
        // A live Supabase session only overrides state when no local session
        // is active, so the offline test account is never clobbered.
        if (!_localAuth.isAuthenticated) {
          _applySession(data.session);
          notifyListeners();
        }
      });
    } catch (_) {
      // Supabase not available (offline) — local auth is the only path.
    }
    notifyListeners();
  }

  /// Mirrors an offline demo session (for [email]) into the UI-facing state.
  void _applyLocalTestUser(String email) {
    _isDemo = false;
    _user = {
      'id': 'local-demo',
      'email': email,
      'displayName': AuthService.testDisplayName,
    };
    _status = AuthStatus.authenticated;
    _error = null;
  }

  /// True when [email]/[password] match one of the SupabaseConfig test accounts
  /// (QA or Dev). Comparison is case-insensitive on the email.
  bool _isConfigTestAccount(String email, String password) {
    final e = email.trim().toLowerCase();
    return (e == SupabaseConfig.qaEmail.toLowerCase() &&
            password == SupabaseConfig.qaPassword) ||
        (e == SupabaseConfig.devEmail.toLowerCase() &&
            password == SupabaseConfig.devPassword);
  }

  /// One-tap sign-in with the shared QA test account. Tries Supabase first and
  /// (with no network) falls back to a persisted offline demo session. Returns
  /// true on success.
  Future<bool> loginWithTestAccount() async {
    final res = await login(
      email: SupabaseConfig.qaEmail,
      password: SupabaseConfig.qaPassword,
    );
    return res.containsKey('accessToken');
  }

  void _applySession(Session? session) {
    if (session != null) {
      _isDemo = false;
      _user = _userMap(session.user);
      _status = AuthStatus.authenticated;
    } else {
      _user = null;
      _status = AuthStatus.unauthenticated;
    }
  }

  Map<String, dynamic> _userMap(User u) => {
        'id': u.id,
        'email': u.email,
        'displayName': u.userMetadata?['display_name'] ?? u.userMetadata?['name'],
      };

  Future<bool> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    _error = null;
    _notice = null;
    _awaitingEmailConfirmation = false;
    try {
      final res = await _client.auth.signUp(
        email: email,
        password: password,
        data: displayName == null ? null : {'display_name': displayName},
        emailRedirectTo: SupabaseConfig.oauthRedirect,
      );
      if (res.session != null) {
        // Project has email confirmation disabled (auto-confirm) → signed in.
        _applySession(res.session);
        notifyListeners();
        return true;
      }
      // No session => email confirmation is required before sign-in.
      _awaitingEmailConfirmation = true;
      _pendingEmail = email;
      _notice = 'We sent a confirmation link to $email. '
          'Tap it, then sign in.';
      notifyListeners();
      return false;
    } on AuthException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Could not create account. Please try again.';
      notifyListeners();
      return false;
    }
  }

  /// Re-sends the sign-up confirmation email for the pending address.
  Future<void> resendConfirmation() async {
    final email = _pendingEmail;
    if (email == null) return;
    _error = null;
    try {
      await _client.auth.resend(type: OtpType.signup, email: email);
      _notice = 'Confirmation email re-sent to $email.';
    } on AuthException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Could not resend the email. Please try again.';
    }
    notifyListeners();
  }

  /// Returns a map mirroring the previous API: contains `accessToken` on
  /// success, or `error` on failure. (MFA is handled by Supabase directly, so
  /// `requiresMfa` is never set here.)
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    _error = null;
    _notice = null;
    try {
      // Real, online sign-in via Supabase GoTrue.
      final res = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      _awaitingEmailConfirmation = false;
      _applySession(res.session);
      notifyListeners();
      final token = res.session?.accessToken;
      if (token != null) return {'accessToken': token, 'user': _user};
      _error = 'Sign in failed. Please try again.';
      return {'error': _error};
    } on AuthException catch (e) {
      // Supabase actively REJECTED these credentials (wrong password,
      // unconfirmed email, etc). This is a genuine auth failure, so we NEVER
      // fall back to an offline session here — not even for a test-account
      // email. Surface the "confirm your email" path so the UI can offer a
      // resend.
      final code = e.code ?? '';
      if (code == 'email_not_confirmed' ||
          e.message.toLowerCase().contains('not confirmed')) {
        _awaitingEmailConfirmation = true;
        _pendingEmail = email;
        _error = 'Please confirm your email first. Check your inbox or resend.';
      } else {
        _error = e.message;
      }
      notifyListeners();
      return {'error': _error};
    } catch (e) {
      // Network/socket error (device offline) or Supabase never initialized.
      // The server never got to accept OR reject the credentials, so — and
      // ONLY here — if the entered credentials match one of the SupabaseConfig
      // test accounts, fall back to a persisted local demo session so reviewers
      // can still get in with no network. Any other credentials just fail; we
      // never invent a session for unknown users.
      if (_isConfigTestAccount(email, password)) {
        await _localAuth.saveOfflineSession(email.trim());
        _awaitingEmailConfirmation = false;
        _applyLocalTestUser(email.trim());
        notifyListeners();
        return {'accessToken': 'local-demo-session', 'user': _user};
      }
      _error = 'Sign in failed. Please check your connection and try again.';
      notifyListeners();
      return {'error': _error};
    }
  }

  /// Seamless Google sign-in via the Supabase-native ID-token flow.
  ///
  /// The native Google SDK returns a signed `idToken` (+ `accessToken`);
  /// [SupabaseClient.auth.signInWithIdToken] exchanges them for a session and
  /// auto-creates the account on first sign-in (no separate sign-up step).
  /// [SupabaseConfig.googleServerClientId] (the web/server client id) must match
  /// the Google provider's configured Client ID in the Supabase dashboard, or
  /// the exchange is rejected. Returns true on success; false on cancel/failure.
  Future<bool> signInWithGoogle() async {
    _error = null;
    _notice = null;
    try {
      final iosClientId = SupabaseConfig.googleIosClientId;
      final googleSignIn = GoogleSignIn(
        serverClientId: SupabaseConfig.googleServerClientId,
        clientId: iosClientId.isNotEmpty ? iosClientId : null,
      );

      final account = await googleSignIn.signIn();
      if (account == null) return false; // user cancelled — not an error.
      final googleAuth = await account.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null) {
        _error = 'Google sign-in failed: missing ID token.';
        notifyListeners();
        return false;
      }

      final res = await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: googleAuth.accessToken,
      );
      _applySession(res.session);
      notifyListeners();
      return res.session != null;
    } on AuthException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Google sign-in failed. Please try again.';
      notifyListeners();
      return false;
    }
  }

  /// Seamless Apple sign-in via the Supabase-native ID-token flow.
  ///
  /// Generates a cryptographically random raw nonce and sends its SHA-256 hash
  /// to Apple; Apple binds the hash into the returned identity token, and
  /// Supabase re-derives the hash from the raw nonce to verify the binding
  /// (replay protection). Supabase auto-creates the account on first sign-in.
  /// Returns true on success; false on cancel/failure.
  Future<bool> signInWithApple() async {
    _error = null;
    _notice = null;
    try {
      final rawNonce = _generateNonce();
      final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: const [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );

      final idToken = credential.identityToken;
      if (idToken == null) {
        _error = 'Apple sign-in failed: missing identity token.';
        notifyListeners();
        return false;
      }

      final res = await _client.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
        nonce: rawNonce,
      );
      _applySession(res.session);
      notifyListeners();
      return res.session != null;
    } on SignInWithAppleAuthorizationException catch (e) {
      // User cancelled the native sheet — not an error to surface loudly.
      if (e.code == AuthorizationErrorCode.canceled) return false;
      _error = 'Apple sign-in failed. Please try again.';
      notifyListeners();
      return false;
    } on AuthException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Apple sign-in failed. Please try again.';
      notifyListeners();
      return false;
    }
  }

  /// Seamless, no-login identity. Creates a real (anonymous) Supabase session
  /// that persists and can later be upgraded to a full account. This is the
  /// account-backed complement to guest mode ([continueAsGuest]).
  Future<bool> signInAnonymously() async {
    _error = null;
    _notice = null;
    try {
      final res = await _client.auth.signInAnonymously();
      _applySession(res.session);
      notifyListeners();
      return res.session != null;
    } on AuthException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Anonymous sign-in failed. Please try again.';
      notifyListeners();
      return false;
    }
  }

  /// Cryptographically secure random nonce (URL-safe charset) for Apple sign-in.
  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Retained for the existing UI contract. Supabase performs MFA inline during
  /// sign-in, so this path is not exercised by the password flow.
  Future<bool> verifyMfa({
    required String tempToken,
    required String code,
  }) async {
    return false;
  }

  /// Signs out and returns the user to the guest home — it never forces the
  /// login screen. Clears BOTH sessions: the offline demo session and the live
  /// Supabase session.
  Future<void> logout() async {
    await _localAuth.signOut(); // clears the persisted offline demo session
    try {
      await _client.auth.signOut(); // clears the Supabase session
    } catch (_) {}
    try {
      await GoogleSignIn().signOut(); // clears the cached native Google session
    } catch (_) {}
    _user = null;
    _isDemo = false;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> refreshProfile() async {
    _applySession(_client.auth.currentSession);
    notifyListeners();
  }
}
