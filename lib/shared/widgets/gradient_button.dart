import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';

/// Pulsating gradient button inspired by GitaWisdom2 journal save button
/// Uses existing pastel colors from AppColors
class GradientButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isPulsating;
  final List<Color>? gradientColors;
  final IconData? icon;
  final double? width;
  final double height;
  final BorderRadius? borderRadius;
  final bool hapticFeedback;

  const GradientButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isPulsating = true,
    this.gradientColors,
    this.icon,
    this.width,
    this.height = 56,
    this.borderRadius,
    this.hapticFeedback = true,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  bool _animationsEnabled = true;

  @override
  void initState() {
    super.initState();

    // Pulsating animation (GitaWisdom2 pattern)
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 8.0,
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
    if (widget.isPulsating && !widget.isLoading && _animationsEnabled) {
      if (!_controller.isAnimating) {
        _controller.repeat(reverse: true);
      }
    } else {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void didUpdateWidget(GradientButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Only animate if motion is enabled and conditions are met
    if (widget.isPulsating && !widget.isLoading && _animationsEnabled && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isPulsating || widget.isLoading || !_animationsEnabled) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.hapticFeedback) {
      HapticFeedback.mediumImpact();
    }
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final gradientColors = widget.gradientColors ?? AppColors.primaryGradient;
    final borderRadius = widget.borderRadius ?? BorderRadius.circular(16);
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    return Semantics(
      button: true,
      label: widget.label,
      hint: widget.isLoading ? null : 'Double tap to activate',
      enabled: isEnabled,
      liveRegion: widget.isLoading,  // Announce loading state changes
      child: AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isPulsating ? _scaleAnimation.value : 1.0,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              boxShadow: widget.isPulsating
                  ? [
                      BoxShadow(
                        color: gradientColors.first.withValues(alpha: 0.4),
                        blurRadius: _glowAnimation.value,
                        spreadRadius: _glowAnimation.value / 2,
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: AppColors.shadowMedium,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.isLoading ? null : _handleTap,
                borderRadius: borderRadius,
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: borderRadius,
                  ),
                  child: Center(
                    child: widget.isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (widget.icon != null) ...[
                                Icon(
                                  widget.icon,
                                  color: AppColors.deepLavender,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                              ],
                              Text(
                                widget.label,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.deepLavender,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ),
    );
  }
}

/// Outlined gradient button variant
class OutlinedGradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final List<Color>? gradientColors;
  final IconData? icon;
  final double? width;
  final double height;
  final bool hapticFeedback;

  const OutlinedGradientButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.gradientColors,
    this.icon,
    this.width,
    this.height = 56,
    this.hapticFeedback = true,
  });

  void _handleTap() {
    if (hapticFeedback) {
      HapticFeedback.lightImpact();
    }
    onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final colors = gradientColors ?? AppColors.primaryGradient;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.all(2), // Border width
        decoration: BoxDecoration(
          color: AppColors.cream,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isLoading ? null : _handleTap,
            borderRadius: BorderRadius.circular(14),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colors.first,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (icon != null) ...[
                          Icon(
                            icon,
                            color: AppColors.deepLavender,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          label,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.deepLavender,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
