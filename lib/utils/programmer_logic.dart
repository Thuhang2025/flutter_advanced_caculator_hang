import '../models/base_mode.dart';

/// Utility class for Programmer Mode operations
/// Handles base conversions and bitwise operations
class ProgrammerLogic {
  ProgrammerLogic._();

  /// Convert a number string from one base to another
  /// Returns the converted string, or null on error
  static String? convertBase(String value, BaseMode fromBase, BaseMode toBase) {
    if (value.isEmpty) return null;

    try {
      // Parse from source base
      final intValue = int.parse(value, radix: fromBase.radix);

      // Convert to target base
      return intValue.toRadixString(toBase.radix).toUpperCase();
    } catch (e) {
      return null;
    }
  }

  /// Convert current value to a specific base format
  static String formatToBase(String value, BaseMode base) {
    if (value.isEmpty) return value;

    try {
      // Try to parse as decimal first
      final intValue = int.tryParse(value);
      if (intValue != null) {
        return intValue.toRadixString(base.radix).toUpperCase();
      }
      // If not decimal, try to parse in current base (for display purposes)
      return value.toUpperCase();
    } catch (e) {
      return value;
    }
  }

  /// Parse a number from any base to integer
  static int? parseFromBase(String value, BaseMode base) {
    if (value.isEmpty) return null;

    try {
      return int.parse(value, radix: base.radix);
    } catch (e) {
      return null;
    }
  }

  /// Perform bitwise AND operation
  static String? bitwiseAnd(String a, String b, BaseMode base) {
    final intA = parseFromBase(a, base);
    final intB = parseFromBase(b, base);

    if (intA == null || intB == null) return null;

    final result = intA & intB;
    return result.toRadixString(base.radix).toUpperCase();
  }

  /// Perform bitwise OR operation
  static String? bitwiseOr(String a, String b, BaseMode base) {
    final intA = parseFromBase(a, base);
    final intB = parseFromBase(b, base);

    if (intA == null || intB == null) return null;

    final result = intA | intB;
    return result.toRadixString(base.radix).toUpperCase();
  }

  /// Perform bitwise XOR operation
  static String? bitwiseXor(String a, String b, BaseMode base) {
    final intA = parseFromBase(a, base);
    final intB = parseFromBase(b, base);

    if (intA == null || intB == null) return null;

    final result = intA ^ intB;
    return result.toRadixString(base.radix).toUpperCase();
  }

  /// Perform bitwise NOT operation
  static String? bitwiseNot(String value, BaseMode base) {
    final intValue = parseFromBase(value, base);

    if (intValue == null) return null;

    // For 32-bit signed integer NOT operation
    final result = (~intValue) & 0xFFFFFFFF;
    return result.toRadixString(base.radix).toUpperCase();
  }

  /// Perform left bit shift
  static String? leftShift(String value, int shift, BaseMode base) {
    final intValue = parseFromBase(value, base);

    if (intValue == null || shift < 0) return null;

    final result = intValue << shift;
    return result.toRadixString(base.radix).toUpperCase();
  }

  /// Perform right bit shift
  static String? rightShift(String value, int shift, BaseMode base) {
    final intValue = parseFromBase(value, base);

    if (intValue == null || shift < 0) return null;

    final result = intValue >> shift;
    return result.toRadixString(base.radix).toUpperCase();
  }

