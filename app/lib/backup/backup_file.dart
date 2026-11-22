import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:archive/archive_io.dart';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;

import '../data/database.dart';

/// Version of the backup file's own layout (not the database's).
const backupFormat = 1;

/// Something went wrong that the person can be told about in plain words.
class BackupProblem implements Exception {
  const BackupProblem(this.message);
  final String message;

  @override
  String toString() => message;
}

/// The backup is locked with a password, and none (or the wrong one) was given.
class BackupPasswordNeeded implements Exception {
  const BackupPasswordNeeded();
}

/// What a backup file says about itself, shown before anything is restored.
class BackupSummary {
  const BackupSummary({
    required this.createdAt,
    required this.madeOn,
    required this.schemaVersion,
    required this.counts,
    required this.photoFiles,
  });
  final DateTime createdAt;

  /// "iPhone" or "Android".
  final String madeOn;
  final int schemaVersion;

  /// Rows per table, by table name.
  final Map<String, int> counts;
  final int photoFiles;

  int count(String table) => counts[table] ?? 0;
}

/// A backup that has been opened and checked, ready to restore.
class OpenedBackup {
  const OpenedBackup({required this.file, required this.password, required this.summary, required this.tables});
  final File file;
  final String? password;
  final BackupSummary summary;
  final Map<String, List<Map<String, Object?>>> tables;
}

/// How many records a restore added, by table name.
typedef RestoreResult = ({Map<String, int> added, int photos});

/// A photo file name Aloft itself would have made. Anything else in a backup is ignored, so a
/// crafted file can't write outside the photos folder.
final _safePhotoName = RegExp(r'^[A-Za-z0-9-]{1,64}\.[a-z0-9]{1,5}$');

// The isolate work lives in top-level functions so the closures sent to the other isolate
// carry only these plain values, never the database.
Future<void> _zip(String outPath, String? password, String manifest, String data, List<String> photoPaths) {
  return Isolate.run(() {
    final zip = ZipFileEncoder(password: password)..create(outPath);
    try {
      zip.addArchiveFile(ArchiveFile.string('manifest.json', manifest));
      zip.addArchiveFile(ArchiveFile.string('data.json', data));
      for (final path in photoPaths) {
        // Photos are already compressed; storing them as they are is much faster.
        zip.addFileSync(File(path), 'photos/${p.basename(path)}', ZipFileEncoder.store);
      }
    } finally {
      zip.closeSync();
    }
  });
}

Future<void> _unzipPhotos(String zipPath, String? password, String intoPath, Set<String> wanted) {
  return Isolate.run(() {
    final input = InputFileStream(zipPath);
    try {
      for (final entry in ZipDecoder().decodeStream(input, password: password).files) {
        if (!entry.isFile || !entry.name.startsWith('photos/')) continue;
        final name = entry.name.substring('photos/'.length);
        if (!wanted.contains(name)) continue;
        final out = OutputFileStream(p.join(intoPath, name));
        try {
          entry.writeContent(out);
        } finally {
          out.closeSync();
        }
      }
    } finally {
      input.closeSync();
    }
  });
}

String _platformName() => Platform.isIOS ? 'iPhone' : (Platform.isAndroid ? 'Android' : Platform.operatingSystem);

extension BackupData on AloftDatabase {
  /// Parents before children, so rows can be put back in this order.
  List<TableInfo<Table, Object?>> get _backupTables => [
    appSettingsTable,
    medications,
    supplies,
    prescriptions,
    doses,
    weights,
    sideEffects,
    dayNotes,
    progressPhotos,
  ];

  /// Deletes everything the person has entered: medications, shots, weights, side effects,
  /// notes, photos and their files, the goal weight and height. Units, reminder switches and
  /// the lock stay, and the welcome screens are not shown again. Cannot be undone.
  Future<void> deleteAllData({required Directory photoFolder}) async {
    await transaction(() async {
      for (final table in _backupTables.reversed) {
        if (table != appSettingsTable) await customStatement('DELETE FROM "${table.actualTableName}"');
      }
      await customStatement('UPDATE "app_settings" SET "goal_weight_kg" = NULL, "height_cm" = NULL');
    });
    markTablesUpdated(allTables);
    if (photoFolder.existsSync()) photoFolder.deleteSync(recursive: true);
  }

  /// Every row of every table, as stored. One consistent moment: nothing can change part-way.
  Future<Map<String, List<Map<String, Object?>>>> _dump() {
    return transaction(() async {
      return {
        for (final table in _backupTables)
          table.actualTableName: [
            for (final row in await customSelect('SELECT * FROM "${table.actualTableName}"').get())
              Map<String, Object?>.from(row.data),
          ],
      };
    });
  }

