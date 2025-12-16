import 'package:flutter/material.dart';
import '../models/base_mode.dart';
import '../utils/constants.dart';

/// Widget for selecting number base in Programmer Mode
class BaseSelector extends StatelessWidget {
  final BaseMode selectedBase;
  final Function(BaseMode) onBaseChanged;

  const BaseSelector({
    super.key,
    required this.selectedBase,
    required this.onBaseChanged,
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
        children: BaseMode.values.map((base) {
          final isSelected = base == selectedBase;
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
                  onTap: () => onBaseChanged(base),
                  borderRadius: BorderRadius.circular(
                    AppConstants.buttonBorderRadius - 4,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      base.displayName,
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

