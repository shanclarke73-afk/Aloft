import 'dart:io';

import 'package:flutter/services.dart';

/// Android only: keeps Aloft's screen out of the recent-apps view (and screenshots).
/// On iPhone the cover drawn by the app does this job.
abstract final class ScreenPrivacy {
  static const _channel = MethodChannel('aloft/screen_privacy');

  /// Test builds only: `--dart-define=ALOFT_ALLOW_SCREENSHOTS=true` leaves the screen
  /// capturable, so the app can be checked and photographed on an emulator.
  static const _allowScreenshots = bool.fromEnvironment('ALOFT_ALLOW_SCREENSHOTS');

  static Future<void> setHidden(bool hidden) async {
    if (!Platform.isAndroid || _allowScreenshots) return;
    try {
      await _channel.invokeMethod<void>('setSecure', hidden);
    } on PlatformException catch (_) {
    } on MissingPluginException catch (_) {}
  }
}
