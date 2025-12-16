/// Enum representing number base modes for Programmer Mode
enum BaseMode {
  decimal,
  hexadecimal,
  octal,
  binary,
}

/// Extension to get display name and properties for base modes
extension BaseModeExtension on BaseMode {
  /// Get display name for the base mode
  String get displayName {
    switch (this) {
      case BaseMode.decimal:
        return 'DEC';
      case BaseMode.hexadecimal:
        return 'HEX';
      case BaseMode.octal:
        return 'OCT';
      case BaseMode.binary:
        return 'BIN';
    }
  }

  /// Get the radix (base) value
  int get radix {
    switch (this) {
      case BaseMode.decimal:
        return 10;
      case BaseMode.hexadecimal:
        return 16;
      case BaseMode.octal:
        return 8;
      case BaseMode.binary:
        return 2;
    }
  }

  /// Get valid characters for this base
  String get validChars {
    switch (this) {
      case BaseMode.decimal:
        return '0123456789';
      case BaseMode.hexadecimal:
        return '0123456789ABCDEF';
      case BaseMode.octal:
        return '01234567';
      case BaseMode.binary:
        return '01';
    }
  }

  /// Check if a character is valid for this base
  bool isValidChar(String char) {
    return validChars.contains(char.toUpperCase());
  }
}

