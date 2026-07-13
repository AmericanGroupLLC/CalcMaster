/// Supabase connection settings.
///
/// The URL and publishable (anon) key are safe to ship in a mobile binary —
/// they only allow operations permitted by Row Level Security. NEVER place the
/// service-role or secret keys here. Both values can be overridden at build
/// time with --dart-define for staging/other projects.
class SupabaseConfig {
  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://smvvjivvlprjhzhoizym.supabase.co',
  );

  static const String publishableKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_nqtYGp48NKiRF53zivkpsQ_bRiqDSfc',
  );

  /// Deep-link the OAuth provider redirects back to after sign-in. Must be
  /// registered in the Supabase dashboard (Authentication → URL Configuration →
  /// Redirect URLs) AND declared as a URL scheme in iOS Info.plist / Android
  /// manifest. Scheme = app bundle id to guarantee uniqueness.
  static const String oauthRedirect =
      'com.americangroupllc.calcmaster://login-callback/';
}
