import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/data/database.dart';
import 'package:kakeibo/data/providers.dart';
import 'package:kakeibo/features/ledger/ledger_screen.dart';
import 'package:kakeibo/models/app_settings.dart';
import 'package:kakeibo/models/enums.dart';
import 'package:kakeibo/theme.dart';

class _FakeSettings extends SettingsNotifier {
  @override
  AppSettings build() => const AppSettings();
}

/// Lets drift's real async work finish between frames.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 20)));
    await tester.pump(const Duration(milliseconds: 300));
  }
}

void main() {
  testWidgets('swipe to delete, then undo', (tester) async {
    final db = AppDatabase(
      DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true),
    );
    await tester.runAsync(() async {
      await db.addEntry(
        amountFils: 2500,
        category: SpendCategory.wants,
        date: DateTime.now(),
        note: 'Coffee',
      );
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          settingsProvider.overrideWith(_FakeSettings.new),
        ],
        child: MaterialApp(theme: buildTheme(Brightness.light), home: const LedgerScreen()),
      ),
    );
    await settle(tester);
    expect(find.text('Coffee'), findsOneWidget);

    await tester.drag(find.text('Coffee'), const Offset(-600, 0));
    await settle(tester);
    expect(find.text('Coffee'), findsNothing);
    expect(find.textContaining('Deleted KD 2.500'), findsOneWidget);
    expect(
      await tester.runAsync(() => db.watchEntries(DateTime(2000), DateTime(2100)).first),
      isEmpty,
    );

    await tester.tap(find.text('Undo'));
    await settle(tester);
    expect(find.text('Coffee'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(db.close);
  });
}
