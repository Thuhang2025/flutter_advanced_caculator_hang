import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/calculation_history.dart';
import '../models/calculator_mode.dart';
import '../models/angle_mode.dart';
import '../utils/constants.dart';

/// Service for managing persistent storage using SharedPreferences
/// Handles saving and loading: history, settings, memory, preferences
class StorageService {
  static SharedPreferences? _prefs;

  /// Initialize SharedPreferences instance
  static Future<void> _init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Load calculation history from storage
  /// Returns empty list if no history exists
  static Future<List<CalculationHistory>> loadHistory() async {
    await _init();
    final historyJson = _prefs?.getString(AppConstants.keyCalculationHistory);
    
    if (historyJson == null || historyJson.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> historyList = json.decode(historyJson);
      return historyList
          .map((item) => CalculationHistory.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // If parsing fails, return empty list
      return [];
    }
  }

  /// Save calculation history to storage
  /// Limits history size to the specified maximum
  static Future<void> saveHistory(
    List<CalculationHistory> history, 
    int maxSize,
  ) async {
    await _init();
    
    // Limit history size (keep most recent entries)
    final historyToSave = history.length > maxSize
        ? history.sublist(history.length - maxSize)
        : history;
    
    final historyJson = json.encode(
      historyToSave.map((item) => item.toJson()).toList(),
    );
    
    await _prefs?.setString(AppConstants.keyCalculationHistory, historyJson);
  }

  /// Clear all calculation history
  static Future<void> clearHistory() async {
    await _init();
    await _prefs?.remove(AppConstants.keyCalculationHistory);
  }

  /// Load memory value
  static Future<double> loadMemory() async {
    await _init();
    return _prefs?.getDouble(AppConstants.keyMemoryValue) ?? 0.0;
  }

  /// Save memory value
  static Future<void> saveMemory(double value) async {
    await _init();
    if (value == 0.0) {
      await _prefs?.remove(AppConstants.keyMemoryValue);
    } else {
      await _prefs?.setDouble(AppConstants.keyMemoryValue, value);
    }
  }

  /// Load calculator mode preference
  static Future<CalculatorMode> loadCalculatorMode() async {
    await _init();
    final modeString = _prefs?.getString(AppConstants.keyCalculatorMode);
    
    if (modeString == null) {
      return CalculatorMode.basic;
    }

    try {
      return CalculatorMode.values.firstWhere(
        (mode) => mode.toString() == modeString,
        orElse: () => CalculatorMode.basic,
      );
    } catch (e) {
      return CalculatorMode.basic;
    }
  }

  /// Save calculator mode preference
  static Future<void> saveCalculatorMode(CalculatorMode mode) async {
    await _init();
    await _prefs?.setString(AppConstants.keyCalculatorMode, mode.toString());
  }

  /// Load angle mode preference
  static Future<AngleMode> loadAngleMode() async {
    await _init();
    final angleModeString = _prefs?.getString(AppConstants.keyAngleMode);
    
    if (angleModeString == null) {
      return AngleMode.degrees;
    }

    try {
      return AngleMode.values.firstWhere(
        (mode) => mode.toString() == angleModeString,
        orElse: () => AngleMode.degrees,
      );
    } catch (e) {
      return AngleMode.degrees;
    }
  }

  /// Save angle mode preference
  static Future<void> saveAngleMode(AngleMode mode) async {
    await _init();
    await _prefs?.setString(AppConstants.keyAngleMode, mode.toString());
  }

  /// Load decimal precision setting
  static Future<int> loadDecimalPrecision() async {
    await _init();
    final precision = _prefs?.getInt(AppConstants.keyDecimalPrecision);
    
    if (precision == null) {
      return AppConstants.defaultDecimalPrecision;
    }

    // Validate precision range
    if (precision >= AppConstants.minDecimalPrecision &&
        precision <= AppConstants.maxDecimalPrecision) {
      return precision;
    }
    
    return AppConstants.defaultDecimalPrecision;
  }

  /// Save decimal precision setting
  static Future<void> saveDecimalPrecision(int precision) async {
    await _init();
    if (precision >= AppConstants.minDecimalPrecision &&
        precision <= AppConstants.maxDecimalPrecision) {
      await _prefs?.setInt(AppConstants.keyDecimalPrecision, precision);
    }
  }

  /// Load haptic feedback setting
  static Future<bool> loadHapticFeedback() async {
    await _init();
    return _prefs?.getBool(AppConstants.keyHapticFeedback) ?? true;
  }

  /// Save haptic feedback setting
  static Future<void> saveHapticFeedback(bool enabled) async {
    await _init();
    await _prefs?.setBool(AppConstants.keyHapticFeedback, enabled);
  }

  /// Load sound effects setting
  static Future<bool> loadSoundEffects() async {
    await _init();
    return _prefs?.getBool(AppConstants.keySoundEffects) ?? false;
  }

  /// Save sound effects setting
  static Future<void> saveSoundEffects(bool enabled) async {
    await _init();
    await _prefs?.setBool(AppConstants.keySoundEffects, enabled);
  }

  /// Load history size setting
  static Future<int> loadHistorySize() async {
    await _init();
    final size = _prefs?.getInt(AppConstants.keyHistorySize);
    
    if (size == null) {
      return AppConstants.defaultHistorySize;
    }

    // Validate size is one of the allowed options
    if (AppConstants.historySizeOptions.contains(size)) {
      return size;
    }
    
    return AppConstants.defaultHistorySize;
  }

  /// Save history size setting
  static Future<void> saveHistorySize(int size) async {
    await _init();
    if (AppConstants.historySizeOptions.contains(size)) {
      await _prefs?.setInt(AppConstants.keyHistorySize, size);
    }
  }

  /// Clear all stored preferences (except theme which is managed by ThemeProvider)
  static Future<void> clearAllPreferences() async {
    await _init();
    await _prefs?.remove(AppConstants.keyDecimalPrecision);
    await _prefs?.remove(AppConstants.keyAngleMode);
    await _prefs?.remove(AppConstants.keyHapticFeedback);
    await _prefs?.remove(AppConstants.keySoundEffects);
    await _prefs?.remove(AppConstants.keyHistorySize);
    await _prefs?.remove(AppConstants.keyCalculatorMode);
    await _prefs?.remove(AppConstants.keyMemoryValue);
    await _prefs?.remove(AppConstants.keyCalculationHistory);
  }
}

