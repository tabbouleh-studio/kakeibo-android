import 'dart:math';

import 'enums.dart';

/// The numbers behind the home screen for one budget month.
class BudgetSummary {
  BudgetSummary({
    required this.hasPlan,
    required this.incomeFils,
    required this.fixedCostsFils,
    required this.savingsGoalFils,
    required Map<SpendCategory, int> spentByCategory,
  }) : spentByCategory = {for (final c in SpendCategory.values) c: spentByCategory[c] ?? 0};

  factory BudgetSummary.compute({
    required bool hasPlan,
    required int incomeFils,
    required int fixedCostsFils,
    required int savingsGoalFils,
    required Iterable<(SpendCategory, int)> spending,
  }) {
    final byCategory = <SpendCategory, int>{};
    for (final (category, fils) in spending) {
      byCategory[category] = (byCategory[category] ?? 0) + fils;
    }
    return BudgetSummary(
      hasPlan: hasPlan,
      incomeFils: incomeFils,
      fixedCostsFils: fixedCostsFils,
      savingsGoalFils: savingsGoalFils,
      spentByCategory: byCategory,
    );
  }

  final bool hasPlan;
  final int incomeFils;
  final int fixedCostsFils;
  final int savingsGoalFils;
  final Map<SpendCategory, int> spentByCategory;

  /// Income − fixed costs − savings goal.
  int get spendableFils => incomeFils - fixedCostsFils - savingsGoalFils;

  int get spentFils => spentByCategory.values.fold(0, (a, b) => a + b);

  /// Negative when overspent.
  int get leftFils => spendableFils - spentFils;

  /// Savings still intact: overspending eats into the savings goal first.
  int get savedFils => max(0, savingsGoalFils + min(0, leftFils));

  /// Overspending beyond what the savings goal could absorb.
  int get overBudgetFils => max(0, -(savingsGoalFils + leftFils));

  double get savingsProgress => savingsGoalFils <= 0 ? 0 : savedFils / savingsGoalFils;

  /// Share of the spendable amount used by [category], 0..1.
  double categoryFraction(SpendCategory category) {
    final spent = spentByCategory[category]!;
    if (spendableFils <= 0) return spent > 0 ? 1 : 0;
    return min(1, spent / spendableFils);
  }

  /// For display: share of the spendable amount when planned, otherwise
  /// share of everything spent. 0..1.
  double categoryShare(SpendCategory category) {
    if (hasPlan) return categoryFraction(category);
    final total = spentFils;
    return total == 0 ? 0 : spentByCategory[category]! / total;
  }
}
