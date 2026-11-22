import 'dart:io';

import 'package:aloft/backup/backup_file.dart';
import 'package:aloft/backup/backup_files.dart';
import 'package:aloft/data/body_store.dart';
import 'package:aloft/data/database.dart';
import 'package:aloft/data/encrypted_database.dart';
import 'package:aloft/data/photo_store.dart';
import 'package:aloft/features/backup/backup_screen.dart';
import 'package:aloft/photos/photo_picker.dart';
import 'package:aloft/settings/settings.dart';
import 'package:archive/archive_io.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/wait.dart';
import 'photos_test.dart' show onePixel;

/// Stands in for the share sheet and the file chooser. Keeps a copy of what was shared,
/// because the screen clears its own temporary file afterwards.
class FakeFiles implements BackupFiles {
  FakeFiles(this.keepIn);
  final Directory keepIn;
  File? shared;
  File? sharedFrom;
  File? toPick;

  @override
  Future<void> share(File file, {Rect? origin}) async {
    sharedFrom = file;
    shared = file.copySync('${keepIn.path}/${file.uri.pathSegments.last}');
  }

  @override
  Future<File?> pick() async => toPick;
}

void main() {
  late Directory dir;
  late FakeFiles files;

  Future<(AloftDatabase, AppSettings, Directory)> phone(WidgetTester tester, String name) async {
    final home = Directory('${dir.path}/$name')..createSync();
    late AloftDatabase db;
    late AppSettings settings;
    await tester.runAsync(() async {
      db = openEncryptedDatabase(File('${home.path}/aloft.db'), generateDatabaseKey());
      settings = await db.loadSettings(countryCode: 'US');
    });
    return (db, settings, Directory('${home.path}/photos'));
  }

  Future<void> settle(WidgetTester tester, {int rounds = 16}) async {
    for (var i = 0; i < rounds; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
      await tester.pump();
    }
    await tester.pumpAndSettle();
  }

  Future<void> show(WidgetTester tester, AloftDatabase db, AppSettings settings, Directory photos) async {
    await tester.pumpWidget(
      ProviderScope(
        key: UniqueKey(),
        overrides: [
          databaseProvider.overrideWithValue(db),
          initialSettingsProvider.overrideWithValue(settings),
          photoFolderProvider.overrideWithValue(photos),
          backupFilesProvider.overrideWithValue(files),
        ],
        child: const MaterialApp(home: BackupScreen()),
      ),
    );
    await settle(tester);
  }

  /// Taps something that starts real file work, and waits for it.
  Future<void> tapAndWait(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.runAsync(() async {
      await tester.tap(finder);
      await Future<void>.delayed(const Duration(milliseconds: 600));
    });
    await settle(tester, rounds: 24);
  }

  testWidgets('a locked backup made on one phone is restored onto another', (tester) async {
    dir = Directory.systemTemp.createTempSync('aloft_backup_ui');
    addTearDown(() => dir.deleteSync(recursive: true));
    files = FakeFiles(dir);

    final (oldDb, oldSettings, oldPhotos) = await phone(tester, 'old');
    await tester.runAsync(() async {
      await oldDb.logWeight(kg: 89.4, measuredAt: DateTime(2026, 9, 4, 7));
      await oldDb.logWeight(kg: 83.7, measuredAt: DateTime(2026, 11, 20, 7));
      final source = File('${dir.path}/src.jpg')..writeAsBytesSync(onePixel);
      await oldDb.addPhoto(oldPhotos, source: source, pose: PhotoPose.front, takenAt: DateTime(2026, 9, 4, 8));
    });
    await show(tester, oldDb, oldSettings, oldPhotos);
    expect(find.text('1 photo'), findsOneWidget);
    expect(tester.widget<Text>(find.byKey(const Key('password-note'))).data, contains('anyone who gets the file'));
    await tester.enterText(find.byKey(const Key('backup-password')), 'river stone');
    await tester.pump();
    expect(tester.widget<Text>(find.byKey(const Key('password-note'))).data, contains("can't be opened"));
    await tapAndWait(tester, find.byKey(const Key('save-backup')));

    expect(files.shared, isNotNull);
    expect(files.shared!.path, matches(RegExp(r'Aloft backup \d{4}-\d{2}-\d{2}\.zip$')));
    // The screen's own temporary copy is gone once the share sheet closes.
    expect(files.sharedFrom!.existsSync(), isFalse);

    // The new phone already has one weight of its own.
    final (newDb, newSettings, newPhotos) = await phone(tester, 'new');
    await tester.runAsync(() => newDb.logWeight(kg: 70, measuredAt: DateTime(2026, 1, 1)));
    files.toPick = files.shared;
    await show(tester, newDb, newSettings, newPhotos);
    await tapAndWait(tester, find.byKey(const Key('restore-backup')));
    expect(find.text('This backup is locked with a password.'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('restore-password')), 'wrong');
    await tapAndWait(tester, find.byKey(const Key('restore-password-ok')));
    expect(find.text("That password didn't open it. Try again."), findsOneWidget);
    await tester.enterText(find.byKey(const Key('restore-password')), 'river stone');
    await tapAndWait(tester, find.byKey(const Key('restore-password-ok')));

    expect(find.byType(RestoreScreen), findsOneWidget);
    expect(tester.widget<Text>(find.byKey(const Key('backup-contents'))).data, '2 weights\n1 photo');
    // Nothing has changed yet.
    await tester.runAsync(() async => expect((await newDb.select(newDb.weights).get()).length, 1));

    await tester.tap(find.byKey(const Key('choose-replace')));
    await tester.pump();
    await tester.ensureVisible(find.byKey(const Key('restore-now')));
    await tester.tap(find.byKey(const Key('restore-now')));
    await tester.pumpAndSettle();
    expect(find.text('Replace everything on this phone?'), findsOneWidget);
    // The restore starts once the dialog has closed, so let it close before waiting on the file work.
    await tester.tap(find.byKey(const Key('confirm-replace')));
    await tester.pumpAndSettle();
    await pumpUntilFound(tester, find.text('Restored 2 weights, 1 photo.'));
    expect(find.text('Restored 2 weights, 1 photo.'), findsOneWidget);

    await tester.runAsync(() async {
      expect([for (final w in await newDb.select(newDb.weights).get()) w.kg]..sort(), [83.7, 89.4]);
      final photo = (await newDb.select(newDb.progressPhotos).get()).single;
      expect(photoFile(newPhotos, photo).readAsBytesSync(), onePixel);
    });
    await tester.tap(find.byKey(const Key('restore-done')));
    await tester.pumpAndSettle();
    expect(find.byType(BackupScreen), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('adding what is missing is the default, and a file that is not a backup changes nothing', (tester) async {
    dir = Directory.systemTemp.createTempSync('aloft_backup_ui');
    addTearDown(() => dir.deleteSync(recursive: true));
    files = FakeFiles(dir);
    final (db, settings, photos) = await phone(tester, 'only');
    await tester.runAsync(() => db.logWeight(kg: 80, measuredAt: DateTime(2026, 11, 20, 7)));

    files.toPick = File('${dir.path}/holiday.zip')..writeAsStringSync('not a backup');
    await show(tester, db, settings, photos);
    await tapAndWait(tester, find.byKey(const Key('restore-backup')));
    expect(tester.widget<Text>(find.byKey(const Key('backup-problem'))).data, "That file isn't an Aloft backup.");
    expect(find.byType(RestoreScreen), findsNothing);

    // Its own backup, restored over itself: nothing to add.
    final own = File('${dir.path}/own.zip');
    late OpenedBackup opened;
    await tester.runAsync(() async {
      await db.writeBackup(to: own, photoFolder: photos, now: DateTime(2026, 11, 21, 20, 5));
      opened = await openBackup(own, currentSchemaVersion: db.schemaVersion);
    });
    expect(opened.summary.count('weights'), 1);
    files.toPick = own;
    await tapAndWait(tester, find.byKey(const Key('restore-backup')));
    expect(find.textContaining('Backup from Nov 21, 2026'), findsOneWidget);
    await tapAndWait(tester, find.byKey(const Key('restore-now')));
    expect(find.text('Everything in this backup was already on this phone. Nothing was added.'), findsOneWidget);
    await tester.runAsync(() async => expect((await db.select(db.weights).get()).single.kg, 80));
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('Export as CSV shares a zip of spreadsheet files and leaves no copy behind', (tester) async {
    dir = Directory.systemTemp.createTempSync('aloft_backup_ui');
    addTearDown(() => dir.deleteSync(recursive: true));
    files = FakeFiles(dir);
    final (db, settings, photos) = await phone(tester, 'only');
    await tester.runAsync(() => db.logWeight(kg: 89.4, measuredAt: DateTime(2026, 9, 4, 7)));
    await show(tester, db, settings, photos);
    // Says plainly that it is neither a backup nor locked.
    expect(find.textContaining("can't be restored"), findsOneWidget);
    expect(find.textContaining("isn't locked"), findsOneWidget);

    await tapAndWait(tester, find.byKey(const Key('export-csv')));
    expect(files.shared!.uri.pathSegments.last, startsWith('Aloft export '));
    final names = ZipDecoder().decodeBytes(files.shared!.readAsBytesSync()).files.map((f) => f.name);
    expect(names, ['doses.csv', 'weights.csv', 'side_effects.csv', 'notes.csv']);
    expect(files.sharedFrom!.existsSync(), isFalse);
    await tester.runAsync(db.close);
  });
}
