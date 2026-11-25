import 'package:aloft/pro/pro.dart';
import 'package:aloft/util/links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:purchases_flutter/purchases_flutter.dart' show PeriodUnit;

/// A store that sells nothing real: the test decides what each call answers.
class FakeStore implements ProStore {
  FakeStore({this.alreadyPro = false, this.yearlyTrial});
  final bool alreadyPro;

  /// The trial the store offers on the yearly plan; none for someone who has subscribed before.
  final FreeTrial? yearlyTrial;
  PurchaseOutcome next = PurchaseOutcome.bought;
  bool restoreFinds = false;
  bool reachable = true;
  ProPlan? bought;
  void Function(bool pro)? onChange;

  @override
  bool get available => true;

  @override
  Future<void> start(void Function(bool pro) onChange) async {
    this.onChange = onChange;
    onChange(alreadyPro);
  }

  @override
  Future<List<ProPlan>> plans() async => reachable
      ? [
          ProPlan(kind: ProPlanKind.yearly, price: r'$14.99', trial: yearlyTrial, handle: 'y'),
          const ProPlan(kind: ProPlanKind.lifetime, price: r'$29.99', handle: 'l'),
          const ProPlan(kind: ProPlanKind.monthly, price: r'$1.99', handle: 'm'),
        ]
      : const [];

  @override
  Future<PurchaseOutcome> buy(ProPlan plan) async {
    if (next == PurchaseOutcome.bought) bought = plan;
    return next;
  }

  @override
  Future<bool> restore() async => restoreFinds;

  @override
  Future<Uri?> manageUrl() async => null;
}

final openedLinks = <Uri>[];

