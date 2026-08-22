import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:calcmaster/main.dart' as app;

/// End-to-end cold-launch smoke test.
///
/// The previous version of this file pumped a hardcoded
/// `Text('app')` widget and asserted it was found — it never launched
/// CalcMaster, so it could not fail and verified nothing. This boots the real
/// `main()` entry point: Supabase init, the provider graph, the router, the
/// splash animation and the tab shell.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  /// Pump until [finder] matches, or give up after [timeout].
  ///
  /// On a real device the splash animation, Supabase init and SharedPreferences
  /// all resolve in wall-clock time, so a fixed number of `pump()` calls is a
  /// race — it passed on the host and failed on-device. The ambient background
  /// animation never settles, so `pumpAndSettle()` is not an option either.
  Future<bool> pumpUntilFound(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline)) {
      await tester.pump(const Duration(milliseconds: 100));
      if (finder.evaluate().isNotEmpty) return true;
    }
    return false;
  }

  testWidgets('cold launch reaches the tab shell without throwing', (tester) async {
    await app.main();
    await tester.pump();

    final arrived = await pumpUntilFound(tester, find.text('Convert'));
    expect(tester.takeException(), isNull, reason: 'cold launch must not throw');
    expect(arrived, isTrue,
        reason: 'the tab shell should appear within 30s of cold launch');

    for (final label in ['Convert', 'Calculate', 'Finance', 'Tools', 'Notes']) {
      expect(
        find.text(label),
        findsWidgets,
        reason: 'the "$label" destination should be reachable after launch',
      );
    }
  });
}
