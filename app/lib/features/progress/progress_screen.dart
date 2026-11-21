import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/body_store.dart';
import '../../data/database.dart';
import '../../data/photo_store.dart';
import '../../photos/photo_picker.dart';
import '../../settings/settings.dart';
import '../../util/format.dart';
import '../../widgets/form_widgets.dart';
import 'add_photos_screen.dart';
import 'photo_image.dart';
import 'photo_view_screen.dart';

/// The Progress tab (mockups/PhotoCompare): a gallery by date, and two days side by side.
class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen> {
  bool _comparing = false;

  @override
  Widget build(BuildContext context) {
    final photos = ref.watch(photosProvider).value;
    final days = photoDays(photos ?? const []);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress'),
        actions: [
          if (days.isNotEmpty)
            IconButton(
              key: const Key('add-photos'),
              tooltip: 'Add photos',
              icon: const Icon(Icons.add_a_photo_outlined),
              onPressed: () => startAddPhotos(context),
            ),
        ],
      ),
      body: photos == null
          ? const SizedBox()
          : days.isEmpty
          ? const _Empty()
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<bool>(
                      showSelectedIcon: false,
                      segments: const [
                        ButtonSegment(value: false, label: Text('Gallery')),
                        ButtonSegment(value: true, label: Text('Compare')),
                      ],
                      selected: {_comparing},
                      onSelectionChanged: (s) => setState(() => _comparing = s.single),
                    ),
                  ),
                ),
                Expanded(
                  child: _comparing ? _Compare(days: days) : _Gallery(days: days),
                ),
              ],
            ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.photo_camera_outlined, size: 44, color: scheme.secondary),
            const SizedBox(height: 16),
            const Text('Progress photos', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(
              'Photos are optional. Add one whenever you like, or bring in older ones with their original dates.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, height: 1.45, color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              key: const Key('add-first-photos'),
              onPressed: () => startAddPhotos(context),
              icon: const Icon(Icons.add_a_photo_outlined),
              label: const Text('Add photos'),
            ),
            const SizedBox(height: 16),
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

class _Gallery extends ConsumerWidget {
  const _Gallery({required this.days});
  final List<PhotoDay> days;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final folder = ref.watch(photoFolderProvider);
    final weights = ref.watch(weightsProvider).value ?? const <Weight>[];
    final unit = ref.watch(settingsProvider).weightUnit;
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
      itemCount: days.length,
      itemBuilder: (context, i) {
        final (:day, :photos) = days[i];
        final weight = weightOnDay(weights, day);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Text(
                '${formatFullDate(context, day)}${weight == null ? '' : ' · ${formatWeight(weight.kg, unit)}'}',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
            ),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 3 / 4.6,
              children: [
                for (final photo in photos)
                  Column(
                    children: [
                      PhotoTile(
                        key: Key('photo-${photo.id}'),
                        photoFile(folder, photo),
                        onTap: () => openPhoto(context, photo),
                      ),
                      const SizedBox(height: 4),
                      Text(photo.pose.label, style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
                    ],
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

/// Two days of the same pose, side by side, with the weight change if both days have a weight.
class _Compare extends ConsumerStatefulWidget {
  const _Compare({required this.days});
  final List<PhotoDay> days;

  @override
  ConsumerState<_Compare> createState() => _CompareState();
}

class _CompareState extends ConsumerState<_Compare> {
  PhotoPose? _pose;
  DateTime? _from, _to;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final folder = ref.watch(photoFolderProvider);
    final weights = ref.watch(weightsProvider).value ?? const <Weight>[];
    final unit = ref.watch(settingsProvider).weightUnit;

    // Oldest first, one photo per day for each pose.
    final byPose = <PhotoPose, Map<DateTime, ProgressPhoto>>{};
    for (final (:day, :photos) in widget.days.reversed) {
      for (final photo in photos) {
        byPose.putIfAbsent(photo.pose, () => {}).putIfAbsent(day, () => photo);
      }
    }
    final poses = [
      for (final pose in PhotoPose.values)
        if (byPose.containsKey(pose)) pose,
    ];
    // Start on the pose with the most days to compare.
    final pose = poses.contains(_pose) ? _pose! : poses.reduce((a, b) => byPose[b]!.length > byPose[a]!.length ? b : a);
    final choices = byPose[pose]!;
    final dates = choices.keys.toList();
    final from = choices.containsKey(_from) ? _from! : dates.first;
    final to = choices.containsKey(_to) ? _to! : dates.last;
    final fromWeight = weightOnDay(weights, from), toWeight = weightOnDay(weights, to);

    Widget side(String label, DateTime day, Key key, ValueChanged<DateTime> onPick) {
      final weight = weightOnDay(weights, day);
      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FieldLabel(label),
            PickerField(
              key: key,
              text: formatFullDate(context, day),
              onTap: () async {
                final picked = await _pickDay(context, dates, day);
                if (picked != null) onPick(picked);
              },
            ),
            const SizedBox(height: 10),
            PhotoTile(photoFile(folder, choices[day]!), onTap: () => openPhoto(context, choices[day]!)),
            const SizedBox(height: 6),
            Text(
              weight == null ? 'No weight that day' : formatWeight(weight.kg, unit),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 8,
            children: [
              for (final p in poses)
                ChoiceChip(
                  key: Key('compare-${p.name}'),
                  label: Text(p.label),
                  selected: p == pose,
                  showCheckmark: false,
                  onSelected: (_) => setState(() {
                    _pose = p;
                    _from = _to = null;
                  }),
                ),
            ],
          ),
          if (dates.length < 2)
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Text(
                'Only one day has a ${pose.label.toLowerCase()} photo so far. '
                'Add one from another day to see them side by side.',
                style: TextStyle(fontSize: 15, height: 1.45, color: scheme.onSurfaceVariant),
              ),
            )
          else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                side('From', from, const Key('compare-from'), (d) => setState(() => _from = d)),
                const SizedBox(width: 12),
                side('To', to, const Key('compare-to'), (d) => setState(() => _to = d)),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              [
                describeApart(from, to),
                if (fromWeight != null && toWeight != null && from != to)
                  // Always earlier day to later day, whichever side each is on.
                  from.isBefore(to)
                      ? formatWeightChange(fromWeight.kg, toWeight.kg, unit)
                      : formatWeightChange(toWeight.kg, fromWeight.kg, unit),
              ].join(' · '),
              key: const Key('compare-summary'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
          ],
        ],
      ),
    );
  }

  Future<DateTime?> _pickDay(BuildContext context, List<DateTime> dates, DateTime current) {
    return showModalBottomSheet<DateTime>(
      context: context,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final day in dates.reversed)
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                title: Text(formatFullDate(sheet, day), style: const TextStyle(fontWeight: FontWeight.w700)),
                trailing: day == current ? const Icon(Icons.check) : null,
                onTap: () => Navigator.pop(sheet, day),
              ),
          ],
        ),
      ),
    );
  }
}
