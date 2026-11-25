import 'package:aloft/widgets/wide_frame.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<Size> shownAt(WidgetTester tester, Size screen) async {
    tester.view.physicalSize = screen;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
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
  });

  testWidgets('an iPad gets a centred column and screens are told its width', (tester) async {
    expect((await shownAt(tester, const Size(1032, 1376))).width, WideFrame.maxWidth);
    final left = tester.getTopLeft(find.byKey(const Key('body'))).dx;
    expect(left, (1032 - WideFrame.maxWidth) / 2);
  });
}
