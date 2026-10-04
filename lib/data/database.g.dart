// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $RecurringItemsTable extends RecurringItems
    with TableInfo<$RecurringItemsTable, RecurringItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecurringItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountFilsMeta = const VerificationMeta('amountFils');
  @override
  late final GeneratedColumn<int> amountFils = GeneratedColumn<int>(
    'amount_fils',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SpendCategory, String> category =
      GeneratedColumn<String>(
        'category',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<SpendCategory>($RecurringItemsTable.$convertercategory);
  @override
  late final GeneratedColumnWithTypeConverter<Frequency, String> frequency =
      GeneratedColumn<String>(
        'frequency',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Frequency>($RecurringItemsTable.$converterfrequency);
  static const VerificationMeta _nextDueDateMeta = const VerificationMeta('nextDueDate');
  @override
  late final GeneratedColumn<DateTime> nextDueDate = GeneratedColumn<DateTime>(
    'next_due_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("active" IN (0, 1))'),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    amountFils,
    category,
    frequency,
    nextDueDate,
    active,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recurring_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecurringItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('amount_fils')) {
      context.handle(
        _amountFilsMeta,
        amountFils.isAcceptableOrUnknown(data['amount_fils']!, _amountFilsMeta),
      );
    } else if (isInserting) {
      context.missing(_amountFilsMeta);
    }
    if (data.containsKey('next_due_date')) {
      context.handle(
        _nextDueDateMeta,
        nextDueDate.isAcceptableOrUnknown(data['next_due_date']!, _nextDueDateMeta),
      );
    } else if (isInserting) {
      context.missing(_nextDueDateMeta);
    }
    if (data.containsKey('active')) {
      context.handle(_activeMeta, active.isAcceptableOrUnknown(data['active']!, _activeMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecurringItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecurringItem(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      amountFils: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_fils'],
      )!,
      category: $RecurringItemsTable.$convertercategory.fromSql(
        attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      ),
      frequency: $RecurringItemsTable.$converterfrequency.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}frequency'],
        )!,
      ),
      nextDueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_due_date'],
      )!,
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
    );
  }

  @override
  $RecurringItemsTable createAlias(String alias) {
    return $RecurringItemsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SpendCategory, String, String> $convertercategory =
      const EnumNameConverter<SpendCategory>(SpendCategory.values);
  static JsonTypeConverter2<Frequency, String, String> $converterfrequency =
      const EnumNameConverter<Frequency>(Frequency.values);
}

