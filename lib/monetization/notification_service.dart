import 'package:shared_preferences/shared_preferences.dart';

import 'analytics_service.dart';
import 'monetization_config.dart';

/// Permission + scheduling stub for push & local notifications. In the scaffold,
/// only the user's opt-in choice is persisted. Real FCM + flutter_local_notifications
/// integration drops into the body of the methods later.
class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  static const _kEnabled = '@calcmaster/notifications_enabled';

  Future<bool> isEnabled() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getBool(_kEnabled) ?? false;
  }

  Future<void> setEnabled({required bool enabled}) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_kEnabled, enabled);
    AnalyticsService.instance.logNotificationPermission(enabled);
  }

  /// Request OS-level permission. Stubbed to return the persisted opt-in for now.
  Future<bool> requestPermission() async {
    if (!MonetizationConfig.fcmEnabled) {
      return isEnabled();
    }
    // TODO(monetization): use firebase_messaging requestPermission + APNs registration.
    return isEnabled();
  }

  /// Subscribe to a topic for re-engagement messages. No-op until FCM is wired.
  Future<void> subscribe(String topic) async {
    if (!MonetizationConfig.fcmEnabled) return;
    // TODO(monetization): FirebaseMessaging.instance.subscribeToTopic(topic);
  }
}
