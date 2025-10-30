import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Glassmorphism card with frosted glass effect
class GlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final double blur;
  final double opacity;
  final Gradient? gradient;
  final Border? border;
  final List<BoxShadow>? shadows;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.blur = 10.0,
    this.opacity = 0.1,
    this.gradient,
    this.border,
    this.shadows,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final defaultBorderRadius = borderRadius ?? BorderRadius.circular(20);
    final defaultGradient = gradient ?? LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white.withValues(alpha: opacity),
        Colors.white.withValues(alpha: opacity * 0.5),
      ],
    );

    final defaultBorder = border ?? Border.all(
      color: Colors.white.withValues(alpha: 0.2),
      width: 1.5,
    );

    final defaultShadows = shadows ?? [
      BoxShadow(
        color: AppColors.lavender.withValues(alpha: 0.1),
        blurRadius: 20,
        offset: const Offset(0, 10),
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.05),
        blurRadius: 10,
        offset: const Offset(0, 5),
      ),
    ];

    Widget card = ClipRRect(
      borderRadius: defaultBorderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width,
          height: height,
          padding: padding ?? const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: defaultGradient,
            borderRadius: defaultBorderRadius,
            border: defaultBorder,
            boxShadow: defaultShadows,
          ),
          child: child,
        ),
      ),
    );

    if (margin != null) {
      card = Padding(padding: margin!, child: card);
    }

    if (onTap != null) {
      card = InkWell(
        onTap: onTap,
        borderRadius: defaultBorderRadius,
        child: card,
      );
    }

    return card;
  }
}

/// Preset glass card styles
class GlassCardPresets {
  /// Light frosted glass (subtle)
  static GlassCard light({
    required Widget child,
    EdgeInsetsGeometry? padding,
    VoidCallback? onTap,
  }) {
    return GlassCard(
      blur: 8,
      opacity: 0.05,
      padding: padding,
      onTap: onTap,
      gradient: LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0.08),
          Colors.white.withValues(alpha: 0.04),
        ],
      ),
      child: child,
    );
  }

  /// Medium frosted glass (balanced)
  static GlassCard medium({
    required Widget child,
    EdgeInsetsGeometry? padding,
    VoidCallback? onTap,
  }) {
    return GlassCard(
      blur: 12,
      opacity: 0.12,
      padding: padding,
      onTap: onTap,
      child: child,
    );
  }

  /// Heavy frosted glass (prominent)
  static GlassCard heavy({
    required Widget child,
    EdgeInsetsGeometry? padding,
    VoidCallback? onTap,
  }) {
    return GlassCard(
      blur: 16,
      opacity: 0.2,
      padding: padding,
      onTap: onTap,
      gradient: LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0.25),
          Colors.white.withValues(alpha: 0.15),
        ],
      ),
      child: child,
    );
  }

  /// Colored glass with gradient
  static GlassCard colored({
    required Widget child,
    required List<Color> colors,
    EdgeInsetsGeometry? padding,
    VoidCallback? onTap,
  }) {
    return GlassCard(
      blur: 12,
      opacity: 0.15,
      padding: padding,
      onTap: onTap,
      gradient: LinearGradient(
        colors: colors.map((c) => c.withValues(alpha: 0.2)).toList(),
      ),
      child: child,
    );
  }
}
