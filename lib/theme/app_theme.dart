import 'package:flutter/material.dart';

/// Global design tokens for court+
class AppColors {
  AppColors._();

  // Brand accent
  static const Color neonGreen = Color(0xFFC4FF00);
  static const Color neonGreenAlt = Color(0xFFA3FF12);

  // Dark theme palette
  static const Color darkBg = Color(0xFF0D1117);
  static const Color darkSurface = Color(0xFF101418);
  static const Color darkField = Color(0xFF1C232B);
  static const Color darkBorder = Color(0xFF2A313A);
  static const Color darkText = Color(0xFF14181D);

  // Light theme palette
  static const Color lightBg = Color(0xFFF5F5F7);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF1A1D20);
  static const Color lightMuted = Color(0xFF8A9099);
  static const Color lightField = Color(0xFFF1F3F5);
  static const Color lightBorder = Color(0xFFE5E7EB);

  // Feedback
  static const Color error = Color(0xFFEF4444);
  static const Color white60 = Colors.white60;
  static const Color darkSlate = Color(0xFF101820);
}

class AppTheme {
  AppTheme._();
  static const String fontFamily = 'Inter';

  static ThemeData get light => ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.lightBg,
        fontFamily: fontFamily,
        colorScheme: const ColorScheme.light(
          primary: AppColors.neonGreen,
          secondary: AppColors.neonGreenAlt,
          surface: AppColors.lightSurface,
          error: AppColors.error,
          onPrimary: AppColors.darkText,
          onSecondary: AppColors.darkText,
          onSurface: AppColors.lightText,
          onError: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.lightSurface,
          foregroundColor: AppColors.lightText,
          elevation: 0,
          scrolledUnderElevation: 0.5,
          centerTitle: true,
        ),
        cardTheme: CardThemeData(
          color: AppColors.lightSurface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.lightBorder),
          ),
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
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.lightField,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.lightBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.lightBorder),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          hintStyle: const TextStyle(color: AppColors.lightMuted, fontSize: 14),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.lightSurface,
          selectedItemColor: AppColors.lightText,
          unselectedItemColor: AppColors.lightMuted,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.lightBorder,
          thickness: 1,
          space: 1,
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.lightText),
          headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.lightText),
          titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.lightText),
          titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.lightText),
          bodyLarge: TextStyle(fontSize: 15, color: AppColors.lightText),
          bodyMedium: TextStyle(fontSize: 14, color: AppColors.lightMuted),
          labelLarge: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.lightMuted),
        ),
      );

  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.darkBg,
        fontFamily: fontFamily,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.neonGreen,
          secondary: AppColors.neonGreenAlt,
          surface: AppColors.darkSurface,
          error: AppColors.error,
          onPrimary: AppColors.darkText,
          onSecondary: AppColors.darkText,
          onSurface: Colors.white,
          onError: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.darkSurface,
          foregroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0.5,
          centerTitle: true,
        ),
        cardTheme: CardThemeData(
          color: AppColors.darkField,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.darkBorder),
          ),
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
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.darkField,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.darkBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.darkBorder),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          hintStyle: const TextStyle(color: AppColors.white60, fontSize: 14),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.darkSurface,
          selectedItemColor: AppColors.neonGreen,
          unselectedItemColor: Colors.white60,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.darkBorder,
          thickness: 1,
          space: 1,
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
          bodyLarge: TextStyle(fontSize: 15, color: Colors.white),
          bodyMedium: TextStyle(fontSize: 14, color: Colors.white70),
          labelLarge: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white70),
        ),
      );
}