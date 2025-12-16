import 'package:flutter/material.dart';
import '../models/calculator_mode.dart';
import '../utils/constants.dart';

/// Widget for selecting calculator mode with smooth transitions
class ModeSelector extends StatelessWidget {
  final CalculatorMode selectedMode;
  final Function(CalculatorMode) onModeChanged;

  const ModeSelector({
    super.key,
    required this.selectedMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.screenPadding,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
        border: Border.all(
          color: colorScheme.secondary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: CalculatorMode.values.map((mode) {
          final isSelected = mode == selectedMode;
          return Expanded(
            child: AnimatedContainer(
              duration: AppConstants.modeSwitchDuration,
              curve: Curves.easeInOut,
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isSelected
                    ? colorScheme.tertiary.withOpacity(0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(
                  AppConstants.buttonBorderRadius - 4,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onModeChanged(mode),
                  borderRadius: BorderRadius.circular(
                    AppConstants.buttonBorderRadius - 4,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      mode.displayName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: AppConstants.buttonFontSize,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: isSelected
                            ? colorScheme.tertiary
                            : theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

