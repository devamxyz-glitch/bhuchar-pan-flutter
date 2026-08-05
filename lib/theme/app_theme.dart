import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFF080808);

  static const Color surface = Color(0xFF151515);

  static const Color card = Color(0xFF1E1E1E);

  static const Color gold = Color(0xFFFFC107);

  static const Color goldDark = Color(0xFFFFA000);

  static const Color white = Colors.white;

  static const Color grey = Color(0xFFBDBDBD);

  static const Color border = Color(0x33FFFFFF);

  static const Color success = Color(0xFF4CAF50);

  static const Color error = Color(0xFFE53935);
}

class AppTheme {
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,

    brightness: Brightness.dark,

    scaffoldBackgroundColor: AppColors.background,

    primaryColor: AppColors.gold,

    colorScheme: const ColorScheme.dark(
      primary: AppColors.gold,
      secondary: AppColors.goldDark,
      surface: AppColors.surface,
    ),

    cardColor: AppColors.card,

    inputDecorationTheme: InputDecorationTheme(
      filled: true,

      fillColor: const Color(0x22FFFFFF),

      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 18,
      ),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: AppColors.border,
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: AppColors.gold,
          width: 1.5,
        ),
      ),

      labelStyle: const TextStyle(
        color: Colors.white70,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 56),

        backgroundColor: AppColors.gold,

        foregroundColor: Colors.black,

        elevation: 0,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),

        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 56),

        side: const BorderSide(
          color: AppColors.gold,
        ),

        foregroundColor: AppColors.gold,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    ),

    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,

      backgroundColor: Colors.grey.shade900,

      contentTextStyle: const TextStyle(
        color: Colors.white,
      ),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
    ),
  );
}