import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/database.dart';
import 'security/app_lock.dart';
import 'security/lock_screen.dart';
import 'security/screen_privacy.dart';
import 'settings/settings.dart';
import 'shell/home_shell.dart';
import 'theme/aloft_theme.dart';

class AloftApp extends ConsumerStatefulWidget {
  const AloftApp({super.key});

  @override
  ConsumerState<AloftApp> createState() => _AloftAppState();
}

class _AloftAppState extends ConsumerState<AloftApp> with WidgetsBindingObserver {
  bool _inForeground = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ScreenPrivacy.setHidden(ref.read(settingsProvider).hideInAppSwitcher);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final lock = ref.read(appLockProvider);
    if (state == AppLifecycleState.resumed) {
      lock.onForeground();
    } else if (state == AppLifecycleState.hidden || state == AppLifecycleState.paused) {
      lock.onBackground();
    }
    setState(() => _inForeground = state == AppLifecycleState.resumed);
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final lock = ref.watch(appLockProvider);
    ref.listen(settingsProvider.select((s) => s.hideInAppSwitcher), (_, hide) => ScreenPrivacy.setHidden(hide));

    return MaterialApp(
      title: 'Aloft',
      debugShowCheckedModeBanner: false,
      theme: aloftTheme(Brightness.light),
      darkTheme: aloftTheme(Brightness.dark),
      themeMode: switch (settings.appearance) {
        Appearance.system => ThemeMode.system,
        Appearance.light => ThemeMode.light,
        Appearance.dark => ThemeMode.dark,
      },
      home: const HomeShell(),
      // The lock and the app-switcher cover sit above every screen, sheet and dialog.
      builder: (context, child) => ListenableBuilder(
        listenable: lock,
        builder: (context, _) => Stack(
          children: [
            ?child,
            if (lock.locked) Positioned.fill(child: LockScreen(lock: lock)),
            if (!_inForeground && settings.hideInAppSwitcher) const Positioned.fill(child: PrivacyCover()),
          ],
        ),
      ),
    );
  }
}

/// Shown when the database can't be opened. Nothing is deleted.
class StartupProblemApp extends StatelessWidget {
  const StartupProblemApp({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aloft',
      debugShowCheckedModeBanner: false,
      theme: aloftTheme(Brightness.light),
      darkTheme: aloftTheme(Brightness.dark),
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Aloft can\'t open your data', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, height: 1.45)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
