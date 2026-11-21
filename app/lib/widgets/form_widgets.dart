import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../dose/dose_math.dart';
import '../theme/aloft_theme.dart';

/// Small label above a field.
class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 6),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// A field for typing an amount. Any amount can be typed: doses are never limited to presets.
class NumberField extends StatelessWidget {
  const NumberField({
    super.key,
    required this.controller,
    this.suffix,
    this.hint,
    this.onChanged,
    this.wholeNumber = false,
    this.large = false,
  });
  final TextEditingController controller;
  final String? suffix;
  final String? hint;
  final ValueChanged<String>? onChanged;
  final bool wholeNumber;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: !wholeNumber),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(wholeNumber ? r'[0-9]' : r'[0-9.,]'))],
      style: large ? const TextStyle(fontSize: 28, fontWeight: FontWeight.w800) : null,
      decoration: InputDecoration(hintText: hint, suffixText: suffix),
      // The number keypad has no Done key, so tapping anywhere else closes it.
      onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
      onChanged: onChanged,
    );
  }
}

/// Looks like a field; tapping opens a picker.
class PickerField extends StatelessWidget {
  const PickerField({super.key, required this.text, required this.onTap});
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: const InputDecoration(suffixIcon: Icon(Icons.expand_more)),
        child: Text(text, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}

/// How many tablets, in halves.
class TabletStepper extends StatelessWidget {
  const TabletStepper({super.key, required this.value, required this.onChanged});
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton.filledTonal(
          tooltip: 'Half a tablet less',
          onPressed: value > 0.5 ? () => onChanged(value - 0.5) : null,
          icon: const Icon(Icons.remove),
        ),
        Expanded(
          child: Text(
            describeAmount(value, DoseUnit.tablets),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
        ),
        IconButton.filledTonal(
          tooltip: 'Half a tablet more',
          onPressed: value < 20 ? () => onChanged(value + 0.5) : null,
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}

/// Soft teal box for a summary or a reassurance.
class InfoBox extends StatelessWidget {
  const InfoBox(this.text, {super.key, this.warning = false});
  final String text;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final background = warning
        ? (dark ? const Color(0xFF4A3324) : const Color(0xFFFDEEE6))
        : (dark ? const Color(0xFF1B3A44) : AloftColors.tealSoft);
    final foreground = warning
        ? (dark ? const Color(0xFFFFD9C7) : const Color(0xFF8A3D17))
        : (dark ? AloftColors.mist : const Color(0xFF1B5F67));
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(14)),
      child: Text(
        text,
        style: TextStyle(fontSize: 14, height: 1.4, fontWeight: FontWeight.w600, color: foreground),
      ),
    );
  }
}
