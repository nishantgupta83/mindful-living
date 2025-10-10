import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';

/// Breathing patterns for guided breathing exercises
enum BreathingPattern {
  fourSevenEight(
    name: '4-7-8 Breathing',
    description: 'Relaxing breath (Inhale 4s, Hold 7s, Exhale 8s)',
    inhale: 4,
    hold: 7,
    exhale: 8,
    holdAfterExhale: 0,
  ),
  boxBreathing(
    name: 'Box Breathing',
    description: 'Focus and calm (4-4-4-4)',
    inhale: 4,
    hold: 4,
    exhale: 4,
    holdAfterExhale: 4,
  ),
  deepCalm(
    name: 'Deep Calm',
    description: 'Deep relaxation (6-3-6-3)',
    inhale: 6,
    hold: 3,
    exhale: 6,
    holdAfterExhale: 3,
  ),
  quickRelax(
    name: 'Quick Relax',
    description: 'Fast stress relief (3-3-3)',
    inhale: 3,
    hold: 3,
    exhale: 3,
    holdAfterExhale: 0,
  ),
  resonant(
    name: 'Resonant Breathing',
    description: 'Heart coherence (5-5)',
    inhale: 5,
    hold: 0,
    exhale: 5,
    holdAfterExhale: 0,
  );

  const BreathingPattern({
    required this.name,
    required this.description,
    required this.inhale,
    required this.hold,
    required this.exhale,
    required this.holdAfterExhale,
  });

  final String name;
  final String description;
  final int inhale;
  final int hold;
  final int exhale;
  final int holdAfterExhale;

  int get totalDuration => inhale + hold + exhale + holdAfterExhale;
}

/// Breathing phase during the exercise
enum BreathingPhase {
  inhale,
  hold,
  exhale,
  holdAfterExhale,
}

/// Circular breathing timer with expanding/contracting animation
/// Provides guided breathing exercises with haptic feedback
class BreathingTimer extends StatefulWidget {
  final BreathingPattern pattern;
  final VoidCallback? onComplete;
  final bool enableHaptic;
  final bool enableVoiceGuidance;
  final int? targetCycles;
  final List<Color>? gradientColors;

  const BreathingTimer({
    super.key,
    this.pattern = BreathingPattern.fourSevenEight,
    this.onComplete,
    this.enableHaptic = true,
    this.enableVoiceGuidance = false,
    this.targetCycles,
    this.gradientColors,
  });

  @override
  State<BreathingTimer> createState() => _BreathingTimerState();
}

