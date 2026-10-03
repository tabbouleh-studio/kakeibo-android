import 'dart:convert';

import 'package:drift/drift.dart';

import '../models/enums.dart';
import '../util/money.dart';
import 'database.dart';

const backupAppId = 'kakeibo';

/// Version of the backup file format. Matches the database schema version.
const backupSchemaVersion = 1;

class BackupFormatException implements Exception {
  const BackupFormatException(this.message);

  final String message;

  @override
  String toString() => message;
}

class BackupSettings {
  const BackupSettings({
    required this.monthStartDay,
    required this.weekStartDay,
    required this.lockEnabled,
  });

  final int monthStartDay;
  final int weekStartDay;
  final bool lockEnabled;
}

/// Everything the app stores, as written to / read from a backup file.
class BackupData {
  const BackupData({
    required this.schemaVersion,
    required this.exportedAt,
    required this.settings,
    required this.entries,
    required this.monthPlans,
    required this.fixedCosts,
    required this.recurringItems,
    required this.reflections,
  });

  final int schemaVersion;
  final DateTime exportedAt;
  final BackupSettings settings;
  final List<Entry> entries;
  final List<MonthPlan> monthPlans;
  final List<FixedCost> fixedCosts;
  final List<RecurringItem> recurringItems;
  final List<Reflection> reflections;

  Map<String, Object?> toJson() => {
    'app': backupAppId,
    'schemaVersion': schemaVersion,
    'exportedAt': exportedAt.toIso8601String(),
    'settings': {
      'monthStartDay': settings.monthStartDay,
      'weekStartDay': settings.weekStartDay,
      'lockEnabled': settings.lockEnabled,
    },
    'entries': [
      for (final e in entries)
        {
          'id': e.id,
          'amountFils': e.amountFils,
          'category': e.category.name,
          'note': e.note,
          'date': _formatDay(e.date),
          'createdAt': e.createdAt.toIso8601String(),
          'recurringId': e.recurringId,
        },
    ],
    'monthPlans': [
      for (final p in monthPlans)
        {
          'periodStart': _formatDay(p.periodStart),
          'incomeFils': p.incomeFils,
          'savingsGoalFils': p.savingsGoalFils,
        },
    ],
    'fixedCosts': [
      for (final c in fixedCosts)
        {
          'id': c.id,
          'periodStart': _formatDay(c.periodStart),
          'name': c.name,
          'amountFils': c.amountFils,
        },
    ],
    'recurringItems': [
      for (final r in recurringItems)
        {
          'id': r.id,
          'name': r.name,
          'amountFils': r.amountFils,
          'category': r.category.name,
          'frequency': r.frequency.name,
          'nextDueDate': _formatDay(r.nextDueDate),
          'active': r.active,
        },
    ],
    'reflections': [
      for (final r in reflections)
        {
          'id': r.id,
          'type': r.type.name,
          'periodStart': _formatDay(r.periodStart),
          'haveFils': r.haveFils,
          'saveFils': r.saveFils,
          'spentFils': r.spentFils,
          'haveNote': r.haveNote,
          'saveNote': r.saveNote,
          'spendNote': r.spendNote,
          'improveNote': r.improveNote,
          'createdAt': r.createdAt.toIso8601String(),
        },
    ],
  };

  String encode() => const JsonEncoder.withIndent('  ').convert(toJson());

