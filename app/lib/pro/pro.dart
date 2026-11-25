import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/aloft_theme.dart';
import '../util/links.dart';
import '../widgets/form_widgets.dart';
import 'pro_store.dart';
import 'review_access.dart';
import '../util/device.dart';
import '../widgets/system_bar_spacer.dart';

export 'pro_store.dart';

/// Test builds only: `--dart-define=ALOFT_PRO=true` starts with Pro switched on, so the Pro
/// features can be tried without buying anything.
const _proForTesting = bool.fromEnvironment('ALOFT_PRO');

/// Whether this person has Aloft Pro. One switch, so every Pro feature asks the same place.
/// The store sets it: at launch, after a purchase or a restore, and when a subscription ends.
final proProvider = NotifierProvider<ProController, bool>(ProController.new);

class ProController extends Notifier<bool> {
  /// This install used the store reviewers' access code.
  bool _reviewAccess = false;

  @override
  bool build() {
    final store = ref.watch(proStoreProvider);
    final review = ref.watch(reviewAccessProvider);
    // After this build returns, so the store's first answer has a state to change.
    Future.microtask(() async {
      _reviewAccess = await review.granted();
      if (_reviewAccess) state = true;
      await store.start((pro) => state = pro || _proForTesting || _reviewAccess);
    });
    return _proForTesting;
  }

  /// Switches Pro on if [code] is the access code this build accepts. Returns whether it was.
  Future<bool> redeemAccessCode(String code) async {
    final ok = await ref.read(reviewAccessProvider).redeem(code);
    if (ok) {
      _reviewAccess = true;
      state = true;
    }
    return ok;
  }

  void set(bool pro) => state = pro;
}

/// The plans the store has on offer. Fetched again each time the Pro screen opens.
final proPlansProvider = FutureProvider.autoDispose<List<ProPlan>>((ref) => ref.watch(proStoreProvider).plans());

/// What Pro adds, in the order the Pro screen lists it (SPEC section 8).
const proFeatures = [
  (Icons.medication_outlined, 'More than one medication', 'Track two or more at the same time'),
  (Icons.picture_as_pdf_outlined, 'Report for your provider', 'A PDF of your doses, weight and side effects'),
  (Icons.table_chart_outlined, 'Spreadsheet export', 'Your history as CSV files'),
];

/// The planned prices, shown for information in a build that has no store to buy from.
const plannedPlans = [
  ProPlan(kind: ProPlanKind.yearly, price: r'$14.99'),
  ProPlan(kind: ProPlanKind.lifetime, price: r'$29.99'),
  ProPlan(kind: ProPlanKind.monthly, price: r'$1.99'),
];

/// True when the person has Pro. Otherwise shows the Pro screen, and returns whether they
/// have it once that screen closes.
///
/// [reason] says what the person was doing when Pro came up, such as "Track NAD+ alongside
/// Zepbound with Pro."; it is shown at the top of the Pro screen.
Future<bool> requirePro(BuildContext context, WidgetRef ref, {String? reason}) async {
  if (ref.read(proProvider)) return true;
  await Navigator.of(context)
      .push(MaterialPageRoute<void>(fullscreenDialog: true, builder: (_) => ProScreen(reason: reason)));
  return ref.read(proProvider);
}

/// What Aloft Pro is, and where it is bought, restored and managed.
class ProScreen extends ConsumerStatefulWidget {
  const ProScreen({super.key, this.reason});

  /// What brought the person here, when it wasn't the Pro row in More.
  final String? reason;

  @override
  ConsumerState<ProScreen> createState() => _ProScreenState();
}

class _ProScreenState extends ConsumerState<ProScreen> {
  ProPlanKind _chosen = ProPlanKind.yearly;
  bool _busy = false;
  String? _message;

  Future<void> _buy(ProPlan plan) async {
    setState(() {
      _busy = true;
      _message = null;
    });
    final outcome = await ref.read(proStoreProvider).buy(plan);
    if (!mounted) return;
    if (outcome == PurchaseOutcome.bought) ref.read(proProvider.notifier).set(true);
    setState(() {
      _busy = false;
      _message = switch (outcome) {
        PurchaseOutcome.bought => null,
        PurchaseOutcome.cancelled => null,
        PurchaseOutcome.failed =>
          "The purchase didn't go through, and you haven't been charged. Try again in a moment.",
      };
    });
  }

  Future<void> _restore() async {
    setState(() {
      _busy = true;
      _message = null;
    });
    final found = await ref.read(proStoreProvider).restore();
    if (!mounted) return;
    if (found) ref.read(proProvider.notifier).set(true);
    setState(() {
      _busy = false;
      _message = found ? null : 'No earlier Aloft Pro purchase was found on this store account.';
    });
  }

