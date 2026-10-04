import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_info.dart';
import 'data/database.dart';
import 'data/providers.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/lock/app_gate.dart';
import 'features/shell/app_shell.dart';
import 'models/app_settings.dart';
import 'theme.dart';
import 'widgets/money_scope.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // SQLite is compiled into the app from source; list its notice too.
  LicenseRegistry.addLicense(() async* {
    yield const LicenseEntryWithLineBreaks(['SQLite'], sqliteNotice);
  });
  final prefs = await SharedPreferencesWithCache.create(
    cacheOptions: const SharedPreferencesWithCacheOptions(allowList: AppSettings.keys),
  );
  final db = AppDatabase();
  // People updating from a version without first-launch setup skip it.
  if (prefs.getBool(AppSettings.onboardingDoneKey) == null && await db.hasAnyData()) {
    await prefs.setBool(AppSettings.onboardingDoneKey, true);
  }
  runApp(
    ProviderScope(
      overrides: [
        sharedPrefsProvider.overrideWithValue(prefs),
        databaseProvider.overrideWithValue(db),
      ],
      child: const KakeiboApp(),
    ),
  );
}

class KakeiboApp extends ConsumerWidget {
  const KakeiboApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Kakeibo',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      themeMode: ref.watch(settingsProvider.select((s) => s.themeMode)),
      scaffoldMessengerKey: messengerKey,
      builder: (context, child) => Consumer(
        builder: (context, ref, _) {
          final settings = ref.watch(settingsProvider);
          final revealed = ref.watch(amountsRevealedProvider);
          final dark = Theme.of(context).brightness == Brightness.dark;
          // Status bar icons follow the app theme, also on screens without an app bar.
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: (dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark).copyWith(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: Colors.transparent,
            ),
            child: MoneyScope(
              currency: settings.currency,
              hidden: settings.hideAmounts && !revealed,
              child: AppGate(child: child!),
            ),
          );
        },
      ),
      home: ref.watch(settingsProvider.select((s) => s.onboardingDone))
          ? const AppShell()
          : const OnboardingScreen(),
    );
  }
}
