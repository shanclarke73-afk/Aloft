import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/aloft_theme.dart';
import '../widgets/form_widgets.dart';

/// Test builds only: `--dart-define=ALOFT_PRO=true` starts with Pro switched on, so the Pro
/// features can be tried before purchases are connected.
const _proForTesting = bool.fromEnvironment('ALOFT_PRO');

/// Whether this person has Aloft Pro. One switch, so every Pro feature asks the same place;
/// purchases (RevenueCat, the "pro" entitlement) will set it when they are connected.
final proProvider = NotifierProvider<ProController, bool>(ProController.new);

class ProController extends Notifier<bool> {
  @override
  bool build() => _proForTesting;

  void set(bool pro) => state = pro;
}

/// What Pro adds, in the order the Pro screen lists it (SPEC section 8).
const proFeatures = [
  (Icons.picture_as_pdf_outlined, 'Report for your provider', 'A PDF of your doses, weight and side effects'),
  (Icons.table_chart_outlined, 'Spreadsheet export', 'Your history as CSV files'),
];

/// The three ways to get Pro, as decided in the spec. Shown for information until purchases
/// are connected; the real prices will then come from the store.
const proPlans = [
  ('Yearly', r'$14.99 per year', 'Renews each year until cancelled'),
  ('Lifetime', r'$29.99 once', 'Pay once, yours for good'),
  ('Monthly', r'$1.99 per month', 'Renews each month until cancelled'),
];

/// True when the person has Pro. Otherwise shows the Pro screen and returns false.
Future<bool> requirePro(BuildContext context, WidgetRef ref) async {
  if (ref.read(proProvider)) return true;
  await Navigator.of(context).push(MaterialPageRoute<void>(fullscreenDialog: true, builder: (_) => const ProScreen()));
  return false;
}

/// What Aloft Pro is. Purchases aren't connected yet, so this explains rather than sells:
/// nothing on it takes money or pretends to.
class ProScreen extends ConsumerWidget {
  const ProScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final pro = ref.watch(proProvider);
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
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        children: [
          Text(
            'Tracking, photos, reminders and backup stay free. Pro adds the extras.',
            style: TextStyle(fontSize: 16, height: 1.45, color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          for (final (icon, title, detail) in proFeatures)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(icon, color: scheme.secondary),
              title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text(detail),
            ),
          const SizedBox(height: 16),
          if (pro)
            const InfoBox('You have Aloft Pro.')
          else ...[
            for (final (name, price, detail) in proPlans)
              Card(
                child: ListTile(
                  title: Text(name, style: const TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: Text(detail),
                  trailing: Text(price, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              ),
            const SizedBox(height: 12),
            const InfoBox('Buying Pro isn\'t available in this version of Aloft yet. Nothing here can charge you.'),
          ],
        ],
      ),
    );
  }
}
