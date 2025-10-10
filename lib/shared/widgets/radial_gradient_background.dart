import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Radial gradient background inspired by GitaWisdom2 journal screen
/// Creates a soft radial glow effect from center to edges
class RadialGradientBackground extends StatelessWidget {
  final Widget child;
  final List<Color>? colors;
  final AlignmentGeometry center;
  final double radius;
  final List<double>? stops;

  const RadialGradientBackground({
    super.key,
    required this.child,
    this.colors,
    this.center = Alignment.center,
    this.radius = 1.5,
    this.stops,
  });

  @override
  Widget build(BuildContext context) {
    final gradientColors = colors ?? [
      AppColors.lavender.withValues(alpha: 0.3), // Center - soft lavender
      AppColors.cream, // Edge - cream white
    ];

    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: gradientColors,
          center: center,
          radius: radius,
          stops: stops ?? [0.0, 1.0],
        ),
      ),
      child: child,
    );
  }
}

/// Animated radial gradient background with pulsating effect
/// Perfect for journal entry or meditation screens
class AnimatedRadialGradientBackground extends StatefulWidget {
  final Widget child;
  final List<Color>? colors;
  final AlignmentGeometry center;
  final Duration duration;
  final double minRadius;
  final double maxRadius;

  const AnimatedRadialGradientBackground({
    super.key,
    required this.child,
    this.colors,
    this.center = Alignment.center,
    this.duration = const Duration(seconds: 3),
    this.minRadius = 1.2,
    this.maxRadius = 1.8,
  });

  @override
  State<AnimatedRadialGradientBackground> createState() =>
      _AnimatedRadialGradientBackgroundState();
}

class _AnimatedRadialGradientBackgroundState
    extends State<AnimatedRadialGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _radiusAnimation;
  bool _animationsEnabled = true;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _radiusAnimation = Tween<double>(
      begin: widget.minRadius,
      end: widget.maxRadius,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Check for reduced motion preference
    final mediaQuery = MediaQuery.maybeOf(context);
    _animationsEnabled = mediaQuery?.disableAnimations == false;

    // Start or stop animation based on preferences
    if (_animationsEnabled) {
      if (!_controller.isAnimating) {
        _controller.repeat(reverse: true);
      }
    } else {
      _controller.stop();
      _controller.value = 0.5; // Set to middle value when disabled
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gradientColors = widget.colors ?? [
      AppColors.lavender.withValues(alpha: 0.3),
      AppColors.cream,
    ];

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: gradientColors,
              center: widget.center,
              radius: _radiusAnimation.value,
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}

/// Multi-color radial gradient background with blend effects
/// Useful for home screen or wellness summary cards
class MultiRadialGradientBackground extends StatelessWidget {
  final Widget child;
  final List<RadialGradientConfig> gradients;

  const MultiRadialGradientBackground({
    super.key,
    required this.child,
    required this.gradients,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ...gradients.map((config) => Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: config.colors,
                    center: config.center,
                    radius: config.radius,
                    stops: config.stops,
                  ),
                ),
              ),
            )),
        child,
      ],
    );
  }
}

/// Configuration for multi-radial gradient backgrounds
class RadialGradientConfig {
  final List<Color> colors;
  final AlignmentGeometry center;
  final double radius;
  final List<double>? stops;

  const RadialGradientConfig({
    required this.colors,
    required this.center,
    this.radius = 1.0,
    this.stops,
  });
}

/// Predefined radial gradient presets for common use cases
class RadialGradientPresets {
  /// Journal screen gradient (lavender center)
  static RadialGradientBackground journal({required Widget child}) {
    return RadialGradientBackground(
      center: Alignment.topCenter,
      radius: 1.5,
      colors: [
        AppColors.lavender.withValues(alpha: 0.3),
        AppColors.cream,
      ],
      stops: const [0.0, 0.8],
      child: child,
    );
  }

  /// Wellness card gradient (mint center)
  static RadialGradientBackground wellness({required Widget child}) {
    return RadialGradientBackground(
      center: Alignment.center,
      radius: 1.2,
      colors: [
        AppColors.mintGreen.withValues(alpha: 0.2),
        Colors.white,
      ],
      stops: const [0.0, 1.0],
      child: child,
    );
  }

  /// Energy card gradient (peach center)
  static RadialGradientBackground energy({required Widget child}) {
    return RadialGradientBackground(
      center: Alignment.center,
      radius: 1.2,
      colors: [
        AppColors.peach.withValues(alpha: 0.2),
        Colors.white,
      ],
      stops: const [0.0, 1.0],
      child: child,
    );
  }

  /// Calm card gradient (sky blue center)
  static RadialGradientBackground calm({required Widget child}) {
    return RadialGradientBackground(
      center: Alignment.center,
      radius: 1.2,
      colors: [
        AppColors.skyBlue.withValues(alpha: 0.2),
        Colors.white,
      ],
      stops: const [0.0, 1.0],
      child: child,
    );
  }

  /// Growth card gradient (purple center)
  static RadialGradientBackground growth({required Widget child}) {
    return RadialGradientBackground(
      center: Alignment.center,
      radius: 1.2,
      colors: [
        AppColors.softPurple.withValues(alpha: 0.2),
        Colors.white,
      ],
      stops: const [0.0, 1.0],
      child: child,
    );
  }
}
