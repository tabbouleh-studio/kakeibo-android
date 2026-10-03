import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/models/budget_summary.dart';
import 'package:kakeibo/models/enums.dart';

BudgetSummary summary(
  List<(SpendCategory, int)> spending, {
  int income = 1000000,
  int fixed = 400000,
  int savings = 200000,
}) => BudgetSummary.compute(
  hasPlan: true,
  incomeFils: income,
  fixedCostsFils: fixed,
  savingsGoalFils: savings,
  spending: spending,
);

void main() {
  test('spendable and left', () {
    final s = summary([(SpendCategory.needs, 100000), (SpendCategory.needs, 50000)]);
    expect(s.spendableFils, 400000);
    expect(s.spentFils, 150000);
    expect(s.leftFils, 250000);
    expect(s.spentByCategory[SpendCategory.needs], 150000);
    expect(s.spentByCategory[SpendCategory.culture], 0);
    expect(s.categoryFraction(SpendCategory.needs), 0.375);
    expect(s.categoryShare(SpendCategory.needs), 1);
  });

  test('savings intact while within budget', () {
    final s = summary([(SpendCategory.wants, 400000)]);
    expect(s.leftFils, 0);
    expect(s.savedFils, 200000);
    expect(s.savingsProgress, 1);
    expect(s.overBudgetFils, 0);
  });

  test('overspending eats into savings first', () {
    final s = summary([(SpendCategory.wants, 450000)]);
    expect(s.leftFils, -50000);
    expect(s.savedFils, 150000);
    expect(s.savingsProgress, 0.75);
    expect(s.overBudgetFils, 0);
  });

  test('beyond savings is over budget', () {
    final s = summary([(SpendCategory.extra, 700000)]);
    expect(s.savedFils, 0);
    expect(s.overBudgetFils, 100000);
    expect(s.categoryFraction(SpendCategory.extra), 1);
  });

  test('no savings goal', () {
    final s = summary([(SpendCategory.needs, 10000)], savings: 0);
    expect(s.savedFils, 0);
    expect(s.savingsProgress, 0);
  });

  test('category share is the share of total spent', () {
    final s = BudgetSummary.compute(
      hasPlan: false,
      incomeFils: 0,
      fixedCostsFils: 0,
      savingsGoalFils: 0,
      spending: [(SpendCategory.needs, 3000), (SpendCategory.wants, 1000)],
    );
    expect(s.categoryShare(SpendCategory.needs), 0.75);
    expect(s.categoryShare(SpendCategory.culture), 0);
  });
}
