import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

import '../data/database.dart';

final appLockProvider = Provider<AppLock>((ref) => throw UnimplementedError('app lock not created'));

/// The phone's own Face ID / Touch ID / fingerprint / passcode check.
abstract class Authenticator {
  /// Returns null when the person passed, or a reason they didn't. An empty reason means
  /// they cancelled and nothing needs to be shown.
  Future<String?> authenticate(String reason);

  /// "Face ID", "Touch ID", "fingerprint" or "passcode", for labels.
  Future<String> methodName();
}

class DeviceAuthenticator implements Authenticator {
  final _auth = LocalAuthentication();

  @override
  Future<String?> authenticate(String reason) async {
    try {
      if (!await _auth.isDeviceSupported()) {
        return 'Set a passcode on this phone to use the app lock.';
      }
      final ok = await _auth.authenticate(localizedReason: reason, persistAcrossBackgrounding: true);
      return ok ? null : '';
    } on LocalAuthException catch (e) {
      return switch (e.code) {
        LocalAuthExceptionCode.userCanceled || LocalAuthExceptionCode.systemCanceled => '',
        LocalAuthExceptionCode.noCredentialsSet => 'Set a passcode on this phone to use the app lock.',
        LocalAuthExceptionCode.temporaryLockout ||
        LocalAuthExceptionCode.biometricLockout => 'Too many attempts. Use your phone passcode, or try again shortly.',
        _ => 'Couldn\'t check it\'s you (${e.code.name}). Try again.',
      };
    } catch (_) {
      return 'Couldn\'t check it\'s you. Try again.';
    }
  }

  @override
  Future<String> methodName() async {
    try {
      final types = await _auth.getAvailableBiometrics();
      if (types.isEmpty) return 'passcode';
      if (Platform.isIOS) return types.contains(BiometricType.face) ? 'Face ID' : 'Touch ID';
      return types.contains(BiometricType.face) && !types.contains(BiometricType.fingerprint)
          ? 'face unlock'
          : 'fingerprint';
    } catch (_) {
      return 'passcode';
    }
  }
}

/// Optional lock in front of the whole app (SPEC 6.12). Locked whenever the app starts.
class AppLock extends ChangeNotifier {
  AppLock({required this.authenticator, required bool enabled, required this.lockAfter, DateTime Function()? clock})
    : _enabled = enabled,
      _locked = enabled,
      _now = clock ?? DateTime.now;

  final Authenticator authenticator;
  final DateTime Function() _now;

  LockAfter lockAfter;
  bool _enabled;
  bool _locked;
  bool _authenticating = false;
  DateTime? _backgroundedAt;
  int _awayOnPurpose = 0;
  DateTime? _expectedLeaveAt;
  DateTime? _leftOnPurposeAt;
  String methodName = 'passcode';

  /// How long Aloft's own camera, photo chooser, file chooser or share sheet can stay open
  /// before coming back asks for the lock again.
  static const awayOnPurposeLimit = Duration(minutes: 5);

  bool get enabled => _enabled;
  bool get locked => _locked;

  Future<void> detectMethod() async {
    methodName = await authenticator.methodName();
    notifyListeners();
  }

  /// The app left the screen. The system's own Face ID sheet also sends the app to the
  /// background briefly, so that doesn't count.
  void onBackground() {
    if (_authenticating || _awayOnPurpose > 0 || _leftOnPurposeAt != null) return;
    final expected = _expectedLeaveAt;
    _expectedLeaveAt = null;
    if (expected != null && _now().difference(expected) < const Duration(seconds: 10)) {
      _leftOnPurposeAt = _now();
      return;
    }
    _backgroundedAt ??= _now();
    if (_enabled && !_locked && lockAfter == LockAfter.immediately) {
      _locked = true;
      notifyListeners();
    }
  }

  void onForeground() {
    final leftOnPurpose = _leftOnPurposeAt;
    if (leftOnPurpose != null) {
      _leftOnPurposeAt = null;
      if (_enabled && !_locked && _now().difference(leftOnPurpose) >= awayOnPurposeLimit) {
        _locked = true;
        notifyListeners();
      }
      return;
    }
    final since = _backgroundedAt;
    _backgroundedAt = null;
    if (_enabled && !_locked && since != null && _now().difference(since) >= const Duration(minutes: 1)) {
      _locked = true;
      notifyListeners();
    }
  }

  /// Runs something that covers Aloft with a screen the person asked for from inside the
  /// app: the camera, the photo or file chooser, the share sheet. The phone reports that as
  /// leaving the app, but coming straight back shouldn't ask for the lock again. Staying
  /// away longer than [awayOnPurposeLimit] still locks.
  Future<T> awayOnPurpose<T>(Future<T> Function() task) async {
    final started = _now();
    _awayOnPurpose++;
    try {
      return await task();
    } finally {
      _awayOnPurpose--;
      _backgroundedAt = null;
      if (_enabled && !_locked && _now().difference(started) >= awayOnPurposeLimit) {
        _locked = true;
        notifyListeners();
      }
    }
  }

  /// Aloft is about to hand the screen to another app for something the person asked for
  /// (opening a saved report), with nothing to wait on that says when they are back. The next
  /// time the app leaves the screen, within a few seconds, is treated like [awayOnPurpose].
  void expectLeaving() => _expectedLeaveAt = _now();

  /// Shows the system prompt. Returns a message to show, or null.
  Future<String?> unlock() async {
    if (_authenticating || !_locked) return null;
    final problem = await _check('Unlock Aloft');
    if (problem == null) {
      _locked = false;
      notifyListeners();
    }
    return problem == null || problem.isEmpty ? null : problem;
  }

  /// Turning the lock on or off always asks first: on, so nobody locks themselves out;
  /// off, so someone holding an unlocked phone can't remove it. Returns whether it changed;
  /// [onProblem] gets a message when there's something to tell the person.
  Future<bool> setEnabled(bool on, {void Function(String message)? onProblem}) async {
    final problem = await _check(on ? 'Turn on the Aloft lock' : 'Turn off the Aloft lock');
    if (problem != null) {
      if (problem.isNotEmpty) onProblem?.call(problem);
      return false;
    }
    _enabled = on;
    _locked = false;
    notifyListeners();
    return true;
  }

  Future<String?> _check(String reason) async {
    _authenticating = true;
    try {
      return await authenticator.authenticate(reason);
    } finally {
      _authenticating = false;
      _backgroundedAt = null;
    }
  }
}
