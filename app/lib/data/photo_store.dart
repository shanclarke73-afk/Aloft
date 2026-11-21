import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/material.dart' show DateUtils;
import 'package:path/path.dart' as p;

import 'database.dart';

/// The photos taken on one calendar day, in pose order.
typedef PhotoDay = ({DateTime day, List<ProgressPhoto> photos});

/// Groups photos by calendar day, newest day first.
List<PhotoDay> photoDays(List<ProgressPhoto> photos) {
  final byDay = <DateTime, List<ProgressPhoto>>{};
  for (final photo in photos) {
    byDay.putIfAbsent(DateUtils.dateOnly(photo.takenAt), () => []).add(photo);
  }
  final days = byDay.keys.toList()..sort((a, b) => b.compareTo(a));
  return [
    for (final day in days)
      (
        day: day,
        photos: byDay[day]!
          ..sort((a, b) {
            final pose = a.pose.index.compareTo(b.pose.index);
            return pose != 0 ? pose : a.takenAt.compareTo(b.takenAt);
          }),
      ),
  ];
}

/// The last weight logged on that calendar day, or null. Never borrows from another day.
Weight? weightOnDay(List<Weight> weights, DateTime day) {
  Weight? found;
  for (final w in weights) {
    if (!DateUtils.isSameDay(w.measuredAt, day)) continue;
    if (found == null || w.measuredAt.isAfter(found.measuredAt)) found = w;
  }
  return found;
}

/// "same day", "5 days apart", "11 weeks apart", "1.5 years apart": the time between two photo days.
String describeApart(DateTime from, DateTime to) {
  final days = DateUtils.dateOnly(to).difference(DateUtils.dateOnly(from)).inDays.abs();
  if (days == 0) return 'same day';
  if (days < 14) return '$days ${days == 1 ? 'day' : 'days'} apart';
  if (days < 365) return '${(days / 7).round()} weeks apart';
  final years = (days / 365.25).toStringAsFixed(1);
  return '${years.endsWith('.0') ? years.substring(0, years.length - 2) : years} ${years == '1.0' ? 'year' : 'years'} apart';
}

/// Reads the date a camera wrote into a photo: "2025:01:06 08:30:00". Null if it isn't one.
DateTime? parseExifDate(String? text) {
  final m = RegExp(r'^(\d{4}):(\d{2}):(\d{2})[ T](\d{2}):(\d{2}):(\d{2})').firstMatch(text?.trim() ?? '');
  if (m == null) return null;
  final n = [for (var i = 1; i <= 6; i++) int.parse(m.group(i)!)];
  if (n[0] < 1990 || n[1] < 1 || n[1] > 12 || n[2] < 1 || n[2] > 31 || n[3] > 23 || n[4] > 59 || n[5] > 59) {
    return null;
  }
  return DateTime(n[0], n[1], n[2], n[3], n[4], n[5]);
}

File photoFile(Directory folder, ProgressPhoto photo) => File(p.join(folder.path, photo.fileName));

extension PhotoStore on AloftDatabase {
  /// Copies [source] into the app's private photos [folder] and records it. The source file
  /// is left alone.
  Future<ProgressPhoto> addPhoto(
    Directory folder, {
    required File source,
    required PhotoPose pose,
    required DateTime takenAt,
  }) async {
    final id = newId();
    final extension = p.extension(source.path).toLowerCase();
    final fileName = '$id${RegExp(r'^\.[a-z0-9]{1,5}$').hasMatch(extension) ? extension : '.jpg'}';
    await folder.create(recursive: true);
    final copy = await source.copy(p.join(folder.path, fileName));
    try {
      return await into(progressPhotos).insertReturning(
        ProgressPhotosCompanion.insert(id: Value(id), takenAt: takenAt, pose: pose, fileName: fileName),
      );
    } catch (_) {
      // Don't leave a photo on the phone that the app has no record of.
      if (await copy.exists()) await copy.delete();
      rethrow;
    }
  }

  Future<void> updatePhoto(ProgressPhoto photo, {required PhotoPose pose, required DateTime takenAt}) {
    return (update(progressPhotos)..where((x) => x.id.equals(photo.id))).write(
      ProgressPhotosCompanion(pose: Value(pose), takenAt: Value(takenAt), updatedAt: Value(DateTime.now())),
    );
  }

  /// Removes the record and the file. This can't be undone.
  Future<void> deletePhoto(Directory folder, ProgressPhoto photo) async {
    await (delete(progressPhotos)..where((x) => x.id.equals(photo.id))).go();
    final file = photoFile(folder, photo);
    if (await file.exists()) await file.delete();
  }

  /// Newest first.
  Stream<List<ProgressPhoto>> watchPhotos() =>
      (select(progressPhotos)..orderBy([(x) => OrderingTerm.desc(x.takenAt)])).watch();
}
