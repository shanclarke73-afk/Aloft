import 'package:aloft/features/about/about_screen.dart';
import 'package:aloft/widgets/system_bar_spacer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('a page stops above the phone\'s navigation buttons, and uses the full height without them', (
    tester,
  ) async {
    Future<double> pageBottom(double systemBar) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [appVersionProvider.overrideWith((ref) async => '1.0.0')],
          child: MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(
                size: const Size(400, 800),
                padding: EdgeInsets.only(bottom: systemBar),
              ),
              child: const AboutScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byType(SystemBarSpacer)).height, systemBar);
      return tester.getBottomLeft(find.byType(SingleChildScrollView)).dy;
    }

    final screen = tester.view.physicalSize.height / tester.view.devicePixelRatio;
    expect(await pageBottom(48), screen - 48);
    expect(await pageBottom(0), screen);
  });
}
