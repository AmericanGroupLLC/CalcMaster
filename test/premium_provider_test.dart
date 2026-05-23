import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:calcmaster/monetization/premium_provider.dart';
import 'package:calcmaster/screens/paywall_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('PremiumProvider', () {
    test('default isPro is false', () async {
      final p = PremiumProvider();
      // Wait one microtask for hydration to complete.
      await Future<void>.delayed(Duration.zero);
      expect(p.isPro, isFalse);
    });

    test('purchase returns false when subscriptions disabled', () async {
      final p = PremiumProvider();
      await Future<void>.delayed(Duration.zero);
      final ok = await p.purchase(SubscriptionTier.annual);
      expect(ok, isFalse);
      expect(p.isPro, isFalse);
    });

    test('restore returns false when subscriptions disabled', () async {
      final p = PremiumProvider();
      await Future<void>.delayed(Duration.zero);
      final ok = await p.restore();
      expect(ok, isFalse);
    });

    test('setIsProForTest flips entitlement and persists', () async {
      final p = PremiumProvider();
      await Future<void>.delayed(Duration.zero);
      await p.setIsProForTest(true);
      expect(p.isPro, isTrue);

      // New instance hydrates from the same SharedPreferences mock.
      final p2 = PremiumProvider();
      await Future<void>.delayed(Duration.zero);
      expect(p2.isPro, isTrue);
    });
  });

  group('PaywallScreen', () {
    testWidgets('renders 3 tier cards + continue button', (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => PremiumProvider(),
          child: const MaterialApp(home: PaywallScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Unlock CalcMaster Pro'), findsOneWidget);
      expect(find.text('Monthly'), findsOneWidget);
      expect(find.text('Annual'), findsOneWidget);
      expect(find.text('Lifetime'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
      expect(find.text('Restore purchases'), findsOneWidget);
    });
  });
}
