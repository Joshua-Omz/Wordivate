import 'package:flutter/material.dart';
import 'package:wordivate/core/constants/app_colors.dart';

class AppTheme {
  // Theme identifiers
  static const String light = 'light';
  static const String dark = 'dark';
  static const String system = 'system';
  static const String amoled = 'amoled';
  static const String blue = 'blue';
  static const String green = 'green';
  static const String red = 'red';
  static const String purple = 'purple';
  static const String orange = 'orange';

  // Get light theme
  static ThemeData getLightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      primarySwatch: AppColors.primarySwatch,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color.fromARGB(255, 239, 239, 239),
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
      ),
      textTheme: TextTheme(
  displayLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 28),
  displayMedium: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 24),
  displaySmall: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 20),
  headlineMedium: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
  titleLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
  bodyLarge: TextStyle(color: AppColors.textPrimary, fontSize: 16),
  bodyMedium: TextStyle(color: AppColors.textSecondary, fontSize: 14),
  bodySmall: TextStyle(color: AppColors.textSecondary, fontSize: 12),
  labelLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500, fontSize: 14),
),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        fillColor: AppColors.surface,
        filled: true,
      ),
      iconTheme: IconThemeData(
        color: AppColors.textPrimary,

      )
    );
  }

  // Get dark theme
  static ThemeData getDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primarySwatch: AppColors.primarySwatch,
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      textTheme: TextTheme(
  displayLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 28),
  displayMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
  displaySmall: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
  headlineMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
  titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
  bodyLarge: TextStyle(color: Colors.white, fontSize: 16),
  bodyMedium: TextStyle(color: Colors.white70, fontSize: 14),
  bodySmall: TextStyle(color: Colors.white60, fontSize: 12),
  labelLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14),
),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        ),
      ),
    
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3E3E3E)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        fillColor: const Color(0xFF2C2C2C),
        filled: true,
      ),
      iconTheme: IconThemeData(
        color: Colors.white70,
      ),  
    );
  }

  // Get theme by name
  static ThemeData getThemeByName(String themeName) {
    switch (themeName) {
      case dark:
        return getDarkTheme();
      case amoled:
        return _getAmoledTheme();
      case blue:
        return _getBlueTheme();
      case green:
        return _getGreenTheme();
      case red:
        return _getRedTheme();
      case purple:
        return _getPurpleTheme();
      case orange:
        return _getOrangeTheme();
      case light:
      default:
        return getLightTheme();
    }
  }

  // Private theme methods for additional themes
  static ThemeData _getAmoledTheme() {
    // True black for AMOLED displays
    final darkTheme = getDarkTheme();
    return darkTheme.copyWith(
      scaffoldBackgroundColor: Colors.black,
      cardTheme: darkTheme.cardTheme.copyWith(
        color: const Color(0xFF121212),
      ),
      primaryIconTheme: const IconThemeData(
  color: AppColors.primary,),
    );
  }

  static ThemeData _getBlueTheme() {
    final baseTheme = getLightTheme();
    const primaryColor = Color(0xFF1976D2);
    return baseTheme.copyWith(
      primaryColor: primaryColor,
      colorScheme: baseTheme.colorScheme.copyWith(primary: primaryColor),
      primaryIconTheme: const IconThemeData(
  color: AppColors.primary,)
    );
  }

  static ThemeData _getGreenTheme() {
    final baseTheme = getLightTheme();
    const primaryColor = Color(0xFF2E7D32);
    return baseTheme.copyWith(
      primaryColor: primaryColor,
      colorScheme: baseTheme.colorScheme.copyWith(primary: primaryColor),
      primaryIconTheme: const IconThemeData(
  color: AppColors.primary,
),
    );
  }

  static ThemeData _getRedTheme() {
    final baseTheme = getLightTheme();
    const primaryColor = Color(0xFFC62828);
    return baseTheme.copyWith(
      primaryColor: primaryColor,
      colorScheme: baseTheme.colorScheme.copyWith(primary: primaryColor),
      primaryIconTheme: const IconThemeData(
  color: AppColors.primary,
),
    );
  }

  static ThemeData _getPurpleTheme() {
    final baseTheme = getLightTheme();
    const primaryColor = Color(0xFF7B1FA2);
    return baseTheme.copyWith(
      primaryColor: primaryColor,
      colorScheme: baseTheme.colorScheme.copyWith(primary: primaryColor),
      primaryIconTheme: const IconThemeData(
  color: AppColors.primary,
),
    );
  }

  static ThemeData _getOrangeTheme() {
    final baseTheme = getLightTheme();
    const primaryColor = Color(0xFFEF6C00);
    return baseTheme.copyWith(
      primaryColor: primaryColor,
      colorScheme: baseTheme.colorScheme.copyWith(primary: primaryColor),
      primaryIconTheme: const IconThemeData(
  color: AppColors.primary,
),
    );
  }
}