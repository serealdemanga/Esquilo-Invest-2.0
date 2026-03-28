import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppPalette {
  static const Color background = Color(0xFF061019);
  static const Color panel = Color(0xFF10202C);
  static const Color panelAlt = Color(0xFF132938);
  static const Color border = Color(0xFF284557);
  static const Color textPrimary = Color(0xFFF3F7FB);
  static const Color textMuted = Color(0xFF9BAEBE);
  static const Color amber = Color(0xFFFFB347);
  static const Color cyan = Color(0xFF68D8FF);
  static const Color green = Color(0xFF6DE6B3);
  static const Color red = Color(0xFFFF8F8F);
}

class AppTheme {
  static ThemeData get themeData {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppPalette.amber,
        secondary: AppPalette.cyan,
        surface: AppPalette.panel,
        error: AppPalette.red,
      ),
    );

    final textTheme = GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: AppPalette.textPrimary,
      displayColor: AppPalette.textPrimary,
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppPalette.background,
      cardColor: AppPalette.panel,
      textTheme: textTheme,
      dividerColor: AppPalette.border,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF08131D),
        indicatorColor: AppPalette.amber.withValues(alpha: 0.14),
        labelTextStyle: WidgetStatePropertyAll(
          GoogleFonts.rajdhani(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        side: const BorderSide(color: AppPalette.border),
        backgroundColor: AppPalette.panelAlt,
      ),
    );
  }

  static TextStyle hudStyle({
    double size = 16,
    FontWeight weight = FontWeight.w700,
    Color color = AppPalette.textPrimary,
  }) {
    return GoogleFonts.orbitron(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: -0.3,
    );
  }

  static TextStyle tacticalLabel({
    double size = 12,
    FontWeight weight = FontWeight.w700,
    Color color = AppPalette.textMuted,
  }) {
    return GoogleFonts.rajdhani(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: 1.1,
    );
  }
}
