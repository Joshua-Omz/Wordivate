import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wordivate/core/constants/apptheme.dart';
import 'package:wordivate/core/services/storage_service.dart';

// Provider for current theme mode
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier();
});

// State class for theme
class ThemeState {
  final String themeMode;
  final ThemeData themeData;

  ThemeState({
    required this.themeMode,
    required this.themeData,
  });

  ThemeState copyWith({
    String? themeMode,
    ThemeData? themeData,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      themeData: themeData ?? this.themeData,
    );
  }
}

// Notifier for managing theme
class ThemeNotifier extends StateNotifier<ThemeState> {
  final StorageService _storageService = StorageService();
  
  ThemeNotifier() : super(
    ThemeState(
      themeMode: AppTheme.light,
      themeData: AppTheme.getLightTheme(),
    )
  ) {
    _loadTheme();
  }

  // Load saved theme from storage
  Future<void> _loadTheme() async {
    try {
      final savedTheme = await _storageService.getTheme();
      if (savedTheme != null) {
        setTheme(savedTheme);
      }
    } catch (e) {
      // If there's an error, stick with the default light theme
      debugPrint('Error loading theme: $e');
    }
  }

  // Set theme by theme name
  void setTheme(String themeName) {
    final themeData = AppTheme.getThemeByName(themeName);
    state = ThemeState(
      themeMode: themeName,
      themeData: themeData,
    );
    _saveTheme(themeName);
  }

  // Toggle between light and dark themes
  void toggleTheme() {
    final newTheme = state.themeMode == AppTheme.light 
        ? AppTheme.dark 
        : AppTheme.light;
    setTheme(newTheme);
  }

  // Save theme preference
  Future<void> _saveTheme(String themeName) async {
    try {
      await _storageService.saveTheme(themeName);
    } catch (e) {
      debugPrint('Error saving theme: $e');
    }
  }
}