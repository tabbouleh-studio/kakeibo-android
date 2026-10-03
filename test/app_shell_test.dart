import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/data/database.dart';
import 'package:kakeibo/data/providers.dart';
import 'package:kakeibo/features/shell/app_shell.dart';
import 'package:kakeibo/models/app_settings.dart';
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
  testWidgets('bottom bar switches tabs, + opens entry, back returns home', (tester) async {
    final db = AppDatabase(
      DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          settingsProvider.overrideWith(_FakeSettings.new),
        ],
        child: MaterialApp(theme: buildTheme(Brightness.light), home: const AppShell()),
      ),
    );
    await settle(tester);
    expect(find.text('Start your month with intention'), findsOneWidget);

    await tester.tap(find.text('Ledger'));
    await settle(tester);
    expect(find.text('A clean page'), findsOneWidget);

    await tester.tap(find.text('Reflect').last);
    await settle(tester);
    expect(find.text('This week'), findsOneWidget);

    await tester.tap(find.text('Settings').last);
    await settle(tester);
    expect(find.text('App lock'), findsOneWidget);

    await tester.tap(find.text('Add'));
    await settle(tester);
    expect(find.text('New expense'), findsOneWidget);
    await tester.tap(find.byTooltip('Close'));
    await settle(tester);
    expect(find.text('App lock'), findsOneWidget);

    // System back from a tab goes to Home first.
    await tester.binding.handlePopRoute();
    await settle(tester);
    expect(find.text('Start your month with intention'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(db.close);
  });
}
