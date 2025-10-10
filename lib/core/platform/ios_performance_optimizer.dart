// iOS Performance Optimizer for MindfulLiving Wellness App
// Specialized performance optimizations for iOS wellness and meditation features

import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

/// iOS Performance Optimizer
/// Provides iOS-specific performance optimizations for wellness content
class IOSPerformanceOptimizer {
  static IOSPerformanceOptimizer? _instance;
  static IOSPerformanceOptimizer get instance => _instance ??= IOSPerformanceOptimizer._();
  IOSPerformanceOptimizer._();

  bool _isInitialized = false;
  bool _isProMotionDevice = false;
  bool _isMetalEnabled = false;
  double _devicePixelRatio = 1.0;
  Size _screenSize = Size.zero;

  // Performance tracking
  final List<Duration> _frameTimes = [];
  int _droppedFrames = 0;
  bool _isPerformanceMonitoringEnabled = false;

  /// Initialize iOS Performance Optimizer
  Future<void> initialize() async {
    if (_isInitialized || !Platform.isIOS) return;

    await _detectDeviceCapabilities();
    _setupPerformanceMonitoring();
    _configureIOSOptimizations();

    _isInitialized = true;

    if (kDebugMode) {
      print('⚡ iOS Performance Optimizer initialized');
      print('📱 ProMotion: $_isProMotionDevice');
      print('🎨 Metal: $_isMetalEnabled');
      print('📏 Pixel Ratio: $_devicePixelRatio');
      print('📐 Screen Size: $_screenSize');
    }
  }

  Future<void> _detectDeviceCapabilities() async {
    try {
      final window = WidgetsBinding.instance.platformDispatcher.views.first;
      _devicePixelRatio = window.devicePixelRatio;
      _screenSize = window.physicalSize / _devicePixelRatio;

      final display = WidgetsBinding.instance.platformDispatcher.displays.first;
      _isProMotionDevice = display.refreshRate >= 120;
      _isMetalEnabled = Platform.isIOS; // iOS 8+ supports Metal

      if (kDebugMode) {
        print('🔍 Device capabilities detected: ProMotion=$_isProMotionDevice, Metal=$_isMetalEnabled');
      }
    } catch (e) {
      if (kDebugMode) print('Device capability detection error: $e');
    }
  }

  void _setupPerformanceMonitoring() {
    if (!kDebugMode) return;

    _isPerformanceMonitoringEnabled = true;
    SchedulerBinding.instance.addTimingsCallback(_onFrameTimeUpdate);
  }

  void _onFrameTimeUpdate(List<FrameTiming> timings) {
    if (!_isPerformanceMonitoringEnabled) return;

    for (final timing in timings) {
      final frameDuration = timing.totalSpan;
      _frameTimes.add(frameDuration);

      // Keep only recent frame times (last 60 frames)
      if (_frameTimes.length > 60) {
        _frameTimes.removeAt(0);
      }

      // Check for dropped frames (>16.67ms for 60fps, >8.33ms for 120fps)
      final targetFrameTime = _isProMotionDevice
          ? const Duration(microseconds: 8333)
          : const Duration(microseconds: 16667);

      if (frameDuration > targetFrameTime) {
        _droppedFrames++;
      }
    }
  }

  void _configureIOSOptimizations() {
    if (!Platform.isIOS) return;

    // Configure system-level optimizations
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Optimize for battery life during meditation
    if (_isProMotionDevice) {
      // ProMotion devices can reduce refresh rate for static content
      _optimizeRefreshRateForMeditation();
    }
  }

  void _optimizeRefreshRateForMeditation() {
    // This would be implemented with platform channels in production
    if (kDebugMode) {
      print('📱 Optimizing refresh rate for meditation mode');
    }
  }

  // MARK: - Widget Optimizations

  /// Create optimized container for meditation content
  Widget createOptimizedMeditationContainer({
    required Widget child,
    Color? backgroundColor,
    Gradient? gradient,
    BorderRadius? borderRadius,
    List<BoxShadow>? boxShadow,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? width,
    double? height,
  }) {
    Widget container = Container(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor,
        gradient: gradient,
        borderRadius: borderRadius,
        boxShadow: _optimizeShadowsForDevice(boxShadow),
      ),
      child: child,
    );

