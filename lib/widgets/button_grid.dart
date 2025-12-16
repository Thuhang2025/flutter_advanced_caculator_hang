import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/calculator_mode.dart';
import '../models/base_mode.dart';
import '../providers/calculator_provider.dart';
import '../utils/constants.dart';
import 'calculator_button.dart';

/// Grid of calculator buttons that changes layout based on mode
class ButtonGrid extends StatelessWidget {
  final bool enableHapticFeedback;

  const ButtonGrid({
    super.key,
    this.enableHapticFeedback = true,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CalculatorProvider>(
      builder: (context, calculator, _) {
        switch (calculator.mode) {
          case CalculatorMode.basic:
            return _buildBasicGrid(context, calculator);
          case CalculatorMode.scientific:
            return _buildScientificGrid(context, calculator);
          case CalculatorMode.programmer:
            return _buildProgrammerGrid(context, calculator);
        }
      },
    );
  }

  /// Build basic mode button grid (4×5)
  Widget _buildBasicGrid(BuildContext context, CalculatorProvider calculator) {
    final buttons = [
      ['C', 'CE', '%', '÷'],
      ['7', '8', '9', '×'],
      ['4', '5', '6', '-'],
      ['1', '2', '3', '+'],
      ['±', '0', '.', '='],
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.screenPadding),
      child: Column(
        children: buttons.map((row) {
          return Expanded(
            child: Row(
              children: row.map((label) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.buttonSpacing / 2),
                    child: CalculatorButton(
                      label: label,
                      isOperator: _isOperator(label),
                      isSpecial: _isSpecial(label),
                      enableHapticFeedback: enableHapticFeedback,
                      onPressed: () => _handleButtonPress(calculator, label),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Build scientific mode button grid (6×6)
  Widget _buildScientificGrid(BuildContext context, CalculatorProvider calculator) {
    final buttons = [
      ['2nd', 'sin', 'cos', 'tan', 'ln', 'log'],
      ['x²', '√', 'x^y', '(', ')', '÷'],
      ['MC', '7', '8', '9', 'C', '×'],
      ['MR', '4', '5', '6', 'CE', '-'],
      ['M+', '1', '2', '3', '%', '+'],
      ['M-', '±', '0', '.', 'π', '='],
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.screenPadding),
      child: Column(
        children: buttons.map((row) {
          return Expanded(
            child: Row(
              children: row.map((label) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.buttonSpacing / 2),
                    child: CalculatorButton(
                      label: label,
                      isOperator: _isOperator(label),
                      isSpecial: _isSpecial(label) || _isMemoryFunction(label),
                      enableHapticFeedback: enableHapticFeedback,
                      onPressed: () => _handleScientificButtonPress(calculator, label),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Build programmer mode button grid
  Widget _buildProgrammerGrid(BuildContext context, CalculatorProvider calculator) {
    // Button layout for programmer mode
    // Row 1: Base buttons (HEX, DEC, OCT, BIN)
    // Row 2: Bitwise operations (AND, OR, XOR, NOT)
    // Row 3: Number pad (A-F, 0-9)
    // Row 4-5: Standard operations and controls

    final baseButtons = ['HEX', 'DEC', 'OCT', 'BIN'];
    final bitwiseButtons = ['AND', 'OR', 'XOR', 'NOT'];
    final hexRow1 = ['A', 'B', 'C', 'DEL'];
    final hexRow2 = ['D', 'E', 'F', 'C'];
    final numberRow1 = ['7', '8', '9', '/'];
    final numberRow2 = ['4', '5', '6', '*'];
    final numberRow3 = ['1', '2', '3', '-'];
    final numberRow4 = ['0', '(', ')', '+'];
    final bottomRow = ['<<', '>>', '=', '=']; // Last '=' is placeholder

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.screenPadding),
      child: Column(
        children: [
          // Base mode buttons
          Expanded(
            child: Row(
              children: baseButtons.map((label) {
                final isSelected = _isBaseButtonSelected(label, calculator.baseMode);
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.buttonSpacing / 2),
                    child: CalculatorButton(
                      label: label,
                      isSpecial: isSelected,
                      backgroundColor: isSelected
                          ? Theme.of(context).colorScheme.tertiary.withOpacity(0.3)
                          : null,
                      textColor: isSelected
                          ? Theme.of(context).colorScheme.tertiary
                          : null,
                      enableHapticFeedback: enableHapticFeedback,
                      onPressed: () => _handleProgrammerButtonPress(calculator, label),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Bitwise operations
          Expanded(
            child: Row(
              children: bitwiseButtons.map((label) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.buttonSpacing / 2),
                    child: CalculatorButton(
                      label: label,
                      isOperator: true,
                      enableHapticFeedback: enableHapticFeedback,
                      onPressed: () => _handleProgrammerButtonPress(calculator, label),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Hex row 1 (A, B, C, DEL) - only show A-F if in HEX mode
          if (calculator.baseMode == BaseMode.hexadecimal)
            Expanded(
              child: Row(
                children: hexRow1.map((label) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.buttonSpacing / 2),
                      child: CalculatorButton(
                        label: label,
                        isSpecial: label == 'DEL',
                        enableHapticFeedback: enableHapticFeedback,
                        onPressed: () => _handleProgrammerButtonPress(calculator, label),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

          // Hex row 2 (D, E, F, C) - only show if in HEX mode
          if (calculator.baseMode == BaseMode.hexadecimal)
            Expanded(
              child: Row(
                children: hexRow2.map((label) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.buttonSpacing / 2),
                      child: CalculatorButton(
                        label: label,
                        isSpecial: label == 'C',
                        enableHapticFeedback: enableHapticFeedback,
                        onPressed: () => _handleProgrammerButtonPress(calculator, label),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

          // Number rows
          Expanded(
            child: Row(
              children: numberRow1.map((label) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.buttonSpacing / 2),
                    child: CalculatorButton(
                      label: label,
                      isOperator: ['/', '*', '-', '+'].contains(label),
                      isSpecial: label == 'C' || label == 'DEL',
                      enableHapticFeedback: enableHapticFeedback,
                      onPressed: () => _handleProgrammerButtonPress(calculator, label),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          Expanded(
            child: Row(
              children: numberRow2.map((label) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.buttonSpacing / 2),
                    child: CalculatorButton(
                      label: label,
                      isOperator: ['/', '*', '-', '+'].contains(label),
                      enableHapticFeedback: enableHapticFeedback,
                      onPressed: () => _handleProgrammerButtonPress(calculator, label),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          Expanded(
            child: Row(
              children: numberRow3.map((label) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.buttonSpacing / 2),
                    child: CalculatorButton(
                      label: label,
                      isOperator: ['/', '*', '-', '+'].contains(label),
                      enableHapticFeedback: enableHapticFeedback,
                      onPressed: () => _handleProgrammerButtonPress(calculator, label),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          Expanded(
            child: Row(
              children: numberRow4.map((label) {
                final isShift = label == '<<' || label == '>>';
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.buttonSpacing / 2),
                    child: CalculatorButton(
                      label: label,
                      isOperator: ['/', '*', '-', '+', '='].contains(label),
                      isSpecial: isShift,
                      enableHapticFeedback: enableHapticFeedback,
                      onPressed: () => _handleProgrammerButtonPress(calculator, label),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Bottom row with shifts and equals
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.buttonSpacing / 2),
                    child: CalculatorButton(
                      label: '<<',
                      isSpecial: true,
                      enableHapticFeedback: enableHapticFeedback,
                      onPressed: () => _handleProgrammerButtonPress(calculator, '<<'),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.buttonSpacing / 2),
                    child: CalculatorButton(
                      label: '>>',
                      isSpecial: true,
                      enableHapticFeedback: enableHapticFeedback,
                      onPressed: () => _handleProgrammerButtonPress(calculator, '>>'),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.buttonSpacing / 2),
                    child: CalculatorButton(
                      label: '=',
                      isOperator: true,
                      backgroundColor: Theme.of(context).colorScheme.tertiary.withOpacity(0.3),
                      textColor: Theme.of(context).colorScheme.tertiary,
                      enableHapticFeedback: enableHapticFeedback,
                      onPressed: () => _handleProgrammerButtonPress(calculator, '='),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Handle button press for basic mode
  void _handleButtonPress(CalculatorProvider calculator, String label) {
    // Handle special memory functions
    if (label == 'MC') {
      calculator.memoryClear();
      return;
    }
    if (label == 'MR') {
      calculator.memoryRecall();
      return;
    }
    if (label == 'M+') {
      calculator.memoryAdd();
      return;
    }
    if (label == 'M-') {
      calculator.memorySubtract();
      return;
    }

    // Handle other buttons
    calculator.addToExpression(label);
  }

  /// Handle button press for scientific mode
  void _handleScientificButtonPress(CalculatorProvider calculator, String label) {
    // Handle 2nd function key (placeholder for now)
    if (label == '2nd') {
      // TODO: Implement 2nd function toggle
      return;
    }

    // Handle memory functions
    if (label == 'MC') {
      calculator.memoryClear();
      return;
    }
    if (label == 'MR') {
      calculator.memoryRecall();
      return;
    }
    if (label == 'M+') {
      calculator.memoryAdd();
      return;
    }
    if (label == 'M-') {
      calculator.memorySubtract();
      return;
    }

    // Handle scientific functions
    if (label == 'sin' || label == 'cos' || label == 'tan') {
      calculator.addToExpression(label);
      return;
    }

    if (label == 'ln' || label == 'log') {
      calculator.addToExpression(label);
      return;
    }

    // Handle power operations
    if (label == 'x²' || label == 'x³' || label == 'x^y') {
      calculator.addToExpression(label);
      return;
    }

    // Handle square root
    if (label == '√') {
      calculator.addToExpression(label);
      return;
    }

    // Handle constants
    if (label == 'π') {
      calculator.addToExpression('π');
      return;
    }

    // Handle other buttons normally
    calculator.addToExpression(label);
  }

  /// Check if label is an operator
  bool _isOperator(String label) {
    return ['+', '-', '×', '÷', '=', '^', '%'].contains(label);
  }

  /// Check if label is a special button
  bool _isSpecial(String label) {
    return ['C', 'CE', '±', '2nd'].contains(label) || 
           label.contains('sin') ||
           label.contains('cos') ||
           label.contains('tan') ||
           label.contains('log') ||
           label == 'ln' ||
           label == '√' ||
           label == 'x²' ||
           label == 'x³' ||
           label == 'x^y';
  }

  /// Check if label is a memory function
  bool _isMemoryFunction(String label) {
    return ['MC', 'MR', 'M+', 'M-'].contains(label);
  }

  /// Handle button press for programmer mode
  void _handleProgrammerButtonPress(CalculatorProvider calculator, String label) {
    // Handle base switching
    if (label == 'HEX' || label == 'DEC' || label == 'OCT' || label == 'BIN') {
      calculator.addToExpression(label);
      return;
    }

    // Handle other buttons normally
    calculator.addToExpression(label);
  }

  /// Check if a base button is selected
  bool _isBaseButtonSelected(String label, BaseMode currentBase) {
    switch (label) {
      case 'HEX':
        return currentBase == BaseMode.hexadecimal;
      case 'DEC':
        return currentBase == BaseMode.decimal;
      case 'OCT':
        return currentBase == BaseMode.octal;
      case 'BIN':
        return currentBase == BaseMode.binary;
      default:
        return false;
    }
  }
}

