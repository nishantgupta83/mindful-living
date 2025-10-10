import 'package:flutter/material.dart';
import '../base/base_component.dart';

/// Custom page transition that mimics breathing for a calming effect
/// Combines fade, scale, and subtle slide animations
class BreathePageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final Duration transitionDuration;
  final Curve curve;

  BreathePageRoute({
    required this.child,
    this.transitionDuration = const Duration(milliseconds: 600),
    this.curve = Curves.easeInOutCubic,
    RouteSettings? settings,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: transitionDuration,
          reverseTransitionDuration: transitionDuration,
          settings: settings,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return BreatheTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              curve: curve,
              child: child,
            );
          },
        );
}

/// The actual breathe transition widget
class BreatheTransition extends BaseComponent {
  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final Widget child;
  final Curve curve;

  const BreatheTransition({
    super.key,
    required this.animation,
    required this.secondaryAnimation,
    required this.child,
    this.curve = Curves.easeInOutCubic,
  });

  @override
  Widget build(BuildContext context) {
    // Primary animation (entering page)
    final fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Interval(0.0, 0.8, curve: curve),
    ));

    final scaleAnimation = Tween<double>(
      begin: 0.92,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Interval(0.2, 1.0, curve: curve),
    ));

    final slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Interval(0.0, 0.6, curve: curve),
    ));

    // Secondary animation (exiting page)
    final secondaryFadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: secondaryAnimation,
      curve: Interval(0.2, 1.0, curve: curve),
    ));

    final secondaryScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: secondaryAnimation,
      curve: Interval(0.0, 0.8, curve: curve),
    ));

    return Stack(
      children: [
        // Exiting page (if any)
        if (secondaryAnimation.status != AnimationStatus.dismissed)
          AnimatedBuilder(
            animation: secondaryAnimation,
            builder: (context, child) {
              return FadeTransition(
                opacity: secondaryFadeAnimation,
                child: Transform.scale(
                  scale: secondaryScaleAnimation.value,
                  child: child,
                ),
              );
            },
            child: child,
          ),
        
        // Entering page
        AnimatedBuilder(
          animation: animation,
          builder: (context, _) {
            return FadeTransition(
              opacity: fadeAnimation,
              child: SlideTransition(
                position: slideAnimation,
                child: Transform.scale(
                  scale: scaleAnimation.value,
                  child: child,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Alternative breathe transition for modal/dialog presentations
class BreatheModalTransition extends BaseComponent {
  final Animation<double> animation;
  final Widget child;
  final bool isModal;

  const BreatheModalTransition({
    super.key,
    required this.animation,
    required this.child,
    this.isModal = true,
  });

  @override
  Widget build(BuildContext context) {
    final fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    final scaleAnimation = Tween<double>(
      begin: isModal ? 0.8 : 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: const Interval(0.2, 1.0, curve: Curves.elasticOut),
    ));

    final backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    ));

    return Stack(
      children: [
        // Background overlay for modals
        if (isModal)
          AnimatedBuilder(
            animation: backgroundAnimation,
            builder: (context, _) {
              return Container(
                color: Colors.black.withValues(alpha: 0.5 * backgroundAnimation.value),
              );
            },
          ),
        
        // Main content
        Center(
          child: AnimatedBuilder(
            animation: animation,
            builder: (context, _) {
              return FadeTransition(
                opacity: fadeAnimation,
                child: Transform.scale(
                  scale: scaleAnimation.value,
                  child: child,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Helper class for creating different types of breathe transitions
class BreatheTransitions {
  /// Standard page transition
  static Route<T> page<T extends Object?>({
    required Widget child,
    RouteSettings? settings,
    Duration? duration,
  }) {
    return BreathePageRoute<T>(
      child: child,
      settings: settings,
      transitionDuration: duration ?? const Duration(milliseconds: 600),
    );
  }

  /// Fast page transition for quick navigation
  static Route<T> fastPage<T extends Object?>({
    required Widget child,
    RouteSettings? settings,
  }) {
    return BreathePageRoute<T>(
      child: child,
      settings: settings,
      transitionDuration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  /// Slow, meditative transition for wellness content
  static Route<T> meditativePage<T extends Object?>({
    required Widget child,
    RouteSettings? settings,
  }) {
    return BreathePageRoute<T>(
      child: child,
      settings: settings,
      transitionDuration: const Duration(milliseconds: 900),
      curve: Curves.easeInOutQuart,
    );
  }

  /// Modal transition for dialogs and overlays
  static Route<T> modal<T extends Object?>({
    required Widget child,
    RouteSettings? settings,
    bool barrierDismissible = true,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionDuration: const Duration(milliseconds: 400),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      settings: settings,
      opaque: false,
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.transparent,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return BreatheModalTransition(
          animation: animation,
          child: child,
        );
      },
    );
  }

  /// Bottom sheet transition with breathe effect
  static Route<T> bottomSheet<T extends Object?>({
    required Widget child,
    RouteSettings? settings,
    bool isScrollControlled = false,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionDuration: const Duration(milliseconds: 500),
      reverseTransitionDuration: const Duration(milliseconds: 400),
      settings: settings,
      opaque: false,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slideAnimation = Tween<Offset>(
          begin: const Offset(0.0, 1.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        ));

        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
        ));

        return FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(
            position: slideAnimation,
            child: child,
          ),
        );
      },
    );
  }
}

/// Extension for easy navigation with breathe transitions
extension BreatheNavigation on NavigatorState {
  /// Push with breathe transition
  Future<T?> pushBreathe<T extends Object?>(Widget page) {
    return push<T>(BreatheTransitions.page<T>(child: page));
  }

  /// Push replacement with breathe transition
  Future<T?> pushReplacementBreathe<T extends Object?, TO extends Object?>(
    Widget page, {
    TO? result,
  }) {
    return pushReplacement<T, TO>(
      BreatheTransitions.page<T>(child: page),
      result: result,
    );
  }

  /// Push and remove until with breathe transition
  Future<T?> pushAndRemoveUntilBreathe<T extends Object?>(
    Widget page,
    RoutePredicate predicate,
  ) {
    return pushAndRemoveUntil<T>(
      BreatheTransitions.page<T>(child: page),
      predicate,
    );
  }

  /// Show modal with breathe transition
  Future<T?> showModalBreathe<T extends Object?>(Widget modal) {
    return push<T>(BreatheTransitions.modal<T>(child: modal));
  }

  /// Show bottom sheet with breathe transition
  Future<T?> showBottomSheetBreathe<T extends Object?>(Widget sheet) {
    return push<T>(BreatheTransitions.bottomSheet<T>(child: sheet));
  }
}

/// Extension for BuildContext navigation
extension BreatheNavigationContext on BuildContext {
  /// Push with breathe transition
  Future<T?> pushBreathe<T extends Object?>(Widget page) {
    return Navigator.of(this).pushBreathe<T>(page);
  }

  /// Push replacement with breathe transition
  Future<T?> pushReplacementBreathe<T extends Object?, TO extends Object?>(
    Widget page, {
    TO? result,
  }) {
    return Navigator.of(this).pushReplacementBreathe<T, TO>(page, result: result);
  }

  /// Show modal with breathe transition
  Future<T?> showModalBreathe<T extends Object?>(Widget modal) {
    return Navigator.of(this).showModalBreathe<T>(modal);
  }

  /// Show bottom sheet with breathe transition
  Future<T?> showBottomSheetBreathe<T extends Object?>(Widget sheet) {
    return Navigator.of(this).showBottomSheetBreathe<T>(sheet);
  }
}