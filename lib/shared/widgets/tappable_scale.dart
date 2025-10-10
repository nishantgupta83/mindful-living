import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A widget that scales down slightly when tapped, providing tactile feedback
///
/// This creates a delightful micro-interaction that makes the UI feel responsive.
/// The scale animation duration is 100ms, matching iOS's native feel.
///
/// Usage:
/// ```dart
/// TappableScale(
///   onTap: () => print('Tapped!'),
///   child: YourWidget(),
/// )
/// ```
class TappableScale extends StatefulWidget {
  const TappableScale({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.scale = 0.95,
    this.duration = const Duration(milliseconds: 100),
    this.enableHaptic = true,
    this.hapticType = HapticType.light,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// Scale factor when pressed (default 0.95 = 95% of original size)
  final double scale;

  /// Animation duration (default 100ms)
  final Duration duration;

  /// Whether to trigger haptic feedback (default true)
  final bool enableHaptic;

  /// Type of haptic feedback
  final HapticType hapticType;

  @override
  State<TappableScale> createState() => _TappableScaleState();
}

class _TappableScaleState extends State<TappableScale>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scale,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  void _handleTap() {
    if (widget.enableHaptic) {
      _triggerHaptic();
    }
    widget.onTap?.call();
  }

  void _handleLongPress() {
    if (widget.enableHaptic) {
      HapticFeedback.mediumImpact();
    }
    widget.onLongPress?.call();
  }

  void _triggerHaptic() {
    switch (widget.hapticType) {
      case HapticType.light:
        HapticFeedback.lightImpact();
        break;
      case HapticType.medium:
        HapticFeedback.mediumImpact();
        break;
      case HapticType.heavy:
        HapticFeedback.heavyImpact();
        break;
      case HapticType.selection:
        HapticFeedback.selectionClick();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap != null ? _handleTapDown : null,
      onTapUp: widget.onTap != null ? _handleTapUp : null,
      onTapCancel: widget.onTap != null ? _handleTapCancel : null,
      onTap: widget.onTap != null ? _handleTap : null,
      onLongPress: widget.onLongPress != null ? _handleLongPress : null,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}

/// Types of haptic feedback
enum HapticType {
  light,
  medium,
  heavy,
  selection,
}

/// A wrapper that adds both scale animation and semantic labels
/// Useful for cards and buttons that need both interactions and accessibility
class TappableCard extends StatelessWidget {
  const TappableCard({
    super.key,
    required this.child,
    this.onTap,
    this.semanticLabel,
    this.semanticHint,
    this.scale = 0.97,
    this.enableHaptic = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final String? semanticHint;
  final double scale;
  final bool enableHaptic;

  @override
  Widget build(BuildContext context) {
    Widget result = TappableScale(
      onTap: onTap,
      scale: scale,
      enableHaptic: enableHaptic,
      child: child,
    );

    if (semanticLabel != null || semanticHint != null) {
      result = Semantics(
        button: true,
        label: semanticLabel,
        hint: semanticHint,
        enabled: onTap != null,
        child: result,
      );
    }

    return result;
  }
}

/// Staggered animation for list items
/// Makes lists feel more dynamic by animating items in sequence
class StaggeredListItem extends StatefulWidget {
  const StaggeredListItem({
    super.key,
    required this.index,
    required this.child,
    this.delay = 50,
  });

  final int index;
  final Widget child;

  /// Delay in milliseconds between each item
  final int delay;

  @override
  State<StaggeredListItem> createState() => _StaggeredListItemState();
}

class _StaggeredListItemState extends State<StaggeredListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    // Start animation after delay based on index
    Future.delayed(
      Duration(milliseconds: widget.index * widget.delay),
      () {
        if (mounted) {
          _controller.forward();
        }
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}
