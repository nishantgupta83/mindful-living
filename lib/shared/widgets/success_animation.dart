import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

/// Success checkmark animation
///
/// Displays an animated checkmark with a circular reveal effect.
/// Perfect for confirming actions like saving entries or completing tasks.
///
/// Usage:
/// ```dart
/// SuccessAnimation(
///   onComplete: () => Navigator.pop(context),
/// )
/// ```
class SuccessAnimation extends StatefulWidget {
  const SuccessAnimation({
    super.key,
    this.size = 120,
    this.color = const Color(0xFF7ED321),
    this.duration = const Duration(milliseconds: 600),
    this.onComplete,
  });

  final double size;
  final Color color;
  final Duration duration;
  final VoidCallback? onComplete;

  @override
  State<SuccessAnimation> createState() => _SuccessAnimationState();
}

class _SuccessAnimationState extends State<SuccessAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _checkAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    HapticFeedback.mediumImpact();
    _controller.forward().then((_) {
      widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.color.withValues(alpha: 0.4),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: CustomPaint(
              painter: _CheckmarkPainter(
                progress: _checkAnimation.value,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CheckmarkPainter extends CustomPainter {
  final double progress;
  final Color color;

  _CheckmarkPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.width * 0.08
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();

    // Checkmark coordinates (scaled to size)
    final p1 = Offset(size.width * 0.3, size.height * 0.5);
    final p2 = Offset(size.width * 0.45, size.height * 0.65);
    final p3 = Offset(size.width * 0.7, size.height * 0.35);

    if (progress < 0.5) {
      // Draw first segment
      final segmentProgress = progress * 2;
      path.moveTo(p1.dx, p1.dy);
      path.lineTo(
        p1.dx + (p2.dx - p1.dx) * segmentProgress,
        p1.dy + (p2.dy - p1.dy) * segmentProgress,
      );
    } else {
      // Draw both segments
      final segmentProgress = (progress - 0.5) * 2;
      path.moveTo(p1.dx, p1.dy);
      path.lineTo(p2.dx, p2.dy);
      path.lineTo(
        p2.dx + (p3.dx - p2.dx) * segmentProgress,
        p2.dy + (p3.dy - p2.dy) * segmentProgress,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CheckmarkPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Confetti particle for celebration animations
class _ConfettiParticle {
  Offset position;
  Offset velocity;
  double rotation;
  double rotationSpeed;
  Color color;
  double size;

  _ConfettiParticle({
    required this.position,
    required this.velocity,
    required this.rotation,
    required this.rotationSpeed,
    required this.color,
    required this.size,
  });

  void update(double dt) {
    position = Offset(
      position.dx + velocity.dx * dt,
      position.dy + velocity.dy * dt,
    );
    velocity = Offset(
      velocity.dx,
      velocity.dy + 400 * dt, // Gravity
    );
    rotation += rotationSpeed * dt;
  }
}

/// Confetti celebration animation
///
/// Displays colorful confetti particles that fall from the top.
/// Great for celebrating achievements, completed tasks, or milestones.
///
/// Usage:
/// ```dart
/// ConfettiCelebration(
///   particleCount: 50,
///   duration: Duration(seconds: 3),
/// )
/// ```
class ConfettiCelebration extends StatefulWidget {
  const ConfettiCelebration({
    super.key,
    this.particleCount = 50,
    this.duration = const Duration(seconds: 3),
  });

  final int particleCount;
  final Duration duration;

  @override
  State<ConfettiCelebration> createState() => _ConfettiCelebrationState();
}

class _ConfettiCelebrationState extends State<ConfettiCelebration>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_ConfettiParticle> _particles;
  final _random = math.Random();

  static const _colors = [
    Color(0xFFD8C7F5), // Lavender
    Color(0xFFB8E8D1), // Mint
    Color(0xFFFFD4B3), // Peach
    Color(0xFFC2DDF0), // Sky blue
    Color(0xFFE0CAFF), // Soft purple
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _particles = List.generate(widget.particleCount, (index) {
      return _ConfettiParticle(
        position: Offset(
          _random.nextDouble() * 400,
          -20 - _random.nextDouble() * 100,
        ),
        velocity: Offset(
          (_random.nextDouble() - 0.5) * 200,
          _random.nextDouble() * 200 + 100,
        ),
        rotation: _random.nextDouble() * math.pi * 2,
        rotationSpeed: (_random.nextDouble() - 0.5) * 10,
        color: _colors[_random.nextInt(_colors.length)],
        size: _random.nextDouble() * 10 + 5,
      );
    });

    HapticFeedback.heavyImpact();
    _controller.forward();
    _controller.addListener(_updateParticles);
  }

  void _updateParticles() {
    if (!mounted) return;
    setState(() {
      for (var particle in _particles) {
        particle.update(0.016); // ~60fps
      }
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_updateParticles);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _ConfettiPainter(
          particles: _particles,
          progress: _controller.value,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;

  _ConfettiPainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()
        ..color = particle.color.withValues(alpha: 1.0 - progress);

      canvas.save();
      canvas.translate(particle.position.dx, particle.position.dy);
      canvas.rotate(particle.rotation);

      // Draw rectangle confetti
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: particle.size,
          height: particle.size * 1.5,
        ),
        paint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) => true;
}

/// Success overlay that combines checkmark and confetti
class SuccessOverlay extends StatelessWidget {
  const SuccessOverlay({
    super.key,
    this.message = 'Success!',
    this.onComplete,
    this.showConfetti = true,
  });

  final String message;
  final VoidCallback? onComplete;
  final bool showConfetti;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: Stack(
        children: [
          if (showConfetti)
            const Positioned.fill(
              child: ConfettiCelebration(),
            ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SuccessAnimation(
                  onComplete: onComplete,
                ),
                const SizedBox(height: 24),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Show success overlay as a dialog
  static Future<void> show(
    BuildContext context, {
    String message = 'Success!',
    bool showConfetti = true,
    Duration displayDuration = const Duration(seconds: 2),
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (context) => SuccessOverlay(
        message: message,
        showConfetti: showConfetti,
        onComplete: () {
          Future.delayed(displayDuration, () {
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          });
        },
      ),
    );
  }
}
