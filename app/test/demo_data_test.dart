import 'dart:io';

import 'package:aloft/data/body_store.dart';
import 'package:aloft/data/encrypted_database.dart';
import 'package:aloft/data/medication_store.dart';
import 'package:aloft/demo/demo_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the screenshot history is a finished setup with a shot due today and a believable vial', () async {
    final dir = Directory.systemTemp.createTempSync('aloft_demo');
    addTearDown(() => dir.deleteSync(recursive: true));
    final db = openEncryptedDatabase(File('${dir.path}/demo.db'), generateDatabaseKey());
    addTearDown(db.close);
    final now = DateTime(2026, 11, 25, 9, 41);
    await seedDemoData(db, now: now);

    final settings = await db.loadSettings();
    expect(settings.onboardingDone, isTrue);
    expect(settings.goalWeightKg, isNotNull);

    final detail = (await db.watchMedications().first).single;
    expect(detail.medication.scheduleDays, [now.weekday]);
    expect(await db.select(db.doses).get(), hasLength(12));
    // 4 x 0.1 mL, 4 x 0.2 mL and 4 x 0.4 mL from a 4 mL vial leaves three more doses.
    expect(detail.usedMl, closeTo(2.8, 0.001));
    final weights = await db.watchWeights().first;
    expect(weights, hasLength(13));
    expect(weights.first.kg, lessThan(weights.last.kg));
  });
}
