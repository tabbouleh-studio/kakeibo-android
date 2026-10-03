import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/data/database.dart';
import 'package:kakeibo/models/enums.dart';

void main() {
  late AppDatabase db;

  setUp(
    () => db = AppDatabase(
      DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true),
    ),
  );
  tearDown(() => db.close());

  final sep = DateTime(2026, 9, 25);
  final oct = DateTime(2026, 10, 25);
  final dec = DateTime(2026, 12, 25);

  test('a month without a plan copies the most recent earlier plan', () async {
    await db.savePlan(
      periodStart: sep,
      incomeFils: 1000000,
      savingsGoalFils: 150000,
      costs: [(name: 'Rent', amountFils: 350000), (name: 'Phone', amountFils: 12500)],
    );

    await db.ensurePlanFor(dec);
    final plan = await db.watchPlan(dec).first;
    expect(plan, isNotNull);
    expect(plan!.incomeFils, 1000000);
    expect(plan.savingsGoalFils, 150000);
    expect([for (final c in plan.fixedCosts) c.name], ['Rent', 'Phone']);
    expect(plan.fixedCostsFils, 362500);
  });

  test('editing a month does not change earlier months', () async {
    await db.savePlan(
      periodStart: sep,
      incomeFils: 1000000,
      savingsGoalFils: 0,
      costs: [(name: 'Rent', amountFils: 350000)],
    );
    await db.ensurePlanFor(oct);
    await db.savePlan(
      periodStart: oct,
      incomeFils: 1100000,
      savingsGoalFils: 0,
      costs: [(name: 'Rent', amountFils: 400000)],
    );

    final september = await db.watchPlan(sep).first;
    expect(september!.incomeFils, 1000000);
    expect(september.fixedCostsFils, 350000);
    final october = await db.watchPlan(oct).first;
    expect(october!.fixedCostsFils, 400000);
  });

  test('ensurePlanFor does nothing without an earlier plan or with an existing one', () async {
    await db.ensurePlanFor(oct);
    expect(await db.watchPlan(oct).first, isNull);

    await db.savePlan(periodStart: oct, incomeFils: 5000, savingsGoalFils: 0, costs: []);
    await db.savePlan(periodStart: sep, incomeFils: 9000, savingsGoalFils: 0, costs: []);
    await db.ensurePlanFor(oct);
    expect((await db.watchPlan(oct).first)!.incomeFils, 5000);
  });

  test('entries are filtered by period and stored at local midnight', () async {
    await db.addEntry(
      amountFils: 2500,
      category: SpendCategory.wants,
      date: DateTime(2026, 10, 1, 18, 45),
      note: '  coffee ',
    );
    await db.addEntry(
      amountFils: 9000,
      category: SpendCategory.needs,
      date: DateTime(2026, 10, 25),
    );

    final entries = await db.watchEntries(sep, oct).first;
    expect(entries, hasLength(1));
    expect(entries.single.date, DateTime(2026, 10, 1));
    expect(entries.single.note, 'coffee');
    expect(entries.single.category, SpendCategory.wants);
  });
}
