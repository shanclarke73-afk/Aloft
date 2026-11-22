import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../security/app_lock.dart';

/// Aloft's pages on peaceofmindapps.com. Both stores require the privacy policy and, beside a
/// subscription, the terms.
final privacyPolicyUrl = Uri.parse('https://peaceofmindapps.com/aloft/privacy');
final termsUrl = Uri.parse('https://peaceofmindapps.com/aloft/terms');
final supportUrl = Uri.parse('https://peaceofmindapps.com/aloft/');

/// Opens a web page in the phone's browser. Replaced in tests.
final linkOpenerProvider = Provider<Future<bool> Function(Uri url)>((ref) {
  final lock = ref.watch(appLockProvider);
  return (url) {
    // The browser covers Aloft; coming back from reading a page shouldn't ask for the lock.
    lock.expectLeaving();
    return launchUrl(url, mode: LaunchMode.externalApplication);
  };
});

/// Opens [url], and says so if the phone has nothing to open it with.
Future<void> openLink(BuildContext context, WidgetRef ref, Uri url) async {
  final messenger = ScaffoldMessenger.of(context);
  var opened = false;
  try {
    opened = await ref.read(linkOpenerProvider)(url);
  } catch (_) {}
  if (!opened) messenger.showSnackBar(SnackBar(content: Text('Couldn\'t open $url')));
}

/// A link that looks like one: underlined, in the app's link colour.
class LinkButton extends ConsumerWidget {
  const LinkButton({super.key, required this.label, required this.url});
  final String label;
  final Uri url;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = Theme.of(context).colorScheme.secondary;
    return TextButton(
      onPressed: () => openLink(context, ref, url),
      child: Text(
        label,
        style: TextStyle(color: color, decoration: TextDecoration.underline, decorationColor: color),
      ),
    );
  }
}
