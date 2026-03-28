import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppPalette {
  static const Color background = Color(0xFF05070A);
  static const Color panel = Color(0xFF0F172A);
  static const Color panelAlt = Color(0xFF111C31);
  static const Color border = Color(0x1FFFFFFF);
  static const Color textPrimary = Color(0xFFE2E8F0);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color amber = Color(0xFFF59E0B);
  static const Color cyan = Color(0xFF38BDF8);
  static const Color green = Color(0xFF6EE7B7);
  static const Color red = Color(0xFFFCA5A5);
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
        backgroundColor: const Color(0xFF081018),
        indicatorColor: AppPalette.amber.withValues(alpha: 0.10),
        labelTextStyle: WidgetStatePropertyAll(
          GoogleFonts.rajdhani(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppPalette.amber,
          foregroundColor: const Color(0xFFF8FAFC),
          textStyle: GoogleFonts.rajdhani(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.9,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
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
      letterSpacing: 0.2,
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
      letterSpacing: 1.4,
    );
  }
}
