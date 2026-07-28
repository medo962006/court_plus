import 'package:flutter/material.dart';

/// Global design tokens for court+
class AppColors {
  // Accent
  static const Color neonGreen = Color(0xFFC4FF00);
  static const Color neonGreenAlt = Color(0xFFA3FF12);

  // Dark theme
  static const Color darkBg = Color(0xFF0D1117);
  static const Color darkSurface = Color(0xFF101418);
  static const Color darkField = Color(0xFF1C232B);
  static const Color darkBorder = Color(0xFF2A313A);
  static const Color darkText = Color(0xFF14181D);

  // Light theme
  static const Color lightBg = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF8F9FA);
  static const Color lightText = Color(0xFF1A1D20);
  static const Color lightMuted = Color(0xFF8A9099);
  static const Color lightField = Color(0xFFF1F3F5);

  static const Color error = Color(0xFFFF4D4F);
  static const Color white60 = Colors.white60;
  static const Color darkSlate = Color(0xFF101820);
  static const Color lightBorder = Color(0xFFEAECEE);
}

class AppTheme {
  static const String fontFamily = 'Inter';

  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.darkBg,
        fontFamily: fontFamily,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.neonGreen,
          secondary: AppColors.neonGreen,
          surface: AppColors.darkSurface,
          error: AppColors.error,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.neonGreen,
            foregroundColor: AppColors.darkText,
            minimumSize: const Size.fromHeight(54),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: fontFamily,
            ),
          ),
        ),
      );

  static ThemeData get light => ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.lightBg,
        fontFamily: fontFamily,
        colorScheme: const ColorScheme.light(
          primary: AppColors.neonGreen,
          secondary: AppColors.neonGreen,
          surface: AppColors.lightSurface,
          error: AppColors.error,
        ),
      );
}