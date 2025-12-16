import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/calculator_provider.dart';
import '../providers/history_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/display_area.dart';
import '../widgets/button_grid.dart';
import '../widgets/mode_selector.dart';
import '../widgets/base_selector.dart';
import '../services/storage_service.dart';
import '../models/base_mode.dart';
import '../models/calculator_mode.dart';
import '../models/angle_mode.dart';

/// Main calculator screen
class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String? _previousResult;
  bool _enableHapticFeedback = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _loadHapticFeedback();
  }

  /// Load haptic feedback setting
  Future<void> _loadHapticFeedback() async {
    final haptic = await StorageService.loadHapticFeedback();
    setState(() {
      _enableHapticFeedback = haptic;
    });
  }

  /// Load saved preferences into providers
  Future<void> _loadPreferences() async {
    final calculator = Provider.of<CalculatorProvider>(context, listen: false);
    
    // Load calculator mode
    final savedMode = await StorageService.loadCalculatorMode();
    calculator.toggleMode(savedMode);
    
    // Load angle mode
    final savedAngleMode = await StorageService.loadAngleMode();
    calculator.setAngleMode(savedAngleMode);
    
    // Load decimal precision
    final savedPrecision = await StorageService.loadDecimalPrecision();
    calculator.setDecimalPrecision(savedPrecision);
    
    // Load memory value
    final savedMemory = await StorageService.loadMemory();
    if (savedMemory != 0.0) {
      calculator.setMemory(savedMemory);
    }
  }

  /// Save preferences when they change
  Future<void> _savePreferences() async {
    final calculator = Provider.of<CalculatorProvider>(context, listen: false);
    
    await StorageService.saveCalculatorMode(calculator.mode);
    await StorageService.saveAngleMode(calculator.angleMode);
    await StorageService.saveDecimalPrecision(calculator.decimalPrecision);
    await StorageService.saveMemory(calculator.memory);
  }

  /// Listen to calculator changes and save history/results
  void _handleCalculationResult(String expression, String result, String error) {
    if (result.isNotEmpty && error.isEmpty) {
      final historyProvider = Provider.of<HistoryProvider>(context, listen: false);
      historyProvider.addToHistory(expression, result);
      _previousResult = result;
    }
    
    // Save preferences periodically
    _savePreferences();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Calculator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.pushNamed(context, '/history');
            },
            tooltip: 'History',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Consumer<CalculatorProvider>(
        builder: (context, calculator, _) {
          // Handle calculation results for history
          // Only process when there's a new result
          if (calculator.result.isNotEmpty && calculator.result != _previousResult) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _handleCalculationResult(
                calculator.expression,
                calculator.result,
                calculator.error,
              );
            });
          }

          return Column(
            children: [
              // Mode selector
              ModeSelector(
                selectedMode: calculator.mode,
                onModeChanged: (mode) {
                  calculator.toggleMode(mode);
                  _savePreferences();
                },
              ),

              // Base selector (only in Programmer Mode)
              if (calculator.mode == CalculatorMode.programmer) ...[
                const SizedBox(height: 8),
                BaseSelector(
                  selectedBase: calculator.baseMode,
                  onBaseChanged: (base) {
                    calculator.setBaseMode(base);
                    _savePreferences();
                  },
                ),
              ],

              const SizedBox(height: 8),

              // Display area
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onHorizontalDragEnd: (details) {
                    // Swipe right to delete last character
                    if (details.primaryVelocity != null && 
                        details.primaryVelocity! > 0) {
                      calculator.delete();
                    }
                  },
                  child: DisplayArea(
                    expression: calculator.expression,
                    result: calculator.result,
                    error: calculator.error,
                    hasMemory: calculator.hasMemory,
                    angleMode: calculator.angleMode.displayName,
                  ),
                ),
              ),

              // Button grid
              Expanded(
                flex: 5,
                child: ButtonGrid(
                  enableHapticFeedback: _enableHapticFeedback,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
