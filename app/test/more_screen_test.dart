import 'dart:io';

import 'package:aloft/app.dart';
import 'package:aloft/data/database.dart';
import 'package:aloft/data/encrypted_database.dart';
import 'package:aloft/data/body_store.dart';
import 'package:aloft/photos/photo_picker.dart';
import 'package:aloft/reminders/reminders.dart';
import 'package:aloft/security/app_lock.dart';
import 'package:aloft/settings/settings.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_lock_test.dart' show FakeAuthenticator;

void main() {
  testWidgets('turning on the lock from More saves it, and the app locks when it leaves the screen', (tester) async {
    final dir = Directory.systemTemp.createTempSync('aloft_widget');
    addTearDown(() => dir.deleteSync(recursive: true));
    late AloftDatabase db;
    late AppSettings settings;
    await tester.runAsync(() async {
      db = openEncryptedDatabase(File('${dir.path}/aloft.db'), generateDatabaseKey());
      await db.loadSettings(countryCode: 'US');
      // Past the welcome screens, which have their own test.
      settings = await db.saveSettings(const AppSettingsTableCompanion(onboardingDone: Value(true)));
    });
    final lock = AppLock(authenticator: FakeAuthenticator(), enabled: false, lockAfter: LockAfter.immediately);
    await tester.runAsync(lock.detectMethod);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          initialSettingsProvider.overrideWithValue(settings),
          appLockProvider.overrideWithValue(lock),
        ],
        child: const AloftApp(),
      ),
    );
    expect(find.text('Aloft is locked'), findsNothing);

    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('lb'), 200, scrollable: find.byType(Scrollable).last);
    expect(find.text('Lock after'), findsNothing);

    await tester.scrollUntilVisible(find.text('Lock with Face ID'), 200, scrollable: find.byType(Scrollable).last);
    await tester.runAsync(() async {
      await tester.tap(find.text('Lock with Face ID'));
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    // Waits for the saved setting to arrive rather than for a fixed time, which was too short
    // on a busy machine.
    for (var i = 0; i < 100 && find.text('Lock after').evaluate().isEmpty; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pump();
    }
    await tester.pumpAndSettle();
    expect(find.text('Lock after'), findsOneWidget);
    await tester.runAsync(() async => expect((await db.loadSettings()).appLock, isTrue));

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(find.text('Aloft is locked'), findsOneWidget);

    await tester.runAsync(db.close);
  });

  testWidgets('Delete all my data asks first, and cancelling keeps everything', (tester) async {
    final dir = Directory.systemTemp.createTempSync('aloft_widget');
    addTearDown(() => dir.deleteSync(recursive: true));
    late AloftDatabase db;
    late AppSettings settings;
    await tester.runAsync(() async {
      db = openEncryptedDatabase(File('${dir.path}/aloft.db'), generateDatabaseKey());
      await db.loadSettings(countryCode: 'US');
      settings = await db.saveSettings(
        const AppSettingsTableCompanion(onboardingDone: Value(true), goalWeightKg: Value(70)),
      );
      await db.logWeight(kg: 80, measuredAt: DateTime(2026, 11, 20));
    });
    final lock = AppLock(authenticator: FakeAuthenticator(), enabled: false, lockAfter: LockAfter.immediately);
    await tester.runAsync(lock.detectMethod);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          initialSettingsProvider.overrideWithValue(settings),
          appLockProvider.overrideWithValue(lock),
          photoFolderProvider.overrideWithValue(Directory('${dir.path}/photos')),
        ],
        child: const AloftApp(),
      ),
    );
    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();
    final row = find.byKey(const Key('delete-all-data'));
    Future<int> weights() async {
      late int n;
      await tester.runAsync(() async => n = (await db.select(db.weights).get()).length);
      return n;
    }

    // Taps run for real, so the database work that follows a tap isn't stuck on the test clock.
    Future<void> tap(Finder target) async {
      await tester.runAsync(() async {
        await tester.tap(target);
        await Future<void>.delayed(const Duration(milliseconds: 600));
      });
      for (var i = 0; i < 20; i++) {
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
        await tester.pump();
      }
      await tester.pumpAndSettle();
    }

    await tester.scrollUntilVisible(row, 200, scrollable: find.byType(Scrollable).last);
    await tap(row);
    expect(find.textContaining("It can't be undone"), findsOneWidget);
    await tap(find.text('Cancel'));
    expect(await weights(), 1);

    await tap(row);
    await tap(find.byKey(const Key('confirm-delete-all')));
    expect(await weights(), 0);
    expect(find.text('All your data was deleted from this phone.'), findsOneWidget);
    await tester.runAsync(() async => expect((await db.loadSettings()).goalWeightKg, isNull));
    // Still past the welcome screens.
    expect(find.text('Delete all my data'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('More says so when the phone is blocking Aloft notifications', (tester) async {
    final dir = Directory.systemTemp.createTempSync('aloft_widget');
    addTearDown(() => dir.deleteSync(recursive: true));
    late AloftDatabase db;
    late AppSettings settings;
    await tester.runAsync(() async {
      db = openEncryptedDatabase(File('${dir.path}/aloft.db'), generateDatabaseKey());
      await db.loadSettings(countryCode: 'US');
      settings = await db.saveSettings(const AppSettingsTableCompanion(onboardingDone: Value(true)));
    });
    final lock = AppLock(authenticator: FakeAuthenticator(), enabled: false, lockAfter: LockAfter.immediately);
    await tester.runAsync(lock.detectMethod);
    final reminders = _BlockedReminders();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          initialSettingsProvider.overrideWithValue(settings),
          appLockProvider.overrideWithValue(lock),
          remindersProvider.overrideWithValue(reminders),
        ],
        child: const AloftApp(),
      ),
    );
    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();
    final warning = find.textContaining('Notifications are turned off for Aloft');
    await tester.scrollUntilVisible(find.text('Shot and dose days'), 200, scrollable: find.byType(Scrollable).last);
    expect(warning, findsOneWidget);

    // Switched back on in the phone's settings: the warning goes when the app returns.
    reminders.blocked = false;
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(warning, findsNothing);

    // Allowed, but the phone may hold reminders back: More offers the setting that fixes it.
    final late = find.textContaining('may deliver reminders late');
    expect(late, findsNothing);
    reminders.late = true;
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(late, findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('on-time-reminders')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('on-time-reminders')));
    await tester.pump();
    expect(reminders.asked, 1);
    // Switched on in the phone's settings: gone when the app returns.
    reminders.late = false;
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(late, findsNothing);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 5));
  });
}

class _BlockedReminders extends Reminders {
  bool blocked = true;
  bool late = false;
  int asked = 0;

  @override
  Future<bool> allowed() async => !blocked;

  @override
  Future<bool> onTime() async => !late;

  @override
  Future<void> askForOnTime() async => asked++;
}
