import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static const radiusXl = 30.0;
  static const radiusLg = 24.0;
  static const radiusMd = 18.0;

  static ThemeData lightTheme = _buildTheme(Brightness.light);
  static ThemeData darkTheme = _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.black,
      brightness: brightness,
      surface: isDark ? const Color(0xFF191A1F) : AppColors.surface,
      primary: AppColors.black,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme.copyWith(
        primary: isDark ? Colors.white : AppColors.black,
        onPrimary: isDark ? AppColors.black : Colors.white,
        surface: isDark ? const Color(0xFF191A1F) : AppColors.surface,
        onSurface: isDark ? Colors.white : AppColors.textPrimary,
        surfaceContainerHighest:
            isDark ? const Color(0xFF24262C) : AppColors.surfaceMuted,
      ),
      scaffoldBackgroundColor:
          isDark ? const Color(0xFF111214) : AppColors.background,
      dividerColor: Colors.transparent,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      textTheme: TextTheme(
        displayLarge: TextStyle(
          color: isDark ? Colors.white : AppColors.textPrimary,
          fontSize: 50,
          fontWeight: FontWeight.w700,
          letterSpacing: -2.6,
        ),
        displayMedium: TextStyle(
          color: isDark ? Colors.white : AppColors.textPrimary,
          fontSize: 42,
          fontWeight: FontWeight.w700,
          letterSpacing: -2,
        ),
        displaySmall: TextStyle(
          color: isDark ? Colors.white : AppColors.textPrimary,
          fontSize: 34,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.5,
        ),
        headlineSmall: TextStyle(
          color: isDark ? Colors.white : AppColors.textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -1,
        ),
        titleLarge: TextStyle(
          color: isDark ? Colors.white : AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        titleMedium: TextStyle(
          color: isDark ? Colors.white : AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.4,
        ),
        bodyLarge: TextStyle(
          color: isDark ? Colors.white : AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        bodyMedium: TextStyle(
          color: isDark ? Colors.white70 : AppColors.textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor:
            isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.surfaceMuted,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? const Color(0xFF24262C) : AppColors.black,
        contentTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      cupertinoOverrideTheme: CupertinoThemeData(
        brightness: brightness,
        primaryColor: isDark ? Colors.white : AppColors.black,
        scaffoldBackgroundColor:
            isDark ? const Color(0xFF111214) : AppColors.background,
        barBackgroundColor:
            isDark ? const Color(0xE91A1B20) : const Color(0xF9FFFFFF),
        textTheme: CupertinoTextThemeData(
          textStyle: TextStyle(
            color: isDark ? Colors.white : AppColors.textPrimary,
            fontSize: 16,
            letterSpacing: -0.2,
          ),
          navLargeTitleTextStyle: TextStyle(
            color: isDark ? Colors.white : AppColors.textPrimary,
            fontSize: 34,
            fontWeight: FontWeight.w700,
            letterSpacing: -1.2,
          ),
          navTitleTextStyle: TextStyle(
            color: isDark ? Colors.white : AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
