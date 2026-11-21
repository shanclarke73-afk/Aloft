import 'dart:io';

import 'package:aloft/backup/backup_file.dart';
import 'package:aloft/data/body_store.dart';
import 'package:aloft/data/database.dart';
import 'package:aloft/data/encrypted_database.dart';
import 'package:aloft/data/medication_store.dart';
import 'package:aloft/data/photo_store.dart';
import 'package:aloft/dose/dose_math.dart';
import 'package:archive/archive_io.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

import 'medication_store_test.dart' show tirzepatideVial;
import 'photos_test.dart' show onePixel;

void main() {
  late Directory dir;
  late AloftDatabase db;
  late Directory photos;
  var phones = 0;

  /// A separate "phone": its own database, key and photos folder.
  (AloftDatabase, Directory) newPhone() {
    final home = Directory('${dir.path}/phone${phones++}')..createSync();
    return (
      openEncryptedDatabase(File('${home.path}/aloft.db'), generateDatabaseKey()),
      Directory('${home.path}/photos'),
    );
  }

  /// Settings, a vial with two shots, two weights, a side effect, a note and two photos.
  Future<void> fill(AloftDatabase db, Directory photos) async {
    await db.loadSettings(countryCode: 'US');
    await db.saveSettings(const AppSettingsTableCompanion(weightUnit: Value(WeightUnit.kg), appLock: Value(true)));
    await db.addMedication(tirzepatideVial);
    final med = (await db.watchMedications().first).single;
    for (final day in [13, 20]) {
      await db.logDose(
        medication: med.medication,
        supply: med.supply!,
        amount: 25,
        unit: DoseUnit.units,
        takenAt: DateTime(2026, 11, day, 20),
      );
    }
    await db.logWeight(kg: 89.4, measuredAt: DateTime(2026, 9, 4, 7));
    await db.logWeight(kg: 83.7, measuredAt: DateTime(2026, 11, 20, 7));
    await db.logSideEffects(severities: {SideEffectType.nausea: 3}, occurredAt: DateTime(2026, 11, 21, 9));
    await db.into(db.dayNotes).insert(DayNotesCompanion.insert(noteDate: DateTime(2026, 11, 21), body: 'Felt fine'));
    final source = File('${dir.path}/src.jpg')..writeAsBytesSync(onePixel);
    await db.addPhoto(photos, source: source, pose: PhotoPose.front, takenAt: DateTime(2026, 9, 4, 8));
    await db.addPhoto(photos, source: source, pose: PhotoPose.front, takenAt: DateTime(2026, 11, 20, 8));
  }

  Future<Map<String, int>> counts(AloftDatabase db) async => {
    'medications': (await db.select(db.medications).get()).length,
    'supplies': (await db.select(db.supplies).get()).length,
    'prescriptions': (await db.select(db.prescriptions).get()).length,
    'doses': (await db.select(db.doses).get()).length,
    'weights': (await db.select(db.weights).get()).length,
    'side_effects': (await db.select(db.sideEffects).get()).length,
    'day_notes': (await db.select(db.dayNotes).get()).length,
    'progress_photos': (await db.select(db.progressPhotos).get()).length,
  };
  const full = {
    'medications': 1,
    'supplies': 1,
    'prescriptions': 1,
    'doses': 2,
    'weights': 2,
    'side_effects': 1,
    'day_notes': 1,
    'progress_photos': 2,
  };

  setUp(() async {
    dir = Directory.systemTemp.createTempSync('aloft_backup');
    (db, photos) = newPhone();
    await fill(db, photos);
  });
  tearDown(() async {
    await db.close();
    dir.deleteSync(recursive: true);
  });

  Future<OpenedBackup> backUp({bool includePhotos = true, String? password, String? openWith}) async {
    final file = File('${dir.path}/${backupFileName(DateTime(2026, 11, 21))}');
    await db.writeBackup(
      to: file,
      photoFolder: photos,
      includePhotos: includePhotos,
      password: password,
      now: DateTime(2026, 11, 21, 20, 5),
    );
    return openBackup(file, password: openWith ?? password, currentSchemaVersion: db.schemaVersion);
  }

  test('the file is named for its date and describes what is inside', () async {
    final backup = await backUp();
    expect(backup.file.path, endsWith('Aloft backup 2026-11-21.zip'));
    final s = backup.summary;
    expect((s.createdAt, s.schemaVersion, s.photoFiles), (DateTime(2026, 11, 21, 20, 5), db.schemaVersion, 2));
    expect((s.count('doses'), s.count('weights'), s.count('progress_photos'), s.count('nothing')), (2, 2, 2, 0));
  });

  test('a new phone gets everything back, exactly as it was', () async {
    final backup = await backUp();
    final (phone, phonePhotos) = newPhone();
    addTearDown(phone.close);
    await phone.loadSettings(countryCode: 'US');
    final result = await phone.restoreBackup(backup, photoFolder: phonePhotos, replace: true);
    expect(result.added, full);
    expect(result.photos, 2);
    expect(await counts(phone), full);

    // Row for row, the same data.
    expect('${await phone.select(phone.doses).get()}', '${await db.select(db.doses).get()}');
    expect('${await phone.select(phone.supplies).get()}', '${await db.select(db.supplies).get()}');
    expect('${await phone.select(phone.weights).get()}', '${await db.select(db.weights).get()}');
    final detail = (await phone.watchMedications().first).single;
    expect((detail.medication.name, detail.lastLogged?.takenAt), (tirzepatideVial.name, DateTime(2026, 11, 20, 20)));
    for (final photo in await phone.select(phone.progressPhotos).get()) {
      expect(photoFile(phonePhotos, photo).readAsBytesSync(), onePixel);
    }
    // Units come back; the lock stays as it was set on the new phone.
    final settings = await phone.loadSettings();
    expect((settings.weightUnit, settings.appLock), (WeightUnit.kg, false));
  });

  test('replacing removes what the phone had, including its photo files', () async {
    final backup = await backUp();
    final (phone, phonePhotos) = newPhone();
    addTearDown(phone.close);
    await phone.loadSettings(countryCode: 'US');
    await phone.logWeight(kg: 70, measuredAt: DateTime(2026, 1, 1));
    final own = await phone.addPhoto(
      phonePhotos,
      source: File('${dir.path}/src.jpg'),
      pose: PhotoPose.back,
      takenAt: DateTime(2026, 1, 1),
    );
    await phone.restoreBackup(backup, photoFolder: phonePhotos, replace: true);
    expect(await counts(phone), full);
    expect((await phone.select(phone.weights).get()).any((w) => w.kg == 70), isFalse);
    expect(photoFile(phonePhotos, own).existsSync(), isFalse);
    expect(phonePhotos.listSync().length, 2);
  });

  test('adding what is missing keeps what the phone has, and doing it twice adds nothing', () async {
    final backup = await backUp();
    final (phone, phonePhotos) = newPhone();
    addTearDown(phone.close);
    await phone.loadSettings(countryCode: 'US');
    await phone.logWeight(kg: 70, measuredAt: DateTime(2026, 1, 1));
    var result = await phone.restoreBackup(backup, photoFolder: phonePhotos, replace: false);
    expect(result.added, full);
    expect(await counts(phone), {...full, 'weights': 3});
    // This phone's own units are left alone.
    expect((await phone.loadSettings()).weightUnit, WeightUnit.lb);

    result = await phone.restoreBackup(backup, photoFolder: phonePhotos, replace: false);
    expect(result.added.values.every((n) => n == 0), isTrue);
    expect(result.photos, 0);
    expect(await counts(phone), {...full, 'weights': 3});
  });

  test('a backup without photos leaves photos out completely', () async {
    final backup = await backUp(includePhotos: false);
    expect((backup.summary.photoFiles, backup.summary.count('progress_photos')), (0, 0));
    final (phone, phonePhotos) = newPhone();
    addTearDown(phone.close);
    await phone.loadSettings(countryCode: 'US');
    await phone.restoreBackup(backup, photoFolder: phonePhotos, replace: true);
    expect(await counts(phone), {...full, 'progress_photos': 0});
  });

  test('a password locks the whole file', () async {
    final backup = await backUp(password: 'correct horse');
    expect(backup.summary.count('doses'), 2);
    // Nothing readable in the file itself, not even the names of medications.
    final raw = String.fromCharCodes(backup.file.readAsBytesSync());
    expect(raw.contains('Tirzepatide') || raw.contains('tirzepatide') || raw.contains('schemaVersion'), isFalse);
    for (final wrong in [null, '', 'Correct horse']) {
      await expectLater(
        openBackup(backup.file, password: wrong, currentSchemaVersion: db.schemaVersion),
        throwsA(isA<BackupPasswordNeeded>()),
      );
    }
    final (phone, phonePhotos) = newPhone();
    addTearDown(phone.close);
    await phone.loadSettings(countryCode: 'US');
    final result = await phone.restoreBackup(backup, photoFolder: phonePhotos, replace: true);
    expect(result.photos, 2);
    expect(await counts(phone), full);
  });

  test('files that are not Aloft backups are turned away in plain words', () async {
    Future<String> problem(File file, {int schema = 99}) async {
      try {
        await openBackup(file, currentSchemaVersion: schema);
        return 'opened';
      } on BackupProblem catch (e) {
        return e.message;
      }
    }

    final text = File('${dir.path}/notes.zip')..writeAsStringSync('hello');
    expect(await problem(text), "That file isn't an Aloft backup.");
    expect(await problem(File('${dir.path}/missing.zip')), "That file isn't an Aloft backup.");
    final otherZip = File('${dir.path}/other.zip');
    (ZipFileEncoder()..create(otherZip.path))
      ..addArchiveFile(ArchiveFile.string('manifest.json', '{"app":"something else","format":1,"schemaVersion":1}'))
      ..addArchiveFile(ArchiveFile.string('data.json', '{}'))
      ..closeSync();
    expect(await problem(otherZip), "That file isn't an Aloft backup.");

    final real = await backUp();
    expect(await problem(real.file, schema: db.schemaVersion - 1), contains('newer version of Aloft'));
  });

  test('a backup that cannot go in whole changes nothing', () async {
    final backup = await backUp();
    // A dose that points at a supply that isn't in the backup.
    final broken = OpenedBackup(
      file: backup.file,
      password: null,
      summary: backup.summary,
      tables: {
        ...backup.tables,
        'doses': [
          ...backup.tables['doses']!,
          {...backup.tables['doses']!.first, 'id': 'extra', 'supply_id': 'no-such-supply'},
        ],
      },
    );
    final (phone, phonePhotos) = newPhone();
    addTearDown(phone.close);
    await phone.loadSettings(countryCode: 'US');
    await phone.logWeight(kg: 70, measuredAt: DateTime(2026, 1, 1));
    await expectLater(
      phone.restoreBackup(broken, photoFolder: phonePhotos, replace: true),
      throwsA(isA<BackupProblem>().having((e) => e.message, 'message', contains('Nothing was changed'))),
    );
    expect((await phone.select(phone.weights).get()).single.kg, 70);
    expect(await phone.select(phone.doses).get(), isEmpty);
    expect(phonePhotos.existsSync() ? phonePhotos.listSync() : const [], isEmpty);
    expect(Directory('${phonePhotos.path}.restoring').existsSync(), isFalse);
  });

  test('file names in a backup cannot reach outside the photos folder', () async {
    final backup = await backUp();
    final sneaky = OpenedBackup(
      file: backup.file,
      password: null,
      summary: backup.summary,
      tables: {
        ...backup.tables,
        'progress_photos': [
          {...backup.tables['progress_photos']!.first, 'id': 'x', 'file_name': '../aloft.db'},
        ],
      },
    );
    final (phone, phonePhotos) = newPhone();
    addTearDown(phone.close);
    await phone.loadSettings(countryCode: 'US');
    final result = await phone.restoreBackup(sneaky, photoFolder: phonePhotos, replace: false);
    expect((result.photos, result.added['progress_photos']), (0, 0));
  });
}
