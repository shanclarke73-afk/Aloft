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
  static const VerificationMeta _remindShotsMeta = const VerificationMeta('remindShots');
  @override
  late final GeneratedColumn<bool> remindShots = GeneratedColumn<bool>(
    'remind_shots',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("remind_shots" IN (0, 1))'),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _remindReorderMeta = const VerificationMeta('remindReorder');
  @override
  late final GeneratedColumn<bool> remindReorder = GeneratedColumn<bool>(
    'remind_reorder',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("remind_reorder" IN (0, 1))'),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _remindUseByMeta = const VerificationMeta('remindUseBy');
  @override
  late final GeneratedColumn<bool> remindUseBy = GeneratedColumn<bool>(
    'remind_use_by',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("remind_use_by" IN (0, 1))'),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    weightUnit,
    lengthUnit,
    appearance,
    appLock,
    lockAfter,
    hideInAppSwitcher,
    remindShots,
    remindReorder,
    remindUseBy,
  ];
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
    if (data.containsKey('remind_shots')) {
      context.handle(_remindShotsMeta, remindShots.isAcceptableOrUnknown(data['remind_shots']!, _remindShotsMeta));
    }
    if (data.containsKey('remind_reorder')) {
      context.handle(
        _remindReorderMeta,
        remindReorder.isAcceptableOrUnknown(data['remind_reorder']!, _remindReorderMeta),
      );
    }
    if (data.containsKey('remind_use_by')) {
      context.handle(_remindUseByMeta, remindUseBy.isAcceptableOrUnknown(data['remind_use_by']!, _remindUseByMeta));
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
      remindShots: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}remind_shots'])!,
      remindReorder: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}remind_reorder'])!,
      remindUseBy: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}remind_use_by'])!,
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
  final bool remindShots;
  final bool remindReorder;
  final bool remindUseBy;
  const AppSettings({
    required this.id,
    required this.weightUnit,
    required this.lengthUnit,
    required this.appearance,
    required this.appLock,
    required this.lockAfter,
    required this.hideInAppSwitcher,
    required this.remindShots,
    required this.remindReorder,
    required this.remindUseBy,
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
    map['remind_shots'] = Variable<bool>(remindShots);
    map['remind_reorder'] = Variable<bool>(remindReorder);
    map['remind_use_by'] = Variable<bool>(remindUseBy);
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
      remindShots: Value(remindShots),
      remindReorder: Value(remindReorder),
      remindUseBy: Value(remindUseBy),
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
      remindShots: serializer.fromJson<bool>(json['remindShots']),
      remindReorder: serializer.fromJson<bool>(json['remindReorder']),
      remindUseBy: serializer.fromJson<bool>(json['remindUseBy']),
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
      'remindShots': serializer.toJson<bool>(remindShots),
      'remindReorder': serializer.toJson<bool>(remindReorder),
      'remindUseBy': serializer.toJson<bool>(remindUseBy),
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
    bool? remindShots,
    bool? remindReorder,
    bool? remindUseBy,
  }) => AppSettings(
    id: id ?? this.id,
    weightUnit: weightUnit ?? this.weightUnit,
    lengthUnit: lengthUnit ?? this.lengthUnit,
    appearance: appearance ?? this.appearance,
    appLock: appLock ?? this.appLock,
    lockAfter: lockAfter ?? this.lockAfter,
    hideInAppSwitcher: hideInAppSwitcher ?? this.hideInAppSwitcher,
    remindShots: remindShots ?? this.remindShots,
    remindReorder: remindReorder ?? this.remindReorder,
    remindUseBy: remindUseBy ?? this.remindUseBy,
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
      remindShots: data.remindShots.present ? data.remindShots.value : this.remindShots,
      remindReorder: data.remindReorder.present ? data.remindReorder.value : this.remindReorder,
      remindUseBy: data.remindUseBy.present ? data.remindUseBy.value : this.remindUseBy,
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
          ..write('hideInAppSwitcher: $hideInAppSwitcher, ')
          ..write('remindShots: $remindShots, ')
          ..write('remindReorder: $remindReorder, ')
          ..write('remindUseBy: $remindUseBy')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    weightUnit,
    lengthUnit,
    appearance,
    appLock,
    lockAfter,
    hideInAppSwitcher,
    remindShots,
    remindReorder,
    remindUseBy,
  );
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
          other.hideInAppSwitcher == this.hideInAppSwitcher &&
          other.remindShots == this.remindShots &&
          other.remindReorder == this.remindReorder &&
          other.remindUseBy == this.remindUseBy);
}

class AppSettingsTableCompanion extends UpdateCompanion<AppSettings> {
  final Value<int> id;
  final Value<WeightUnit> weightUnit;
  final Value<LengthUnit> lengthUnit;
  final Value<Appearance> appearance;
  final Value<bool> appLock;
  final Value<LockAfter> lockAfter;
  final Value<bool> hideInAppSwitcher;
  final Value<bool> remindShots;
  final Value<bool> remindReorder;
  final Value<bool> remindUseBy;
  const AppSettingsTableCompanion({
    this.id = const Value.absent(),
    this.weightUnit = const Value.absent(),
    this.lengthUnit = const Value.absent(),
    this.appearance = const Value.absent(),
    this.appLock = const Value.absent(),
    this.lockAfter = const Value.absent(),
    this.hideInAppSwitcher = const Value.absent(),
    this.remindShots = const Value.absent(),
    this.remindReorder = const Value.absent(),
    this.remindUseBy = const Value.absent(),
  });
  AppSettingsTableCompanion.insert({
    this.id = const Value.absent(),
    required WeightUnit weightUnit,
    required LengthUnit lengthUnit,
    this.appearance = const Value.absent(),
    this.appLock = const Value.absent(),
    this.lockAfter = const Value.absent(),
    this.hideInAppSwitcher = const Value.absent(),
    this.remindShots = const Value.absent(),
    this.remindReorder = const Value.absent(),
    this.remindUseBy = const Value.absent(),
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
    Expression<bool>? remindShots,
    Expression<bool>? remindReorder,
    Expression<bool>? remindUseBy,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (weightUnit != null) 'weight_unit': weightUnit,
      if (lengthUnit != null) 'length_unit': lengthUnit,
      if (appearance != null) 'appearance': appearance,
      if (appLock != null) 'app_lock': appLock,
      if (lockAfter != null) 'lock_after': lockAfter,
      if (hideInAppSwitcher != null) 'hide_in_app_switcher': hideInAppSwitcher,
      if (remindShots != null) 'remind_shots': remindShots,
      if (remindReorder != null) 'remind_reorder': remindReorder,
      if (remindUseBy != null) 'remind_use_by': remindUseBy,
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
    Value<bool>? remindShots,
    Value<bool>? remindReorder,
    Value<bool>? remindUseBy,
  }) {
    return AppSettingsTableCompanion(
      id: id ?? this.id,
      weightUnit: weightUnit ?? this.weightUnit,
      lengthUnit: lengthUnit ?? this.lengthUnit,
      appearance: appearance ?? this.appearance,
      appLock: appLock ?? this.appLock,
      lockAfter: lockAfter ?? this.lockAfter,
      hideInAppSwitcher: hideInAppSwitcher ?? this.hideInAppSwitcher,
      remindShots: remindShots ?? this.remindShots,
      remindReorder: remindReorder ?? this.remindReorder,
      remindUseBy: remindUseBy ?? this.remindUseBy,
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
    if (remindShots.present) {
      map['remind_shots'] = Variable<bool>(remindShots.value);
    }
    if (remindReorder.present) {
      map['remind_reorder'] = Variable<bool>(remindReorder.value);
    }
    if (remindUseBy.present) {
      map['remind_use_by'] = Variable<bool>(remindUseBy.value);
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
          ..write('hideInAppSwitcher: $hideInAppSwitcher, ')
          ..write('remindShots: $remindShots, ')
          ..write('remindReorder: $remindReorder, ')
          ..write('remindUseBy: $remindUseBy')
          ..write(')'))
        .toString();
  }
}

class $MedicationsTable extends Medications with TableInfo<$MedicationsTable, Medication> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MedicationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: newId,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
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
  static const VerificationMeta _activeIngredientMeta = const VerificationMeta('activeIngredient');
  @override
  late final GeneratedColumn<String> activeIngredient = GeneratedColumn<String>(
    'active_ingredient',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isGlp1Meta = const VerificationMeta('isGlp1');
  @override
  late final GeneratedColumn<bool> isGlp1 = GeneratedColumn<bool>(
    'is_glp1',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("is_glp1" IN (0, 1))'),
  );
  @override
  late final GeneratedColumnWithTypeConverter<MedicationForm, String> form = GeneratedColumn<String>(
    'form',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<MedicationForm>($MedicationsTable.$converterform);
  @override
  late final GeneratedColumnWithTypeConverter<MedicationStatus, String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('active'),
  ).withConverter<MedicationStatus>($MedicationsTable.$converterstatus);
  static const VerificationMeta _halfLifeHoursMeta = const VerificationMeta('halfLifeHours');
  @override
  late final GeneratedColumn<double> halfLifeHours = GeneratedColumn<double>(
    'half_life_hours',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tmaxHoursMeta = const VerificationMeta('tmaxHours');
  @override
  late final GeneratedColumn<double> tmaxHours = GeneratedColumn<double>(
    'tmax_hours',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ScheduleType, String> scheduleType = GeneratedColumn<String>(
    'schedule_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<ScheduleType>($MedicationsTable.$converterscheduleType);
  @override
  late final GeneratedColumnWithTypeConverter<List<int>, String> scheduleDays = GeneratedColumn<String>(
    'schedule_days',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  ).withConverter<List<int>>($MedicationsTable.$converterscheduleDays);
  static const VerificationMeta _scheduleIntervalMeta = const VerificationMeta('scheduleInterval');
  @override
  late final GeneratedColumn<int> scheduleInterval = GeneratedColumn<int>(
    'schedule_interval',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timeOfDayMinutesMeta = const VerificationMeta('timeOfDayMinutes');
  @override
  late final GeneratedColumn<int> timeOfDayMinutes = GeneratedColumn<int>(
    'time_of_day_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta('startDate');
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    name,
    activeIngredient,
    isGlp1,
    form,
    status,
    halfLifeHours,
    tmaxHours,
    scheduleType,
    scheduleDays,
    scheduleInterval,
    timeOfDayMinutes,
    startDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'medications';
  @override
  VerificationContext validateIntegrity(Insertable<Medication> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta, updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('name')) {
      context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('active_ingredient')) {
      context.handle(
        _activeIngredientMeta,
        activeIngredient.isAcceptableOrUnknown(data['active_ingredient']!, _activeIngredientMeta),
      );
    } else if (isInserting) {
      context.missing(_activeIngredientMeta);
    }
    if (data.containsKey('is_glp1')) {
      context.handle(_isGlp1Meta, isGlp1.isAcceptableOrUnknown(data['is_glp1']!, _isGlp1Meta));
    } else if (isInserting) {
      context.missing(_isGlp1Meta);
    }
    if (data.containsKey('half_life_hours')) {
      context.handle(
        _halfLifeHoursMeta,
        halfLifeHours.isAcceptableOrUnknown(data['half_life_hours']!, _halfLifeHoursMeta),
      );
    }
    if (data.containsKey('tmax_hours')) {
      context.handle(_tmaxHoursMeta, tmaxHours.isAcceptableOrUnknown(data['tmax_hours']!, _tmaxHoursMeta));
    }
    if (data.containsKey('schedule_interval')) {
      context.handle(
        _scheduleIntervalMeta,
        scheduleInterval.isAcceptableOrUnknown(data['schedule_interval']!, _scheduleIntervalMeta),
      );
    }
    if (data.containsKey('time_of_day_minutes')) {
      context.handle(
        _timeOfDayMinutesMeta,
        timeOfDayMinutes.isAcceptableOrUnknown(data['time_of_day_minutes']!, _timeOfDayMinutesMeta),
      );
    }
    if (data.containsKey('start_date')) {
      context.handle(_startDateMeta, startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta));
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Medication map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Medication(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      name: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      activeIngredient: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}active_ingredient'],
      )!,
      isGlp1: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}is_glp1'])!,
      form: $MedicationsTable.$converterform.fromSql(
        attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}form'])!,
      ),
      status: $MedicationsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      ),
      halfLifeHours: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}half_life_hours']),
      tmaxHours: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}tmax_hours']),
      scheduleType: $MedicationsTable.$converterscheduleType.fromSql(
        attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}schedule_type'])!,
      ),
      scheduleDays: $MedicationsTable.$converterscheduleDays.fromSql(
        attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}schedule_days'])!,
      ),
      scheduleInterval: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}schedule_interval'],
      ),
      timeOfDayMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_of_day_minutes'],
      ),
      startDate: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}start_date'])!,
    );
  }

  @override
  $MedicationsTable createAlias(String alias) {
    return $MedicationsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<MedicationForm, String, String> $converterform = const EnumNameConverter<MedicationForm>(
    MedicationForm.values,
  );
  static JsonTypeConverter2<MedicationStatus, String, String> $converterstatus =
      const EnumNameConverter<MedicationStatus>(MedicationStatus.values);
  static JsonTypeConverter2<ScheduleType, String, String> $converterscheduleType =
      const EnumNameConverter<ScheduleType>(ScheduleType.values);
  static TypeConverter<List<int>, String> $converterscheduleDays = const IntListConverter();
}

