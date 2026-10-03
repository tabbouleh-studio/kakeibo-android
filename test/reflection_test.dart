import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/data/database.dart';
import 'package:kakeibo/models/enums.dart';
import 'package:kakeibo/models/reflection_numbers.dart';

void main() {
  group('computeReflectionNumbers', () {
    const spending = [(SpendCategory.needs, 30000), (SpendCategory.wants, 12500)];

    test('monthly uses the plan as is', () {
      final n = computeReflectionNumbers(
        type: ReflectionType.monthly,
        planMonthDays: 30,
        hasPlan: true,
        incomeFils: 1000000,
        fixedCostsFils: 400000,
        savingsGoalFils: 150000,
        spending: spending,
      );
      expect(n.haveFils, 600000);
      expect(n.saveFils, 150000);
      expect(n.spentFils, 42500);
      expect(n.spentByCategory[SpendCategory.wants], 12500);
      expect(n.spentByCategory[SpendCategory.extra], 0);
      expect(n.leftFils, 407500);
    });

    test('weekly uses a 7-day share of the month', () {
      final n = computeReflectionNumbers(
        type: ReflectionType.weekly,
        planMonthDays: 30,
        hasPlan: true,
        incomeFils: 1000000,
        fixedCostsFils: 400000,
        savingsGoalFils: 150000,
        spending: spending,
      );
      expect(n.haveFils, 140000);
      expect(n.saveFils, 35000);
      expect(n.spentFils, 42500);
    });

    test('prorate rounds to the nearest fils, including negatives', () {
      expect(prorate(1000, 7, 31), 226); // 225.8
      expect(prorate(-1000, 7, 31), -226);
      expect(prorate(0, 7, 31), 0);
    });
  });

  test('a saved reflection keeps its snapshot; later saves change notes only', () async {
    final db = AppDatabase(
      DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true),
    );
    final start = DateTime(2026, 9, 27);
    await db.saveReflection(
      type: ReflectionType.weekly,
      periodStart: start,
      haveFils: 100000,
      saveFils: 20000,
      spentFils: 30000,
      haveNote: '',
      saveNote: '',
      spendNote: '',
      improveNote: ' Cook more ',
    );
    await db.saveReflection(
      type: ReflectionType.weekly,
      periodStart: start,
      haveFils: 1,
      saveFils: 2,
      spentFils: 3,
      haveNote: 'ok',
      saveNote: '',
      spendNote: '',
      improveNote: 'Cook more, walk more',
    );
    final saved = await db.watchReflections(ReflectionType.weekly).first;
    expect(saved, hasLength(1));
    expect(saved.single.spentFils, 30000);
    expect(saved.single.haveFils, 100000);
    expect(saved.single.improveNote, 'Cook more, walk more');
    expect(saved.single.haveNote, 'ok');
    expect(await db.watchReflections(ReflectionType.monthly).first, isEmpty);
    await db.close();
  });
}
