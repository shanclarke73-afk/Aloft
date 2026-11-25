import 'package:flutter/widgets.dart';

/// Keeps a screen's content above the phone's own navigation buttons or gesture bar.
///
/// Newer Android versions draw apps underneath that bar, so a Save button at the end of a
/// page would sit behind the buttons. Given to a Scaffold as its `bottomNavigationBar`, this
/// reserves exactly the bar's height and nothing where there is no bar (inside the home tabs,
/// which already sit above the tab bar, or while the keyboard is up).
class SystemBarSpacer extends StatelessWidget {
  const SystemBarSpacer({super.key});

  @override
  Widget build(BuildContext context) => SizedBox(height: MediaQuery.paddingOf(context).bottom);
}