  Future<void> _accessCode() async {
    final controller = TextEditingController();
    final code = await showDialog<String>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: const Text('Access code'),
        content: TextField(
          key: const Key('access-code-field'),
          controller: controller,
          autofocus: true,
          autocorrect: false,
          enableSuggestions: false,
          decoration: const InputDecoration(hintText: 'Enter your code'),
          onSubmitted: (value) => Navigator.pop(dialog, value),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialog), child: const Text('Cancel')),
          TextButton(
            key: const Key('access-code-use'),
            onPressed: () => Navigator.pop(dialog, controller.text),
            child: const Text('Use code'),
          ),
        ],
      ),
    );
    if (code == null || !mounted) return;
    final ok = await ref.read(proProvider.notifier).redeemAccessCode(code);
    if (!mounted) return;
    setState(() => _message = ok ? null : "That code isn't right. Check it and try again.");
  }

  Future<void> _manage() async {
    final url = await ref.read(proStoreProvider).manageUrl();
    if (!mounted) return;
    if (url == null || !await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        setState(() => _message = 'Subscriptions are managed in your $deviceWord\'s store app, under your account.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final pro = ref.watch(proProvider);
    final store = ref.watch(proStoreProvider);
    final plans = store.available ? ref.watch(proPlansProvider) : const AsyncData(<ProPlan>[]);
    final muted = TextStyle(fontSize: 13, height: 1.45, color: scheme.onSurfaceVariant);

    return Scaffold(
      appBar: AppBar(
        leading: TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        leadingWidth: 88,
        title: const Text(
          'Aloft Pro',
          style: TextStyle(fontFamily: displayFont, fontSize: 20, fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),
      // Not a lazy list: the buy button and the terms must exist even before they scroll into view.
      bottomNavigationBar: const SystemBarSpacer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.reason != null && !pro) ...[
              InfoBox(widget.reason!, key: const Key('pro-reason')),
              const SizedBox(height: 12),
            ],
            Text(
              'Tracking, photos, reminders and backup stay free. Pro adds the extras.',
              style: TextStyle(fontSize: 16, height: 1.45, color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            for (final (icon, title, detail) in proFeatures)
              ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                visualDensity: VisualDensity.compact,
                leading: Icon(icon, color: scheme.secondary),
                title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                subtitle: Text(detail, style: const TextStyle(fontSize: 13)),
              ),
            const SizedBox(height: 16),
            if (pro) ...[
              const InfoBox('You have Aloft Pro.', key: Key('pro-active')),
              if (store.available) ...[
                const SizedBox(height: 12),
                OutlinedButton(
                  key: const Key('pro-manage'),
                  onPressed: _manage,
                  child: const Text('Manage subscription'),
                ),
              ],
            ] else if (!store.available) ...[
              for (final plan in plannedPlans) _planCard(plan, selectable: false),
              const SizedBox(height: 12),
              const InfoBox('Buying Pro isn\'t available in this version of Aloft yet. Nothing here can charge you.'),
            ] else
              ...plans.when(
                loading: () => const [
                  Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ],
                error: (_, _) => [_unreachable()],
                data: (found) {
                  if (found.isEmpty) return [_unreachable()];
                  final chosen = found.firstWhere((p) => p.kind == _chosen, orElse: () => found.first);
                  return [
                    for (final plan in found) _planCard(plan, selectable: true, selected: plan.kind == chosen.kind),
                    const SizedBox(height: 12),
                    FilledButton(
                      key: const Key('pro-buy'),
                      onPressed: _busy ? null : () => _buy(chosen),
                      child: Text(_busy ? 'Working…' : chosen.buyLabel),
                    ),
                    const SizedBox(height: 8),
                    Text(chosen.terms, key: const Key('pro-terms'), style: muted),
                  ];
                },
              ),
            if (_message != null) ...[const SizedBox(height: 12), InfoBox(_message!, key: const Key('pro-message'))],
            if (store.available && !pro) ...[
              const SizedBox(height: 12),
              OutlinedButton(
                key: const Key('pro-restore'),
                onPressed: _busy ? null : _restore,
                child: const Text('Restore purchases'),
              ),
            ],
            // Only in a build that accepts a code, and only until Pro is on.
            if (ref.watch(reviewAccessProvider).offered && !pro)
              TextButton(
                key: const Key('access-code-link'),
                onPressed: _busy ? null : _accessCode,
                child: const Text('Have an access code?'),
              ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LinkButton(key: const Key('pro-terms-link'), label: 'Terms of use', url: termsUrl),
                LinkButton(key: const Key('pro-privacy-link'), label: 'Privacy policy', url: privacyPolicyUrl),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _unreachable() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const InfoBox('The store can\'t be reached right now, so the plans can\'t be shown. Check your connection.'),
      const SizedBox(height: 8),
      OutlinedButton(onPressed: () => ref.invalidate(proPlansProvider), child: const Text('Try again')),
    ],
  );

  Widget _planCard(ProPlan plan, {required bool selectable, bool selected = false}) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: selected ? scheme.secondary : scheme.outlineVariant, width: selected ? 2 : 1),
      ),
      child: ListTile(
        key: Key('plan-${plan.kind.name}'),
        onTap: selectable && !_busy ? () => setState(() => _chosen = plan.kind) : null,
        leading: selectable
            ? Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off, color: scheme.secondary)
            : null,
        title: Text(plan.name, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(switch (plan.kind) {
          ProPlanKind.yearly when plan.trial != null => 'Best value · ${plan.trial!.length} free',
          ProPlanKind.yearly => 'Best value',
          ProPlanKind.monthly when plan.trial != null => '${plan.trial!.length} free, then cancel any time',
          ProPlanKind.lifetime => 'Pay once, yours for good',
          ProPlanKind.monthly => 'Cancel any time',
        }),
        trailing: Text(plan.priceLine, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
      ),
    );
  }
}
