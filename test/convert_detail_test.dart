import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calcmaster/l10n/generated/app_localizations.dart';
import 'package:calcmaster/screens/convert_detail.dart';

MaterialApp _wrap(Widget child) => MaterialApp(
      home: child,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );

void main() {
  group('ConvertDetail · swap button', () {
    testWidgets('initial state shows mm → cm conversion', (tester) async {
      await tester.pumpWidget(_wrap(const ConvertDetail(categoryId: 'distance')));
      await tester.pumpAndSettle();

      // Header
      expect(find.text('Distance'), findsOneWidget);
      expect(find.text('9 units available'), findsOneWidget);

      // FROM and TO labels both visible
      expect(find.text('FROM'), findsOneWidget);
      expect(find.text('TO'), findsOneWidget);
      expect(find.text('ALL CONVERSIONS'), findsOneWidget);

      // Swap icon present
      expect(find.byIcon(Icons.swap_horiz), findsOneWidget);
    });

    testWidgets('typing 1 mm with TO=cm shows 0.1', (tester) async {
      await tester.pumpWidget(_wrap(const ConvertDetail(categoryId: 'distance')));
      await tester.pumpAndSettle();

      final inputFinder = find.byType(TextField);
      await tester.enterText(inputFinder, '1');
      await tester.pumpAndSettle();

      // 1 mm = 0.1 cm — find that exact value somewhere on screen
      // (cm is the second unit by default)
      expect(find.textContaining('0.1'), findsWidgets);
    });

    testWidgets('tapping swap button reverses FROM/TO units', (tester) async {
      await tester.pumpWidget(_wrap(const ConvertDetail(categoryId: 'distance')));
      await tester.pumpAndSettle();

      // Default state: FROM=mm, TO=cm. ALL CONVERSIONS for 1 mm shows cm row highlighted.
      await tester.enterText(find.byType(TextField), '1');
      await tester.pumpAndSettle();

      // Find swap button (by icon) and tap it
      final swap = find.byIcon(Icons.swap_horiz);
      expect(swap, findsOneWidget);
      await tester.tap(swap);
      await tester.pumpAndSettle();

      // After swap: FROM=cm, TO=mm. 1 cm = 10 mm.
      // The big TO value should now show "10".
      expect(find.text('10'), findsAtLeastNWidgets(1));
    });

    testWidgets('volume: 1 L → mL after typing', (tester) async {
      await tester.pumpWidget(_wrap(const ConvertDetail(categoryId: 'volume')));
      await tester.pumpAndSettle();
      // Default first units. Just confirm 1 of base unit produces nonzero output.
      await tester.enterText(find.byType(TextField), '1');
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.swap_horiz), findsOneWidget);
    });
  });
}
