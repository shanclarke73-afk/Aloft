import 'package:aloft/util/device.dart';
import 'package:aloft/widgets/wide_frame.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<Size> shownAt(WidgetTester tester, Size screen) async {
    tester.view.physicalSize = screen;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    addTearDown(() => deviceWord = 'phone');
    late Size told;
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => WideFrame(child: child!),
        home: Builder(
          builder: (context) {
            told = MediaQuery.sizeOf(context);
            return const Scaffold(body: SizedBox.expand(key: Key('body')));
          },
        ),
      ),
    );
    expect(tester.getSize(find.byKey(const Key('body'))).width, told.width);
    return told;
  }

  testWidgets('a phone keeps its full width', (tester) async {
    expect((await shownAt(tester, const Size(402, 874))).width, 402);
    expect(deviceWord, 'phone');
  });

  testWidgets('an iPad gets a centred column and screens are told its width', (tester) async {
    expect((await shownAt(tester, const Size(1032, 1376))).width, WideFrame.maxWidth);
    final left = tester.getTopLeft(find.byKey(const Key('body'))).dx;
    expect(left, (1032 - WideFrame.maxWidth) / 2);
  });

  testWidgets('the app says iPad on an iPad and tablet on an Android tablet', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    await shownAt(tester, const Size(1032, 1376));
    expect(deviceWord, 'iPad');
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    await shownAt(tester, const Size(800, 1280));
    expect(deviceWord, 'tablet');
    debugDefaultTargetPlatformOverride = null;
  });

  test('a phone turned sideways is still a phone', () {
    expect(deviceWordFor(const Size(874, 402), ios: true), 'phone');
    expect(deviceWordFor(const Size(1376, 1032), ios: true), 'iPad');
  });
}