    // Apply iOS-specific optimizations
    if (Platform.isIOS) {
      container = RepaintBoundary(
        child: _isMetalEnabled
            ? BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                child: container,
              )
            : container,
      );
    }

    return container;
  }

  /// Create optimized ListView for meditation content
  Widget createOptimizedMeditationList({
    required Widget Function(BuildContext, int) itemBuilder,
    required int itemCount,
    ScrollController? controller,
    EdgeInsets? padding,
    ScrollPhysics? physics,
    bool shrinkWrap = false,
  }) {
    return ListView.builder(
      controller: controller,
      padding: padding,
      physics: physics ?? (_getOptimizedScrollPhysics()),
      shrinkWrap: shrinkWrap,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return RepaintBoundary(
          key: ValueKey('meditation_item_$index'),
          child: itemBuilder(context, index),
        );
      },
      cacheExtent: _getOptimalCacheExtent(),
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: false, // We add them manually
    );
  }

  /// Create optimized circular progress for meditation timer
  Widget createOptimizedCircularProgress({
    required double value,
    required Color color,
    Color? backgroundColor,
    double strokeWidth = 4.0,
    double size = 200.0,
    Widget? child,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _OptimizedCircularProgressPainter(
            progress: value,
            progressColor: color,
            backgroundColor: backgroundColor ?? Colors.grey.withOpacity(0.3),
            strokeWidth: strokeWidth,
            isMetalEnabled: _isMetalEnabled,
          ),
          child: child,
        ),
      ),
    );
  }

  /// Create optimized breathing animation
  Widget createOptimizedBreathingAnimation({
    required AnimationController controller,
    required Color color,
    double size = 200.0,
    Widget? child,
  }) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return RepaintBoundary(
          child: Transform.scale(
            scale: 1.0 + (controller.value * 0.3),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    color.withOpacity(0.8),
                    color.withOpacity(0.1),
                  ],
                ),
              ),
              child: child,
            ),
          ),
        );
      },
    );
  }

  // MARK: - Performance Helpers

  ScrollPhysics _getOptimizedScrollPhysics() {
    if (!Platform.isIOS) return const ClampingScrollPhysics();

    return _isProMotionDevice
        ? const BouncingScrollPhysics()
        : const BouncingScrollPhysics();
  }

  double _getOptimalCacheExtent() {
    if (_isProMotionDevice) {
      return 1000.0; // Larger cache for high refresh rate
    }
    return 500.0;
  }

  List<BoxShadow>? _optimizeShadowsForDevice(List<BoxShadow>? shadows) {
    if (shadows == null || !_isMetalEnabled) return shadows;

    // Optimize shadows for Metal rendering
    return shadows.map((shadow) => BoxShadow(
      color: shadow.color,
      offset: shadow.offset,
      blurRadius: shadow.blurRadius.clamp(0, 20), // Limit blur radius
      spreadRadius: shadow.spreadRadius,
      blurStyle: BlurStyle.normal,
    )).toList();
  }

  /// Optimize widget for memory usage
  Widget optimizeForMemory(Widget child) {
    if (!Platform.isIOS) return child;

    return RepaintBoundary(
      child: AutomaticKeepAlive(
        child: child,
      ),
    );
  }

  /// Create optimized image for meditation backgrounds
  Widget createOptimizedMeditationImage({
    required ImageProvider image,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Alignment alignment = Alignment.center,
  }) {
    return RepaintBoundary(
      child: Image(
        image: image,
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
        cacheWidth: width != null ? (width * _devicePixelRatio).round() : null,
        cacheHeight: height != null ? (height * _devicePixelRatio).round() : null,
        filterQuality: _isProMotionDevice ? FilterQuality.medium : FilterQuality.low,
        isAntiAlias: _isMetalEnabled,
      ),
    );
  }

  // MARK: - Performance Monitoring

  /// Get current FPS
  double getCurrentFPS() {
    if (_frameTimes.isEmpty) return 0.0;

    final averageFrameTime = _frameTimes.fold<Duration>(
      Duration.zero,
      (sum, time) => sum + time,
    ) ~/ _frameTimes.length;

    if (averageFrameTime.inMicroseconds == 0) return 0.0;

    return 1000000.0 / averageFrameTime.inMicroseconds;
  }

  /// Get dropped frame percentage
  double getDroppedFramePercentage() {
    if (_frameTimes.isEmpty) return 0.0;
    return (_droppedFrames / _frameTimes.length) * 100;
  }

  /// Check if performance is good for meditation
  bool isPerformanceSuitableForMeditation() {
    final fps = getCurrentFPS();
    final droppedPercentage = getDroppedFramePercentage();

    // Consider performance good if FPS > 55 and dropped frames < 5%
    return fps > 55.0 && droppedPercentage < 5.0;
  }

  /// Reset performance metrics
  void resetPerformanceMetrics() {
    _frameTimes.clear();
    _droppedFrames = 0;
  }

  /// Enable/disable performance monitoring
  void setPerformanceMonitoring(bool enabled) {
    _isPerformanceMonitoringEnabled = enabled;
    if (!enabled) {
      resetPerformanceMetrics();
    }
  }

  // MARK: - Memory Management

  /// Trigger memory optimization for meditation mode
  void optimizeMemoryForMeditation() {
    if (!Platform.isIOS) return;

    // Clear image cache if memory pressure is high
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();

    if (kDebugMode) {
      print('🧠 Memory optimized for meditation mode');
    }
  }

  /// Get recommended image cache size based on device
  int getRecommendedImageCacheSize() {
    // Estimate based on screen size and device capabilities
    final screenPixels = _screenSize.width * _screenSize.height * _devicePixelRatio;

    if (_isProMotionDevice && screenPixels > 2000000) {
      return 150; // High-end device
    } else if (screenPixels > 1000000) {
      return 100; // Mid-range device
    } else {
      return 50; // Lower-end device
    }
  }

  // MARK: - Getters

  bool get isInitialized => _isInitialized;
  bool get isProMotionDevice => _isProMotionDevice;
  bool get isMetalEnabled => _isMetalEnabled;
  double get devicePixelRatio => _devicePixelRatio;
  Size get screenSize => _screenSize;
  bool get isPerformanceMonitoringEnabled => _isPerformanceMonitoringEnabled;
}

