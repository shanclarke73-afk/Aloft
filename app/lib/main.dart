import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'data/encrypted_database.dart';
import 'photos/photo_picker.dart';
import 'reminders/reminders.dart';
import 'security/app_lock.dart';
import 'settings/settings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    final database = await openAppDatabase();
    final settings = await database.loadSettings(
      countryCode: WidgetsBinding.instance.platformDispatcher.locale.countryCode,
    );
    // Private to the app: not the camera roll, and not visible in the Files app.
    final photoFolder = Directory(p.join((await getApplicationSupportDirectory()).path, 'photos'));
    final lock = AppLock(authenticator: DeviceAuthenticator(), enabled: settings.appLock, lockAfter: settings.lockAfter)
      ..detectMethod();
    runApp(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          initialSettingsProvider.overrideWithValue(settings),
          appLockProvider.overrideWithValue(lock),
          remindersProvider.overrideWithValue(DeviceReminders()),
          photoPickerProvider.overrideWithValue(DevicePhotoPicker()),
          photoFolderProvider.overrideWithValue(photoFolder),
        ],
        child: const AloftApp(),
      ),
    );
  } on DatabaseUnavailable catch (e) {
    runApp(StartupProblemApp(message: e.message));
  } catch (_) {
    runApp(const StartupProblemApp(message: 'Something went wrong opening Aloft. Nothing has been deleted.'));
  }
}
