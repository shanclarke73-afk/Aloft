import 'package:aloft/features/about/about_screen.dart';
import 'package:aloft/util/links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('About shows the version, the disclaimer, the trademark notice and the licenses', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appVersionProvider.overrideWith((ref) async => '1.0.0')],
        child: const MaterialApp(home: AboutScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.widget<Text>(find.byKey(const Key('app-version'))).data, 'Version 1.0.0');
    expect(find.text(medicalDisclaimer), findsOneWidget);
    expect(find.text(trademarkNotice), findsOneWidget);
    expect(find.textContaining('nothing you log is sent to us'), findsOneWidget);
    expect(find.textContaining('not a blood level'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('licenses')));
    await tester.tap(find.byKey(const Key('licenses')));
    await tester.pumpAndSettle();
    expect(find.byType(LicensePage), findsOneWidget);
  });

  testWidgets('About links to the privacy policy, terms and support pages', (tester) async {
    final opened = <Uri>[];
    var works = true;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appVersionProvider.overrideWith((ref) async => '1.0.0'),
          linkOpenerProvider.overrideWithValue((url) async {
            opened.add(url);
            return works;
          }),
        ],
        child: const MaterialApp(home: AboutScreen()),
      ),
    );
    await tester.pumpAndSettle();
    for (final key in ['privacy-policy', 'terms', 'support']) {
      await tester.ensureVisible(find.byKey(Key(key)));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key(key)));
      await tester.pumpAndSettle();
    }
    expect(opened.map((u) => u.toString()), [
      'https://peaceofmindapps.com/aloft/privacy',
      'https://peaceofmindapps.com/aloft/terms',
      'https://peaceofmindapps.com/aloft/',
    ]);
    expect(find.byType(SnackBar), findsNothing);

    // A phone with no browser says so instead of doing nothing.
    works = false;
    await tester.tap(find.byKey(const Key('support')));
    await tester.pumpAndSettle();
    expect(find.textContaining("Couldn't open https://peaceofmindapps.com/aloft/"), findsOneWidget);
  });

  test('the disclaimer never tells anyone how much to take, and every listed brand is credited', () {
    expect(medicalDisclaimer, contains('does not provide medical advice or tell you how much to take'));
    for (final brand in ['Ozempic', 'Wegovy', 'Rybelsus', 'Saxenda', 'Victoza', 'Mounjaro', 'Zepbound', 'Trulicity']) {
      expect(trademarkNotice, contains('$brand®'), reason: brand);
    }
    expect(trademarkNotice, contains('not affiliated'));
  });
}
