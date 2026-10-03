import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/util/period.dart';

void main() {
  group('budgetMonthFor', () {
    test('default start day 1 is the calendar month', () {
      final p = budgetMonthFor(DateTime(2026, 10, 3, 15, 30), 1);
      expect(p.start, DateTime(2026, 10, 1));
      expect(p.end, DateTime(2026, 11, 1));
      expect(p.lengthInDays, 31);
    });

    test('start day 25, on and after the start day', () {
      final p = budgetMonthFor(DateTime(2026, 9, 25), 25);
      expect(p.start, DateTime(2026, 9, 25));
      expect(p.end, DateTime(2026, 10, 25));
      expect(p.lastDay, DateTime(2026, 10, 24));
    });

    test('start day 25, before the start day belongs to previous month', () {
      final p = budgetMonthFor(DateTime(2026, 10, 24, 23, 59), 25);
      expect(p.start, DateTime(2026, 9, 25));
    });

    test('crosses the year boundary', () {
      final p = budgetMonthFor(DateTime(2027, 1, 10), 25);
      expect(p.start, DateTime(2026, 12, 25));
      expect(p.end, DateTime(2027, 1, 25));
    });

    test('start day 31 clamps in short months', () {
      expect(
        budgetMonthFor(DateTime(2027, 3, 15), 31),
        Period(DateTime(2027, 2, 28), DateTime(2027, 3, 31)),
      );
      expect(
        budgetMonthFor(DateTime(2027, 2, 28), 31),
        Period(DateTime(2027, 2, 28), DateTime(2027, 3, 31)),
      );
      expect(
        budgetMonthFor(DateTime(2027, 2, 27), 31),
        Period(DateTime(2027, 1, 31), DateTime(2027, 2, 28)),
      );
      expect(
        budgetMonthFor(DateTime(2026, 5, 1), 31),
        Period(DateTime(2026, 4, 30), DateTime(2026, 5, 31)),
      );
    });

    test('start day 29 in a leap year', () {
      expect(budgetMonthFor(DateTime(2028, 2, 29), 29).start, DateTime(2028, 2, 29));
      expect(budgetMonthFor(DateTime(2027, 3, 1), 29).start, DateTime(2027, 2, 28));
    });

    test('consecutive months tile without gaps', () {
      for (final startDay in [1, 15, 25, 29, 30, 31]) {
        var p = budgetMonthFor(DateTime(2026, 1, 1), startDay);
        for (var i = 0; i < 24; i++) {
          final next = budgetMonthFor(p.end, startDay);
          expect(next.start, p.end, reason: 'startDay $startDay after $p');
          p = next;
        }
      }
    });
  });

  group('weekFor', () {
    // 3 Oct 2026 is a Saturday.
    final saturday = DateTime(2026, 10, 3, 9);

    test('Sunday start', () {
      final p = weekFor(saturday, DateTime.sunday);
      expect(p.start, DateTime(2026, 9, 27));
      expect(p.end, DateTime(2026, 10, 4));
    });

    test('Saturday start', () {
      expect(weekFor(saturday, DateTime.saturday).start, DateTime(2026, 10, 3));
    });

    test('Monday start', () {
      expect(weekFor(saturday, DateTime.monday).start, DateTime(2026, 9, 28));
    });
  });

  test('contains is half-open', () {
    final p = Period(DateTime(2026, 9, 25), DateTime(2026, 10, 25));
    expect(p.contains(DateTime(2026, 9, 25)), isTrue);
    expect(p.contains(DateTime(2026, 10, 24)), isTrue);
    expect(p.contains(DateTime(2026, 10, 25)), isFalse);
  });

  test('daysBetween', () {
    expect(daysBetween(DateTime(2026, 10, 3, 23), DateTime(2026, 10, 25)), 22);
  });

  test('formatPeriod', () {
    final p = Period(DateTime(2026, 9, 25), DateTime(2026, 10, 25));
    expect(formatPeriod(p, now: DateTime(2026, 10, 3)), '25 Sep – 24 Oct');
    expect(formatPeriod(p, now: DateTime(2027, 1, 1)), '25 Sep 2026 – 24 Oct 2026');
  });

  group('month navigation', () {
    test('previous and next with start day 25', () {
      final oct = budgetMonthFor(DateTime(2026, 10, 3), 25);
      expect(previousBudgetMonth(oct, 25).start, DateTime(2026, 8, 25));
      expect(nextBudgetMonth(oct, 25).start, DateTime(2026, 10, 25));
    });

    test('previous across a clamped February', () {
      final mar = budgetMonthFor(DateTime(2027, 3, 31), 31);
      expect(mar.start, DateTime(2027, 3, 31));
      final feb = previousBudgetMonth(mar, 31);
      expect(feb, Period(DateTime(2027, 2, 28), DateTime(2027, 3, 31)));
      expect(previousBudgetMonth(feb, 31).start, DateTime(2027, 1, 31));
    });
  });

  test('formatDay', () {
    final now = DateTime(2026, 10, 3, 12);
    expect(formatDay(DateTime(2026, 10, 3), now: now), 'Today');
    expect(formatDay(DateTime(2026, 10, 2), now: now), 'Yesterday');
    expect(formatDay(DateTime(2026, 10, 1), now: now), 'Thu 1 Oct');
    expect(formatDay(DateTime(2025, 12, 31), now: now), 'Wed 31 Dec 2025');
  });
}
