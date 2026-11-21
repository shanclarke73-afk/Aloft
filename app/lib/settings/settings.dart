import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';

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

  Future<void> setWeightUnit(WeightUnit unit) => _save(AppSettingsTableCompanion(weightUnit: Value(unit)));
  Future<void> setLengthUnit(LengthUnit unit) => _save(AppSettingsTableCompanion(lengthUnit: Value(unit)));
  Future<void> setAppearance(Appearance value) => _save(AppSettingsTableCompanion(appearance: Value(value)));
  Future<void> setAppLock(bool on) => _save(AppSettingsTableCompanion(appLock: Value(on)));
  Future<void> setLockAfter(LockAfter value) => _save(AppSettingsTableCompanion(lockAfter: Value(value)));
  Future<void> setHideInAppSwitcher(bool on) => _save(AppSettingsTableCompanion(hideInAppSwitcher: Value(on)));
}
