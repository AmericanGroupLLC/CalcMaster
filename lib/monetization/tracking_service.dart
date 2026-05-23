import 'dart:io' show Platform;

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'analytics_service.dart';

/// iOS App Tracking Transparency (ATT) prompt manager.
///
/// Apple requires apps that show personalised ads to ask the user for tracking
/// consent via the standard ATT prompt. The prompt must NOT pop on cold launch
/// (Apple rejects builds that do that) — best practice is to defer it until
/// the user demonstrates intent (opening the paywall, first ad load, etc).
///
/// On Android + web this class is a no-op.
class TrackingService {
  static final TrackingService instance = TrackingService._();
  TrackingService._();

  static const _kPromptShown = '@calcmaster/att_prompt_shown';

  bool _hasShownThisSession = false;

  /// Trigger the ATT prompt if appropriate. Safe to call multiple times —
  /// only prompts once per app lifetime; subsequent calls are no-ops.
  Future<TrackingStatus> requestIfNeeded() async {
    if (kIsWeb) return TrackingStatus.notSupported;
    try {
      if (!Platform.isIOS) return TrackingStatus.notSupported;
    } catch (_) {
      return TrackingStatus.notSupported;
    }
    if (_hasShownThisSession) return _cachedStatus();

    final sp = await SharedPreferences.getInstance();
    final alreadyAsked = sp.getBool(_kPromptShown) ?? false;
    final current = await AppTrackingTransparency.trackingAuthorizationStatus;

    // If the OS already has a non-notDetermined status, we don't need to ask.
    if (current != TrackingStatus.notDetermined || alreadyAsked) {
      _hasShownThisSession = true;
      return current;
    }

    final result = await AppTrackingTransparency.requestTrackingAuthorization();
    await sp.setBool(_kPromptShown, true);
    _hasShownThisSession = true;
    AnalyticsService.instance.logEvent('att_prompt_result', {
      'status': result.toString(),
    });
    return result;
  }

  Future<TrackingStatus> _cachedStatus() async {
    return AppTrackingTransparency.trackingAuthorizationStatus;
  }
}
