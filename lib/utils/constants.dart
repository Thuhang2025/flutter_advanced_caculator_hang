import 'package:flutter/material.dart';

/// Design constants and theme colors for the Advanced Calculator App
class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();

  // Light Theme Colors
  static const Color lightPrimary = Color(0xFF1E1E1E);
  static const Color lightSecondary = Color(0xFF424242);
  static const Color lightAccent = Color(0xFFFF6B6B);
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF5F5F5);

  // Dark Theme Colors
  static const Color darkPrimary = Color(0xFF121212);
  static const Color darkSecondary = Color(0xFF2C2C2C);
  static const Color darkAccent = Color(0xFF4ECDC4);
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);

  // Typography
  static const String fontFamily = 'Roboto';
  static const double buttonFontSize = 16.0;
  static const double displayFontSize = 32.0;
  static const double historyFontSize = 18.0;

  // Spacing
  static const double buttonSpacing = 12.0;
  static const double screenPadding = 24.0;

  // Border Radius
  static const double buttonBorderRadius = 16.0;
  static const double displayBorderRadius = 24.0;

  // Animation Durations
  static const Duration buttonPressDuration = Duration(milliseconds: 200);
  static const Duration modeSwitchDuration = Duration(milliseconds: 300);

  // Calculator Settings Defaults
  static const int defaultDecimalPrecision = 6;
  static const int minDecimalPrecision = 2;
  static const int maxDecimalPrecision = 10;
  static const int defaultHistorySize = 50;
  static const List<int> historySizeOptions = [25, 50, 100];

  // Storage Keys
  static const String keyThemeMode = 'theme_mode';
  static const String keyDecimalPrecision = 'decimal_precision';
  static const String keyAngleMode = 'angle_mode';
  static const String keyHapticFeedback = 'haptic_feedback';
  static const String keySoundEffects = 'sound_effects';
  static const String keyHistorySize = 'history_size';
  static const String keyCalculationHistory = 'calculation_history';
  static const String keyMemoryValue = 'memory_value';
  static const String keyCalculatorMode = 'calculator_mode';
}

