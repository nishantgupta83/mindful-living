import 'package:flutter/material.dart';
import '../../../../shared/widgets/breathing_timer.dart';
import '../../../../core/constants/app_colors.dart';

/// Full-screen breathing exercise page
/// Provides guided breathing exercises with beautiful animations
class BreathingExercisePage extends StatefulWidget {
  const BreathingExercisePage({super.key});

  @override
  State<BreathingExercisePage> createState() => _BreathingExercisePageState();
}

class _BreathingExercisePageState extends State<BreathingExercisePage> {
  BreathingPattern _selectedPattern = BreathingPattern.fourSevenEight;
  bool _showTimer = false;
  int? _targetCycles;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Breathing Exercises'),
        backgroundColor: AppColors.lavender.withValues(alpha: 0.1),
        elevation: 0,
        actions: [
          if (_showTimer)
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                _showPatternInfo(context);
              },
            ),
        ],
      ),
      body: _showTimer
          ? BreathingTimer(
              pattern: _selectedPattern,
              targetCycles: _targetCycles,
              enableHaptic: true,
              enableVoiceGuidance: false,
              onComplete: () {
                _showCompletionDialog();
              },
            )
          : _buildPatternSelection(),
    );
  }

  Widget _buildPatternSelection() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.lavender.withValues(alpha: 0.2),
                  AppColors.cream,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.air,
                  size: 64,
                  color: AppColors.deepLavender,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Find Your Calm',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: AppColors.deepLavender,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose a breathing pattern to begin your practice',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.softCharcoal,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Pattern selector
          BreathingPatternSelector(
            selectedPattern: _selectedPattern,
            onPatternChanged: (pattern) {
              setState(() {
                _selectedPattern = pattern;
              });
            },
          ),

          const SizedBox(height: 24),

          // Cycle selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Number of cycles',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.deepLavender,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildCycleChip(null, 'Continuous'),
                    _buildCycleChip(3, '3 cycles'),
                    _buildCycleChip(5, '5 cycles'),
                    _buildCycleChip(10, '10 cycles'),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Start button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _showTimer = true;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.deepLavender,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
              child: const Text(
                'Begin Practice',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildCycleChip(int? cycles, String label) {
    final isSelected = _targetCycles == cycles;

    return FilterChip(
      selected: isSelected,
      label: Text(label),
      onSelected: (selected) {
        setState(() {
          _targetCycles = cycles;
        });
      },
      selectedColor: AppColors.lavender.withValues(alpha: 0.3),
      checkmarkColor: AppColors.deepLavender,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.deepLavender : AppColors.softCharcoal,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
      ),
    );
  }

  void _showPatternInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_selectedPattern.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_selectedPattern.description),
            const SizedBox(height: 16),
            _buildPatternDetail('Inhale', _selectedPattern.inhale),
            if (_selectedPattern.hold > 0)
              _buildPatternDetail('Hold', _selectedPattern.hold),
            _buildPatternDetail('Exhale', _selectedPattern.exhale),
            if (_selectedPattern.holdAfterExhale > 0)
              _buildPatternDetail('Hold', _selectedPattern.holdAfterExhale),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildPatternDetail(String label, int seconds) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Text('$seconds seconds'),
        ],
      ),
    );
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Practice Complete! 🎉'),
        content: const Text(
          'You\'ve completed your breathing practice. How do you feel?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _showTimer = false;
              });
            },
            child: const Text('Done'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
}
