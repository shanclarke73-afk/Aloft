import 'package:flutter_test/flutter_test.dart';

/// Lets real time pass until [finder] finds something, for up to about ten seconds.
///
/// Widget tests that wait on the real encrypted database can't know how long it will take:
/// a fixed delay that is plenty on a laptop is too short on a busy build machine. Follow
/// this with an `expect`, which still fails if the thing never appears.
Future<void> pumpUntilFound(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 200 && finder.evaluate().isEmpty; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pump();
  }
}