class Medication extends DataClass implements Insertable<Medication> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String name;

  /// Lower-case ingredient, e.g. "tirzepatide". Shots of the same ingredient share a level curve.
  final String activeIngredient;
  final bool isGlp1;
  final MedicationForm form;
  final MedicationStatus status;
  final double? halfLifeHours;
  final double? tmaxHours;
  final ScheduleType scheduleType;
  final List<int> scheduleDays;
  final int? scheduleInterval;

  /// Minutes after midnight for the dose time. Null for "as needed".
  final int? timeOfDayMinutes;
  final DateTime startDate;
  const Medication({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.name,
    required this.activeIngredient,
    required this.isGlp1,
    required this.form,
    required this.status,
    this.halfLifeHours,
    this.tmaxHours,
    required this.scheduleType,
    required this.scheduleDays,
    this.scheduleInterval,
    this.timeOfDayMinutes,
    required this.startDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['name'] = Variable<String>(name);
    map['active_ingredient'] = Variable<String>(activeIngredient);
    map['is_glp1'] = Variable<bool>(isGlp1);
    {
      map['form'] = Variable<String>($MedicationsTable.$converterform.toSql(form));
    }
    {
      map['status'] = Variable<String>($MedicationsTable.$converterstatus.toSql(status));
    }
    if (!nullToAbsent || halfLifeHours != null) {
      map['half_life_hours'] = Variable<double>(halfLifeHours);
    }
    if (!nullToAbsent || tmaxHours != null) {
      map['tmax_hours'] = Variable<double>(tmaxHours);
    }
    {
      map['schedule_type'] = Variable<String>($MedicationsTable.$converterscheduleType.toSql(scheduleType));
    }
    {
      map['schedule_days'] = Variable<String>($MedicationsTable.$converterscheduleDays.toSql(scheduleDays));
    }
    if (!nullToAbsent || scheduleInterval != null) {
      map['schedule_interval'] = Variable<int>(scheduleInterval);
    }
    if (!nullToAbsent || timeOfDayMinutes != null) {
      map['time_of_day_minutes'] = Variable<int>(timeOfDayMinutes);
    }
    map['start_date'] = Variable<DateTime>(startDate);
    return map;
  }

  MedicationsCompanion toCompanion(bool nullToAbsent) {
    return MedicationsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      name: Value(name),
      activeIngredient: Value(activeIngredient),
      isGlp1: Value(isGlp1),
      form: Value(form),
      status: Value(status),
      halfLifeHours: halfLifeHours == null && nullToAbsent ? const Value.absent() : Value(halfLifeHours),
      tmaxHours: tmaxHours == null && nullToAbsent ? const Value.absent() : Value(tmaxHours),
      scheduleType: Value(scheduleType),
      scheduleDays: Value(scheduleDays),
      scheduleInterval: scheduleInterval == null && nullToAbsent ? const Value.absent() : Value(scheduleInterval),
      timeOfDayMinutes: timeOfDayMinutes == null && nullToAbsent ? const Value.absent() : Value(timeOfDayMinutes),
      startDate: Value(startDate),
    );
  }

  factory Medication.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Medication(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      name: serializer.fromJson<String>(json['name']),
      activeIngredient: serializer.fromJson<String>(json['activeIngredient']),
      isGlp1: serializer.fromJson<bool>(json['isGlp1']),
      form: $MedicationsTable.$converterform.fromJson(serializer.fromJson<String>(json['form'])),
      status: $MedicationsTable.$converterstatus.fromJson(serializer.fromJson<String>(json['status'])),
      halfLifeHours: serializer.fromJson<double?>(json['halfLifeHours']),
      tmaxHours: serializer.fromJson<double?>(json['tmaxHours']),
      scheduleType: $MedicationsTable.$converterscheduleType.fromJson(
        serializer.fromJson<String>(json['scheduleType']),
      ),
      scheduleDays: serializer.fromJson<List<int>>(json['scheduleDays']),
      scheduleInterval: serializer.fromJson<int?>(json['scheduleInterval']),
      timeOfDayMinutes: serializer.fromJson<int?>(json['timeOfDayMinutes']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'name': serializer.toJson<String>(name),
      'activeIngredient': serializer.toJson<String>(activeIngredient),
      'isGlp1': serializer.toJson<bool>(isGlp1),
      'form': serializer.toJson<String>($MedicationsTable.$converterform.toJson(form)),
      'status': serializer.toJson<String>($MedicationsTable.$converterstatus.toJson(status)),
      'halfLifeHours': serializer.toJson<double?>(halfLifeHours),
      'tmaxHours': serializer.toJson<double?>(tmaxHours),
      'scheduleType': serializer.toJson<String>($MedicationsTable.$converterscheduleType.toJson(scheduleType)),
      'scheduleDays': serializer.toJson<List<int>>(scheduleDays),
      'scheduleInterval': serializer.toJson<int?>(scheduleInterval),
      'timeOfDayMinutes': serializer.toJson<int?>(timeOfDayMinutes),
      'startDate': serializer.toJson<DateTime>(startDate),
    };
  }

  Medication copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? name,
    String? activeIngredient,
    bool? isGlp1,
    MedicationForm? form,
    MedicationStatus? status,
    Value<double?> halfLifeHours = const Value.absent(),
    Value<double?> tmaxHours = const Value.absent(),
    ScheduleType? scheduleType,
    List<int>? scheduleDays,
    Value<int?> scheduleInterval = const Value.absent(),
    Value<int?> timeOfDayMinutes = const Value.absent(),
    DateTime? startDate,
  }) => Medication(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    name: name ?? this.name,
    activeIngredient: activeIngredient ?? this.activeIngredient,
    isGlp1: isGlp1 ?? this.isGlp1,
    form: form ?? this.form,
    status: status ?? this.status,
    halfLifeHours: halfLifeHours.present ? halfLifeHours.value : this.halfLifeHours,
    tmaxHours: tmaxHours.present ? tmaxHours.value : this.tmaxHours,
    scheduleType: scheduleType ?? this.scheduleType,
    scheduleDays: scheduleDays ?? this.scheduleDays,
    scheduleInterval: scheduleInterval.present ? scheduleInterval.value : this.scheduleInterval,
    timeOfDayMinutes: timeOfDayMinutes.present ? timeOfDayMinutes.value : this.timeOfDayMinutes,
    startDate: startDate ?? this.startDate,
  );
  Medication copyWithCompanion(MedicationsCompanion data) {
    return Medication(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      name: data.name.present ? data.name.value : this.name,
      activeIngredient: data.activeIngredient.present ? data.activeIngredient.value : this.activeIngredient,
      isGlp1: data.isGlp1.present ? data.isGlp1.value : this.isGlp1,
      form: data.form.present ? data.form.value : this.form,
      status: data.status.present ? data.status.value : this.status,
      halfLifeHours: data.halfLifeHours.present ? data.halfLifeHours.value : this.halfLifeHours,
      tmaxHours: data.tmaxHours.present ? data.tmaxHours.value : this.tmaxHours,
      scheduleType: data.scheduleType.present ? data.scheduleType.value : this.scheduleType,
      scheduleDays: data.scheduleDays.present ? data.scheduleDays.value : this.scheduleDays,
      scheduleInterval: data.scheduleInterval.present ? data.scheduleInterval.value : this.scheduleInterval,
      timeOfDayMinutes: data.timeOfDayMinutes.present ? data.timeOfDayMinutes.value : this.timeOfDayMinutes,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Medication(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('name: $name, ')
          ..write('activeIngredient: $activeIngredient, ')
          ..write('isGlp1: $isGlp1, ')
          ..write('form: $form, ')
          ..write('status: $status, ')
          ..write('halfLifeHours: $halfLifeHours, ')
          ..write('tmaxHours: $tmaxHours, ')
          ..write('scheduleType: $scheduleType, ')
          ..write('scheduleDays: $scheduleDays, ')
          ..write('scheduleInterval: $scheduleInterval, ')
          ..write('timeOfDayMinutes: $timeOfDayMinutes, ')
          ..write('startDate: $startDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    name,
    activeIngredient,
    isGlp1,
    form,
    status,
    halfLifeHours,
    tmaxHours,
    scheduleType,
    scheduleDays,
    scheduleInterval,
    timeOfDayMinutes,
    startDate,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Medication &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.name == this.name &&
          other.activeIngredient == this.activeIngredient &&
          other.isGlp1 == this.isGlp1 &&
          other.form == this.form &&
          other.status == this.status &&
          other.halfLifeHours == this.halfLifeHours &&
          other.tmaxHours == this.tmaxHours &&
          other.scheduleType == this.scheduleType &&
          other.scheduleDays == this.scheduleDays &&
          other.scheduleInterval == this.scheduleInterval &&
          other.timeOfDayMinutes == this.timeOfDayMinutes &&
          other.startDate == this.startDate);
}

class MedicationsCompanion extends UpdateCompanion<Medication> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> name;
  final Value<String> activeIngredient;
  final Value<bool> isGlp1;
  final Value<MedicationForm> form;
  final Value<MedicationStatus> status;
  final Value<double?> halfLifeHours;
  final Value<double?> tmaxHours;
  final Value<ScheduleType> scheduleType;
  final Value<List<int>> scheduleDays;
  final Value<int?> scheduleInterval;
  final Value<int?> timeOfDayMinutes;
  final Value<DateTime> startDate;
  final Value<int> rowid;
  const MedicationsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.name = const Value.absent(),
    this.activeIngredient = const Value.absent(),
    this.isGlp1 = const Value.absent(),
    this.form = const Value.absent(),
    this.status = const Value.absent(),
    this.halfLifeHours = const Value.absent(),
    this.tmaxHours = const Value.absent(),
    this.scheduleType = const Value.absent(),
    this.scheduleDays = const Value.absent(),
    this.scheduleInterval = const Value.absent(),
    this.timeOfDayMinutes = const Value.absent(),
    this.startDate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MedicationsCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required String name,
    required String activeIngredient,
    required bool isGlp1,
    required MedicationForm form,
    this.status = const Value.absent(),
    this.halfLifeHours = const Value.absent(),
    this.tmaxHours = const Value.absent(),
    required ScheduleType scheduleType,
    this.scheduleDays = const Value.absent(),
    this.scheduleInterval = const Value.absent(),
    this.timeOfDayMinutes = const Value.absent(),
    required DateTime startDate,
    this.rowid = const Value.absent(),
  }) : name = Value(name),
       activeIngredient = Value(activeIngredient),
       isGlp1 = Value(isGlp1),
       form = Value(form),
       scheduleType = Value(scheduleType),
       startDate = Value(startDate);
  static Insertable<Medication> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? name,
    Expression<String>? activeIngredient,
    Expression<bool>? isGlp1,
    Expression<String>? form,
    Expression<String>? status,
    Expression<double>? halfLifeHours,
    Expression<double>? tmaxHours,
    Expression<String>? scheduleType,
    Expression<String>? scheduleDays,
    Expression<int>? scheduleInterval,
    Expression<int>? timeOfDayMinutes,
    Expression<DateTime>? startDate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (name != null) 'name': name,
      if (activeIngredient != null) 'active_ingredient': activeIngredient,
      if (isGlp1 != null) 'is_glp1': isGlp1,
      if (form != null) 'form': form,
      if (status != null) 'status': status,
      if (halfLifeHours != null) 'half_life_hours': halfLifeHours,
      if (tmaxHours != null) 'tmax_hours': tmaxHours,
      if (scheduleType != null) 'schedule_type': scheduleType,
      if (scheduleDays != null) 'schedule_days': scheduleDays,
      if (scheduleInterval != null) 'schedule_interval': scheduleInterval,
      if (timeOfDayMinutes != null) 'time_of_day_minutes': timeOfDayMinutes,
      if (startDate != null) 'start_date': startDate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MedicationsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? name,
    Value<String>? activeIngredient,
    Value<bool>? isGlp1,
    Value<MedicationForm>? form,
    Value<MedicationStatus>? status,
    Value<double?>? halfLifeHours,
    Value<double?>? tmaxHours,
    Value<ScheduleType>? scheduleType,
    Value<List<int>>? scheduleDays,
    Value<int?>? scheduleInterval,
    Value<int?>? timeOfDayMinutes,
    Value<DateTime>? startDate,
    Value<int>? rowid,
  }) {
    return MedicationsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      name: name ?? this.name,
      activeIngredient: activeIngredient ?? this.activeIngredient,
      isGlp1: isGlp1 ?? this.isGlp1,
      form: form ?? this.form,
      status: status ?? this.status,
      halfLifeHours: halfLifeHours ?? this.halfLifeHours,
      tmaxHours: tmaxHours ?? this.tmaxHours,
      scheduleType: scheduleType ?? this.scheduleType,
      scheduleDays: scheduleDays ?? this.scheduleDays,
      scheduleInterval: scheduleInterval ?? this.scheduleInterval,
      timeOfDayMinutes: timeOfDayMinutes ?? this.timeOfDayMinutes,
      startDate: startDate ?? this.startDate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (activeIngredient.present) {
      map['active_ingredient'] = Variable<String>(activeIngredient.value);
    }
    if (isGlp1.present) {
      map['is_glp1'] = Variable<bool>(isGlp1.value);
    }
    if (form.present) {
      map['form'] = Variable<String>($MedicationsTable.$converterform.toSql(form.value));
    }
    if (status.present) {
      map['status'] = Variable<String>($MedicationsTable.$converterstatus.toSql(status.value));
    }
    if (halfLifeHours.present) {
      map['half_life_hours'] = Variable<double>(halfLifeHours.value);
    }
    if (tmaxHours.present) {
      map['tmax_hours'] = Variable<double>(tmaxHours.value);
    }
    if (scheduleType.present) {
      map['schedule_type'] = Variable<String>($MedicationsTable.$converterscheduleType.toSql(scheduleType.value));
    }
    if (scheduleDays.present) {
      map['schedule_days'] = Variable<String>($MedicationsTable.$converterscheduleDays.toSql(scheduleDays.value));
    }
    if (scheduleInterval.present) {
      map['schedule_interval'] = Variable<int>(scheduleInterval.value);
    }
    if (timeOfDayMinutes.present) {
      map['time_of_day_minutes'] = Variable<int>(timeOfDayMinutes.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MedicationsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('name: $name, ')
          ..write('activeIngredient: $activeIngredient, ')
          ..write('isGlp1: $isGlp1, ')
          ..write('form: $form, ')
          ..write('status: $status, ')
          ..write('halfLifeHours: $halfLifeHours, ')
          ..write('tmaxHours: $tmaxHours, ')
          ..write('scheduleType: $scheduleType, ')
          ..write('scheduleDays: $scheduleDays, ')
          ..write('scheduleInterval: $scheduleInterval, ')
          ..write('timeOfDayMinutes: $timeOfDayMinutes, ')
          ..write('startDate: $startDate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SuppliesTable extends Supplies with TableInfo<$SuppliesTable, Supply> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SuppliesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: newId,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _medicationIdMeta = const VerificationMeta('medicationId');
  @override
  late final GeneratedColumn<String> medicationId = GeneratedColumn<String>(
    'medication_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES medications (id) ON DELETE CASCADE'),
  );
  static const VerificationMeta _concentrationMgPerMlMeta = const VerificationMeta('concentrationMgPerMl');
  @override
  late final GeneratedColumn<double> concentrationMgPerMl = GeneratedColumn<double>(
    'concentration_mg_per_ml',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _penDoseMgMeta = const VerificationMeta('penDoseMg');
  @override
  late final GeneratedColumn<double> penDoseMg = GeneratedColumn<double>(
    'pen_dose_mg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pillStrengthMgMeta = const VerificationMeta('pillStrengthMg');
  @override
  late final GeneratedColumn<double> pillStrengthMg = GeneratedColumn<double>(
    'pill_strength_mg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<Additive>, String> additives = GeneratedColumn<String>(
    'additives',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  ).withConverter<List<Additive>>($SuppliesTable.$converteradditives);
  static const VerificationMeta _volumeMlMeta = const VerificationMeta('volumeMl');
  @override
  late final GeneratedColumn<double> volumeMl = GeneratedColumn<double>(
    'volume_ml',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lostMlMeta = const VerificationMeta('lostMl');
  @override
  late final GeneratedColumn<double> lostMl = GeneratedColumn<double>(
    'lost_ml',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _pillCountMeta = const VerificationMeta('pillCount');
  @override
  late final GeneratedColumn<double> pillCount = GeneratedColumn<double>(
    'pill_count',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pharmacyMeta = const VerificationMeta('pharmacy');
  @override
  late final GeneratedColumn<String> pharmacy = GeneratedColumn<String>(
    'pharmacy',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lotNumberMeta = const VerificationMeta('lotNumber');
  @override
  late final GeneratedColumn<String> lotNumber = GeneratedColumn<String>(
    'lot_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateOpenedMeta = const VerificationMeta('dateOpened');
  @override
  late final GeneratedColumn<DateTime> dateOpened = GeneratedColumn<DateTime>(
    'date_opened',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _beyondUseDateMeta = const VerificationMeta('beyondUseDate');
  @override
  late final GeneratedColumn<DateTime> beyondUseDate = GeneratedColumn<DateTime>(
    'beyond_use_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _costMeta = const VerificationMeta('cost');
  @override
  late final GeneratedColumn<double> cost = GeneratedColumn<double>(
    'cost',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SupplyStatus, String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('active'),
  ).withConverter<SupplyStatus>($SuppliesTable.$converterstatus);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    medicationId,
    concentrationMgPerMl,
    penDoseMg,
    pillStrengthMg,
    additives,
    volumeMl,
    lostMl,
    pillCount,
    pharmacy,
    lotNumber,
    dateOpened,
    beyondUseDate,
    cost,
    status,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'supplies';
  @override
  VerificationContext validateIntegrity(Insertable<Supply> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta, updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('medication_id')) {
      context.handle(_medicationIdMeta, medicationId.isAcceptableOrUnknown(data['medication_id']!, _medicationIdMeta));
    } else if (isInserting) {
      context.missing(_medicationIdMeta);
    }
    if (data.containsKey('concentration_mg_per_ml')) {
      context.handle(
        _concentrationMgPerMlMeta,
        concentrationMgPerMl.isAcceptableOrUnknown(data['concentration_mg_per_ml']!, _concentrationMgPerMlMeta),
      );
    }
    if (data.containsKey('pen_dose_mg')) {
      context.handle(_penDoseMgMeta, penDoseMg.isAcceptableOrUnknown(data['pen_dose_mg']!, _penDoseMgMeta));
    }
    if (data.containsKey('pill_strength_mg')) {
      context.handle(
        _pillStrengthMgMeta,
        pillStrengthMg.isAcceptableOrUnknown(data['pill_strength_mg']!, _pillStrengthMgMeta),
      );
    }
    if (data.containsKey('volume_ml')) {
      context.handle(_volumeMlMeta, volumeMl.isAcceptableOrUnknown(data['volume_ml']!, _volumeMlMeta));
    }
    if (data.containsKey('lost_ml')) {
      context.handle(_lostMlMeta, lostMl.isAcceptableOrUnknown(data['lost_ml']!, _lostMlMeta));
    }
    if (data.containsKey('pill_count')) {
      context.handle(_pillCountMeta, pillCount.isAcceptableOrUnknown(data['pill_count']!, _pillCountMeta));
    }
    if (data.containsKey('pharmacy')) {
      context.handle(_pharmacyMeta, pharmacy.isAcceptableOrUnknown(data['pharmacy']!, _pharmacyMeta));
    }
    if (data.containsKey('lot_number')) {
      context.handle(_lotNumberMeta, lotNumber.isAcceptableOrUnknown(data['lot_number']!, _lotNumberMeta));
    }
    if (data.containsKey('date_opened')) {
      context.handle(_dateOpenedMeta, dateOpened.isAcceptableOrUnknown(data['date_opened']!, _dateOpenedMeta));
    }
    if (data.containsKey('beyond_use_date')) {
      context.handle(
        _beyondUseDateMeta,
        beyondUseDate.isAcceptableOrUnknown(data['beyond_use_date']!, _beyondUseDateMeta),
      );
    }
    if (data.containsKey('cost')) {
      context.handle(_costMeta, cost.isAcceptableOrUnknown(data['cost']!, _costMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Supply map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Supply(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      medicationId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}medication_id'])!,
      concentrationMgPerMl: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}concentration_mg_per_ml'],
      ),
      penDoseMg: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}pen_dose_mg']),
      pillStrengthMg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}pill_strength_mg'],
      ),
      additives: $SuppliesTable.$converteradditives.fromSql(
        attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}additives'])!,
      ),
      volumeMl: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}volume_ml']),
      lostMl: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}lost_ml'])!,
      pillCount: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}pill_count']),
      pharmacy: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}pharmacy']),
      lotNumber: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}lot_number']),
      dateOpened: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}date_opened']),
      beyondUseDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}beyond_use_date'],
      ),
      cost: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}cost']),
      status: $SuppliesTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      ),
    );
  }

  @override
  $SuppliesTable createAlias(String alias) {
    return $SuppliesTable(attachedDatabase, alias);
  }

  static TypeConverter<List<Additive>, String> $converteradditives = const AdditivesConverter();
  static JsonTypeConverter2<SupplyStatus, String, String> $converterstatus = const EnumNameConverter<SupplyStatus>(
    SupplyStatus.values,
  );
}

