import 'package:aloft/data/database.dart';
import 'package:aloft/security/app_lock.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeAuthenticator implements Authenticator {
  String? result;
  int prompts = 0;

  @override
  Future<String?> authenticate(String reason) async {
    prompts++;
    return result;
  }

  @override
  Future<String> methodName() async => 'Face ID';
}

void main() {
  late FakeAuthenticator auth;
  late DateTime now;

  AppLock lock({bool enabled = true, LockAfter after = LockAfter.immediately}) =>
      AppLock(authenticator: auth, enabled: enabled, lockAfter: after, clock: () => now);

  setUp(() {
    auth = FakeAuthenticator();
    now = DateTime(2026, 11, 21, 9);
  });

  test('starts locked when the lock is on, open when it is off', () {
    expect(lock().locked, isTrue);
    expect(lock(enabled: false).locked, isFalse);
  });

  test('unlocks only when the phone confirms it is you', () async {
    final l = lock();
    auth.result = '';
    expect(await l.unlock(), isNull, reason: 'cancelling shows no message');
    expect(l.locked, isTrue);

    auth.result = 'Too many attempts.';
    expect(await l.unlock(), 'Too many attempts.');
    expect(l.locked, isTrue);

    auth.result = null;
    expect(await l.unlock(), isNull);
    expect(l.locked, isFalse);
  });

  test('"Immediately" locks as soon as the app leaves the screen', () async {
    final l = lock();
    await l.unlock();
    l.onBackground();
    expect(l.locked, isTrue);
  });

  test('"1 minute" locks only after a minute away', () async {
    final l = lock(after: LockAfter.oneMinute);
    await l.unlock();

    l.onBackground();
    now = now.add(const Duration(seconds: 59));
    l.onForeground();
    expect(l.locked, isFalse);

    l.onBackground();
    now = now.add(const Duration(seconds: 60));
    l.onForeground();
    expect(l.locked, isTrue);
  });

  test('turning the lock on or off needs the phone to confirm it is you', () async {
    final l = lock(enabled: false);
    String? shown;

    auth.result = 'Set a passcode on this phone to use the app lock.';
    expect(await l.setEnabled(true, onProblem: (m) => shown = m), isFalse);
    expect(l.enabled, isFalse);
    expect(shown, contains('passcode'));

    auth.result = null;
    expect(await l.setEnabled(true), isTrue);
    expect((l.enabled, l.locked), (true, false));

    auth.result = '';
    expect(await l.setEnabled(false), isFalse, reason: 'cancelled');
    expect(l.enabled, isTrue);
  });

  test('never locks when the lock is off', () {
    final l = lock(enabled: false);
    l.onBackground();
    now = now.add(const Duration(hours: 1));
    l.onForeground();
    expect(l.locked, isFalse);
  });
}
