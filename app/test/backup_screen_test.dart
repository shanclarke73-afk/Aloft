import 'dart:io';

import 'package:aloft/backup/backup_file.dart';
import 'package:aloft/backup/backup_files.dart';
import 'package:aloft/data/body_store.dart';
import 'package:aloft/data/database.dart';
import 'package:aloft/data/encrypted_database.dart';
import 'package:aloft/data/photo_store.dart';
import 'package:aloft/features/backup/backup_screen.dart';
import 'package:aloft/features/report/report_screen.dart';
import 'package:aloft/photos/photo_picker.dart';
import 'package:aloft/pro/pro.dart';
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

  /// The phone's set folder, in words; null for a phone that has none.
  String? place;
  File? savedOnPhone;

  @override
  Future<String?> saveOnPhone(File file) async {
    if (place == null) return null;
    savedOnPhone = file.copySync('${keepIn.path}/on-phone-${file.uri.pathSegments.last}');
    return place;
  }
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

  Future<void> show(
    WidgetTester tester,
    AloftDatabase db,
    AppSettings settings,
    Directory photos, {
    bool pro = true,
    Widget screen = const BackupScreen(),
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        key: UniqueKey(),
        overrides: [
          proProvider.overrideWithBuild((ref, notifier) => pro),
          databaseProvider.overrideWithValue(db),
          initialSettingsProvider.overrideWithValue(settings),
          photoFolderProvider.overrideWithValue(photos),
          backupFilesProvider.overrideWithValue(files),
        ],
        child: MaterialApp(home: screen),
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
    // Remembered, so Today's reminder to save a backup stays quiet for a while.
    await tester.runAsync(() async {
      final saved = (await oldDb.loadSettings()).lastBackupAt;
      expect(saved, isNotNull);
      expect(DateTime.now().difference(saved!).inMinutes, 0);
    });

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

  testWidgets('a backup goes straight to the phone\'s folder without asking, or can be sent elsewhere', (tester) async {
    dir = Directory.systemTemp.createTempSync('aloft_backup_ui');
    addTearDown(() => dir.deleteSync(recursive: true));
    files = FakeFiles(dir)..place = 'Documents › Aloft';
    final (db, settings, photos) = await phone(tester, 'only');
    await tester.runAsync(() => db.logWeight(kg: 89.4, measuredAt: DateTime(2026, 9, 4, 7)));
    await show(tester, db, settings, photos);
    // Says that a copy on the phone alone isn't enough.
    expect(find.textContaining("won't help if the phone is lost"), findsOneWidget);

    await tapAndWait(tester, find.byKey(const Key('save-backup')));
    await pumpUntilFound(tester, find.byKey(const Key('saved-to')));
    expect(files.shared, isNull, reason: 'no share sheet');
    final name = files.savedOnPhone!.uri.pathSegments.last.replaceFirst('on-phone-', '');
    expect(find.text('Saved to Documents › Aloft as $name.'), findsOneWidget);
    await tester.runAsync(() async {
      // What landed there is a real backup, and it counts for the Today reminder.
      final opened = await openBackup(files.savedOnPhone!, currentSchemaVersion: db.schemaVersion);
      expect(opened.tables['weights']!.length, 1);
      expect((await db.loadSettings()).lastBackupAt, isNotNull);
    });

    await tapAndWait(tester, find.byKey(const Key('send-backup')));
    expect(files.shared, isNotNull);
    expect(find.byKey(const Key('saved-to')), findsNothing);
    await tester.runAsync(db.close);
  });

  testWidgets('without Pro, Export as CSV shows what Pro is and exports nothing', (tester) async {
    dir = Directory.systemTemp.createTempSync('aloft_backup_ui');
    addTearDown(() => dir.deleteSync(recursive: true));
    files = FakeFiles(dir);
    final (db, settings, photos) = await phone(tester, 'only');
    await show(tester, db, settings, photos, pro: false);
    final button = find.byKey(const Key('export-csv'));
    await tester.ensureVisible(button);
    await tester.pumpAndSettle();
    expect(find.text('Export as CSV · Aloft Pro'), findsOneWidget);
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(find.byType(ProScreen), findsOneWidget);
    expect(find.text('Report for your provider'), findsOneWidget);
    // It explains; it doesn't sell. Nothing on it can be bought yet.
    expect(find.textContaining("isn't available in this version"), findsOneWidget);
    expect(find.byType(FilledButton), findsNothing);
    expect(files.shared, isNull);
    // Backups stay free.
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    await tapAndWait(tester, find.byKey(const Key('send-backup')));
    expect(files.shared, isNotNull);
    await tester.runAsync(db.close);
  });

  testWidgets('the provider report is saved as a PDF for the chosen period and paper', (tester) async {
    dir = Directory.systemTemp.createTempSync('aloft_backup_ui');
    addTearDown(() => dir.deleteSync(recursive: true));
    files = FakeFiles(dir)..place = 'Documents › Aloft';
    final (db, settings, photos) = await phone(tester, 'only');
    await tester.runAsync(() async {
      await db.logWeight(kg: 89.4, measuredAt: DateTime(2026, 9, 4, 7));
      await db.logWeight(kg: 83.7, measuredAt: DateTime(2026, 11, 20, 7));
    });
    await show(tester, db, settings, photos, screen: ReportScreen(now: DateTime(2026, 11, 22, 9)));
    expect(find.textContaining("isn't medical advice"), findsOneWidget);
    expect(find.textContaining("isn't locked"), findsOneWidget);

    await tester.tap(find.byKey(const Key('period-all')));
    await tester.tap(find.text('A4'));
    await tester.pump();
    await tapAndWait(tester, find.byKey(const Key('report-save')));
    await pumpUntilFound(tester, find.byKey(const Key('report-message')));
    expect(find.text('Saved to Documents › Aloft as Aloft report 2026-11-22.pdf.'), findsOneWidget);
    final bytes = files.savedOnPhone!.readAsBytesSync();
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    expect(files.shared, isNull);

    await tapAndWait(tester, find.byKey(const Key('report-send')));
    await pumpUntilFound(tester, find.text('Send the report somewhere else'));
    expect(files.shared!.path, endsWith('Aloft report 2026-11-22.pdf'));
    await tester.runAsync(db.close);
  });
}
