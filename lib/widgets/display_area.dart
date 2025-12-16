import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Display area for calculator showing expression, result, and errors
class DisplayArea extends StatelessWidget {
  final String expression;
  final String result;
  final String error;
  final bool hasMemory;
  final String angleMode;
  final VoidCallback? onSwipeRight;

  const DisplayArea({
    super.key,
    required this.expression,
    required this.result,
    required this.error,
    this.hasMemory = false,
    this.angleMode = 'DEG',
    this.onSwipeRight,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasError = error.isNotEmpty;
    final hasResult = result.isNotEmpty && !hasError;
    final hasExpression = expression.isNotEmpty;

    return SafeArea(
      minimum: const EdgeInsets.symmetric(
        horizontal: AppConstants.screenPadding,
        vertical: 8,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.symmetric(
          horizontal: AppConstants.screenPadding,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(AppConstants.displayBorderRadius),
          border: Border.all(
            color: hasError 
                ? Colors.red.withOpacity(0.3)
                : colorScheme.secondary.withOpacity(0.2),
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.max,
          children: [
            // Mode indicators row (fixed height)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (hasMemory)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: colorScheme.tertiary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'M',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.tertiary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.secondary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    angleMode,
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Error message (fixed height, doesn't scroll)
            if (hasError)
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 40),
                child: AnimatedOpacity(
                  opacity: hasError ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    reverse: true,
                    child: Text(
                      error,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ),
              ),
            
            // Expression display (expandable, scrollable)
            if (hasExpression && !hasError)
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  reverse: true,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      expression,
                      style: TextStyle(
                        fontSize: AppConstants.displayFontSize * 0.6,
                        color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
                        fontWeight: FontWeight.normal,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ),
              )
            else if (!hasError)
              // Empty space when no expression
              const Expanded(child: SizedBox()),
            
            const SizedBox(height: 8),
            
            // Result display (auto-scaled to fit width)
            if (hasResult)
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: FadeInText(
                  text: result,
                  style: TextStyle(
                    fontSize: AppConstants.displayFontSize,
                    fontWeight: FontWeight.w500,
                    color: theme.textTheme.displayLarge?.color,
                  ),
                ),
              )
            else if (hasExpression && !hasError)
              // Placeholder for result
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  '= ?',
                  style: TextStyle(
                    fontSize: AppConstants.displayFontSize * 0.7,
                    color: theme.textTheme.bodyLarge?.color?.withOpacity(0.5),
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ],
          ),
      ),
    );
  }
}

/// Widget that fades in text when it appears
class FadeInText extends StatefulWidget {
  final String text;
  final TextStyle? style;

  const FadeInText({
    super.key,
    required this.text,
    this.style,
  });

  @override
  State<FadeInText> createState() => _FadeInTextState();
}

class _FadeInTextState extends State<FadeInText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(FadeInText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Text(
        widget.text,
        style: widget.style,
        textAlign: TextAlign.right,
      ),
    );
  }
}