class _BreathingTimerState extends State<BreathingTimer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _breathAnimation;

  BreathingPhase _currentPhase = BreathingPhase.inhale;
  int _currentCycle = 0;
  int _phaseSecondsRemaining = 0;
  bool _isActive = false;
  bool _animationsEnabled = true;

  @override
  void initState() {
    super.initState();

    final pattern = widget.pattern;
    _controller = AnimationController(
      duration: Duration(seconds: pattern.totalDuration),
      vsync: this,
    );

    _breathAnimation = TweenSequence<double>([
      // Inhale: expand from 0.6 to 1.0
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.6, end: 1.0).chain(
          CurveTween(curve: Curves.easeInOut),
        ),
        weight: pattern.inhale.toDouble(),
      ),
      // Hold: stay at 1.0
      if (pattern.hold > 0)
        TweenSequenceItem(
          tween: ConstantTween<double>(1.0),
          weight: pattern.hold.toDouble(),
        ),
      // Exhale: contract from 1.0 to 0.6
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.6).chain(
          CurveTween(curve: Curves.easeInOut),
        ),
        weight: pattern.exhale.toDouble(),
      ),
      // Hold after exhale: stay at 0.6
      if (pattern.holdAfterExhale > 0)
        TweenSequenceItem(
          tween: ConstantTween<double>(0.6),
          weight: pattern.holdAfterExhale.toDouble(),
        ),
    ]).animate(_controller);

    _controller.addListener(_onAnimationTick);
    _controller.addStatusListener(_onAnimationStatus);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Check for reduced motion preference
    final mediaQuery = MediaQuery.maybeOf(context);
    _animationsEnabled = mediaQuery?.disableAnimations == false;
  }

  void _onAnimationTick() {
    final elapsed = _controller.value * widget.pattern.totalDuration;
    final pattern = widget.pattern;

    BreathingPhase newPhase;
    int secondsRemaining;

    if (elapsed < pattern.inhale) {
      newPhase = BreathingPhase.inhale;
      secondsRemaining = pattern.inhale - elapsed.floor();
    } else if (elapsed < pattern.inhale + pattern.hold) {
      newPhase = BreathingPhase.hold;
      secondsRemaining = (pattern.inhale + pattern.hold) - elapsed.floor();
    } else if (elapsed < pattern.inhale + pattern.hold + pattern.exhale) {
      newPhase = BreathingPhase.exhale;
      secondsRemaining = (pattern.inhale + pattern.hold + pattern.exhale) - elapsed.floor();
    } else {
      newPhase = BreathingPhase.holdAfterExhale;
      secondsRemaining = pattern.totalDuration - elapsed.floor();
    }

    if (newPhase != _currentPhase) {
      setState(() {
        _currentPhase = newPhase;
      });
      _triggerPhaseChange();
    }

    if (secondsRemaining != _phaseSecondsRemaining) {
      setState(() {
        _phaseSecondsRemaining = secondsRemaining;
      });
    }
  }

  void _onAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _currentCycle++;

      if (widget.targetCycles != null && _currentCycle >= widget.targetCycles!) {
        _stop();
        widget.onComplete?.call();
      } else {
        _controller.forward(from: 0);
      }
    }
  }

  void _triggerPhaseChange() {
    if (widget.enableHaptic) {
      HapticFeedback.selectionClick();
    }

    // TODO: Add voice guidance here if enabled
    // if (widget.enableVoiceGuidance) {
    //   _speakPhase(_currentPhase);
    // }
  }

  void _start() {
    if (!mounted) return;

    setState(() {
      _isActive = true;
      _currentCycle = 0;
      _currentPhase = BreathingPhase.inhale;
    });

    if (_animationsEnabled) {
      _controller.forward(from: 0);
    }
  }

  void _pause() {
    if (!mounted) return;

    setState(() {
      _isActive = false;
    });
    _controller.stop();
  }

  void _resume() {
    if (!mounted) return;

    setState(() {
      _isActive = true;
    });

    if (_animationsEnabled) {
      _controller.forward();
    }
  }

  void _stop() {
    if (!mounted) return;

    setState(() {
      _isActive = false;
      _currentCycle = 0;
    });
    _controller.stop();
    _controller.reset();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getPhaseLabel(BreathingPhase phase) {
    switch (phase) {
      case BreathingPhase.inhale:
        return 'Breathe In';
      case BreathingPhase.hold:
        return 'Hold';
      case BreathingPhase.exhale:
        return 'Breathe Out';
      case BreathingPhase.holdAfterExhale:
        return 'Hold';
    }
  }

  Color _getPhaseColor(BreathingPhase phase) {
    switch (phase) {
      case BreathingPhase.inhale:
        return AppColors.skyBlue;
      case BreathingPhase.hold:
        return AppColors.lavender;
      case BreathingPhase.exhale:
        return AppColors.mintGreen;
      case BreathingPhase.holdAfterExhale:
        return AppColors.peach;
    }
  }

  @override
  Widget build(BuildContext context) {
    final gradientColors = widget.gradientColors ?? [
      AppColors.lavender.withValues(alpha: 0.3),
      AppColors.cream,
    ];

    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: gradientColors,
          center: Alignment.center,
          radius: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Pattern info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Text(
                  widget.pattern.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: AppColors.deepLavender,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.pattern.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.softCharcoal,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 48),

          // Breathing circle animation
          SizedBox(
            height: 300,
            width: 300,
            child: AnimatedBuilder(
              animation: _breathAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: BreathingCirclePainter(
                    progress: _animationsEnabled ? _breathAnimation.value : 0.8,
                    phase: _currentPhase,
                    phaseColor: _getPhaseColor(_currentPhase),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Phase label
                        Text(
                          _getPhaseLabel(_currentPhase),
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            color: _getPhaseColor(_currentPhase),
                            letterSpacing: 1.0,
                          ),
                        ),

                        if (_isActive) ...[
                          const SizedBox(height: 8),
                          // Countdown
                          Text(
                            '$_phaseSecondsRemaining',
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w300,
                              color: AppColors.deepLavender,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 48),

          // Cycle counter
          if (widget.targetCycles != null && _isActive)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                'Cycle ${_currentCycle + 1} of ${widget.targetCycles}',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.softCharcoal,
                ),
              ),
            ),

          // Control buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!_isActive)
                  _buildControlButton(
                    icon: Icons.play_arrow,
                    label: 'Start',
                    onPressed: _start,
                    isPrimary: true,
                  )
                else ...[
                  _buildControlButton(
                    icon: Icons.pause,
                    label: 'Pause',
                    onPressed: _pause,
                  ),
                  const SizedBox(width: 16),
                  _buildControlButton(
                    icon: Icons.stop,
                    label: 'Stop',
                    onPressed: _stop,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isPrimary = false,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? AppColors.deepLavender : AppColors.mistyWhite,
        foregroundColor: isPrimary ? Colors.white : AppColors.deepLavender,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: isPrimary ? 4 : 2,
      ),
    );
  }
}