class RecurringItem extends DataClass implements Insertable<RecurringItem> {
  final int id;
  final String name;
  final int amountFils;
  final SpendCategory category;
  final Frequency frequency;
  final DateTime nextDueDate;
  final bool active;
  const RecurringItem({
    required this.id,
    required this.name,
    required this.amountFils,
    required this.category,
    required this.frequency,
    required this.nextDueDate,
    required this.active,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['amount_fils'] = Variable<int>(amountFils);
    {
      map['category'] = Variable<String>($RecurringItemsTable.$convertercategory.toSql(category));
    }
    {
      map['frequency'] = Variable<String>(
        $RecurringItemsTable.$converterfrequency.toSql(frequency),
      );
    }
    map['next_due_date'] = Variable<DateTime>(nextDueDate);
    map['active'] = Variable<bool>(active);
    return map;
  }

  RecurringItemsCompanion toCompanion(bool nullToAbsent) {
    return RecurringItemsCompanion(
      id: Value(id),
      name: Value(name),
      amountFils: Value(amountFils),
      category: Value(category),
      frequency: Value(frequency),
      nextDueDate: Value(nextDueDate),
      active: Value(active),
    );
  }

  factory RecurringItem.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecurringItem(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      amountFils: serializer.fromJson<int>(json['amountFils']),
      category: $RecurringItemsTable.$convertercategory.fromJson(
        serializer.fromJson<String>(json['category']),
      ),
      frequency: $RecurringItemsTable.$converterfrequency.fromJson(
        serializer.fromJson<String>(json['frequency']),
      ),
      nextDueDate: serializer.fromJson<DateTime>(json['nextDueDate']),
      active: serializer.fromJson<bool>(json['active']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'amountFils': serializer.toJson<int>(amountFils),
      'category': serializer.toJson<String>(
        $RecurringItemsTable.$convertercategory.toJson(category),
      ),
      'frequency': serializer.toJson<String>(
        $RecurringItemsTable.$converterfrequency.toJson(frequency),
      ),
      'nextDueDate': serializer.toJson<DateTime>(nextDueDate),
      'active': serializer.toJson<bool>(active),
    };
  }

  RecurringItem copyWith({
    int? id,
    String? name,
    int? amountFils,
    SpendCategory? category,
    Frequency? frequency,
    DateTime? nextDueDate,
    bool? active,
  }) => RecurringItem(
    id: id ?? this.id,
    name: name ?? this.name,
    amountFils: amountFils ?? this.amountFils,
    category: category ?? this.category,
    frequency: frequency ?? this.frequency,
    nextDueDate: nextDueDate ?? this.nextDueDate,
    active: active ?? this.active,
  );
  RecurringItem copyWithCompanion(RecurringItemsCompanion data) {
    return RecurringItem(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      amountFils: data.amountFils.present ? data.amountFils.value : this.amountFils,
      category: data.category.present ? data.category.value : this.category,
      frequency: data.frequency.present ? data.frequency.value : this.frequency,
      nextDueDate: data.nextDueDate.present ? data.nextDueDate.value : this.nextDueDate,
      active: data.active.present ? data.active.value : this.active,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecurringItem(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('amountFils: $amountFils, ')
          ..write('category: $category, ')
          ..write('frequency: $frequency, ')
          ..write('nextDueDate: $nextDueDate, ')
          ..write('active: $active')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, amountFils, category, frequency, nextDueDate, active);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecurringItem &&
          other.id == this.id &&
          other.name == this.name &&
          other.amountFils == this.amountFils &&
          other.category == this.category &&
          other.frequency == this.frequency &&
          other.nextDueDate == this.nextDueDate &&
          other.active == this.active);
}

class RecurringItemsCompanion extends UpdateCompanion<RecurringItem> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> amountFils;
  final Value<SpendCategory> category;
  final Value<Frequency> frequency;
  final Value<DateTime> nextDueDate;
  final Value<bool> active;
  const RecurringItemsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.amountFils = const Value.absent(),
    this.category = const Value.absent(),
    this.frequency = const Value.absent(),
    this.nextDueDate = const Value.absent(),
    this.active = const Value.absent(),
  });
  RecurringItemsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int amountFils,
    required SpendCategory category,
    required Frequency frequency,
    required DateTime nextDueDate,
    this.active = const Value.absent(),
  }) : name = Value(name),
       amountFils = Value(amountFils),
       category = Value(category),
       frequency = Value(frequency),
       nextDueDate = Value(nextDueDate);
  static Insertable<RecurringItem> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? amountFils,
    Expression<String>? category,
    Expression<String>? frequency,
    Expression<DateTime>? nextDueDate,
    Expression<bool>? active,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (amountFils != null) 'amount_fils': amountFils,
      if (category != null) 'category': category,
      if (frequency != null) 'frequency': frequency,
      if (nextDueDate != null) 'next_due_date': nextDueDate,
      if (active != null) 'active': active,
    });
  }

  RecurringItemsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? amountFils,
    Value<SpendCategory>? category,
    Value<Frequency>? frequency,
    Value<DateTime>? nextDueDate,
    Value<bool>? active,
  }) {
    return RecurringItemsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      amountFils: amountFils ?? this.amountFils,
      category: category ?? this.category,
      frequency: frequency ?? this.frequency,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      active: active ?? this.active,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (amountFils.present) {
      map['amount_fils'] = Variable<int>(amountFils.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(
        $RecurringItemsTable.$convertercategory.toSql(category.value),
      );
    }
    if (frequency.present) {
      map['frequency'] = Variable<String>(
        $RecurringItemsTable.$converterfrequency.toSql(frequency.value),
      );
    }
    if (nextDueDate.present) {
      map['next_due_date'] = Variable<DateTime>(nextDueDate.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecurringItemsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('amountFils: $amountFils, ')
          ..write('category: $category, ')
          ..write('frequency: $frequency, ')
          ..write('nextDueDate: $nextDueDate, ')
          ..write('active: $active')
          ..write(')'))
        .toString();
  }
}

class $EntriesTable extends Entries with TableInfo<$EntriesTable, Entry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _amountFilsMeta = const VerificationMeta('amountFils');
  @override
  late final GeneratedColumn<int> amountFils = GeneratedColumn<int>(
    'amount_fils',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SpendCategory, String> category =
      GeneratedColumn<String>(
        'category',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<SpendCategory>($EntriesTable.$convertercategory);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recurringIdMeta = const VerificationMeta('recurringId');
  @override
  late final GeneratedColumn<int> recurringId = GeneratedColumn<int>(
    'recurring_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES recurring_items (id) ON DELETE SET NULL',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    amountFils,
    category,
    note,
    date,
    createdAt,
    recurringId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'entries';
  @override
  VerificationContext validateIntegrity(Insertable<Entry> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('amount_fils')) {
      context.handle(
        _amountFilsMeta,
        amountFils.isAcceptableOrUnknown(data['amount_fils']!, _amountFilsMeta),
      );
    } else if (isInserting) {
      context.missing(_amountFilsMeta);
    }
    if (data.containsKey('note')) {
      context.handle(_noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('date')) {
      context.handle(_dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('recurring_id')) {
      context.handle(
        _recurringIdMeta,
        recurringId.isAcceptableOrUnknown(data['recurring_id']!, _recurringIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Entry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Entry(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      amountFils: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_fils'],
      )!,
      category: $EntriesTable.$convertercategory.fromSql(
        attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      ),
      note: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}note'])!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      recurringId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recurring_id'],
      ),
    );
  }

  @override
  $EntriesTable createAlias(String alias) {
    return $EntriesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SpendCategory, String, String> $convertercategory =
      const EnumNameConverter<SpendCategory>(SpendCategory.values);
}

class Entry extends DataClass implements Insertable<Entry> {
  final int id;
  final int amountFils;
  final SpendCategory category;
  final String note;

  /// Local midnight of the day the money was spent.
  final DateTime date;
  final DateTime createdAt;
  final int? recurringId;
  const Entry({
    required this.id,
    required this.amountFils,
    required this.category,
    required this.note,
    required this.date,
    required this.createdAt,
    this.recurringId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['amount_fils'] = Variable<int>(amountFils);
    {
      map['category'] = Variable<String>($EntriesTable.$convertercategory.toSql(category));
    }
    map['note'] = Variable<String>(note);
    map['date'] = Variable<DateTime>(date);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || recurringId != null) {
      map['recurring_id'] = Variable<int>(recurringId);
    }
    return map;
  }

  EntriesCompanion toCompanion(bool nullToAbsent) {
    return EntriesCompanion(
      id: Value(id),
      amountFils: Value(amountFils),
      category: Value(category),
      note: Value(note),
      date: Value(date),
      createdAt: Value(createdAt),
      recurringId: recurringId == null && nullToAbsent ? const Value.absent() : Value(recurringId),
    );
  }

  factory Entry.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Entry(
      id: serializer.fromJson<int>(json['id']),
      amountFils: serializer.fromJson<int>(json['amountFils']),
      category: $EntriesTable.$convertercategory.fromJson(
        serializer.fromJson<String>(json['category']),
      ),
      note: serializer.fromJson<String>(json['note']),
      date: serializer.fromJson<DateTime>(json['date']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      recurringId: serializer.fromJson<int?>(json['recurringId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'amountFils': serializer.toJson<int>(amountFils),
      'category': serializer.toJson<String>($EntriesTable.$convertercategory.toJson(category)),
      'note': serializer.toJson<String>(note),
      'date': serializer.toJson<DateTime>(date),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'recurringId': serializer.toJson<int?>(recurringId),
    };
  }

  Entry copyWith({
    int? id,
    int? amountFils,
    SpendCategory? category,
    String? note,
    DateTime? date,
    DateTime? createdAt,
    Value<int?> recurringId = const Value.absent(),
  }) => Entry(
    id: id ?? this.id,
    amountFils: amountFils ?? this.amountFils,
    category: category ?? this.category,
    note: note ?? this.note,
    date: date ?? this.date,
    createdAt: createdAt ?? this.createdAt,
    recurringId: recurringId.present ? recurringId.value : this.recurringId,
  );
  Entry copyWithCompanion(EntriesCompanion data) {
    return Entry(
      id: data.id.present ? data.id.value : this.id,
      amountFils: data.amountFils.present ? data.amountFils.value : this.amountFils,
      category: data.category.present ? data.category.value : this.category,
      note: data.note.present ? data.note.value : this.note,
      date: data.date.present ? data.date.value : this.date,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      recurringId: data.recurringId.present ? data.recurringId.value : this.recurringId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Entry(')
          ..write('id: $id, ')
          ..write('amountFils: $amountFils, ')
          ..write('category: $category, ')
          ..write('note: $note, ')
          ..write('date: $date, ')
          ..write('createdAt: $createdAt, ')
          ..write('recurringId: $recurringId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, amountFils, category, note, date, createdAt, recurringId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Entry &&
          other.id == this.id &&
          other.amountFils == this.amountFils &&
          other.category == this.category &&
          other.note == this.note &&
          other.date == this.date &&
          other.createdAt == this.createdAt &&
          other.recurringId == this.recurringId);
}

class EntriesCompanion extends UpdateCompanion<Entry> {
  final Value<int> id;
  final Value<int> amountFils;
  final Value<SpendCategory> category;
  final Value<String> note;
  final Value<DateTime> date;
  final Value<DateTime> createdAt;
  final Value<int?> recurringId;
  const EntriesCompanion({
    this.id = const Value.absent(),
    this.amountFils = const Value.absent(),
    this.category = const Value.absent(),
    this.note = const Value.absent(),
    this.date = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.recurringId = const Value.absent(),
  });
  EntriesCompanion.insert({
    this.id = const Value.absent(),
    required int amountFils,
    required SpendCategory category,
    this.note = const Value.absent(),
    required DateTime date,
    required DateTime createdAt,
    this.recurringId = const Value.absent(),
  }) : amountFils = Value(amountFils),
       category = Value(category),
       date = Value(date),
       createdAt = Value(createdAt);
  static Insertable<Entry> custom({
    Expression<int>? id,
    Expression<int>? amountFils,
    Expression<String>? category,
    Expression<String>? note,
    Expression<DateTime>? date,
    Expression<DateTime>? createdAt,
    Expression<int>? recurringId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (amountFils != null) 'amount_fils': amountFils,
      if (category != null) 'category': category,
      if (note != null) 'note': note,
      if (date != null) 'date': date,
      if (createdAt != null) 'created_at': createdAt,
      if (recurringId != null) 'recurring_id': recurringId,
    });
  }

  EntriesCompanion copyWith({
    Value<int>? id,
    Value<int>? amountFils,
    Value<SpendCategory>? category,
    Value<String>? note,
    Value<DateTime>? date,
    Value<DateTime>? createdAt,
    Value<int?>? recurringId,
  }) {
    return EntriesCompanion(
      id: id ?? this.id,
      amountFils: amountFils ?? this.amountFils,
      category: category ?? this.category,
      note: note ?? this.note,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      recurringId: recurringId ?? this.recurringId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (amountFils.present) {
      map['amount_fils'] = Variable<int>(amountFils.value);
    }
    if (category.present) {
      map['category'] = Variable<String>($EntriesTable.$convertercategory.toSql(category.value));
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (recurringId.present) {
      map['recurring_id'] = Variable<int>(recurringId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EntriesCompanion(')
          ..write('id: $id, ')
          ..write('amountFils: $amountFils, ')
          ..write('category: $category, ')
          ..write('note: $note, ')
          ..write('date: $date, ')
          ..write('createdAt: $createdAt, ')
          ..write('recurringId: $recurringId')
          ..write(')'))
        .toString();
  }
}

class $MonthPlansTable extends MonthPlans with TableInfo<$MonthPlansTable, MonthPlan> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MonthPlansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _periodStartMeta = const VerificationMeta('periodStart');
  @override
  late final GeneratedColumn<DateTime> periodStart = GeneratedColumn<DateTime>(
    'period_start',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _incomeFilsMeta = const VerificationMeta('incomeFils');
  @override
  late final GeneratedColumn<int> incomeFils = GeneratedColumn<int>(
    'income_fils',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _savingsGoalFilsMeta = const VerificationMeta('savingsGoalFils');
  @override
  late final GeneratedColumn<int> savingsGoalFils = GeneratedColumn<int>(
    'savings_goal_fils',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [periodStart, incomeFils, savingsGoalFils];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'month_plans';
  @override
  VerificationContext validateIntegrity(
    Insertable<MonthPlan> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('period_start')) {
      context.handle(
        _periodStartMeta,
        periodStart.isAcceptableOrUnknown(data['period_start']!, _periodStartMeta),
      );
    } else if (isInserting) {
      context.missing(_periodStartMeta);
    }
    if (data.containsKey('income_fils')) {
      context.handle(
        _incomeFilsMeta,
        incomeFils.isAcceptableOrUnknown(data['income_fils']!, _incomeFilsMeta),
      );
    } else if (isInserting) {
      context.missing(_incomeFilsMeta);
    }
    if (data.containsKey('savings_goal_fils')) {
      context.handle(
        _savingsGoalFilsMeta,
        savingsGoalFils.isAcceptableOrUnknown(data['savings_goal_fils']!, _savingsGoalFilsMeta),
      );
    } else if (isInserting) {
      context.missing(_savingsGoalFilsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {periodStart};
  @override
  MonthPlan map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MonthPlan(
      periodStart: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}period_start'],
      )!,
      incomeFils: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}income_fils'],
      )!,
      savingsGoalFils: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}savings_goal_fils'],
      )!,
    );
  }

  @override
  $MonthPlansTable createAlias(String alias) {
    return $MonthPlansTable(attachedDatabase, alias);
  }
}

class MonthPlan extends DataClass implements Insertable<MonthPlan> {
  final DateTime periodStart;
  final int incomeFils;
  final int savingsGoalFils;
  const MonthPlan({
    required this.periodStart,
    required this.incomeFils,
    required this.savingsGoalFils,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['period_start'] = Variable<DateTime>(periodStart);
    map['income_fils'] = Variable<int>(incomeFils);
    map['savings_goal_fils'] = Variable<int>(savingsGoalFils);
    return map;
  }

  MonthPlansCompanion toCompanion(bool nullToAbsent) {
    return MonthPlansCompanion(
      periodStart: Value(periodStart),
      incomeFils: Value(incomeFils),
      savingsGoalFils: Value(savingsGoalFils),
    );
  }

  factory MonthPlan.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MonthPlan(
      periodStart: serializer.fromJson<DateTime>(json['periodStart']),
      incomeFils: serializer.fromJson<int>(json['incomeFils']),
      savingsGoalFils: serializer.fromJson<int>(json['savingsGoalFils']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'periodStart': serializer.toJson<DateTime>(periodStart),
      'incomeFils': serializer.toJson<int>(incomeFils),
      'savingsGoalFils': serializer.toJson<int>(savingsGoalFils),
    };
  }

  MonthPlan copyWith({DateTime? periodStart, int? incomeFils, int? savingsGoalFils}) => MonthPlan(
    periodStart: periodStart ?? this.periodStart,
    incomeFils: incomeFils ?? this.incomeFils,
    savingsGoalFils: savingsGoalFils ?? this.savingsGoalFils,
  );
  MonthPlan copyWithCompanion(MonthPlansCompanion data) {
    return MonthPlan(
      periodStart: data.periodStart.present ? data.periodStart.value : this.periodStart,
      incomeFils: data.incomeFils.present ? data.incomeFils.value : this.incomeFils,
      savingsGoalFils: data.savingsGoalFils.present
          ? data.savingsGoalFils.value
          : this.savingsGoalFils,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MonthPlan(')
          ..write('periodStart: $periodStart, ')
          ..write('incomeFils: $incomeFils, ')
          ..write('savingsGoalFils: $savingsGoalFils')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(periodStart, incomeFils, savingsGoalFils);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MonthPlan &&
          other.periodStart == this.periodStart &&
          other.incomeFils == this.incomeFils &&
          other.savingsGoalFils == this.savingsGoalFils);
}

class MonthPlansCompanion extends UpdateCompanion<MonthPlan> {
  final Value<DateTime> periodStart;
  final Value<int> incomeFils;
  final Value<int> savingsGoalFils;
  final Value<int> rowid;
  const MonthPlansCompanion({
    this.periodStart = const Value.absent(),
    this.incomeFils = const Value.absent(),
    this.savingsGoalFils = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MonthPlansCompanion.insert({
    required DateTime periodStart,
    required int incomeFils,
    required int savingsGoalFils,
    this.rowid = const Value.absent(),
  }) : periodStart = Value(periodStart),
       incomeFils = Value(incomeFils),
       savingsGoalFils = Value(savingsGoalFils);
  static Insertable<MonthPlan> custom({
    Expression<DateTime>? periodStart,
    Expression<int>? incomeFils,
    Expression<int>? savingsGoalFils,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (periodStart != null) 'period_start': periodStart,
      if (incomeFils != null) 'income_fils': incomeFils,
      if (savingsGoalFils != null) 'savings_goal_fils': savingsGoalFils,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MonthPlansCompanion copyWith({
    Value<DateTime>? periodStart,
    Value<int>? incomeFils,
    Value<int>? savingsGoalFils,
    Value<int>? rowid,
  }) {
    return MonthPlansCompanion(
      periodStart: periodStart ?? this.periodStart,
      incomeFils: incomeFils ?? this.incomeFils,
      savingsGoalFils: savingsGoalFils ?? this.savingsGoalFils,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (periodStart.present) {
      map['period_start'] = Variable<DateTime>(periodStart.value);
    }
    if (incomeFils.present) {
      map['income_fils'] = Variable<int>(incomeFils.value);
    }
    if (savingsGoalFils.present) {
      map['savings_goal_fils'] = Variable<int>(savingsGoalFils.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MonthPlansCompanion(')
          ..write('periodStart: $periodStart, ')
          ..write('incomeFils: $incomeFils, ')
          ..write('savingsGoalFils: $savingsGoalFils, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FixedCostsTable extends FixedCosts with TableInfo<$FixedCostsTable, FixedCost> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FixedCostsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _periodStartMeta = const VerificationMeta('periodStart');
  @override
  late final GeneratedColumn<DateTime> periodStart = GeneratedColumn<DateTime>(
    'period_start',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES month_plans (period_start) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountFilsMeta = const VerificationMeta('amountFils');
  @override
  late final GeneratedColumn<int> amountFils = GeneratedColumn<int>(
    'amount_fils',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, periodStart, name, amountFils];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fixed_costs';
  @override
  VerificationContext validateIntegrity(
    Insertable<FixedCost> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('period_start')) {
      context.handle(
        _periodStartMeta,
        periodStart.isAcceptableOrUnknown(data['period_start']!, _periodStartMeta),
      );
    } else if (isInserting) {
      context.missing(_periodStartMeta);
    }
    if (data.containsKey('name')) {
      context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('amount_fils')) {
      context.handle(
        _amountFilsMeta,
        amountFils.isAcceptableOrUnknown(data['amount_fils']!, _amountFilsMeta),
      );
    } else if (isInserting) {
      context.missing(_amountFilsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FixedCost map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FixedCost(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      periodStart: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}period_start'],
      )!,
      name: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      amountFils: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_fils'],
      )!,
    );
  }

  @override
  $FixedCostsTable createAlias(String alias) {
    return $FixedCostsTable(attachedDatabase, alias);
  }
}

class FixedCost extends DataClass implements Insertable<FixedCost> {
  final int id;
  final DateTime periodStart;
  final String name;
  final int amountFils;
  const FixedCost({
    required this.id,
    required this.periodStart,
    required this.name,
    required this.amountFils,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['period_start'] = Variable<DateTime>(periodStart);
    map['name'] = Variable<String>(name);
    map['amount_fils'] = Variable<int>(amountFils);
    return map;
  }

  FixedCostsCompanion toCompanion(bool nullToAbsent) {
    return FixedCostsCompanion(
      id: Value(id),
      periodStart: Value(periodStart),
      name: Value(name),
      amountFils: Value(amountFils),
    );
  }

  factory FixedCost.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FixedCost(
      id: serializer.fromJson<int>(json['id']),
      periodStart: serializer.fromJson<DateTime>(json['periodStart']),
      name: serializer.fromJson<String>(json['name']),
      amountFils: serializer.fromJson<int>(json['amountFils']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'periodStart': serializer.toJson<DateTime>(periodStart),
      'name': serializer.toJson<String>(name),
      'amountFils': serializer.toJson<int>(amountFils),
    };
  }

  FixedCost copyWith({int? id, DateTime? periodStart, String? name, int? amountFils}) => FixedCost(
    id: id ?? this.id,
    periodStart: periodStart ?? this.periodStart,
    name: name ?? this.name,
    amountFils: amountFils ?? this.amountFils,
  );
  FixedCost copyWithCompanion(FixedCostsCompanion data) {
    return FixedCost(
      id: data.id.present ? data.id.value : this.id,
      periodStart: data.periodStart.present ? data.periodStart.value : this.periodStart,
      name: data.name.present ? data.name.value : this.name,
      amountFils: data.amountFils.present ? data.amountFils.value : this.amountFils,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FixedCost(')
          ..write('id: $id, ')
          ..write('periodStart: $periodStart, ')
          ..write('name: $name, ')
          ..write('amountFils: $amountFils')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, periodStart, name, amountFils);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FixedCost &&
          other.id == this.id &&
          other.periodStart == this.periodStart &&
          other.name == this.name &&
          other.amountFils == this.amountFils);
}

class FixedCostsCompanion extends UpdateCompanion<FixedCost> {
  final Value<int> id;
  final Value<DateTime> periodStart;
  final Value<String> name;
  final Value<int> amountFils;
  const FixedCostsCompanion({
    this.id = const Value.absent(),
    this.periodStart = const Value.absent(),
    this.name = const Value.absent(),
    this.amountFils = const Value.absent(),
  });
  FixedCostsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime periodStart,
    required String name,
    required int amountFils,
  }) : periodStart = Value(periodStart),
       name = Value(name),
       amountFils = Value(amountFils);
  static Insertable<FixedCost> custom({
    Expression<int>? id,
    Expression<DateTime>? periodStart,
    Expression<String>? name,
    Expression<int>? amountFils,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (periodStart != null) 'period_start': periodStart,
      if (name != null) 'name': name,
      if (amountFils != null) 'amount_fils': amountFils,
    });
  }

  FixedCostsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? periodStart,
    Value<String>? name,
    Value<int>? amountFils,
  }) {
    return FixedCostsCompanion(
      id: id ?? this.id,
      periodStart: periodStart ?? this.periodStart,
      name: name ?? this.name,
      amountFils: amountFils ?? this.amountFils,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (periodStart.present) {
      map['period_start'] = Variable<DateTime>(periodStart.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (amountFils.present) {
      map['amount_fils'] = Variable<int>(amountFils.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FixedCostsCompanion(')
          ..write('id: $id, ')
          ..write('periodStart: $periodStart, ')
          ..write('name: $name, ')
          ..write('amountFils: $amountFils')
          ..write(')'))
        .toString();
  }
}

class $ReflectionsTable extends Reflections with TableInfo<$ReflectionsTable, Reflection> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReflectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  @override
  late final GeneratedColumnWithTypeConverter<ReflectionType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ReflectionType>($ReflectionsTable.$convertertype);
  static const VerificationMeta _periodStartMeta = const VerificationMeta('periodStart');
  @override
  late final GeneratedColumn<DateTime> periodStart = GeneratedColumn<DateTime>(
    'period_start',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _haveFilsMeta = const VerificationMeta('haveFils');
  @override
  late final GeneratedColumn<int> haveFils = GeneratedColumn<int>(
    'have_fils',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _saveFilsMeta = const VerificationMeta('saveFils');
  @override
  late final GeneratedColumn<int> saveFils = GeneratedColumn<int>(
    'save_fils',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _spentFilsMeta = const VerificationMeta('spentFils');
  @override
  late final GeneratedColumn<int> spentFils = GeneratedColumn<int>(
    'spent_fils',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _haveNoteMeta = const VerificationMeta('haveNote');
  @override
  late final GeneratedColumn<String> haveNote = GeneratedColumn<String>(
    'have_note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _saveNoteMeta = const VerificationMeta('saveNote');
  @override
  late final GeneratedColumn<String> saveNote = GeneratedColumn<String>(
    'save_note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _spendNoteMeta = const VerificationMeta('spendNote');
  @override
  late final GeneratedColumn<String> spendNote = GeneratedColumn<String>(
    'spend_note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _improveNoteMeta = const VerificationMeta('improveNote');
  @override
  late final GeneratedColumn<String> improveNote = GeneratedColumn<String>(
    'improve_note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    periodStart,
    haveFils,
    saveFils,
    spentFils,
    haveNote,
    saveNote,
    spendNote,
    improveNote,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reflections';
  @override
  VerificationContext validateIntegrity(
    Insertable<Reflection> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('period_start')) {
      context.handle(
        _periodStartMeta,
        periodStart.isAcceptableOrUnknown(data['period_start']!, _periodStartMeta),
      );
    } else if (isInserting) {
      context.missing(_periodStartMeta);
    }
    if (data.containsKey('have_fils')) {
      context.handle(
        _haveFilsMeta,
        haveFils.isAcceptableOrUnknown(data['have_fils']!, _haveFilsMeta),
      );
    } else if (isInserting) {
      context.missing(_haveFilsMeta);
    }
    if (data.containsKey('save_fils')) {
      context.handle(
        _saveFilsMeta,
        saveFils.isAcceptableOrUnknown(data['save_fils']!, _saveFilsMeta),
      );
    } else if (isInserting) {
      context.missing(_saveFilsMeta);
    }
    if (data.containsKey('spent_fils')) {
      context.handle(
        _spentFilsMeta,
        spentFils.isAcceptableOrUnknown(data['spent_fils']!, _spentFilsMeta),
      );
    } else if (isInserting) {
      context.missing(_spentFilsMeta);
    }
    if (data.containsKey('have_note')) {
      context.handle(
        _haveNoteMeta,
        haveNote.isAcceptableOrUnknown(data['have_note']!, _haveNoteMeta),
      );
    }
    if (data.containsKey('save_note')) {
      context.handle(
        _saveNoteMeta,
        saveNote.isAcceptableOrUnknown(data['save_note']!, _saveNoteMeta),
      );
    }
    if (data.containsKey('spend_note')) {
      context.handle(
        _spendNoteMeta,
        spendNote.isAcceptableOrUnknown(data['spend_note']!, _spendNoteMeta),
      );
    }
    if (data.containsKey('improve_note')) {
      context.handle(
        _improveNoteMeta,
        improveNote.isAcceptableOrUnknown(data['improve_note']!, _improveNoteMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {type, periodStart},
  ];
  @override
  Reflection map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Reflection(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      type: $ReflectionsTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      ),
      periodStart: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}period_start'],
      )!,
      haveFils: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}have_fils'],
      )!,
      saveFils: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}save_fils'],
      )!,
      spentFils: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}spent_fils'],
      )!,
      haveNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}have_note'],
      )!,
      saveNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}save_note'],
      )!,
      spendNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}spend_note'],
      )!,
      improveNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}improve_note'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ReflectionsTable createAlias(String alias) {
    return $ReflectionsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ReflectionType, String, String> $convertertype =
      const EnumNameConverter<ReflectionType>(ReflectionType.values);
}

class Reflection extends DataClass implements Insertable<Reflection> {
  final int id;
  final ReflectionType type;
  final DateTime periodStart;
  final int haveFils;
  final int saveFils;
  final int spentFils;
  final String haveNote;
  final String saveNote;
  final String spendNote;
  final String improveNote;
  final DateTime createdAt;
  const Reflection({
    required this.id,
    required this.type,
    required this.periodStart,
    required this.haveFils,
    required this.saveFils,
    required this.spentFils,
    required this.haveNote,
    required this.saveNote,
    required this.spendNote,
    required this.improveNote,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['type'] = Variable<String>($ReflectionsTable.$convertertype.toSql(type));
    }
    map['period_start'] = Variable<DateTime>(periodStart);
    map['have_fils'] = Variable<int>(haveFils);
    map['save_fils'] = Variable<int>(saveFils);
    map['spent_fils'] = Variable<int>(spentFils);
    map['have_note'] = Variable<String>(haveNote);
    map['save_note'] = Variable<String>(saveNote);
    map['spend_note'] = Variable<String>(spendNote);
    map['improve_note'] = Variable<String>(improveNote);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ReflectionsCompanion toCompanion(bool nullToAbsent) {
    return ReflectionsCompanion(
      id: Value(id),
      type: Value(type),
      periodStart: Value(periodStart),
      haveFils: Value(haveFils),
      saveFils: Value(saveFils),
      spentFils: Value(spentFils),
      haveNote: Value(haveNote),
      saveNote: Value(saveNote),
      spendNote: Value(spendNote),
      improveNote: Value(improveNote),
      createdAt: Value(createdAt),
    );
  }

  factory Reflection.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Reflection(
      id: serializer.fromJson<int>(json['id']),
      type: $ReflectionsTable.$convertertype.fromJson(serializer.fromJson<String>(json['type'])),
      periodStart: serializer.fromJson<DateTime>(json['periodStart']),
      haveFils: serializer.fromJson<int>(json['haveFils']),
      saveFils: serializer.fromJson<int>(json['saveFils']),
      spentFils: serializer.fromJson<int>(json['spentFils']),
      haveNote: serializer.fromJson<String>(json['haveNote']),
      saveNote: serializer.fromJson<String>(json['saveNote']),
      spendNote: serializer.fromJson<String>(json['spendNote']),
      improveNote: serializer.fromJson<String>(json['improveNote']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'type': serializer.toJson<String>($ReflectionsTable.$convertertype.toJson(type)),
      'periodStart': serializer.toJson<DateTime>(periodStart),
      'haveFils': serializer.toJson<int>(haveFils),
      'saveFils': serializer.toJson<int>(saveFils),
      'spentFils': serializer.toJson<int>(spentFils),
      'haveNote': serializer.toJson<String>(haveNote),
      'saveNote': serializer.toJson<String>(saveNote),
      'spendNote': serializer.toJson<String>(spendNote),
      'improveNote': serializer.toJson<String>(improveNote),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Reflection copyWith({
    int? id,
    ReflectionType? type,
    DateTime? periodStart,
    int? haveFils,
    int? saveFils,
    int? spentFils,
    String? haveNote,
    String? saveNote,
    String? spendNote,
    String? improveNote,
    DateTime? createdAt,
  }) => Reflection(
    id: id ?? this.id,
    type: type ?? this.type,
    periodStart: periodStart ?? this.periodStart,
    haveFils: haveFils ?? this.haveFils,
    saveFils: saveFils ?? this.saveFils,
    spentFils: spentFils ?? this.spentFils,
    haveNote: haveNote ?? this.haveNote,
    saveNote: saveNote ?? this.saveNote,
    spendNote: spendNote ?? this.spendNote,
    improveNote: improveNote ?? this.improveNote,
    createdAt: createdAt ?? this.createdAt,
  );
  Reflection copyWithCompanion(ReflectionsCompanion data) {
    return Reflection(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      periodStart: data.periodStart.present ? data.periodStart.value : this.periodStart,
      haveFils: data.haveFils.present ? data.haveFils.value : this.haveFils,
      saveFils: data.saveFils.present ? data.saveFils.value : this.saveFils,
      spentFils: data.spentFils.present ? data.spentFils.value : this.spentFils,
      haveNote: data.haveNote.present ? data.haveNote.value : this.haveNote,
      saveNote: data.saveNote.present ? data.saveNote.value : this.saveNote,
      spendNote: data.spendNote.present ? data.spendNote.value : this.spendNote,
      improveNote: data.improveNote.present ? data.improveNote.value : this.improveNote,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Reflection(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('periodStart: $periodStart, ')
          ..write('haveFils: $haveFils, ')
          ..write('saveFils: $saveFils, ')
          ..write('spentFils: $spentFils, ')
          ..write('haveNote: $haveNote, ')
          ..write('saveNote: $saveNote, ')
          ..write('spendNote: $spendNote, ')
          ..write('improveNote: $improveNote, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    type,
    periodStart,
    haveFils,
    saveFils,
    spentFils,
    haveNote,
    saveNote,
    spendNote,
    improveNote,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Reflection &&
          other.id == this.id &&
          other.type == this.type &&
          other.periodStart == this.periodStart &&
          other.haveFils == this.haveFils &&
          other.saveFils == this.saveFils &&
          other.spentFils == this.spentFils &&
          other.haveNote == this.haveNote &&
          other.saveNote == this.saveNote &&
          other.spendNote == this.spendNote &&
          other.improveNote == this.improveNote &&
          other.createdAt == this.createdAt);
}

class ReflectionsCompanion extends UpdateCompanion<Reflection> {
  final Value<int> id;
  final Value<ReflectionType> type;
  final Value<DateTime> periodStart;
  final Value<int> haveFils;
  final Value<int> saveFils;
  final Value<int> spentFils;
  final Value<String> haveNote;
  final Value<String> saveNote;
  final Value<String> spendNote;
  final Value<String> improveNote;
  final Value<DateTime> createdAt;
  const ReflectionsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.periodStart = const Value.absent(),
    this.haveFils = const Value.absent(),
    this.saveFils = const Value.absent(),
    this.spentFils = const Value.absent(),
    this.haveNote = const Value.absent(),
    this.saveNote = const Value.absent(),
    this.spendNote = const Value.absent(),
    this.improveNote = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ReflectionsCompanion.insert({
    this.id = const Value.absent(),
    required ReflectionType type,
    required DateTime periodStart,
    required int haveFils,
    required int saveFils,
    required int spentFils,
    this.haveNote = const Value.absent(),
    this.saveNote = const Value.absent(),
    this.spendNote = const Value.absent(),
    this.improveNote = const Value.absent(),
    required DateTime createdAt,
  }) : type = Value(type),
       periodStart = Value(periodStart),
       haveFils = Value(haveFils),
       saveFils = Value(saveFils),
       spentFils = Value(spentFils),
       createdAt = Value(createdAt);
  static Insertable<Reflection> custom({
    Expression<int>? id,
    Expression<String>? type,
    Expression<DateTime>? periodStart,
    Expression<int>? haveFils,
    Expression<int>? saveFils,
    Expression<int>? spentFils,
    Expression<String>? haveNote,
    Expression<String>? saveNote,
    Expression<String>? spendNote,
    Expression<String>? improveNote,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (periodStart != null) 'period_start': periodStart,
      if (haveFils != null) 'have_fils': haveFils,
      if (saveFils != null) 'save_fils': saveFils,
      if (spentFils != null) 'spent_fils': spentFils,
      if (haveNote != null) 'have_note': haveNote,
      if (saveNote != null) 'save_note': saveNote,
      if (spendNote != null) 'spend_note': spendNote,
      if (improveNote != null) 'improve_note': improveNote,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ReflectionsCompanion copyWith({
    Value<int>? id,
    Value<ReflectionType>? type,
    Value<DateTime>? periodStart,
    Value<int>? haveFils,
    Value<int>? saveFils,
    Value<int>? spentFils,
    Value<String>? haveNote,
    Value<String>? saveNote,
    Value<String>? spendNote,
    Value<String>? improveNote,
    Value<DateTime>? createdAt,
  }) {
    return ReflectionsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      periodStart: periodStart ?? this.periodStart,
      haveFils: haveFils ?? this.haveFils,
      saveFils: saveFils ?? this.saveFils,
      spentFils: spentFils ?? this.spentFils,
      haveNote: haveNote ?? this.haveNote,
      saveNote: saveNote ?? this.saveNote,
      spendNote: spendNote ?? this.spendNote,
      improveNote: improveNote ?? this.improveNote,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>($ReflectionsTable.$convertertype.toSql(type.value));
    }
    if (periodStart.present) {
      map['period_start'] = Variable<DateTime>(periodStart.value);
    }
    if (haveFils.present) {
      map['have_fils'] = Variable<int>(haveFils.value);
    }
    if (saveFils.present) {
      map['save_fils'] = Variable<int>(saveFils.value);
    }
    if (spentFils.present) {
      map['spent_fils'] = Variable<int>(spentFils.value);
    }
    if (haveNote.present) {
      map['have_note'] = Variable<String>(haveNote.value);
    }
    if (saveNote.present) {
      map['save_note'] = Variable<String>(saveNote.value);
    }
    if (spendNote.present) {
      map['spend_note'] = Variable<String>(spendNote.value);
    }
    if (improveNote.present) {
      map['improve_note'] = Variable<String>(improveNote.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReflectionsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('periodStart: $periodStart, ')
          ..write('haveFils: $haveFils, ')
          ..write('saveFils: $saveFils, ')
          ..write('spentFils: $spentFils, ')
          ..write('haveNote: $haveNote, ')
          ..write('saveNote: $saveNote, ')
          ..write('spendNote: $spendNote, ')
          ..write('improveNote: $improveNote, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $RecurringItemsTable recurringItems = $RecurringItemsTable(this);
  late final $EntriesTable entries = $EntriesTable(this);
  late final $MonthPlansTable monthPlans = $MonthPlansTable(this);
  late final $FixedCostsTable fixedCosts = $FixedCostsTable(this);
  late final $ReflectionsTable reflections = $ReflectionsTable(this);
  late final Index entriesDate = Index(
    'entries_date',
    'CREATE INDEX entries_date ON entries (date)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    recurringItems,
    entries,
    monthPlans,
    fixedCosts,
    reflections,
    entriesDate,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName('recurring_items', limitUpdateKind: UpdateKind.delete),
      result: [TableUpdate('entries', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName('month_plans', limitUpdateKind: UpdateKind.delete),
      result: [TableUpdate('fixed_costs', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$RecurringItemsTableCreateCompanionBuilder = RecurringItemsCompanion Function({
  Value<int> id,
  required String name,
  required int amountFils,
  required SpendCategory category,
  required Frequency frequency,
  required DateTime nextDueDate,
  Value<bool> active,
});
typedef $$RecurringItemsTableUpdateCompanionBuilder = RecurringItemsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<int> amountFils,
  Value<SpendCategory> category,
  Value<Frequency> frequency,
  Value<DateTime> nextDueDate,
  Value<bool> active,
});

final class $$RecurringItemsTableReferences
    extends BaseReferences<_$AppDatabase, $RecurringItemsTable, RecurringItem> {
  $$RecurringItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$EntriesTable, List<Entry>> _entriesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.entries,
        aliasName: 'recurring_items__id__entries__recurring_id',
      );

  $$EntriesTableProcessedTableManager get entriesRefs {
    final manager = $$EntriesTableTableManager(
      $_db,
      $_db.entries,
    ).filter((f) => f.recurringId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_entriesRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$RecurringItemsTableFilterComposer extends Composer<_$AppDatabase, $RecurringItemsTable> {
  $$RecurringItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get amountFils =>
      $composableBuilder(column: $table.amountFils, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<SpendCategory, SpendCategory, String> get category =>
      $composableBuilder(
        column: $table.category,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Frequency, Frequency, String> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get nextDueDate =>
      $composableBuilder(column: $table.nextDueDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => ColumnFilters(column));

  Expression<bool> entriesRefs(Expression<bool> Function($$EntriesTableFilterComposer f) f) {
    final $$EntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entries,
      getReferencedColumn: (t) => t.recurringId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$EntriesTableFilterComposer(
            $db: $db,
            $table: $db.entries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RecurringItemsTableOrderingComposer extends Composer<_$AppDatabase, $RecurringItemsTable> {
  $$RecurringItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get amountFils =>
      $composableBuilder(column: $table.amountFils, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get frequency =>
      $composableBuilder(column: $table.frequency, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get nextDueDate =>
      $composableBuilder(column: $table.nextDueDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => ColumnOrderings(column));
}

class $$RecurringItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecurringItemsTable> {
  $$RecurringItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get amountFils =>
      $composableBuilder(column: $table.amountFils, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SpendCategory, String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Frequency, String> get frequency =>
      $composableBuilder(column: $table.frequency, builder: (column) => column);

  GeneratedColumn<DateTime> get nextDueDate =>
      $composableBuilder(column: $table.nextDueDate, builder: (column) => column);

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);

  Expression<T> entriesRefs<T extends Object>(
    Expression<T> Function($$EntriesTableAnnotationComposer a) f,
  ) {
    final $$EntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entries,
      getReferencedColumn: (t) => t.recurringId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$EntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.entries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RecurringItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecurringItemsTable,
          RecurringItem,
          $$RecurringItemsTableFilterComposer,
          $$RecurringItemsTableOrderingComposer,
          $$RecurringItemsTableAnnotationComposer,
          $$RecurringItemsTableCreateCompanionBuilder,
          $$RecurringItemsTableUpdateCompanionBuilder,
          (RecurringItem, $$RecurringItemsTableReferences),
          RecurringItem,
          PrefetchHooks Function({bool entriesRefs})
        > {
  $$RecurringItemsTableTableManager(_$AppDatabase db, $RecurringItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecurringItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecurringItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecurringItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> amountFils = const Value.absent(),
                Value<SpendCategory> category = const Value.absent(),
                Value<Frequency> frequency = const Value.absent(),
                Value<DateTime> nextDueDate = const Value.absent(),
                Value<bool> active = const Value.absent(),
              }) => RecurringItemsCompanion(
                id: id,
                name: name,
                amountFils: amountFils,
                category: category,
                frequency: frequency,
                nextDueDate: nextDueDate,
                active: active,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required int amountFils,
                required SpendCategory category,
                required Frequency frequency,
                required DateTime nextDueDate,
                Value<bool> active = const Value.absent(),
              }) => RecurringItemsCompanion.insert(
                id: id,
                name: name,
                amountFils: amountFils,
                category: category,
                frequency: frequency,
                nextDueDate: nextDueDate,
                active: active,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RecurringItemsTable, RecurringItem>(table),
                  $$RecurringItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({entriesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (entriesRefs) db.entries],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (entriesRefs)
                    await $_getPrefetchedData<RecurringItem, $RecurringItemsTable, Entry>(
                      currentTable: table,
                      referencedTable: $$RecurringItemsTableReferences._entriesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$RecurringItemsTableReferences(db, table, p0).entriesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.recurringId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$RecurringItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecurringItemsTable,
      RecurringItem,
      $$RecurringItemsTableFilterComposer,
      $$RecurringItemsTableOrderingComposer,
      $$RecurringItemsTableAnnotationComposer,
      $$RecurringItemsTableCreateCompanionBuilder,
      $$RecurringItemsTableUpdateCompanionBuilder,
      (RecurringItem, $$RecurringItemsTableReferences),
      RecurringItem,
      PrefetchHooks Function({bool entriesRefs})
    >;
typedef $$EntriesTableCreateCompanionBuilder = EntriesCompanion Function({
  Value<int> id,
  required int amountFils,
  required SpendCategory category,
  Value<String> note,
  required DateTime date,
  required DateTime createdAt,
  Value<int?> recurringId,
});
typedef $$EntriesTableUpdateCompanionBuilder = EntriesCompanion Function({
  Value<int> id,
  Value<int> amountFils,
  Value<SpendCategory> category,
  Value<String> note,
  Value<DateTime> date,
  Value<DateTime> createdAt,
  Value<int?> recurringId,
});

final class $$EntriesTableReferences extends BaseReferences<_$AppDatabase, $EntriesTable, Entry> {
  $$EntriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RecurringItemsTable _recurringIdTable(_$AppDatabase db) =>
      db.recurringItems.createAlias('entries__recurring_id__recurring_items__id');

  $$RecurringItemsTableProcessedTableManager? get recurringId {
    final $_column = $_itemColumn<int>('recurring_id');
    if ($_column == null) return null;
    final manager = $$RecurringItemsTableTableManager(
      $_db,
      $_db.recurringItems,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_recurringIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$EntriesTableFilterComposer extends Composer<_$AppDatabase, $EntriesTable> {
  $$EntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get amountFils =>
      $composableBuilder(column: $table.amountFils, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<SpendCategory, SpendCategory, String> get category =>
      $composableBuilder(
        column: $table.category,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$RecurringItemsTableFilterComposer get recurringId {
    final $$RecurringItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recurringId,
      referencedTable: $db.recurringItems,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$RecurringItemsTableFilterComposer(
            $db: $db,
            $table: $db.recurringItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EntriesTableOrderingComposer extends Composer<_$AppDatabase, $EntriesTable> {
  $$EntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get amountFils =>
      $composableBuilder(column: $table.amountFils, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$RecurringItemsTableOrderingComposer get recurringId {
    final $$RecurringItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recurringId,
      referencedTable: $db.recurringItems,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$RecurringItemsTableOrderingComposer(
            $db: $db,
            $table: $db.recurringItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EntriesTableAnnotationComposer extends Composer<_$AppDatabase, $EntriesTable> {
  $$EntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get amountFils =>
      $composableBuilder(column: $table.amountFils, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SpendCategory, String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$RecurringItemsTableAnnotationComposer get recurringId {
    final $$RecurringItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recurringId,
      referencedTable: $db.recurringItems,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$RecurringItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.recurringItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EntriesTable,
          Entry,
          $$EntriesTableFilterComposer,
          $$EntriesTableOrderingComposer,
          $$EntriesTableAnnotationComposer,
          $$EntriesTableCreateCompanionBuilder,
          $$EntriesTableUpdateCompanionBuilder,
          (Entry, $$EntriesTableReferences),
          Entry,
          PrefetchHooks Function({bool recurringId})
        > {
  $$EntriesTableTableManager(_$AppDatabase db, $EntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$EntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$EntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> amountFils = const Value.absent(),
                Value<SpendCategory> category = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int?> recurringId = const Value.absent(),
              }) => EntriesCompanion(
                id: id,
                amountFils: amountFils,
                category: category,
                note: note,
                date: date,
                createdAt: createdAt,
                recurringId: recurringId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int amountFils,
                required SpendCategory category,
                Value<String> note = const Value.absent(),
                required DateTime date,
                required DateTime createdAt,
                Value<int?> recurringId = const Value.absent(),
              }) => EntriesCompanion.insert(
                id: id,
                amountFils: amountFils,
                category: category,
                note: note,
                date: date,
                createdAt: createdAt,
                recurringId: recurringId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EntriesTable, Entry>(table),
                  $$EntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({recurringId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (recurringId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.recurringId,
                        referencedTable: $$EntriesTableReferences._recurringIdTable(db),
                        referencedColumn: $$EntriesTableReferences._recurringIdTable(db).id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$EntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EntriesTable,
      Entry,
      $$EntriesTableFilterComposer,
      $$EntriesTableOrderingComposer,
      $$EntriesTableAnnotationComposer,
      $$EntriesTableCreateCompanionBuilder,
      $$EntriesTableUpdateCompanionBuilder,
      (Entry, $$EntriesTableReferences),
      Entry,
      PrefetchHooks Function({bool recurringId})
    >;
typedef $$MonthPlansTableCreateCompanionBuilder = MonthPlansCompanion Function({
  required DateTime periodStart,
  required int incomeFils,
  required int savingsGoalFils,
  Value<int> rowid,
});
typedef $$MonthPlansTableUpdateCompanionBuilder = MonthPlansCompanion Function({
  Value<DateTime> periodStart,
  Value<int> incomeFils,
  Value<int> savingsGoalFils,
  Value<int> rowid,
});

final class $$MonthPlansTableReferences
    extends BaseReferences<_$AppDatabase, $MonthPlansTable, MonthPlan> {
  $$MonthPlansTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$FixedCostsTable, List<FixedCost>> _fixedCostsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.fixedCosts,
    aliasName: 'month_plans__period_start__fixed_costs__period_start',
  );

  $$FixedCostsTableProcessedTableManager get fixedCostsRefs {
    final manager = $$FixedCostsTableTableManager(
      $_db,
      $_db.fixedCosts,
    ).filter((f) => f.periodStart.periodStart.sqlEquals($_itemColumn<DateTime>('period_start')!));

    final cache = $_typedResult.readTableOrNull(_fixedCostsRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$MonthPlansTableFilterComposer extends Composer<_$AppDatabase, $MonthPlansTable> {
  $$MonthPlansTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get periodStart =>
      $composableBuilder(column: $table.periodStart, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get incomeFils =>
      $composableBuilder(column: $table.incomeFils, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get savingsGoalFils => $composableBuilder(
    column: $table.savingsGoalFils,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> fixedCostsRefs(Expression<bool> Function($$FixedCostsTableFilterComposer f) f) {
    final $$FixedCostsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.periodStart,
      referencedTable: $db.fixedCosts,
      getReferencedColumn: (t) => t.periodStart,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$FixedCostsTableFilterComposer(
            $db: $db,
            $table: $db.fixedCosts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MonthPlansTableOrderingComposer extends Composer<_$AppDatabase, $MonthPlansTable> {
  $$MonthPlansTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get periodStart =>
      $composableBuilder(column: $table.periodStart, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get incomeFils =>
      $composableBuilder(column: $table.incomeFils, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get savingsGoalFils => $composableBuilder(
    column: $table.savingsGoalFils,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MonthPlansTableAnnotationComposer extends Composer<_$AppDatabase, $MonthPlansTable> {
  $$MonthPlansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get periodStart =>
      $composableBuilder(column: $table.periodStart, builder: (column) => column);

  GeneratedColumn<int> get incomeFils =>
      $composableBuilder(column: $table.incomeFils, builder: (column) => column);

  GeneratedColumn<int> get savingsGoalFils =>
      $composableBuilder(column: $table.savingsGoalFils, builder: (column) => column);

  Expression<T> fixedCostsRefs<T extends Object>(
    Expression<T> Function($$FixedCostsTableAnnotationComposer a) f,
  ) {
    final $$FixedCostsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.periodStart,
      referencedTable: $db.fixedCosts,
      getReferencedColumn: (t) => t.periodStart,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$FixedCostsTableAnnotationComposer(
            $db: $db,
            $table: $db.fixedCosts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MonthPlansTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MonthPlansTable,
          MonthPlan,
          $$MonthPlansTableFilterComposer,
          $$MonthPlansTableOrderingComposer,
          $$MonthPlansTableAnnotationComposer,
          $$MonthPlansTableCreateCompanionBuilder,
          $$MonthPlansTableUpdateCompanionBuilder,
          (MonthPlan, $$MonthPlansTableReferences),
          MonthPlan,
          PrefetchHooks Function({bool fixedCostsRefs})
        > {
  $$MonthPlansTableTableManager(_$AppDatabase db, $MonthPlansTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$MonthPlansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$MonthPlansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MonthPlansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<DateTime> periodStart = const Value.absent(),
                Value<int> incomeFils = const Value.absent(),
                Value<int> savingsGoalFils = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MonthPlansCompanion(
                periodStart: periodStart,
                incomeFils: incomeFils,
                savingsGoalFils: savingsGoalFils,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required DateTime periodStart,
                required int incomeFils,
                required int savingsGoalFils,
                Value<int> rowid = const Value.absent(),
              }) => MonthPlansCompanion.insert(
                periodStart: periodStart,
                incomeFils: incomeFils,
                savingsGoalFils: savingsGoalFils,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MonthPlansTable, MonthPlan>(table),
                  $$MonthPlansTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({fixedCostsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (fixedCostsRefs) db.fixedCosts],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (fixedCostsRefs)
                    await $_getPrefetchedData<MonthPlan, $MonthPlansTable, FixedCost>(
                      currentTable: table,
                      referencedTable: $$MonthPlansTableReferences._fixedCostsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$MonthPlansTableReferences(db, table, p0).fixedCostsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.periodStart == item.periodStart),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$MonthPlansTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MonthPlansTable,
      MonthPlan,
      $$MonthPlansTableFilterComposer,
      $$MonthPlansTableOrderingComposer,
      $$MonthPlansTableAnnotationComposer,
      $$MonthPlansTableCreateCompanionBuilder,
      $$MonthPlansTableUpdateCompanionBuilder,
      (MonthPlan, $$MonthPlansTableReferences),
      MonthPlan,
      PrefetchHooks Function({bool fixedCostsRefs})
    >;
typedef $$FixedCostsTableCreateCompanionBuilder = FixedCostsCompanion Function({
  Value<int> id,
  required DateTime periodStart,
  required String name,
  required int amountFils,
});
typedef $$FixedCostsTableUpdateCompanionBuilder = FixedCostsCompanion Function({
  Value<int> id,
  Value<DateTime> periodStart,
  Value<String> name,
  Value<int> amountFils,
});

final class $$FixedCostsTableReferences
    extends BaseReferences<_$AppDatabase, $FixedCostsTable, FixedCost> {
  $$FixedCostsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MonthPlansTable _periodStartTable(_$AppDatabase db) =>
      db.monthPlans.createAlias('fixed_costs__period_start__month_plans__period_start');

  $$MonthPlansTableProcessedTableManager get periodStart {
    final $_column = $_itemColumn<DateTime>('period_start')!;

    final manager = $$MonthPlansTableTableManager(
      $_db,
      $_db.monthPlans,
    ).filter((f) => f.periodStart.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_periodStartTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$FixedCostsTableFilterComposer extends Composer<_$AppDatabase, $FixedCostsTable> {
  $$FixedCostsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get amountFils =>
      $composableBuilder(column: $table.amountFils, builder: (column) => ColumnFilters(column));

  $$MonthPlansTableFilterComposer get periodStart {
    final $$MonthPlansTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.periodStart,
      referencedTable: $db.monthPlans,
      getReferencedColumn: (t) => t.periodStart,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$MonthPlansTableFilterComposer(
            $db: $db,
            $table: $db.monthPlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FixedCostsTableOrderingComposer extends Composer<_$AppDatabase, $FixedCostsTable> {
  $$FixedCostsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get amountFils =>
      $composableBuilder(column: $table.amountFils, builder: (column) => ColumnOrderings(column));

  $$MonthPlansTableOrderingComposer get periodStart {
    final $$MonthPlansTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.periodStart,
      referencedTable: $db.monthPlans,
      getReferencedColumn: (t) => t.periodStart,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$MonthPlansTableOrderingComposer(
            $db: $db,
            $table: $db.monthPlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FixedCostsTableAnnotationComposer extends Composer<_$AppDatabase, $FixedCostsTable> {
  $$FixedCostsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get amountFils =>
      $composableBuilder(column: $table.amountFils, builder: (column) => column);

  $$MonthPlansTableAnnotationComposer get periodStart {
    final $$MonthPlansTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.periodStart,
      referencedTable: $db.monthPlans,
      getReferencedColumn: (t) => t.periodStart,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$MonthPlansTableAnnotationComposer(
            $db: $db,
            $table: $db.monthPlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FixedCostsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FixedCostsTable,
          FixedCost,
          $$FixedCostsTableFilterComposer,
          $$FixedCostsTableOrderingComposer,
          $$FixedCostsTableAnnotationComposer,
          $$FixedCostsTableCreateCompanionBuilder,
          $$FixedCostsTableUpdateCompanionBuilder,
          (FixedCost, $$FixedCostsTableReferences),
          FixedCost,
          PrefetchHooks Function({bool periodStart})
        > {
  $$FixedCostsTableTableManager(_$AppDatabase db, $FixedCostsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$FixedCostsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$FixedCostsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FixedCostsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> periodStart = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> amountFils = const Value.absent(),
              }) => FixedCostsCompanion(
                id: id,
                periodStart: periodStart,
                name: name,
                amountFils: amountFils,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime periodStart,
                required String name,
                required int amountFils,
              }) => FixedCostsCompanion.insert(
                id: id,
                periodStart: periodStart,
                name: name,
                amountFils: amountFils,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FixedCostsTable, FixedCost>(table),
                  $$FixedCostsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({periodStart = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (periodStart) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.periodStart,
                        referencedTable: $$FixedCostsTableReferences._periodStartTable(db),
                        referencedColumn: $$FixedCostsTableReferences
                            ._periodStartTable(db)
                            .periodStart,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$FixedCostsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FixedCostsTable,
      FixedCost,
      $$FixedCostsTableFilterComposer,
      $$FixedCostsTableOrderingComposer,
      $$FixedCostsTableAnnotationComposer,
      $$FixedCostsTableCreateCompanionBuilder,
      $$FixedCostsTableUpdateCompanionBuilder,
      (FixedCost, $$FixedCostsTableReferences),
      FixedCost,
      PrefetchHooks Function({bool periodStart})
    >;
typedef $$ReflectionsTableCreateCompanionBuilder = ReflectionsCompanion Function({
  Value<int> id,
  required ReflectionType type,
  required DateTime periodStart,
  required int haveFils,
  required int saveFils,
  required int spentFils,
  Value<String> haveNote,
  Value<String> saveNote,
  Value<String> spendNote,
  Value<String> improveNote,
  required DateTime createdAt,
});
typedef $$ReflectionsTableUpdateCompanionBuilder = ReflectionsCompanion Function({
  Value<int> id,
  Value<ReflectionType> type,
  Value<DateTime> periodStart,
  Value<int> haveFils,
  Value<int> saveFils,
  Value<int> spentFils,
  Value<String> haveNote,
  Value<String> saveNote,
  Value<String> spendNote,
  Value<String> improveNote,
  Value<DateTime> createdAt,
});

class $$ReflectionsTableFilterComposer extends Composer<_$AppDatabase, $ReflectionsTable> {
  $$ReflectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<ReflectionType, ReflectionType, String> get type =>
      $composableBuilder(
        column: $table.type,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get periodStart =>
      $composableBuilder(column: $table.periodStart, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get haveFils =>
      $composableBuilder(column: $table.haveFils, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get saveFils =>
      $composableBuilder(column: $table.saveFils, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get spentFils =>
      $composableBuilder(column: $table.spentFils, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get haveNote =>
      $composableBuilder(column: $table.haveNote, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get saveNote =>
      $composableBuilder(column: $table.saveNote, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get spendNote =>
      $composableBuilder(column: $table.spendNote, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get improveNote =>
      $composableBuilder(column: $table.improveNote, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$ReflectionsTableOrderingComposer extends Composer<_$AppDatabase, $ReflectionsTable> {
  $$ReflectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get periodStart =>
      $composableBuilder(column: $table.periodStart, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get haveFils =>
      $composableBuilder(column: $table.haveFils, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get saveFils =>
      $composableBuilder(column: $table.saveFils, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get spentFils =>
      $composableBuilder(column: $table.spentFils, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get haveNote =>
      $composableBuilder(column: $table.haveNote, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get saveNote =>
      $composableBuilder(column: $table.saveNote, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get spendNote =>
      $composableBuilder(column: $table.spendNote, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get improveNote =>
      $composableBuilder(column: $table.improveNote, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$ReflectionsTableAnnotationComposer extends Composer<_$AppDatabase, $ReflectionsTable> {
  $$ReflectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ReflectionType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<DateTime> get periodStart =>
      $composableBuilder(column: $table.periodStart, builder: (column) => column);

  GeneratedColumn<int> get haveFils =>
      $composableBuilder(column: $table.haveFils, builder: (column) => column);

  GeneratedColumn<int> get saveFils =>
      $composableBuilder(column: $table.saveFils, builder: (column) => column);

  GeneratedColumn<int> get spentFils =>
      $composableBuilder(column: $table.spentFils, builder: (column) => column);

  GeneratedColumn<String> get haveNote =>
      $composableBuilder(column: $table.haveNote, builder: (column) => column);

  GeneratedColumn<String> get saveNote =>
      $composableBuilder(column: $table.saveNote, builder: (column) => column);

  GeneratedColumn<String> get spendNote =>
      $composableBuilder(column: $table.spendNote, builder: (column) => column);

  GeneratedColumn<String> get improveNote =>
      $composableBuilder(column: $table.improveNote, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ReflectionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReflectionsTable,
          Reflection,
          $$ReflectionsTableFilterComposer,
          $$ReflectionsTableOrderingComposer,
          $$ReflectionsTableAnnotationComposer,
          $$ReflectionsTableCreateCompanionBuilder,
          $$ReflectionsTableUpdateCompanionBuilder,
          (Reflection, BaseReferences<_$AppDatabase, $ReflectionsTable, Reflection>),
          Reflection,
          PrefetchHooks Function()
        > {
  $$ReflectionsTableTableManager(_$AppDatabase db, $ReflectionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$ReflectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$ReflectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReflectionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<ReflectionType> type = const Value.absent(),
                Value<DateTime> periodStart = const Value.absent(),
                Value<int> haveFils = const Value.absent(),
                Value<int> saveFils = const Value.absent(),
                Value<int> spentFils = const Value.absent(),
                Value<String> haveNote = const Value.absent(),
                Value<String> saveNote = const Value.absent(),
                Value<String> spendNote = const Value.absent(),
                Value<String> improveNote = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ReflectionsCompanion(
                id: id,
                type: type,
                periodStart: periodStart,
                haveFils: haveFils,
                saveFils: saveFils,
                spentFils: spentFils,
                haveNote: haveNote,
                saveNote: saveNote,
                spendNote: spendNote,
                improveNote: improveNote,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required ReflectionType type,
                required DateTime periodStart,
                required int haveFils,
                required int saveFils,
                required int spentFils,
                Value<String> haveNote = const Value.absent(),
                Value<String> saveNote = const Value.absent(),
                Value<String> spendNote = const Value.absent(),
                Value<String> improveNote = const Value.absent(),
                required DateTime createdAt,
              }) => ReflectionsCompanion.insert(
                id: id,
                type: type,
                periodStart: periodStart,
                haveFils: haveFils,
                saveFils: saveFils,
                spentFils: spentFils,
                haveNote: haveNote,
                saveNote: saveNote,
                spendNote: spendNote,
                improveNote: improveNote,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ReflectionsTable, Reflection>(table),
                  BaseReferences<_$AppDatabase, $ReflectionsTable, Reflection>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReflectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReflectionsTable,
      Reflection,
      $$ReflectionsTableFilterComposer,
      $$ReflectionsTableOrderingComposer,
      $$ReflectionsTableAnnotationComposer,
      $$ReflectionsTableCreateCompanionBuilder,
      $$ReflectionsTableUpdateCompanionBuilder,
      (Reflection, BaseReferences<_$AppDatabase, $ReflectionsTable, Reflection>),
      Reflection,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$RecurringItemsTableTableManager get recurringItems =>
      $$RecurringItemsTableTableManager(_db, _db.recurringItems);
  $$EntriesTableTableManager get entries => $$EntriesTableTableManager(_db, _db.entries);
  $$MonthPlansTableTableManager get monthPlans =>
      $$MonthPlansTableTableManager(_db, _db.monthPlans);
  $$FixedCostsTableTableManager get fixedCosts =>
      $$FixedCostsTableTableManager(_db, _db.fixedCosts);
  $$ReflectionsTableTableManager get reflections =>
      $$ReflectionsTableTableManager(_db, _db.reflections);
}
