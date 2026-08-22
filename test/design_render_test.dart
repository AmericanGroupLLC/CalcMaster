@Tags(['design'])
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:calcmaster/app_router.dart';
import 'package:calcmaster/l10n/generated/app_localizations.dart';
import 'package:calcmaster/monetization/premium_provider.dart';
import 'package:calcmaster/state/notes_provider.dart';
import 'package:calcmaster/state/region_provider.dart';
import 'package:calcmaster/theme/app_theme.dart';

/// Renders real screens to PNGs under `test/goldens/` so the UI can be
/// inspected without a device:
///
///   flutter test --run-skipped --update-goldens --tags design
///
/// These are review artifacts, not assertions. `dart_test.yaml` marks the
/// `design` tag as skipped, so `flutter test` never runs them and a pixel diff
/// (or a machine without DejaVu installed) can never fail CI — hence the
/// explicit `--run-skipped` above.
void main() {
  const phone = Size(390, 844);

  setUpAll(() async {
    // Widget tests ship no fonts, so text would render as tofu boxes. Load a
    // system face under the families the app asks for.
    GoogleFonts.config.allowRuntimeFetching = false;
    final regular = File('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf');
    final bold = File('/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf');
    if (regular.existsSync()) {
      for (final family in ['Roboto', 'Inter', 'packages/calcmaster/Inter']) {
        final loader = FontLoader(family)
          ..addFont(Future.value(ByteData.sublistView(regular.readAsBytesSync())));
        if (bold.existsSync()) {
          loader.addFont(Future.value(ByteData.sublistView(bold.readAsBytesSync())));
        }
        await loader.load();
      }
    }
  });

  Widget buildApp() => MultiProvider(
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
        ),
      );

  Future<void> shoot(WidgetTester tester, String name, {String? tapTab}) async {
    tester.view.physicalSize = phone * 2;
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(buildApp());
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle(const Duration(milliseconds: 400));

    if (tapTab != null) {
      final tab = find.text(tapTab);
      if (tab.evaluate().isNotEmpty) {
        await tester.tap(tab.first);
        await tester.pump(const Duration(milliseconds: 200));
        await tester.pumpAndSettle(const Duration(milliseconds: 400));
      }
    }

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/$name.png'),
    );
  }

  testWidgets('convert tab', (t) => shoot(t, '01_convert'));
  testWidgets('calculate tab', (t) => shoot(t, '02_calculate', tapTab: 'Calculate'));
  testWidgets('finance tab', (t) => shoot(t, '03_finance', tapTab: 'Finance'));
  testWidgets('tools tab', (t) => shoot(t, '04_tools', tapTab: 'Tools'));
  testWidgets('notes tab', (t) => shoot(t, '05_notes', tapTab: 'Notes'));
}
