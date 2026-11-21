import 'dart:convert';
import 'dart:io';

import 'package:aloft/data/database.dart';
import 'package:aloft/data/encrypted_database.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  late Directory dir;
  late File file;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('aloft_test');
    file = File('${dir.path}/aloft.db');
  });
  tearDown(() => dir.deleteSync(recursive: true));

  test('a new key is 64 hex characters and different every time', () {
    final a = generateDatabaseKey();
    expect(a, matches(RegExp(r'^[0-9a-f]{64}$')));
    expect(generateDatabaseKey(), isNot(a));
  });

  test('the file on disk is encrypted and only opens with its key', () async {
    final key = generateDatabaseKey();
    final db = openEncryptedDatabase(file, key);
    await db.loadSettings(countryCode: 'US');
    await db.close();

    // A plain SQLite file starts with this text; an encrypted one must not.
    final header = latin1.decode(file.readAsBytesSync().sublist(0, 16));
    expect(header, isNot(startsWith('SQLite format 3')));

    final wrongKey = sqlite3.open(file.path);
    expect(() => applyDatabaseKey(wrongKey, generateDatabaseKey()), throwsA(isA<SqliteException>()));
    wrongKey.close();

    final reopened = openEncryptedDatabase(file, key);
    expect((await reopened.loadSettings()).weightUnit, WeightUnit.lb);
    await reopened.close();
  });

  test('a malformed key is refused', () {
    final db = sqlite3.openInMemory();
    expect(() => applyDatabaseKey(db, "abc'; --"), throwsA(isA<DatabaseUnavailable>()));
    db.close();
  });

  test('settings start in lb and inches in the US, kg and cm elsewhere, then stick', () async {
    var db = openEncryptedDatabase(file, generateDatabaseKey());
    final us = await db.loadSettings(countryCode: 'US');
    expect((us.weightUnit, us.lengthUnit), (WeightUnit.lb, LengthUnit.inches));
    expect((us.appLock, us.lockAfter, us.hideInAppSwitcher), (false, LockAfter.immediately, true));
    // The country is only used on first launch.
    expect((await db.loadSettings(countryCode: 'CA')).weightUnit, WeightUnit.lb);
    await db.close();

    final other = File('${dir.path}/other.db');
    db = openEncryptedDatabase(other, generateDatabaseKey());
    final ca = await db.loadSettings(countryCode: 'CA');
    expect((ca.weightUnit, ca.lengthUnit), (WeightUnit.kg, LengthUnit.cm));
    await db.close();
  });

  test('saved settings survive closing and reopening', () async {
    final key = generateDatabaseKey();
    var db = openEncryptedDatabase(file, key);
    await db.loadSettings(countryCode: 'US');
    final saved = await db.saveSettings(
      const AppSettingsTableCompanion(appLock: Value(true), lockAfter: Value(LockAfter.oneMinute)),
    );
    expect(saved.appLock, isTrue);
    await db.close();

    db = openEncryptedDatabase(file, key);
    final loaded = await db.loadSettings();
    expect((loaded.appLock, loaded.lockAfter), (true, LockAfter.oneMinute));
    await db.close();
  });
}
