import 'package:flutter/material.dart';

/// Colors from the app icon and mockups (brand/README.md).
abstract final class AloftColors {
  static const navy = Color(0xFF1D3557);
  static const navyDeep = Color(0xFF12263A);
  static const teal = Color(0xFF237A85);
  static const tealBrand = Color(0xFF3E8E8A);
  static const tealSoft = Color(0xFFE4F1F2);
  static const tealLight = Color(0xFF8FD3D9);
  static const mist = Color(0xFFCDE5E8);
  static const peach = Color(0xFFE8956B);
  static const slate = Color(0xFF5B6878);
  static const line = Color(0xFFE3E8EF);
  static const page = Color(0xFFF6F8FB);
}

ThemeData aloftTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final scheme = dark
      ? const ColorScheme.dark(
          primary: AloftColors.tealLight,
          onPrimary: AloftColors.navyDeep,
          secondary: AloftColors.peach,
          onSecondary: AloftColors.navyDeep,
          surface: Color(0xFF16283F),
          onSurface: Color(0xFFF1F5F9),
          onSurfaceVariant: Color(0xFFA9BDD3),
          outline: Color(0xFF6F84A0),
          outlineVariant: Color(0xFF2A3F5C),
          error: Color(0xFFFFB4AB),
        )
      : const ColorScheme.light(
          primary: AloftColors.navy,
          onPrimary: Colors.white,
          secondary: AloftColors.teal,
          onSecondary: Colors.white,
          surface: Colors.white,
          onSurface: AloftColors.navyDeep,
          onSurfaceVariant: AloftColors.slate,
          outline: Color(0xFF8C9BAB),
          outlineVariant: AloftColors.line,
          error: Color(0xFFB3261E),
        );
  final page = dark ? const Color(0xFF0E1B2C) : AloftColors.page;
  final base = ThemeData(brightness: brightness, colorScheme: scheme, useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: page,
    appBarTheme: AppBarTheme(
      backgroundColor: page,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: scheme.onSurface),
    ),
    cardTheme: CardThemeData(
      color: scheme.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.outlineVariant),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: scheme.surface,
      indicatorColor: dark ? const Color(0xFF24406A) : AloftColors.tealSoft,
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? (dark ? Colors.white : AloftColors.teal)
              : scheme.onSurfaceVariant,
        ),
      ),
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: scheme.onSurfaceVariant),
      ),
    ),
    switchTheme: SwitchThemeData(
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? (dark ? AloftColors.tealBrand : AloftColors.teal) : null,
      ),
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? Colors.white : null,
      ),
    ),
    dividerTheme: DividerThemeData(color: scheme.outlineVariant, space: 1, thickness: 1),
  );
}