  /// Parses and fully validates a backup file. Throws [BackupFormatException]
  /// with a readable reason if anything is wrong.
  static BackupData decode(String text) {
    final Object? json;
    try {
      json = jsonDecode(text);
    } on FormatException {
      throw const BackupFormatException('The file is not valid JSON.');
    }
    final root = _Obj(json, 'backup');
    if (root.map['app'] != backupAppId) {
      throw const BackupFormatException('This is not a Kakeibo backup file.');
    }
    final version = root.integer('schemaVersion', min: 1);
    if (version > backupSchemaVersion) {
      throw const BackupFormatException(
        'This backup was made by a newer version of the app. Update the app first.',
      );
    }

    final s = root.object('settings');
    final settings = BackupSettings(
      monthStartDay: s.integer('monthStartDay', min: 1, max: 31),
      weekStartDay: s.integer('weekStartDay', min: 1, max: 7),
      lockEnabled: s.boolean('lockEnabled'),
    );
    if (!const {
      DateTime.sunday,
      DateTime.saturday,
      DateTime.monday,
    }.contains(settings.weekStartDay)) {
      throw const BackupFormatException(
        'settings.weekStartDay must be Sunday, Saturday or Monday.',
      );
    }

    final monthPlans = [
      for (final p in root.list('monthPlans'))
        MonthPlan(
          periodStart: p.day('periodStart'),
          incomeFils: p.amount('incomeFils'),
          savingsGoalFils: p.amount('savingsGoalFils'),
        ),
    ];
    final fixedCosts = [
      for (final c in root.list('fixedCosts'))
        FixedCost(
          id: c.integer('id', min: 1),
          periodStart: c.day('periodStart'),
          name: c.text('name'),
          amountFils: c.amount('amountFils'),
        ),
    ];
    final recurringItems = [
      for (final r in root.list('recurringItems'))
        RecurringItem(
          id: r.integer('id', min: 1),
          name: r.text('name'),
          amountFils: r.amount('amountFils', min: 1),
          category: r.enumValue('category', SpendCategory.values),
          frequency: r.enumValue('frequency', Frequency.values),
          nextDueDate: r.day('nextDueDate'),
          active: r.boolean('active'),
        ),
    ];
    final entries = [
      for (final e in root.list('entries'))
        Entry(
          id: e.integer('id', min: 1),
          amountFils: e.amount('amountFils', min: 1),
          category: e.enumValue('category', SpendCategory.values),
          note: e.text('note'),
          date: e.day('date'),
          createdAt: e.instant('createdAt'),
          recurringId: e.optionalInteger('recurringId'),
        ),
    ];
    final reflections = [
      for (final r in root.list('reflections'))
        Reflection(
          id: r.integer('id', min: 1),
          type: r.enumValue('type', ReflectionType.values),
          periodStart: r.day('periodStart'),
          haveFils: r.integer('haveFils', min: -maxInputFils, max: maxInputFils),
          saveFils: r.integer('saveFils', min: -maxInputFils, max: maxInputFils),
          spentFils: r.integer('spentFils', min: -maxInputFils, max: maxInputFils),
          haveNote: r.text('haveNote'),
          saveNote: r.text('saveNote'),
          spendNote: r.text('spendNote'),
          improveNote: r.text('improveNote'),
          createdAt: r.instant('createdAt'),
        ),
    ];

    // Cross-checks the database would otherwise reject halfway through a restore.
    _unique([for (final p in monthPlans) p.periodStart], 'month plan period');
    _unique([for (final c in fixedCosts) c.id], 'fixed cost id');
    _unique([for (final r in recurringItems) r.id], 'recurring item id');
    _unique([for (final e in entries) e.id], 'entry id');
    _unique([for (final r in reflections) r.id], 'reflection id');
    _unique([for (final r in reflections) (r.type, r.periodStart)], 'reflection period');
    final planStarts = {for (final p in monthPlans) p.periodStart};
    for (final c in fixedCosts) {
      if (!planStarts.contains(c.periodStart)) {
        throw BackupFormatException('Fixed cost ${c.id} belongs to a month plan that is missing.');
      }
    }
    final recurringIds = {for (final r in recurringItems) r.id};
    for (final e in entries) {
      if (e.recurringId case final id? when !recurringIds.contains(id)) {
        throw BackupFormatException('Entry ${e.id} refers to a recurring item that is missing.');
      }
    }

    return BackupData(
      schemaVersion: version,
      exportedAt: root.instant('exportedAt'),
      settings: settings,
      entries: entries,
      monthPlans: monthPlans,
      fixedCosts: fixedCosts,
      recurringItems: recurringItems,
      reflections: reflections,
    );
  }
}

