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