  /// Writes a backup file: every record, plus the photo files when [includePhotos] is on.
  /// With a [password] the whole file is encrypted (AES-256) and can't be read without it.
  Future<BackupSummary> writeBackup({
    required File to,
    required Directory photoFolder,
    bool includePhotos = true,
    String? password,
    DateTime? now,
  }) async {
    final tables = await _dump();
    // Without the files, photo records would point at nothing after a restore.
    if (!includePhotos) tables[progressPhotos.actualTableName] = [];
    final photoPaths = [
      for (final row in tables[progressPhotos.actualTableName]!)
        if (_safePhotoName.hasMatch(row['file_name'] as String) &&
            File(p.join(photoFolder.path, row['file_name'] as String)).existsSync())
          p.join(photoFolder.path, row['file_name'] as String),
    ];
    final summary = BackupSummary(
      createdAt: now ?? DateTime.now(),
      madeOn: _platformName(),
      schemaVersion: schemaVersion,
      counts: {for (final entry in tables.entries) entry.key: entry.value.length},
      photoFiles: photoPaths.length,
    );
    final manifest = jsonEncode({
      'app': 'aloft',
      'format': backupFormat,
      'createdAt': summary.createdAt.toIso8601String(),
      'madeOn': summary.madeOn,
      'schemaVersion': summary.schemaVersion,
      'counts': summary.counts,
      'photoFiles': summary.photoFiles,
    });
    final data = jsonEncode(tables);
    final secret = password == null || password.isEmpty ? null : password;
    await _zip(to.path, secret, manifest, data, photoPaths);
    return summary;
  }

  /// Puts a backup's records and photos onto this phone.
  ///
  /// With [replace], what's on the phone now is removed first. Without it, only records the
  /// phone doesn't already have are added, and nothing is removed or changed. Either way it
  /// is all-or-nothing for the records: if anything fails, the phone's data is left as it was.
  Future<RestoreResult> restoreBackup(
    OpenedBackup backup, {
    required Directory photoFolder,
    required bool replace,
  }) async {
    // 1. Unpack the photos to one side first, so a damaged file fails before anything changes.
    final staging = Directory('${photoFolder.path}.restoring');
    if (staging.existsSync()) staging.deleteSync(recursive: true);
    staging.createSync(recursive: true);
    try {
      final zipPath = backup.file.path, stagingPath = staging.path, secret = backup.password;
      final wanted = {
        for (final row in backup.tables[progressPhotos.actualTableName] ?? const <Map<String, Object?>>[])
          if (row['file_name'] case final String name when _safePhotoName.hasMatch(name)) name,
      };
      try {
        await _unzipPhotos(zipPath, secret, stagingPath, wanted);
      } catch (_) {
        throw const BackupProblem("The photos in this backup couldn't be read. Nothing was changed.");
      }

      // 2. The records, in one transaction.
      final added = <String, int>{};
      try {
        await transaction(() async {
          Future<int> rows(TableInfo<Table, Object?> t) async =>
              (await customSelect('SELECT count(*) AS n FROM "${t.actualTableName}"').getSingle()).read<int>('n');
          if (replace) {
            for (final table in _backupTables.reversed) {
              if (table != appSettingsTable) await customStatement('DELETE FROM "${table.actualTableName}"');
            }
          }
          for (final table in _backupTables) {
            final name = table.actualTableName;
            final known = {for (final c in table.$columns) c.name};
            final before = await rows(table);
            for (final row in backup.tables[name] ?? const <Map<String, Object?>>[]) {
              // An older backup may lack newer columns (they take their defaults); unknown ones are skipped.
              final columns = [
                for (final key in row.keys)
                  if (known.contains(key)) key,
              ];
              if (table == appSettingsTable) {
                // Units and reminder choices come back only when replacing. The lock and app-switcher
                // choices, and whether the welcome screens are done, always stay as they are on this phone.
                if (!replace) continue;
                final keep = columns.where(
                  (c) => !const {'id', 'app_lock', 'lock_after', 'hide_in_app_switcher', 'onboarding_done'}.contains(c),
                );
                if (keep.isEmpty) continue;
                await customStatement('UPDATE "$name" SET ${keep.map((c) => '"$c" = ?').join(', ')}', [
                  for (final c in keep) row[c],
                ]);
                continue;
              }
              if (table == progressPhotos) {
                final fileName = row['file_name'];
                // Only names Aloft itself makes; anything else could point outside the photos folder.
                if (fileName is! String || !_safePhotoName.hasMatch(fileName)) continue;
                // No file for this photo in the backup: keep the record only if the phone has the file.
                if (!File(p.join(staging.path, fileName)).existsSync() &&
                    !File(p.join(photoFolder.path, fileName)).existsSync()) {
                  continue;
                }
              }
              await customStatement(
                'INSERT OR IGNORE INTO "$name" (${columns.map((c) => '"$c"').join(', ')}) '
                'VALUES (${List.filled(columns.length, '?').join(', ')})',
                [for (final c in columns) row[c]],
              );
            }
            if (table != appSettingsTable) added[name] = (await rows(table)) - (replace ? 0 : before);
          }
        });
      } on BackupProblem {
        rethrow;
      } catch (_) {
        throw const BackupProblem("This backup couldn't be restored. Nothing was changed.");
      }
      markTablesUpdated(allTables);

      // 3. Photos into place. Files the phone already has are left alone.
      photoFolder.createSync(recursive: true);
      var photos = 0;
      for (final file in staging.listSync().whereType<File>()) {
        final target = File(p.join(photoFolder.path, p.basename(file.path)));
        if (!target.existsSync()) {
          file.copySync(target.path);
          photos++;
        }
      }
      if (replace) {
        // Photo files that no record points at any more.
        final kept = {for (final row in await select(progressPhotos).get()) row.fileName};
        for (final file in photoFolder.listSync().whereType<File>()) {
          if (!kept.contains(p.basename(file.path))) file.deleteSync();
        }
      }
      return (added: added, photos: photos);
    } finally {
      if (staging.existsSync()) staging.deleteSync(recursive: true);
    }
  }
}