/// Reads everything from [db] in one consistent snapshot.
Future<BackupData> createBackup(AppDatabase db, BackupSettings settings) => db.transaction(
  () async => BackupData(
    schemaVersion: backupSchemaVersion,
    exportedAt: DateTime.now(),
    settings: settings,
    entries: await (db.select(db.entries)..orderBy([(e) => OrderingTerm.asc(e.id)])).get(),
    monthPlans: await (db.select(
      db.monthPlans,
    )..orderBy([(p) => OrderingTerm.asc(p.periodStart)])).get(),
    fixedCosts: await (db.select(db.fixedCosts)..orderBy([(c) => OrderingTerm.asc(c.id)])).get(),
    recurringItems: await (db.select(
      db.recurringItems,
    )..orderBy([(r) => OrderingTerm.asc(r.id)])).get(),
    reflections: await (db.select(db.reflections)..orderBy([(r) => OrderingTerm.asc(r.id)])).get(),
  ),
);

/// Replaces all data in [db] with [data], in one transaction.
/// Settings are applied separately by the caller.
Future<void> restoreBackup(AppDatabase db, BackupData data) => db.transaction(() async {
  await db.delete(db.entries).go();
  await db.delete(db.fixedCosts).go();
  await db.delete(db.reflections).go();
  await db.delete(db.recurringItems).go();
  await db.delete(db.monthPlans).go();
  await db.batch((b) {
    b.insertAll(db.monthPlans, data.monthPlans);
    b.insertAll(db.fixedCosts, data.fixedCosts);
    b.insertAll(db.recurringItems, data.recurringItems);
    b.insertAll(db.entries, data.entries);
    b.insertAll(db.reflections, data.reflections);
  });
});

String _formatDay(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

void _unique<T>(List<T> values, String what) {
  final seen = <T>{};
  for (final v in values) {
    if (!seen.add(v)) throw BackupFormatException('Duplicate $what in backup.');
  }
}

final _dayPattern = RegExp(r'^\d{4}-\d{2}-\d{2}$');

/// A JSON object being validated, with its path for error messages.
class _Obj {
  _Obj(Object? value, this.path)
    : map = value is Map<String, Object?>
          ? value
          : throw BackupFormatException('$path should be an object.');

  final String path;
  final Map<String, Object?> map;

  Never _fail(String key, String expected) =>
      throw BackupFormatException('$path.$key should be $expected.');

  int integer(String key, {int min = 0, int? max}) {
    final v = map[key];
    if (v is! int || v < min || (max != null && v > max)) {
      _fail(
        key,
        max == null ? 'a whole number of at least $min' : 'a whole number from $min to $max',
      );
    }
    return v;
  }

  int? optionalInteger(String key) => map[key] == null ? null : integer(key, min: 1);

  int amount(String key, {int min = 0}) => integer(key, min: min, max: maxInputFils);

  String text(String key) {
    final v = map[key];
    if (v is! String) _fail(key, 'text');
    return v;
  }

  bool boolean(String key) {
    final v = map[key];
    if (v is! bool) _fail(key, 'true or false');
    return v;
  }

  DateTime day(String key) {
    final v = map[key];
    if (v is String && _dayPattern.hasMatch(v)) {
      final d = DateTime.parse(v);
      if (_formatDay(d) == v) return d; // rejects e.g. 2026-02-30
    }
    _fail(key, 'a date like 2026-10-03');
  }

  DateTime instant(String key) {
    final v = map[key];
    final d = v is String ? DateTime.tryParse(v) : null;
    if (d == null) _fail(key, 'a date and time');
    return d.toLocal();
  }

  T enumValue<T extends Enum>(String key, List<T> values) {
    final v = map[key];
    for (final e in values) {
      if (e.name == v) return e;
    }
    _fail(key, 'one of ${values.map((e) => e.name).join(', ')}');
  }

  _Obj object(String key) => _Obj(map[key], '$path.$key');

  List<_Obj> list(String key) {
    final v = map[key];
    if (v is! List) _fail(key, 'a list');
    return [for (final (i, item) in v.indexed) _Obj(item, '$path.$key[$i]')];
  }
}
