import 'package:flutter/material.dart';

/// AppColors provides all color constants used throughout the application.
/// This centralized approach makes it easier to maintain a consistent theme.
class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF000000);       // Pure black
  static const Color primaryLight = Color(0xFF333333);  // Dark gray
  static const Color primaryDark = Color(0xFF000000);   // Pure black
  
  // Secondary/accent color for highlights
  static const Color secondary = Color(0xFF757575);     // Medium gray accent
  static const Color secondaryLight = Color(0xFFAAAAAA);
  static const Color secondaryDark = Color(0xFF424242);
  
  // Neutral colors for backgrounds, cards, etc.
  static const Color background = Colors.white;         // Clean white background
  static const Color surface = Colors.white;            // Surface color for cards
  static const Color cardBackground = Colors.white;     // Card background
  static const Color surfaceLight = Color(0xFFF5F5F5);  // Very light gray surface
  static const Color divider = Color(0xFFE0E0E0);       // Light gray dividers
  
  // Text colors
  static const Color textPrimary = Color(0xFF000000);   // Black text
  static const Color textSecondary = Color(0xFF757575); // Gray text
  static const Color textLight = Color(0xFFBDBDBD);     // Light gray text
  static const Color textOnPrimary = Colors.white;      // White text on black
  
  // Status colors (subtle but clear)
  static const Color success = Color(0xFF66BB6A);       // Muted green
  static const Color error = Color(0xFFE57373);         // Muted red
  static const Color warning = Color(0xFFFFD54F);       // Muted yellow
  static const Color info = Color(0xFF4FC3F7);          // Muted blue
  
  // Word difficulty level colors (grayscale with slight color tint)
  static const Color beginner = Color(0xFF81C784);      // Light gray-green
  static const Color intermediate = Color(0xFFFFB74D);  // Light gray-orange
  static const Color advanced = Color(0xFFE57373);      // Light gray-red
  


  static const Color white = Colors.white;
  // Category colors - monochromatic palette
  static const List<Color> categoryColors = [
    Color(0xFF212121),  // Almost black
    Color(0xFF424242),  // Dark gray
    Color(0xFF616161),  // Medium-dark gray
    Color(0xFF757575),  // Medium gray
    Color(0xFF9E9E9E),  // Medium-light gray
    Color(0xFFBDBDBD),  // Light gray
    Color(0xFFE0E0E0),  // Very light gray
    Color(0xFFF5F5F5),  // Almost white
  ];
  
  // Additional app-specific colors
  static const Color favorite = Color(0xFFE57373);      // Subtle red for favorites
  static const Color progressBackground = Color(0xFFF5F5F5); // Light gray progress bg
  
  // Returns a black-based material color swatch
  static MaterialColor primarySwatch = MaterialColor(
    primary.value,
    <int, Color>{
      50: Color(0xFFE0E0E0),
      100: Color(0xFFBDBDBD),
      200: Color(0xFF9E9E9E),
      300: Color(0xFF757575),
      400: Color(0xFF616161),
      500: Color(0xFF424242),
      600: Color(0xFF303030),
      700: Color(0xFF212121),
      800: Color(0xFF121212),
      900: Colors.black,
    },
  );
}