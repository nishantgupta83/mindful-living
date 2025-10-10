import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';

enum PastelButtonStyle {
  primary,
  secondary,
  ghost,
  gradient,
}

enum PastelButtonSize {
  small,
  medium,
  large,
}

class PastelButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final PastelButtonStyle style;
  final PastelButtonSize size;
  final IconData? icon;
  final bool iconOnRight;
  final Color? backgroundColor;
  final Color? textColor;
  final List<Color>? gradientColors;
  final double? width;
  final bool isLoading;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;

  const PastelButton({
    super.key,
    required this.text,
    this.onPressed,
    this.style = PastelButtonStyle.primary,
    this.size = PastelButtonSize.medium,
    this.icon,
    this.iconOnRight = false,
    this.backgroundColor,
    this.textColor,
    this.gradientColors,
    this.width,
    this.isLoading = false,
    this.borderRadius,
    this.padding,
  });

  // Convenience constructors
  const PastelButton.primary({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.iconOnRight = false,
    this.size = PastelButtonSize.medium,
    this.width,
    this.isLoading = false,
    this.borderRadius,
    this.padding,
  }) : style = PastelButtonStyle.primary,
       backgroundColor = null,
       textColor = null,
       gradientColors = null;

  const PastelButton.secondary({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.iconOnRight = false,
    this.size = PastelButtonSize.medium,
    this.width,
    this.isLoading = false,
    this.borderRadius,
    this.padding,
  }) : style = PastelButtonStyle.secondary,
       backgroundColor = null,
       textColor = null,
       gradientColors = null;

  const PastelButton.ghost({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.iconOnRight = false,
    this.size = PastelButtonSize.medium,
    this.width,
    this.isLoading = false,
    this.borderRadius,
    this.padding,
  }) : style = PastelButtonStyle.ghost,
       backgroundColor = null,
       textColor = null,
       gradientColors = null;

  const PastelButton.gradient({
    super.key,
    required this.text,
    required this.onPressed,
    required List<Color> this.gradientColors,
    this.icon,
    this.iconOnRight = false,
    this.size = PastelButtonSize.medium,
    this.textColor,
    this.width,
    this.isLoading = false,
    this.borderRadius,
    this.padding,
  }) : style = PastelButtonStyle.gradient,
       backgroundColor = null;

  @override
  State<PastelButton> createState() => _PastelButtonState();
}

class _PastelButtonState extends State<PastelButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
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

  EdgeInsetsGeometry get _buttonPadding {
    if (widget.padding != null) return widget.padding!;
    
    switch (widget.size) {
      case PastelButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case PastelButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
      case PastelButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    }
  }

  TextStyle get _textStyle {
    final baseStyle = widget.size == PastelButtonSize.small
        ? AppTypography.labelSmall
        : widget.size == PastelButtonSize.medium
            ? AppTypography.labelMedium
            : AppTypography.labelLarge;
    
    return baseStyle.copyWith(
      color: _getTextColor(),
      fontWeight: FontWeight.w600,
    );
  }

  double get _iconSize {
    switch (widget.size) {
      case PastelButtonSize.small:
        return 16;
      case PastelButtonSize.medium:
        return 18;
      case PastelButtonSize.large:
        return 20;
    }
  }

  Color _getTextColor() {
    if (widget.textColor != null) return widget.textColor!;
    
    switch (widget.style) {
      case PastelButtonStyle.primary:
        return AppColors.deepLavender;
      case PastelButtonStyle.secondary:
        return AppColors.softCharcoal;
      case PastelButtonStyle.ghost:
        return AppColors.deepLavender;
      case PastelButtonStyle.gradient:
        return widget.textColor ?? AppColors.deepLavender;
    }
  }

  Color _getBackgroundColor() {
    if (widget.backgroundColor != null) return widget.backgroundColor!;
    
    switch (widget.style) {
      case PastelButtonStyle.primary:
        return AppColors.lavender;
      case PastelButtonStyle.secondary:
        return AppColors.softGray;
      case PastelButtonStyle.ghost:
        return Colors.transparent;
      case PastelButtonStyle.gradient:
        return Colors.transparent; // Will use gradient instead
    }
  }

  Border? _getBorder() {
    if (widget.style == PastelButtonStyle.ghost) {
      return Border.all(
        color: AppColors.paleGray,
        width: 1.5,
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = widget.borderRadius ?? BorderRadius.circular(16);
    final isEnabled = widget.onPressed != null && !widget.isLoading;
    
    Widget buttonChild = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null && !widget.iconOnRight) ...[
          Icon(
            widget.icon,
            size: _iconSize,
            color: _getTextColor(),
          ),
          const SizedBox(width: 8),
        ],
        if (widget.isLoading)
          SizedBox(
            width: _iconSize,
            height: _iconSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(_getTextColor()),
            ),
          )
        else
          Text(
            widget.text,
            style: _textStyle,
          ),
        if (widget.icon != null && widget.iconOnRight) ...[
          const SizedBox(width: 8),
          Icon(
            widget.icon,
            size: _iconSize,
            color: _getTextColor(),
          ),
        ],
      ],
    );

    Widget button = AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: widget.width,
            decoration: BoxDecoration(
              color: widget.style != PastelButtonStyle.gradient 
                  ? _getBackgroundColor() 
                  : null,
              gradient: widget.style == PastelButtonStyle.gradient
                  ? AppColors.createGradient(
                      widget.gradientColors ?? AppColors.primaryGradient,
                    )
                  : null,
              borderRadius: borderRadius,
              border: _getBorder(),
              boxShadow: isEnabled && widget.style != PastelButtonStyle.ghost
                  ? [
                      BoxShadow(
                        color: AppColors.shadowLight,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: borderRadius,
              child: InkWell(
                onTap: isEnabled ? widget.onPressed : null,
                onTapDown: isEnabled ? (_) => _animationController.forward() : null,
                onTapUp: isEnabled ? (_) => _animationController.reverse() : null,
                onTapCancel: isEnabled ? () => _animationController.reverse() : null,
                borderRadius: borderRadius,
                splashColor: AppColors.withOpacity(AppColors.lavender, 0.1),
                highlightColor: AppColors.withOpacity(AppColors.lavender, 0.05),
                child: Padding(
                  padding: _buttonPadding,
                  child: buttonChild,
                ),
              ),
            ),
          ),
        );
      },
    );

    if (!isEnabled) {
      return Opacity(
        opacity: 0.5,
        child: button,
      );
    }

    return button;
  }
}

