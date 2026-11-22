import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'reminder_plan.dart';

/// Replaced with [DeviceReminders] in main(); tests and previews schedule nothing.
final remindersProvider = Provider<Reminders>((ref) => const Reminders());

class Reminders {
  const Reminders();

  /// Replaces every pending notification with [plan].
  Future<void> sync(List<PlannedReminder> plan) async {}

  /// Whether the phone will show Aloft's notifications. False when the person said no to the
  /// phone's own question, or switched them off in the phone's settings. Never asks.
  Future<bool> allowed() async => true;

  /// Whether reminders arrive at their minute. On Android that needs the "Alarms & reminders"
  /// setting; without it the phone may hold a reminder back, up to an hour for one set far
  /// ahead. Always true on iPhone.
  Future<bool> onTime() async => true;

  /// Opens the phone's "Alarms & reminders" setting for Aloft.
  Future<void> askForOnTime() async {}
}

/// Whether the phone lets Aloft show notifications right now. Checked again whenever the
/// app comes back to the screen, since the answer is changed in the phone's settings.
final notificationsAllowedProvider = FutureProvider<bool>((ref) => ref.watch(remindersProvider).allowed());

/// Whether reminders arrive on the minute. Checked again whenever the app comes back to the screen.
final remindersOnTimeProvider = FutureProvider<bool>((ref) => ref.watch(remindersProvider).onTime());

/// Local notifications only: scheduled on the phone, nothing is sent anywhere.
class DeviceReminders implements Reminders {
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;
  Future<void> _queue = Future.value();

  Future<void> _init() async {
    if (_ready) return;
    tzdata.initializeTimeZones();
    try {
      final zone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(zone.identifier));
    } catch (_) {}
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    _ready = true;
  }

  /// Asks the first time there's something to remind about; after that the phone remembers
  /// the answer and this doesn't ask again.
  Future<bool> _allowed() async {
    if (Platform.isIOS) {
      final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      return await ios?.requestPermissions(alert: true, sound: true) ?? false;
    }
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    return await android?.requestNotificationsPermission() ?? true;
  }

  @override
  Future<bool> allowed() async {
    try {
      await _init();
      if (Platform.isIOS) {
        final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
        return (await ios?.checkPermissions())?.isEnabled ?? true;
      }
      final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      return await android?.areNotificationsEnabled() ?? true;
    } catch (_) {
      return true;
    }
  }

  AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

  @override
  Future<bool> onTime() async {
    if (!Platform.isAndroid) return true;
    try {
      await _init();
      return await _android?.canScheduleExactNotifications() ?? false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> askForOnTime() async {
    if (!Platform.isAndroid) return;
    try {
      await _init();
      await _android?.requestExactAlarmsPermission();
    } catch (_) {}
  }

  @override
  Future<void> sync(List<PlannedReminder> plan) {
    // One at a time, so two quick changes can't interleave a cancel and a schedule.
    return _queue = _queue.then((_) => _sync(plan));
  }

  Future<void> _sync(List<PlannedReminder> plan) async {
    try {
      await _init();
      await _plugin.cancelAll();
      if (plan.isEmpty || !await _allowed()) return;
      // Asking for exact timing without the setting throws, so check each time: it can be
      // switched off in the phone's settings while the app is closed.
      final exact = await onTime();
      var id = 1;
      for (final reminder in plan) {
        final at = reminder.at;
        await _plugin.zonedSchedule(
          id: id++,
          title: reminder.title,
          body: reminder.body,
          scheduledDate: tz.TZDateTime(tz.local, at.year, at.month, at.day, at.hour, at.minute),
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              reminder.channel.id,
              reminder.channel.label,
              channelDescription: reminder.channel.description,
              importance: Importance.high,
              // Shown as "Aloft" with the content hidden on a locked Android phone.
              visibility: NotificationVisibility.private,
            ),
            iOS: DarwinNotificationDetails(threadIdentifier: reminder.channel.id),
          ),
          androidScheduleMode: exact
              ? AndroidScheduleMode.exactAllowWhileIdle
              : AndroidScheduleMode.inexactAllowWhileIdle,
        );
      }
    } catch (e) {
      debugPrint('Scheduling reminders failed: $e');
    }
  }
}
