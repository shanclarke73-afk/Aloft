import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../security/app_lock.dart';

/// Which of the three ways to get Pro a plan is.
enum ProPlanKind { yearly, lifetime, monthly }

/// One way to buy Pro, with the price the store gave for this person's country.
class ProPlan {
  const ProPlan({required this.kind, required this.price, this.handle});
  final ProPlanKind kind;

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

  /// What the stores require beside a price: how it renews, or that it doesn't.
  String get terms => switch (kind) {
    ProPlanKind.yearly =>
      'Renews automatically at $price a year until you cancel. Cancel any time in your store account, at least '
          '24 hours before it renews.',
    ProPlanKind.monthly =>
      'Renews automatically at $price a month until you cancel. Cancel any time in your store account, at least '
          '24 hours before it renews.',
    ProPlanKind.lifetime => 'One payment of $price. It doesn\'t renew and there is nothing to cancel.',
  };
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
      final found = <ProPlan>[
        for (final package in offering.availablePackages)
          if (switch (package.packageType) {
                PackageType.annual => ProPlanKind.yearly,
                PackageType.lifetime => ProPlanKind.lifetime,
                PackageType.monthly => ProPlanKind.monthly,
                _ => null,
              }
              case final kind?)
            ProPlan(kind: kind, price: package.storeProduct.priceString, handle: package),
      ]..sort((a, b) => a.kind.index.compareTo(b.kind.index));
      return found;
    } catch (_) {
      return const [];
    }
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
