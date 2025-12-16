/// Model for storing calculation history entries
class CalculationHistory {
  final String expression;
  final String result;
  final DateTime timestamp;

  const CalculationHistory({
    required this.expression,
    required this.result,
    required this.timestamp,
  });

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'expression': expression,
      'result': result,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Create from JSON
  factory CalculationHistory.fromJson(Map<String, dynamic> json) {
    return CalculationHistory(
      expression: json['expression'] as String,
      result: json['result'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  @override
  String toString() {
    return '$expression = $result';
  }
}

