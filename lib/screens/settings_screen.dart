import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/generated/app_localizations.dart';
import '../monetization/analytics_service.dart';
import '../monetization/monetization_config.dart';
import '../monetization/notification_service.dart';
import '../monetization/premium_provider.dart';
import '../theme/tokens.dart';
import '../widgets/pro_badge.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _hydrate();
  }

  Future<void> _hydrate() async {
    final on = await NotificationService.instance.isEnabled();
    if (!mounted) return;
    setState(() {
      _notificationsEnabled = on;
      _loaded = true;
    });
  }

  Future<void> _toggleNotifications(bool value) async {
    if (value) {
      final granted = await NotificationService.instance.requestPermission();
      if (!granted) {
        await NotificationService.instance.setEnabled(enabled: true);
      } else {
        await NotificationService.instance.setEnabled(enabled: true);
      }
    } else {
      await NotificationService.instance.setEnabled(enabled: false);
    }
    if (!mounted) return;
    setState(() => _notificationsEnabled = value);
  }

  Future<void> _sendFeedback() async {
    final uri = Uri.parse('mailto:${MonetizationConfig.supportEmail}?subject=Calculator%20Feedback');
    try {
      await launchUrl(uri);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Email: ${MonetizationConfig.supportEmail}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isPro = context.watch<PremiumProvider>().isPro;
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.text),
          onPressed: () => context.pop(),
        ),
        title: Text(loc.settingsTitle, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Spacing.lg, 0, Spacing.lg, Spacing.xxl),
        children: [
          _SectionHeader(label: loc.settingsSubscription),
          _Tile(
            icon: Icons.workspace_premium,
            iconColor: AppColors.warning,
            title: isPro ? loc.settingsCalcMasterPro : loc.settingsSubscribePro,
            subtitle: isPro ? 'Active subscription · thanks!' : 'Remove ads + advanced features',
            trailing: isPro ? const ProBadge() : const Icon(Icons.chevron_right, color: AppColors.textDim),
            onTap: isPro
                ? null
                : () {
                    AnalyticsService.instance.logPaywallShown('settings');
                    context.push('/paywall');
                  },
          ),
          _Tile(
            icon: Icons.restore,
            iconColor: AppColors.text,
            title: loc.settingsRestorePurchases,
            subtitle: 'Already paid on another device?',
            onTap: () async {
              final ok = await context.read<PremiumProvider>().restore();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(ok ? 'Restored.' : 'No active purchases found.')),
              );
            },
          ),
          const SizedBox(height: Spacing.lg),
          _SectionHeader(label: loc.settingsPreferences),
          _Tile(
            icon: Icons.notifications_outlined,
            iconColor: AppColors.accentPrimary,
            title: loc.settingsNotifications,
            subtitle: _loaded
                ? (_notificationsEnabled ? 'Reminders & rate alerts on' : 'Off')
                : 'Loading…',
            trailing: Switch(
              value: _notificationsEnabled,
              activeTrackColor: AppColors.accentPrimary,
              onChanged: _loaded ? _toggleNotifications : null,
            ),
          ),
          const SizedBox(height: Spacing.lg),
          _SectionHeader(label: loc.settingsHelp),
          _Tile(
            icon: Icons.email_outlined,
            iconColor: AppColors.text,
            title: loc.settingsSendFeedback,
            subtitle: MonetizationConfig.supportEmail,
            onTap: _sendFeedback,
          ),
          _Tile(
            icon: Icons.lock_outline,
            iconColor: AppColors.text,
            title: loc.settingsPrivacyPolicy,
            onTap: () => context.push('/privacy'),
          ),
          _Tile(
            icon: Icons.info_outline,
            iconColor: AppColors.text,
            title: loc.settingsAbout,
            onTap: () => context.push('/about'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, Spacing.md, 0, Spacing.sm),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _Tile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(Radii.button),
        child: InkWell(
          borderRadius: BorderRadius.circular(Radii.button),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.md),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(Radii.button),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: iconColor),
                ),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              color: AppColors.text, fontSize: 16, fontWeight: FontWeight.w600)),
                      if (subtitle != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(subtitle!,
                              style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
                        ),
                    ],
                  ),
                ),
                trailing ?? const Icon(Icons.chevron_right, color: AppColors.textDim),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