void main() {
  test('a release build never connects with a test-store key, which would shut the app down', () {
    expect(canUseStoreKey('', releaseBuild: false), isFalse);
    expect(canUseStoreKey('test_abc', releaseBuild: false), isTrue);
    expect(canUseStoreKey('test_abc', releaseBuild: true), isFalse);
    expect(canUseStoreKey('goog_abc', releaseBuild: true), isTrue);
    expect(canUseStoreKey('appl_abc', releaseBuild: true), isTrue);
  });

  test('each store build uses its own key, and a debug build falls back to the shared one', () {
    String key(TargetPlatform p) => storeKeyFor(p, shared: 'test_x', android: 'goog_a', ios: 'appl_i');
    expect(key(TargetPlatform.android), 'goog_a');
    expect(key(TargetPlatform.iOS), 'appl_i');
    expect(storeKeyFor(TargetPlatform.android, shared: 'test_x', android: '', ios: 'appl_i'), 'test_x');
    expect(storeKeyFor(TargetPlatform.iOS, shared: '', android: 'goog_a', ios: ''), '');
  });

  test('a trial is described in days or months, and an unusable length means no trial', () {
    expect(FreeTrial.from(PeriodUnit.week, 2)!.length, '14 days');
    expect(FreeTrial.from(PeriodUnit.week, 2)!.adjective, '14-day');
    expect(FreeTrial.from(PeriodUnit.day, 1)!.length, '1 day');
    expect(FreeTrial.from(PeriodUnit.month, 1)!.length, '1 month');
    expect(FreeTrial.from(PeriodUnit.year, 1)!.adjective, '12-month');
    expect(FreeTrial.from(PeriodUnit.unknown, 2), isNull);
    expect(FreeTrial.from(PeriodUnit.day, 0), isNull);
  });

  Future<ProviderContainer> show(WidgetTester tester, {ProStore? store}) async {
    late ProviderContainer container;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          if (store != null) proStoreProvider.overrideWithValue(store),
          linkOpenerProvider.overrideWithValue((url) async {
            openedLinks.add(url);
            return true;
          }),
        ],
        child: Consumer(
          builder: (context, ref, _) {
            container = ProviderScope.containerOf(context);
            return const MaterialApp(home: ProScreen());
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  Future<void> tap(WidgetTester tester, Key key) async {
    // The list builds rows as they scroll into view, so scroll to it first.
    await tester.scrollUntilVisible(find.byKey(key), 120, scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(key));
    await tester.pumpAndSettle();
  }

  testWidgets('a build with no store explains Pro and offers nothing to buy', (tester) async {
    final container = await show(tester);
    expect(container.read(proProvider), isFalse);
    expect(find.text(r'$14.99 per year'), findsOneWidget);
    expect(find.textContaining("isn't available in this version"), findsOneWidget);
    expect(find.byKey(const Key('pro-buy')), findsNothing);
    expect(find.byKey(const Key('pro-restore')), findsNothing);
  });

  testWidgets('the paywall shows the store\'s prices and the renewal terms, and buying switches Pro on', (
    tester,
  ) async {
    final store = FakeStore();
    final container = await show(tester, store: store);
    // Yearly is chosen to start with, and its terms say how it renews and how to cancel.
    expect(find.text('Continue with Yearly'), findsOneWidget);
    expect(find.textContaining(r'Renews automatically at $14.99 a year'), findsOneWidget);
    expect(find.textContaining('Cancel any time'), findsWidgets);
    expect(find.text(r'$1.99 per month'), findsOneWidget);

    await tap(tester, const Key('plan-lifetime'));
    expect(find.text('Continue with Lifetime'), findsOneWidget);
    expect(find.textContaining("It doesn't renew"), findsOneWidget);

    await tap(tester, const Key('pro-buy'));
    expect(store.bought!.kind, ProPlanKind.lifetime);
    expect(container.read(proProvider), isTrue);
    expect(find.byKey(const Key('pro-active')), findsOneWidget);
    // Someone who has Pro is never shown the plans again.
    expect(find.byKey(const Key('pro-buy')), findsNothing);
    expect(find.byKey(const Key('pro-manage')), findsOneWidget);
  });

  testWidgets('a free trial is stated with its length, the price after it and that it renews', (tester) async {
    final store = FakeStore(yearlyTrial: FreeTrial.from(PeriodUnit.week, 2));
    await show(tester, store: store);
    expect(find.text('Start 14-day free trial'), findsOneWidget);
    expect(find.text('Best value · 14 days free'), findsOneWidget);
    final terms = tester.widget<Text>(find.byKey(const Key('pro-terms'))).data!;
    expect(terms, contains(r'Free for 14 days, then $14.99 a year'));
    expect(terms, contains(r'renews automatically at $14.99 a year'));
    expect(terms, contains('before the trial ends'));

    // The trial belongs to the yearly plan only.
    await tap(tester, const Key('plan-monthly'));
    expect(find.text('Continue with Monthly'), findsOneWidget);
    expect(find.textContaining('Free for'), findsNothing);

    await tap(tester, const Key('plan-yearly'));
    await tap(tester, const Key('pro-buy'));
    expect(store.bought!.kind, ProPlanKind.yearly);
  });

  testWidgets('someone the store offers no trial sees no mention of one', (tester) async {
    await show(tester, store: FakeStore());
    expect(find.text('Continue with Yearly'), findsOneWidget);
    expect(find.text('Best value'), findsOneWidget);
    expect(find.textContaining('free trial'), findsNothing);
    expect(find.textContaining('Free for'), findsNothing);
  });

  testWidgets('backing out of a purchase says nothing; a failed one says no charge was made', (tester) async {
    final store = FakeStore()..next = PurchaseOutcome.cancelled;
    final container = await show(tester, store: store);
    await tap(tester, const Key('pro-buy'));
    expect(container.read(proProvider), isFalse);
    expect(find.byKey(const Key('pro-message')), findsNothing);

    store.next = PurchaseOutcome.failed;
    await tap(tester, const Key('pro-buy'));
    expect(container.read(proProvider), isFalse);
    expect(find.textContaining("you haven't been charged"), findsOneWidget);
  });

  testWidgets('Restore purchases finds an earlier purchase, or says there is none', (tester) async {
    final store = FakeStore();
    final container = await show(tester, store: store);
    await tap(tester, const Key('pro-restore'));
    expect(find.textContaining('No earlier Aloft Pro purchase was found'), findsOneWidget);
    expect(container.read(proProvider), isFalse);

    store.restoreFinds = true;
    await tap(tester, const Key('pro-restore'));
    expect(container.read(proProvider), isTrue);
    expect(find.byKey(const Key('pro-active')), findsOneWidget);
  });

  testWidgets('Pro follows the store: on at launch for an owner, off again when a subscription ends', (tester) async {
    final store = FakeStore(alreadyPro: true);
    final container = await show(tester, store: store);
    expect(container.read(proProvider), isTrue);
    expect(find.byKey(const Key('pro-active')), findsOneWidget);

    store.onChange!(false);
    await tester.pumpAndSettle();
    expect(container.read(proProvider), isFalse);
    expect(find.byKey(const Key('pro-buy')), findsOneWidget);
  });

  testWidgets('when the store can\'t be reached the screen says so and offers to try again', (tester) async {
    final store = FakeStore()..reachable = false;
    await show(tester, store: store);
    expect(find.textContaining("can't be reached"), findsOneWidget);
    expect(find.byKey(const Key('pro-buy')), findsNothing);
    store.reachable = true;
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('pro-buy')), findsOneWidget);
  });

  testWidgets('the paywall links to the terms and the privacy policy, as the stores require', (tester) async {
    openedLinks.clear();
    await show(tester, store: FakeStore());
    await tap(tester, const Key('pro-terms-link'));
    await tap(tester, const Key('pro-privacy-link'));
    expect(openedLinks.map((u) => u.path), ['/aloft/terms', '/aloft/privacy']);
  });
}