/// Opens a backup file and checks it, without changing anything on the phone.
Future<OpenedBackup> openBackup(File file, {String? password, required int currentSchemaVersion}) async {
  final path = file.path;
  final secret = password == null || password.isEmpty ? null : password;
  final (String? manifestText, String? dataText) = await Isolate.run(() {
    final InputFileStream input;
    try {
      input = InputFileStream(path);
    } catch (_) {
      return (null, null);
    }
    try {
      final archive = ZipDecoder().decodeStream(input, password: secret);
      String? text(String name) => switch (archive.findFile(name)?.readBytes()) {
        null => null,
        final bytes => utf8.decode(bytes, allowMalformed: true),
      };
      return (text('manifest.json'), text('data.json'));
    } on ArchivePasswordException {
      return ('password', null);
    } catch (_) {
      return (null, null);
    } finally {
      input.closeSync();
    }
  });
  if (manifestText == 'password' && dataText == null) throw const BackupPasswordNeeded();
  const notOurs = BackupProblem("That file isn't an Aloft backup.");
  if (manifestText == null || dataText == null) throw notOurs;
  final Map<String, dynamic> manifest;
  final Map<String, List<Map<String, Object?>>> tables;
  try {
    manifest = jsonDecode(manifestText) as Map<String, dynamic>;
    if (manifest['app'] != 'aloft') throw notOurs;
    tables = {
      for (final MapEntry(:key, :value) in (jsonDecode(dataText) as Map<String, dynamic>).entries)
        key: [for (final row in value as List) Map<String, Object?>.from(row as Map)],
    };
  } on BackupProblem {
    rethrow;
  } catch (_) {
    throw notOurs;
  }
  final format = manifest['format'], schema = manifest['schemaVersion'];
  if (format is! int || schema is! int) throw notOurs;
  if (format > backupFormat || schema > currentSchemaVersion) {
    throw const BackupProblem('This backup was made by a newer version of Aloft. Update Aloft, then try again.');
  }
  return OpenedBackup(
    file: file,
    password: secret,
    tables: tables,
    summary: BackupSummary(
      createdAt: DateTime.tryParse('${manifest['createdAt']}') ?? DateTime.fromMillisecondsSinceEpoch(0),
      madeOn: '${manifest['madeOn'] ?? ''}',
      schemaVersion: schema,
      // Counted from the records themselves, not taken on trust from the label.
      counts: {for (final entry in tables.entries) entry.key: entry.value.length},
      photoFiles: manifest['photoFiles'] is int ? manifest['photoFiles'] as int : 0,
    ),
  );
}

/// "Aloft backup 2026-11-21.zip"
String backupFileName(DateTime now) =>
    'Aloft backup ${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}.zip';