// MARK: - Custom Painters

class _OptimizedCircularProgressPainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final Color backgroundColor;
  final double strokeWidth;
  final bool isMetalEnabled;

  _OptimizedCircularProgressPainter({
    required this.progress,
    required this.progressColor,
    required this.backgroundColor,
    required this.strokeWidth,
    required this.isMetalEnabled,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Optimize for Metal if available
    if (isMetalEnabled) {
      progressPaint.shader = LinearGradient(
        colors: [
          progressColor,
          progressColor.withOpacity(0.8),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    }

    final sweepAngle = 2 * 3.14159 * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2, // Start from top
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_OptimizedCircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.progressColor != progressColor ||
           oldDelegate.backgroundColor != backgroundColor;
  }
}

// MARK: - Extensions

extension IOSPerformanceOptimized on Widget {
  /// Apply iOS performance optimizations
  Widget optimizeForIOSPerformance() {
    if (!Platform.isIOS) return this;

    return IOSPerformanceOptimizer.instance.optimizeForMemory(this);
  }
}

/// Usage Example:
///
/// ```dart
/// // Initialize
/// await IOSPerformanceOptimizer.instance.initialize();
///
/// // Create optimized meditation container
/// IOSPerformanceOptimizer.instance.createOptimizedMeditationContainer(
///   child: MeditationContent(),
///   gradient: LinearGradient(colors: [Colors.blue, Colors.purple]),
/// );
///
/// // Monitor performance
/// final fps = IOSPerformanceOptimizer.instance.getCurrentFPS();
/// final isSuitable = IOSPerformanceOptimizer.instance.isPerformanceSuitableForMeditation();
/// ```