import 'package:flutter/foundation.dart';
import '../models/calculation_history.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';

/// Provider for managing calculation history
/// Handles storage, retrieval, and persistence of calculation history
class HistoryProvider with ChangeNotifier {
  List<CalculationHistory> _history = [];
  int _maxHistorySize = AppConstants.defaultHistorySize;

  List<CalculationHistory> get history => List.unmodifiable(_history);
  int get maxHistorySize => _maxHistorySize;
  int get historyCount => _history.length;
  bool get hasHistory => _history.isNotEmpty;

  HistoryProvider() {
    _loadHistory();
  }

  /// Load history from storage on initialization
  Future<void> _loadHistory() async {
    try {
      // Load history size preference first
      _maxHistorySize = await StorageService.loadHistorySize();
      
      // Load history entries
      _history = await StorageService.loadHistory();
      
      // Ensure history doesn't exceed max size
      if (_history.length > _maxHistorySize) {
        _history = _history.sublist(_history.length - _maxHistorySize);
        await _saveHistory();
      }
      
      notifyListeners();
    } catch (e) {
      // If loading fails, start with empty history
      _history = [];
    }
  }

  /// Save history to storage
  Future<void> _saveHistory() async {
    try {
      await StorageService.saveHistory(_history, _maxHistorySize);
    } catch (e) {
      // Log error if needed, but don't throw
      debugPrint('Error saving history: $e');
    }
  }

  /// Add a new calculation to history
  Future<void> addToHistory(String expression, String result) async {
    if (expression.isEmpty || result.isEmpty) {
      return;
    }

    final entry = CalculationHistory(
      expression: expression,
      result: result,
      timestamp: DateTime.now(),
    );

    _history.add(entry);

    // Limit history size
    if (_history.length > _maxHistorySize) {
      _history.removeAt(0);
    }

    await _saveHistory();
    notifyListeners();
  }

  /// Remove a specific history entry by index
  Future<void> removeHistoryEntry(int index) async {
    if (index >= 0 && index < _history.length) {
      _history.removeAt(index);
      await _saveHistory();
      notifyListeners();
    }
  }

  /// Clear all history
  Future<void> clearHistory() async {
    _history.clear();
    await StorageService.clearHistory();
    notifyListeners();
  }

  /// Get the last N calculations
  List<CalculationHistory> getLastCalculations(int count) {
    if (count <= 0 || _history.isEmpty) {
      return [];
    }
    
    final startIndex = _history.length > count 
        ? _history.length - count 
        : 0;
    
    return _history.sublist(startIndex);
  }

  /// Update maximum history size
  Future<void> setMaxHistorySize(int size) async {
    if (!AppConstants.historySizeOptions.contains(size)) {
      return;
    }

    _maxHistorySize = size;

    // Trim history if it exceeds new max size
    if (_history.length > _maxHistorySize) {
      _history = _history.sublist(_history.length - _maxHistorySize);
      await _saveHistory();
    }

    // Save preference
    await StorageService.saveHistorySize(size);
    notifyListeners();
  }

  /// Get history entry by index
  CalculationHistory? getHistoryEntry(int index) {
    if (index >= 0 && index < _history.length) {
      return _history[index];
    }
    return null;
  }

  /// Search history by expression or result
  List<CalculationHistory> searchHistory(String query) {
    if (query.isEmpty) {
      return List.unmodifiable(_history);
    }

    final lowercaseQuery = query.toLowerCase();
    return _history.where((entry) {
      return entry.expression.toLowerCase().contains(lowercaseQuery) ||
             entry.result.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }
}

