import 'package:flutter/material.dart';

// Text style extensions for theme-aware text styling
extension TextStyleExtensions on BuildContext {
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  // Headings
  TextStyle get headingLarge => textTheme.displayLarge!;
  TextStyle get headingMedium => textTheme.displayMedium!;
  TextStyle get headingSmall => textTheme.displaySmall!;

  // Titles & body
  TextStyle get titleLarge => textTheme.titleLarge!;
  TextStyle get titleMedium => textTheme.titleMedium!;
  TextStyle get titleSmall => textTheme.titleSmall!;
  TextStyle get bodyLarge => textTheme.bodyLarge!;
  TextStyle get bodyMedium => textTheme.bodyMedium!;
  TextStyle get bodySmall => textTheme.bodySmall!;

  // Semantic
  TextStyle get errorText => textTheme.bodyMedium!.copyWith(color: colorScheme.error);
  TextStyle get captionText => textTheme.bodySmall!.copyWith(color: colorScheme.onSurface.withOpacity(0.6));
  TextStyle get hintText => textTheme.bodyMedium!.copyWith(color: colorScheme.onSurface.withOpacity(0.6));

  // App-specific
  TextStyle get drawerSectionTitle => textTheme.titleSmall!.copyWith(
    fontWeight: FontWeight.bold,
    color: colorScheme.onSurface.withOpacity(0.7),
  );
  TextStyle get emptyStateTitle => textTheme.headlineMedium!;
  TextStyle get emptyStateSubtitle => textTheme.bodyMedium!;

  // Add these new semantic styles
  TextStyle get dialogTitle => titleLarge.copyWith(fontWeight: FontWeight.bold);
  TextStyle get dialogContent => bodyMedium;
  TextStyle get buttonText => textTheme.labelLarge!.copyWith(fontWeight: FontWeight.bold);
  TextStyle get tabLabel => textTheme.labelLarge!;
  TextStyle get cardTitle => titleMedium.copyWith(fontWeight: FontWeight.w600);
  TextStyle get cardSubtitle => bodySmall;
  TextStyle get chipText => bodySmall.copyWith(fontWeight: FontWeight.w500);
  TextStyle get placeholderText => bodyMedium.copyWith(
    color: colorScheme.onSurface.withOpacity(0.5),
    fontStyle: FontStyle.italic,
  );
}

// Icon theme extensions for theme-aware icon styling
extension IconThemeExtensions on BuildContext {
  Color get iconColor => Theme.of(this).iconTheme.color!;
  Color get primaryIconColor => colorScheme.primary;
  Color get errorIconColor => colorScheme.error;
  Color get warningIconColor => Colors.amber;
  Color get infoIconColor => Colors.blue;
  Color get disabledIconColor => Theme.of(this).disabledColor;
  Color get subtleIconColor => iconColor.withOpacity(0.7);
}

// Selection state extensions for consistent selection styling
extension SelectionStateExtensions on BuildContext {
  Color get selectedColor => colorScheme.primaryContainer;
  Color get selectedTextColor => colorScheme.onPrimaryContainer;
  BoxDecoration get selectedItemDecoration => BoxDecoration(
    color: selectedColor,
    borderRadius: BorderRadius.circular(8),
  );
}