class Supply extends DataClass implements Insertable<Supply> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String medicationId;
  final double? concentrationMgPerMl;
  final double? penDoseMg;
  final double? pillStrengthMg;
  final List<Additive> additives;
  final double? volumeMl;

  /// Volume lost to spills or priming, set by "Adjust what's left".
  final double lostMl;
  final double? pillCount;
  final String? pharmacy;
  final String? lotNumber;
  final DateTime? dateOpened;
  final DateTime? beyondUseDate;
  final double? cost;
  final SupplyStatus status;
  const Supply({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.medicationId,
    this.concentrationMgPerMl,
    this.penDoseMg,
    this.pillStrengthMg,
    required this.additives,
    this.volumeMl,
    required this.lostMl,
    this.pillCount,
    this.pharmacy,
    this.lotNumber,
    this.dateOpened,
    this.beyondUseDate,
    this.cost,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['medication_id'] = Variable<String>(medicationId);
    if (!nullToAbsent || concentrationMgPerMl != null) {
      map['concentration_mg_per_ml'] = Variable<double>(concentrationMgPerMl);
    }
    if (!nullToAbsent || penDoseMg != null) {
      map['pen_dose_mg'] = Variable<double>(penDoseMg);
    }
    if (!nullToAbsent || pillStrengthMg != null) {
      map['pill_strength_mg'] = Variable<double>(pillStrengthMg);
    }
    {
      map['additives'] = Variable<String>($SuppliesTable.$converteradditives.toSql(additives));
    }
    if (!nullToAbsent || volumeMl != null) {
      map['volume_ml'] = Variable<double>(volumeMl);
    }
    map['lost_ml'] = Variable<double>(lostMl);
    if (!nullToAbsent || pillCount != null) {
      map['pill_count'] = Variable<double>(pillCount);
    }
    if (!nullToAbsent || pharmacy != null) {
      map['pharmacy'] = Variable<String>(pharmacy);
    }
    if (!nullToAbsent || lotNumber != null) {
      map['lot_number'] = Variable<String>(lotNumber);
    }
    if (!nullToAbsent || dateOpened != null) {
      map['date_opened'] = Variable<DateTime>(dateOpened);
    }
    if (!nullToAbsent || beyondUseDate != null) {
      map['beyond_use_date'] = Variable<DateTime>(beyondUseDate);
    }
    if (!nullToAbsent || cost != null) {
      map['cost'] = Variable<double>(cost);
    }
    {
      map['status'] = Variable<String>($SuppliesTable.$converterstatus.toSql(status));
    }
    return map;
  }

  SuppliesCompanion toCompanion(bool nullToAbsent) {
    return SuppliesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      medicationId: Value(medicationId),
      concentrationMgPerMl: concentrationMgPerMl == null && nullToAbsent
          ? const Value.absent()
          : Value(concentrationMgPerMl),
      penDoseMg: penDoseMg == null && nullToAbsent ? const Value.absent() : Value(penDoseMg),
      pillStrengthMg: pillStrengthMg == null && nullToAbsent ? const Value.absent() : Value(pillStrengthMg),
      additives: Value(additives),
      volumeMl: volumeMl == null && nullToAbsent ? const Value.absent() : Value(volumeMl),
      lostMl: Value(lostMl),
      pillCount: pillCount == null && nullToAbsent ? const Value.absent() : Value(pillCount),
      pharmacy: pharmacy == null && nullToAbsent ? const Value.absent() : Value(pharmacy),
      lotNumber: lotNumber == null && nullToAbsent ? const Value.absent() : Value(lotNumber),
      dateOpened: dateOpened == null && nullToAbsent ? const Value.absent() : Value(dateOpened),
      beyondUseDate: beyondUseDate == null && nullToAbsent ? const Value.absent() : Value(beyondUseDate),
      cost: cost == null && nullToAbsent ? const Value.absent() : Value(cost),
      status: Value(status),
    );
  }

  factory Supply.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Supply(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      medicationId: serializer.fromJson<String>(json['medicationId']),
      concentrationMgPerMl: serializer.fromJson<double?>(json['concentrationMgPerMl']),
      penDoseMg: serializer.fromJson<double?>(json['penDoseMg']),
      pillStrengthMg: serializer.fromJson<double?>(json['pillStrengthMg']),
      additives: serializer.fromJson<List<Additive>>(json['additives']),
      volumeMl: serializer.fromJson<double?>(json['volumeMl']),
      lostMl: serializer.fromJson<double>(json['lostMl']),
      pillCount: serializer.fromJson<double?>(json['pillCount']),
      pharmacy: serializer.fromJson<String?>(json['pharmacy']),
      lotNumber: serializer.fromJson<String?>(json['lotNumber']),
      dateOpened: serializer.fromJson<DateTime?>(json['dateOpened']),
      beyondUseDate: serializer.fromJson<DateTime?>(json['beyondUseDate']),
      cost: serializer.fromJson<double?>(json['cost']),
      status: $SuppliesTable.$converterstatus.fromJson(serializer.fromJson<String>(json['status'])),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'medicationId': serializer.toJson<String>(medicationId),
      'concentrationMgPerMl': serializer.toJson<double?>(concentrationMgPerMl),
      'penDoseMg': serializer.toJson<double?>(penDoseMg),
      'pillStrengthMg': serializer.toJson<double?>(pillStrengthMg),
      'additives': serializer.toJson<List<Additive>>(additives),
      'volumeMl': serializer.toJson<double?>(volumeMl),
      'lostMl': serializer.toJson<double>(lostMl),
      'pillCount': serializer.toJson<double?>(pillCount),
      'pharmacy': serializer.toJson<String?>(pharmacy),
      'lotNumber': serializer.toJson<String?>(lotNumber),
      'dateOpened': serializer.toJson<DateTime?>(dateOpened),
      'beyondUseDate': serializer.toJson<DateTime?>(beyondUseDate),
      'cost': serializer.toJson<double?>(cost),
      'status': serializer.toJson<String>($SuppliesTable.$converterstatus.toJson(status)),
    };
  }

  Supply copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? medicationId,
    Value<double?> concentrationMgPerMl = const Value.absent(),
    Value<double?> penDoseMg = const Value.absent(),
    Value<double?> pillStrengthMg = const Value.absent(),
    List<Additive>? additives,
    Value<double?> volumeMl = const Value.absent(),
    double? lostMl,
    Value<double?> pillCount = const Value.absent(),
    Value<String?> pharmacy = const Value.absent(),
    Value<String?> lotNumber = const Value.absent(),
    Value<DateTime?> dateOpened = const Value.absent(),
    Value<DateTime?> beyondUseDate = const Value.absent(),
    Value<double?> cost = const Value.absent(),
    SupplyStatus? status,
  }) => Supply(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    medicationId: medicationId ?? this.medicationId,
    concentrationMgPerMl: concentrationMgPerMl.present ? concentrationMgPerMl.value : this.concentrationMgPerMl,
    penDoseMg: penDoseMg.present ? penDoseMg.value : this.penDoseMg,
    pillStrengthMg: pillStrengthMg.present ? pillStrengthMg.value : this.pillStrengthMg,
    additives: additives ?? this.additives,
    volumeMl: volumeMl.present ? volumeMl.value : this.volumeMl,
    lostMl: lostMl ?? this.lostMl,
    pillCount: pillCount.present ? pillCount.value : this.pillCount,
    pharmacy: pharmacy.present ? pharmacy.value : this.pharmacy,
    lotNumber: lotNumber.present ? lotNumber.value : this.lotNumber,
    dateOpened: dateOpened.present ? dateOpened.value : this.dateOpened,
    beyondUseDate: beyondUseDate.present ? beyondUseDate.value : this.beyondUseDate,
    cost: cost.present ? cost.value : this.cost,
    status: status ?? this.status,
  );
  Supply copyWithCompanion(SuppliesCompanion data) {
    return Supply(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      medicationId: data.medicationId.present ? data.medicationId.value : this.medicationId,
      concentrationMgPerMl: data.concentrationMgPerMl.present
          ? data.concentrationMgPerMl.value
          : this.concentrationMgPerMl,
      penDoseMg: data.penDoseMg.present ? data.penDoseMg.value : this.penDoseMg,
      pillStrengthMg: data.pillStrengthMg.present ? data.pillStrengthMg.value : this.pillStrengthMg,
      additives: data.additives.present ? data.additives.value : this.additives,
      volumeMl: data.volumeMl.present ? data.volumeMl.value : this.volumeMl,
      lostMl: data.lostMl.present ? data.lostMl.value : this.lostMl,
      pillCount: data.pillCount.present ? data.pillCount.value : this.pillCount,
      pharmacy: data.pharmacy.present ? data.pharmacy.value : this.pharmacy,
      lotNumber: data.lotNumber.present ? data.lotNumber.value : this.lotNumber,
      dateOpened: data.dateOpened.present ? data.dateOpened.value : this.dateOpened,
      beyondUseDate: data.beyondUseDate.present ? data.beyondUseDate.value : this.beyondUseDate,
      cost: data.cost.present ? data.cost.value : this.cost,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Supply(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('medicationId: $medicationId, ')
          ..write('concentrationMgPerMl: $concentrationMgPerMl, ')
          ..write('penDoseMg: $penDoseMg, ')
          ..write('pillStrengthMg: $pillStrengthMg, ')
          ..write('additives: $additives, ')
          ..write('volumeMl: $volumeMl, ')
          ..write('lostMl: $lostMl, ')
          ..write('pillCount: $pillCount, ')
          ..write('pharmacy: $pharmacy, ')
          ..write('lotNumber: $lotNumber, ')
          ..write('dateOpened: $dateOpened, ')
          ..write('beyondUseDate: $beyondUseDate, ')
          ..write('cost: $cost, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    medicationId,
    concentrationMgPerMl,
    penDoseMg,
    pillStrengthMg,
    additives,
    volumeMl,
    lostMl,
    pillCount,
    pharmacy,
    lotNumber,
    dateOpened,
    beyondUseDate,
    cost,
    status,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Supply &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.medicationId == this.medicationId &&
          other.concentrationMgPerMl == this.concentrationMgPerMl &&
          other.penDoseMg == this.penDoseMg &&
          other.pillStrengthMg == this.pillStrengthMg &&
          other.additives == this.additives &&
          other.volumeMl == this.volumeMl &&
          other.lostMl == this.lostMl &&
          other.pillCount == this.pillCount &&
          other.pharmacy == this.pharmacy &&
          other.lotNumber == this.lotNumber &&
          other.dateOpened == this.dateOpened &&
          other.beyondUseDate == this.beyondUseDate &&
          other.cost == this.cost &&
          other.status == this.status);
}

class SuppliesCompanion extends UpdateCompanion<Supply> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> medicationId;
  final Value<double?> concentrationMgPerMl;
  final Value<double?> penDoseMg;
  final Value<double?> pillStrengthMg;
  final Value<List<Additive>> additives;
  final Value<double?> volumeMl;
  final Value<double> lostMl;
  final Value<double?> pillCount;
  final Value<String?> pharmacy;
  final Value<String?> lotNumber;
  final Value<DateTime?> dateOpened;
  final Value<DateTime?> beyondUseDate;
  final Value<double?> cost;
  final Value<SupplyStatus> status;
  final Value<int> rowid;
  const SuppliesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.medicationId = const Value.absent(),
    this.concentrationMgPerMl = const Value.absent(),
    this.penDoseMg = const Value.absent(),
    this.pillStrengthMg = const Value.absent(),
    this.additives = const Value.absent(),
    this.volumeMl = const Value.absent(),
    this.lostMl = const Value.absent(),
    this.pillCount = const Value.absent(),
    this.pharmacy = const Value.absent(),
    this.lotNumber = const Value.absent(),
    this.dateOpened = const Value.absent(),
    this.beyondUseDate = const Value.absent(),
    this.cost = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SuppliesCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required String medicationId,
    this.concentrationMgPerMl = const Value.absent(),
    this.penDoseMg = const Value.absent(),
    this.pillStrengthMg = const Value.absent(),
    this.additives = const Value.absent(),
    this.volumeMl = const Value.absent(),
    this.lostMl = const Value.absent(),
    this.pillCount = const Value.absent(),
    this.pharmacy = const Value.absent(),
    this.lotNumber = const Value.absent(),
    this.dateOpened = const Value.absent(),
    this.beyondUseDate = const Value.absent(),
    this.cost = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : medicationId = Value(medicationId);
  static Insertable<Supply> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? medicationId,
    Expression<double>? concentrationMgPerMl,
    Expression<double>? penDoseMg,
    Expression<double>? pillStrengthMg,
    Expression<String>? additives,
    Expression<double>? volumeMl,
    Expression<double>? lostMl,
    Expression<double>? pillCount,
    Expression<String>? pharmacy,
    Expression<String>? lotNumber,
    Expression<DateTime>? dateOpened,
    Expression<DateTime>? beyondUseDate,
    Expression<double>? cost,
    Expression<String>? status,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (medicationId != null) 'medication_id': medicationId,
      if (concentrationMgPerMl != null) 'concentration_mg_per_ml': concentrationMgPerMl,
      if (penDoseMg != null) 'pen_dose_mg': penDoseMg,
      if (pillStrengthMg != null) 'pill_strength_mg': pillStrengthMg,
      if (additives != null) 'additives': additives,
      if (volumeMl != null) 'volume_ml': volumeMl,
      if (lostMl != null) 'lost_ml': lostMl,
      if (pillCount != null) 'pill_count': pillCount,
      if (pharmacy != null) 'pharmacy': pharmacy,
      if (lotNumber != null) 'lot_number': lotNumber,
      if (dateOpened != null) 'date_opened': dateOpened,
      if (beyondUseDate != null) 'beyond_use_date': beyondUseDate,
      if (cost != null) 'cost': cost,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SuppliesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? medicationId,
    Value<double?>? concentrationMgPerMl,
    Value<double?>? penDoseMg,
    Value<double?>? pillStrengthMg,
    Value<List<Additive>>? additives,
    Value<double?>? volumeMl,
    Value<double>? lostMl,
    Value<double?>? pillCount,
    Value<String?>? pharmacy,
    Value<String?>? lotNumber,
    Value<DateTime?>? dateOpened,
    Value<DateTime?>? beyondUseDate,
    Value<double?>? cost,
    Value<SupplyStatus>? status,
    Value<int>? rowid,
  }) {
    return SuppliesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      medicationId: medicationId ?? this.medicationId,
      concentrationMgPerMl: concentrationMgPerMl ?? this.concentrationMgPerMl,
      penDoseMg: penDoseMg ?? this.penDoseMg,
      pillStrengthMg: pillStrengthMg ?? this.pillStrengthMg,
      additives: additives ?? this.additives,
      volumeMl: volumeMl ?? this.volumeMl,
      lostMl: lostMl ?? this.lostMl,
      pillCount: pillCount ?? this.pillCount,
      pharmacy: pharmacy ?? this.pharmacy,
      lotNumber: lotNumber ?? this.lotNumber,
      dateOpened: dateOpened ?? this.dateOpened,
      beyondUseDate: beyondUseDate ?? this.beyondUseDate,
      cost: cost ?? this.cost,
      status: status ?? this.status,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (medicationId.present) {
      map['medication_id'] = Variable<String>(medicationId.value);
    }
    if (concentrationMgPerMl.present) {
      map['concentration_mg_per_ml'] = Variable<double>(concentrationMgPerMl.value);
    }
    if (penDoseMg.present) {
      map['pen_dose_mg'] = Variable<double>(penDoseMg.value);
    }
    if (pillStrengthMg.present) {
      map['pill_strength_mg'] = Variable<double>(pillStrengthMg.value);
    }
    if (additives.present) {
      map['additives'] = Variable<String>($SuppliesTable.$converteradditives.toSql(additives.value));
    }
    if (volumeMl.present) {
      map['volume_ml'] = Variable<double>(volumeMl.value);
    }
    if (lostMl.present) {
      map['lost_ml'] = Variable<double>(lostMl.value);
    }
    if (pillCount.present) {
      map['pill_count'] = Variable<double>(pillCount.value);
    }
    if (pharmacy.present) {
      map['pharmacy'] = Variable<String>(pharmacy.value);
    }
    if (lotNumber.present) {
      map['lot_number'] = Variable<String>(lotNumber.value);
    }
    if (dateOpened.present) {
      map['date_opened'] = Variable<DateTime>(dateOpened.value);
    }
    if (beyondUseDate.present) {
      map['beyond_use_date'] = Variable<DateTime>(beyondUseDate.value);
    }
    if (cost.present) {
      map['cost'] = Variable<double>(cost.value);
    }
    if (status.present) {
      map['status'] = Variable<String>($SuppliesTable.$converterstatus.toSql(status.value));
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SuppliesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('medicationId: $medicationId, ')
          ..write('concentrationMgPerMl: $concentrationMgPerMl, ')
          ..write('penDoseMg: $penDoseMg, ')
          ..write('pillStrengthMg: $pillStrengthMg, ')
          ..write('additives: $additives, ')
          ..write('volumeMl: $volumeMl, ')
          ..write('lostMl: $lostMl, ')
          ..write('pillCount: $pillCount, ')
          ..write('pharmacy: $pharmacy, ')
          ..write('lotNumber: $lotNumber, ')
          ..write('dateOpened: $dateOpened, ')
          ..write('beyondUseDate: $beyondUseDate, ')
          ..write('cost: $cost, ')
          ..write('status: $status, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PrescriptionsTable extends Prescriptions with TableInfo<$PrescriptionsTable, Prescription> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PrescriptionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: newId,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _medicationIdMeta = const VerificationMeta('medicationId');
  @override
  late final GeneratedColumn<String> medicationId = GeneratedColumn<String>(
    'medication_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES medications (id) ON DELETE CASCADE'),
  );
  static const VerificationMeta _prescribedDoseMeta = const VerificationMeta('prescribedDose');
  @override
  late final GeneratedColumn<double> prescribedDose = GeneratedColumn<double>(
    'prescribed_dose',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DoseUnit, String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<DoseUnit>($PrescriptionsTable.$converterunit);
  static const VerificationMeta _directionsTextMeta = const VerificationMeta('directionsText');
  @override
  late final GeneratedColumn<String> directionsText = GeneratedColumn<String>(
    'directions_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta('startDate');
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta('endDate');
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
    'end_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    medicationId,
    prescribedDose,
    unit,
    directionsText,
    startDate,
    endDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'prescriptions';
  @override
  VerificationContext validateIntegrity(Insertable<Prescription> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta, updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('medication_id')) {
      context.handle(_medicationIdMeta, medicationId.isAcceptableOrUnknown(data['medication_id']!, _medicationIdMeta));
    } else if (isInserting) {
      context.missing(_medicationIdMeta);
    }
    if (data.containsKey('prescribed_dose')) {
      context.handle(
        _prescribedDoseMeta,
        prescribedDose.isAcceptableOrUnknown(data['prescribed_dose']!, _prescribedDoseMeta),
      );
    } else if (isInserting) {
      context.missing(_prescribedDoseMeta);
    }
    if (data.containsKey('directions_text')) {
      context.handle(
        _directionsTextMeta,
        directionsText.isAcceptableOrUnknown(data['directions_text']!, _directionsTextMeta),
      );
    }
    if (data.containsKey('start_date')) {
      context.handle(_startDateMeta, startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta));
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(_endDateMeta, endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Prescription map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Prescription(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      medicationId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}medication_id'])!,
      prescribedDose: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}prescribed_dose'],
      )!,
      unit: $PrescriptionsTable.$converterunit.fromSql(
        attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}unit'])!,
      ),
      directionsText: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}directions_text']),
      startDate: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}start_date'])!,
      endDate: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}end_date']),
    );
  }

  @override
  $PrescriptionsTable createAlias(String alias) {
    return $PrescriptionsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<DoseUnit, String, String> $converterunit = const EnumNameConverter<DoseUnit>(
    DoseUnit.values,
  );
}

