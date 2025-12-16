import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/constants.dart';

/// Custom calculator button with animations and haptic feedback
class CalculatorButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isOperator;
  final bool isSpecial;
  final bool enableHapticFeedback;

  const CalculatorButton({
    super.key,
    required this.label,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.isOperator = false,
    this.isSpecial = false,
    this.enableHapticFeedback = true,
  });

  @override
  State<CalculatorButton> createState() => _CalculatorButtonState();
}

class _CalculatorButtonState extends State<CalculatorButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppConstants.buttonPressDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.onPressed == null) return;

    // Haptic feedback
    if (widget.enableHapticFeedback) {
      HapticFeedback.lightImpact();
    }

    // Animation
    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    // Execute callback
    widget.onPressed?.call();
  }

  Color _getBackgroundColor(BuildContext context) {
    if (widget.backgroundColor != null) {
      return widget.backgroundColor!;
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (widget.isSpecial) {
      return colorScheme.tertiary.withOpacity(0.2);
    } else if (widget.isOperator) {
      return colorScheme.secondary.withOpacity(0.3);
    } else {
      return colorScheme.surface;
    }
  }

  Color _getTextColor(BuildContext context) {
    if (widget.textColor != null) {
      return widget.textColor!;
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (widget.isSpecial) {
      return colorScheme.tertiary;
    } else if (widget.isOperator) {
      return colorScheme.secondary;
    } else {
      return theme.textTheme.bodyLarge?.color ?? Colors.black87;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onPressed != null ? _handleTap : null,
          borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
          child: Container(
            decoration: BoxDecoration(
              color: _getBackgroundColor(context),
              borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
              border: Border.all(
                color: _getBackgroundColor(context).withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                widget.label,
                style: TextStyle(
                  fontSize: AppConstants.buttonFontSize,
                  fontWeight: widget.isOperator || widget.isSpecial
                      ? FontWeight.w600
                      : FontWeight.normal,
                  color: _getTextColor(context),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

