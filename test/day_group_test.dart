import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/models/day_group.dart';

void main() {
  test('groups consecutive items by calendar day with totals', () {
    final items = [
      (DateTime(2026, 10, 3, 18), 1000),
      (DateTime(2026, 10, 3, 9), 2500),
      (DateTime(2026, 10, 1), 750),
    ];
    final groups = groupByDay(items, dateOf: (i) => i.$1, filsOf: (i) => i.$2);
    expect(groups, hasLength(2));
    expect(groups[0].day, DateTime(2026, 10, 3));
    expect(groups[0].items, hasLength(2));
    expect(groups[0].totalFils, 3500);
    expect(groups[1].day, DateTime(2026, 10, 1));
    expect(groups[1].totalFils, 750);
  });

  test('empty input gives no groups', () {
    expect(groupByDay(<int>[], dateOf: (_) => DateTime(2026), filsOf: (i) => i), isEmpty);
  });
}
