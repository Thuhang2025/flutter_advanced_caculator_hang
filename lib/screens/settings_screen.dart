import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/calculator_provider.dart';
import '../providers/history_provider.dart';
import '../models/angle_mode.dart';
import '../utils/constants.dart';
import '../services/storage_service.dart';

/// Settings screen for app configuration
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _hapticFeedback = true;
  bool _soundEffects = false;
  int _historySize = AppConstants.defaultHistorySize;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  /// Load current settings from storage
  Future<void> _loadSettings() async {
    final haptic = await StorageService.loadHapticFeedback();
    final sound = await StorageService.loadSoundEffects();
    final historySize = await StorageService.loadHistorySize();

    setState(() {
      _hapticFeedback = haptic;
      _soundEffects = sound;
      _historySize = historySize;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.screenPadding),
        children: [
          // Theme Section
          _buildSectionHeader('Appearance'),
          _buildThemeModeSection(),
          
          const SizedBox(height: 16),
          
          // Calculator Settings Section
          _buildSectionHeader('Calculator'),
          _buildDecimalPrecisionSection(),
          _buildAngleModeSection(),
          
          const SizedBox(height: 16),
          
          // Preferences Section
          _buildSectionHeader('Preferences'),
          _buildHapticFeedbackSwitch(),
          _buildSoundEffectsSwitch(),
          _buildHistorySizeSection(),
          
          const SizedBox(height: 16),
          
          // Data Management Section
          _buildSectionHeader('Data'),
          _buildClearHistoryButton(),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  /// Build section header
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Build theme mode selection
  Widget _buildThemeModeSection() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
            side: BorderSide(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              RadioListTile<ThemeMode>(
                title: const Text('Light'),
                value: ThemeMode.light,
                groupValue: themeProvider.themeMode,
                onChanged: (value) {
                  if (value != null) {
                    themeProvider.setThemeMode(value);
                  }
                },
              ),
              Divider(
                height: 1,
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Dark'),
                value: ThemeMode.dark,
                groupValue: themeProvider.themeMode,
                onChanged: (value) {
                  if (value != null) {
                    themeProvider.setThemeMode(value);
                  }
                },
              ),
              Divider(
                height: 1,
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
              ),
              RadioListTile<ThemeMode>(
                title: const Text('System Default'),
                value: ThemeMode.system,
                groupValue: themeProvider.themeMode,
                onChanged: (value) {
                  if (value != null) {
                    themeProvider.setThemeMode(value);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Build decimal precision slider
  Widget _buildDecimalPrecisionSection() {
    return Consumer<CalculatorProvider>(
      builder: (context, calculator, _) {
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
            side: BorderSide(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Decimal Precision',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    Text(
                      '${calculator.decimalPrecision}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Slider(
                  value: calculator.decimalPrecision.toDouble(),
                  min: AppConstants.minDecimalPrecision.toDouble(),
                  max: AppConstants.maxDecimalPrecision.toDouble(),
                  divisions: AppConstants.maxDecimalPrecision -
                      AppConstants.minDecimalPrecision,
                  label: calculator.decimalPrecision.toString(),
                  onChanged: (value) {
                    calculator.setDecimalPrecision(value.toInt());
                    StorageService.saveDecimalPrecision(value.toInt());
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${AppConstants.minDecimalPrecision}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      '${AppConstants.maxDecimalPrecision}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Build angle mode selection
  Widget _buildAngleModeSection() {
    return Consumer<CalculatorProvider>(
      builder: (context, calculator, _) {
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
            side: BorderSide(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              RadioListTile<AngleMode>(
                title: const Text('Degrees (DEG)'),
                subtitle: const Text('0° - 360°'),
                value: AngleMode.degrees,
                groupValue: calculator.angleMode,
                onChanged: (value) {
                  if (value != null) {
                    calculator.setAngleMode(value);
                    StorageService.saveAngleMode(value);
                  }
                },
              ),
              Divider(
                height: 1,
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
              ),
              RadioListTile<AngleMode>(
                title: const Text('Radians (RAD)'),
                subtitle: const Text('0 - 2π'),
                value: AngleMode.radians,
                groupValue: calculator.angleMode,
                onChanged: (value) {
                  if (value != null) {
                    calculator.setAngleMode(value);
                    StorageService.saveAngleMode(value);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Build haptic feedback switch
  Widget _buildHapticFeedbackSwitch() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
        side: BorderSide(
          color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: SwitchListTile(
        title: const Text('Haptic Feedback'),
        subtitle: const Text('Vibrate on button press'),
        value: _hapticFeedback,
        onChanged: (value) {
          setState(() {
            _hapticFeedback = value;
          });
          StorageService.saveHapticFeedback(value);
        },
      ),
    );
  }

  /// Build sound effects switch
  Widget _buildSoundEffectsSwitch() {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(top: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
        side: BorderSide(
          color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: SwitchListTile(
        title: const Text('Sound Effects'),
        subtitle: const Text('Play sounds on button press'),
        value: _soundEffects,
        onChanged: (value) {
          setState(() {
            _soundEffects = value;
          });
          StorageService.saveSoundEffects(value);
        },
      ),
    );
  }

  /// Build history size selector
  Widget _buildHistorySizeSection() {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(top: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
        side: BorderSide(
          color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'History Size',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Maximum calculations to keep',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  Text(
                    '$_historySize',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                ],
              ),
            ),
            Wrap(
              spacing: 8,
              children: AppConstants.historySizeOptions.map((size) {
                final isSelected = _historySize == size;
                return ChoiceChip(
                  label: Text('$size'),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _historySize = size;
                      });
                      final historyProvider = Provider.of<HistoryProvider>(
                        context,
                        listen: false,
                      );
                      historyProvider.setMaxHistorySize(size);
                      StorageService.saveHistorySize(size);
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  /// Build clear history button
  Widget _buildClearHistoryButton() {
    return Consumer<HistoryProvider>(
      builder: (context, historyProvider, _) {
        final hasHistory = historyProvider.hasHistory;
        
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
            side: BorderSide(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: ListTile(
            leading: Icon(
              Icons.delete_sweep,
              color: hasHistory ? Colors.red : Colors.grey,
            ),
            title: Text(
              'Clear All History',
              style: TextStyle(
                color: hasHistory ? null : Colors.grey,
              ),
            ),
            subtitle: Text(
              hasHistory
                  ? '${historyProvider.historyCount} calculation(s)'
                  : 'No history to clear',
            ),
            enabled: hasHistory,
            onTap: hasHistory
                ? () => _showClearHistoryDialog(context, historyProvider)
                : null,
            trailing: hasHistory
                ? const Icon(Icons.chevron_right)
                : null,
          ),
        );
      },
    );
  }

  /// Show confirmation dialog for clearing history
  void _showClearHistoryDialog(
    BuildContext context,
    HistoryProvider historyProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All History?'),
        content: Text(
          'This will permanently delete all ${historyProvider.historyCount} calculation(s) from history. This action cannot be undone.',
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
