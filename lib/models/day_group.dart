/// Items that fall on the same day, with their total.
class DayGroup<T> {
  const DayGroup(this.day, this.items, this.totalFils);

  final DateTime day;
  final List<T> items;
  final int totalFils;
}

/// Groups [items] (already sorted newest first) by calendar day.
List<DayGroup<T>> groupByDay<T>(
  Iterable<T> items, {
  required DateTime Function(T) dateOf,
  required int Function(T) filsOf,
}) {
  final groups = <DayGroup<T>>[];
  DateTime? day;
  var bucket = <T>[];
  var total = 0;
  for (final item in items) {
    final d = dateOf(item);
    final itemDay = DateTime(d.year, d.month, d.day);
    if (itemDay != day) {
      if (day != null) groups.add(DayGroup(day, bucket, total));
      day = itemDay;
      bucket = [];
      total = 0;
    }
    bucket.add(item);
    total += filsOf(item);
  }
  if (day != null) groups.add(DayGroup(day, bucket, total));
  return groups;
}
