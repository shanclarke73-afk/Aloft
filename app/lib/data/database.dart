import 'package:drift/drift.dart';

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

@DriftDatabase(tables: [AppSettingsTable])
class AloftDatabase extends _$AloftDatabase {
  AloftDatabase(super.executor);

  @override
  int get schemaVersion => 1;

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
