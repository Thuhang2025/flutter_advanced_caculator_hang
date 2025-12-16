/// Enum representing different calculator modes
enum CalculatorMode {
  basic,
  scientific,
  programmer,
}

/// Extension to get display name for calculator modes
extension CalculatorModeExtension on CalculatorMode {
  String get displayName {
    switch (this) {
      case CalculatorMode.basic:
        return 'Basic';
      case CalculatorMode.scientific:
        return 'Scientific';
      case CalculatorMode.programmer:
        return 'Programmer';
    }
  }
}

