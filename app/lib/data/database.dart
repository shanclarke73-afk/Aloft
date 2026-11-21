import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../dose/dose_math.dart';
import '../dose/injection_sites.dart';

part 'database.g.dart';

enum WeightUnit { lb, kg }

enum LengthUnit { inches, cm }

enum Appearance { system, light, dark }

enum LockAfter { immediately, oneMinute }

/// The one row of app settings (SPEC section 4, Settings). More columns arrive with the
/// features that need them (goal weight, start date, default syringe).
@DataClassName('AppSettings')
class AppSettingsTable extends Table {
  @override
  String get tableName => 'app_settings';

  IntColumn get id => integer().withDefault(const Constant(1)).customConstraint('NOT NULL DEFAULT 1 CHECK (id = 1)')();
  TextColumn get weightUnit => textEnum<WeightUnit>()();
  TextColumn get lengthUnit => textEnum<LengthUnit>()();
  TextColumn get appearance => textEnum<Appearance>().withDefault(const Constant('system'))();
  BoolColumn get appLock => boolean().withDefault(const Constant(false))();
  TextColumn get lockAfter => textEnum<LockAfter>().withDefault(const Constant('immediately'))();
  BoolColumn get hideInAppSwitcher => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

enum MedicationForm { brandPen, compoundedVial, oral, other }

enum MedicationStatus { active, paused, ended }

enum ScheduleType { weekly, daysOfWeek, everyNDays, daily, asNeeded }

enum SupplyStatus { active, finished, discarded }

String newId() => const Uuid().v4();

/// Columns every record has (SPEC section 4).
mixin RecordColumns on Table {
  TextColumn get id => text().clientDefault(newId)();
  DateTimeColumn get createdAt => dateTime().clientDefault(DateTime.now)();
  DateTimeColumn get updatedAt => dateTime().clientDefault(DateTime.now)();

  @override
  Set<Column> get primaryKey => {id};
}

class AdditivesConverter extends TypeConverter<List<Additive>, String> {
  const AdditivesConverter();
  @override
  List<Additive> fromSql(String fromDb) => [
    for (final item in jsonDecode(fromDb) as List) Additive.fromJson(item as Map<String, dynamic>),
  ];
  @override
  String toSql(List<Additive> value) => jsonEncode([for (final a in value) a.toJson()]);
}

/// Extra-ingredient amounts frozen into a logged dose: name → "0.125 mg".
class AmountsConverter extends TypeConverter<Map<String, String>, String> {
  const AmountsConverter();
  @override
  Map<String, String> fromSql(String fromDb) => Map<String, String>.from(jsonDecode(fromDb) as Map);
  @override
  String toSql(Map<String, String> value) => jsonEncode(value);
}

/// Weekdays as 1 (Monday) to 7 (Sunday).
class IntListConverter extends TypeConverter<List<int>, String> {
  const IntListConverter();
  @override
  List<int> fromSql(String fromDb) => List<int>.from(jsonDecode(fromDb) as List);
  @override
  String toSql(List<int> value) => jsonEncode(value);
}

/// What the drug is, and its own schedule.
@DataClassName('Medication')
class Medications extends Table with RecordColumns {
  TextColumn get name => text()();

  /// Lower-case ingredient, e.g. "tirzepatide". Shots of the same ingredient share a level curve.
  TextColumn get activeIngredient => text()();
  BoolColumn get isGlp1 => boolean()();
  TextColumn get form => textEnum<MedicationForm>()();
  TextColumn get status => textEnum<MedicationStatus>().withDefault(const Constant('active'))();

  // Level-chart numbers. Left empty until they've been checked against prescribing information.
  RealColumn get halfLifeHours => real().nullable()();
  RealColumn get tmaxHours => real().nullable()();

  TextColumn get scheduleType => textEnum<ScheduleType>()();
  TextColumn get scheduleDays => text().map(const IntListConverter()).withDefault(const Constant('[]'))();
  IntColumn get scheduleInterval => integer().nullable()();

