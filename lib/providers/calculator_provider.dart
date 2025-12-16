import 'package:flutter/foundation.dart';
import '../models/calculator_mode.dart';
import '../models/angle_mode.dart';
import '../models/base_mode.dart';
import '../utils/expression_parser.dart';
import '../utils/programmer_logic.dart';
import '../utils/constants.dart';

/// Provider for managing calculator state and operations
/// Handles expression input, calculation, memory operations, and mode switching
class CalculatorProvider with ChangeNotifier {
  // Expression and result
  String _expression = '';
  String _result = '';
  String _error = '';

  // Calculator mode
  CalculatorMode _mode = CalculatorMode.basic;

  // Angle mode (Degrees/Radians)
  AngleMode _angleMode = AngleMode.degrees;

  // Base mode (for Programmer Mode)
  BaseMode _baseMode = BaseMode.decimal;

  // Memory value
  double _memory = 0.0;

  // Decimal precision
  int _decimalPrecision = AppConstants.defaultDecimalPrecision;

  // Getters
  String get expression => _expression;
  String get result => _result;
  String get error => _error;
  CalculatorMode get mode => _mode;
  AngleMode get angleMode => _angleMode;
  BaseMode get baseMode => _baseMode;
  double get memory => _memory;
  bool get hasMemory => _memory != 0.0;
  int get decimalPrecision => _decimalPrecision;

  /// Add a value to the current expression
  /// Validates input based on calculator mode
  void addToExpression(String value) {
    _error = '';
    
    // Validate input based on mode
    if (_mode == CalculatorMode.basic) {
      if (!_isValidBasicInput(value)) {
        _error = 'Invalid input for basic mode';
        notifyListeners();
        return;
      }
    } else if (_mode == CalculatorMode.scientific) {
      if (!_isValidScientificInput(value)) {
        _error = 'Invalid input for scientific mode';
        notifyListeners();
        return;
      }
    } else if (_mode == CalculatorMode.programmer) {
      if (!_isValidProgrammerInput(value)) {
        _error = 'Invalid input for programmer mode';
        notifyListeners();
        return;
      }
    }
    
    // Handle special cases
    if (value == '=') {
      calculate();
      return;
    }
    
    // Handle clear operations
    if (value == 'C' || value == 'CE') {
      clear();
      return;
    }
    
    // Handle backspace
    if (value == '⌫' || value == 'DEL') {
      delete();
      return;
    }
    
    // Handle percentage
    if (value == '%') {
      _expression += '/100';
      notifyListeners();
      return;
    }
    
    // Handle constants
    if (value == 'π' || value == 'pi') {
      _expression += 'π';
      notifyListeners();
      return;
    }
    
    if (value == 'e') {
      _expression += 'e';
      notifyListeners();
      return;
    }
    
    // Handle scientific functions
    if (_isFunction(value)) {
      _expression += '$value(';
      notifyListeners();
      return;
    }
    
    // Handle power operations
    if (value == 'x²') {
      _expression += '²';
      notifyListeners();
      return;
    }
    
    if (value == 'x³') {
      _expression += '³';
      notifyListeners();
      return;
    }
    
    if (value == 'x^y') {
      _expression += '^';
      notifyListeners();
      return;
    }
    
    // Handle square root
    if (value == '√') {
      _expression += '√';
      notifyListeners();
      return;
    }
    
    // Handle sign change
    if (value == '±' || value == '+/-') {
      _toggleSign();
      notifyListeners();
      return;
    }

    // Handle programmer mode operations
    if (_mode == CalculatorMode.programmer) {
      if (value == 'AND' || value == 'OR' || value == 'XOR') {
        _expression += ' $value ';
        notifyListeners();
        return;
      }
      if (value == 'NOT') {
        _expression += 'NOT(';
        notifyListeners();
        return;
      }
      if (value == '<<' || value == 'LSH') {
        _expression += ' << ';
        notifyListeners();
        return;
      }
      if (value == '>>' || value == 'RSH') {
        _expression += ' >> ';
        notifyListeners();
        return;
      }
      // For base switching buttons, convert current value
      if (value == 'HEX' || value == 'DEC' || value == 'OCT' || value == 'BIN') {
        _switchBase(value);
        return;
      }
    }
    
    // Normal input (validate character for programmer mode)
    if (_mode == CalculatorMode.programmer) {
      // Convert to uppercase for hex
      final char = _baseMode == BaseMode.hexadecimal ? value.toUpperCase() : value;
      if (!ProgrammerLogic.isValidCharForBase(char, _baseMode)) {
        _error = 'Invalid character for ${_baseMode.displayName}';
        notifyListeners();
        return;
      }
      _expression += char;
    } else {
      _expression += value;
    }
    notifyListeners();
  }

