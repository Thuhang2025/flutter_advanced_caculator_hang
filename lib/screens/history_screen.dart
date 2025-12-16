import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/history_provider.dart';
import '../providers/calculator_provider.dart';
import '../models/calculation_history.dart';
import '../utils/constants.dart';

/// History screen for displaying calculation history
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculation History'),
        actions: [
          Consumer<HistoryProvider>(
            builder: (context, historyProvider, _) {
              if (!historyProvider.hasHistory) {
                return const SizedBox.shrink();
              }
              
              return IconButton(
                icon: const Icon(Icons.delete_sweep),
                onPressed: () => _showClearAllDialog(context, historyProvider),
                tooltip: 'Clear All History',
              );
            },
          ),
        ],
      ),
      body: Consumer<HistoryProvider>(
        builder: (context, historyProvider, _) {
          if (!historyProvider.hasHistory) {
            return _buildEmptyState(context);
          }

          final history = historyProvider.history.reversed.toList();

          return ListView.builder(
            padding: const EdgeInsets.all(AppConstants.screenPadding),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final entry = history[index];
              return _buildHistoryItem(context, entry, index, historyProvider);
            },
          );
        },
      ),
    );
  }

  /// Build empty state when no history exists
  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Calculation History',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your calculations will appear here',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  /// Build a single history item with swipe-to-dismiss
  Widget _buildHistoryItem(
    BuildContext context,
    CalculationHistory entry,
    int index,
    HistoryProvider historyProvider,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dismissible(
      key: Key('history_${entry.timestamp.millisecondsSinceEpoch}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
        ),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 28,
        ),
      ),
      confirmDismiss: (direction) async {
        // Ask for confirmation before deleting
        return await _showDeleteConfirmationDialog(context);
      },
      onDismissed: (direction) {
        // Find the actual index in the original list (reversed)
        final history = historyProvider.history;
        final actualIndex = history.length - 1 - index;
        historyProvider.removeHistoryEntry(actualIndex);
        
        // Show snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Calculation removed from history'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: AppConstants.buttonSpacing),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
          side: BorderSide(
            color: colorScheme.secondary.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: InkWell(
          onTap: () => _useCalculation(context, entry),
          borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Expression
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        entry.expression,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontSize: AppConstants.historyFontSize,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.right,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Result
                Text(
                  entry.result,
                  style: theme.textTheme.displayLarge?.copyWith(
                    fontSize: AppConstants.displayFontSize * 0.6,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.tertiary,
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 8),
                
                // Timestamp
                Text(
                  _formatTimestamp(entry.timestamp),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Format timestamp for display
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, yyyy').format(timestamp);
    }
  }

  /// Use calculation from history - load it into calculator
  void _useCalculation(BuildContext context, CalculationHistory entry) {
    final calculator = Provider.of<CalculatorProvider>(context, listen: false);
    
    // Set the result as the expression for continued calculation
    calculator.setExpression(entry.result);
    
    // Navigate back to calculator screen
    Navigator.pop(context);
    
    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Loaded: ${entry.result}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  /// Show confirmation dialog for deleting a single entry
  Future<bool> _showDeleteConfirmationDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Calculation?'),
        content: const Text('This calculation will be removed from history.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Show confirmation dialog for clearing all history
  void _showClearAllDialog(
    BuildContext context,
    HistoryProvider historyProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All History?'),
        content: Text(
          'This will permanently delete all ${historyProvider.historyCount} calculation(s) from history.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              historyProvider.clearHistory();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All history cleared'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
