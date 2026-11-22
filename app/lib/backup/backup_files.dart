import '../security/app_lock.dart';

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Handing a backup file to the phone (to save or send), and choosing one to restore.
abstract class BackupFiles {
  /// Opens the phone's share sheet for [file]. Returns once the sheet has closed.
  Future<void> share(File file, {Rect? origin});

  /// A file the person chose, or null if they backed out.
  Future<File?> pick();

  /// Puts a copy of [file] in this phone's usual place for Aloft's files, without asking
  /// where. Returns that place in words ("Documents › Aloft"), or null when the phone has no
  /// such place or the copy failed, so the caller can fall back to the share sheet.
  Future<String?> saveOnPhone(File file);
}

class DeviceBackupFiles implements BackupFiles {
  DeviceBackupFiles(this._lock);

  /// The share sheet and the file chooser cover Aloft; coming back shouldn't ask for the lock.
  final AppLock _lock;

  @override
  Future<void> share(File file, {Rect? origin}) async {
    await _lock.awayOnPurpose(
      () => SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'application/zip')],
          sharePositionOrigin: origin,
        ),
      ),
    );
  }

  @override
  Future<File?> pick() async {
    final picked = await _lock.awayOnPurpose(
      () => FilePicker.pickFiles(type: FileType.custom, allowedExtensions: ['zip']),
    );
    final path = picked.singleOrNull?.path;
    return path == null ? null : File(path);
  }

  static const _files = MethodChannel('aloft/files');

  @override
  Future<String?> saveOnPhone(File file) async {
    final name = p.basename(file.path);
    try {
      if (Platform.isAndroid) {
        // Documents/Aloft through the phone's media store: no chooser and no storage permission.
        final saved = await _files.invokeMethod<bool>('saveToDocuments', {'path': file.path, 'name': name});
        return saved == true ? 'Documents › Aloft' : null;
      }
      if (Platform.isIOS) {
        // The app's Documents folder, which the Files app shows as "On My iPhone › Aloft".
        final folder = await getApplicationDocumentsDirectory();
        var target = File(p.join(folder.path, name));
        for (var n = 2; target.existsSync(); n++) {
          target = File(p.join(folder.path, '${p.basenameWithoutExtension(name)} ($n)${p.extension(name)}'));
        }
        file.copySync(target.path);
        return 'Files › On My iPhone › Aloft';
      }
    } catch (_) {}
    return null;
  }
}

/// Set in main().
final backupFilesProvider = Provider<BackupFiles>((ref) => throw UnimplementedError('backup files not set'));
