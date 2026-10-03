import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/data/database.dart';
import 'package:kakeibo/models/enums.dart';
import 'package:kakeibo/models/recurring.dart';

void main() {
  group('advanceDueDate', () {
    test('weekly adds seven days, across months', () {
      expect(advanceDueDate(DateTime(2026, 9, 28), Frequency.weekly), DateTime(2026, 10, 5));
    });

    test('monthly keeps the day', () {
      expect(advanceDueDate(DateTime(2026, 10, 5), Frequency.monthly), DateTime(2026, 11, 5));
      expect(advanceDueDate(DateTime(2026, 12, 15), Frequency.monthly), DateTime(2027, 1, 15));
    });

    test('monthly clamps to short months and the last day stays the last day', () {
      var d = DateTime(2027, 1, 31);
      final seen = <DateTime>[];
      for (var i = 0; i < 3; i++) {
        d = advanceDueDate(d, Frequency.monthly);
        seen.add(d);
      }
      expect(seen, [DateTime(2027, 2, 28), DateTime(2027, 3, 31), DateTime(2027, 4, 30)]);
      expect(advanceDueDate(DateTime(2027, 1, 29), Frequency.monthly), DateTime(2027, 2, 28));
    });
  });

  group('occurrencesUntil', () {
    test('catches up on every missed occurrence, including today', () {
      final r = occurrencesUntil(DateTime(2026, 7, 5), Frequency.monthly, DateTime(2026, 10, 5, 8));
      expect(r.due, [
        DateTime(2026, 7, 5),
        DateTime(2026, 8, 5),
        DateTime(2026, 9, 5),
        DateTime(2026, 10, 5),
      ]);
      expect(r.next, DateTime(2026, 11, 5));
    });

    test('nothing due in the future', () {
      final r = occurrencesUntil(DateTime(2026, 10, 10), Frequency.weekly, DateTime(2026, 10, 3));
      expect(r.due, isEmpty);
      expect(r.next, DateTime(2026, 10, 10));
    });
  });

  test('processDueRecurring logs due entries once and skips paused items', () async {
    final db = AppDatabase(
      DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true),
    );
    await db.saveRecurringItem(
      RecurringItemsCompanion.insert(
        name: 'Netflix',
        amountFils: 3500,
        category: SpendCategory.wants,
        frequency: Frequency.monthly,
        nextDueDate: DateTime(2026, 8, 20),
      ),
    );
    await db.saveRecurringItem(
      RecurringItemsCompanion.insert(
        name: 'Paused gym',
        amountFils: 15000,
        category: SpendCategory.needs,
        frequency: Frequency.weekly,
        nextDueDate: DateTime(2026, 9, 1),
        active: const Value(false),
      ),
    );

    expect(await db.processDueRecurring(DateTime(2026, 10, 3)), 2);
    expect(await db.processDueRecurring(DateTime(2026, 10, 3)), 0);

    final entries = await db.allEntries();
    expect([for (final e in entries) e.date], [DateTime(2026, 8, 20), DateTime(2026, 9, 20)]);
    expect(entries.every((e) => e.note == 'Netflix' && e.recurringId != null), isTrue);
    final items = await db.watchRecurringItems().first;
    expect(items.firstWhere((i) => i.name == 'Netflix').nextDueDate, DateTime(2026, 10, 20));

    // Deleting the item keeps its past entries.
    await db.deleteRecurringItem(items.firstWhere((i) => i.name == 'Netflix').id);
    final after = await db.allEntries();
    expect(after, hasLength(2));
    expect(after.every((e) => e.recurringId == null), isTrue);
    await db.close();
  });
}
