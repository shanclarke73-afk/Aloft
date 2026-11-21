import 'package:flutter/material.dart';

import '../theme/aloft_theme.dart';
import 'app_lock.dart';

/// Shown instead of the app while it's locked (mockups/LockScreen).
class LockScreen extends StatefulWidget {
  const LockScreen({super.key, required this.lock});
  final AppLock lock;

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  String? _message;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _unlock());
  }

  Future<void> _unlock() async {
    final message = await widget.lock.unlock();
    if (mounted) setState(() => _message = message);
  }

  @override
  Widget build(BuildContext context) {
    final method = widget.lock.methodName;
    return Scaffold(
      backgroundColor: AloftColors.navy,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
          child: Column(
            children: [
              const Spacer(),
              const Icon(Icons.lock_outline, size: 56, color: Colors.white),
              const SizedBox(height: 20),
              const Text(
                'Aloft is locked',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white),
              ),
              const SizedBox(height: 12),
              const Text(
                'Your health data and photos stay private.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, height: 1.45, color: AloftColors.mist),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: 260,
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AloftColors.navy),
                  onPressed: _unlock,
                  child: Text(method == 'passcode' ? 'Unlock with passcode' : 'Unlock with $method'),
                ),
              ),
              if (_message != null) ...[
                const SizedBox(height: 16),
                Text(
                  _message!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Colors.white),
                ),
              ],
              const Spacer(),
              const Text(
                'Lock settings: More → Privacy & security',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Color(0xFFA9BDD3)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Covers the app in the app switcher so shots, weights and photos aren't visible there.
class PrivacyCover extends StatelessWidget {
  const PrivacyCover({super.key});

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AloftColors.navy,
      child: Center(
        child: Text(
          'Aloft',
          textDirection: TextDirection.ltr,
          style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: Colors.white),
        ),
      ),
    );
  }
}
