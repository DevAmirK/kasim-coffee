import 'package:flutter/material.dart';

class AppTheme {
  static const primary = Color(0xFFF9E532);
  static const accentSoft = Color(0xFFFFF4A8);
  static const graphite = Color(0xFF222222);
  static const secondaryText = Color(0xFF444444);
  static const background = Color(0xFFF5F5F2);
  static const border = Color(0xFFE6E6E2);

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
      surface: background,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme.copyWith(
        primary: primary,
        onPrimary: graphite,
        secondary: graphite,
        onSecondary: Colors.white,
        surface: Colors.white,
        onSurface: graphite,
        outline: border,
      ),
      scaffoldBackgroundColor: background,
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: secondaryText),
        bodyMedium: TextStyle(color: secondaryText),
        titleLarge: TextStyle(color: graphite),
        titleMedium: TextStyle(color: graphite),
        headlineSmall: TextStyle(color: graphite),
        headlineMedium: TextStyle(color: graphite),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: graphite),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(foregroundColor: graphite),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        shadowColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }
}
