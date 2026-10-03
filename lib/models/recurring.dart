import 'dart:math';

import '../util/period.dart';
import 'enums.dart';

/// The due date after [date]. Monthly items keep their day of month, clamped
/// to shorter months; an item due on the last day of a month stays on the
/// last day (31 Jan → 28 Feb → 31 Mar).
DateTime advanceDueDate(DateTime date, Frequency frequency) {
  if (frequency == Frequency.weekly) {
    return DateTime(date.year, date.month, date.day + 7);
  }
  final next = DateTime(date.year, date.month + 1);
  final lastOfNext = daysInMonth(next.year, next.month);
  final wasLastDay = date.day == daysInMonth(date.year, date.month);
  return DateTime(next.year, next.month, wasLastDay ? lastOfNext : min(date.day, lastOfNext));
}

/// Every occurrence from [nextDue] up to and including [today], and the
/// due date that follows them. Catches up on all missed occurrences.
({List<DateTime> due, DateTime next}) occurrencesUntil(
  DateTime nextDue,
  Frequency frequency,
  DateTime today, {
  int limit = 1000,
}) {
  final end = dateOnly(today);
  final due = <DateTime>[];
  var d = dateOnly(nextDue);
  while (!d.isAfter(end) && due.length < limit) {
    due.add(d);
    d = advanceDueDate(d, frequency);
  }
  return (due: due, next: d);
}
