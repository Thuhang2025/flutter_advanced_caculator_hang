/// Model for calculator settings
class CalculatorSettings {
  final int decimalPrecision;
  final bool isDegreesMode; // true for degrees, false for radians
  final bool hapticFeedback;
  final bool soundEffects;
  final int historySize;

  const CalculatorSettings({
    this.decimalPrecision = 6,
    this.isDegreesMode = true,
    this.hapticFeedback = true,
    this.soundEffects = false,
    this.historySize = 50,
  });

  /// Create a copy with updated values
  CalculatorSettings copyWith({
    int? decimalPrecision,
    bool? isDegreesMode,
    bool? hapticFeedback,
    bool? soundEffects,
    int? historySize,
  }) {
    return CalculatorSettings(
      decimalPrecision: decimalPrecision ?? this.decimalPrecision,
      isDegreesMode: isDegreesMode ?? this.isDegreesMode,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      soundEffects: soundEffects ?? this.soundEffects,
      historySize: historySize ?? this.historySize,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'decimalPrecision': decimalPrecision,
      'isDegreesMode': isDegreesMode,
      'hapticFeedback': hapticFeedback,
      'soundEffects': soundEffects,
      'historySize': historySize,
    };
  }

  /// Create from JSON
  factory CalculatorSettings.fromJson(Map<String, dynamic> json) {
    return CalculatorSettings(
      decimalPrecision: json['decimalPrecision'] as int? ?? 6,
      isDegreesMode: json['isDegreesMode'] as bool? ?? true,
      hapticFeedback: json['hapticFeedback'] as bool? ?? true,
      soundEffects: json['soundEffects'] as bool? ?? false,
      historySize: json['historySize'] as int? ?? 50,
    );
  }
}

