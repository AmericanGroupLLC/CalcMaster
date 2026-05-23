import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'premium_provider.dart';

/// Renders [child] when the user has an active premium entitlement, otherwise
/// renders [fallback]. Used to gate features such as advanced analytics, data
/// export, or ad-free mode.
class PremiumGate extends StatelessWidget {
  final Widget child;
  final Widget fallback;
  const PremiumGate({super.key, required this.child, required this.fallback});

  @override
  Widget build(BuildContext context) {
    final isPro = context.watch<PremiumProvider>().isPro;
    return isPro ? child : fallback;
  }
}
