import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../state/auth_provider.dart';
import '../../theme/tokens.dart';
import '../../widgets/animated_gradient_background.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glow_text.dart';
import '../../l10n/generated/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  bool _isRegister = false;
  bool _loading = false;
  bool _obscure = true;
  String? _validationError;
  bool _navigated = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading) return;

    final email = _emailCtrl.text.trim();
    final password = _passCtrl.text;

    if (!email.contains('@') || !email.contains('.')) {
      setState(() => _validationError = 'Please enter a valid email address.');
      return;
    }
    if (password.length < 8) {
      setState(() => _validationError = 'Password must be at least 8 characters.');
      return;
    }

    setState(() {
      _validationError = null;
      _loading = true;
    });

    final auth = context.read<AuthProvider>();

    if (_isRegister) {
      final ok = await auth.register(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
        displayName: _nameCtrl.text.trim().isEmpty ? null : _nameCtrl.text.trim(),
      );
      if (ok && mounted) context.go('/convert');
    } else {
      final data = await auth.login(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );
      if (data['requiresMfa'] == true && mounted) {
        _showMfaDialog(data['tempToken']);
      } else if (data.containsKey('accessToken') && mounted) {
        context.go('/convert');
      }
    }

    if (mounted) setState(() => _loading = false);
  }

  void _showMfaDialog(String tempToken) {
    final codeCtrl = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(AppLocalizations.of(context)!.authTwoFactor,
            style: const TextStyle(color: AppColors.text)),
        content: TextField(
          controller: codeCtrl,
          keyboardType: TextInputType.number,
          maxLength: 6,
          style: const TextStyle(color: AppColors.text, fontSize: 24, letterSpacing: 8),
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.authOtpHint,
            hintStyle: const TextStyle(color: AppColors.textDim),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(context)!.authCancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final nav = Navigator.of(ctx);
              final router = GoRouter.of(ctx);
              final auth = ctx.read<AuthProvider>();
              final ok = await auth.verifyMfa(
                tempToken: tempToken,
                code: codeCtrl.text.trim(),
              );
              if (ok && ctx.mounted) {
                nav.pop();
                router.go('/convert');
              }
            },
            child: Text(AppLocalizations.of(context)!.authVerify),
          ),
        ],
      ),
    );
  }

  Future<void> _googleSignIn() async {
    if (_loading) return;
    setState(() {
      _validationError = null;
      _loading = true;
    });
    // Native Supabase ID-token flow: on success the session is applied
    // synchronously and build() navigates once auth becomes authenticated.
    await context.read<AuthProvider>().signInWithGoogle();
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _appleSignIn() async {
    if (_loading) return;
    setState(() {
      _validationError = null;
      _loading = true;
    });
    // Native Supabase ID-token flow (Sign in with Apple). build() navigates
    // once auth becomes authenticated.
    await context.read<AuthProvider>().signInWithApple();
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _continueAsGuest() async {
    // Guest mode: use the app with no account. The choice is persisted so the
    // app never re-prompts on relaunch. Calculators/converters work fully
    // offline; optional Supabase sign-in only powers cloud features.
    final auth = context.read<AuthProvider>();
    final router = GoRouter.of(context);
    await auth.continueAsGuest();
    if (mounted) router.go('/calculate');
  }

  Future<void> _useTestAccount() async {
    if (_loading) return;
    setState(() {
      _validationError = null;
      _loading = true;
    });
    // One-tap sign-in with the bundled offline test account. Persists across
    // launches and lands on the calculator home.
    final ok = await context.read<AuthProvider>().loginWithTestAccount();
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) context.go('/calculate');
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    // OAuth (Google) completes asynchronously; navigate once authenticated.
    if (auth.isLoggedIn && !_navigated) {
      _navigated = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/convert');
      });
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: AnimatedGradientBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(Spacing.xxl),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              AppColors.accentPrimary,
                              Color(0xFF5CE0A8),
                            ],
                          ),
                        ),
                        child: const Icon(Icons.calculate_rounded,
                            color: Colors.white, size: 36),
                      ),
                      const SizedBox(height: Spacing.xl),
                      GlowText(
                        'Calculator',
                        glowColor: AppColors.accentPrimary,
                        style: const TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: Spacing.xxxl),
                      GlassCard(
                        padding: const EdgeInsets.all(Spacing.xl),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              _isRegister ? 'Create Account' : 'Welcome Back',
                              style: const TextStyle(
                                color: AppColors.text,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: Spacing.xl),
                            if (_isRegister) ...[
                              _field(_nameCtrl, 'Display name',
                                  Icons.person_outline),
                              const SizedBox(height: Spacing.md),
                            ],
                            _field(_emailCtrl, 'Email', Icons.email_outlined,
                                type: TextInputType.emailAddress),
                            const SizedBox(height: Spacing.md),
                            _field(_passCtrl, 'Password', Icons.lock_outline,
                                obscure: _obscure,
                                suffix: IconButton(
                                  icon: Icon(
                                    _obscure
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: AppColors.textDim,
                                    size: 20,
                                  ),
                                  onPressed: () =>
                                      setState(() => _obscure = !_obscure),
                                )),
                            if (_validationError != null) ...[
                              const SizedBox(height: Spacing.md),
                              Text(_validationError!,
                                  style: const TextStyle(
                                      color: AppColors.danger, fontSize: 13)),
                            ],
                            if (auth.error != null) ...[
                              const SizedBox(height: Spacing.md),
                              Text(auth.error!,
                                  style: const TextStyle(
                                      color: AppColors.danger, fontSize: 13)),
                            ],
                            if (auth.notice != null) ...[
                              const SizedBox(height: Spacing.md),
                              Text(auth.notice!,
                                  style: const TextStyle(
                                      color: AppColors.success, fontSize: 13)),
                            ],
                            if (auth.awaitingEmailConfirmation) ...[
                              const SizedBox(height: Spacing.sm),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton(
                                  onPressed: _loading
                                      ? null
                                      : () => context
                                          .read<AuthProvider>()
                                          .resendConfirmation(),
                                  style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero),
                                  child: const Text('Resend confirmation email',
                                      style: TextStyle(
                                          color: AppColors.accentPrimary,
                                          fontSize: 13)),
                                ),
                              ),
                            ],
                            const SizedBox(height: Spacing.xl),
                            SizedBox(
                              height: 50,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(Radii.button),
                                  gradient: const LinearGradient(
                                    colors: [
                                      AppColors.accentPrimary,
                                      Color(0xFF5CE0A8),
                                    ],
                                  ),
                                ),
                                child: ElevatedButton(
                                  onPressed: _loading ? null : _submit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(Radii.button),
                                    ),
                                  ),
                                  child: _loading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white),
                                        )
                                      : Text(
                                          _isRegister
                                              ? 'Create Account'
                                              : 'Sign In',
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white),
                                        ),
                                ),
                              ),
                            ),
                            const SizedBox(height: Spacing.lg),
                            Row(
                              children: [
                                const Expanded(
                                    child: Divider(color: AppColors.border)),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: Spacing.md),
                                  child: Text('or',
                                      style: TextStyle(
                                          color: AppColors.textDim,
                                          fontSize: 13)),
                                ),
                                const Expanded(
                                    child: Divider(color: AppColors.border)),
                              ],
                            ),
                            const SizedBox(height: Spacing.lg),
                            SizedBox(
                              height: 50,
                              child: OutlinedButton.icon(
                                onPressed: _loading ? null : _googleSignIn,
                                style: OutlinedButton.styleFrom(
                                  backgroundColor:
                                      Colors.white.withValues(alpha: 0.06),
                                  side: const BorderSide(
                                      color: AppColors.border),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(Radii.button),
                                  ),
                                ),
                                icon: const Icon(Icons.g_mobiledata,
                                    color: AppColors.text, size: 28),
                                label: const Text('Continue with Google',
                                    style: TextStyle(
                                        color: AppColors.text,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600)),
                              ),
                            ),
                            const SizedBox(height: Spacing.md),
                            // Sign in with Apple — native ID-token flow. Optional,
                            // just like Google; the app never requires an account.
                            SizedBox(
                              height: 50,
                              child: OutlinedButton.icon(
                                onPressed: _loading ? null : _appleSignIn,
                                style: OutlinedButton.styleFrom(
                                  backgroundColor:
                                      Colors.white.withValues(alpha: 0.06),
                                  side: const BorderSide(
                                      color: AppColors.border),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(Radii.button),
                                  ),
                                ),
                                icon: const Icon(Icons.apple,
                                    color: AppColors.text, size: 24),
                                label: const Text('Continue with Apple',
                                    style: TextStyle(
                                        color: AppColors.text,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600)),
                              ),
                            ),
                            const SizedBox(height: Spacing.md),
                            // Prominent guest entry — login is OPTIONAL, so this
                            // is the primary way into the app.
                            SizedBox(
                              height: 50,
                              child: TextButton.icon(
                                onPressed: _loading ? null : _continueAsGuest,
                                style: TextButton.styleFrom(
                                  backgroundColor:
                                      AppColors.accentPrimary.withValues(alpha: 0.12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(Radii.button),
                                  ),
                                ),
                                icon: const Icon(Icons.arrow_forward_rounded,
                                    color: AppColors.accentPrimary, size: 20),
                                label: const Text('Continue without account',
                                    style: TextStyle(
                                        color: AppColors.accentPrimary,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600)),
                              ),
                            ),
                            const SizedBox(height: Spacing.md),
                            // One-tap offline test account (no network). Lands
                            // on the calculator home. Creds are in the README.
                            SizedBox(
                              height: 50,
                              child: OutlinedButton.icon(
                                onPressed: _loading ? null : _useTestAccount,
                                style: OutlinedButton.styleFrom(
                                  backgroundColor:
                                      AppColors.success.withValues(alpha: 0.10),
                                  side: BorderSide(
                                      color: AppColors.success
                                          .withValues(alpha: 0.5)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(Radii.button),
                                  ),
                                ),
                                icon: const Icon(Icons.verified_user_outlined,
                                    color: AppColors.success, size: 20),
                                label: const Text('Use test account',
                                    style: TextStyle(
                                        color: AppColors.success,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: Spacing.lg),
                      TextButton(
                        onPressed: () =>
                            setState(() => _isRegister = !_isRegister),
                        child: Text(
                          _isRegister
                              ? 'Already have an account? Sign in'
                              : "Don't have an account? Register",
                          style: const TextStyle(color: AppColors.textMuted),
                        ),
                      ),
                      const SizedBox(height: Spacing.md),
                      TextButton(
                        onPressed: _loading ? null : _continueAsGuest,
                        child: const Text(
                          'Skip for now',
                          style: TextStyle(color: AppColors.textDim),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    TextInputType type = TextInputType.text,
    bool obscure = false,
    Widget? suffix,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      obscureText: obscure,
      style: const TextStyle(color: AppColors.text, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textDim),
        prefixIcon: Icon(icon, color: AppColors.textMuted, size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.06),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.input),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: Spacing.lg),
      ),
    );
  }
}
