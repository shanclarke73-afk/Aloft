import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../util/device.dart';

/// On an iPad or tablet, keeps the app to a comfortable reading width in the middle of the
/// screen instead of stretching the phone layout edge to edge. Phones are left alone.
///
/// Everything inside (screens, sheets, dialogs) is told the narrower width, so nothing lays
/// itself out for the full screen and then gets cut off.
class WideFrame extends StatelessWidget {
  const WideFrame({super.key, required this.child});
  final Widget child;

  /// The widest the app's column gets.
  static const maxWidth = 640.0;

  /// Screens narrower than this are treated as phones.
  static const _tabletFrom = 700.0;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    // Keeps the app's wording ("this phone" / "this iPad") right for the screen it is on.
    deviceWord = deviceWordFor(media.size, ios: defaultTargetPlatform == TargetPlatform.iOS);
    if (media.size.width < _tabletFrom) return child;
    final scheme = Theme.of(context).colorScheme;
    return ColoredBox(
      color: scheme.surfaceContainerHighest,
      child: Center(
        child: SizedBox(
          width: maxWidth,
          child: MediaQuery(
            data: media.copyWith(
              size: Size(maxWidth, media.size.height),
              padding: media.padding.copyWith(left: 0, right: 0),
              viewPadding: media.viewPadding.copyWith(left: 0, right: 0),
            ),
            child: ClipRect(child: child),
          ),
        ),
      ),
    );
  }
}
