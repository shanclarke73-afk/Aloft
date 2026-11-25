import 'dart:ui';

/// What Aloft calls the thing it is running on, in sentences like "It stays on this phone":
/// "phone", "iPad" or "tablet". Set once in main(), before anything is shown.
String deviceWord = 'phone';

/// Screens whose short side is at least this many points are tablets.
const _tabletShortSide = 600.0;

/// The word for a screen of [size] (in points) on iOS or on anything else.
String deviceWordFor(Size size, {required bool ios}) =>
    size.shortestSide < _tabletShortSide ? 'phone' : (ios ? 'iPad' : 'tablet');
