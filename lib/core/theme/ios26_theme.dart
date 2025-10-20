import 'package:flutter/material.dart';
import 'app_colors.dart';

class Ios26Theme {
  // Light Theme with Liquid Glass aesthetic
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: AppColors.accentBlue,
    scaffoldBackgroundColor: AppColors.glassBackgroundLight,
    
    colorScheme: const ColorScheme.light(
      primary: AppColors.accentBlue,
      secondary: AppColors.accentPurple,
      surface: AppColors.glassSurfaceLight,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.textPrimaryLight,
      onError: Colors.white,
    ),
    
    // Use Cupertino-style app bar
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.textPrimaryLight,
      elevation: 0,
      centerTitle: true,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
        color: AppColors.textPrimaryLight,
        fontSize: 17,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.41,
      ),
    ),
    
    // Liquid Glass Card Style
    cardTheme: CardThemeData(
      color: AppColors.glassSurfaceLight.withValues(alpha: 0.7),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: AppColors.glassBorderLight,
          width: 0.5,
        ),
      ),
    ),
    
    // iOS-style elevated button
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accentBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.41,
        ),
      ),
    ),
    
    // iOS-style text button
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.accentBlue,
        textStyle: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.41,
        ),
      ),
    ),
    
    // iOS-style input decoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.glassSurfaceLight.withValues(alpha: 0.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: AppColors.glassBorderLight,
          width: 0.5,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: AppColors.glassBorderLight,
          width: 0.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: AppColors.accentBlue,
          width: 2,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    
    // San Francisco font-inspired text theme
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimaryLight,
        letterSpacing: -0.5,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimaryLight,
        letterSpacing: -0.5,
      ),
      displaySmall: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimaryLight,
        letterSpacing: -0.41,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryLight,
        letterSpacing: -0.41,
      ),
      titleLarge: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryLight,
        letterSpacing: -0.41,
      ),
      bodyLarge: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimaryLight,
        letterSpacing: -0.41,
      ),
      bodyMedium: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondaryLight,
        letterSpacing: -0.24,
      ),
      bodySmall: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.textTertiaryLight,
        letterSpacing: -0.08,
      ),
    ),
  );
  
  // Dark Theme with Liquid Glass aesthetic
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: AppColors.accentBlue,
    scaffoldBackgroundColor: AppColors.glassBackgroundDark,
    
    colorScheme: const ColorScheme.dark(
      primary: AppColors.accentBlue,
      secondary: AppColors.accentPurple,
      surface: AppColors.glassSurfaceDark,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.textPrimaryDark,
      onError: Colors.white,
    ),
    
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.textPrimaryDark,
      elevation: 0,
      centerTitle: true,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
        color: AppColors.textPrimaryDark,
        fontSize: 17,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.41,
      ),
    ),
    
    cardTheme: CardThemeData(
      color: AppColors.glassSurfaceDark.withValues(alpha: 0.5),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: AppColors.glassBorderDark,
          width: 0.5,
        ),
      ),
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accentBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.41,
        ),
      ),
    ),
    
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.accentBlue,
        textStyle: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.41,
        ),
      ),
    ),
    
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.glassSurfaceDark.withValues(alpha: 0.3),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: AppColors.glassBorderDark,
          width: 0.5,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: AppColors.glassBorderDark,
          width: 0.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: AppColors.accentBlue,
          width: 2,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimaryDark,
        letterSpacing: -0.5,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimaryDark,
        letterSpacing: -0.5,
      ),
      displaySmall: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimaryDark,
        letterSpacing: -0.41,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryDark,
        letterSpacing: -0.41,
      ),
      titleLarge: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryDark,
        letterSpacing: -0.41,
      ),
      bodyLarge: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimaryDark,
        letterSpacing: -0.41,
      ),
      bodyMedium: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondaryDark,
        letterSpacing: -0.24,
      ),
      bodySmall: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.textTertiaryDark,
        letterSpacing: -0.08,
      ),
    ),
  );
}