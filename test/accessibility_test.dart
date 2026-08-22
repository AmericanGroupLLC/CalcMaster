import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:calcmaster/app_router.dart';
import 'package:calcmaster/l10n/generated/app_localizations.dart';
import 'package:calcmaster/monetization/premium_provider.dart';
import 'package:calcmaster/state/notes_provider.dart';
import 'package:calcmaster/state/region_provider.dart';
import 'package:calcmaster/theme/app_theme.dart';

/// Accessibility guarantees for the tab shell.
///
/// Uses Flutter's own guideline matchers (tap-target size, rendered text
/// contrast, semantic labels) plus a large-text sweep. Text scaling is the
/// usual source of breakage on these screens: a RenderFlex overflow throws in
/// debug, so pumping at 2.0x turns "does it survive a user with large fonts?"
/// into a pass/fail question instead of a guess.
/// Blocks real sockets. `RegionProvider` refreshes FX rates on construction;
/// in a test that live request outlives the test body and the zone reports it
/// as an unhandled error. `fetchLatestRates()` already catches failures and
/// falls back to the bundled static rates, so refusing to connect exercises
/// the offline path rather than papering over anything.
class _OfflineHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) =>
      throw const SocketException('network disabled in tests');
}

void main() {
  setUpAll(() => HttpOverrides.global = _OfflineHttpOverrides());
  tearDownAll(() => HttpOverrides.global = null);
  setUp(() => SharedPreferences.setMockInitialValues({}));

  const tabs = ['Convert', 'Calculate', 'Finance', 'Tools', 'Notes'];

  Widget buildApp({TextScaler? scaler}) {
    final app = MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RegionProvider()),
        ChangeNotifierProvider(create: (_) => NotesProvider()),
        ChangeNotifierProvider(create: (_) => PremiumProvider()),
      ],
      child: MaterialApp.router(
        theme: buildAppTheme(),
        routerConfig: appRouter,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: scaler == null
            ? null
            : (context, child) => MediaQuery(
                  data: MediaQuery.of(context).copyWith(textScaler: scaler),
                  child: child!,
                ),
      ),
    );
    return app;
  }

  Future<void> settle(WidgetTester tester) async {
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle(const Duration(milliseconds: 400));
  }

  group('tap targets, contrast and semantics', () {
    testWidgets('the tab shell meets platform guidelines', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(buildApp());
      await settle(tester);

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

      handle.dispose();
    });
  });

  group('large text does not break layout', () {
    // 2.0x is within what iOS and Android expose to users.
    for (final scale in <double>[1.3, 2.0]) {
      testWidgets('every tab survives ${scale}x text', (tester) async {
        // A taller viewport than the 600px test default: at 2.0x the default
        // surface is shorter than a real phone and would report overflows no
        // device would ever show.
        tester.view.physicalSize = const Size(1170, 2532);
        tester.view.devicePixelRatio = 3.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(buildApp(scaler: TextScaler.linear(scale)));
        await settle(tester);
        expect(tester.takeException(), isNull,
            reason: 'Convert tab overflowed at ${scale}x text');

        for (final label in tabs.skip(1)) {
          final tab = find.text(label);
          if (tab.evaluate().isEmpty) continue;
          await tester.tap(tab.first);
          await settle(tester);
          expect(tester.takeException(), isNull,
              reason: '$label tab overflowed at ${scale}x text');
        }
      });
    }
  });
}
