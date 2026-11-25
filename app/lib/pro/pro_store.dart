import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../security/app_lock.dart';

/// Which of the three ways to get Pro a plan is.
enum ProPlanKind { yearly, lifetime, monthly }

/// A free trial the store is offering this person before the first payment.
class FreeTrial {
  const FreeTrial(this.days, {this.months = 0});

  /// What the store reported, as a length in whole days or whole months. Null when it gave
  /// nothing usable, so that no trial is promised.
  static FreeTrial? from(PeriodUnit unit, int count) => switch (unit) {
    _ when count <= 0 => null,
    PeriodUnit.day => FreeTrial(count),
    PeriodUnit.week => FreeTrial(count * 7),
    PeriodUnit.month => FreeTrial(0, months: count),
    PeriodUnit.year => FreeTrial(0, months: count * 12),
    PeriodUnit.unknown => null,
  };

  final int days;
  final int months;

  /// "14 days", "1 month".
  String get length =>
      months > 0 ? '$months ${months == 1 ? 'month' : 'months'}' : '$days ${days == 1 ? 'day' : 'days'}';

  /// "14-day", "1-month".
  String get adjective => months > 0 ? '$months-month' : '$days-day';
}

/// One way to buy Pro, with the price the store gave for this person's country.
class ProPlan {
  const ProPlan({required this.kind, required this.price, this.trial, this.handle});
  final ProPlanKind kind;

  /// The free trial this person would get with this plan. Null when the store offers none,
  /// which includes anyone who has subscribed before. Only ever what the store reported.
  final FreeTrial? trial;

  /// As the store formats it: "$14.99".
  final String price;

  /// The store's own object for this plan; only the store that made it reads it.
  final Object? handle;

  String get name => switch (kind) {
    ProPlanKind.yearly => 'Yearly',
    ProPlanKind.lifetime => 'Lifetime',
    ProPlanKind.monthly => 'Monthly',
  };

  /// "$14.99 per year".
  String get priceLine => switch (kind) {
    ProPlanKind.yearly => '$price per year',
    ProPlanKind.lifetime => '$price once',
    ProPlanKind.monthly => '$price per month',
  };

  /// The buy button: "Start 14-day free trial", or "Continue with Yearly".
  String get buyLabel => trial == null ? 'Continue with $name' : 'Start ${trial!.adjective} free trial';

  /// What the stores require beside a price: the trial if there is one, how it renews, or
  /// that it doesn't.
  String get terms {
    final each = kind == ProPlanKind.yearly ? 'a year' : 'a month';
    if (kind == ProPlanKind.lifetime) {
      return 'One payment of $price. It doesn\'t renew and there is nothing to cancel.';
    }
    if (trial == null) {
      return 'Renews automatically at $price $each until you cancel. Cancel any time in your store account, at '
          'least 24 hours before it renews.';
    }
    return 'Free for ${trial!.length}, then $price $each. It renews automatically at $price $each until you '
        'cancel. Cancel any time in your store account, at least 24 hours before the trial ends, and you '
        'won\'t be charged.';
  }
}

enum PurchaseOutcome { bought, cancelled, failed }

/// Buying and restoring Pro. The app talks to this, never to a store's library directly, so
/// tests and builds without a store key run without one.
abstract class ProStore {
  /// False when this build has no store to buy from; the Pro screen then only explains.
  bool get available;

  /// Connects, reports whether the person has Pro now, and again whenever that changes.
  Future<void> start(void Function(bool pro) onChange);

  /// The plans on offer, yearly first. Empty if the store couldn't be reached.
  Future<List<ProPlan>> plans();

  Future<PurchaseOutcome> buy(ProPlan plan);

  /// Looks for an earlier purchase on this store account. Returns whether Pro was found.
  Future<bool> restore();

  /// Where a subscription is managed or cancelled, when the person has one.
  Future<Uri?> manageUrl();
}

/// No store: nothing can be bought.
class NoProStore implements ProStore {
  const NoProStore();

  @override
  bool get available => false;
  @override
  Future<void> start(void Function(bool pro) onChange) async {}
  @override
  Future<List<ProPlan>> plans() async => const [];
  @override
  Future<PurchaseOutcome> buy(ProPlan plan) async => PurchaseOutcome.failed;
  @override
  Future<bool> restore() async => false;
  @override
  Future<Uri?> manageUrl() async => null;
}

/// Set in main() when the build was given a store key.
final proStoreProvider = Provider<ProStore>((ref) => const NoProStore());

/// The store key this build was made with: `--dart-define=ALOFT_RC_KEY=...`. Empty in a build
/// with no purchases. A key that starts with "test_" is RevenueCat's Test Store, where
/// purchases are pretend and free; it must never go into a build for the App Store or Play.
const revenueCatKey = String.fromEnvironment('ALOFT_RC_KEY');

/// The keys for store builds. Google Play and the App Store each have their own, and one
/// `dart_defines.release.json` holds both: `ALOFT_RC_KEY_ANDROID` ("goog_...") and
/// `ALOFT_RC_KEY_IOS` ("appl_...").
const revenueCatAndroidKey = String.fromEnvironment('ALOFT_RC_KEY_ANDROID');
const revenueCatIosKey = String.fromEnvironment('ALOFT_RC_KEY_IOS');

