import 'dart:io';
import 'dart:ui' show Rect;

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

/// Handing a backup file to the phone (to save or send), and choosing one to restore.
abstract class BackupFiles {
  /// Opens the phone's share sheet for [file]. Returns once the sheet has closed.
  Future<void> share(File file, {Rect? origin});

  /// A file the person chose, or null if they backed out.
  Future<File?> pick();
}

class DeviceBackupFiles implements BackupFiles {
  @override
  Future<void> share(File file, {Rect? origin}) async {
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/zip')],
        sharePositionOrigin: origin,
      ),
    );
  }

  @override
  Future<File?> pick() async {
    final picked = await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: ['zip']);
    final path = picked.singleOrNull?.path;
    return path == null ? null : File(path);
  }
}

/// Set in main().
final backupFilesProvider = Provider<BackupFiles>((ref) => throw UnimplementedError('backup files not set'));