  /// Calculate the result of the current expression
  void calculate() {
    _error = '';
    _result = '';
    
    if (_expression.trim().isEmpty) {
      return;
    }
    
    try {
      if (_mode == CalculatorMode.programmer) {
        // Use programmer mode evaluation
        final result = ProgrammerLogic.evaluateProgrammerExpression(
          _expression,
          _baseMode,
        );
        
        if (result != null) {
          _result = result;
          _error = '';
        } else {
          _error = 'Invalid programmer expression';
          _result = '';
        }
      } else {
        // Use standard evaluation
        double calculatedResult = ExpressionParser.evaluate(
          _expression,
          isDegreesMode: _angleMode == AngleMode.degrees,
        );
        
        // Format the result
        _result = _formatResult(calculatedResult);
        _error = '';
      }
    } on FormatException catch (e) {
      _error = e.message;
      _result = '';
    } on ArgumentError catch (e) {
      _error = e.message ?? 'Invalid calculation';
      _result = '';
    } catch (e) {
      _error = 'Error: ${e.toString()}';
      _result = '';
    }
    
    notifyListeners();
  }

  /// Clear the expression and result
  void clear() {
    _expression = '';
    _result = '';
    _error = '';
    notifyListeners();
  }

  /// Clear entry (clear last entry)
  void clearEntry() {
    _expression = '';
    _error = '';
    notifyListeners();
  }

  /// Delete the last character from the expression
  void delete() {
    if (_expression.isNotEmpty) {
      _expression = _expression.substring(0, _expression.length - 1);
      _error = '';
      notifyListeners();
    }
  }

  /// Toggle calculator mode
  void toggleMode(CalculatorMode newMode) {
    if (_mode != newMode) {
      _mode = newMode;
      // Reset base mode to decimal when leaving programmer mode
      if (newMode != CalculatorMode.programmer) {
        _baseMode = BaseMode.decimal;
      }
      // Clear expression when switching modes to avoid confusion
      clear();
      notifyListeners();
    }
  }

  /// Set base mode (for Programmer Mode)
  void setBaseMode(BaseMode mode) {
    if (_baseMode != mode) {
      // Convert current result/expression if there's a value
      if (_result.isNotEmpty) {
        final converted = ProgrammerLogic.convertBase(
          _result,
          _baseMode,
          mode,
        );
        if (converted != null) {
          _result = converted;
        }
      }
      _baseMode = mode;
      notifyListeners();
    }
  }

  /// Switch base mode from button press
  void _switchBase(String baseButton) {
    BaseMode? newBase;
    switch (baseButton) {
      case 'HEX':
        newBase = BaseMode.hexadecimal;
        break;
      case 'DEC':
        newBase = BaseMode.decimal;
        break;
      case 'OCT':
        newBase = BaseMode.octal;
        break;
      case 'BIN':
        newBase = BaseMode.binary;
        break;
    }
    
    if (newBase != null && newBase != _baseMode) {
      // Convert current result if it exists
      if (_result.isNotEmpty) {
        final converted = ProgrammerLogic.convertBase(
          _result,
          _baseMode,
          newBase,
        );
        if (converted != null) {
          _result = converted;
        }
      }
      // Convert current expression value if it's just a number
      if (_expression.isNotEmpty && _isProgrammerNumber(_expression)) {
        final converted = ProgrammerLogic.convertBase(
          _expression.trim(),
          _baseMode,
          newBase,
        );
        if (converted != null) {
          _expression = converted;
        }
      }
      _baseMode = newBase;
      notifyListeners();
    }
  }

  /// Check if expression is just a number (for base conversion)
  bool _isProgrammerNumber(String expr) {
    // Simple check: if it's just alphanumeric (no operators)
    return RegExp(r'^[0-9A-F\s]+$', caseSensitive: false).hasMatch(expr.trim());
  }

  /// Set angle mode (Degrees or Radians)
  void setAngleMode(AngleMode mode) {
    if (_angleMode != mode) {
      _angleMode = mode;
      notifyListeners();
    }
  }

  /// Toggle angle mode between Degrees and Radians
  void toggleAngleMode() {
    _angleMode = _angleMode == AngleMode.degrees 
        ? AngleMode.radians 
        : AngleMode.degrees;
    notifyListeners();
  }

  /// Set decimal precision
  void setDecimalPrecision(int precision) {
    if (precision >= AppConstants.minDecimalPrecision && 
        precision <= AppConstants.maxDecimalPrecision) {
      _decimalPrecision = precision;
      notifyListeners();
    }
  }

  /// Memory: Add current result to memory
  void memoryAdd() {
    try {
      if (_result.isNotEmpty) {
        double value = double.parse(_result);
        _memory += value;
        notifyListeners();
      } else if (_expression.isNotEmpty) {
        // Try to calculate first
        calculate();
        if (_result.isNotEmpty && _error.isEmpty) {
          double value = double.parse(_result);
          _memory += value;
          notifyListeners();
        }
      }
    } catch (e) {
      _error = 'Invalid value for memory';
      notifyListeners();
    }
  }

