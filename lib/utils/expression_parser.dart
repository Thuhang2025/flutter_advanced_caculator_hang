import 'package:math_expressions/math_expressions.dart';
import 'dart:math' as math;

/// Parser for evaluating mathematical expressions
/// Supports basic operations, scientific functions, constants, and implicit multiplication
class ExpressionParser {
  // Private constructor to prevent instantiation
  ExpressionParser._();

  /// Evaluate a mathematical expression string
  /// Returns the result as a double, or throws an exception on error
  /// 
  /// [expression] - The mathematical expression to evaluate
  /// [angleMode] - Whether to interpret angles as degrees (true) or radians (false)
  /// 
  /// Throws [FormatException] if the expression is invalid
  /// Throws [ArgumentError] for division by zero or other mathematical errors
  static double evaluate(String expression, {bool isDegreesMode = true}) {
    if (expression.trim().isEmpty) {
      throw FormatException('Expression cannot be empty');
    }

    try {
      // Preprocess the expression (handles degree conversion, implicit multiplication, etc.)
      String processedExpression = _preprocessExpression(expression, isDegreesMode: isDegreesMode);
      
      // Parse the expression
      Parser parser = Parser();
      Expression exp = parser.parse(processedExpression);
      
      // Create context with constants only (functions are built-in)
      ContextModel context = _createContext(isDegreesMode);
      
      // Evaluate the expression
      double result = exp.evaluate(EvaluationType.REAL, context);
      
      // Check for special cases
      if (result.isInfinite) {
        throw ArgumentError('Result is infinite (division by zero?)');
      }
      if (result.isNaN) {
        throw ArgumentError('Result is not a number');
      }
      
      return result;
    } on FormatException {
      rethrow;
    } on ArgumentError {
      rethrow;
    } catch (e) {
      throw FormatException('Invalid expression: ${e.toString()}');
    }
  }

  /// Preprocess the expression to handle implicit multiplication and normalize
  static String _preprocessExpression(String expression, {bool isDegreesMode = true}) {
    String processed = expression.trim();
    
    // Replace common symbols
    processed = processed.replaceAll('×', '*');
    processed = processed.replaceAll('÷', '/');
    processed = processed.replaceAll('π', 'pi');
    processed = processed.replaceAll('Π', 'pi');
    processed = processed.replaceAll('e', 'euler');
    
    // Handle degree conversion for trigonometric functions
    // Note: Regular trig functions (sin, cos, tan) convert input degrees to radians
    // Inverse trig functions (asin, acos, atan) work in radians and we convert result
    if (isDegreesMode) {
      // Regular trigonometric functions: convert degrees to radians
      final trigFunctions = ['sin', 'cos', 'tan'];
      for (final func in trigFunctions) {
        // Pattern: sin(45) -> sin(45*pi/180)
        processed = processed.replaceAllMapped(
          RegExp('$func\\(([^)]+)\\)', caseSensitive: false),
          (match) {
            final arg = match.group(1)!;
            return '$func(($arg)*pi/180)';
          },
        );
      }
      
      // Inverse trigonometric functions: convert result from radians to degrees
      // We'll handle these after evaluation by wrapping: asin(x) -> asin(x)*180/pi
      final invTrigFunctions = ['asin', 'acos', 'atan'];
      for (final func in invTrigFunctions) {
        // Pattern: asin(x) -> (asin(x))*180/pi
        processed = processed.replaceAllMapped(
          RegExp('$func\\(([^)]+)\\)', caseSensitive: false),
          (match) {
            final arg = match.group(1)!;
            return '($func($arg))*180/pi';
          },
        );
      }
    }
    
    // Handle implicit multiplication (e.g., 2π -> 2*π, 3(2+1) -> 3*(2+1))
    // Pattern: number followed by letter, constant, or opening parenthesis
    processed = processed.replaceAllMapped(
      RegExp(r'(\d+)([a-zA-Z]|\()'),
      (match) => '${match.group(1)}*${match.group(2)}',
    );
    
    // Pattern: closing parenthesis followed by number, letter, or opening parenthesis
    processed = processed.replaceAllMapped(
      RegExp(r'\)(\d+|[a-zA-Z]|\()'),
      (match) => ')*${match.group(1)}',
    );
    
    // Pattern: letter/constant followed by number or opening parenthesis
    processed = processed.replaceAllMapped(
      RegExp(r'([a-zA-Z]+)(\d+|\()'),
      (match) {
        // Don't add * for function names (sin, cos, etc.)
        String first = match.group(1)!;
        if (_isFunctionName(first)) {
          return match.group(0)!;
        }
        return '${match.group(1)}*${match.group(2)}';
      },
    );
    
    // Handle power operations (x^y, x², x³)
    processed = processed.replaceAll('²', '^2');
    processed = processed.replaceAll('³', '^3');
    processed = processed.replaceAll('√', 'sqrt');
    
    // Handle sqrt with implicit multiplication: sqrt(4) -> sqrt(4)
    // Handle sqrt without parentheses: sqrt4 -> sqrt(4)
    processed = processed.replaceAllMapped(
      RegExp(r'sqrt(\d+\.?\d*)'),
      (match) => 'sqrt(${match.group(1)})',
    );
    
    return processed;
  }

  /// Check if a string is a function name
  static bool _isFunctionName(String name) {
    const functionNames = [
      'sin', 'cos', 'tan', 'asin', 'acos', 'atan',
      'sinh', 'cosh', 'tanh',
      'log', 'ln', 'log2',
      'sqrt', 'cbrt', 'abs',
      'exp', 'pow',
      'pi', 'euler', 'e',
    ];
    return functionNames.contains(name.toLowerCase());
  }

  /// Create context with mathematical constants
  /// Note: math_expressions library already handles standard functions (sin, cos, tan, log, etc.)
  /// We only need to bind custom constants and handle degree conversion
  static ContextModel _createContext(bool isDegreesMode) {
    ContextModel context = ContextModel();
    
    // Add constants only
    context.bindVariable(Variable('pi'), Number(math.pi));
    context.bindVariable(Variable('e'), Number(math.e));
    context.bindVariable(Variable('euler'), Number(math.e));
    
    // Note: Standard functions like sin, cos, tan, log, ln, sqrt, etc. are built-in
    // and automatically available in math_expressions library.
    // They work in radians by default. If degree conversion is needed, we would need
    // to preprocess the expression or use a custom wrapper, but for simplicity,
    // we'll rely on the library's built-in functions which use radians.
    
    // For degree mode, trigonometric functions would need special handling.
    // However, since the library expects radians, we'll note this limitation
    // and let the library handle functions as-is.
    
    return context;
  }
}