class Prescription extends DataClass implements Insertable<Prescription> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String medicationId;
  final double prescribedDose;
  final DoseUnit unit;
  final String? directionsText;
  final DateTime startDate;
  final DateTime? endDate;
  const Prescription({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.medicationId,
    required this.prescribedDose,
    required this.unit,
    this.directionsText,
    required this.startDate,
    this.endDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['medication_id'] = Variable<String>(medicationId);
    map['prescribed_dose'] = Variable<double>(prescribedDose);
    {
      map['unit'] = Variable<String>($PrescriptionsTable.$converterunit.toSql(unit));
    }
    if (!nullToAbsent || directionsText != null) {
      map['directions_text'] = Variable<String>(directionsText);
    }
    map['start_date'] = Variable<DateTime>(startDate);
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    return map;
  }

  PrescriptionsCompanion toCompanion(bool nullToAbsent) {
    return PrescriptionsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      medicationId: Value(medicationId),
      prescribedDose: Value(prescribedDose),
      unit: Value(unit),
      directionsText: directionsText == null && nullToAbsent ? const Value.absent() : Value(directionsText),
      startDate: Value(startDate),
      endDate: endDate == null && nullToAbsent ? const Value.absent() : Value(endDate),
    );
  }

  factory Prescription.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Prescription(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      medicationId: serializer.fromJson<String>(json['medicationId']),
      prescribedDose: serializer.fromJson<double>(json['prescribedDose']),
      unit: $PrescriptionsTable.$converterunit.fromJson(serializer.fromJson<String>(json['unit'])),
      directionsText: serializer.fromJson<String?>(json['directionsText']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'medicationId': serializer.toJson<String>(medicationId),
      'prescribedDose': serializer.toJson<double>(prescribedDose),
      'unit': serializer.toJson<String>($PrescriptionsTable.$converterunit.toJson(unit)),
      'directionsText': serializer.toJson<String?>(directionsText),
      'startDate': serializer.toJson<DateTime>(startDate),
      'endDate': serializer.toJson<DateTime?>(endDate),
    };
  }

  Prescription copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? medicationId,
    double? prescribedDose,
    DoseUnit? unit,
    Value<String?> directionsText = const Value.absent(),
    DateTime? startDate,
    Value<DateTime?> endDate = const Value.absent(),
  }) => Prescription(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    medicationId: medicationId ?? this.medicationId,
    prescribedDose: prescribedDose ?? this.prescribedDose,
    unit: unit ?? this.unit,
    directionsText: directionsText.present ? directionsText.value : this.directionsText,
    startDate: startDate ?? this.startDate,
    endDate: endDate.present ? endDate.value : this.endDate,
  );
  Prescription copyWithCompanion(PrescriptionsCompanion data) {
    return Prescription(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      medicationId: data.medicationId.present ? data.medicationId.value : this.medicationId,
      prescribedDose: data.prescribedDose.present ? data.prescribedDose.value : this.prescribedDose,
      unit: data.unit.present ? data.unit.value : this.unit,
      directionsText: data.directionsText.present ? data.directionsText.value : this.directionsText,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Prescription(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('medicationId: $medicationId, ')
          ..write('prescribedDose: $prescribedDose, ')
          ..write('unit: $unit, ')
          ..write('directionsText: $directionsText, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, createdAt, updatedAt, medicationId, prescribedDose, unit, directionsText, startDate, endDate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Prescription &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.medicationId == this.medicationId &&
          other.prescribedDose == this.prescribedDose &&
          other.unit == this.unit &&
          other.directionsText == this.directionsText &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate);
}

class PrescriptionsCompanion extends UpdateCompanion<Prescription> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> medicationId;
  final Value<double> prescribedDose;
  final Value<DoseUnit> unit;
  final Value<String?> directionsText;
  final Value<DateTime> startDate;
  final Value<DateTime?> endDate;
  final Value<int> rowid;
  const PrescriptionsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.medicationId = const Value.absent(),
    this.prescribedDose = const Value.absent(),
    this.unit = const Value.absent(),
    this.directionsText = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PrescriptionsCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required String medicationId,
    required double prescribedDose,
    required DoseUnit unit,
    this.directionsText = const Value.absent(),
    required DateTime startDate,
    this.endDate = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : medicationId = Value(medicationId),
       prescribedDose = Value(prescribedDose),
       unit = Value(unit),
       startDate = Value(startDate);
  static Insertable<Prescription> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? medicationId,
    Expression<double>? prescribedDose,
    Expression<String>? unit,
    Expression<String>? directionsText,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (medicationId != null) 'medication_id': medicationId,
      if (prescribedDose != null) 'prescribed_dose': prescribedDose,
      if (unit != null) 'unit': unit,
      if (directionsText != null) 'directions_text': directionsText,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PrescriptionsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? medicationId,
    Value<double>? prescribedDose,
    Value<DoseUnit>? unit,
    Value<String?>? directionsText,
    Value<DateTime>? startDate,
    Value<DateTime?>? endDate,
    Value<int>? rowid,
  }) {
    return PrescriptionsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      medicationId: medicationId ?? this.medicationId,
      prescribedDose: prescribedDose ?? this.prescribedDose,
      unit: unit ?? this.unit,
      directionsText: directionsText ?? this.directionsText,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (medicationId.present) {
      map['medication_id'] = Variable<String>(medicationId.value);
    }
    if (prescribedDose.present) {
      map['prescribed_dose'] = Variable<double>(prescribedDose.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>($PrescriptionsTable.$converterunit.toSql(unit.value));
    }
    if (directionsText.present) {
      map['directions_text'] = Variable<String>(directionsText.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PrescriptionsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('medicationId: $medicationId, ')
          ..write('prescribedDose: $prescribedDose, ')
          ..write('unit: $unit, ')
          ..write('directionsText: $directionsText, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DosesTable extends Doses with TableInfo<$DosesTable, Dose> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DosesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: newId,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _medicationIdMeta = const VerificationMeta('medicationId');
  @override
  late final GeneratedColumn<String> medicationId = GeneratedColumn<String>(
    'medication_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES medications (id) ON DELETE CASCADE'),
  );
  static const VerificationMeta _supplyIdMeta = const VerificationMeta('supplyId');
  @override
  late final GeneratedColumn<String> supplyId = GeneratedColumn<String>(
    'supply_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES supplies (id) ON DELETE CASCADE'),
  );
  static const VerificationMeta _takenAtMeta = const VerificationMeta('takenAt');
  @override
  late final GeneratedColumn<DateTime> takenAt = GeneratedColumn<DateTime>(
    'taken_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountEnteredMeta = const VerificationMeta('amountEntered');
  @override
  late final GeneratedColumn<double> amountEntered = GeneratedColumn<double>(
    'amount_entered',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DoseUnit, String> unitEntered = GeneratedColumn<String>(
    'unit_entered',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<DoseUnit>($DosesTable.$converterunitEntered);
  static const VerificationMeta _volumeMlMeta = const VerificationMeta('volumeMl');
  @override
  late final GeneratedColumn<double> volumeMl = GeneratedColumn<double>(
    'volume_ml',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _drugMgMeta = const VerificationMeta('drugMg');
  @override
  late final GeneratedColumn<double> drugMg = GeneratedColumn<double>(
    'drug_mg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Map<String, String>, String> additiveAmounts = GeneratedColumn<String>(
    'additive_amounts',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  ).withConverter<Map<String, String>>($DosesTable.$converteradditiveAmounts);
  static const VerificationMeta _injectionPainMeta = const VerificationMeta('injectionPain');
  @override
  late final GeneratedColumn<int> injectionPain = GeneratedColumn<int>(
    'injection_pain',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  late final GeneratedColumnWithTypeConverter<InjectionSite?, String> injectionSite = GeneratedColumn<String>(
    'injection_site',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<InjectionSite?>($DosesTable.$converterinjectionSiten);
  static const VerificationMeta _syringeTypeMeta = const VerificationMeta('syringeType');
  @override
  late final GeneratedColumn<String> syringeType = GeneratedColumn<String>(
    'syringe_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _skippedMeta = const VerificationMeta('skipped');
  @override
  late final GeneratedColumn<bool> skipped = GeneratedColumn<bool>(
    'skipped',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("skipped" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    medicationId,
    supplyId,
    takenAt,
    amountEntered,
    unitEntered,
    volumeMl,
    drugMg,
    additiveAmounts,
    injectionPain,
    injectionSite,
    syringeType,
    notes,
    skipped,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'doses';
  @override
  VerificationContext validateIntegrity(Insertable<Dose> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta, updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('medication_id')) {
      context.handle(_medicationIdMeta, medicationId.isAcceptableOrUnknown(data['medication_id']!, _medicationIdMeta));
    } else if (isInserting) {
      context.missing(_medicationIdMeta);
    }
    if (data.containsKey('supply_id')) {
      context.handle(_supplyIdMeta, supplyId.isAcceptableOrUnknown(data['supply_id']!, _supplyIdMeta));
    } else if (isInserting) {
      context.missing(_supplyIdMeta);
    }
    if (data.containsKey('taken_at')) {
      context.handle(_takenAtMeta, takenAt.isAcceptableOrUnknown(data['taken_at']!, _takenAtMeta));
    } else if (isInserting) {
      context.missing(_takenAtMeta);
    }
    if (data.containsKey('amount_entered')) {
      context.handle(
        _amountEnteredMeta,
        amountEntered.isAcceptableOrUnknown(data['amount_entered']!, _amountEnteredMeta),
      );
    } else if (isInserting) {
      context.missing(_amountEnteredMeta);
    }
    if (data.containsKey('volume_ml')) {
      context.handle(_volumeMlMeta, volumeMl.isAcceptableOrUnknown(data['volume_ml']!, _volumeMlMeta));
    }
    if (data.containsKey('drug_mg')) {
      context.handle(_drugMgMeta, drugMg.isAcceptableOrUnknown(data['drug_mg']!, _drugMgMeta));
    }
    if (data.containsKey('injection_pain')) {
      context.handle(
        _injectionPainMeta,
        injectionPain.isAcceptableOrUnknown(data['injection_pain']!, _injectionPainMeta),
      );
    }
    if (data.containsKey('syringe_type')) {
      context.handle(_syringeTypeMeta, syringeType.isAcceptableOrUnknown(data['syringe_type']!, _syringeTypeMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(_notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('skipped')) {
      context.handle(_skippedMeta, skipped.isAcceptableOrUnknown(data['skipped']!, _skippedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Dose map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Dose(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      medicationId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}medication_id'])!,
      supplyId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}supply_id'])!,
      takenAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}taken_at'])!,
      amountEntered: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}amount_entered'])!,
      unitEntered: $DosesTable.$converterunitEntered.fromSql(
        attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}unit_entered'])!,
      ),
      volumeMl: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}volume_ml']),
      drugMg: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}drug_mg']),
      additiveAmounts: $DosesTable.$converteradditiveAmounts.fromSql(
        attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}additive_amounts'])!,
      ),
      injectionPain: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}injection_pain'])!,
      injectionSite: $DosesTable.$converterinjectionSiten.fromSql(
        attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}injection_site']),
      ),
      syringeType: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}syringe_type']),
      notes: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}notes']),
      skipped: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}skipped'])!,
    );
  }

  @override
  $DosesTable createAlias(String alias) {
    return $DosesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<DoseUnit, String, String> $converterunitEntered = const EnumNameConverter<DoseUnit>(
    DoseUnit.values,
  );
  static TypeConverter<Map<String, String>, String> $converteradditiveAmounts = const AmountsConverter();
  static JsonTypeConverter2<InjectionSite, String, String> $converterinjectionSite =
      const EnumNameConverter<InjectionSite>(InjectionSite.values);
  static JsonTypeConverter2<InjectionSite?, String?, String?> $converterinjectionSiten = JsonTypeConverter2.asNullable(
    $converterinjectionSite,
  );
}

class Dose extends DataClass implements Insertable<Dose> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String medicationId;
  final String supplyId;
  final DateTime takenAt;
  final double amountEntered;
  final DoseUnit unitEntered;
  final double? volumeMl;
  final double? drugMg;
  final Map<String, String> additiveAmounts;

  /// 0 to 10; 0 means none or not set.
  final int injectionPain;
  final InjectionSite? injectionSite;
  final String? syringeType;
  final String? notes;
  final bool skipped;
  const Dose({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.medicationId,
    required this.supplyId,
    required this.takenAt,
    required this.amountEntered,
    required this.unitEntered,
    this.volumeMl,
    this.drugMg,
    required this.additiveAmounts,
    required this.injectionPain,
    this.injectionSite,
    this.syringeType,
    this.notes,
    required this.skipped,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['medication_id'] = Variable<String>(medicationId);
    map['supply_id'] = Variable<String>(supplyId);
    map['taken_at'] = Variable<DateTime>(takenAt);
    map['amount_entered'] = Variable<double>(amountEntered);
    {
      map['unit_entered'] = Variable<String>($DosesTable.$converterunitEntered.toSql(unitEntered));
    }
    if (!nullToAbsent || volumeMl != null) {
      map['volume_ml'] = Variable<double>(volumeMl);
    }
    if (!nullToAbsent || drugMg != null) {
      map['drug_mg'] = Variable<double>(drugMg);
    }
    {
      map['additive_amounts'] = Variable<String>($DosesTable.$converteradditiveAmounts.toSql(additiveAmounts));
    }
    map['injection_pain'] = Variable<int>(injectionPain);
    if (!nullToAbsent || injectionSite != null) {
      map['injection_site'] = Variable<String>($DosesTable.$converterinjectionSiten.toSql(injectionSite));
    }
    if (!nullToAbsent || syringeType != null) {
      map['syringe_type'] = Variable<String>(syringeType);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['skipped'] = Variable<bool>(skipped);
    return map;
  }

  DosesCompanion toCompanion(bool nullToAbsent) {
    return DosesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      medicationId: Value(medicationId),
      supplyId: Value(supplyId),
      takenAt: Value(takenAt),
      amountEntered: Value(amountEntered),
      unitEntered: Value(unitEntered),
      volumeMl: volumeMl == null && nullToAbsent ? const Value.absent() : Value(volumeMl),
      drugMg: drugMg == null && nullToAbsent ? const Value.absent() : Value(drugMg),
      additiveAmounts: Value(additiveAmounts),
      injectionPain: Value(injectionPain),
      injectionSite: injectionSite == null && nullToAbsent ? const Value.absent() : Value(injectionSite),
      syringeType: syringeType == null && nullToAbsent ? const Value.absent() : Value(syringeType),
      notes: notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      skipped: Value(skipped),
    );
  }

  factory Dose.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Dose(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      medicationId: serializer.fromJson<String>(json['medicationId']),
      supplyId: serializer.fromJson<String>(json['supplyId']),
      takenAt: serializer.fromJson<DateTime>(json['takenAt']),
      amountEntered: serializer.fromJson<double>(json['amountEntered']),
      unitEntered: $DosesTable.$converterunitEntered.fromJson(serializer.fromJson<String>(json['unitEntered'])),
      volumeMl: serializer.fromJson<double?>(json['volumeMl']),
      drugMg: serializer.fromJson<double?>(json['drugMg']),
      additiveAmounts: serializer.fromJson<Map<String, String>>(json['additiveAmounts']),
      injectionPain: serializer.fromJson<int>(json['injectionPain']),
      injectionSite: $DosesTable.$converterinjectionSiten.fromJson(serializer.fromJson<String?>(json['injectionSite'])),
      syringeType: serializer.fromJson<String?>(json['syringeType']),
      notes: serializer.fromJson<String?>(json['notes']),
      skipped: serializer.fromJson<bool>(json['skipped']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'medicationId': serializer.toJson<String>(medicationId),
      'supplyId': serializer.toJson<String>(supplyId),
      'takenAt': serializer.toJson<DateTime>(takenAt),
      'amountEntered': serializer.toJson<double>(amountEntered),
      'unitEntered': serializer.toJson<String>($DosesTable.$converterunitEntered.toJson(unitEntered)),
      'volumeMl': serializer.toJson<double?>(volumeMl),
      'drugMg': serializer.toJson<double?>(drugMg),
      'additiveAmounts': serializer.toJson<Map<String, String>>(additiveAmounts),
      'injectionPain': serializer.toJson<int>(injectionPain),
      'injectionSite': serializer.toJson<String?>($DosesTable.$converterinjectionSiten.toJson(injectionSite)),
      'syringeType': serializer.toJson<String?>(syringeType),
      'notes': serializer.toJson<String?>(notes),
      'skipped': serializer.toJson<bool>(skipped),
    };
  }

  Dose copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? medicationId,
    String? supplyId,
    DateTime? takenAt,
    double? amountEntered,
    DoseUnit? unitEntered,
    Value<double?> volumeMl = const Value.absent(),
    Value<double?> drugMg = const Value.absent(),
    Map<String, String>? additiveAmounts,
    int? injectionPain,
    Value<InjectionSite?> injectionSite = const Value.absent(),
    Value<String?> syringeType = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    bool? skipped,
  }) => Dose(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    medicationId: medicationId ?? this.medicationId,
    supplyId: supplyId ?? this.supplyId,
    takenAt: takenAt ?? this.takenAt,
    amountEntered: amountEntered ?? this.amountEntered,
    unitEntered: unitEntered ?? this.unitEntered,
    volumeMl: volumeMl.present ? volumeMl.value : this.volumeMl,
    drugMg: drugMg.present ? drugMg.value : this.drugMg,
    additiveAmounts: additiveAmounts ?? this.additiveAmounts,
    injectionPain: injectionPain ?? this.injectionPain,
    injectionSite: injectionSite.present ? injectionSite.value : this.injectionSite,
    syringeType: syringeType.present ? syringeType.value : this.syringeType,
    notes: notes.present ? notes.value : this.notes,
    skipped: skipped ?? this.skipped,
  );
  Dose copyWithCompanion(DosesCompanion data) {
    return Dose(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      medicationId: data.medicationId.present ? data.medicationId.value : this.medicationId,
      supplyId: data.supplyId.present ? data.supplyId.value : this.supplyId,
      takenAt: data.takenAt.present ? data.takenAt.value : this.takenAt,
      amountEntered: data.amountEntered.present ? data.amountEntered.value : this.amountEntered,
      unitEntered: data.unitEntered.present ? data.unitEntered.value : this.unitEntered,
      volumeMl: data.volumeMl.present ? data.volumeMl.value : this.volumeMl,
      drugMg: data.drugMg.present ? data.drugMg.value : this.drugMg,
      additiveAmounts: data.additiveAmounts.present ? data.additiveAmounts.value : this.additiveAmounts,
      injectionPain: data.injectionPain.present ? data.injectionPain.value : this.injectionPain,
      injectionSite: data.injectionSite.present ? data.injectionSite.value : this.injectionSite,
      syringeType: data.syringeType.present ? data.syringeType.value : this.syringeType,
      notes: data.notes.present ? data.notes.value : this.notes,
      skipped: data.skipped.present ? data.skipped.value : this.skipped,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Dose(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('medicationId: $medicationId, ')
          ..write('supplyId: $supplyId, ')
          ..write('takenAt: $takenAt, ')
          ..write('amountEntered: $amountEntered, ')
          ..write('unitEntered: $unitEntered, ')
          ..write('volumeMl: $volumeMl, ')
          ..write('drugMg: $drugMg, ')
          ..write('additiveAmounts: $additiveAmounts, ')
          ..write('injectionPain: $injectionPain, ')
          ..write('injectionSite: $injectionSite, ')
          ..write('syringeType: $syringeType, ')
          ..write('notes: $notes, ')
          ..write('skipped: $skipped')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    medicationId,
    supplyId,
    takenAt,
    amountEntered,
    unitEntered,
    volumeMl,
    drugMg,
    additiveAmounts,
    injectionPain,
    injectionSite,
    syringeType,
    notes,
    skipped,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Dose &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.medicationId == this.medicationId &&
          other.supplyId == this.supplyId &&
          other.takenAt == this.takenAt &&
          other.amountEntered == this.amountEntered &&
          other.unitEntered == this.unitEntered &&
          other.volumeMl == this.volumeMl &&
          other.drugMg == this.drugMg &&
          other.additiveAmounts == this.additiveAmounts &&
          other.injectionPain == this.injectionPain &&
          other.injectionSite == this.injectionSite &&
          other.syringeType == this.syringeType &&
          other.notes == this.notes &&
          other.skipped == this.skipped);
}

class DosesCompanion extends UpdateCompanion<Dose> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> medicationId;
  final Value<String> supplyId;
  final Value<DateTime> takenAt;
  final Value<double> amountEntered;
  final Value<DoseUnit> unitEntered;
  final Value<double?> volumeMl;
  final Value<double?> drugMg;
  final Value<Map<String, String>> additiveAmounts;
  final Value<int> injectionPain;
  final Value<InjectionSite?> injectionSite;
  final Value<String?> syringeType;
  final Value<String?> notes;
  final Value<bool> skipped;
  final Value<int> rowid;
  const DosesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.medicationId = const Value.absent(),
    this.supplyId = const Value.absent(),
    this.takenAt = const Value.absent(),
    this.amountEntered = const Value.absent(),
    this.unitEntered = const Value.absent(),
    this.volumeMl = const Value.absent(),
    this.drugMg = const Value.absent(),
    this.additiveAmounts = const Value.absent(),
    this.injectionPain = const Value.absent(),
    this.injectionSite = const Value.absent(),
    this.syringeType = const Value.absent(),
    this.notes = const Value.absent(),
    this.skipped = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DosesCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required String medicationId,
    required String supplyId,
    required DateTime takenAt,
    required double amountEntered,
    required DoseUnit unitEntered,
    this.volumeMl = const Value.absent(),
    this.drugMg = const Value.absent(),
    this.additiveAmounts = const Value.absent(),
    this.injectionPain = const Value.absent(),
    this.injectionSite = const Value.absent(),
    this.syringeType = const Value.absent(),
    this.notes = const Value.absent(),
    this.skipped = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : medicationId = Value(medicationId),
       supplyId = Value(supplyId),
       takenAt = Value(takenAt),
       amountEntered = Value(amountEntered),
       unitEntered = Value(unitEntered);
  static Insertable<Dose> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? medicationId,
    Expression<String>? supplyId,
    Expression<DateTime>? takenAt,
    Expression<double>? amountEntered,
    Expression<String>? unitEntered,
    Expression<double>? volumeMl,
    Expression<double>? drugMg,
    Expression<String>? additiveAmounts,
    Expression<int>? injectionPain,
    Expression<String>? injectionSite,
    Expression<String>? syringeType,
    Expression<String>? notes,
    Expression<bool>? skipped,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (medicationId != null) 'medication_id': medicationId,
      if (supplyId != null) 'supply_id': supplyId,
      if (takenAt != null) 'taken_at': takenAt,
      if (amountEntered != null) 'amount_entered': amountEntered,
      if (unitEntered != null) 'unit_entered': unitEntered,
      if (volumeMl != null) 'volume_ml': volumeMl,
      if (drugMg != null) 'drug_mg': drugMg,
      if (additiveAmounts != null) 'additive_amounts': additiveAmounts,
      if (injectionPain != null) 'injection_pain': injectionPain,
      if (injectionSite != null) 'injection_site': injectionSite,
      if (syringeType != null) 'syringe_type': syringeType,
      if (notes != null) 'notes': notes,
      if (skipped != null) 'skipped': skipped,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DosesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? medicationId,
    Value<String>? supplyId,
    Value<DateTime>? takenAt,
    Value<double>? amountEntered,
    Value<DoseUnit>? unitEntered,
    Value<double?>? volumeMl,
    Value<double?>? drugMg,
    Value<Map<String, String>>? additiveAmounts,
    Value<int>? injectionPain,
    Value<InjectionSite?>? injectionSite,
    Value<String?>? syringeType,
    Value<String?>? notes,
    Value<bool>? skipped,
    Value<int>? rowid,
  }) {
    return DosesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      medicationId: medicationId ?? this.medicationId,
      supplyId: supplyId ?? this.supplyId,
      takenAt: takenAt ?? this.takenAt,
      amountEntered: amountEntered ?? this.amountEntered,
      unitEntered: unitEntered ?? this.unitEntered,
      volumeMl: volumeMl ?? this.volumeMl,
      drugMg: drugMg ?? this.drugMg,
      additiveAmounts: additiveAmounts ?? this.additiveAmounts,
      injectionPain: injectionPain ?? this.injectionPain,
      injectionSite: injectionSite ?? this.injectionSite,
      syringeType: syringeType ?? this.syringeType,
      notes: notes ?? this.notes,
      skipped: skipped ?? this.skipped,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (medicationId.present) {
      map['medication_id'] = Variable<String>(medicationId.value);
    }
    if (supplyId.present) {
      map['supply_id'] = Variable<String>(supplyId.value);
    }
    if (takenAt.present) {
      map['taken_at'] = Variable<DateTime>(takenAt.value);
    }
    if (amountEntered.present) {
      map['amount_entered'] = Variable<double>(amountEntered.value);
    }
    if (unitEntered.present) {
      map['unit_entered'] = Variable<String>($DosesTable.$converterunitEntered.toSql(unitEntered.value));
    }
    if (volumeMl.present) {
      map['volume_ml'] = Variable<double>(volumeMl.value);
    }
    if (drugMg.present) {
      map['drug_mg'] = Variable<double>(drugMg.value);
    }
    if (additiveAmounts.present) {
      map['additive_amounts'] = Variable<String>($DosesTable.$converteradditiveAmounts.toSql(additiveAmounts.value));
    }
    if (injectionPain.present) {
      map['injection_pain'] = Variable<int>(injectionPain.value);
    }
    if (injectionSite.present) {
      map['injection_site'] = Variable<String>($DosesTable.$converterinjectionSiten.toSql(injectionSite.value));
    }
    if (syringeType.present) {
      map['syringe_type'] = Variable<String>(syringeType.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (skipped.present) {
      map['skipped'] = Variable<bool>(skipped.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DosesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('medicationId: $medicationId, ')
          ..write('supplyId: $supplyId, ')
          ..write('takenAt: $takenAt, ')
          ..write('amountEntered: $amountEntered, ')
          ..write('unitEntered: $unitEntered, ')
          ..write('volumeMl: $volumeMl, ')
          ..write('drugMg: $drugMg, ')
          ..write('additiveAmounts: $additiveAmounts, ')
          ..write('injectionPain: $injectionPain, ')
          ..write('injectionSite: $injectionSite, ')
          ..write('syringeType: $syringeType, ')
          ..write('notes: $notes, ')
          ..write('skipped: $skipped, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WeightsTable extends Weights with TableInfo<$WeightsTable, Weight> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WeightsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: newId,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _measuredAtMeta = const VerificationMeta('measuredAt');
  @override
  late final GeneratedColumn<DateTime> measuredAt = GeneratedColumn<DateTime>(
    'measured_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kgMeta = const VerificationMeta('kg');
  @override
  late final GeneratedColumn<double> kg = GeneratedColumn<double>(
    'kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<WeightSource, String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('manual'),
  ).withConverter<WeightSource>($WeightsTable.$convertersource);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, createdAt, updatedAt, measuredAt, kg, source, notes];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'weights';
  @override
  VerificationContext validateIntegrity(Insertable<Weight> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta, updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('measured_at')) {
      context.handle(_measuredAtMeta, measuredAt.isAcceptableOrUnknown(data['measured_at']!, _measuredAtMeta));
    } else if (isInserting) {
      context.missing(_measuredAtMeta);
    }
    if (data.containsKey('kg')) {
      context.handle(_kgMeta, kg.isAcceptableOrUnknown(data['kg']!, _kgMeta));
    } else if (isInserting) {
      context.missing(_kgMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(_notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Weight map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Weight(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      measuredAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}measured_at'])!,
      kg: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}kg'])!,
      source: $WeightsTable.$convertersource.fromSql(
        attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}source'])!,
      ),
      notes: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}notes']),
    );
  }

  @override
  $WeightsTable createAlias(String alias) {
    return $WeightsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<WeightSource, String, String> $convertersource = const EnumNameConverter<WeightSource>(
    WeightSource.values,
  );
}

class Weight extends DataClass implements Insertable<Weight> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime measuredAt;
  final double kg;
  final WeightSource source;
  final String? notes;
  const Weight({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.measuredAt,
    required this.kg,
    required this.source,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['measured_at'] = Variable<DateTime>(measuredAt);
    map['kg'] = Variable<double>(kg);
    {
      map['source'] = Variable<String>($WeightsTable.$convertersource.toSql(source));
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  WeightsCompanion toCompanion(bool nullToAbsent) {
    return WeightsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      measuredAt: Value(measuredAt),
      kg: Value(kg),
      source: Value(source),
      notes: notes == null && nullToAbsent ? const Value.absent() : Value(notes),
    );
  }

  factory Weight.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Weight(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      measuredAt: serializer.fromJson<DateTime>(json['measuredAt']),
      kg: serializer.fromJson<double>(json['kg']),
      source: $WeightsTable.$convertersource.fromJson(serializer.fromJson<String>(json['source'])),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'measuredAt': serializer.toJson<DateTime>(measuredAt),
      'kg': serializer.toJson<double>(kg),
      'source': serializer.toJson<String>($WeightsTable.$convertersource.toJson(source)),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  Weight copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? measuredAt,
    double? kg,
    WeightSource? source,
    Value<String?> notes = const Value.absent(),
  }) => Weight(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    measuredAt: measuredAt ?? this.measuredAt,
    kg: kg ?? this.kg,
    source: source ?? this.source,
    notes: notes.present ? notes.value : this.notes,
  );
  Weight copyWithCompanion(WeightsCompanion data) {
    return Weight(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      measuredAt: data.measuredAt.present ? data.measuredAt.value : this.measuredAt,
      kg: data.kg.present ? data.kg.value : this.kg,
      source: data.source.present ? data.source.value : this.source,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Weight(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('measuredAt: $measuredAt, ')
          ..write('kg: $kg, ')
          ..write('source: $source, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, createdAt, updatedAt, measuredAt, kg, source, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Weight &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.measuredAt == this.measuredAt &&
          other.kg == this.kg &&
          other.source == this.source &&
          other.notes == this.notes);
}

class WeightsCompanion extends UpdateCompanion<Weight> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime> measuredAt;
  final Value<double> kg;
  final Value<WeightSource> source;
  final Value<String?> notes;
  final Value<int> rowid;
  const WeightsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.measuredAt = const Value.absent(),
    this.kg = const Value.absent(),
    this.source = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WeightsCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required DateTime measuredAt,
    required double kg,
    this.source = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : measuredAt = Value(measuredAt),
       kg = Value(kg);
  static Insertable<Weight> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? measuredAt,
    Expression<double>? kg,
    Expression<String>? source,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (measuredAt != null) 'measured_at': measuredAt,
      if (kg != null) 'kg': kg,
      if (source != null) 'source': source,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WeightsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime>? measuredAt,
    Value<double>? kg,
    Value<WeightSource>? source,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return WeightsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      measuredAt: measuredAt ?? this.measuredAt,
      kg: kg ?? this.kg,
      source: source ?? this.source,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (measuredAt.present) {
      map['measured_at'] = Variable<DateTime>(measuredAt.value);
    }
    if (kg.present) {
      map['kg'] = Variable<double>(kg.value);
    }
    if (source.present) {
      map['source'] = Variable<String>($WeightsTable.$convertersource.toSql(source.value));
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WeightsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('measuredAt: $measuredAt, ')
          ..write('kg: $kg, ')
          ..write('source: $source, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SideEffectsTable extends SideEffects with TableInfo<$SideEffectsTable, SideEffect> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SideEffectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: newId,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta('occurredAt');
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SideEffectType, String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<SideEffectType>($SideEffectsTable.$convertertype);
  static const VerificationMeta _customNameMeta = const VerificationMeta('customName');
  @override
  late final GeneratedColumn<String> customName = GeneratedColumn<String>(
    'custom_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _severityMeta = const VerificationMeta('severity');
  @override
  late final GeneratedColumn<int> severity = GeneratedColumn<int>(
    'severity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _medicationIdMeta = const VerificationMeta('medicationId');
  @override
  late final GeneratedColumn<String> medicationId = GeneratedColumn<String>(
    'medication_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES medications (id) ON DELETE SET NULL'),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    occurredAt,
    type,
    customName,
    severity,
    medicationId,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'side_effects';
  @override
  VerificationContext validateIntegrity(Insertable<SideEffect> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta, updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('occurred_at')) {
      context.handle(_occurredAtMeta, occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta));
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('custom_name')) {
      context.handle(_customNameMeta, customName.isAcceptableOrUnknown(data['custom_name']!, _customNameMeta));
    }
    if (data.containsKey('severity')) {
      context.handle(_severityMeta, severity.isAcceptableOrUnknown(data['severity']!, _severityMeta));
    } else if (isInserting) {
      context.missing(_severityMeta);
    }
    if (data.containsKey('medication_id')) {
      context.handle(_medicationIdMeta, medicationId.isAcceptableOrUnknown(data['medication_id']!, _medicationIdMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(_notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SideEffect map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SideEffect(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      occurredAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}occurred_at'])!,
      type: $SideEffectsTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      ),
      customName: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}custom_name']),
      severity: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}severity'])!,
      medicationId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}medication_id']),
      notes: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}notes']),
    );
  }

  @override
  $SideEffectsTable createAlias(String alias) {
    return $SideEffectsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SideEffectType, String, String> $convertertype = const EnumNameConverter<SideEffectType>(
    SideEffectType.values,
  );
}

class SideEffect extends DataClass implements Insertable<SideEffect> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime occurredAt;
  final SideEffectType type;

  /// The name typed for [SideEffectType.custom].
  final String? customName;

  /// 1 (barely) to 10 (severe), the same scale Shotsy uses.
  final int severity;

  /// "Likely from": optional.
  final String? medicationId;
  final String? notes;
  const SideEffect({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.occurredAt,
    required this.type,
    this.customName,
    required this.severity,
    this.medicationId,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    {
      map['type'] = Variable<String>($SideEffectsTable.$convertertype.toSql(type));
    }
    if (!nullToAbsent || customName != null) {
      map['custom_name'] = Variable<String>(customName);
    }
    map['severity'] = Variable<int>(severity);
    if (!nullToAbsent || medicationId != null) {
      map['medication_id'] = Variable<String>(medicationId);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  SideEffectsCompanion toCompanion(bool nullToAbsent) {
    return SideEffectsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      occurredAt: Value(occurredAt),
      type: Value(type),
      customName: customName == null && nullToAbsent ? const Value.absent() : Value(customName),
      severity: Value(severity),
      medicationId: medicationId == null && nullToAbsent ? const Value.absent() : Value(medicationId),
      notes: notes == null && nullToAbsent ? const Value.absent() : Value(notes),
    );
  }

  factory SideEffect.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SideEffect(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
      type: $SideEffectsTable.$convertertype.fromJson(serializer.fromJson<String>(json['type'])),
      customName: serializer.fromJson<String?>(json['customName']),
      severity: serializer.fromJson<int>(json['severity']),
      medicationId: serializer.fromJson<String?>(json['medicationId']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
      'type': serializer.toJson<String>($SideEffectsTable.$convertertype.toJson(type)),
      'customName': serializer.toJson<String?>(customName),
      'severity': serializer.toJson<int>(severity),
      'medicationId': serializer.toJson<String?>(medicationId),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  SideEffect copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? occurredAt,
    SideEffectType? type,
    Value<String?> customName = const Value.absent(),
    int? severity,
    Value<String?> medicationId = const Value.absent(),
    Value<String?> notes = const Value.absent(),
  }) => SideEffect(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    occurredAt: occurredAt ?? this.occurredAt,
    type: type ?? this.type,
    customName: customName.present ? customName.value : this.customName,
    severity: severity ?? this.severity,
    medicationId: medicationId.present ? medicationId.value : this.medicationId,
    notes: notes.present ? notes.value : this.notes,
  );
  SideEffect copyWithCompanion(SideEffectsCompanion data) {
    return SideEffect(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      occurredAt: data.occurredAt.present ? data.occurredAt.value : this.occurredAt,
      type: data.type.present ? data.type.value : this.type,
      customName: data.customName.present ? data.customName.value : this.customName,
      severity: data.severity.present ? data.severity.value : this.severity,
      medicationId: data.medicationId.present ? data.medicationId.value : this.medicationId,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SideEffect(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('type: $type, ')
          ..write('customName: $customName, ')
          ..write('severity: $severity, ')
          ..write('medicationId: $medicationId, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, createdAt, updatedAt, occurredAt, type, customName, severity, medicationId, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SideEffect &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.occurredAt == this.occurredAt &&
          other.type == this.type &&
          other.customName == this.customName &&
          other.severity == this.severity &&
          other.medicationId == this.medicationId &&
          other.notes == this.notes);
}

class SideEffectsCompanion extends UpdateCompanion<SideEffect> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime> occurredAt;
  final Value<SideEffectType> type;
  final Value<String?> customName;
  final Value<int> severity;
  final Value<String?> medicationId;
  final Value<String?> notes;
  final Value<int> rowid;
  const SideEffectsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.type = const Value.absent(),
    this.customName = const Value.absent(),
    this.severity = const Value.absent(),
    this.medicationId = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SideEffectsCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required DateTime occurredAt,
    required SideEffectType type,
    this.customName = const Value.absent(),
    required int severity,
    this.medicationId = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : occurredAt = Value(occurredAt),
       type = Value(type),
       severity = Value(severity);
  static Insertable<SideEffect> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? occurredAt,
    Expression<String>? type,
    Expression<String>? customName,
    Expression<int>? severity,
    Expression<String>? medicationId,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (type != null) 'type': type,
      if (customName != null) 'custom_name': customName,
      if (severity != null) 'severity': severity,
      if (medicationId != null) 'medication_id': medicationId,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SideEffectsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime>? occurredAt,
    Value<SideEffectType>? type,
    Value<String?>? customName,
    Value<int>? severity,
    Value<String?>? medicationId,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return SideEffectsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      occurredAt: occurredAt ?? this.occurredAt,
      type: type ?? this.type,
      customName: customName ?? this.customName,
      severity: severity ?? this.severity,
      medicationId: medicationId ?? this.medicationId,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (type.present) {
      map['type'] = Variable<String>($SideEffectsTable.$convertertype.toSql(type.value));
    }
    if (customName.present) {
      map['custom_name'] = Variable<String>(customName.value);
    }
    if (severity.present) {
      map['severity'] = Variable<int>(severity.value);
    }
    if (medicationId.present) {
      map['medication_id'] = Variable<String>(medicationId.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SideEffectsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('type: $type, ')
          ..write('customName: $customName, ')
          ..write('severity: $severity, ')
          ..write('medicationId: $medicationId, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AloftDatabase extends GeneratedDatabase {
  _$AloftDatabase(QueryExecutor e) : super(e);
  $AloftDatabaseManager get managers => $AloftDatabaseManager(this);
  late final $AppSettingsTableTable appSettingsTable = $AppSettingsTableTable(this);
  late final $MedicationsTable medications = $MedicationsTable(this);
  late final $SuppliesTable supplies = $SuppliesTable(this);
  late final $PrescriptionsTable prescriptions = $PrescriptionsTable(this);
  late final $DosesTable doses = $DosesTable(this);
  late final $WeightsTable weights = $WeightsTable(this);
  late final $SideEffectsTable sideEffects = $SideEffectsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables => allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    appSettingsTable,
    medications,
    supplies,
    prescriptions,
    doses,
    weights,
    sideEffects,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName('medications', limitUpdateKind: UpdateKind.delete),
      result: [TableUpdate('supplies', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName('medications', limitUpdateKind: UpdateKind.delete),
      result: [TableUpdate('prescriptions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName('medications', limitUpdateKind: UpdateKind.delete),
      result: [TableUpdate('doses', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName('supplies', limitUpdateKind: UpdateKind.delete),
      result: [TableUpdate('doses', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName('medications', limitUpdateKind: UpdateKind.delete),
      result: [TableUpdate('side_effects', kind: UpdateKind.update)],
    ),
  ]);
}

typedef $$AppSettingsTableTableCreateCompanionBuilder = AppSettingsTableCompanion Function({
  Value<int> id,
  required WeightUnit weightUnit,
  required LengthUnit lengthUnit,
  Value<Appearance> appearance,
  Value<bool> appLock,
  Value<LockAfter> lockAfter,
  Value<bool> hideInAppSwitcher,
  Value<bool> remindShots,
  Value<bool> remindReorder,
  Value<bool> remindUseBy,
});
typedef $$AppSettingsTableTableUpdateCompanionBuilder = AppSettingsTableCompanion Function({
  Value<int> id,
  Value<WeightUnit> weightUnit,
  Value<LengthUnit> lengthUnit,
  Value<Appearance> appearance,
  Value<bool> appLock,
  Value<LockAfter> lockAfter,
  Value<bool> hideInAppSwitcher,
  Value<bool> remindShots,
  Value<bool> remindReorder,
  Value<bool> remindUseBy,
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

  ColumnFilters<bool> get remindShots =>
      $composableBuilder(column: $table.remindShots, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get remindReorder =>
      $composableBuilder(column: $table.remindReorder, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get remindUseBy =>
      $composableBuilder(column: $table.remindUseBy, builder: (column) => ColumnFilters(column));
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

  ColumnOrderings<bool> get remindShots =>
      $composableBuilder(column: $table.remindShots, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get remindReorder =>
      $composableBuilder(column: $table.remindReorder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get remindUseBy =>
      $composableBuilder(column: $table.remindUseBy, builder: (column) => ColumnOrderings(column));
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

  GeneratedColumn<bool> get remindShots => $composableBuilder(column: $table.remindShots, builder: (column) => column);

  GeneratedColumn<bool> get remindReorder =>
      $composableBuilder(column: $table.remindReorder, builder: (column) => column);

  GeneratedColumn<bool> get remindUseBy => $composableBuilder(column: $table.remindUseBy, builder: (column) => column);
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
                Value<bool> remindShots = const Value.absent(),
                Value<bool> remindReorder = const Value.absent(),
                Value<bool> remindUseBy = const Value.absent(),
              }) => AppSettingsTableCompanion(
                id: id,
                weightUnit: weightUnit,
                lengthUnit: lengthUnit,
                appearance: appearance,
                appLock: appLock,
                lockAfter: lockAfter,
                hideInAppSwitcher: hideInAppSwitcher,
                remindShots: remindShots,
                remindReorder: remindReorder,
                remindUseBy: remindUseBy,
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
                Value<bool> remindShots = const Value.absent(),
                Value<bool> remindReorder = const Value.absent(),
                Value<bool> remindUseBy = const Value.absent(),
              }) => AppSettingsTableCompanion.insert(
                id: id,
                weightUnit: weightUnit,
                lengthUnit: lengthUnit,
                appearance: appearance,
                appLock: appLock,
                lockAfter: lockAfter,
                hideInAppSwitcher: hideInAppSwitcher,
                remindShots: remindShots,
                remindReorder: remindReorder,
                remindUseBy: remindUseBy,
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
typedef $$MedicationsTableCreateCompanionBuilder = MedicationsCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  required String name,
  required String activeIngredient,
  required bool isGlp1,
  required MedicationForm form,
  Value<MedicationStatus> status,
  Value<double?> halfLifeHours,
  Value<double?> tmaxHours,
  required ScheduleType scheduleType,
  Value<List<int>> scheduleDays,
  Value<int?> scheduleInterval,
  Value<int?> timeOfDayMinutes,
  required DateTime startDate,
  Value<int> rowid,
});
typedef $$MedicationsTableUpdateCompanionBuilder = MedicationsCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String> name,
  Value<String> activeIngredient,
  Value<bool> isGlp1,
  Value<MedicationForm> form,
  Value<MedicationStatus> status,
  Value<double?> halfLifeHours,
  Value<double?> tmaxHours,
  Value<ScheduleType> scheduleType,
  Value<List<int>> scheduleDays,
  Value<int?> scheduleInterval,
  Value<int?> timeOfDayMinutes,
  Value<DateTime> startDate,
  Value<int> rowid,
});

final class $$MedicationsTableReferences extends BaseReferences<_$AloftDatabase, $MedicationsTable, Medication> {
  $$MedicationsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SuppliesTable, List<Supply>> _suppliesRefsTable(_$AloftDatabase db) =>
      MultiTypedResultKey.fromTable(db.supplies, aliasName: 'medications__id__supplies__medication_id');

  $$SuppliesTableProcessedTableManager get suppliesRefs {
    final manager = $$SuppliesTableTableManager(
      $_db,
      $_db.supplies,
    ).filter((f) => f.medicationId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_suppliesRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$PrescriptionsTable, List<Prescription>> _prescriptionsRefsTable(_$AloftDatabase db) =>
      MultiTypedResultKey.fromTable(db.prescriptions, aliasName: 'medications__id__prescriptions__medication_id');

  $$PrescriptionsTableProcessedTableManager get prescriptionsRefs {
    final manager = $$PrescriptionsTableTableManager(
      $_db,
      $_db.prescriptions,
    ).filter((f) => f.medicationId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_prescriptionsRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$DosesTable, List<Dose>> _dosesRefsTable(_$AloftDatabase db) =>
      MultiTypedResultKey.fromTable(db.doses, aliasName: 'medications__id__doses__medication_id');

  $$DosesTableProcessedTableManager get dosesRefs {
    final manager = $$DosesTableTableManager(
      $_db,
      $_db.doses,
    ).filter((f) => f.medicationId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_dosesRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$SideEffectsTable, List<SideEffect>> _sideEffectsRefsTable(_$AloftDatabase db) =>
      MultiTypedResultKey.fromTable(db.sideEffects, aliasName: 'medications__id__side_effects__medication_id');

  $$SideEffectsTableProcessedTableManager get sideEffectsRefs {
    final manager = $$SideEffectsTableTableManager(
      $_db,
      $_db.sideEffects,
    ).filter((f) => f.medicationId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_sideEffectsRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$MedicationsTableFilterComposer extends Composer<_$AloftDatabase, $MedicationsTable> {
  $$MedicationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get activeIngredient =>
      $composableBuilder(column: $table.activeIngredient, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isGlp1 =>
      $composableBuilder(column: $table.isGlp1, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<MedicationForm, MedicationForm, String> get form =>
      $composableBuilder(column: $table.form, builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<MedicationStatus, MedicationStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<double> get halfLifeHours =>
      $composableBuilder(column: $table.halfLifeHours, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get tmaxHours =>
      $composableBuilder(column: $table.tmaxHours, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<ScheduleType, ScheduleType, String> get scheduleType =>
      $composableBuilder(column: $table.scheduleType, builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<List<int>, List<int>, String> get scheduleDays =>
      $composableBuilder(column: $table.scheduleDays, builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<int> get scheduleInterval =>
      $composableBuilder(column: $table.scheduleInterval, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get timeOfDayMinutes =>
      $composableBuilder(column: $table.timeOfDayMinutes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => ColumnFilters(column));

  Expression<bool> suppliesRefs(Expression<bool> Function($$SuppliesTableFilterComposer f) f) {
    final $$SuppliesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.supplies,
      getReferencedColumn: (t) => t.medicationId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$SuppliesTableFilterComposer(
            $db: $db,
            $table: $db.supplies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> prescriptionsRefs(Expression<bool> Function($$PrescriptionsTableFilterComposer f) f) {
    final $$PrescriptionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.prescriptions,
      getReferencedColumn: (t) => t.medicationId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$PrescriptionsTableFilterComposer(
            $db: $db,
            $table: $db.prescriptions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> dosesRefs(Expression<bool> Function($$DosesTableFilterComposer f) f) {
    final $$DosesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.doses,
      getReferencedColumn: (t) => t.medicationId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$DosesTableFilterComposer(
            $db: $db,
            $table: $db.doses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> sideEffectsRefs(Expression<bool> Function($$SideEffectsTableFilterComposer f) f) {
    final $$SideEffectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sideEffects,
      getReferencedColumn: (t) => t.medicationId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$SideEffectsTableFilterComposer(
            $db: $db,
            $table: $db.sideEffects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MedicationsTableOrderingComposer extends Composer<_$AloftDatabase, $MedicationsTable> {
  $$MedicationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get activeIngredient =>
      $composableBuilder(column: $table.activeIngredient, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isGlp1 =>
      $composableBuilder(column: $table.isGlp1, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get form =>
      $composableBuilder(column: $table.form, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get halfLifeHours =>
      $composableBuilder(column: $table.halfLifeHours, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get tmaxHours =>
      $composableBuilder(column: $table.tmaxHours, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get scheduleType =>
      $composableBuilder(column: $table.scheduleType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get scheduleDays =>
      $composableBuilder(column: $table.scheduleDays, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get scheduleInterval =>
      $composableBuilder(column: $table.scheduleInterval, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get timeOfDayMinutes =>
      $composableBuilder(column: $table.timeOfDayMinutes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => ColumnOrderings(column));
}

class $$MedicationsTableAnnotationComposer extends Composer<_$AloftDatabase, $MedicationsTable> {
  $$MedicationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt => $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get name => $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get activeIngredient =>
      $composableBuilder(column: $table.activeIngredient, builder: (column) => column);

  GeneratedColumn<bool> get isGlp1 => $composableBuilder(column: $table.isGlp1, builder: (column) => column);

  GeneratedColumnWithTypeConverter<MedicationForm, String> get form =>
      $composableBuilder(column: $table.form, builder: (column) => column);

  GeneratedColumnWithTypeConverter<MedicationStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<double> get halfLifeHours =>
      $composableBuilder(column: $table.halfLifeHours, builder: (column) => column);

  GeneratedColumn<double> get tmaxHours => $composableBuilder(column: $table.tmaxHours, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ScheduleType, String> get scheduleType =>
      $composableBuilder(column: $table.scheduleType, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<int>, String> get scheduleDays =>
      $composableBuilder(column: $table.scheduleDays, builder: (column) => column);

  GeneratedColumn<int> get scheduleInterval =>
      $composableBuilder(column: $table.scheduleInterval, builder: (column) => column);

  GeneratedColumn<int> get timeOfDayMinutes =>
      $composableBuilder(column: $table.timeOfDayMinutes, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate => $composableBuilder(column: $table.startDate, builder: (column) => column);

  Expression<T> suppliesRefs<T extends Object>(Expression<T> Function($$SuppliesTableAnnotationComposer a) f) {
    final $$SuppliesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.supplies,
      getReferencedColumn: (t) => t.medicationId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$SuppliesTableAnnotationComposer(
            $db: $db,
            $table: $db.supplies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> prescriptionsRefs<T extends Object>(
    Expression<T> Function($$PrescriptionsTableAnnotationComposer a) f,
  ) {
    final $$PrescriptionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.prescriptions,
      getReferencedColumn: (t) => t.medicationId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$PrescriptionsTableAnnotationComposer(
            $db: $db,
            $table: $db.prescriptions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> dosesRefs<T extends Object>(Expression<T> Function($$DosesTableAnnotationComposer a) f) {
    final $$DosesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.doses,
      getReferencedColumn: (t) => t.medicationId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$DosesTableAnnotationComposer(
            $db: $db,
            $table: $db.doses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> sideEffectsRefs<T extends Object>(Expression<T> Function($$SideEffectsTableAnnotationComposer a) f) {
    final $$SideEffectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sideEffects,
      getReferencedColumn: (t) => t.medicationId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$SideEffectsTableAnnotationComposer(
            $db: $db,
            $table: $db.sideEffects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MedicationsTableTableManager
    extends
        RootTableManager<
          _$AloftDatabase,
          $MedicationsTable,
          Medication,
          $$MedicationsTableFilterComposer,
          $$MedicationsTableOrderingComposer,
          $$MedicationsTableAnnotationComposer,
          $$MedicationsTableCreateCompanionBuilder,
          $$MedicationsTableUpdateCompanionBuilder,
          (Medication, $$MedicationsTableReferences),
          Medication,
          PrefetchHooks Function({bool suppliesRefs, bool prescriptionsRefs, bool dosesRefs, bool sideEffectsRefs})
        > {
  $$MedicationsTableTableManager(_$AloftDatabase db, $MedicationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$MedicationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$MedicationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$MedicationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> activeIngredient = const Value.absent(),
                Value<bool> isGlp1 = const Value.absent(),
                Value<MedicationForm> form = const Value.absent(),
                Value<MedicationStatus> status = const Value.absent(),
                Value<double?> halfLifeHours = const Value.absent(),
                Value<double?> tmaxHours = const Value.absent(),
                Value<ScheduleType> scheduleType = const Value.absent(),
                Value<List<int>> scheduleDays = const Value.absent(),
                Value<int?> scheduleInterval = const Value.absent(),
                Value<int?> timeOfDayMinutes = const Value.absent(),
                Value<DateTime> startDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MedicationsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                name: name,
                activeIngredient: activeIngredient,
                isGlp1: isGlp1,
                form: form,
                status: status,
                halfLifeHours: halfLifeHours,
                tmaxHours: tmaxHours,
                scheduleType: scheduleType,
                scheduleDays: scheduleDays,
                scheduleInterval: scheduleInterval,
                timeOfDayMinutes: timeOfDayMinutes,
                startDate: startDate,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                required String name,
                required String activeIngredient,
                required bool isGlp1,
                required MedicationForm form,
                Value<MedicationStatus> status = const Value.absent(),
                Value<double?> halfLifeHours = const Value.absent(),
                Value<double?> tmaxHours = const Value.absent(),
                required ScheduleType scheduleType,
                Value<List<int>> scheduleDays = const Value.absent(),
                Value<int?> scheduleInterval = const Value.absent(),
                Value<int?> timeOfDayMinutes = const Value.absent(),
                required DateTime startDate,
                Value<int> rowid = const Value.absent(),
              }) => MedicationsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                name: name,
                activeIngredient: activeIngredient,
                isGlp1: isGlp1,
                form: form,
                status: status,
                halfLifeHours: halfLifeHours,
                tmaxHours: tmaxHours,
                scheduleType: scheduleType,
                scheduleDays: scheduleDays,
                scheduleInterval: scheduleInterval,
                timeOfDayMinutes: timeOfDayMinutes,
                startDate: startDate,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (e.readTable<$MedicationsTable, Medication>(table), $$MedicationsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({suppliesRefs = false, prescriptionsRefs = false, dosesRefs = false, sideEffectsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (suppliesRefs) db.supplies,
                    if (prescriptionsRefs) db.prescriptions,
                    if (dosesRefs) db.doses,
                    if (sideEffectsRefs) db.sideEffects,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (suppliesRefs)
                        await $_getPrefetchedDataByColumns<Medication, $MedicationsTable, Supply, $SuppliesTable>(
                          currentTable: table,
                          referencedTable: $$MedicationsTableReferences._suppliesRefsTable(db),
                          managerFromTypedResult: (p0) => $$MedicationsTableReferences(db, table, p0).suppliesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'medication_id',
                          typedResults: items,
                        ),
                      if (prescriptionsRefs)
                        await $_getPrefetchedDataByColumns<
                          Medication,
                          $MedicationsTable,
                          Prescription,
                          $PrescriptionsTable
                        >(
                          currentTable: table,
                          referencedTable: $$MedicationsTableReferences._prescriptionsRefsTable(db),
                          managerFromTypedResult: (p0) => $$MedicationsTableReferences(db, table, p0).prescriptionsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'medication_id',
                          typedResults: items,
                        ),
                      if (dosesRefs)
                        await $_getPrefetchedDataByColumns<Medication, $MedicationsTable, Dose, $DosesTable>(
                          currentTable: table,
                          referencedTable: $$MedicationsTableReferences._dosesRefsTable(db),
                          managerFromTypedResult: (p0) => $$MedicationsTableReferences(db, table, p0).dosesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'medication_id',
                          typedResults: items,
                        ),
                      if (sideEffectsRefs)
                        await $_getPrefetchedDataByColumns<
                          Medication,
                          $MedicationsTable,
                          SideEffect,
                          $SideEffectsTable
                        >(
                          currentTable: table,
                          referencedTable: $$MedicationsTableReferences._sideEffectsRefsTable(db),
                          managerFromTypedResult: (p0) => $$MedicationsTableReferences(db, table, p0).sideEffectsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'medication_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$MedicationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AloftDatabase,
      $MedicationsTable,
      Medication,
      $$MedicationsTableFilterComposer,
      $$MedicationsTableOrderingComposer,
      $$MedicationsTableAnnotationComposer,
      $$MedicationsTableCreateCompanionBuilder,
      $$MedicationsTableUpdateCompanionBuilder,
      (Medication, $$MedicationsTableReferences),
      Medication,
      PrefetchHooks Function({bool suppliesRefs, bool prescriptionsRefs, bool dosesRefs, bool sideEffectsRefs})
    >;
typedef $$SuppliesTableCreateCompanionBuilder = SuppliesCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  required String medicationId,
  Value<double?> concentrationMgPerMl,
  Value<double?> penDoseMg,
  Value<double?> pillStrengthMg,
  Value<List<Additive>> additives,
  Value<double?> volumeMl,
  Value<double> lostMl,
  Value<double?> pillCount,
  Value<String?> pharmacy,
  Value<String?> lotNumber,
  Value<DateTime?> dateOpened,
  Value<DateTime?> beyondUseDate,
  Value<double?> cost,
  Value<SupplyStatus> status,
  Value<int> rowid,
});
typedef $$SuppliesTableUpdateCompanionBuilder = SuppliesCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String> medicationId,
  Value<double?> concentrationMgPerMl,
  Value<double?> penDoseMg,
  Value<double?> pillStrengthMg,
  Value<List<Additive>> additives,
  Value<double?> volumeMl,
  Value<double> lostMl,
  Value<double?> pillCount,
  Value<String?> pharmacy,
  Value<String?> lotNumber,
  Value<DateTime?> dateOpened,
  Value<DateTime?> beyondUseDate,
  Value<double?> cost,
  Value<SupplyStatus> status,
  Value<int> rowid,
});

final class $$SuppliesTableReferences extends BaseReferences<_$AloftDatabase, $SuppliesTable, Supply> {
  $$SuppliesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MedicationsTable _medicationIdTable(_$AloftDatabase db) =>
      db.medications.createAlias('supplies__medication_id__medications__id');

  $$MedicationsTableProcessedTableManager get medicationId {
    final $_column = $_itemColumn<String>('medication_id')!;

    final manager = $$MedicationsTableTableManager($_db, $_db.medications).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_medicationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$DosesTable, List<Dose>> _dosesRefsTable(_$AloftDatabase db) =>
      MultiTypedResultKey.fromTable(db.doses, aliasName: 'supplies__id__doses__supply_id');

  $$DosesTableProcessedTableManager get dosesRefs {
    final manager = $$DosesTableTableManager(
      $_db,
      $_db.doses,
    ).filter((f) => f.supplyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_dosesRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$SuppliesTableFilterComposer extends Composer<_$AloftDatabase, $SuppliesTable> {
  $$SuppliesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get concentrationMgPerMl =>
      $composableBuilder(column: $table.concentrationMgPerMl, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get penDoseMg =>
      $composableBuilder(column: $table.penDoseMg, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get pillStrengthMg =>
      $composableBuilder(column: $table.pillStrengthMg, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<List<Additive>, List<Additive>, String> get additives =>
      $composableBuilder(column: $table.additives, builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<double> get volumeMl =>
      $composableBuilder(column: $table.volumeMl, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get lostMl =>
      $composableBuilder(column: $table.lostMl, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get pillCount =>
      $composableBuilder(column: $table.pillCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get pharmacy =>
      $composableBuilder(column: $table.pharmacy, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lotNumber =>
      $composableBuilder(column: $table.lotNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dateOpened =>
      $composableBuilder(column: $table.dateOpened, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get beyondUseDate =>
      $composableBuilder(column: $table.beyondUseDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get cost => $composableBuilder(column: $table.cost, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<SupplyStatus, SupplyStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => ColumnWithTypeConverterFilters(column));

  $$MedicationsTableFilterComposer get medicationId {
    final $$MedicationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicationId,
      referencedTable: $db.medications,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$MedicationsTableFilterComposer(
            $db: $db,
            $table: $db.medications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> dosesRefs(Expression<bool> Function($$DosesTableFilterComposer f) f) {
    final $$DosesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.doses,
      getReferencedColumn: (t) => t.supplyId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$DosesTableFilterComposer(
            $db: $db,
            $table: $db.doses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SuppliesTableOrderingComposer extends Composer<_$AloftDatabase, $SuppliesTable> {
  $$SuppliesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get concentrationMgPerMl =>
      $composableBuilder(column: $table.concentrationMgPerMl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get penDoseMg =>
      $composableBuilder(column: $table.penDoseMg, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get pillStrengthMg =>
      $composableBuilder(column: $table.pillStrengthMg, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get additives =>
      $composableBuilder(column: $table.additives, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get volumeMl =>
      $composableBuilder(column: $table.volumeMl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get lostMl =>
      $composableBuilder(column: $table.lostMl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get pillCount =>
      $composableBuilder(column: $table.pillCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get pharmacy =>
      $composableBuilder(column: $table.pharmacy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lotNumber =>
      $composableBuilder(column: $table.lotNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dateOpened =>
      $composableBuilder(column: $table.dateOpened, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get beyondUseDate =>
      $composableBuilder(column: $table.beyondUseDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get cost =>
      $composableBuilder(column: $table.cost, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => ColumnOrderings(column));

  $$MedicationsTableOrderingComposer get medicationId {
    final $$MedicationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicationId,
      referencedTable: $db.medications,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$MedicationsTableOrderingComposer(
            $db: $db,
            $table: $db.medications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SuppliesTableAnnotationComposer extends Composer<_$AloftDatabase, $SuppliesTable> {
  $$SuppliesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt => $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<double> get concentrationMgPerMl =>
      $composableBuilder(column: $table.concentrationMgPerMl, builder: (column) => column);

  GeneratedColumn<double> get penDoseMg => $composableBuilder(column: $table.penDoseMg, builder: (column) => column);

  GeneratedColumn<double> get pillStrengthMg =>
      $composableBuilder(column: $table.pillStrengthMg, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<Additive>, String> get additives =>
      $composableBuilder(column: $table.additives, builder: (column) => column);

  GeneratedColumn<double> get volumeMl => $composableBuilder(column: $table.volumeMl, builder: (column) => column);

  GeneratedColumn<double> get lostMl => $composableBuilder(column: $table.lostMl, builder: (column) => column);

  GeneratedColumn<double> get pillCount => $composableBuilder(column: $table.pillCount, builder: (column) => column);

  GeneratedColumn<String> get pharmacy => $composableBuilder(column: $table.pharmacy, builder: (column) => column);

  GeneratedColumn<String> get lotNumber => $composableBuilder(column: $table.lotNumber, builder: (column) => column);

  GeneratedColumn<DateTime> get dateOpened =>
      $composableBuilder(column: $table.dateOpened, builder: (column) => column);

  GeneratedColumn<DateTime> get beyondUseDate =>
      $composableBuilder(column: $table.beyondUseDate, builder: (column) => column);

  GeneratedColumn<double> get cost => $composableBuilder(column: $table.cost, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SupplyStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  $$MedicationsTableAnnotationComposer get medicationId {
    final $$MedicationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicationId,
      referencedTable: $db.medications,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$MedicationsTableAnnotationComposer(
            $db: $db,
            $table: $db.medications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> dosesRefs<T extends Object>(Expression<T> Function($$DosesTableAnnotationComposer a) f) {
    final $$DosesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.doses,
      getReferencedColumn: (t) => t.supplyId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$DosesTableAnnotationComposer(
            $db: $db,
            $table: $db.doses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SuppliesTableTableManager
    extends
        RootTableManager<
          _$AloftDatabase,
          $SuppliesTable,
          Supply,
          $$SuppliesTableFilterComposer,
          $$SuppliesTableOrderingComposer,
          $$SuppliesTableAnnotationComposer,
          $$SuppliesTableCreateCompanionBuilder,
          $$SuppliesTableUpdateCompanionBuilder,
          (Supply, $$SuppliesTableReferences),
          Supply,
          PrefetchHooks Function({bool medicationId, bool dosesRefs})
        > {
  $$SuppliesTableTableManager(_$AloftDatabase db, $SuppliesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$SuppliesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$SuppliesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$SuppliesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> medicationId = const Value.absent(),
                Value<double?> concentrationMgPerMl = const Value.absent(),
                Value<double?> penDoseMg = const Value.absent(),
                Value<double?> pillStrengthMg = const Value.absent(),
                Value<List<Additive>> additives = const Value.absent(),
                Value<double?> volumeMl = const Value.absent(),
                Value<double> lostMl = const Value.absent(),
                Value<double?> pillCount = const Value.absent(),
                Value<String?> pharmacy = const Value.absent(),
                Value<String?> lotNumber = const Value.absent(),
                Value<DateTime?> dateOpened = const Value.absent(),
                Value<DateTime?> beyondUseDate = const Value.absent(),
                Value<double?> cost = const Value.absent(),
                Value<SupplyStatus> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SuppliesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                medicationId: medicationId,
                concentrationMgPerMl: concentrationMgPerMl,
                penDoseMg: penDoseMg,
                pillStrengthMg: pillStrengthMg,
                additives: additives,
                volumeMl: volumeMl,
                lostMl: lostMl,
                pillCount: pillCount,
                pharmacy: pharmacy,
                lotNumber: lotNumber,
                dateOpened: dateOpened,
                beyondUseDate: beyondUseDate,
                cost: cost,
                status: status,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                required String medicationId,
                Value<double?> concentrationMgPerMl = const Value.absent(),
                Value<double?> penDoseMg = const Value.absent(),
                Value<double?> pillStrengthMg = const Value.absent(),
                Value<List<Additive>> additives = const Value.absent(),
                Value<double?> volumeMl = const Value.absent(),
                Value<double> lostMl = const Value.absent(),
                Value<double?> pillCount = const Value.absent(),
                Value<String?> pharmacy = const Value.absent(),
                Value<String?> lotNumber = const Value.absent(),
                Value<DateTime?> dateOpened = const Value.absent(),
                Value<DateTime?> beyondUseDate = const Value.absent(),
                Value<double?> cost = const Value.absent(),
                Value<SupplyStatus> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SuppliesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                medicationId: medicationId,
                concentrationMgPerMl: concentrationMgPerMl,
                penDoseMg: penDoseMg,
                pillStrengthMg: pillStrengthMg,
                additives: additives,
                volumeMl: volumeMl,
                lostMl: lostMl,
                pillCount: pillCount,
                pharmacy: pharmacy,
                lotNumber: lotNumber,
                dateOpened: dateOpened,
                beyondUseDate: beyondUseDate,
                cost: cost,
                status: status,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable<$SuppliesTable, Supply>(table), $$SuppliesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({medicationId = false, dosesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (dosesRefs) db.doses],
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
                    if (medicationId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.medicationId,
                        referencedTable: $$SuppliesTableReferences._medicationIdTable(db),
                        referencedColumn: $$SuppliesTableReferences._medicationIdTable(db).id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (dosesRefs)
                    await $_getPrefetchedDataByColumns<Supply, $SuppliesTable, Dose, $DosesTable>(
                      currentTable: table,
                      referencedTable: $$SuppliesTableReferences._dosesRefsTable(db),
                      managerFromTypedResult: (p0) => $$SuppliesTableReferences(db, table, p0).dosesRefs,
                      currentColumn: 'id',
                      referencedColumn: 'supply_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$SuppliesTableProcessedTableManager =
    ProcessedTableManager<
      _$AloftDatabase,
      $SuppliesTable,
      Supply,
      $$SuppliesTableFilterComposer,
      $$SuppliesTableOrderingComposer,
      $$SuppliesTableAnnotationComposer,
      $$SuppliesTableCreateCompanionBuilder,
      $$SuppliesTableUpdateCompanionBuilder,
      (Supply, $$SuppliesTableReferences),
      Supply,
      PrefetchHooks Function({bool medicationId, bool dosesRefs})
    >;
typedef $$PrescriptionsTableCreateCompanionBuilder = PrescriptionsCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  required String medicationId,
  required double prescribedDose,
  required DoseUnit unit,
  Value<String?> directionsText,
  required DateTime startDate,
  Value<DateTime?> endDate,
  Value<int> rowid,
});
typedef $$PrescriptionsTableUpdateCompanionBuilder = PrescriptionsCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String> medicationId,
  Value<double> prescribedDose,
  Value<DoseUnit> unit,
  Value<String?> directionsText,
  Value<DateTime> startDate,
  Value<DateTime?> endDate,
  Value<int> rowid,
});

final class $$PrescriptionsTableReferences extends BaseReferences<_$AloftDatabase, $PrescriptionsTable, Prescription> {
  $$PrescriptionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MedicationsTable _medicationIdTable(_$AloftDatabase db) =>
      db.medications.createAlias('prescriptions__medication_id__medications__id');

  $$MedicationsTableProcessedTableManager get medicationId {
    final $_column = $_itemColumn<String>('medication_id')!;

    final manager = $$MedicationsTableTableManager($_db, $_db.medications).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_medicationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$PrescriptionsTableFilterComposer extends Composer<_$AloftDatabase, $PrescriptionsTable> {
  $$PrescriptionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get prescribedDose =>
      $composableBuilder(column: $table.prescribedDose, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<DoseUnit, DoseUnit, String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get directionsText =>
      $composableBuilder(column: $table.directionsText, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => ColumnFilters(column));

  $$MedicationsTableFilterComposer get medicationId {
    final $$MedicationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicationId,
      referencedTable: $db.medications,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$MedicationsTableFilterComposer(
            $db: $db,
            $table: $db.medications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PrescriptionsTableOrderingComposer extends Composer<_$AloftDatabase, $PrescriptionsTable> {
  $$PrescriptionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get prescribedDose =>
      $composableBuilder(column: $table.prescribedDose, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get directionsText =>
      $composableBuilder(column: $table.directionsText, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => ColumnOrderings(column));

  $$MedicationsTableOrderingComposer get medicationId {
    final $$MedicationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicationId,
      referencedTable: $db.medications,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$MedicationsTableOrderingComposer(
            $db: $db,
            $table: $db.medications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PrescriptionsTableAnnotationComposer extends Composer<_$AloftDatabase, $PrescriptionsTable> {
  $$PrescriptionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt => $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<double> get prescribedDose =>
      $composableBuilder(column: $table.prescribedDose, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DoseUnit, String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<String> get directionsText =>
      $composableBuilder(column: $table.directionsText, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate => $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate => $composableBuilder(column: $table.endDate, builder: (column) => column);

  $$MedicationsTableAnnotationComposer get medicationId {
    final $$MedicationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicationId,
      referencedTable: $db.medications,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$MedicationsTableAnnotationComposer(
            $db: $db,
            $table: $db.medications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PrescriptionsTableTableManager
    extends
        RootTableManager<
          _$AloftDatabase,
          $PrescriptionsTable,
          Prescription,
          $$PrescriptionsTableFilterComposer,
          $$PrescriptionsTableOrderingComposer,
          $$PrescriptionsTableAnnotationComposer,
          $$PrescriptionsTableCreateCompanionBuilder,
          $$PrescriptionsTableUpdateCompanionBuilder,
          (Prescription, $$PrescriptionsTableReferences),
          Prescription,
          PrefetchHooks Function({bool medicationId})
        > {
  $$PrescriptionsTableTableManager(_$AloftDatabase db, $PrescriptionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$PrescriptionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$PrescriptionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$PrescriptionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> medicationId = const Value.absent(),
                Value<double> prescribedDose = const Value.absent(),
                Value<DoseUnit> unit = const Value.absent(),
                Value<String?> directionsText = const Value.absent(),
                Value<DateTime> startDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PrescriptionsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                medicationId: medicationId,
                prescribedDose: prescribedDose,
                unit: unit,
                directionsText: directionsText,
                startDate: startDate,
                endDate: endDate,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                required String medicationId,
                required double prescribedDose,
                required DoseUnit unit,
                Value<String?> directionsText = const Value.absent(),
                required DateTime startDate,
                Value<DateTime?> endDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PrescriptionsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                medicationId: medicationId,
                prescribedDose: prescribedDose,
                unit: unit,
                directionsText: directionsText,
                startDate: startDate,
                endDate: endDate,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PrescriptionsTable, Prescription>(table),
                  $$PrescriptionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({medicationId = false}) {
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
                    if (medicationId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.medicationId,
                        referencedTable: $$PrescriptionsTableReferences._medicationIdTable(db),
                        referencedColumn: $$PrescriptionsTableReferences._medicationIdTable(db).id,
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

typedef $$PrescriptionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AloftDatabase,
      $PrescriptionsTable,
      Prescription,
      $$PrescriptionsTableFilterComposer,
      $$PrescriptionsTableOrderingComposer,
      $$PrescriptionsTableAnnotationComposer,
      $$PrescriptionsTableCreateCompanionBuilder,
      $$PrescriptionsTableUpdateCompanionBuilder,
      (Prescription, $$PrescriptionsTableReferences),
      Prescription,
      PrefetchHooks Function({bool medicationId})
    >;
typedef $$DosesTableCreateCompanionBuilder = DosesCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  required String medicationId,
  required String supplyId,
  required DateTime takenAt,
  required double amountEntered,
  required DoseUnit unitEntered,
  Value<double?> volumeMl,
  Value<double?> drugMg,
  Value<Map<String, String>> additiveAmounts,
  Value<int> injectionPain,
  Value<InjectionSite?> injectionSite,
  Value<String?> syringeType,
  Value<String?> notes,
  Value<bool> skipped,
  Value<int> rowid,
});
typedef $$DosesTableUpdateCompanionBuilder = DosesCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String> medicationId,
  Value<String> supplyId,
  Value<DateTime> takenAt,
  Value<double> amountEntered,
  Value<DoseUnit> unitEntered,
  Value<double?> volumeMl,
  Value<double?> drugMg,
  Value<Map<String, String>> additiveAmounts,
  Value<int> injectionPain,
  Value<InjectionSite?> injectionSite,
  Value<String?> syringeType,
  Value<String?> notes,
  Value<bool> skipped,
  Value<int> rowid,
});

final class $$DosesTableReferences extends BaseReferences<_$AloftDatabase, $DosesTable, Dose> {
  $$DosesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MedicationsTable _medicationIdTable(_$AloftDatabase db) =>
      db.medications.createAlias('doses__medication_id__medications__id');

  $$MedicationsTableProcessedTableManager get medicationId {
    final $_column = $_itemColumn<String>('medication_id')!;

    final manager = $$MedicationsTableTableManager($_db, $_db.medications).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_medicationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }

  static $SuppliesTable _supplyIdTable(_$AloftDatabase db) => db.supplies.createAlias('doses__supply_id__supplies__id');

  $$SuppliesTableProcessedTableManager get supplyId {
    final $_column = $_itemColumn<String>('supply_id')!;

    final manager = $$SuppliesTableTableManager($_db, $_db.supplies).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_supplyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$DosesTableFilterComposer extends Composer<_$AloftDatabase, $DosesTable> {
  $$DosesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get takenAt =>
      $composableBuilder(column: $table.takenAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amountEntered =>
      $composableBuilder(column: $table.amountEntered, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<DoseUnit, DoseUnit, String> get unitEntered =>
      $composableBuilder(column: $table.unitEntered, builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<double> get volumeMl =>
      $composableBuilder(column: $table.volumeMl, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get drugMg =>
      $composableBuilder(column: $table.drugMg, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<Map<String, String>, Map<String, String>, String> get additiveAmounts =>
      $composableBuilder(column: $table.additiveAmounts, builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<int> get injectionPain =>
      $composableBuilder(column: $table.injectionPain, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<InjectionSite?, InjectionSite, String> get injectionSite =>
      $composableBuilder(column: $table.injectionSite, builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get syringeType =>
      $composableBuilder(column: $table.syringeType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get skipped =>
      $composableBuilder(column: $table.skipped, builder: (column) => ColumnFilters(column));

  $$MedicationsTableFilterComposer get medicationId {
    final $$MedicationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicationId,
      referencedTable: $db.medications,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$MedicationsTableFilterComposer(
            $db: $db,
            $table: $db.medications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SuppliesTableFilterComposer get supplyId {
    final $$SuppliesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.supplyId,
      referencedTable: $db.supplies,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$SuppliesTableFilterComposer(
            $db: $db,
            $table: $db.supplies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DosesTableOrderingComposer extends Composer<_$AloftDatabase, $DosesTable> {
  $$DosesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get takenAt =>
      $composableBuilder(column: $table.takenAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amountEntered =>
      $composableBuilder(column: $table.amountEntered, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get unitEntered =>
      $composableBuilder(column: $table.unitEntered, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get volumeMl =>
      $composableBuilder(column: $table.volumeMl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get drugMg =>
      $composableBuilder(column: $table.drugMg, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get additiveAmounts =>
      $composableBuilder(column: $table.additiveAmounts, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get injectionPain =>
      $composableBuilder(column: $table.injectionPain, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get injectionSite =>
      $composableBuilder(column: $table.injectionSite, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syringeType =>
      $composableBuilder(column: $table.syringeType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get skipped =>
      $composableBuilder(column: $table.skipped, builder: (column) => ColumnOrderings(column));

  $$MedicationsTableOrderingComposer get medicationId {
    final $$MedicationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicationId,
      referencedTable: $db.medications,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$MedicationsTableOrderingComposer(
            $db: $db,
            $table: $db.medications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SuppliesTableOrderingComposer get supplyId {
    final $$SuppliesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.supplyId,
      referencedTable: $db.supplies,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$SuppliesTableOrderingComposer(
            $db: $db,
            $table: $db.supplies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DosesTableAnnotationComposer extends Composer<_$AloftDatabase, $DosesTable> {
  $$DosesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt => $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get takenAt => $composableBuilder(column: $table.takenAt, builder: (column) => column);

  GeneratedColumn<double> get amountEntered =>
      $composableBuilder(column: $table.amountEntered, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DoseUnit, String> get unitEntered =>
      $composableBuilder(column: $table.unitEntered, builder: (column) => column);

  GeneratedColumn<double> get volumeMl => $composableBuilder(column: $table.volumeMl, builder: (column) => column);

  GeneratedColumn<double> get drugMg => $composableBuilder(column: $table.drugMg, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Map<String, String>, String> get additiveAmounts =>
      $composableBuilder(column: $table.additiveAmounts, builder: (column) => column);

  GeneratedColumn<int> get injectionPain =>
      $composableBuilder(column: $table.injectionPain, builder: (column) => column);

  GeneratedColumnWithTypeConverter<InjectionSite?, String> get injectionSite =>
      $composableBuilder(column: $table.injectionSite, builder: (column) => column);

  GeneratedColumn<String> get syringeType =>
      $composableBuilder(column: $table.syringeType, builder: (column) => column);

  GeneratedColumn<String> get notes => $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get skipped => $composableBuilder(column: $table.skipped, builder: (column) => column);

  $$MedicationsTableAnnotationComposer get medicationId {
    final $$MedicationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicationId,
      referencedTable: $db.medications,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$MedicationsTableAnnotationComposer(
            $db: $db,
            $table: $db.medications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SuppliesTableAnnotationComposer get supplyId {
    final $$SuppliesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.supplyId,
      referencedTable: $db.supplies,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$SuppliesTableAnnotationComposer(
            $db: $db,
            $table: $db.supplies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DosesTableTableManager
    extends
        RootTableManager<
          _$AloftDatabase,
          $DosesTable,
          Dose,
          $$DosesTableFilterComposer,
          $$DosesTableOrderingComposer,
          $$DosesTableAnnotationComposer,
          $$DosesTableCreateCompanionBuilder,
          $$DosesTableUpdateCompanionBuilder,
          (Dose, $$DosesTableReferences),
          Dose,
          PrefetchHooks Function({bool medicationId, bool supplyId})
        > {
  $$DosesTableTableManager(_$AloftDatabase db, $DosesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$DosesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$DosesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$DosesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> medicationId = const Value.absent(),
                Value<String> supplyId = const Value.absent(),
                Value<DateTime> takenAt = const Value.absent(),
                Value<double> amountEntered = const Value.absent(),
                Value<DoseUnit> unitEntered = const Value.absent(),
                Value<double?> volumeMl = const Value.absent(),
                Value<double?> drugMg = const Value.absent(),
                Value<Map<String, String>> additiveAmounts = const Value.absent(),
                Value<int> injectionPain = const Value.absent(),
                Value<InjectionSite?> injectionSite = const Value.absent(),
                Value<String?> syringeType = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> skipped = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DosesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                medicationId: medicationId,
                supplyId: supplyId,
                takenAt: takenAt,
                amountEntered: amountEntered,
                unitEntered: unitEntered,
                volumeMl: volumeMl,
                drugMg: drugMg,
                additiveAmounts: additiveAmounts,
                injectionPain: injectionPain,
                injectionSite: injectionSite,
                syringeType: syringeType,
                notes: notes,
                skipped: skipped,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                required String medicationId,
                required String supplyId,
                required DateTime takenAt,
                required double amountEntered,
                required DoseUnit unitEntered,
                Value<double?> volumeMl = const Value.absent(),
                Value<double?> drugMg = const Value.absent(),
                Value<Map<String, String>> additiveAmounts = const Value.absent(),
                Value<int> injectionPain = const Value.absent(),
                Value<InjectionSite?> injectionSite = const Value.absent(),
                Value<String?> syringeType = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> skipped = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DosesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                medicationId: medicationId,
                supplyId: supplyId,
                takenAt: takenAt,
                amountEntered: amountEntered,
                unitEntered: unitEntered,
                volumeMl: volumeMl,
                drugMg: drugMg,
                additiveAmounts: additiveAmounts,
                injectionPain: injectionPain,
                injectionSite: injectionSite,
                syringeType: syringeType,
                notes: notes,
                skipped: skipped,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable<$DosesTable, Dose>(table), $$DosesTableReferences(db, table, e))).toList(),
          prefetchHooksCallback: ({medicationId = false, supplyId = false}) {
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
                    if (medicationId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.medicationId,
                        referencedTable: $$DosesTableReferences._medicationIdTable(db),
                        referencedColumn: $$DosesTableReferences._medicationIdTable(db).id,
                      ) as T;
                    }
                    if (supplyId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.supplyId,
                        referencedTable: $$DosesTableReferences._supplyIdTable(db),
                        referencedColumn: $$DosesTableReferences._supplyIdTable(db).id,
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

typedef $$DosesTableProcessedTableManager =
    ProcessedTableManager<
      _$AloftDatabase,
      $DosesTable,
      Dose,
      $$DosesTableFilterComposer,
      $$DosesTableOrderingComposer,
      $$DosesTableAnnotationComposer,
      $$DosesTableCreateCompanionBuilder,
      $$DosesTableUpdateCompanionBuilder,
      (Dose, $$DosesTableReferences),
      Dose,
      PrefetchHooks Function({bool medicationId, bool supplyId})
    >;
typedef $$WeightsTableCreateCompanionBuilder = WeightsCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  required DateTime measuredAt,
  required double kg,
  Value<WeightSource> source,
  Value<String?> notes,
  Value<int> rowid,
});
typedef $$WeightsTableUpdateCompanionBuilder = WeightsCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime> measuredAt,
  Value<double> kg,
  Value<WeightSource> source,
  Value<String?> notes,
  Value<int> rowid,
});

class $$WeightsTableFilterComposer extends Composer<_$AloftDatabase, $WeightsTable> {
  $$WeightsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get measuredAt =>
      $composableBuilder(column: $table.measuredAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get kg => $composableBuilder(column: $table.kg, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<WeightSource, WeightSource, String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => ColumnFilters(column));
}

class $$WeightsTableOrderingComposer extends Composer<_$AloftDatabase, $WeightsTable> {
  $$WeightsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get measuredAt =>
      $composableBuilder(column: $table.measuredAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get kg => $composableBuilder(column: $table.kg, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => ColumnOrderings(column));
}

class $$WeightsTableAnnotationComposer extends Composer<_$AloftDatabase, $WeightsTable> {
  $$WeightsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt => $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get measuredAt =>
      $composableBuilder(column: $table.measuredAt, builder: (column) => column);

  GeneratedColumn<double> get kg => $composableBuilder(column: $table.kg, builder: (column) => column);

  GeneratedColumnWithTypeConverter<WeightSource, String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get notes => $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$WeightsTableTableManager
    extends
        RootTableManager<
          _$AloftDatabase,
          $WeightsTable,
          Weight,
          $$WeightsTableFilterComposer,
          $$WeightsTableOrderingComposer,
          $$WeightsTableAnnotationComposer,
          $$WeightsTableCreateCompanionBuilder,
          $$WeightsTableUpdateCompanionBuilder,
          (Weight, BaseReferences<_$AloftDatabase, $WeightsTable, Weight>),
          Weight,
          PrefetchHooks Function()
        > {
  $$WeightsTableTableManager(_$AloftDatabase db, $WeightsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$WeightsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$WeightsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$WeightsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime> measuredAt = const Value.absent(),
                Value<double> kg = const Value.absent(),
                Value<WeightSource> source = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WeightsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                measuredAt: measuredAt,
                kg: kg,
                source: source,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                required DateTime measuredAt,
                required double kg,
                Value<WeightSource> source = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WeightsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                measuredAt: measuredAt,
                kg: kg,
                source: source,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WeightsTable, Weight>(table),
                  BaseReferences<_$AloftDatabase, $WeightsTable, Weight>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WeightsTableProcessedTableManager =
    ProcessedTableManager<
      _$AloftDatabase,
      $WeightsTable,
      Weight,
      $$WeightsTableFilterComposer,
      $$WeightsTableOrderingComposer,
      $$WeightsTableAnnotationComposer,
      $$WeightsTableCreateCompanionBuilder,
      $$WeightsTableUpdateCompanionBuilder,
      (Weight, BaseReferences<_$AloftDatabase, $WeightsTable, Weight>),
      Weight,
      PrefetchHooks Function()
    >;
typedef $$SideEffectsTableCreateCompanionBuilder = SideEffectsCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  required DateTime occurredAt,
  required SideEffectType type,
  Value<String?> customName,
  required int severity,
  Value<String?> medicationId,
  Value<String?> notes,
  Value<int> rowid,
});
typedef $$SideEffectsTableUpdateCompanionBuilder = SideEffectsCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime> occurredAt,
  Value<SideEffectType> type,
  Value<String?> customName,
  Value<int> severity,
  Value<String?> medicationId,
  Value<String?> notes,
  Value<int> rowid,
});

final class $$SideEffectsTableReferences extends BaseReferences<_$AloftDatabase, $SideEffectsTable, SideEffect> {
  $$SideEffectsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MedicationsTable _medicationIdTable(_$AloftDatabase db) =>
      db.medications.createAlias('side_effects__medication_id__medications__id');

  $$MedicationsTableProcessedTableManager? get medicationId {
    final $_column = $_itemColumn<String>('medication_id');
    if ($_column == null) return null;
    final manager = $$MedicationsTableTableManager($_db, $_db.medications).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_medicationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$SideEffectsTableFilterComposer extends Composer<_$AloftDatabase, $SideEffectsTable> {
  $$SideEffectsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get occurredAt =>
      $composableBuilder(column: $table.occurredAt, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<SideEffectType, SideEffectType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get customName =>
      $composableBuilder(column: $table.customName, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get severity =>
      $composableBuilder(column: $table.severity, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => ColumnFilters(column));

  $$MedicationsTableFilterComposer get medicationId {
    final $$MedicationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicationId,
      referencedTable: $db.medications,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$MedicationsTableFilterComposer(
            $db: $db,
            $table: $db.medications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SideEffectsTableOrderingComposer extends Composer<_$AloftDatabase, $SideEffectsTable> {
  $$SideEffectsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get occurredAt =>
      $composableBuilder(column: $table.occurredAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get customName =>
      $composableBuilder(column: $table.customName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get severity =>
      $composableBuilder(column: $table.severity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => ColumnOrderings(column));

  $$MedicationsTableOrderingComposer get medicationId {
    final $$MedicationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicationId,
      referencedTable: $db.medications,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$MedicationsTableOrderingComposer(
            $db: $db,
            $table: $db.medications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SideEffectsTableAnnotationComposer extends Composer<_$AloftDatabase, $SideEffectsTable> {
  $$SideEffectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt => $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAt =>
      $composableBuilder(column: $table.occurredAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SideEffectType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get customName => $composableBuilder(column: $table.customName, builder: (column) => column);

  GeneratedColumn<int> get severity => $composableBuilder(column: $table.severity, builder: (column) => column);

  GeneratedColumn<String> get notes => $composableBuilder(column: $table.notes, builder: (column) => column);

  $$MedicationsTableAnnotationComposer get medicationId {
    final $$MedicationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicationId,
      referencedTable: $db.medications,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$MedicationsTableAnnotationComposer(
            $db: $db,
            $table: $db.medications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SideEffectsTableTableManager
    extends
        RootTableManager<
          _$AloftDatabase,
          $SideEffectsTable,
          SideEffect,
          $$SideEffectsTableFilterComposer,
          $$SideEffectsTableOrderingComposer,
          $$SideEffectsTableAnnotationComposer,
          $$SideEffectsTableCreateCompanionBuilder,
          $$SideEffectsTableUpdateCompanionBuilder,
          (SideEffect, $$SideEffectsTableReferences),
          SideEffect,
          PrefetchHooks Function({bool medicationId})
        > {
  $$SideEffectsTableTableManager(_$AloftDatabase db, $SideEffectsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$SideEffectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$SideEffectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$SideEffectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<SideEffectType> type = const Value.absent(),
                Value<String?> customName = const Value.absent(),
                Value<int> severity = const Value.absent(),
                Value<String?> medicationId = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SideEffectsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                occurredAt: occurredAt,
                type: type,
                customName: customName,
                severity: severity,
                medicationId: medicationId,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                required DateTime occurredAt,
                required SideEffectType type,
                Value<String?> customName = const Value.absent(),
                required int severity,
                Value<String?> medicationId = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SideEffectsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                occurredAt: occurredAt,
                type: type,
                customName: customName,
                severity: severity,
                medicationId: medicationId,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (e.readTable<$SideEffectsTable, SideEffect>(table), $$SideEffectsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({medicationId = false}) {
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
                    if (medicationId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.medicationId,
                        referencedTable: $$SideEffectsTableReferences._medicationIdTable(db),
                        referencedColumn: $$SideEffectsTableReferences._medicationIdTable(db).id,
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

typedef $$SideEffectsTableProcessedTableManager =
    ProcessedTableManager<
      _$AloftDatabase,
      $SideEffectsTable,
      SideEffect,
      $$SideEffectsTableFilterComposer,
      $$SideEffectsTableOrderingComposer,
      $$SideEffectsTableAnnotationComposer,
      $$SideEffectsTableCreateCompanionBuilder,
      $$SideEffectsTableUpdateCompanionBuilder,
      (SideEffect, $$SideEffectsTableReferences),
      SideEffect,
      PrefetchHooks Function({bool medicationId})
    >;

class $AloftDatabaseManager {
  final _$AloftDatabase _db;
  $AloftDatabaseManager(this._db);
  $$AppSettingsTableTableTableManager get appSettingsTable =>
      $$AppSettingsTableTableTableManager(_db, _db.appSettingsTable);
  $$MedicationsTableTableManager get medications => $$MedicationsTableTableManager(_db, _db.medications);
  $$SuppliesTableTableManager get supplies => $$SuppliesTableTableManager(_db, _db.supplies);
  $$PrescriptionsTableTableManager get prescriptions => $$PrescriptionsTableTableManager(_db, _db.prescriptions);
  $$DosesTableTableManager get doses => $$DosesTableTableManager(_db, _db.doses);
  $$WeightsTableTableManager get weights => $$WeightsTableTableManager(_db, _db.weights);
  $$SideEffectsTableTableManager get sideEffects => $$SideEffectsTableTableManager(_db, _db.sideEffects);
}
