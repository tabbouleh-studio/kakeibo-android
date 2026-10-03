import 'dart:convert';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/data/backup.dart';
import 'package:kakeibo/data/csv_export.dart';
import 'package:kakeibo/data/database.dart';
import 'package:kakeibo/models/enums.dart';

AppDatabase memoryDb() =>
    AppDatabase(DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true));

const settings = BackupSettings(
  monthStartDay: 25,
  weekStartDay: DateTime.saturday,
  lockEnabled: true,
);

Future<void> fill(AppDatabase db) async {
  await db.savePlan(
    periodStart: DateTime(2026, 9, 25),
    incomeFils: 1250000,
    savingsGoalFils: 200000,
    costs: [(name: 'Rent', amountFils: 450000), (name: 'Phone', amountFils: 8500)],
  );
  final recurringId = await db
      .into(db.recurringItems)
      .insert(
        RecurringItemsCompanion.insert(
          name: 'Netflix',
          amountFils: 3500,
          category: SpendCategory.wants,
          frequency: Frequency.monthly,
          nextDueDate: DateTime(2026, 11, 5),
        ),
      );
  await db.addEntry(
    amountFils: 2500,
    category: SpendCategory.wants,
    date: DateTime(2026, 10, 1),
    note: 'Coffee, "flat white"',
  );
  await db
      .into(db.entries)
      .insert(
        EntriesCompanion.insert(
          amountFils: 3500,
          category: SpendCategory.wants,
          date: DateTime(2026, 10, 5),
          createdAt: DateTime(2026, 10, 5, 9, 30),
          note: const Value('Netflix'),
          recurringId: Value(recurringId),
        ),
      );
  await db
      .into(db.reflections)
      .insert(
        ReflectionsCompanion.insert(
          type: ReflectionType.weekly,
          periodStart: DateTime(2026, 9, 27),
          haveFils: 400000,
          saveFils: 200000,
          spentFils: -6000,
          improveNote: const Value('Fewer coffees'),
          createdAt: DateTime(2026, 10, 3, 20),
        ),
      );
}

Map<String, Object?> withoutTimestamp(BackupData d) => d.toJson()..remove('exportedAt');

void main() {
  test('backup round-trip restores identical data', () async {
    final source = memoryDb();
    await fill(source);
    final backup = await createBackup(source, settings);
    final text = backup.encode();

    final target = memoryDb();
    await target.addEntry(amountFils: 999, category: SpendCategory.extra, date: DateTime(2020));
    final parsed = BackupData.decode(text);
    await restoreBackup(target, parsed);

    final again = await createBackup(target, settings);
    expect(jsonEncode(withoutTimestamp(again)), jsonEncode(withoutTimestamp(backup)));
    expect(parsed.settings.monthStartDay, 25);
    expect(parsed.settings.weekStartDay, DateTime.saturday);
    expect(parsed.settings.lockEnabled, isTrue);
    expect(parsed.entries.first.date, DateTime(2026, 10, 1));

    // Restored data behaves like normal data.
    final plan = await target.watchPlan(DateTime(2026, 9, 25)).first;
    expect(plan!.fixedCostsFils, 458500);
    await source.close();
    await target.close();
  });

  group('validation', () {
    late Map<String, dynamic> valid;

    setUp(() async {
      final db = memoryDb();
      await fill(db);
      valid = jsonDecode((await createBackup(db, settings)).encode()) as Map<String, dynamic>;
      await db.close();
    });

    void rejects(void Function(Map<String, dynamic> j) mutate, String messagePart) {
      final j = jsonDecode(jsonEncode(valid)) as Map<String, dynamic>;
      mutate(j);
      expect(
        () => BackupData.decode(jsonEncode(j)),
        throwsA(
          isA<BackupFormatException>().having((e) => e.message, 'message', contains(messagePart)),
        ),
      );
    }

    List<dynamic> list(Map<String, dynamic> j, String k) => j[k] as List<dynamic>;
    Map<String, dynamic> first(Map<String, dynamic> j, String k) =>
        list(j, k).first as Map<String, dynamic>;

    test('valid file parses', () => expect(BackupData.decode(jsonEncode(valid)), isNotNull));

    test('not JSON', () {
      expect(() => BackupData.decode('{oops'), throwsA(isA<BackupFormatException>()));
    });
    test('wrong app', () => rejects((j) => j['app'] = 'other', 'not a Kakeibo backup'));
    test('newer schema', () => rejects((j) => j['schemaVersion'] = 99, 'newer version'));
    test('missing list', () => rejects((j) => j.remove('entries'), 'entries should be a list'));
    test('zero amount', () => rejects((j) => first(j, 'entries')['amountFils'] = 0, 'amountFils'));
    test(
      'decimal amount',
      () => rejects((j) => first(j, 'entries')['amountFils'] = 2.5, 'amountFils'),
    );
    test(
      'bad category',
      () => rejects((j) => first(j, 'entries')['category'] = 'food', 'category'),
    );
    test(
      'impossible date',
      () => rejects((j) => first(j, 'entries')['date'] = '2026-02-30', 'date'),
    );
    test(
      'bad month start',
      () => rejects((j) => j['settings']['monthStartDay'] = 32, 'monthStartDay'),
    );
    test('bad week start', () => rejects((j) => j['settings']['weekStartDay'] = 3, 'weekStartDay'));
    test(
      'duplicate entry ids',
      () => rejects((j) => list(j, 'entries').add(first(j, 'entries')), 'Duplicate entry id'),
    );
    test(
      'orphan fixed cost',
      () => rejects((j) => first(j, 'fixedCosts')['periodStart'] = '2020-01-01', 'missing'),
    );
    test(
      'dangling recurring id',
      () => rejects((j) => list(j, 'recurringItems').clear(), 'recurring item that is missing'),
    );
  });

  test('CSV has BOM, header, ISO dates, plain amounts and quoted notes', () {
    final entries = [
      Entry(
        id: 1,
        amountFils: 12750,
        category: SpendCategory.needs,
        note: 'Groceries, Lulu',
        date: DateTime(2026, 10, 1),
        createdAt: DateTime(2026, 10, 1),
      ),
      Entry(
        id: 2,
        amountFils: 1234500,
        category: SpendCategory.culture,
        note: 'Course "Dart"',
        date: DateTime(2026, 10, 2),
        createdAt: DateTime(2026, 10, 2),
      ),
    ];
    final bytes = entriesToCsv(entries);
    expect(bytes.sublist(0, 3), [0xEF, 0xBB, 0xBF]);
    expect(utf8.decode(bytes.sublist(3)).split('\r\n'), [
      'Date,Category,Amount (KWD),Note',
      '2026-10-01,Needs,12.750,"Groceries, Lulu"',
      '2026-10-02,Culture,1234.500,"Course ""Dart"""',
      '',
    ]);
  });
}
