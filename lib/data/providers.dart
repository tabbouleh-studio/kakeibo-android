import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';
import '../models/budget_summary.dart';
import '../models/enums.dart';
import '../util/period.dart';
import 'backup.dart';
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
      currencyCode: prefs.getString(AppSettings.currencyKey) ?? 'KWD',
      hideAmounts: prefs.getBool(AppSettings.hideAmountsKey) ?? false,
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

  Future<void> setLockEnabled(bool enabled) async {
    await _prefs.setBool(AppSettings.lockEnabledKey, enabled);
    state = state.copyWith(lockEnabled: enabled);
  }

  Future<void> setCurrency(String code) async {
    await _prefs.setString(AppSettings.currencyKey, code);
    state = state.copyWith(currencyCode: code);
  }

  Future<void> setHideAmounts(bool hide) async {
    await _prefs.setBool(AppSettings.hideAmountsKey, hide);
    state = state.copyWith(hideAmounts: hide);
  }

  Future<void> setLastBackupAt(DateTime time) async {
    await _prefs.setInt(AppSettings.lastBackupAtKey, time.millisecondsSinceEpoch);
    state = state.copyWith(lastBackupAt: time);
  }

  Future<void> applyBackup(BackupSettings s) async {
    await setMonthStartDay(s.monthStartDay);
    await setWeekStartDay(s.weekStartDay);
    await setLockEnabled(s.lockEnabled);
    await setCurrency(s.currencyCode);
    await setHideAmounts(s.hideAmounts);
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
  final currency = ref.watch(settingsProvider.select((s) => s.currency));
  return ref.watch(databaseProvider).searchEntries(query, currency: currency);
});

/// True when the backup banner should show: never backed up, or more than
/// 30 days ago. "Later" hides it until the app is next opened.
class BackupReminderNotifier extends Notifier<bool> {
  @override
  bool build() {
    final last = ref.watch(settingsProvider.select((s) => s.lastBackupAt));
    return last == null || DateTime.now().difference(last) > const Duration(days: 30);
  }

  void snooze() => state = false;
}

final backupReminderProvider = NotifierProvider<BackupReminderNotifier, bool>(
  BackupReminderNotifier.new,
);

final reflectionsProvider = StreamProvider.family<List<Reflection>, ReflectionType>(
  (ref, type) => ref.watch(databaseProvider).watchReflections(type),
);

final recurringItemsProvider = StreamProvider<List<RecurringItem>>(
  (ref) => ref.watch(databaseProvider).watchRecurringItems(),
);

/// Amounts are temporarily revealed while the privacy mask is on. Resets when
/// the app goes to the background.
class AmountsRevealedNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;

  void reset() => state = false;
}

final amountsRevealedProvider = NotifierProvider<AmountsRevealedNotifier, bool>(
  AmountsRevealedNotifier.new,
);

/// The data that was on the phone before the last restore, kept until the
/// app closes so the restore can be undone.
class UndoRestoreNotifier extends Notifier<BackupData?> {
  @override
  BackupData? build() => null;

  void set(BackupData? data) => state = data;
}

final undoRestoreProvider = NotifierProvider<UndoRestoreNotifier, BackupData?>(
  UndoRestoreNotifier.new,
);
