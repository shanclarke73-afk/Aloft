import 'dart:io';
import 'dart:math';

import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart' show Database;

import 'database.dart';
import '../util/device.dart';

/// Thrown when the database file exists but can't be opened. The file is never deleted or
/// replaced automatically: it may be the only copy of someone's history.
class DatabaseUnavailable implements Exception {
  const DatabaseUnavailable(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Where the database key lives: iOS Keychain / Android Keystore.
abstract class DatabaseKeyStore {
  Future<String?> read();
  Future<void> write(String keyHex);
}

class SecureDatabaseKeyStore implements DatabaseKeyStore {
  const SecureDatabaseKeyStore();

  static const _name = 'aloft.database.key.v1';
  // Readable after the first unlock so reminders can use the database later, and included
  // in encrypted phone-to-phone transfers so the data still opens on a new iPhone.
  static const _storage = FlutterSecureStorage(iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock));

  @override
  Future<String?> read() => _storage.read(key: _name);

  @override
  Future<void> write(String keyHex) => _storage.write(key: _name, value: keyHex);
}

/// A new random 256-bit key, as 64 hex characters.
String generateDatabaseKey() {
  final random = Random.secure();
  return List.generate(32, (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0')).join();
}

/// Applies the key to a freshly opened connection and refuses to continue if this SQLite
/// build can't encrypt, so health data is never written in plain form by mistake.
void applyDatabaseKey(Database db, String keyHex) {
  if (!RegExp(r'^[0-9a-f]{64}$').hasMatch(keyHex)) {
    throw const DatabaseUnavailable('The database key is not valid.');
  }
  db.execute('PRAGMA key = "x\'$keyHex\'"');
  if (db.select('PRAGMA cipher_version').isEmpty) {
    throw const DatabaseUnavailable('This build of Aloft cannot encrypt its database.');
  }
  // Fails here, not later, when the key is wrong.
  db.select('SELECT count(*) FROM sqlite_master');
  db.execute('PRAGMA foreign_keys = ON');
}

AloftDatabase openEncryptedDatabase(File file, String keyHex) {
  return AloftDatabase(NativeDatabase.createInBackground(file, setup: (db) => applyDatabaseKey(db, keyHex)));
}

/// Opens the app's database, creating the key and file on first launch.
Future<AloftDatabase> openAppDatabase({DatabaseKeyStore keyStore = const SecureDatabaseKeyStore()}) async {
  final dir = await getApplicationSupportDirectory();
  final file = File(p.join(dir.path, 'aloft.db'));
  var key = await keyStore.read();
  if (key == null) {
    if (await file.exists()) {
      throw DatabaseUnavailable(
        'Aloft found your data on this $deviceWord but not the key that opens it. '
        'Nothing has been deleted. Contact support before reinstalling.',
      );
    }
    key = generateDatabaseKey();
    await keyStore.write(key);
  }
  return openEncryptedDatabase(file, key);
}
