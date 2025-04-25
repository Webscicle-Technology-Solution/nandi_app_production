import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'light_theme.dart';
import 'dark_theme.dart';

// Enum for theme modes
enum AppTheme {
  light,
  dark,
  system,
}

// StateNotifier to manage the current theme
class ThemeNotifier extends StateNotifier<AppTheme> {
  ThemeNotifier() : super(AppTheme.system) {
    _loadTheme();  // Load theme from SharedPreferences when initializing
  }

  // Load the theme from SharedPreferences
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('theme') ?? AppTheme.system.index;  // Default to system theme
    state = AppTheme.values[themeIndex];
  }

  // Save the theme to SharedPreferences
  Future<void> _saveTheme(AppTheme theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme', theme.index);  // Save the theme index
  }

  // Set Light Theme
  Future<void> setLightTheme() async {
    state = AppTheme.light;
    await _saveTheme(AppTheme.light);  // Persist the light theme
  }

  // Set Dark Theme
  Future<void> setDarkTheme() async {
    state = AppTheme.dark;
    await _saveTheme(AppTheme.dark);  // Persist the dark theme
  }

  // Set System Theme
  Future<void> setSystemTheme() async {
    state = AppTheme.system;
    await _saveTheme(AppTheme.system);  // Persist the system theme
  }
}

// Create a provider to access the current theme state
final themeProvider = StateNotifierProvider<ThemeNotifier, AppTheme>(
  (ref) => ThemeNotifier(),
);

// A function to get the current ThemeData based on the app's theme
ThemeData getThemeData(AppTheme appTheme, BuildContext context) {
  switch (appTheme) {
    case AppTheme.dark:
      return darkTheme;
    case AppTheme.light:
      return lightTheme; // Light theme
    case AppTheme.system:
      // Check the system's brightness and return the appropriate theme
      final brightness = MediaQuery.of(context).platformBrightness;
      return brightness == Brightness.dark ? darkTheme : lightTheme;
    default:
      return lightTheme; // Default to light theme
  }
}

