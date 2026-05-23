import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:calcmaster/l10n/generated/app_localizations.dart';
import 'package:calcmaster/screens/convert_home.dart';
import 'package:calcmaster/state/notes_provider.dart';
import 'package:calcmaster/state/region_provider.dart';

/// Boot the Convert hub in each of the 9 supported locales and assert that
/// the locale's translated heading is rendered. Detects regressions where
/// an ARB key is missing or a widget bypasses AppLocalizations.
Widget wrap(Locale locale) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => RegionProvider()),
      ChangeNotifierProvider(create: (_) => NotesProvider()),
    ],
    child: MaterialApp(
      home: const ConvertHome(),
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    ),
  );
}

void main() {
  // Per-locale expected hero heading on the Convert hub. These values mirror
  // the `convertHubHeading` key in each lib/l10n/app_<lang>.arb file.
  const headings = <String, String>{
    'en': 'Convert',
    'es': 'Convertir',
    'zh': '转换',
    'hi': 'बदलें',
    'fr': 'Convertir',
    'ar': 'تحويل',
    'de': 'Umrechnen',
    'ja': '変換',
    'pt': 'Converter',
  };

  for (final entry in headings.entries) {
    final code = entry.key;
    final expected = entry.value;
    testWidgets('Convert hub renders in $code locale', (tester) async {
      await tester.pumpWidget(wrap(Locale(code)));
      await tester.pumpAndSettle();
      expect(find.text(expected), findsWidgets,
          reason: 'Expected hub heading "$expected" for locale "$code"');
    });
  }

  testWidgets('All 12 locales registered as supported', (tester) async {
    final codes = AppLocalizations.supportedLocales.map((l) => l.languageCode).toSet();
    expect(codes, containsAll(['en', 'es', 'zh', 'hi', 'fr', 'ar', 'de', 'ja', 'pt', 'ko', 'ru', 'it']));
    expect(AppLocalizations.supportedLocales.length, equals(12));
  });

  testWidgets('Arabic forces RTL textDirection', (tester) async {
    await tester.pumpWidget(wrap(const Locale('ar')));
    await tester.pumpAndSettle();
    final dir = Directionality.of(tester.element(find.byType(ConvertHome)));
    expect(dir, equals(TextDirection.rtl));
  });

  testWidgets('English uses LTR textDirection', (tester) async {
    await tester.pumpWidget(wrap(const Locale('en')));
    await tester.pumpAndSettle();
    final dir = Directionality.of(tester.element(find.byType(ConvertHome)));
    expect(dir, equals(TextDirection.ltr));
  });
}
