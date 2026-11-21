import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../backup/backup_file.dart';
import '../../backup/backup_files.dart';
import '../../photos/photo_picker.dart';
import '../../settings/settings.dart';
import '../../util/format.dart';
import '../../widgets/form_widgets.dart';
import '../../theme/aloft_theme.dart';

/// Removes a temporary copy Aloft made or was handed. Files elsewhere are never touched.
void _discardTemporary(File file) {
  try {
    if (p.isWithin(Directory.systemTemp.path, file.path) && file.existsSync()) file.deleteSync();
  } catch (_) {}
}

/// More → Backup and restore: save everything to one file, or bring a file back.
class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  final _password = TextEditingController();
  bool _includePhotos = true;
  bool _busy = false;
  String? _problem;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final box = context.findRenderObject() as RenderBox?;
    final origin = box == null ? null : box.localToGlobal(Offset.zero) & box.size;
    setState(() {
      _busy = true;
      _problem = null;
    });
    final now = DateTime.now();
    // A folder of its own, so the file keeps its plain name.
    final folder = Directory.systemTemp.createTempSync('aloft_backup');
    final file = File(p.join(folder.path, backupFileName(now)));
    try {
      await ref
          .read(databaseProvider)
          .writeBackup(
            to: file,
            photoFolder: ref.read(photoFolderProvider),
            includePhotos: _includePhotos,
            password: _password.text,
            now: now,
          );
      await ref.read(backupFilesProvider).share(file, origin: origin);
    } catch (_) {
      if (mounted) setState(() => _problem = "The backup couldn't be made. Check that your phone has free space.");
    } finally {
      // Don't leave a readable copy of someone's health data lying in temporary storage.
      try {
        folder.deleteSync(recursive: true);
      } catch (_) {}
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restore() async {
    setState(() => _problem = null);
    final File? file;
    try {
      file = await ref.read(backupFilesProvider).pick();
    } catch (_) {
      setState(() => _problem = "That file couldn't be opened.");
      return;
    }
    if (file == null || !mounted) return;
    final schema = ref.read(databaseProvider).schemaVersion;
    String? password;
    OpenedBackup? backup;
    while (backup == null) {
      setState(() => _busy = true);
      try {
        backup = await openBackup(file, password: password, currentSchemaVersion: schema);
      } on BackupPasswordNeeded {
        if (!mounted) return;
        setState(() => _busy = false);
        password = await _askPassword(wrong: password != null);
        if (password == null) {
          _discardTemporary(file);
          return;
        }
      } on BackupProblem catch (e) {
        _discardTemporary(file);
        if (mounted) {
          setState(() {
            _busy = false;
            _problem = e.message;
          });
        }
        return;
      }
    }
    if (!mounted) return;
    setState(() => _busy = false);
    final opened = backup;
    await Navigator.of(context)
        .push(MaterialPageRoute<void>(fullscreenDialog: true, builder: (_) => RestoreScreen(backup: opened)));
    _discardTemporary(file);
  }

  Future<String?> _askPassword({required bool wrong}) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: const Text('Backup password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(wrong ? "That password didn't open it. Try again." : 'This backup is locked with a password.'),
            const SizedBox(height: 12),
            TextField(
              key: const Key('restore-password'),
              controller: controller,
              obscureText: true,
              autofocus: true,
              autocorrect: false,
              enableSuggestions: false,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialog), child: const Text('Cancel')),
          TextButton(
            key: const Key('restore-password-ok'),
            onPressed: () => Navigator.pop(dialog, controller.text),
            child: const Text('Open'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final muted = TextStyle(fontSize: 13, height: 1.45, color: scheme.onSurfaceVariant);
    final photoCount = ref.watch(photosProvider).value?.length ?? 0;
    final locked = _password.text.isNotEmpty;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Backup and restore',
          style: TextStyle(fontFamily: displayFont, fontSize: 20, fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'A backup file holds everything you\'ve logged in Aloft. Save it somewhere of your own, like Files, '
              'iCloud Drive or Google Drive. It\'s also how you move to a new phone, or between iPhone and Android.',
              style: TextStyle(fontSize: 15, height: 1.45, color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              key: const Key('include-photos'),
              contentPadding: EdgeInsets.zero,
              title: const Text('Include progress photos'),
              subtitle: Text(photoCount == 0 ? 'No photos yet' : '$photoCount ${photoCount == 1 ? 'photo' : 'photos'}'),
              value: _includePhotos,
              onChanged: _busy ? null : (on) => setState(() => _includePhotos = on),
            ),
            const FieldLabel('Password (optional)'),
            TextField(
              key: const Key('backup-password'),
              controller: _password,
              obscureText: true,
              autocorrect: false,
              enableSuggestions: false,
              enabled: !_busy,
              onChanged: (_) => setState(() {}),
              onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            ),
            const SizedBox(height: 6),
            Text(
              locked
                  ? 'The file will be locked. If you forget this password, the backup can\'t be opened, and nobody can reset it.'
                  : 'Without a password, anyone who gets the file can read what\'s in it.',
              key: const Key('password-note'),
              style: muted,
            ),
            const SizedBox(height: 16),
            FilledButton(
              key: const Key('save-backup'),
              onPressed: _busy ? null : _save,
              child: Text(_busy ? 'Working…' : 'Save a backup file'),
            ),
            const SizedBox(height: 28),
            const Text('Restore', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(
              'Choose a backup file. You\'ll see what\'s in it before anything on this phone changes.',
              style: TextStyle(fontSize: 15, height: 1.45, color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              key: const Key('restore-backup'),
              onPressed: _busy ? null : _restore,
              child: const Text('Restore from a backup file'),
            ),
            if (_problem != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  _problem!,
                  key: const Key('backup-problem'),
                  style: TextStyle(color: scheme.error, fontWeight: FontWeight.w600),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// What's in a backup, and the choice of how to bring it in. Nothing changes until Restore.
class RestoreScreen extends ConsumerStatefulWidget {
  const RestoreScreen({super.key, required this.backup});
  final OpenedBackup backup;

  @override
  ConsumerState<RestoreScreen> createState() => _RestoreScreenState();
}

class _RestoreScreenState extends ConsumerState<RestoreScreen> {
  bool _replace = false;
  bool _busy = false;
  String? _problem;
  RestoreResult? _result;

  static const _labels = [
    ('medications', 'medication', 'medications'),
    ('doses', 'shot or dose', 'shots and doses'),
    ('weights', 'weight', 'weights'),
    ('side_effects', 'side effect', 'side effects'),
    ('day_notes', 'note', 'notes'),
    ('progress_photos', 'photo', 'photos'),
  ];

  static List<String> _lines(int Function(String table) count) => [
    for (final (table, one, many) in _labels)
      if (count(table) > 0) '${count(table)} ${count(table) == 1 ? one : many}',
  ];

  Future<void> _restore() async {
    if (_replace) {
      final sure = await showDialog<bool>(
        context: context,
        builder: (dialog) => AlertDialog(
          title: const Text('Replace everything on this phone?'),
          content: const Text(
            "What's in Aloft now, including photos, is removed and the backup takes its place. This can't be undone.",
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialog, false), child: const Text('Cancel')),
            TextButton(
              key: const Key('confirm-replace'),
              style: TextButton.styleFrom(foregroundColor: Theme.of(dialog).colorScheme.error),
              onPressed: () => Navigator.pop(dialog, true),
              child: const Text('Replace'),
            ),
          ],
        ),
      );
      if (sure != true) return;
    }
    setState(() {
      _busy = true;
      _problem = null;
    });
    try {
      final result = await ref
          .read(databaseProvider)
          .restoreBackup(widget.backup, photoFolder: ref.read(photoFolderProvider), replace: _replace);
      await ref.read(settingsProvider.notifier).reload();
      if (mounted) setState(() => _result = result);
    } on BackupProblem catch (e) {
      if (mounted) setState(() => _problem = e.message);
    } catch (_) {
      if (mounted) setState(() => _problem = "This backup couldn't be restored.");
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _choice({required Key key, required bool replace, required String title, required String detail}) {
    final scheme = Theme.of(context).colorScheme;
    final selected = _replace == replace;
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: selected ? scheme.secondary : scheme.outlineVariant, width: selected ? 2 : 1),
      ),
      child: ListTile(
        key: key,
        leading: Icon(
          selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
          color: selected ? scheme.secondary : scheme.onSurfaceVariant,
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(detail),
        onTap: _busy ? null : () => setState(() => _replace = replace),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final summary = widget.backup.summary;
    final result = _result;
    final contents = _lines(summary.count);
    return Scaffold(
      appBar: AppBar(
        leading: result != null
            ? const SizedBox.shrink()
            : TextButton(onPressed: _busy ? null : () => Navigator.pop(context), child: const Text('Cancel')),
        leadingWidth: 88,
        title: const Text(
          'Restore',
          style: TextStyle(fontFamily: displayFont, fontSize: 20, fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: result != null
              ? [
                  InfoBox(key: const Key('restore-result'), switch (_lines((t) => result.added[t] ?? 0)) {
                    [] => 'Everything in this backup was already on this phone. Nothing was added.',
                    final added => 'Restored ${added.join(', ')}.',
                  }),
                  const SizedBox(height: 20),
                  FilledButton(
                    key: const Key('restore-done'),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Done'),
                  ),
                ]
              : [
                  Text(
                    'Backup from ${formatFullDate(context, summary.createdAt)}'
                    '${summary.madeOn.isEmpty ? '' : ' · made on ${summary.madeOn}'}',
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    contents.isEmpty ? 'This backup is empty.' : contents.join('\n'),
                    key: const Key('backup-contents'),
                    style: const TextStyle(fontSize: 15, height: 1.5),
                  ),
                  if (summary.count('progress_photos') == 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'No photos in this backup.',
                        style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
                      ),
                    ),
                  const SizedBox(height: 16),
                  _choice(
                    key: const Key('choose-add'),
                    replace: false,
                    title: 'Add what\'s missing',
                    detail: 'Keeps everything on this phone and adds what it doesn\'t have yet.',
                  ),
                  _choice(
                    key: const Key('choose-replace'),
                    replace: true,
                    title: 'Replace everything',
                    detail: 'Removes what\'s on this phone now and puts the backup in its place.',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'App lock stays as it\'s set on this phone.',
                    style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
                  ),
                  if (_problem != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        _problem!,
                        style: TextStyle(color: scheme.error, fontWeight: FontWeight.w600),
                      ),
                    ),
                  const SizedBox(height: 16),
                  FilledButton(
                    key: const Key('restore-now'),
                    onPressed: _busy || contents.isEmpty ? null : _restore,
                    child: Text(_busy ? 'Restoring…' : 'Restore'),
                  ),
                ],
        ),
      ),
    );
  }
}
