import 'package:flutter/material.dart';
import 'dart:io';

/// Platform-aware page transitions
class AppPageRoute<T> extends PageRoute<T> {
  final WidgetBuilder builder;
  final PageTransitionType transitionType;

  AppPageRoute({
    required this.builder,
    this.transitionType = PageTransitionType.platform,
    super.settings,
  });

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return builder(context);
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    final type = transitionType == PageTransitionType.platform
        ? (Platform.isIOS ? PageTransitionType.cupertino : PageTransitionType.material)
        : transitionType;

    switch (type) {
      case PageTransitionType.fade:
        return FadeTransition(opacity: animation, child: child);

      case PageTransitionType.scale:
        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          ),
          child: FadeTransition(opacity: animation, child: child),
        );

      case PageTransitionType.slide:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
          child: child,
        );

      case PageTransitionType.slideUp:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
          child: child,
        );

      case PageTransitionType.cupertino:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.linearToEaseOut)),
          child: child,
        );

      case PageTransitionType.material:
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.1),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          ),
        );

      case PageTransitionType.platform:
        return child; // Handled above
    }
  }
}

enum PageTransitionType {
  platform,
  fade,
  scale,
  slide,
  slideUp,
  cupertino,
  material,
}

/// Hero animation utilities
class HeroAnimations {
  /// Create a hero-wrapped widget
  static Widget wrap({
    required String tag,
    required Widget child,
    bool enabled = true,
  }) {
    if (!enabled) return child;
    return Hero(
      tag: tag,
      child: child,
      flightShuttleBuilder: (context, animation, direction, fromContext, toContext) {
        return Material(
          color: Colors.transparent,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(animation),
            child: child,
          ),
        );
      },
    );
  }

  /// Hero tag for images
  static String imageTag(String id) => 'image_$id';

  /// Hero tag for cards
  static String cardTag(String id) => 'card_$id';

  /// Hero tag for avatars
  static String avatarTag(String id) => 'avatar_$id';
}

/// Animated list item entrance
class AnimatedListItem extends StatelessWidget {
  final Widget child;
  final int index;
  final Duration delay;
  final Curve curve;

  const AnimatedListItem({
    super.key,
    required this.child,
    required this.index,
    this.delay = const Duration(milliseconds: 50),
    this.curve = Curves.easeOutCubic,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 400),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: curve,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
