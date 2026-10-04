import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/data/database.dart';
import 'package:kakeibo/data/providers.dart';
import 'package:kakeibo/features/home/home_screen.dart';
import 'package:kakeibo/models/app_settings.dart';
import 'package:kakeibo/models/enums.dart';
import 'package:kakeibo/theme.dart';

class _FakeSettings extends SettingsNotifier {
  @override
  AppSettings build() => const AppSettings();
}

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 20)));
    await tester.pump(const Duration(milliseconds: 300));
  }
}

void main() {
  testWidgets('tapping a category on Home lists only its expenses', (tester) async {
    tester.view.physicalSize = const Size(1200, 2600);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final db = AppDatabase(
      DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true),
    );
    await tester.runAsync(() async {
      final today = DateTime.now();
      await db.addEntry(
        amountFils: 4500,
        category: SpendCategory.wants,
        date: today,
        note: 'Cinema',
      );
      await db.addEntry(
        amountFils: 2500,
        category: SpendCategory.wants,
        date: today,
        note: 'Coffee',
      );
      await db.addEntry(
        amountFils: 30000,
        category: SpendCategory.needs,
        date: today,
        note: 'Groceries',
      );
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          settingsProvider.overrideWith(_FakeSettings.new),
        ],
        child: MaterialApp(theme: buildTheme(Brightness.light), home: const HomeScreen()),
      ),
    );
    await settle(tester);

    await tester.tap(find.text('Wants'));
    await settle(tester);
    expect(find.text('Cinema'), findsOneWidget);
    expect(find.text('Coffee'), findsOneWidget);
    expect(find.text('Groceries'), findsNothing);
    // Wants: 7.000 of 37.000 spent this month.
    expect(find.text('19%'), findsOneWidget);

    // + opens a new expense with Wants already chosen.
    await tester.tap(find.byTooltip('Add Wants expense'));
    await settle(tester);
    await tester.tap(find.text('5').last);
    await tester.pump();
    expect(find.text('Save KD 5.000'), findsOneWidget);
  });
}
