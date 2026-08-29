import 'package:flutter/material.dart';

class AppTheme {
  static const Color ink = Color(0xFF1F2430);
  static const Color primaryGreen = Color(0xFF52B447);
  static const Color primaryPurple = Color(0xFF6E3EB5);
  static const Color deepPurple = Color(0xFF4D2A86);
  static const Color softGreen = Color(0xFFEAF7E8);
  static const Color softPurple = Color(0xFFF1EBFB);
  static const Color canvas = Color(0xFFF7FAF5);
  static const Color mutedText = Color(0xFF74808F);
  static const Color border = Color(0xFFDCE6D8);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryPurple, primaryGreen],
  );

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFD8C6F4), primaryPurple, deepPurple],
    stops: [0.0, 0.5, 1.0],
  );

  static ThemeData light() {
    const colorScheme = ColorScheme.light(
      primary: primaryGreen,
      onPrimary: Colors.white,
      secondary: primaryPurple,
      onSecondary: Colors.white,
      tertiary: deepPurple,
      surface: Colors.white,
      onSurface: ink,
      error: Color(0xFFD64545),
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: canvas,
      appBarTheme: const AppBarTheme(
        backgroundColor: canvas,
        foregroundColor: ink,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hintStyle: const TextStyle(color: mutedText),
        prefixIconColor: mutedText,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: primaryGreen, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: ink,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
