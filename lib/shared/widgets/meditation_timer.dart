import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';

/// Meditation session durations
enum MeditationDuration {
  fiveMin(5, 'Quick Session'),
  tenMin(10, 'Standard'),
  fifteenMin(15, 'Deep Practice'),
  twentyMin(20, 'Extended'),
  thirtyMin(30, 'Immersive'),
  custom(0, 'Custom');

  const MeditationDuration(this.minutes, this.label);
  final int minutes;
  final String label;
}

/// Meditation timer with countdown and ambient animations
class MeditationTimer extends StatefulWidget {
  final MeditationDuration duration;
  final int? customMinutes;
  final VoidCallback? onComplete;
  final bool enableIntervalBells;
  final int? bellIntervalMinutes;
  final bool enableHaptic;

  const MeditationTimer({
    super.key,
    this.duration = MeditationDuration.tenMin,
    this.customMinutes,
    this.onComplete,
    this.enableIntervalBells = true,
    this.bellIntervalMinutes = 5,
    this.enableHaptic = true,
  });

  @override
  State<MeditationTimer> createState() => _MeditationTimerState();
}

class _MeditationTimerState extends State<MeditationTimer>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  int _totalSeconds = 0;
  int _remainingSeconds = 0;
  bool _isActive = false;
  bool _isPaused = false;
  bool _animationsEnabled = true;

  @override
  void initState() {
    super.initState();

    final minutes = widget.duration == MeditationDuration.custom
        ? (widget.customMinutes ?? 10)
        : widget.duration.minutes;

    _totalSeconds = minutes * 60;
    _remainingSeconds = _totalSeconds;

    _progressController = AnimationController(
      duration: Duration(seconds: _totalSeconds),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _progressController.addListener(_onProgressTick);
    _progressController.addStatusListener(_onProgressStatus);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final mediaQuery = MediaQuery.maybeOf(context);
    _animationsEnabled = mediaQuery?.disableAnimations == false;

    if (_animationsEnabled && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    }
  }

  void _onProgressTick() {
    final elapsed = (_progressController.value * _totalSeconds).round();
    final remaining = _totalSeconds - elapsed;

    if (remaining != _remainingSeconds) {
      setState(() {
        _remainingSeconds = remaining;
      });

      // Interval bells
      if (widget.enableIntervalBells &&
          widget.bellIntervalMinutes != null &&
          remaining > 0 &&
          remaining % (widget.bellIntervalMinutes! * 60) == 0) {
        _triggerIntervalBell();
      }
    }
  }

  void _onProgressStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _complete();
    }
  }

  void _triggerIntervalBell() {
    if (widget.enableHaptic) {
      HapticFeedback.mediumImpact();
    }
    // TODO: Play bell sound
  }

  void _start() {
    if (!mounted) return;

    setState(() {
      _isActive = true;
      _isPaused = false;
    });

    if (_animationsEnabled) {
      _progressController.forward();
    }
  }

  void _pause() {
    if (!mounted) return;

    setState(() {
      _isPaused = true;
    });
    _progressController.stop();
  }

  void _resume() {
    if (!mounted) return;

    setState(() {
      _isPaused = false;
    });

    if (_animationsEnabled) {
      _progressController.forward();
    }
  }

  void _stop() {
    if (!mounted) return;

    setState(() {
      _isActive = false;
      _isPaused = false;
      _remainingSeconds = _totalSeconds;
    });
    _progressController.stop();
    _progressController.reset();
  }

  void _complete() {
    if (widget.enableHaptic) {
      HapticFeedback.heavyImpact();
    }
    setState(() {
      _isActive = false;
      _isPaused = false;
    });
    widget.onComplete?.call();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  double get _progress => _remainingSeconds / _totalSeconds;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            AppColors.lavender.withValues(alpha: 0.2),
            AppColors.skyBlue.withValues(alpha: 0.1),
            AppColors.cream,
          ],
          stops: const [0.0, 0.5, 1.0],
          radius: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Title
          const Text(
            'Meditation Session',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppColors.deepLavender,
            ),
          ),

          const SizedBox(height: 48),

          // Timer circle
          SizedBox(
            height: 320,
            width: 320,
            child: AnimatedBuilder(
              animation: Listenable.merge([_progressController, _pulseController]),
              builder: (context, child) {
                return Transform.scale(
                  scale: _animationsEnabled && _isActive && !_isPaused
                      ? _pulseAnimation.value
                      : 1.0,
                  child: CustomPaint(
                    painter: MeditationCirclePainter(
                      progress: _progress,
                      isActive: _isActive,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Time remaining
                          Text(
                            _formatTime(_remainingSeconds),
                            style: const TextStyle(
                              fontSize: 72,
                              fontWeight: FontWeight.w200,
                              color: AppColors.deepLavender,
                              letterSpacing: 2.0,
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Status
                          Text(
                            _isActive
                                ? (_isPaused ? 'Paused' : 'Meditating')
                                : 'Ready',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: AppColors.softCharcoal,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 48),

          // Interval info
          if (widget.enableIntervalBells && widget.bellIntervalMinutes != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_outlined,
                    size: 16,
                    color: AppColors.softCharcoal,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Bell every ${widget.bellIntervalMinutes} min',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.softCharcoal,
                    ),
                  ),
                ],
              ),
            ),

          // Controls
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _buildControls(),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    if (!_isActive) {
      return ElevatedButton.icon(
        onPressed: _start,
        icon: const Icon(Icons.play_arrow, size: 28),
        label: const Text(
          'Begin',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.deepLavender,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 4,
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Pause/Resume
        IconButton.filled(
          onPressed: _isPaused ? _resume : _pause,
          icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
          iconSize: 32,
          style: IconButton.styleFrom(
            backgroundColor: AppColors.deepLavender,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.all(20),
          ),
        ),

        const SizedBox(width: 24),

        // Stop
        IconButton.filled(
          onPressed: _stop,
          icon: const Icon(Icons.stop),
          iconSize: 32,
          style: IconButton.styleFrom(
            backgroundColor: AppColors.mistyWhite,
            foregroundColor: AppColors.deepLavender,
            padding: const EdgeInsets.all(20),
          ),
        ),
      ],
    );
  }
}

/// Custom painter for meditation circle
class MeditationCirclePainter extends CustomPainter {
  final double progress;
  final bool isActive;

  MeditationCirclePainter({
    required this.progress,
    required this.isActive,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 * 0.85;

    // Background circle
    final bgPaint = Paint()
      ..color = AppColors.mistyWhite
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    if (isActive) {
      final progressPaint = Paint()
        ..shader = SweepGradient(
          colors: [
            AppColors.lavender,
            AppColors.skyBlue,
            AppColors.mintGreen,
            AppColors.lavender,
          ],
          startAngle: -math.pi / 2,
          endAngle: 3 * math.pi / 2,
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round;

      final sweepAngle = 2 * math.pi * progress;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweepAngle,
        false,
        progressPaint,
      );
    }

    // Inner glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.lavender.withValues(alpha: 0.1),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 0.8))
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.8, glowPaint);

    // Ambient particles
    if (isActive) {
      _drawAmbientParticles(canvas, center, radius);
    }
  }

  void _drawAmbientParticles(Canvas canvas, Offset center, double radius) {
    const particleCount = 8;
    final particlePaint = Paint()
      ..color = AppColors.lavender.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < particleCount; i++) {
      final angle = (i / particleCount) * 2 * math.pi;
      final distance = radius * 1.1;

      final x = center.dx + distance * math.cos(angle);
      final y = center.dy + distance * math.sin(angle);

      canvas.drawCircle(Offset(x, y), 4, particlePaint);
    }
  }

  @override
  bool shouldRepaint(MeditationCirclePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isActive != isActive;
  }
}

/// Meditation session result
class MeditationResult {
  final int durationMinutes;
  final DateTime completedAt;
  final int? rating;

  MeditationResult({
    required this.durationMinutes,
    required this.completedAt,
    this.rating,
  });
}
