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
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNtdnZqaXZ2bHByamh6aG9penltIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAyMDIxMDMsImV4cCI6MjA5NTc3ODEwM30.csC-AHt-nI6BaZd6yt7imxbpAkS5tEOjqcpetZGWkF0',
  );

  /// Deep-link the OAuth provider redirects back to after sign-in. Must be
  /// registered in the Supabase dashboard (Authentication → URL Configuration →
  /// Redirect URLs) AND declared as a URL scheme in iOS Info.plist / Android
  /// manifest. Scheme = app bundle id to guarantee uniqueness.
  static const String oauthRedirect =
      'com.americangroupllc.calcmaster://login-callback/';

  /// Alias kept for cross-app consistency (some code refers to `anonKey`).
  static const String anonKey = publishableKey;

  /// Shared test accounts provisioned in the backend (per the org integration
  /// guide). This app does NOT require login — sign-in is optional and only powers
  /// cloud sync — but these back the optional "Use test account" button.
  static const String qaEmail = 'qa@safecodeg.com';
  static const String qaPassword = 'QATest@2024!';
  static const String devEmail = 'dev@safecodeg.com';
  static const String devPassword = 'DevTest@2024!';
  static const String adminEmail = 'admin@safecodeg.com';
  static const String adminPassword = 'AdminTest@2024!';
}