/// Custom painter for the breathing circle animation
class BreathingCirclePainter extends CustomPainter {
  final double progress;
  final BreathingPhase phase;
  final Color phaseColor;

  BreathingCirclePainter({
    required this.progress,
    required this.phase,
    required this.phaseColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2 * 0.7;
    final currentRadius = maxRadius * progress;

    // Draw outer glow circles
    for (int i = 3; i >= 0; i--) {
      final glowPaint = Paint()
        ..color = phaseColor.withValues(alpha: 0.05 * (4 - i))
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        center,
        currentRadius + (i * 8),
        glowPaint,
      );
    }

    // Draw main circle with gradient
    final gradientPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          phaseColor.withValues(alpha: 0.4),
          phaseColor.withValues(alpha: 0.1),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: currentRadius))
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, currentRadius, gradientPaint);

    // Draw border
    final borderPaint = Paint()
      ..color = phaseColor.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(center, currentRadius, borderPaint);

    // Draw particle effects around the circle
    _drawParticles(canvas, center, currentRadius);
  }

  void _drawParticles(Canvas canvas, Offset center, double radius) {
    const particleCount = 12;
    final particlePaint = Paint()
      ..color = phaseColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < particleCount; i++) {
      final angle = (i / particleCount) * 2 * math.pi;
      final particleRadius = radius + 20 + (progress * 10);

      final x = center.dx + particleRadius * math.cos(angle);
      final y = center.dy + particleRadius * math.sin(angle);

      canvas.drawCircle(
        Offset(x, y),
        3 * progress,
        particlePaint,
      );
    }
  }

  @override
  bool shouldRepaint(BreathingCirclePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.phase != phase ||
        oldDelegate.phaseColor != phaseColor;
  }
}

/// Compact breathing pattern selector
class BreathingPatternSelector extends StatelessWidget {
  final BreathingPattern selectedPattern;
  final ValueChanged<BreathingPattern> onPatternChanged;

  const BreathingPatternSelector({
    super.key,
    required this.selectedPattern,
    required this.onPatternChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            'Choose a breathing pattern',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.deepLavender,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: BreathingPattern.values.length,
          itemBuilder: (context, index) {
            final pattern = BreathingPattern.values[index];
            final isSelected = pattern == selectedPattern;

            return ListTile(
              selected: isSelected,
              selectedTileColor: AppColors.lavender.withValues(alpha: 0.1),
              leading: Icon(
                Icons.air,
                color: isSelected ? AppColors.deepLavender : AppColors.softCharcoal,
              ),
              title: Text(
                pattern.name,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? AppColors.deepLavender : AppColors.deepCharcoal,
                ),
              ),
              subtitle: Text(
                pattern.description,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.softCharcoal,
                ),
              ),
              trailing: isSelected
                  ? const Icon(Icons.check_circle, color: AppColors.deepLavender)
                  : null,
              onTap: () {
                HapticFeedback.lightImpact();
                onPatternChanged(pattern);
              },
            );
          },
        ),
      ],
    );
  }
}