/// The key this build uses on [platform]: that store's own key when the build has one,
/// otherwise [shared] (the Test Store key in a debug build).
String storeKeyFor(
  TargetPlatform platform, {
  String shared = revenueCatKey,
  String android = revenueCatAndroidKey,
  String ios = revenueCatIosKey,
}) {
  final own = switch (platform) {
    TargetPlatform.android => android,
    TargetPlatform.iOS => ios,
    _ => '',
  };
  return own.isNotEmpty ? own : shared;
}

/// Whether this build should connect to the store with [key]. RevenueCat shuts the app down
/// if a release build starts with a Test Store key, so that pairing never connects: the app
/// then simply has no store, and the Pro screen says buying isn't available.
bool canUseStoreKey(String key, {required bool releaseBuild}) =>
    key.isNotEmpty && !(releaseBuild && key.startsWith('test_'));

/// RevenueCat, with one entitlement ("pro") and one offering holding the three plans. It keeps
/// an anonymous ID for the store account and nothing Aloft has logged ever goes to it.
class RevenueCatStore implements ProStore {
  RevenueCatStore(this._key, this._lock);
  final String _key;

  /// The store's own purchase sheet covers Aloft; coming back shouldn't ask for the lock.
  final AppLock _lock;
  static const _entitlement = 'pro';
  bool _started = false;

  static bool _isPro(CustomerInfo info) => info.entitlements.active.containsKey(_entitlement);

  @override
  bool get available => true;

  @override
  Future<void> start(void Function(bool pro) onChange) async {
    try {
      if (!_started) {
        await Purchases.configure(PurchasesConfiguration(_key));
        _started = true;
      }
      Purchases.addCustomerInfoUpdateListener((info) => onChange(_isPro(info)));
      onChange(_isPro(await Purchases.getCustomerInfo()));
    } catch (_) {
      // Offline or the store is unreachable: stay as we are and try again next launch.
    }
  }

  @override
  Future<List<ProPlan>> plans() async {
    try {
      final offering = (await Purchases.getOfferings()).current;
      if (offering == null) return const [];
      final trials = await _trials([for (final package in offering.availablePackages) package.storeProduct]);
      final found = <ProPlan>[
        for (final package in offering.availablePackages)
          if (switch (package.packageType) {
                PackageType.annual => ProPlanKind.yearly,
                PackageType.lifetime => ProPlanKind.lifetime,
                PackageType.monthly => ProPlanKind.monthly,
                _ => null,
              }
              case final kind?)
            ProPlan(
              kind: kind,
              price: package.storeProduct.priceString,
              trial: trials[package.storeProduct.identifier],
              handle: package,
            ),
      ]..sort((a, b) => a.kind.index.compareTo(b.kind.index));
      return found;
    } catch (_) {
      return const [];
    }
  }

  /// The free trial each product would give this person, by product ID. A product missing
  /// from the answer has none, and when the store can't say, none is promised.
  ///
  /// Google Play only hands over offers the person can still use, so a free phase on the
  /// default option is theirs. The App Store lists the trial on the product whoever asks, so
  /// there RevenueCat is asked whether this person is still eligible for it.
  Future<Map<String, FreeTrial>> _trials(List<StoreProduct> products) async {
    final trials = <String, FreeTrial>{};
    final toCheck = <String, FreeTrial>{};
    for (final product in products) {
      final option = product.defaultOption;
      if (option != null) {
        final period = option.freePhase?.billingPeriod;
        final trial = period == null ? null : FreeTrial.from(period.unit, period.value);
        if (trial != null) trials[product.identifier] = trial;
        continue;
      }
      final intro = product.introductoryPrice;
      if (intro == null || intro.price != 0) continue;
      final trial = FreeTrial.from(intro.periodUnit, intro.periodNumberOfUnits * intro.cycles);
      if (trial != null) toCheck[product.identifier] = trial;
    }
    if (toCheck.isEmpty) return trials;
    try {
      final eligibility = await Purchases.checkTrialOrIntroductoryPriceEligibility(toCheck.keys.toList());
      for (final MapEntry(key: id, value: trial) in toCheck.entries) {
        if (eligibility[id]?.status == IntroEligibilityStatus.introEligibilityStatusEligible) trials[id] = trial;
      }
    } catch (_) {
      // Not known: show the full price only.
    }
    return trials;
  }

  @override
  Future<PurchaseOutcome> buy(ProPlan plan) async {
    final package = plan.handle;
    if (package is! Package) return PurchaseOutcome.failed;
    try {
      final result = await _lock.awayOnPurpose(() => Purchases.purchase(PurchaseParams.package(package)));
      return _isPro(result.customerInfo) ? PurchaseOutcome.bought : PurchaseOutcome.failed;
    } on PlatformException catch (e) {
      return PurchasesErrorHelper.getErrorCode(e) == PurchasesErrorCode.purchaseCancelledError
          ? PurchaseOutcome.cancelled
          : PurchaseOutcome.failed;
    } catch (_) {
      return PurchaseOutcome.failed;
    }
  }

  @override
  Future<bool> restore() async {
    try {
      return _isPro(await Purchases.restorePurchases());
    } catch (_) {
      return false;
    }
  }

  @override
  Future<Uri?> manageUrl() async {
    try {
      final url = (await Purchases.getCustomerInfo()).managementURL;
      return url == null ? null : Uri.tryParse(url);
    } catch (_) {
      return null;
    }
  }
}
