import 'dart:io';

import 'package:aloft/data/body_store.dart';
import 'package:aloft/data/database.dart';
import 'package:aloft/data/encrypted_database.dart';
import 'package:aloft/features/body/edit_entry_screens.dart';
import 'package:aloft/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory dir;
  late AloftDatabase db;
  late AppSettings settings;

  Future<void> open(WidgetTester tester) async {
    dir = Directory.systemTemp.createTempSync('aloft_edit');
    addTearDown(() => dir.deleteSync(recursive: true));
    await tester.runAsync(() async {
      db = openEncryptedDatabase(File('${dir.path}/aloft.db'), generateDatabaseKey());
      settings = await db.loadSettings(countryCode: 'US');
    });
  }

  Future<void> show(WidgetTester tester, Widget screen) async {
    await tester.pumpWidget(
      ProviderScope(
        // A fresh app each time: saving pops the only screen, which leaves nothing to show the next one in.
        key: UniqueKey(),
        overrides: [databaseProvider.overrideWithValue(db), initialSettingsProvider.overrideWithValue(settings)],
        child: MaterialApp(home: screen),
      ),
    );
  }

  /// Taps for real, then waits for [done] instead of a fixed time.
  Future<void> tapAndWait(WidgetTester tester, Finder target, Future<bool> Function() done) async {
    await tester.ensureVisible(target);
    await tester.runAsync(() async {
      await tester.tap(target);
      for (var i = 0; i < 100 && !await done(); i++) {
        await Future<void>.delayed(const Duration(milliseconds: 30));
      }
    });
    await tester.pump();
  }

  Future<void> close(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 11));
  }

  testWidgets('a note can be typed in for a day, and an empty one is not saved', (tester) async {
    await open(tester);
    await show(tester, const NoteScreen());
    await tester.tap(find.byKey(const Key('save')));
    await tester.pump();
    expect(find.text('Type something to save.'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('note-body')), '  Felt good after a walk  ');
    await tapAndWait(
      tester,
      find.byKey(const Key('save')),
      () async => (await db.select(db.dayNotes).get()).isNotEmpty,
    );
    late DayNote saved;
    await tester.runAsync(() async => saved = (await db.select(db.dayNotes).get()).single);
    expect(saved.body, 'Felt good after a walk');
    // The day only, so it sits with that day in History whatever time it was typed.
    expect(saved.noteDate, DateUtils.dateOnly(DateTime.now()));
    await close(tester);
  });

  testWidgets('a note can be changed or deleted', (tester) async {
    await open(tester);
    late DayNote note;
    await tester.runAsync(() async {
      await db.addDayNote(body: 'Slept badly', day: DateTime(2026, 11, 20, 23, 30));
      note = (await db.select(db.dayNotes).get()).single;
    });
    expect(note.noteDate, DateTime(2026, 11, 20));
    await show(tester, NoteScreen(editing: note));
    expect(find.text('Slept badly'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('note-body')), 'Slept badly, better by noon');
    await tapAndWait(
      tester,
      find.byKey(const Key('save')),
      () async => (await db.select(db.dayNotes).get()).single.body.endsWith('noon'),
    );
    await tester.runAsync(() async {
      final changed = (await db.select(db.dayNotes).get()).single;
      expect(
        (changed.id, changed.body, changed.noteDate),
        (note.id, 'Slept badly, better by noon', DateTime(2026, 11, 20)),
      );
    });

    await show(tester, NoteScreen(editing: note));
    await tapAndWait(tester, find.byKey(const Key('delete')), () async => (await db.select(db.dayNotes).get()).isEmpty);
    await tester.runAsync(() async => expect(await db.select(db.dayNotes).get(), isEmpty));
    await close(tester);
  });

  testWidgets('a side effect keeps what it was; its strength and note can be changed, or it can be deleted', (
    tester,
  ) async {
    await open(tester);
    late SideEffect effect;
    await tester.runAsync(() async {
      await db.logSideEffects(severities: {SideEffectType.nausea: 3}, occurredAt: DateTime(2026, 11, 21, 9));
      effect = (await db.select(db.sideEffects).get()).single;
    });
    await show(tester, EditSideEffectScreen(effect: effect));
    expect(find.text('Nausea'), findsOneWidget);
    expect(find.text('mild (3 of 10)'), findsOneWidget);
    // Nothing here says what to do about it beyond the standing line.
    expect(find.textContaining('contact your prescriber'), findsOneWidget);

    // Drag the slider to the right end: 10.
    final slider = find.byKey(const Key('severity'));
    await tester.drag(slider, Offset(tester.getSize(slider).width, 0));
    await tester.pump();
    expect(find.text('strong (10 of 10)'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('effect-note')), 'After dinner');
    await tapAndWait(
      tester,
      find.byKey(const Key('save')),
      () async => (await db.select(db.sideEffects).get()).single.severity == 10,
    );
    await tester.runAsync(() async {
      final changed = (await db.select(db.sideEffects).get()).single;
      expect(
        (changed.id, changed.type, changed.severity, changed.notes),
        (effect.id, SideEffectType.nausea, 10, 'After dinner'),
      );
      expect(changed.occurredAt, DateTime(2026, 11, 21, 9));
    });

    await show(tester, EditSideEffectScreen(effect: effect));
    await tapAndWait(
      tester,
      find.byKey(const Key('delete')),
      () async => (await db.select(db.sideEffects).get()).isEmpty,
    );
    await tester.runAsync(() async => expect(await db.select(db.sideEffects).get(), isEmpty));
    await close(tester);
  });
}