  /// Memory: Subtract current result from memory
  void memorySubtract() {
    try {
      if (_result.isNotEmpty) {
        double value = double.parse(_result);
        _memory -= value;
        notifyListeners();
      } else if (_expression.isNotEmpty) {
        // Try to calculate first
        calculate();
        if (_result.isNotEmpty && _error.isEmpty) {
          double value = double.parse(_result);
          _memory -= value;
          notifyListeners();
        }
      }
    } catch (e) {
      _error = 'Invalid value for memory';
      notifyListeners();
    }
  }

  /// Memory: Recall memory value
  void memoryRecall() {
    if (_memory != 0.0) {
      _expression += _formatResult(_memory);
      notifyListeners();
    }
  }

  /// Memory: Clear memory
  void memoryClear() {
    _memory = 0.0;
    notifyListeners();
  }

  /// Set memory value directly (useful for loading from storage)
  void setMemory(double value) {
    _memory = value;
    notifyListeners();
  }

  /// Set expression directly (useful for history recall)
  void setExpression(String expr) {
    _expression = expr;
    _result = '';
    _error = '';
    notifyListeners();
  }

  /// Set result directly (useful for chaining calculations)
  void setResultAsExpression() {
    if (_result.isNotEmpty && _error.isEmpty) {
      _expression = _result;
      _result = '';
      notifyListeners();
    }
  }

  // Private helper methods

  /// Check if input is valid for basic mode
  bool _isValidBasicInput(String value) {
    const validChars = '0123456789+-*/.()';
    return validChars.contains(value) || 
           value == '=' || 
           value == 'C' || 
           value == 'CE' ||
           value == '%' ||
           value == '±' ||
           value == '+/-';
  }

  /// Check if input is valid for scientific mode
  bool _isValidScientificInput(String value) {
    // All basic inputs plus scientific functions
    return _isValidBasicInput(value) || 
           _isFunction(value) ||
           value == 'π' ||
           value == 'pi' ||
           value == 'e' ||
           value == '√' ||
           value == 'x²' ||
           value == 'x³' ||
           value == 'x^y';
  }

  /// Check if input is valid for programmer mode
  bool _isValidProgrammerInput(String value) {
    // Single character check
    if (value.length == 1) {
      // Valid if it's a valid character for current base or an operator
      return ProgrammerLogic.isValidCharForBase(value, _baseMode) ||
             ['+', '-', '*', '/', '(', ')', '='].contains(value) ||
             value == 'C' ||
             value == 'CE' ||
             value == '⌫' ||
             value == 'DEL';
    }
    
    // Multi-character operations
    return value == 'AND' ||
           value == 'OR' ||
           value == 'XOR' ||
           value == 'NOT' ||
           value == '<<' ||
           value == 'LSH' ||
           value == '>>' ||
           value == 'RSH' ||
           value == 'HEX' ||
           value == 'DEC' ||
           value == 'OCT' ||
           value == 'BIN' ||
           value == '=' ||
           value == 'C' ||
           value == 'CE' ||
           value == '⌫' ||
           value == 'DEL';
  }

  /// Check if value is a function name
  bool _isFunction(String value) {
    const functions = [
      'sin', 'cos', 'tan',
      'asin', 'acos', 'atan',
      'sinh', 'cosh', 'tanh',
      'log', 'ln', 'log2',
      'sqrt', 'cbrt', 'abs',
      'exp', 'pow',
    ];
    return functions.contains(value.toLowerCase());
  }

  /// Toggle the sign of the last number in expression
  void _toggleSign() {
    if (_expression.isEmpty) {
      _expression = '-';
      return;
    }
    
    // Find the last number and toggle its sign
    final regex = RegExp(r'(-?\d+\.?\d*)$');
    final match = regex.firstMatch(_expression);
    
    if (match != null) {
      final number = match.group(0)!;
      final newNumber = number.startsWith('-') 
          ? number.substring(1) 
          : '-$number';
      _expression = _expression.substring(0, match.start) + newNumber;
    } else {
      // If no number found, add minus sign
      _expression += '-';
    }
  }

  /// Format result with appropriate decimal precision
  String _formatResult(double value) {
    // Remove trailing zeros
    String formatted = value.toStringAsFixed(_decimalPrecision);
    
    // Remove trailing zeros and decimal point if not needed
    if (formatted.contains('.')) {
      formatted = formatted.replaceAll(RegExp(r'0+$'), '');
      formatted = formatted.replaceAll(RegExp(r'\.$'), '');
    }
    
    // Handle very large or very small numbers with scientific notation
    if (value.abs() > 1e10 || (value.abs() < 1e-6 && value != 0)) {
      return value.toStringAsExponential(_decimalPrecision);
    }
    
    return formatted;
  }
}
