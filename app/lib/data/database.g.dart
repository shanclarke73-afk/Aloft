// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $AppSettingsTableTable extends AppSettingsTable with TableInfo<$AppSettingsTableTable, AppSettings> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 1 CHECK (id = 1)',
    defaultValue: const CustomExpression('1'),
  );
  @override
  late final GeneratedColumnWithTypeConverter<WeightUnit, String> weightUnit = GeneratedColumn<String>(
    'weight_unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<WeightUnit>($AppSettingsTableTable.$converterweightUnit);
  @override
  late final GeneratedColumnWithTypeConverter<LengthUnit, String> lengthUnit = GeneratedColumn<String>(
    'length_unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<LengthUnit>($AppSettingsTableTable.$converterlengthUnit);
  @override
  late final GeneratedColumnWithTypeConverter<Appearance, String> appearance = GeneratedColumn<String>(
    'appearance',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('system'),
  ).withConverter<Appearance>($AppSettingsTableTable.$converterappearance);
  static const VerificationMeta _appLockMeta = const VerificationMeta('appLock');
  @override
  late final GeneratedColumn<bool> appLock = GeneratedColumn<bool>(
    'app_lock',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("app_lock" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  @override
  late final GeneratedColumnWithTypeConverter<LockAfter, String> lockAfter = GeneratedColumn<String>(
    'lock_after',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('immediately'),
  ).withConverter<LockAfter>($AppSettingsTableTable.$converterlockAfter);
  static const VerificationMeta _hideInAppSwitcherMeta = const VerificationMeta('hideInAppSwitcher');
  @override
  late final GeneratedColumn<bool> hideInAppSwitcher = GeneratedColumn<bool>(
    'hide_in_app_switcher',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("hide_in_app_switcher" IN (0, 1))'),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [id, weightUnit, lengthUnit, appearance, appLock, lockAfter, hideInAppSwitcher];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(Insertable<AppSettings> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('app_lock')) {
      context.handle(_appLockMeta, appLock.isAcceptableOrUnknown(data['app_lock']!, _appLockMeta));
    }
    if (data.containsKey('hide_in_app_switcher')) {
      context.handle(
        _hideInAppSwitcherMeta,
        hideInAppSwitcher.isAcceptableOrUnknown(data['hide_in_app_switcher']!, _hideInAppSwitcherMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppSettings map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSettings(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      weightUnit: $AppSettingsTableTable.$converterweightUnit.fromSql(
        attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}weight_unit'])!,
      ),
      lengthUnit: $AppSettingsTableTable.$converterlengthUnit.fromSql(
        attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}length_unit'])!,
      ),
      appearance: $AppSettingsTableTable.$converterappearance.fromSql(
        attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}appearance'])!,
      ),
      appLock: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}app_lock'])!,
      lockAfter: $AppSettingsTableTable.$converterlockAfter.fromSql(
        attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}lock_after'])!,
      ),
      hideInAppSwitcher: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}hide_in_app_switcher'],
      )!,
    );
  }

  @override
  $AppSettingsTableTable createAlias(String alias) {
    return $AppSettingsTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<WeightUnit, String, String> $converterweightUnit = const EnumNameConverter<WeightUnit>(
    WeightUnit.values,
  );
  static JsonTypeConverter2<LengthUnit, String, String> $converterlengthUnit = const EnumNameConverter<LengthUnit>(
    LengthUnit.values,
  );
  static JsonTypeConverter2<Appearance, String, String> $converterappearance = const EnumNameConverter<Appearance>(
    Appearance.values,
  );
  static JsonTypeConverter2<LockAfter, String, String> $converterlockAfter = const EnumNameConverter<LockAfter>(
    LockAfter.values,
  );
}

