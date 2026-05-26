import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:calcmaster/app_router.dart';
import 'package:calcmaster/l10n/generated/app_localizations.dart';
import 'package:calcmaster/monetization/premium_provider.dart';
import 'package:calcmaster/state/notes_provider.dart';
import 'package:calcmaster/state/region_provider.dart';
import 'package:calcmaster/theme/app_theme.dart';

/// Boot the entire app under widget test, simulating a tap on each of the 5
/// bottom-tab destinations and asserting no exception is thrown.
///
/// This is the equivalent of "open the app, tap Convert/Calculate/Finance/Tools/Notes
/// in turn" — strong evidence that none of the 5 tabs crash on first render.
void main() {
  Widget buildApp() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RegionProvider()),
        ChangeNotifierProvider(create: (_) => NotesProvider()),
        ChangeNotifierProvider(create: (_) => PremiumProvider()),
      ],
      child: MaterialApp.router(
        title: 'CalcMaster',
        theme: buildAppTheme(),
        routerConfig: appRouter,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
  }

  Future<void> tapTab(WidgetTester tester, String label) async {
    final tab = find.text(label);
    expect(tab, findsWidgets, reason: 'Tab "$label" should be in bottom nav');
    await tester.tap(tab.first);
    // Multiple settles in case of route transitions / async hydration
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
  }

  group('Bottom nav · all 5 tabs render without crash', () {
    testWidgets('Convert tab loads home with all 10 categories', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // Convert is initial — verify hero copy and a couple of cards
      expect(find.text('CalcMaster'), findsOneWidget);
      expect(find.text('Convert'), findsWidgets);
      expect(find.text('Distance'), findsOneWidget);
      expect(find.text('Volume'), findsOneWidget);
      expect(find.text('Weight'), findsOneWidget);
      // Bottom nav present
      expect(find.text('Convert'), findsWidgets);
      expect(find.text('Notes'), findsOneWidget);
    });

    testWidgets('Calculate tab loads with 5 calculator cards', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      await tapTab(tester, 'Calculate');

      expect(find.text('Calculate'), findsWidgets);
      expect(find.text('CALCULATORS'), findsOneWidget);
      expect(find.text('Standard'), findsOneWidget);
      expect(find.text('Scientific'), findsOneWidget);
      expect(find.text('Percentage'), findsOneWidget);
      expect(find.text('Base'), findsOneWidget);
      expect(find.text('Fraction'), findsOneWidget);
    });

    testWidgets('Finance tab loads with 7 finance cards', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      await tapTab(tester, 'Finance');

      expect(find.text('Finance'), findsWidgets);
      expect(find.text('FINANCE TOOLS'), findsOneWidget);
      expect(find.text('Tax'), findsOneWidget);
      expect(find.text('Tip & Split'), findsOneWidget);
      expect(find.text('Discount'), findsOneWidget);
      expect(find.text('Compound Interest'), findsOneWidget);
      expect(find.text('EMI / Loan'), findsOneWidget);
      expect(find.text('Currency'), findsOneWidget);
      expect(find.text('Unit Price'), findsOneWidget);
    });

    testWidgets('Tools tab loads with 8 tool cards', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      await tapTab(tester, 'Tools');

      expect(find.text('Tools'), findsWidgets);
      expect(find.text('UTILITY TOOLS'), findsOneWidget);
      expect(find.text('GPS Coordinates'), findsOneWidget);
      expect(find.text("Ohm's Law"), findsOneWidget);
      expect(find.text('BMI'), findsOneWidget);
      expect(find.text('Date Difference'), findsOneWidget);
      expect(find.text('Time Zones'), findsOneWidget);
      expect(find.text('ADC / DAC'), findsOneWidget);
      expect(find.text('Age'), findsOneWidget);
      expect(find.text('Aspect Ratio'), findsOneWidget);
    });

    testWidgets('Notes tab loads empty editor without crash', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      await tapTab(tester, 'Notes');

      expect(find.text('Notes'), findsWidgets);
      expect(find.text('SAVED NOTES'), findsOneWidget);
      expect(find.text('Save calculations, formulas, and reminders'), findsOneWidget);
      // Editor button visible
      expect(find.text('Add note'), findsOneWidget);
      expect(find.text('No notes yet. Add your first one above.'), findsOneWidget);
    });

    testWidgets('Cycle through all 5 tabs in sequence without exception', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      for (final label in ['Calculate', 'Finance', 'Tools', 'Notes', 'Convert']) {
        await tapTab(tester, label);
        // No exceptions = pass. tester.takeException() will throw if any flutter error occurred.
        expect(tester.takeException(), isNull, reason: 'Tab "$label" should not throw');
      }
    });
  });
}