// Icon button variant
class PastelIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final PastelButtonStyle style;
  final PastelButtonSize size;
  final Color? backgroundColor;
  final Color? iconColor;
  final List<Color>? gradientColors;
  final String? tooltip;
  final BorderRadius? borderRadius;

  const PastelIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.style = PastelButtonStyle.primary,
    this.size = PastelButtonSize.medium,
    this.backgroundColor,
    this.iconColor,
    this.gradientColors,
    this.tooltip,
    this.borderRadius,
  });

  @override
  State<PastelIconButton> createState() => _PastelIconButtonState();
}

class _PastelIconButtonState extends State<PastelIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
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

  double get _buttonSize {
    switch (widget.size) {
      case PastelButtonSize.small:
        return 32;
      case PastelButtonSize.medium:
        return 44;
      case PastelButtonSize.large:
        return 56;
    }
  }

  double get _iconSize {
    switch (widget.size) {
      case PastelButtonSize.small:
        return 16;
      case PastelButtonSize.medium:
        return 20;
      case PastelButtonSize.large:
        return 24;
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = widget.borderRadius ?? BorderRadius.circular(_buttonSize / 2);
    final isEnabled = widget.onPressed != null;

    Widget button = AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: _buttonSize,
            height: _buttonSize,
            decoration: BoxDecoration(
              color: widget.style != PastelButtonStyle.gradient
                  ? (widget.backgroundColor ?? AppColors.lavender)
                  : null,
              gradient: widget.style == PastelButtonStyle.gradient
                  ? AppColors.createGradient(
                      widget.gradientColors ?? AppColors.primaryGradient,
                    )
                  : null,
              borderRadius: borderRadius,
              boxShadow: isEnabled
                  ? [
                      BoxShadow(
                        color: AppColors.shadowLight,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: borderRadius,
              child: InkWell(
                onTap: isEnabled ? widget.onPressed : null,
                onTapDown: isEnabled ? (_) => _animationController.forward() : null,
                onTapUp: isEnabled ? (_) => _animationController.reverse() : null,
                onTapCancel: isEnabled ? () => _animationController.reverse() : null,
                borderRadius: borderRadius,
                splashColor: AppColors.withOpacity(AppColors.lavender, 0.1),
                highlightColor: AppColors.withOpacity(AppColors.lavender, 0.05),
                child: Icon(
                  widget.icon,
                  size: _iconSize,
                  color: widget.iconColor ?? AppColors.deepLavender,
                ),
              ),
            ),
          ),
        );
      },
    );

    if (widget.tooltip != null) {
      return Tooltip(
        message: widget.tooltip!,
        child: button,
      );
    }

    if (!isEnabled) {
      return Opacity(
        opacity: 0.5,
        child: button,
      );
    }

    return button;
  }
}