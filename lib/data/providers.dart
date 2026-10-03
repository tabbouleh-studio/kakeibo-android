import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';
import '../models/budget_summary.dart';
import '../util/period.dart';
import 'database.dart';

/// Overridden in main() once preferences are loaded.
final sharedPrefsProvider = Provider<SharedPreferencesWithCache>(
  (ref) => throw UnimplementedError('sharedPrefsProvider must be overridden'),
);

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

class SettingsNotifier extends Notifier<AppSettings> {
  SharedPreferencesWithCache get _prefs => ref.read(sharedPrefsProvider);

  @override
  AppSettings build() {
    final prefs = ref.watch(sharedPrefsProvider);
    final backupMillis = prefs.getInt(AppSettings.lastBackupAtKey);
    return AppSettings(
      monthStartDay: prefs.getInt(AppSettings.monthStartDayKey) ?? 1,
      weekStartDay: prefs.getInt(AppSettings.weekStartDayKey) ?? DateTime.sunday,
      lockEnabled: prefs.getBool(AppSettings.lockEnabledKey) ?? false,
      lastBackupAt: backupMillis == null ? null : DateTime.fromMillisecondsSinceEpoch(backupMillis),
    );
  }

  Future<void> setMonthStartDay(int day) async {
    await _prefs.setInt(AppSettings.monthStartDayKey, day);
    state = state.copyWith(monthStartDay: day);
  }

  Future<void> setWeekStartDay(int weekday) async {
    await _prefs.setInt(AppSettings.weekStartDayKey, weekday);
    state = state.copyWith(weekStartDay: weekday);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);

/// The budget month containing today.
final currentPeriodProvider = Provider<Period>((ref) {
  final startDay = ref.watch(settingsProvider.select((s) => s.monthStartDay));
  return budgetMonthFor(DateTime.now(), startDay);
});

/// This month's plan, pre-filled from the latest earlier plan if missing.
final currentPlanProvider = StreamProvider<PlanData?>((ref) async* {
  final db = ref.watch(databaseProvider);
  final period = ref.watch(currentPeriodProvider);
  await db.ensurePlanFor(period.start);
  yield* db.watchPlan(period.start);
});

final currentEntriesProvider = StreamProvider<List<Entry>>((ref) {
  final db = ref.watch(databaseProvider);
  final period = ref.watch(currentPeriodProvider);
  return db.watchEntries(period.start, period.end);
});

final budgetSummaryProvider = FutureProvider<BudgetSummary>((ref) async {
  final plan = await ref.watch(currentPlanProvider.future);
  final entries = await ref.watch(currentEntriesProvider.future);
  return BudgetSummary.compute(
    hasPlan: plan != null,
    incomeFils: plan?.incomeFils ?? 0,
    fixedCostsFils: plan?.fixedCostsFils ?? 0,
    savingsGoalFils: plan?.savingsGoalFils ?? 0,
    spending: [for (final e in entries) (e.category, e.amountFils)],
  );
});

/// The budget month shown in the ledger. Starts at the current month.
class LedgerPeriodNotifier extends Notifier<Period> {
  int get _startDay => ref.read(settingsProvider).monthStartDay;

  @override
  Period build() => ref.watch(currentPeriodProvider);

  bool get canGoNext => state.start.isBefore(ref.read(currentPeriodProvider).start);

  void previous() => state = previousBudgetMonth(state, _startDay);

  void next() {
    if (canGoNext) state = nextBudgetMonth(state, _startDay);
  }
}

final ledgerPeriodProvider = NotifierProvider<LedgerPeriodNotifier, Period>(
  LedgerPeriodNotifier.new,
);

final ledgerEntriesProvider = StreamProvider<List<Entry>>((ref) {
  final db = ref.watch(databaseProvider);
  final period = ref.watch(ledgerPeriodProvider);
  return db.watchEntries(period.start, period.end);
});

/// Ledger search text; empty means not searching.
class LedgerSearchNotifier extends Notifier<String> {
  @override
  String build() => '';

  void set(String query) => state = query;
}

final ledgerSearchProvider = NotifierProvider<LedgerSearchNotifier, String>(
  LedgerSearchNotifier.new,
);

final searchResultsProvider = StreamProvider<List<Entry>>((ref) {
  final query = ref.watch(ledgerSearchProvider).trim();
  if (query.isEmpty) return Stream.value(const []);
  return ref.watch(databaseProvider).searchEntries(query);
});
