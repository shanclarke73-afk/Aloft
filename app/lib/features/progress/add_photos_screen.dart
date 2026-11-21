import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/photo_store.dart';
import '../../photos/photo_picker.dart';
import '../../settings/settings.dart';
import '../../util/format.dart';
import '../../widgets/form_widgets.dart';
import 'photo_image.dart';

const photosStayPrivate = 'Saved only inside Aloft, never to your camera roll.';

/// Asks "camera or library", then opens the review screen for what was picked.
Future<void> startAddPhotos(BuildContext context) async {
  final choice = await showModalBottomSheet<bool>(
    context: context,
    showDragHandle: true,
    builder: (sheet) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Add progress photos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            ),
          ),
          ListTile(
            key: const Key('take-photo'),
            contentPadding: const EdgeInsets.symmetric(horizontal: 24),
            leading: const Icon(Icons.photo_camera_outlined),
            title: const Text('Take a photo', style: TextStyle(fontWeight: FontWeight.w700)),
            onTap: () => Navigator.pop(sheet, true),
          ),
          ListTile(
            key: const Key('choose-photos'),
            contentPadding: const EdgeInsets.symmetric(horizontal: 24),
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('Choose from your library', style: TextStyle(fontWeight: FontWeight.w700)),
            subtitle: const Text('Older photos keep their original date'),
            onTap: () => Navigator.pop(sheet, false),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: Text(
              photosStayPrivate,
              style: TextStyle(fontSize: 13, color: Theme.of(sheet).colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    ),
  );
  if (choice == null || !context.mounted) return;
  final picker = ProviderScope.containerOf(context).read(photoPickerProvider);
  final messenger = ScaffoldMessenger.of(context);
  final List<PickedPhoto> picked;
  try {
    picked = choice ? [?await picker.fromCamera()] : await picker.fromLibrary();
  } on CameraUnavailable {
    messenger.showSnackBar(const SnackBar(content: Text("Aloft can't use the camera on this phone right now.")));
    return;
  } catch (_) {
    messenger.showSnackBar(const SnackBar(content: Text("Those photos couldn't be opened.")));
    return;
  }
  if (picked.isEmpty || !context.mounted) return;
  await Navigator.of(context)
      .push(MaterialPageRoute<void>(fullscreenDialog: true, builder: (_) => AddPhotosScreen(picked: picked)));
}

class _Draft {
  _Draft(this.picked, this.pose, this.day);
  final PickedPhoto picked;
  PhotoPose pose;
  DateTime day;
}

/// Review what was picked: choose each photo's pose and check its date, then save.
class AddPhotosScreen extends ConsumerStatefulWidget {
  const AddPhotosScreen({super.key, required this.picked});
  final List<PickedPhoto> picked;

  @override
  ConsumerState<AddPhotosScreen> createState() => _AddPhotosScreenState();
}

class _AddPhotosScreenState extends ConsumerState<AddPhotosScreen> {
  late final List<_Draft> _drafts;
  bool _saving = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _drafts = [
      for (final (i, photo) in widget.picked.indexed)
        // A first guess at front, side, back in the order picked; each one can be changed.
        _Draft(photo, i < 3 ? PhotoPose.values[i] : PhotoPose.other, photo.takenAt ?? now),
    ];
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _failed = false;
    });
    final db = ref.read(databaseProvider), folder = ref.read(photoFolderProvider);
    try {
      while (_drafts.isNotEmpty) {
        final draft = _drafts.first;
        await db.addPhoto(folder, source: draft.picked.file, pose: draft.pose, takenAt: draft.day);
        _discard(draft);
        _drafts.removeAt(0);
      }
    } catch (_) {
      // Whatever saved stays saved; the rest are still listed to try again.
      if (mounted) {
        setState(() {
          _saving = false;
          _failed = true;
        });
      }
      return;
    }
    if (mounted) Navigator.pop(context);
  }

  /// Removes the temporary copy the camera or chooser made. The person's own library is never touched.
  void _discard(_Draft draft) {
    try {
      draft.picked.file.deleteSync();
    } catch (_) {}
  }

  void _cancel() {
    _drafts.forEach(_discard);
    Navigator.pop(context);
  }

  Future<void> _chooseDay(_Draft draft) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: draft.day,
      firstDate: DateTime(now.year - 20),
      lastDate: now,
    );
    if (date == null) return;
    // Keep the time of day, so photos from one day stay in the order they were taken.
    setState(() => draft.day = DateTime(date.year, date.month, date.day, draft.day.hour, draft.day.minute));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final count = _drafts.length;
    return Scaffold(
      appBar: AppBar(
        leading: TextButton(onPressed: _saving ? null : _cancel, child: const Text('Cancel')),
        leadingWidth: 88,
        title: const Text('New photos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (i, draft) in _drafts.indexed)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 108, child: PhotoTile(draft.picked.file)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Wrap(
                            spacing: 6,
                            children: [
                              for (final pose in PhotoPose.values)
                                ChoiceChip(
                                  key: Key('pose-$i-${pose.name}'),
                                  label: Text(pose.label),
                                  selected: draft.pose == pose,
                                  showCheckmark: false,
                                  onSelected: (_) => setState(() => draft.pose = pose),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          PickerField(
                            key: Key('date-$i'),
                            text: formatFullDate(context, draft.day),
                            onTap: () => _chooseDay(draft),
                          ),
                          if (draft.picked.takenAt != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                'Date from the photo',
                                style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
                              ),
                            ),
                          if (count > 1)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton(
                                key: Key('remove-$i'),
                                onPressed: _saving
                                    ? null
                                    : () => setState(() {
                                        _discard(draft);
                                        _drafts.removeAt(i);
                                      }),
                                child: const Text('Leave this one out'),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            if (_failed)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  "These couldn't be saved. Check that your phone has free space, then try again.",
                  style: TextStyle(color: scheme.error, fontWeight: FontWeight.w600),
                ),
              ),
            FilledButton(
              key: const Key('save'),
              onPressed: _saving ? null : _save,
              child: Text(count == 1 ? 'Save photo' : 'Save $count photos'),
            ),
            const SizedBox(height: 12),
            Text(
              photosStayPrivate,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
