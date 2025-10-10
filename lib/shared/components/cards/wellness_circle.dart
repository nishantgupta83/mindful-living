import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../base/base_component.dart';
import '../../../core/constants/app_colors.dart';

/// Animated circular progress widget for wellness score display
/// Features breathing animation, gradient colors, and smooth transitions
class WellnessCircle extends StatefulWidget {
  final int score;
  final int maxScore;
  final String label;
  final String? subtitle;
  final double size;
  final bool enableAnimation;
  final bool enableBreathing;
  final VoidCallback? onTap;

  const WellnessCircle({
    super.key,
    required this.score,
    this.maxScore = 100,
    this.label = 'Wellness Score',
    this.subtitle,
    this.size = 200.0,
    this.enableAnimation = true,
    this.enableBreathing = false,
    this.onTap,
  });

  @override
  State<WellnessCircle> createState() => _WellnessCircleState();
}

class _WellnessCircleState extends State<WellnessCircle>
    with TickerProviderStateMixin {
  
  /// Get text theme from context
  TextTheme getTextTheme(BuildContext context) => Theme.of(context).textTheme;
  late AnimationController _progressController;
  late AnimationController _breathingController;
  late Animation<double> _progressAnimation;
  late Animation<double> _breathingAnimation;

  @override
  void initState() {
    super.initState();
    
    // Progress animation controller
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    // Breathing animation controller
    _breathingController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );
    
    // Progress animation
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.score / widget.maxScore,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOutCubic,
    ));
    
    // Breathing animation
    _breathingAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _breathingController,
      curve: Curves.easeInOut,
    ));
    
    // Start animations
    if (widget.enableAnimation) {
      _progressController.forward();
    } else {
      _progressController.value = 1.0;
    }
    
    if (widget.enableBreathing) {
      _breathingController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(WellnessCircle oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.score != widget.score) {
      _progressAnimation = Tween<double>(
        begin: _progressAnimation.value,
        end: widget.score / widget.maxScore,
      ).animate(CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeInOutCubic,
      ));
      
      _progressController.reset();
      if (widget.enableAnimation) {
        _progressController.forward();
      } else {
        _progressController.value = 1.0;
      }
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _breathingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: Listenable.merge([_progressAnimation, _breathingAnimation]),
          builder: (context, child) {
            final scale = widget.enableBreathing ? _breathingAnimation.value : 1.0;
            
            return Transform.scale(
              scale: scale,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  _buildCircleBackground(),
                  _buildProgressCircle(),
                  _buildCenterContent(context),
                  if (widget.enableBreathing) _buildBreathingGlow(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCircleBackground() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.softGray.withValues(alpha: 0.3),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCircle() {
    return CustomPaint(
      size: Size(widget.size, widget.size),
      painter: WellnessCirclePainter(
        progress: _progressAnimation.value,
        score: widget.score,
        strokeWidth: 8.0,
      ),
    );
  }

  Widget _buildCenterContent(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Score display
        AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            final animatedScore = (_progressAnimation.value * widget.score).round();
            return Text(
              animatedScore.toString(),
              style: getTextTheme(context).displayLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: _getScoreColor(),
                fontSize: widget.size * 0.15,
              ),
            );
          },
        ),
        
        // Label
        Text(
          widget.label,
          style: getTextTheme(context).labelMedium?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        
        // Subtitle
        if (widget.subtitle != null) ...[
          const SizedBox(height: BaseComponent.spacingXs),
          Text(
            widget.subtitle!,
            style: getTextTheme(context).labelSmall?.copyWith(
              color: AppColors.textLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildBreathingGlow() {
    return Container(
      width: widget.size * 1.2,
      height: widget.size * 1.2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            _getScoreColor().withValues(alpha: 0.1),
            _getScoreColor().withValues(alpha: 0.0),
          ],
        ),
      ),
    );
  }

  Color _getScoreColor() {
    final percentage = widget.score / widget.maxScore;
    
    if (percentage >= 0.8) {
      return AppColors.growthGreen;
    } else if (percentage >= 0.6) {
      return AppColors.mindfulOrange;
    } else if (percentage >= 0.4) {
      return AppColors.primaryBlue;
    } else {
      return AppColors.error;
    }
  }
}

/// Custom painter for the wellness circle progress
class WellnessCirclePainter extends CustomPainter {
  final double progress;
  final int score;
  final double strokeWidth;

  WellnessCirclePainter({
    required this.progress,
    required this.score,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    
    // Background circle
    final backgroundPaint = Paint()
      ..color = AppColors.softGray.withValues(alpha: 0.3)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    canvas.drawCircle(center, radius, backgroundPaint);
    
    // Progress arc
    final progressPaint = Paint()
      ..shader = _createGradient(size).createShader(Rect.fromCircle(center: center, radius: radius))
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    const startAngle = -math.pi / 2; // Start from top
    final sweepAngle = 2 * math.pi * progress;
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
    
    // Add glow effect
    if (progress > 0) {
      final glowPaint = Paint()
        ..shader = _createGlowGradient(size).createShader(Rect.fromCircle(center: center, radius: radius))
        ..strokeWidth = strokeWidth + 4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        glowPaint,
      );
    }
  }

  Gradient _createGradient(Size size) {
    final percentage = score / 100;
    List<Color> colors;
    
    if (percentage >= 0.8) {
      colors = [AppColors.growthGreen, AppColors.growthGreen.withValues(alpha: 0.7)];
    } else if (percentage >= 0.6) {
      colors = [AppColors.mindfulOrange, AppColors.mindfulOrange.withValues(alpha: 0.7)];
    } else if (percentage >= 0.4) {
      colors = [AppColors.primaryBlue, AppColors.primaryBlue.withValues(alpha: 0.7)];
    } else {
      colors = [AppColors.error, AppColors.error.withValues(alpha: 0.7)];
    }
    
    return SweepGradient(
      colors: colors,
      stops: const [0.0, 1.0],
    );
  }

  Gradient _createGlowGradient(Size size) {
    final percentage = score / 100;
    Color baseColor;
    
    if (percentage >= 0.8) {
      baseColor = AppColors.growthGreen;
    } else if (percentage >= 0.6) {
      baseColor = AppColors.mindfulOrange;
    } else if (percentage >= 0.4) {
      baseColor = AppColors.primaryBlue;
    } else {
      baseColor = AppColors.error;
    }
    
    return SweepGradient(
      colors: [
        baseColor.withValues(alpha: 0.3),
        baseColor.withValues(alpha: 0.1),
      ],
      stops: const [0.0, 1.0],
    );
  }

  @override
  bool shouldRepaint(WellnessCirclePainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.score != score ||
           oldDelegate.strokeWidth != strokeWidth;
  }
}

/// Compact version of wellness circle for smaller spaces
class WellnessCircleCompact extends BaseComponent {
  final int score;
  final int maxScore;
  final double size;
  final bool showLabel;

  const WellnessCircleCompact({
    super.key,
    required this.score,
    this.maxScore = 100,
    this.size = 60.0,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = score / maxScore;
    
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.softGray.withValues(alpha: 0.3),
            ),
          ),
          
          // Progress circle
          CustomPaint(
            size: Size(size, size),
            painter: WellnessCirclePainter(
              progress: percentage,
              score: score,
              strokeWidth: 4.0,
            ),
          ),
          
          // Score text
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                score.toString(),
                style: getTextTheme(context).labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _getScoreColor(),
                  fontSize: size * 0.25,
                ),
              ),
              if (showLabel)
                Text(
                  'Score',
                  style: getTextTheme(context).labelSmall?.copyWith(
                    color: AppColors.textLight,
                    fontSize: size * 0.12,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getScoreColor() {
    final percentage = score / maxScore;
    
    if (percentage >= 0.8) {
      return AppColors.growthGreen;
    } else if (percentage >= 0.6) {
      return AppColors.mindfulOrange;
    } else if (percentage >= 0.4) {
      return AppColors.primaryBlue;
    } else {
      return AppColors.error;
    }
  }
}