class AppSettings extends DataClass implements Insertable<AppSettings> {
  final int id;
  final WeightUnit weightUnit;
  final LengthUnit lengthUnit;
  final Appearance appearance;
  final bool appLock;
  final LockAfter lockAfter;
  final bool hideInAppSwitcher;
  const AppSettings({
    required this.id,
    required this.weightUnit,
    required this.lengthUnit,
    required this.appearance,
    required this.appLock,
    required this.lockAfter,
    required this.hideInAppSwitcher,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['weight_unit'] = Variable<String>($AppSettingsTableTable.$converterweightUnit.toSql(weightUnit));
    }
    {
      map['length_unit'] = Variable<String>($AppSettingsTableTable.$converterlengthUnit.toSql(lengthUnit));
    }
    {
      map['appearance'] = Variable<String>($AppSettingsTableTable.$converterappearance.toSql(appearance));
    }
    map['app_lock'] = Variable<bool>(appLock);
    {
      map['lock_after'] = Variable<String>($AppSettingsTableTable.$converterlockAfter.toSql(lockAfter));
    }
    map['hide_in_app_switcher'] = Variable<bool>(hideInAppSwitcher);
    return map;
  }

  AppSettingsTableCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsTableCompanion(
      id: Value(id),
      weightUnit: Value(weightUnit),
      lengthUnit: Value(lengthUnit),
      appearance: Value(appearance),
      appLock: Value(appLock),
      lockAfter: Value(lockAfter),
      hideInAppSwitcher: Value(hideInAppSwitcher),
    );
  }

  factory AppSettings.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSettings(
      id: serializer.fromJson<int>(json['id']),
      weightUnit: $AppSettingsTableTable.$converterweightUnit.fromJson(serializer.fromJson<String>(json['weightUnit'])),
      lengthUnit: $AppSettingsTableTable.$converterlengthUnit.fromJson(serializer.fromJson<String>(json['lengthUnit'])),
      appearance: $AppSettingsTableTable.$converterappearance.fromJson(serializer.fromJson<String>(json['appearance'])),
      appLock: serializer.fromJson<bool>(json['appLock']),
      lockAfter: $AppSettingsTableTable.$converterlockAfter.fromJson(serializer.fromJson<String>(json['lockAfter'])),
      hideInAppSwitcher: serializer.fromJson<bool>(json['hideInAppSwitcher']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'weightUnit': serializer.toJson<String>($AppSettingsTableTable.$converterweightUnit.toJson(weightUnit)),
      'lengthUnit': serializer.toJson<String>($AppSettingsTableTable.$converterlengthUnit.toJson(lengthUnit)),
      'appearance': serializer.toJson<String>($AppSettingsTableTable.$converterappearance.toJson(appearance)),
      'appLock': serializer.toJson<bool>(appLock),
      'lockAfter': serializer.toJson<String>($AppSettingsTableTable.$converterlockAfter.toJson(lockAfter)),
      'hideInAppSwitcher': serializer.toJson<bool>(hideInAppSwitcher),
    };
  }

  AppSettings copyWith({
    int? id,
    WeightUnit? weightUnit,
    LengthUnit? lengthUnit,
    Appearance? appearance,
    bool? appLock,
    LockAfter? lockAfter,
    bool? hideInAppSwitcher,
  }) => AppSettings(
    id: id ?? this.id,
    weightUnit: weightUnit ?? this.weightUnit,
    lengthUnit: lengthUnit ?? this.lengthUnit,
    appearance: appearance ?? this.appearance,
    appLock: appLock ?? this.appLock,
    lockAfter: lockAfter ?? this.lockAfter,
    hideInAppSwitcher: hideInAppSwitcher ?? this.hideInAppSwitcher,
  );
  AppSettings copyWithCompanion(AppSettingsTableCompanion data) {
    return AppSettings(
      id: data.id.present ? data.id.value : this.id,
      weightUnit: data.weightUnit.present ? data.weightUnit.value : this.weightUnit,
      lengthUnit: data.lengthUnit.present ? data.lengthUnit.value : this.lengthUnit,
      appearance: data.appearance.present ? data.appearance.value : this.appearance,
      appLock: data.appLock.present ? data.appLock.value : this.appLock,
      lockAfter: data.lockAfter.present ? data.lockAfter.value : this.lockAfter,
      hideInAppSwitcher: data.hideInAppSwitcher.present ? data.hideInAppSwitcher.value : this.hideInAppSwitcher,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSettings(')
          ..write('id: $id, ')
          ..write('weightUnit: $weightUnit, ')
          ..write('lengthUnit: $lengthUnit, ')
          ..write('appearance: $appearance, ')
          ..write('appLock: $appLock, ')
          ..write('lockAfter: $lockAfter, ')
          ..write('hideInAppSwitcher: $hideInAppSwitcher')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, weightUnit, lengthUnit, appearance, appLock, lockAfter, hideInAppSwitcher);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSettings &&
          other.id == this.id &&
          other.weightUnit == this.weightUnit &&
          other.lengthUnit == this.lengthUnit &&
          other.appearance == this.appearance &&
          other.appLock == this.appLock &&
          other.lockAfter == this.lockAfter &&
          other.hideInAppSwitcher == this.hideInAppSwitcher);
}

