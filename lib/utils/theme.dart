import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF6C63FF);
  static const background = Color(0xFF1A1A2E);
  static const surface = Color(0xFF2A2A4A);
  static const error = Color(0xFFFF6B6B);
  static const cardBackground = Color(0xFF16213E);
}

class AppTheme {
  static final ThemeData darkTheme = ThemeData(
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,
    brightness: Brightness.dark,
    fontFamily: 'Poppins',
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.primary,
      surface: AppColors.surface,
      background: AppColors.background,
      error: AppColors.error,
    ),
    cardTheme: CardTheme(
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 8,
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    ),
  );
}

class AppTextStyles {
  static const headerLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );

  static const headerMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static const bodyLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static const bodyMedium = TextStyle(
    fontSize: 16,
    color: Colors.white,
  );

  static TextStyle bodySmall = TextStyle(
    fontSize: 14,
    color: Colors.white.withOpacity(0.7),
  );
}
