import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'screens/about_screen.dart';
import 'screens/calculate/calculate_home.dart';
import 'screens/calculate/calculate_screens.dart';
import 'screens/convert_detail.dart';
import 'screens/convert_home.dart';
import 'screens/finance/finance_home.dart';
import 'screens/finance/finance_screens.dart';
import 'screens/notes_screen.dart';
import 'screens/paywall_screen.dart';
import 'screens/privacy_policy_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/tools/tools_home.dart';
import 'screens/tools/tools_screens.dart';
import 'widgets/tab_scaffold.dart';

final _convertNavKey = GlobalKey<NavigatorState>();
final _calculateNavKey = GlobalKey<NavigatorState>();
final _financeNavKey = GlobalKey<NavigatorState>();
final _toolsNavKey = GlobalKey<NavigatorState>();
final _notesNavKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  initialLocation: '/convert',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => TabScaffold(shell: shell),
      branches: [
        StatefulShellBranch(
          navigatorKey: _convertNavKey,
          routes: [
            GoRoute(
              path: '/convert',
              builder: (_, __) => const ConvertHome(),
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (_, state) => ConvertDetail(categoryId: state.pathParameters['id']!),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _calculateNavKey,
          routes: [
            GoRoute(
              path: '/calculate',
              builder: (_, __) => const CalculateHome(),
              routes: [
                GoRoute(path: 'standard', builder: (_, __) => const StandardCalc()),
                GoRoute(path: 'scientific', builder: (_, __) => const ScientificCalc()),
                GoRoute(path: 'percentage', builder: (_, __) => const PercentageCalc()),
                GoRoute(path: 'base', builder: (_, __) => const BaseCalc()),
                GoRoute(path: 'fraction', builder: (_, __) => const FractionCalc()),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _financeNavKey,
          routes: [
            GoRoute(
              path: '/finance',
              builder: (_, __) => const FinanceHome(),
              routes: [
                GoRoute(path: 'tax', builder: (_, __) => const TaxCalc()),
                GoRoute(path: 'tip', builder: (_, __) => const TipCalc()),
                GoRoute(path: 'discount', builder: (_, __) => const DiscountCalc()),
                GoRoute(path: 'compound', builder: (_, __) => const CompoundCalc()),
                GoRoute(path: 'emi', builder: (_, __) => const EmiCalc()),
                GoRoute(path: 'currency', builder: (_, __) => const CurrencyCalc()),
                GoRoute(path: 'unit-price', builder: (_, __) => const UnitPriceCalc()),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _toolsNavKey,
          routes: [
            GoRoute(
              path: '/tools',
              builder: (_, __) => const ToolsHome(),
              routes: [
                GoRoute(path: 'gps', builder: (_, __) => const GpsCalc()),
                GoRoute(path: 'ohm', builder: (_, __) => const OhmCalc()),
                GoRoute(path: 'bmi', builder: (_, __) => const BmiCalc()),
                GoRoute(path: 'date-diff', builder: (_, __) => const DateDiffCalc()),
                GoRoute(path: 'time-zones', builder: (_, __) => const TimeZonesScreen()),
                GoRoute(path: 'adc-dac', builder: (_, __) => const AdcDacCalc()),
                GoRoute(path: 'age', builder: (_, __) => const AgeCalc()),
                GoRoute(path: 'aspect-ratio', builder: (_, __) => const AspectRatioCalc()),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _notesNavKey,
          routes: [
            GoRoute(
              path: '/notes',
              builder: (_, __) => const NotesScreen(),
            ),
          ],
        ),
      ],
    ),
    // Modal-style routes pushed *over* the bottom-nav scaffold.
    GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
    GoRoute(path: '/paywall', builder: (_, __) => const PaywallScreen()),
    GoRoute(path: '/privacy', builder: (_, __) => const PrivacyPolicyScreen()),
    GoRoute(path: '/about', builder: (_, __) => const AboutScreen()),
  ],
);