class AppSettingsTableCompanion extends UpdateCompanion<AppSettings> {
  final Value<int> id;
  final Value<WeightUnit> weightUnit;
  final Value<LengthUnit> lengthUnit;
  final Value<Appearance> appearance;
  final Value<bool> appLock;
  final Value<LockAfter> lockAfter;
  final Value<bool> hideInAppSwitcher;
  const AppSettingsTableCompanion({
    this.id = const Value.absent(),
    this.weightUnit = const Value.absent(),
    this.lengthUnit = const Value.absent(),
    this.appearance = const Value.absent(),
    this.appLock = const Value.absent(),
    this.lockAfter = const Value.absent(),
    this.hideInAppSwitcher = const Value.absent(),
  });
  AppSettingsTableCompanion.insert({
    this.id = const Value.absent(),
    required WeightUnit weightUnit,
    required LengthUnit lengthUnit,
    this.appearance = const Value.absent(),
    this.appLock = const Value.absent(),
    this.lockAfter = const Value.absent(),
    this.hideInAppSwitcher = const Value.absent(),
  }) : weightUnit = Value(weightUnit),
       lengthUnit = Value(lengthUnit);
  static Insertable<AppSettings> custom({
    Expression<int>? id,
    Expression<String>? weightUnit,
    Expression<String>? lengthUnit,
    Expression<String>? appearance,
    Expression<bool>? appLock,
    Expression<String>? lockAfter,
    Expression<bool>? hideInAppSwitcher,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (weightUnit != null) 'weight_unit': weightUnit,
      if (lengthUnit != null) 'length_unit': lengthUnit,
      if (appearance != null) 'appearance': appearance,
      if (appLock != null) 'app_lock': appLock,
      if (lockAfter != null) 'lock_after': lockAfter,
      if (hideInAppSwitcher != null) 'hide_in_app_switcher': hideInAppSwitcher,
    });
  }

  AppSettingsTableCompanion copyWith({
    Value<int>? id,
    Value<WeightUnit>? weightUnit,
    Value<LengthUnit>? lengthUnit,
    Value<Appearance>? appearance,
    Value<bool>? appLock,
    Value<LockAfter>? lockAfter,
    Value<bool>? hideInAppSwitcher,
  }) {
    return AppSettingsTableCompanion(
      id: id ?? this.id,
      weightUnit: weightUnit ?? this.weightUnit,
      lengthUnit: lengthUnit ?? this.lengthUnit,
      appearance: appearance ?? this.appearance,
      appLock: appLock ?? this.appLock,
      lockAfter: lockAfter ?? this.lockAfter,
      hideInAppSwitcher: hideInAppSwitcher ?? this.hideInAppSwitcher,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (weightUnit.present) {
      map['weight_unit'] = Variable<String>($AppSettingsTableTable.$converterweightUnit.toSql(weightUnit.value));
    }
    if (lengthUnit.present) {
      map['length_unit'] = Variable<String>($AppSettingsTableTable.$converterlengthUnit.toSql(lengthUnit.value));
    }
    if (appearance.present) {
      map['appearance'] = Variable<String>($AppSettingsTableTable.$converterappearance.toSql(appearance.value));
    }
    if (appLock.present) {
      map['app_lock'] = Variable<bool>(appLock.value);
    }
    if (lockAfter.present) {
      map['lock_after'] = Variable<String>($AppSettingsTableTable.$converterlockAfter.toSql(lockAfter.value));
    }
    if (hideInAppSwitcher.present) {
      map['hide_in_app_switcher'] = Variable<bool>(hideInAppSwitcher.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsTableCompanion(')
          ..write('id: $id, ')
          ..write('weightUnit: $weightUnit, ')
          ..write('lengthUnit: $lengthUnit, ')
          ..write('appearance: $appearance, ')
          ..write('appLock: $appLock, ')
          ..write('lockAfter: $lockAfter, ')
          ..write('hideInAppSwitcher: $hideInAppSwitcher')
          ..write(')'))
        .toString();
  }
}

abstract class _$AloftDatabase extends GeneratedDatabase {
  _$AloftDatabase(QueryExecutor e) : super(e);
  $AloftDatabaseManager get managers => $AloftDatabaseManager(this);
  late final $AppSettingsTableTable appSettingsTable = $AppSettingsTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables => allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [appSettingsTable];
}

typedef $$AppSettingsTableTableCreateCompanionBuilder = AppSettingsTableCompanion Function({
  Value<int> id,
  required WeightUnit weightUnit,
  required LengthUnit lengthUnit,
  Value<Appearance> appearance,
  Value<bool> appLock,
  Value<LockAfter> lockAfter,
  Value<bool> hideInAppSwitcher,
});
typedef $$AppSettingsTableTableUpdateCompanionBuilder = AppSettingsTableCompanion Function({
  Value<int> id,
  Value<WeightUnit> weightUnit,
  Value<LengthUnit> lengthUnit,
  Value<Appearance> appearance,
  Value<bool> appLock,
  Value<LockAfter> lockAfter,
  Value<bool> hideInAppSwitcher,
});

class $$AppSettingsTableTableFilterComposer extends Composer<_$AloftDatabase, $AppSettingsTableTable> {
  $$AppSettingsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<WeightUnit, WeightUnit, String> get weightUnit =>
      $composableBuilder(column: $table.weightUnit, builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<LengthUnit, LengthUnit, String> get lengthUnit =>
      $composableBuilder(column: $table.lengthUnit, builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<Appearance, Appearance, String> get appearance =>
      $composableBuilder(column: $table.appearance, builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<bool> get appLock =>
      $composableBuilder(column: $table.appLock, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<LockAfter, LockAfter, String> get lockAfter =>
      $composableBuilder(column: $table.lockAfter, builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<bool> get hideInAppSwitcher =>
      $composableBuilder(column: $table.hideInAppSwitcher, builder: (column) => ColumnFilters(column));
}

class $$AppSettingsTableTableOrderingComposer extends Composer<_$AloftDatabase, $AppSettingsTableTable> {
  $$AppSettingsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get weightUnit =>
      $composableBuilder(column: $table.weightUnit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lengthUnit =>
      $composableBuilder(column: $table.lengthUnit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get appearance =>
      $composableBuilder(column: $table.appearance, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get appLock =>
      $composableBuilder(column: $table.appLock, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lockAfter =>
      $composableBuilder(column: $table.lockAfter, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get hideInAppSwitcher =>
      $composableBuilder(column: $table.hideInAppSwitcher, builder: (column) => ColumnOrderings(column));
}

class $$AppSettingsTableTableAnnotationComposer extends Composer<_$AloftDatabase, $AppSettingsTableTable> {
  $$AppSettingsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<WeightUnit, String> get weightUnit =>
      $composableBuilder(column: $table.weightUnit, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LengthUnit, String> get lengthUnit =>
      $composableBuilder(column: $table.lengthUnit, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Appearance, String> get appearance =>
      $composableBuilder(column: $table.appearance, builder: (column) => column);

  GeneratedColumn<bool> get appLock => $composableBuilder(column: $table.appLock, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LockAfter, String> get lockAfter =>
      $composableBuilder(column: $table.lockAfter, builder: (column) => column);

  GeneratedColumn<bool> get hideInAppSwitcher =>
      $composableBuilder(column: $table.hideInAppSwitcher, builder: (column) => column);
}

class $$AppSettingsTableTableTableManager
    extends
        RootTableManager<
          _$AloftDatabase,
          $AppSettingsTableTable,
          AppSettings,
          $$AppSettingsTableTableFilterComposer,
          $$AppSettingsTableTableOrderingComposer,
          $$AppSettingsTableTableAnnotationComposer,
          $$AppSettingsTableTableCreateCompanionBuilder,
          $$AppSettingsTableTableUpdateCompanionBuilder,
          (AppSettings, BaseReferences<_$AloftDatabase, $AppSettingsTableTable, AppSettings>),
          AppSettings,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableTableManager(_$AloftDatabase db, $AppSettingsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$AppSettingsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$AppSettingsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$AppSettingsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<WeightUnit> weightUnit = const Value.absent(),
                Value<LengthUnit> lengthUnit = const Value.absent(),
                Value<Appearance> appearance = const Value.absent(),
                Value<bool> appLock = const Value.absent(),
                Value<LockAfter> lockAfter = const Value.absent(),
                Value<bool> hideInAppSwitcher = const Value.absent(),
              }) => AppSettingsTableCompanion(
                id: id,
                weightUnit: weightUnit,
                lengthUnit: lengthUnit,
                appearance: appearance,
                appLock: appLock,
                lockAfter: lockAfter,
                hideInAppSwitcher: hideInAppSwitcher,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required WeightUnit weightUnit,
                required LengthUnit lengthUnit,
                Value<Appearance> appearance = const Value.absent(),
                Value<bool> appLock = const Value.absent(),
                Value<LockAfter> lockAfter = const Value.absent(),
                Value<bool> hideInAppSwitcher = const Value.absent(),
              }) => AppSettingsTableCompanion.insert(
                id: id,
                weightUnit: weightUnit,
                lengthUnit: lengthUnit,
                appearance: appearance,
                appLock: appLock,
                lockAfter: lockAfter,
                hideInAppSwitcher: hideInAppSwitcher,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppSettingsTableTable, AppSettings>(table),
                  BaseReferences<_$AloftDatabase, $AppSettingsTableTable, AppSettings>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AloftDatabase,
      $AppSettingsTableTable,
      AppSettings,
      $$AppSettingsTableTableFilterComposer,
      $$AppSettingsTableTableOrderingComposer,
      $$AppSettingsTableTableAnnotationComposer,
      $$AppSettingsTableTableCreateCompanionBuilder,
      $$AppSettingsTableTableUpdateCompanionBuilder,
      (AppSettings, BaseReferences<_$AloftDatabase, $AppSettingsTableTable, AppSettings>),
      AppSettings,
      PrefetchHooks Function()
    >;

class $AloftDatabaseManager {
  final _$AloftDatabase _db;
  $AloftDatabaseManager(this._db);
  $$AppSettingsTableTableTableManager get appSettingsTable =>
      $$AppSettingsTableTableTableManager(_db, _db.appSettingsTable);
}
