import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/body_store.dart';
import '../data/database.dart';
import '../data/medication_store.dart';
import '../data/photo_store.dart';
import '../import/shotsy_import.dart';

/// Both are set in main() once the encrypted database is open.
final databaseProvider = Provider<AloftDatabase>((ref) => throw UnimplementedError('database not opened'));
final initialSettingsProvider = Provider<AppSettings>((ref) => throw UnimplementedError('settings not loaded'));

final settingsProvider = NotifierProvider<SettingsController, AppSettings>(SettingsController.new);

class SettingsController extends Notifier<AppSettings> {
  @override
  AppSettings build() => ref.watch(initialSettingsProvider);

  Future<void> _save(AppSettingsTableCompanion changes) async {
    state = await ref.read(databaseProvider).saveSettings(changes);
  }

  /// Reads the settings again after something changed them underneath (a restore).
  Future<void> reload() async => state = await ref.read(databaseProvider).loadSettings();

  Future<void> finishOnboarding() => _save(const AppSettingsTableCompanion(onboardingDone: Value(true)));
  Future<void> setGoalAndHeight({required double? goalWeightKg, required double? heightCm}) =>
      _save(AppSettingsTableCompanion(goalWeightKg: Value(goalWeightKg), heightCm: Value(heightCm)));

  /// A backup file was just handed to the share sheet.
  Future<void> backupSaved({DateTime? now}) => _save(
    AppSettingsTableCompanion(
      lastBackupAt: Value(now ?? DateTime.now()),
      backupReminderSnoozedUntil: const Value(null),
    ),
  );

  /// "Not now" on the Today reminder.
  Future<void> snoozeBackupReminder(DateTime until) =>
      _save(AppSettingsTableCompanion(backupReminderSnoozedUntil: Value(until)));
  Future<void> setWeightUnit(WeightUnit unit) => _save(AppSettingsTableCompanion(weightUnit: Value(unit)));
  Future<void> setLengthUnit(LengthUnit unit) => _save(AppSettingsTableCompanion(lengthUnit: Value(unit)));
  Future<void> setAppearance(Appearance value) => _save(AppSettingsTableCompanion(appearance: Value(value)));
  Future<void> setAppLock(bool on) => _save(AppSettingsTableCompanion(appLock: Value(on)));
  Future<void> setLockAfter(LockAfter value) => _save(AppSettingsTableCompanion(lockAfter: Value(value)));
  Future<void> setRemindShots(bool on) => _save(AppSettingsTableCompanion(remindShots: Value(on)));
  Future<void> setRemindReorder(bool on) => _save(AppSettingsTableCompanion(remindReorder: Value(on)));
  Future<void> setRemindUseBy(bool on) => _save(AppSettingsTableCompanion(remindUseBy: Value(on)));
  Future<void> setHideInAppSwitcher(bool on) => _save(AppSettingsTableCompanion(hideInAppSwitcher: Value(on)));
}

/// Medications that aren't ended, with their current supply, usual dose and last dose.
final medicationsProvider = StreamProvider<List<MedicationDetail>>(
  (ref) => ref.watch(databaseProvider).watchMedications(),
);

/// Everything logged, newest first.
final historyProvider = StreamProvider<List<HistoryEntry>>((ref) => ref.watch(databaseProvider).watchHistory());

/// Weights, newest first.
final weightsProvider = StreamProvider<List<Weight>>((ref) => ref.watch(databaseProvider).watchWeights());

/// Side effects, newest first.
final sideEffectsProvider = StreamProvider<List<SideEffect>>((ref) => ref.watch(databaseProvider).watchSideEffects());

/// Day notes, newest first.
final dayNotesProvider = StreamProvider<List<DayNote>>((ref) => ref.watch(databaseProvider).watchDayNotes());

/// Progress photos, newest first.
final photosProvider = StreamProvider<List<ProgressPhoto>>((ref) => ref.watch(databaseProvider).watchPhotos());
