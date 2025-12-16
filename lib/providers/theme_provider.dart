import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

/// Provider for managing app theme (Light, Dark, System)
class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  SharedPreferences? _prefs;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadThemePreference();
  }

  /// Initialize SharedPreferences
  Future<void> _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Load theme preference from storage
  Future<void> _loadThemePreference() async {
    await _initPrefs();
    final themeModeString = _prefs?.getString(AppConstants.keyThemeMode);
    if (themeModeString != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (mode) => mode.toString() == themeModeString,
        orElse: () => ThemeMode.system,
      );
      notifyListeners();
    }
  }

  /// Set theme mode and save to storage
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    
    _themeMode = mode;
    await _initPrefs();
    await _prefs?.setString(AppConstants.keyThemeMode, mode.toString());
    notifyListeners();
  }

  /// Toggle between light and dark theme
  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.light) {
      await setThemeMode(ThemeMode.dark);
    } else if (_themeMode == ThemeMode.dark) {
      await setThemeMode(ThemeMode.light);
    } else {
      // If system, check current system theme and switch to opposite
      final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
      await setThemeMode(brightness == Brightness.dark ? ThemeMode.light : ThemeMode.dark);
    }
  }

  /// Get light theme configuration
  static ThemeData getLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: AppConstants.lightPrimary,
        secondary: AppConstants.lightSecondary,
        tertiary: AppConstants.lightAccent,
        surface: AppConstants.lightSurface,
      ),
      scaffoldBackgroundColor: AppConstants.lightBackground,
      fontFamily: AppConstants.fontFamily,
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: AppConstants.displayFontSize,
          fontWeight: FontWeight.w500,
          color: AppConstants.lightPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: AppConstants.buttonFontSize,
          fontWeight: FontWeight.normal,
          color: AppConstants.lightPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: AppConstants.historyFontSize,
          fontWeight: FontWeight.w300,
          color: AppConstants.lightSecondary,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.displayBorderRadius),
        ),
      ),
    );
  }

  /// Get dark theme configuration
  static ThemeData getDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: AppConstants.darkPrimary,
        secondary: AppConstants.darkSecondary,
        tertiary: AppConstants.darkAccent,
        surface: AppConstants.darkSurface,
      ),
      scaffoldBackgroundColor: AppConstants.darkBackground,
      fontFamily: AppConstants.fontFamily,
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: AppConstants.displayFontSize,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        bodyLarge: TextStyle(
          fontSize: AppConstants.buttonFontSize,
          fontWeight: FontWeight.normal,
          color: Colors.white,
        ),
        bodyMedium: TextStyle(
          fontSize: AppConstants.historyFontSize,
          fontWeight: FontWeight.w300,
          color: AppConstants.darkSecondary,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.displayBorderRadius),
        ),
      ),
    );
  }
}

