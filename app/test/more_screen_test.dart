import 'dart:io';

import 'package:aloft/app.dart';
import 'package:aloft/data/database.dart';
import 'package:aloft/data/encrypted_database.dart';
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
    await tester.pumpAndSettle();
    expect(find.text('Lock after'), findsOneWidget);
    await tester.runAsync(() async => expect((await db.loadSettings()).appLock, isTrue));

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(find.text('Aloft is locked'), findsOneWidget);

    await tester.runAsync(db.close);
  });
}
