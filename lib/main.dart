import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_router.dart';
import 'l10n/generated/app_localizations.dart';
import 'monetization/ad_service.dart';
import 'monetization/analytics_service.dart';
import 'monetization/premium_provider.dart';
import 'services/supabase_config.dart';
import 'state/auth_provider.dart';
import 'state/notes_provider.dart';
import 'state/region_provider.dart';
import 'theme/app_theme.dart';
import 'theme/tokens.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  ));
  // Supabase handles auth + session persistence. Guarded so a missing/invalid
  // config never hard-blocks app startup (login simply won't be available).
  try {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
  } catch (e) {
    debugPrint('Supabase init failed: $e');
  }
  // Fire-and-forget bootstrap. Each service no-ops gracefully when its
  // credentials are missing, so this never blocks startup.
  AnalyticsService.instance.bootstrap();
  AdService.instance.bootstrap();
  runApp(const CalcMasterApp());
}

class CalcMasterApp extends StatelessWidget {
  const CalcMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    final base = buildAppTheme();
    final theme = base.copyWith(
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: AppColors.text,
        displayColor: AppColors.text,
      ),
    );
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RegionProvider()),
        ChangeNotifierProvider(create: (_) => NotesProvider()),
        ChangeNotifierProvider(create: (_) => PremiumProvider()),
        ChangeNotifierProvider(create: (_) {
          final auth = AuthProvider();
          auth.init();
          return auth;
        }),
      ],
      child: MaterialApp.router(
        title: 'CalcMaster',
        theme: theme,
        debugShowCheckedModeBanner: false,
        routerConfig: appRouter,
        // Internationalization: 12 locales supported. MaterialApp auto-flips
        // direction for RTL locales (Arabic). When the device locale isn't in
        // the list, fall back to English.
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        localeResolutionCallback: (deviceLocale, supported) {
          if (deviceLocale == null) return const Locale('en');
          for (final s in supported) {
            if (s.languageCode == deviceLocale.languageCode) return s;
          }
          return const Locale('en');
        },
      ),
    );
  }
}
