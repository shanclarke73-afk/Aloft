import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../theme/aloft_theme.dart';

/// The medical disclaimer (SPEC section 9). The same words are used wherever it appears.
const medicalDisclaimer =
    'Aloft is a personal tracking tool, not a medical device. It does not provide medical advice or tell you how '
    'much to take. Always follow your prescriber.';

/// Brand names are used only to describe what someone is taking (SPEC section 9).
const trademarkNotice =
    'Ozempic®, Wegovy®, Rybelsus®, Saxenda® and Victoza® are registered trademarks of Novo Nordisk A/S. '
    'Mounjaro®, Zepbound® and Trulicity® are registered trademarks of Eli Lilly and Company. Shotsy is a '
    'trademark of its owner. Aloft is not affiliated with, endorsed by or sponsored by any of them.';

/// "1.0.0", or null while it loads or where the phone can't say.
final appVersionProvider = FutureProvider<String?>((ref) async {
  try {
    return (await PackageInfo.fromPlatform()).version;
  } catch (_) {
    return null;
  }
});

/// More → About Aloft.
class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final version = ref.watch(appVersionProvider).value;
    final body = TextStyle(fontSize: 15, height: 1.45, color: scheme.onSurface);
    Widget section(String title, String text) => Padding(
      padding: const EdgeInsets.only(top: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 6),
          Text(text, style: body),
        ],
      ),
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'About',
          style: TextStyle(fontFamily: displayFont, fontSize: 20, fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'assets/icon-rounded.png',
                    width: 68,
                    height: 68,
                    errorBuilder: (_, _, _) => const SizedBox(width: 68, height: 68),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Aloft',
                        style: TextStyle(fontFamily: displayFont, fontSize: 26, fontWeight: FontWeight.w800),
                      ),
                      Text(
                        'From titration to thriving.',
                        style: TextStyle(fontSize: 14, color: scheme.onSurfaceVariant),
                      ),
                      if (version != null)
                        Text(
                          'Version $version',
                          key: const Key('app-version'),
                          style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            section('Medical disclaimer', medicalDisclaimer),
            section(
              'Your privacy',
              'There is no Aloft account, and nothing you log is sent to us. Your records are kept in an encrypted '
                  'database on this phone, and your photos in Aloft\'s private storage, never the camera roll. '
                  'Backup files are made only when you save one, and go only where you put them.',
            ),
            section(
              'Estimated levels',
              'The level chart is a simple estimate worked out from the doses you log and the half-life and time to '
                  'peak published in each medication\'s US prescribing information. It is not a blood level and not '
                  'a guide to dosing.',
            ),
            section('Trademarks', trademarkNotice),
            const SizedBox(height: 22),
            OutlinedButton(
              key: const Key('licenses'),
              onPressed: () => showLicensePage(context: context, applicationName: 'Aloft', applicationVersion: version),
              child: const Text('Open-source licenses'),
            ),
            const SizedBox(height: 24),
            Text(
              'A Peace of Mind Apps product',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
