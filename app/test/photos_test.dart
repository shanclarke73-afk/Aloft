import 'dart:convert';
import 'dart:io';

import 'package:aloft/data/body_store.dart';
import 'package:aloft/data/database.dart';
import 'package:aloft/data/encrypted_database.dart';
import 'package:aloft/data/photo_store.dart';
import 'package:aloft/features/progress/photo_view_screen.dart';
import 'package:aloft/features/progress/progress_screen.dart';
import 'package:aloft/photos/photo_picker.dart';
import 'package:aloft/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' show sqlite3;

/// A real one-pixel PNG, so the screens have something they can draw.
final onePixel = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==',
);

class FakePicker implements PhotoPicker {
  FakePicker({this.library = const [], this.camera, this.cameraWorks = true});
  final List<PickedPhoto> library;
  final PickedPhoto? camera;
  final bool cameraWorks;

  @override
  Future<PickedPhoto?> fromCamera() async => cameraWorks ? camera : throw const CameraUnavailable();
  @override
  Future<List<PickedPhoto>> fromLibrary() async => library;
}

ProgressPhoto photo(String id, DateTime at, PhotoPose pose) =>
    ProgressPhoto(id: id, createdAt: at, updatedAt: at, takenAt: at, pose: pose, fileName: '$id.jpg');

