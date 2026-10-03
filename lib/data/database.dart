import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../models/enums.dart';
import '../util/money.dart';
import '../util/period.dart';
import 'tables.dart';

part 'database.g.dart';

typedef FixedCostDraft = ({String name, int amountFils});

/// A month plan together with its fixed costs.
class PlanData {
  const PlanData({
    required this.periodStart,
    required this.incomeFils,
    required this.savingsGoalFils,
    required this.fixedCosts,
  });

  final DateTime periodStart;
  final int incomeFils;
  final int savingsGoalFils;
  final List<FixedCost> fixedCosts;

  int get fixedCostsFils => fixedCosts.fold(0, (sum, c) => sum + c.amountFils);
}

@DriftDatabase(tables: [Entries, MonthPlans, FixedCosts, RecurringItems, Reflections])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? driftDatabase(name: 'kakeibo'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  // Entries

  Future<int> addEntry({
    required int amountFils,
    required SpendCategory category,
    required DateTime date,
    String note = '',
  }) => into(entries).insert(
    EntriesCompanion.insert(
      amountFils: amountFils,
      category: category,
      date: dateOnly(date),
      note: Value(note.trim()),
      createdAt: DateTime.now(),
    ),
  );

  /// Entries with start <= date < end, newest first.
  Stream<List<Entry>> watchEntries(DateTime start, DateTime end) {
    final query = select(entries)
      ..where((e) => e.date.isBiggerOrEqualValue(start) & e.date.isSmallerThanValue(end))
      ..orderBy([(e) => OrderingTerm.desc(e.date), (e) => OrderingTerm.desc(e.createdAt)]);
    return query.watch();
  }

  Future<void> updateEntry(Entry entry) =>
      update(entries).replace(entry.copyWith(date: dateOnly(entry.date), note: entry.note.trim()));

  Future<void> deleteEntry(int id) => (delete(entries)..where((e) => e.id.equals(id))).go();

  /// Puts a deleted entry back with its original id (for undo).
  Future<void> restoreEntry(Entry entry) => into(entries).insert(entry);

  /// All entries whose note contains [query], whose category starts with it,
  /// or whose amount equals it (e.g. "2.5"). Newest first.
  Stream<List<Entry>> searchEntries(String query) {
    final q = query.trim();
    final lower = q.toLowerCase();
    final categories = [
      for (final c in SpendCategory.values)
        if (c.label.toLowerCase().startsWith(lower)) c.name,
    ];
    final fils = parseFils(q);
    final escaped = q.replaceAll(r'\', r'\\').replaceAll('%', r'\%').replaceAll('_', r'\_');
    final statement = select(entries)
      ..where((e) {
        var condition = e.note.like('%$escaped%', escapeChar: r'\');
        if (categories.isNotEmpty) condition = condition | e.category.isIn(categories);
        if (fils != null && fils > 0) condition = condition | e.amountFils.equals(fils);
        return condition;
      })
      ..orderBy([(e) => OrderingTerm.desc(e.date), (e) => OrderingTerm.desc(e.createdAt)]);
    return statement.watch();
  }

  /// Every entry, oldest first (for CSV export).
  Future<List<Entry>> allEntries() => (select(
    entries,
  )..orderBy([(e) => OrderingTerm.asc(e.date), (e) => OrderingTerm.asc(e.createdAt)])).get();

  // Month plans

  Stream<PlanData?> watchPlan(DateTime periodStart) {
    final query =
        select(monthPlans).join([
            leftOuterJoin(fixedCosts, fixedCosts.periodStart.equalsExp(monthPlans.periodStart)),
          ])
          ..where(monthPlans.periodStart.equals(periodStart))
          ..orderBy([OrderingTerm.asc(fixedCosts.id)]);
    return query.watch().map((rows) {
      if (rows.isEmpty) return null;
      final plan = rows.first.readTable(monthPlans);
      return PlanData(
        periodStart: plan.periodStart,
        incomeFils: plan.incomeFils,
        savingsGoalFils: plan.savingsGoalFils,
        fixedCosts: [for (final row in rows) ?row.readTableOrNull(fixedCosts)],
      );
    });
  }

  /// If [periodStart] has no plan, copies the most recent earlier plan
  /// (income, savings goal and fixed costs) into it.
  Future<void> ensurePlanFor(DateTime periodStart) => transaction(() async {
    final existing = await (select(
      monthPlans,
    )..where((p) => p.periodStart.equals(periodStart))).getSingleOrNull();
    if (existing != null) return;

    final previous =
        await (select(monthPlans)
              ..where((p) => p.periodStart.isSmallerThanValue(periodStart))
              ..orderBy([(p) => OrderingTerm.desc(p.periodStart)])
              ..limit(1))
            .getSingleOrNull();
    if (previous == null) return;

    final costs =
        await (select(fixedCosts)
              ..where((c) => c.periodStart.equals(previous.periodStart))
              ..orderBy([(c) => OrderingTerm.asc(c.id)]))
            .get();
    await _writePlan(
      periodStart: periodStart,
      incomeFils: previous.incomeFils,
      savingsGoalFils: previous.savingsGoalFils,
      costs: [for (final c in costs) (name: c.name, amountFils: c.amountFils)],
    );
  });

  Future<void> savePlan({
    required DateTime periodStart,
    required int incomeFils,
    required int savingsGoalFils,
    required List<FixedCostDraft> costs,
  }) => transaction(
    () => _writePlan(
      periodStart: periodStart,
      incomeFils: incomeFils,
      savingsGoalFils: savingsGoalFils,
      costs: costs,
    ),
  );

  Future<void> _writePlan({
    required DateTime periodStart,
    required int incomeFils,
    required int savingsGoalFils,
    required List<FixedCostDraft> costs,
  }) async {
    // Upsert, not REPLACE: a REPLACE would delete the row and cascade to its costs.
    await into(monthPlans).insertOnConflictUpdate(
      MonthPlansCompanion.insert(
        periodStart: periodStart,
        incomeFils: incomeFils,
        savingsGoalFils: savingsGoalFils,
      ),
    );
    await (delete(fixedCosts)..where((c) => c.periodStart.equals(periodStart))).go();
    await batch(
      (b) => b.insertAll(fixedCosts, [
        for (final c in costs)
          FixedCostsCompanion.insert(
            periodStart: periodStart,
            name: c.name,
            amountFils: c.amountFils,
          ),
      ]),
    );
  }
}
