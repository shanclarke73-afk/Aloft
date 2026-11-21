import 'dart:io';

import 'package:exif/exif.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../data/photo_store.dart';

/// A photo just taken or chosen, not saved yet. [file] is a temporary copy that belongs to
/// Aloft; [takenAt] is the date stored inside the photo, when it has one.
class PickedPhoto {
  const PickedPhoto(this.file, {this.takenAt});
  final File file;
  final DateTime? takenAt;
}

/// Thrown when the phone has no camera to use, or Aloft isn't allowed to use it.
class CameraUnavailable implements Exception {
  const CameraUnavailable();
}

abstract class PhotoPicker {
  /// One new photo from the camera, or null if the person backed out.
  Future<PickedPhoto?> fromCamera();

  /// Photos chosen from the phone's library; empty if the person backed out.
  Future<List<PickedPhoto>> fromLibrary();
}

/// Uses the phone's own camera and photo chooser. Nothing is added to the camera roll, and
/// the chooser hands over only the photos picked, so Aloft never sees the rest of the library.
class DevicePhotoPicker implements PhotoPicker {
  final _picker = ImagePicker();

  // Big enough to zoom in on, small enough that years of photos still fit in a backup.
  static const _maxSide = 2400.0;
  static const _quality = 88;

  @override
  Future<PickedPhoto?> fromCamera() async {
    try {
      final shot = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: _maxSide,
        maxHeight: _maxSide,
        imageQuality: _quality,
      );
      return shot == null ? null : PickedPhoto(File(shot.path));
    } on PlatformException {
      throw const CameraUnavailable();
    }
  }

  @override
  Future<List<PickedPhoto>> fromLibrary() async {
    final chosen = await _picker.pickMultiImage(maxWidth: _maxSide, maxHeight: _maxSide, imageQuality: _quality);
    return [for (final x in chosen) PickedPhoto(File(x.path), takenAt: await _dateInside(File(x.path)))];
  }

  Future<DateTime?> _dateInside(File file) async {
    try {
      final tags = await readExifFromBytes(await file.readAsBytes());
      return parseExifDate(tags['EXIF DateTimeOriginal']?.printable) ??
          parseExifDate(tags['Image DateTime']?.printable);
    } catch (_) {
      return null;
    }
  }
}

/// Both are set in main().
final photoPickerProvider = Provider<PhotoPicker>((ref) => throw UnimplementedError('photo picker not set'));
final photoFolderProvider = Provider<Directory>((ref) => throw UnimplementedError('photo folder not set'));
