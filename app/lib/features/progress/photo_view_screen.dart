import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/photo_store.dart';
import '../../photos/photo_picker.dart';
import '../../settings/settings.dart';
import '../../util/format.dart';
import '../../widgets/form_widgets.dart';
import 'photo_image.dart';

Future<void> openPhoto(BuildContext context, ProgressPhoto photo) =>
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => PhotoViewScreen(photoId: photo.id)));

/// One photo, full screen, with pinch to zoom. Its pose and date can be changed, or it can be deleted.
class PhotoViewScreen extends ConsumerWidget {
  const PhotoViewScreen({super.key, required this.photoId});
  final String photoId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photos = ref.watch(photosProvider).value ?? const <ProgressPhoto>[];
    final photo = photos.where((p) => p.id == photoId).firstOrNull;
    if (photo == null) return const Scaffold(backgroundColor: Colors.black);
    final folder = ref.watch(photoFolderProvider);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          '${photo.pose.label} · ${formatFullDate(context, photo.takenAt)}',
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white),
        ),
        actions: [
          IconButton(
            key: const Key('edit-photo'),
            tooltip: 'Change pose or date',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _edit(context, ref, photo),
          ),
          IconButton(
            key: const Key('delete-photo'),
            tooltip: 'Delete photo',
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _delete(context, ref, photo),
          ),
        ],
      ),
      body: SafeArea(
        child: InteractiveViewer(
          maxScale: 5,
          child: SizedBox.expand(child: PhotoImage(photoFile(folder, photo), fit: BoxFit.contain)),
        ),
      ),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, ProgressPhoto photo) async {
    final sure = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: const Text('Delete this photo?'),
        content: const Text("It's removed from Aloft for good. This can't be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialog, false), child: const Text('Keep')),
          TextButton(
            key: const Key('confirm-delete'),
            style: TextButton.styleFrom(foregroundColor: Theme.of(dialog).colorScheme.error),
            onPressed: () => Navigator.pop(dialog, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (sure != true || !context.mounted) return;
    Navigator.pop(context);
    await ref.read(databaseProvider).deletePhoto(ref.read(photoFolderProvider), photo);
  }

  Future<void> _edit(BuildContext context, WidgetRef ref, ProgressPhoto photo) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => _EditSheet(photo: photo),
    );
  }
}

class _EditSheet extends ConsumerStatefulWidget {
  const _EditSheet({required this.photo});
  final ProgressPhoto photo;

  @override
  ConsumerState<_EditSheet> createState() => _EditSheetState();
}

class _EditSheetState extends ConsumerState<_EditSheet> {
  late PhotoPose _pose = widget.photo.pose;
  late DateTime _day = widget.photo.takenAt;

  Future<void> _chooseDay() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _day,
      firstDate: DateTime(now.year - 20),
      lastDate: now,
    );
    if (date == null) return;
    setState(() => _day = DateTime(date.year, date.month, date.day, _day.hour, _day.minute));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Pose and date', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                for (final pose in PhotoPose.values)
                  ChoiceChip(
                    key: Key('edit-pose-${pose.name}'),
                    label: Text(pose.label),
                    selected: _pose == pose,
                    showCheckmark: false,
                    onSelected: (_) => setState(() => _pose = pose),
                  ),
              ],
            ),
            const FieldLabel('Date taken'),
            PickerField(text: formatFullDate(context, _day), onTap: _chooseDay),
            const SizedBox(height: 20),
            FilledButton(
              key: const Key('save-photo-edit'),
              onPressed: () async {
                await ref.read(databaseProvider).updatePhoto(widget.photo, pose: _pose, takenAt: _day);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
