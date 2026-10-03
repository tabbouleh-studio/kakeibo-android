import 'package:intl/intl.dart';

/// A half-open date range [start, end) of local-midnight dates.
class Period {
  const Period(this.start, this.end);

  final DateTime start;
  final DateTime end;

  bool contains(DateTime date) => !date.isBefore(start) && date.isBefore(end);

  DateTime get lastDay => DateTime(end.year, end.month, end.day - 1);

  int get lengthInDays => daysBetween(start, end);

  @override
  bool operator ==(Object other) => other is Period && other.start == start && other.end == end;

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() => 'Period($start, $end)';
}

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

int daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;

/// Whole calendar days from [from] to [to], unaffected by DST.
int daysBetween(DateTime from, DateTime to) => DateTime.utc(
  to.year,
  to.month,
  to.day,
).difference(DateTime.utc(from.year, from.month, from.day)).inDays;

/// Start of the budget month in the given calendar month. Start days past
/// the end of a short month clamp to its last day. [month] may overflow.
DateTime _monthStart(int year, int month, int startDay) {
  final first = DateTime(year, month);
  final day = startDay.clamp(1, daysInMonth(first.year, first.month));
  return DateTime(first.year, first.month, day);
}

/// The custom budget month containing [date], for "my month starts on day X".
Period budgetMonthFor(DateTime date, int startDay) {
  final d = dateOnly(date);
  var start = _monthStart(d.year, d.month, startDay);
  if (d.isBefore(start)) start = _monthStart(d.year, d.month - 1, startDay);
  return Period(start, _monthStart(start.year, start.month + 1, startDay));
}

/// The week containing [date]. [weekStartDay] uses [DateTime.weekday]
/// numbering (1 = Monday ... 7 = Sunday).
Period weekFor(DateTime date, int weekStartDay) {
  final d = dateOnly(date);
  final diff = (d.weekday - weekStartDay) % 7;
  final start = DateTime(d.year, d.month, d.day - diff);
  return Period(start, DateTime(start.year, start.month, start.day + 7));
}

/// "25 Sep – 24 Oct", adding years only when they differ from [now].
String formatPeriod(Period p, {DateTime? now}) {
  final year = (now ?? DateTime.now()).year;
  final last = p.lastDay;
  final showYear = p.start.year != year || last.year != year;
  final f = DateFormat(showYear ? 'd MMM y' : 'd MMM');
  return '${f.format(p.start)} – ${f.format(last)}';
}

/// The budget month before [p].
Period previousBudgetMonth(Period p, int startDay) =>
    budgetMonthFor(DateTime(p.start.year, p.start.month, p.start.day - 1), startDay);

/// The budget month after [p].
Period nextBudgetMonth(Period p, int startDay) => budgetMonthFor(p.end, startDay);

/// "Today", "Yesterday", "Thu 1 Oct", or "Thu 1 Oct 2025" for other years.
String formatDay(DateTime day, {DateTime? now}) {
  final today = now ?? DateTime.now();
  final diff = daysBetween(day, today);
  if (diff == 0) return 'Today';
  if (diff == 1) return 'Yesterday';
  return DateFormat(day.year == today.year ? 'EEE d MMM' : 'EEE d MMM y').format(day);
}
