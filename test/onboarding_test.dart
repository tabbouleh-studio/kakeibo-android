import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/data/database.dart';
import 'package:kakeibo/data/providers.dart';
import 'package:kakeibo/features/onboarding/onboarding_screen.dart';
import 'package:kakeibo/models/app_settings.dart';
import 'package:kakeibo/models/currency.dart';
import 'package:kakeibo/models/region_currency.dart';
import 'package:kakeibo/theme.dart';
import 'package:kakeibo/util/region.dart';

/// Keeps settings in memory instead of shared preferences.
class _MemorySettings extends SettingsNotifier {
  @override
  AppSettings build() => const AppSettings();

  @override
  Future<void> setCurrency(String code) async => state = state.copyWith(currencyCode: code);

  @override
  Future<void> setMonthStartDay(int day) async => state = state.copyWith(monthStartDay: day);

  @override
  Future<void> setOnboardingDone() async => state = state.copyWith(onboardingDone: true);
}

void main() {
  group('region', () {
    test('reads the country from the first locale that has one', () {
      expect(phoneRegion(const [Locale('en'), Locale('ar', 'KW')]), 'KW');
      expect(phoneRegion(const [Locale('en')]), isNull);
    });

    test('maps regions to currencies', () {
      expect(currencyForRegion('KW')?.code, 'KWD');
      expect(currencyForRegion('DE')?.code, 'EUR');
      expect(currencyForRegion('JP')?.code, 'JPY');
      expect(currencyForRegion('ZZ'), isNull);
      expect(currencyForRegion(null), isNull);
    });

    test('every mapped currency exists in the app', () {
      for (final code in regionCurrency.values) {
        expect(Currency.isKnown(code), isTrue, reason: code);
      }
    });
  });

  testWidgets('first-launch setup saves currency and month start', (tester) async {
    tester.view.physicalSize = const Size(1200, 2600);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    tester.platformDispatcher.localesTestValue = const [Locale('en', 'KW')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);

    final db = AppDatabase(
      DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true),
    );
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        settingsProvider.overrideWith(_MemorySettings.new),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(theme: buildTheme(Brightness.light), home: const OnboardingScreen()),
      ),
    );
    expect(find.text('Welcome to Kakeibo'), findsOneWidget);

    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();
    expect(find.text('Which currency do you use?'), findsOneWidget);
    expect(find.textContaining('Suggested from your phone'), findsOneWidget);
    // Pre-selected from the region and shown first.
    expect(find.text('Kuwaiti Dinar'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('When does your month start?'), findsOneWidget);
    await tester.tap(find.text('25'));
    await tester.pump();

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Explore first'));
    await tester.pumpAndSettle();

    final settings = container.read(settingsProvider);
    expect(settings.onboardingDone, isTrue);
    expect(settings.currencyCode, 'KWD');
    expect(settings.monthStartDay, 25);
    await db.close();
  });
}