void main() {
  group('sorting and wording', () {
    test('photos are grouped by day, newest day first, in pose order', () {
      final days = photoDays([
        photo('a', DateTime(2026, 9, 4, 8, 2), PhotoPose.back),
        photo('b', DateTime(2026, 11, 20, 7), PhotoPose.side),
        photo('c', DateTime(2026, 9, 4, 8), PhotoPose.front),
        photo('d', DateTime(2026, 11, 20, 23, 59), PhotoPose.front),
      ]);
      expect([for (final d in days) d.day], [DateTime(2026, 11, 20), DateTime(2026, 9, 4)]);
      expect([for (final d in days) d.photos.map((p) => p.id).join()], ['db', 'ca']);
      expect(photoDays([]), isEmpty);
    });

    test("a day's weight is the last one logged that day, never another day's", () {
      Weight w(String id, DateTime at, double kg) =>
          Weight(id: id, createdAt: at, updatedAt: at, measuredAt: at, kg: kg, source: WeightSource.manual);
      final weights = [
        w('1', DateTime(2026, 11, 20, 7), 84),
        w('2', DateTime(2026, 11, 20, 21), 84.5),
        w('3', DateTime(2026, 11, 19, 7), 85),
      ];
      expect(weightOnDay(weights, DateTime(2026, 11, 20))!.kg, 84.5);
      expect(weightOnDay(weights, DateTime(2026, 11, 21)), isNull);
    });

    test('time apart is in days, then weeks, then years, in either order', () {
      expect(describeApart(DateTime(2026, 11, 20, 9), DateTime(2026, 11, 20, 22)), 'same day');
      expect(describeApart(DateTime(2026, 11, 19, 23), DateTime(2026, 11, 20, 1)), '1 day apart');
      expect(describeApart(DateTime(2026, 11, 7), DateTime(2026, 11, 20)), '13 days apart');
      expect(describeApart(DateTime(2026, 9, 4), DateTime(2026, 11, 20)), '11 weeks apart');
      expect(describeApart(DateTime(2026, 11, 20), DateTime(2026, 9, 4)), '11 weeks apart');
      expect(describeApart(DateTime(2025, 11, 20), DateTime(2026, 11, 20)), '1 year apart');
      expect(describeApart(DateTime(2012, 8, 8), DateTime(2018, 3, 30)), '5.6 years apart');
    });

    test('the date inside a photo is read, and anything else is ignored', () {
      expect(parseExifDate('2025:01:06 08:30:15'), DateTime(2025, 1, 6, 8, 30, 15));
      expect(parseExifDate(' 2025:01:06 08:30:15 '), DateTime(2025, 1, 6, 8, 30, 15));
      for (final bad in [null, '', '0000:00:00 00:00:00', '2025:13:06 08:30:15', '2025-01-06', 'yesterday']) {
        expect(parseExifDate(bad), isNull, reason: '$bad');
      }
    });
  });

  group('saving', () {
    late Directory dir, folder;
    late AloftDatabase db;
    late File source;
    setUp(() {
      dir = Directory.systemTemp.createTempSync('aloft_photos');
      folder = Directory('${dir.path}/photos');
      db = openEncryptedDatabase(File('${dir.path}/aloft.db'), generateDatabaseKey());
      source = File('${dir.path}/IMG_0001.JPG')..writeAsBytesSync(onePixel);
    });
    tearDown(() async {
      await db.close();
      dir.deleteSync(recursive: true);
    });

    test('a photo is copied into the private folder and the original is left alone', () async {
      final saved = await db.addPhoto(folder, source: source, pose: PhotoPose.front, takenAt: DateTime(2026, 9, 4, 8));
      expect(saved.fileName, '${saved.id}.jpg');
      expect(photoFile(folder, saved).readAsBytesSync(), onePixel);
      expect(source.existsSync(), isTrue);
      expect(folder.listSync().length, 1);
      final all = await db.watchPhotos().first;
      expect((all.single.pose, all.single.takenAt), (PhotoPose.front, DateTime(2026, 9, 4, 8)));
    });

    test('pose and date can be changed, and deleting removes the file too', () async {
      final saved = await db.addPhoto(folder, source: source, pose: PhotoPose.front, takenAt: DateTime(2026, 9, 4, 8));
      final other = await db.addPhoto(folder, source: source, pose: PhotoPose.side, takenAt: DateTime(2026, 9, 5, 8));
      await db.updatePhoto(saved, pose: PhotoPose.back, takenAt: DateTime(2026, 8, 1, 8));
      var all = await db.watchPhotos().first;
      expect([for (final p in all) (p.pose, p.takenAt.month)], [(PhotoPose.side, 9), (PhotoPose.back, 8)]);

      await db.deletePhoto(folder, saved);
      all = await db.watchPhotos().first;
      expect(all.single.id, other.id);
      expect(photoFile(folder, saved).existsSync(), isFalse);
      expect(photoFile(folder, other).existsSync(), isTrue);
      // Deleting one whose file is already gone is not an error.
      photoFile(folder, other).deleteSync();
      await db.deletePhoto(folder, other);
      expect(await db.watchPhotos().first, isEmpty);
    });

    test('a photo that cannot be read saves nothing', () async {
      final missing = File('${dir.path}/gone.jpg');
      await expectLater(
        db.addPhoto(folder, source: missing, pose: PhotoPose.front, takenAt: DateTime(2026, 9, 4)),
        throwsA(isA<FileSystemException>()),
      );
      expect(await db.watchPhotos().first, isEmpty);
      expect(folder.listSync(), isEmpty);
    });

    test('a version 5 database gains the photos table and keeps its data', () async {
      await db.close();
      final key = generateDatabaseKey();
      final file = File('${dir.path}/v5.db');
      db = openEncryptedDatabase(file, key);
      await db.logWeight(kg: 80, measuredAt: DateTime(2026, 11, 21));
      await db.close();
      final raw = sqlite3.open(file.path);
      applyDatabaseKey(raw, key);
      raw.execute('DROP TABLE progress_photos; PRAGMA user_version = 5;');
      raw.close();
      db = openEncryptedDatabase(file, key);
      await db.addPhoto(folder, source: source, pose: PhotoPose.front, takenAt: DateTime(2026, 11, 21));
      expect((await db.watchPhotos().first).length, 1);
      expect((await db.watchWeights().first).single.kg, 80);
    });
  });

  // Read tables directly here; see the note in body_test.dart.
  group('screens', () {
    late AloftDatabase db;
    late AppSettings settings;
    late Directory dir, folder;

    Future<void> open(WidgetTester tester) async {
      dir = Directory.systemTemp.createTempSync('aloft_photos_ui');
      folder = Directory('${dir.path}/photos');
      addTearDown(() => dir.deleteSync(recursive: true));
      await tester.runAsync(() async {
        db = openEncryptedDatabase(File('${dir.path}/aloft.db'), generateDatabaseKey());
        settings = await db.loadSettings(countryCode: 'US');
      });
    }

    File temp(String name) => File('${dir.path}/$name')..writeAsBytesSync(onePixel);

    Future<void> settle(WidgetTester tester) async {
      for (var i = 0; i < 16; i++) {
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
        await tester.pump();
      }
      await tester.pumpAndSettle();
    }

    Future<void> show(WidgetTester tester, PhotoPicker picker) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
            initialSettingsProvider.overrideWithValue(settings),
            photoPickerProvider.overrideWithValue(picker),
            photoFolderProvider.overrideWithValue(folder),
          ],
          child: const MaterialApp(home: ProgressScreen()),
        ),
      );
      await settle(tester);
    }

    Future<void> finish(WidgetTester tester) async {
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 5));
    }

    testWidgets('older photos from the library are saved with their own dates and poses', (tester) async {
      await open(tester);
      await tester.runAsync(() => db.logWeight(kg: toKg(197, WeightUnit.lb), measuredAt: DateTime(2025, 1, 6, 7)));
      final a = temp('a.jpg'), b = temp('b.jpg'), c = temp('c.jpg');
      await show(
        tester,
        FakePicker(
          library: [
            PickedPhoto(a, takenAt: DateTime(2025, 1, 6, 8, 30)),
            PickedPhoto(b, takenAt: DateTime(2025, 1, 6, 8, 31)),
            PickedPhoto(c),
          ],
        ),
      );
      expect(find.textContaining('Photos are optional'), findsOneWidget);
      expect(find.text('Saved only inside Aloft, never to your camera roll.'), findsOneWidget);

      await tester.tap(find.byKey(const Key('add-first-photos')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('choose-photos')));
      await settle(tester);
      expect(find.text('New photos'), findsOneWidget);
      expect(find.text('Jan 6, 2025'), findsNWidgets(2));
      expect(find.text('Date from the photo'), findsNWidgets(2));
      expect(find.text('Save 3 photos'), findsOneWidget);

      // The third has no date inside it, so it is left out here rather than guessed at.
      await tester.ensureVisible(find.byKey(const Key('remove-2')));
      await tester.tap(find.byKey(const Key('remove-2')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('pose-1-back')));
      await tester.pump();
      await tester.ensureVisible(find.text('Save 2 photos'));
      await tester.runAsync(() async {
        await tester.tap(find.byKey(const Key('save')));
        await Future<void>.delayed(const Duration(milliseconds: 500));
      });
      await settle(tester);

      late List<ProgressPhoto> saved;
      await tester.runAsync(() async => saved = await db.select(db.progressPhotos).get());
      saved.sort((x, y) => x.takenAt.compareTo(y.takenAt));
      expect(
        [for (final p in saved) (p.pose, p.takenAt)],
        [(PhotoPose.front, DateTime(2025, 1, 6, 8, 30)), (PhotoPose.back, DateTime(2025, 1, 6, 8, 31))],
      );
      expect(folder.listSync().length, 2);
      // The temporary copies are cleared away, including the one left out.
      expect([a, b, c].any((f) => f.existsSync()), isFalse);

      expect(find.text('Jan 6, 2025 · 197.0 lb'), findsOneWidget);
      expect(find.text('Front'), findsOneWidget);
      expect(find.text('Back'), findsOneWidget);
      await finish(tester);
    });

    testWidgets('a phone without a camera gets a plain message and saves nothing', (tester) async {
      await open(tester);
      await show(tester, FakePicker(cameraWorks: false));
      await tester.tap(find.byKey(const Key('add-first-photos')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('take-photo')));
      await settle(tester);
      expect(find.text("Aloft can't use the camera on this phone right now."), findsOneWidget);
      await tester.runAsync(() async => expect(await db.select(db.progressPhotos).get(), isEmpty));
      await finish(tester);
    });

    testWidgets('compare shows two days of one pose with the time and weight between them', (tester) async {
      await open(tester);
      final file = temp('x.jpg');
      await tester.runAsync(() async {
        await db.logWeight(kg: toKg(197, WeightUnit.lb), measuredAt: DateTime(2026, 9, 4, 7));
        await db.logWeight(kg: toKg(184.6, WeightUnit.lb), measuredAt: DateTime(2026, 11, 20, 7));
        for (final (at, pose) in [
          (DateTime(2026, 9, 4, 8), PhotoPose.front),
          (DateTime(2026, 10, 23, 8), PhotoPose.front),
          (DateTime(2026, 11, 20, 8), PhotoPose.front),
          (DateTime(2026, 11, 20, 8, 1), PhotoPose.side),
        ]) {
          await db.addPhoto(folder, source: file, pose: pose, takenAt: at);
        }
      });
      await show(tester, FakePicker());
      await tester.tap(find.text('Compare'));
      await settle(tester);
      // Opens on the pose with the most days, earliest to latest.
      expect(find.text('Sep 4, 2026'), findsOneWidget);
      expect(find.text('Nov 20, 2026'), findsOneWidget);
      expect(find.text('197.0 lb'), findsOneWidget);
      expect(find.text('184.6 lb'), findsOneWidget);
      expect(tester.widget<Text>(find.byKey(const Key('compare-summary'))).data, '11 weeks apart · −12.4 lb');

      await tester.tap(find.byKey(const Key('compare-from')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Oct 23, 2026').last);
      await settle(tester);
      expect(find.text('No weight that day'), findsOneWidget);
      expect(tester.widget<Text>(find.byKey(const Key('compare-summary'))).data, '4 weeks apart');

      await tester.tap(find.byKey(const Key('compare-side')));
      await settle(tester);
      expect(find.textContaining('Only one day has a side photo so far'), findsOneWidget);
      await finish(tester);
    });

    testWidgets('a photo can be given another pose, and deleting it asks first', (tester) async {
      await open(tester);
      final file = temp('x.jpg');
      late ProgressPhoto saved;
      await tester.runAsync(() async {
        saved = await db.addPhoto(folder, source: file, pose: PhotoPose.front, takenAt: DateTime(2026, 11, 20, 8));
      });
      await show(tester, FakePicker());
      await tester.tap(find.byKey(Key('photo-${saved.id}')));
      await settle(tester);
      expect(find.byType(PhotoViewScreen), findsOneWidget);
      expect(find.text('Front · Nov 20, 2026'), findsOneWidget);

      await tester.tap(find.byKey(const Key('edit-photo')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('edit-pose-side')));
      await tester.pump();
      await tester.runAsync(() async {
        await tester.tap(find.byKey(const Key('save-photo-edit')));
        await Future<void>.delayed(const Duration(milliseconds: 500));
      });
      await settle(tester);
      expect(find.text('Side · Nov 20, 2026'), findsOneWidget);

      await tester.tap(find.byKey(const Key('delete-photo')));
      await tester.pumpAndSettle();
      expect(find.text("It's removed from Aloft for good. This can't be undone."), findsOneWidget);
      await tester.tap(find.text('Keep'));
      await tester.pumpAndSettle();
      await tester.runAsync(() async => expect((await db.select(db.progressPhotos).get()).length, 1));

      await tester.tap(find.byKey(const Key('delete-photo')));
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        await tester.tap(find.byKey(const Key('confirm-delete')));
        await Future<void>.delayed(const Duration(milliseconds: 500));
      });
      await settle(tester);
      await tester.runAsync(() async => expect(await db.select(db.progressPhotos).get(), isEmpty));
      expect(folder.listSync(), isEmpty);
      expect(find.textContaining('Photos are optional'), findsOneWidget);
      await finish(tester);
    });
  });
}
