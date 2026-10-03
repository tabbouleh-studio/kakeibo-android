import 'enums.dart';

/// The pre-filled answers to the first three Kakeibo questions.
class ReflectionNumbers {
  const ReflectionNumbers({
    required this.hasPlan,
    required this.haveFils,
    required this.saveFils,
    required this.spentFils,
    required this.spentByCategory,
  });

  final bool hasPlan;

  /// 1. How much money did I have? Income minus fixed costs.
  final int haveFils;

  /// 2. How much did I want to save? The savings goal.
  final int saveFils;

  /// 3. How much did I spend?
  final int spentFils;
  final Map<SpendCategory, int> spentByCategory;

  /// What's left after spending and saving. Negative means savings were used.
  int get leftFils => haveFils - saveFils - spentFils;
}

/// Monthly reflections use the month's plan as is. Weekly ones use the
/// week's share (7 days) of the plan of the budget month the week starts in.
ReflectionNumbers computeReflectionNumbers({
  required ReflectionType type,
  required int planMonthDays,
  required bool hasPlan,
  required int incomeFils,
  required int fixedCostsFils,
  required int savingsGoalFils,
  required Iterable<(SpendCategory, int)> spending,
}) {
  int share(int fils) => type == ReflectionType.monthly ? fils : prorate(fils, 7, planMonthDays);
  final byCategory = {for (final c in SpendCategory.values) c: 0};
  for (final (c, fils) in spending) {
    byCategory[c] = byCategory[c]! + fils;
  }
  return ReflectionNumbers(
    hasPlan: hasPlan,
    haveFils: share(incomeFils - fixedCostsFils),
    saveFils: share(savingsGoalFils),
    spentFils: byCategory.values.fold(0, (a, b) => a + b),
    spentByCategory: byCategory,
  );
}

/// fils × part / whole, rounded to the nearest fils, in integer maths.
int prorate(int fils, int part, int whole) {
  final n = fils.abs() * part;
  final rounded = (2 * n + whole) ~/ (2 * whole);
  return fils < 0 ? -rounded : rounded;
}
