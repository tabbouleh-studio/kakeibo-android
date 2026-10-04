import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/providers.dart';
import 'features/lock/app_gate.dart';
import 'features/shell/app_shell.dart';
import 'models/app_settings.dart';
import 'theme.dart';
import 'widgets/money_scope.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferencesWithCache.create(
    cacheOptions: const SharedPreferencesWithCacheOptions(allowList: AppSettings.keys),
  );
  runApp(
    ProviderScope(
      overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
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
      home: const AppShell(),
    );
  }
}
