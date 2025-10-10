import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

enum PastelCardStyle {
  plain,
  gradient,
  elevated,
  outlined,
}

class PastelCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final List<Color>? gradientColors;
  final PastelCardStyle style;
  final bool isInteractive;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final BorderRadius? borderRadius;
  final double elevation;
  final Color? shadowColor;

  const PastelCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.backgroundColor,
    this.gradientColors,
    this.style = PastelCardStyle.plain,
    this.isInteractive = false,
    this.onTap,
    this.onLongPress,
    this.borderRadius,
    this.elevation = 0,
    this.shadowColor,
  });

  // Convenience constructors for common use cases
  const PastelCard.gradient({
    super.key,
    required this.child,
    required List<Color> this.gradientColors,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.isInteractive = false,
    this.onTap,
    this.onLongPress,
    this.borderRadius,
    this.elevation = 0,
    this.shadowColor,
  }) : style = PastelCardStyle.gradient,
       backgroundColor = null;

  const PastelCard.elevated({
    super.key,
    required this.child,
    this.backgroundColor,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.isInteractive = false,
    this.onTap,
    this.onLongPress,
    this.borderRadius,
    this.elevation = 8,
    this.shadowColor,
  }) : style = PastelCardStyle.elevated,
       gradientColors = null;

  const PastelCard.interactive({
    super.key,
    required this.child,
    required this.onTap,
    this.backgroundColor,
    this.gradientColors,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.onLongPress,
    this.borderRadius,
    this.elevation = 0,
    this.shadowColor,
    this.style = PastelCardStyle.plain,
  }) : isInteractive = true;

  @override
  State<PastelCard> createState() => _PastelCardState();
}

class _PastelCardState extends State<PastelCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.isInteractive) {
      setState(() => _isPressed = true);
      _animationController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.isInteractive) {
      setState(() => _isPressed = false);
      _animationController.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.isInteractive) {
      setState(() => _isPressed = false);
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = widget.borderRadius ?? BorderRadius.circular(20);
    final padding = widget.padding ?? const EdgeInsets.all(16);
    final margin = widget.margin ?? EdgeInsets.zero;

    Widget cardChild = Container(
      width: widget.width,
      height: widget.height,
      margin: margin,
      decoration: _buildDecoration(borderRadius),
      child: Material(
        color: Colors.transparent,
        borderRadius: borderRadius,
        child: InkWell(
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          borderRadius: borderRadius,
          splashColor: widget.isInteractive
              ? AppColors.withOpacity(AppColors.lavender, 0.1)
              : Colors.transparent,
          highlightColor: widget.isInteractive
              ? AppColors.withOpacity(AppColors.lavender, 0.05)
              : Colors.transparent,
          child: Padding(
            padding: padding,
            child: widget.child,
          ),
        ),
      ),
    );

    if (widget.isInteractive) {
      return AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: cardChild,
          );
        },
      );
    }

    return cardChild;
  }

  BoxDecoration _buildDecoration(BorderRadius borderRadius) {
    switch (widget.style) {
      case PastelCardStyle.gradient:
        return BoxDecoration(
          gradient: AppColors.createGradient(
            widget.gradientColors ?? AppColors.primaryGradient,
          ),
          borderRadius: borderRadius,
          boxShadow: _buildShadow(),
        );
      case PastelCardStyle.elevated:
        return BoxDecoration(
          color: widget.backgroundColor ?? AppColors.mistyWhite,
          borderRadius: borderRadius,
          boxShadow: _buildElevatedShadow(),
        );
      case PastelCardStyle.outlined:
        return BoxDecoration(
          color: widget.backgroundColor ?? AppColors.mistyWhite,
          borderRadius: borderRadius,
          border: Border.all(
            color: AppColors.paleGray,
            width: 1,
          ),
          boxShadow: _buildShadow(),
        );
      case PastelCardStyle.plain:
      default:
        return BoxDecoration(
          color: widget.backgroundColor ?? AppColors.mistyWhite,
          borderRadius: borderRadius,
          boxShadow: _buildShadow(),
        );
    }
  }

  List<BoxShadow> _buildShadow() {
    if (widget.elevation == 0) return [];
    
    return [
      BoxShadow(
        color: widget.shadowColor ?? AppColors.shadowLight,
        blurRadius: 10,
        offset: const Offset(0, 4),
        spreadRadius: 0,
      ),
    ];
  }

  List<BoxShadow> _buildElevatedShadow() {
    return [
      BoxShadow(
        color: widget.shadowColor ?? AppColors.shadowMedium,
        blurRadius: widget.elevation * 2,
        offset: Offset(0, widget.elevation / 2),
        spreadRadius: -1,
      ),
      BoxShadow(
        color: AppColors.shadowLight,
        blurRadius: widget.elevation,
        offset: const Offset(0, 1),
        spreadRadius: 0,
      ),
    ];
  }
}

// Specialized cards for common use cases
class WellnessCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const WellnessCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return PastelCard.gradient(
      gradientColors: AppColors.dreamGradient,
      onTap: onTap,
      isInteractive: onTap != null,
      padding: padding,
      margin: margin,
      child: child,
    );
  }
}

class ActionCard extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final List<Color>? gradientColors;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const ActionCard({
    super.key,
    required this.child,
    required this.onTap,
    this.gradientColors,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return PastelCard.interactive(
      onTap: onTap,
      gradientColors: gradientColors ?? AppColors.oceanGradient,
      style: PastelCardStyle.gradient,
      elevation: 4,
      padding: padding,
      margin: margin,
      child: child,
    );
  }
}

class InfoCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  const InfoCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PastelCard(
      backgroundColor: AppColors.skyBlue,
      onTap: onTap,
      isInteractive: onTap != null,
      padding: padding,
      margin: margin,
      child: child,
    );
  }
}