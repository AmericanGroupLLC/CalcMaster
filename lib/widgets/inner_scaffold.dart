import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/tokens.dart';

class InnerScaffold extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final List<Widget> actions;
  const InnerScaffold({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Transparent so the shell's animated gradient flows behind detail
      // screens too, matching the hub screens.
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(Spacing.lg, Spacing.sm, Spacing.lg, Spacing.xxl),
          // Single-task forms read best in a comfortable column rather than
          // stretched across a wide desktop window.
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Row(
                children: [
                  IconButton(
                    tooltip: 'Go back',
                    icon: const Icon(Icons.chevron_left, color: AppColors.text, size: 28),
                    onPressed: () => context.pop(),
                  ),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(color: AppColors.text, fontSize: 22, fontWeight: FontWeight.w700),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  ...actions,
                ],
              ),
              if (subtitle != null)
                Padding(
                  padding: const EdgeInsets.only(left: 36, top: 2),
                  child: Text(subtitle!,
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
                ),
              const SizedBox(height: Spacing.md),
              child,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