  /// Minutes after midnight for the dose time. Null for "as needed".
  IntColumn get timeOfDayMinutes => integer().nullable()();
  DateTimeColumn get startDate => dateTime()();
}

/// A specific vial, pen strength or bottle of pills.
@DataClassName('Supply')
class Supplies extends Table with RecordColumns {
  TextColumn get medicationId => text().references(Medications, #id, onDelete: KeyAction.cascade)();
  RealColumn get concentrationMgPerMl => real().nullable()();
  RealColumn get penDoseMg => real().nullable()();
  RealColumn get pillStrengthMg => real().nullable()();
  TextColumn get additives => text().map(const AdditivesConverter()).withDefault(const Constant('[]'))();
  RealColumn get volumeMl => real().nullable()();
  RealColumn get pillCount => real().nullable()();
  TextColumn get pharmacy => text().nullable()();
  TextColumn get lotNumber => text().nullable()();
  DateTimeColumn get dateOpened => dateTime().nullable()();
  DateTimeColumn get beyondUseDate => dateTime().nullable()();
  RealColumn get cost => real().nullable()();
  TextColumn get status => textEnum<SupplyStatus>().withDefault(const Constant('active'))();
}

/// The usual dose: what the prescriber ordered. Entered by the person, never worked out by Aloft.
@DataClassName('Prescription')
class Prescriptions extends Table with RecordColumns {
  TextColumn get medicationId => text().references(Medications, #id, onDelete: KeyAction.cascade)();
  RealColumn get prescribedDose => real()();
  TextColumn get unit => textEnum<DoseUnit>()();
  TextColumn get directionsText => text().nullable()();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime().nullable()();
}

/// A logged shot or pill, or a skipped one.
@DataClassName('Dose')
class Doses extends Table with RecordColumns {
  TextColumn get medicationId => text().references(Medications, #id, onDelete: KeyAction.cascade)();
  TextColumn get supplyId => text().references(Supplies, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get takenAt => dateTime()();
  RealColumn get amountEntered => real()();
  TextColumn get unitEntered => textEnum<DoseUnit>()();

  // Worked out when the dose is logged and frozen, so editing the vial later never rewrites history.
  RealColumn get volumeMl => real().nullable()();
  RealColumn get drugMg => real().nullable()();
  TextColumn get additiveAmounts => text().map(const AmountsConverter()).withDefault(const Constant('{}'))();

  /// 0 to 10; 0 means none or not set.
  IntColumn get injectionPain => integer().withDefault(const Constant(0))();
  TextColumn get injectionSite => textEnum<InjectionSite>().nullable()();
  TextColumn get syringeType => text().nullable()();
  TextColumn get notes => text().nullable()();
  BoolColumn get skipped => boolean().withDefault(const Constant(false))();
}

@DriftDatabase(tables: [AppSettingsTable, Medications, Supplies, Prescriptions, Doses])
class AloftDatabase extends _$AloftDatabase {
  AloftDatabase(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(medications);
        await m.createTable(supplies);
        await m.createTable(prescriptions);
        await m.createTable(doses);
      }
    },
    beforeOpen: (details) => customStatement('PRAGMA foreign_keys = ON'),
  );

  /// Reads the settings row, creating it on first launch. Pounds and inches are the
  /// first-launch default only in the US; everywhere else starts in kg and cm.
  Future<AppSettings> loadSettings({String? countryCode}) async {
    final existing = await select(appSettingsTable).getSingleOrNull();
    if (existing != null) return existing;
    final imperial = countryCode == null || countryCode.toUpperCase() == 'US';
    return into(appSettingsTable).insertReturning(
      AppSettingsTableCompanion.insert(
        weightUnit: imperial ? WeightUnit.lb : WeightUnit.kg,
        lengthUnit: imperial ? LengthUnit.inches : LengthUnit.cm,
      ),
    );
  }

  Future<AppSettings> saveSettings(AppSettingsTableCompanion changes) async {
    final rows = await update(appSettingsTable).writeReturning(changes);
    return rows.single;
  }
}
