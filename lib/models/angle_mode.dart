/// Enum representing angle mode (Degrees or Radians)
enum AngleMode {
  degrees,
  radians,
}

/// Extension to get display name and conversion for angle modes
extension AngleModeExtension on AngleMode {
  String get displayName {
    switch (this) {
      case AngleMode.degrees:
        return 'DEG';
      case AngleMode.radians:
        return 'RAD';
    }
  }

  /// Convert degrees to radians if needed
  double toRadians(double value) {
    switch (this) {
      case AngleMode.degrees:
        return value * (3.141592653589793 / 180.0);
      case AngleMode.radians:
        return value;
    }
  }
}
