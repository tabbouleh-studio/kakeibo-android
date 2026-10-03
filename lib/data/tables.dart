import 'package:drift/drift.dart';

import '../models/enums.dart';

@TableIndex(name: 'entries_date', columns: {#date})
class Entries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get amountFils => integer()();
  TextColumn get category => textEnum<SpendCategory>()();
  TextColumn get note => text().withDefault(const Constant(''))();

  /// Local midnight of the day the money was spent.
  DateTimeColumn get date => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get recurringId =>
      integer().nullable().references(RecurringItems, #id, onDelete: KeyAction.setNull)();
}

class MonthPlans extends Table {
  DateTimeColumn get periodStart => dateTime()();
  IntColumn get incomeFils => integer()();
  IntColumn get savingsGoalFils => integer()();

  @override
  Set<Column> get primaryKey => {periodStart};
}

/// Stored per month plan, so editing rent doesn't rewrite past months.
class FixedCosts extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get periodStart =>
      dateTime().references(MonthPlans, #periodStart, onDelete: KeyAction.cascade)();
  TextColumn get name => text()();
  IntColumn get amountFils => integer()();
}

class RecurringItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get amountFils => integer()();
  TextColumn get category => textEnum<SpendCategory>()();
  TextColumn get frequency => textEnum<Frequency>()();
  DateTimeColumn get nextDueDate => dateTime()();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
}

/// Snapshots the numbers when saved, so history doesn't change later.
class Reflections extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get type => textEnum<ReflectionType>()();
  DateTimeColumn get periodStart => dateTime()();
  IntColumn get haveFils => integer()();
  IntColumn get saveFils => integer()();
  IntColumn get spentFils => integer()();
  TextColumn get haveNote => text().withDefault(const Constant(''))();
  TextColumn get saveNote => text().withDefault(const Constant(''))();
  TextColumn get spendNote => text().withDefault(const Constant(''))();
  TextColumn get improveNote => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {type, periodStart},
  ];
}