  /// Evaluate a simple programmer mode expression
  /// Supports: numbers, bitwise operations (AND, OR, XOR, NOT), shifts (<<, >>)
  /// Also supports basic arithmetic operations
  static String? evaluateProgrammerExpression(String expression, BaseMode base) {
    if (expression.isEmpty) return null;

    try {
      // Clean up expression - remove extra spaces but keep structure
      expression = expression.trim().toUpperCase();

      // For simple expressions, try to parse directly
      // First, handle basic arithmetic if present
      if (expression.contains('+') || 
          expression.contains('-') || 
          expression.contains('*') || 
          expression.contains('/')) {
        // Parse basic arithmetic operations
        return _evaluateArithmetic(expression, base);
      }

      // Handle shifts first (higher precedence in grouping)
      expression = _evaluateShifts(expression, base);

      // Handle NOT operation (unary) - must be in parentheses
      expression = expression.replaceAllMapped(
        RegExp(r'NOT\s*\(([^)]+)\)'),
        (match) {
          final value = match.group(1)!.trim();
          final result = bitwiseNot(value, base);
          return result ?? '0';
        },
      );

      // Handle bitwise operations (left to right evaluation)
      // AND has higher precedence than OR/XOR
      while (expression.contains(' AND ')) {
        expression = expression.replaceFirstMapped(
          RegExp(r'(\w+)\s+AND\s+(\w+)'),
          (match) {
            final a = match.group(1)!.trim();
            final b = match.group(2)!.trim();
            final result = bitwiseAnd(a, b, base);
            return result ?? '0';
          },
        );
      }

      // XOR
      while (expression.contains(' XOR ')) {
        expression = expression.replaceFirstMapped(
          RegExp(r'(\w+)\s+XOR\s+(\w+)'),
          (match) {
            final a = match.group(1)!.trim();
            final b = match.group(2)!.trim();
            final result = bitwiseXor(a, b, base);
            return result ?? '0';
          },
        );
      }

      // OR
      while (expression.contains(' OR ')) {
        expression = expression.replaceFirstMapped(
          RegExp(r'(\w+)\s+OR\s+(\w+)'),
          (match) {
            final a = match.group(1)!.trim();
            final b = match.group(2)!.trim();
            final result = bitwiseOr(a, b, base);
            return result ?? '0';
          },
        );
      }

      // Final result should be a valid number in the current base
      expression = expression.trim();
      final finalValue = parseFromBase(expression, base);
      if (finalValue != null) {
        return finalValue.toRadixString(base.radix).toUpperCase();
      }

      // If we can't parse it, return as-is (might be invalid)
      return expression.isNotEmpty ? expression : null;
    } catch (e) {
      return null;
    }
  }

  /// Evaluate shifts in expression
  static String _evaluateShifts(String expression, BaseMode base) {
    // Handle left shift
    while (expression.contains('<<')) {
      expression = expression.replaceFirstMapped(
        RegExp(r'(\w+)\s*<<\s*(\w+)'),
        (match) {
          final value = match.group(1)!.trim();
          final shiftStr = match.group(2)!.trim();
          final shift = parseFromBase(shiftStr, base) ?? 0;
          final result = leftShift(value, shift, base);
          return result ?? '0';
        },
      );
    }

    // Handle right shift
    while (expression.contains('>>')) {
      expression = expression.replaceFirstMapped(
        RegExp(r'(\w+)\s*>>\s*(\w+)'),
        (match) {
          final value = match.group(1)!.trim();
          final shiftStr = match.group(2)!.trim();
          final shift = parseFromBase(shiftStr, base) ?? 0;
          final result = rightShift(value, shift, base);
          return result ?? '0';
        },
      );
    }

    return expression;
  }

  /// Evaluate basic arithmetic operations
  static String? _evaluateArithmetic(String expression, BaseMode base) {
    try {
      // Parse all numbers in the expression
      final parts = expression.split(RegExp(r'([+\-*/])'));
      
      if (parts.length < 3) {
        // Not enough parts for an operation
        final value = parseFromBase(expression.trim(), base);
        return value?.toRadixString(base.radix).toUpperCase();
      }

      // Simple left-to-right evaluation
      int? result;
      String? operator;

      for (var part in parts) {
        part = part.trim();
        if (part.isEmpty) continue;

        if (['+', '-', '*', '/'].contains(part)) {
          operator = part;
        } else {
          final value = parseFromBase(part, base);
          if (value == null) continue;

          if (result == null) {
            result = value;
          } else if (operator != null) {
            switch (operator) {
              case '+':
                result = result + value;
                break;
              case '-':
                result = result - value;
                break;
              case '*':
                result = result * value;
                break;
              case '/':
                if (value == 0) return null; // Division by zero
                result = result ~/ value; // Integer division
                break;
            }
            operator = null;
          }
        }
      }

      return result?.toRadixString(base.radix).toUpperCase();
    } catch (e) {
      return null;
    }
  }

  /// Validate if a character is valid for a given base
  static bool isValidCharForBase(String char, BaseMode base) {
    return base.isValidChar(char);
  }
}

