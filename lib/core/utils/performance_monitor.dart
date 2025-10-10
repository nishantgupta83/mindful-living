import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

/// Performance monitoring utility for tracking frame rates and performance metrics
class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  factory PerformanceMonitor() => _instance;
  PerformanceMonitor._internal();

  // Performance metrics
  int _frameCount = 0;
  int _droppedFrames = 0;
  int _criticalFrames = 0;
  double _averageFrameTime = 0;
  double _maxFrameTime = 0;
  DateTime _startTime = DateTime.now();

  // Monitoring state
  bool _isMonitoring = false;
  Timer? _reportTimer;

  // Frame time thresholds (in milliseconds)
  static const double _targetFrameTime = 16.67; // 60 FPS
  static const double _warningFrameTime = 33.33; // 30 FPS
  static const double _criticalFrameTime = 100.0; // <10 FPS

  /// Start performance monitoring
  void startMonitoring() {
    if (_isMonitoring) return;

    _isMonitoring = true;
    _startTime = DateTime.now();
    _resetMetrics();

    // Add frame callback to monitor frame timing
    SchedulerBinding.instance.addTimingsCallback(_onFrameTimings);

    // Start periodic reporting
    _reportTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _reportMetrics();
    });

    if (kDebugMode) {
      print('🚀 Performance monitoring started');
    }
  }

  /// Stop performance monitoring
  void stopMonitoring() {
    if (!_isMonitoring) return;

    _isMonitoring = false;
    SchedulerBinding.instance.removeTimingsCallback(_onFrameTimings);
    _reportTimer?.cancel();

    _reportFinalMetrics();
  }

  /// Process frame timings
  void _onFrameTimings(List<FrameTiming> timings) {
    for (final timing in timings) {
      _frameCount++;

      // Calculate frame time in milliseconds
      final frameTime = (timing.totalSpan.inMicroseconds / 1000).toDouble();

      // Update metrics
      _averageFrameTime = ((_averageFrameTime * (_frameCount - 1)) + frameTime) / _frameCount;
      _maxFrameTime = frameTime > _maxFrameTime ? frameTime : _maxFrameTime;

      // Check for dropped/critical frames
      if (frameTime > _warningFrameTime) {
        _droppedFrames++;

        if (frameTime > _criticalFrameTime) {
          _criticalFrames++;

          if (kDebugMode) {
            print('⚠️ CRITICAL: Frame took ${frameTime.toStringAsFixed(0)}ms to render');
          }
        } else if (kDebugMode && frameTime > _warningFrameTime * 2) {
          print('⚠️ WARNING: Slow frame ${frameTime.toStringAsFixed(0)}ms');
        }
      }
    }
  }

  /// Reset all metrics
  void _resetMetrics() {
    _frameCount = 0;
    _droppedFrames = 0;
    _criticalFrames = 0;
    _averageFrameTime = 0;
    _maxFrameTime = 0;
  }

  /// Report current metrics
  void _reportMetrics() {
    if (!kDebugMode) return;

    final duration = DateTime.now().difference(_startTime);
    final fps = _frameCount / duration.inSeconds;
    final dropRate = (_droppedFrames / _frameCount * 100).toStringAsFixed(1);

    print('''
📊 Performance Report:
   FPS: ${fps.toStringAsFixed(1)}
   Frames: $_frameCount
   Dropped: $_droppedFrames ($dropRate%)
   Critical: $_criticalFrames
   Avg Frame Time: ${_averageFrameTime.toStringAsFixed(1)}ms
   Max Frame Time: ${_maxFrameTime.toStringAsFixed(1)}ms
''');
  }

  /// Report final metrics when stopping
  void _reportFinalMetrics() {
    if (!kDebugMode) return;

    final duration = DateTime.now().difference(_startTime);

    print('''
🚀 Performance Summary:
   Total Duration: ${duration.inSeconds}s
   Total Frames: $_frameCount
   Average FPS: ${(_frameCount / duration.inSeconds).toStringAsFixed(1)}
   Average Frame Time: ${_averageFrameTime.toStringAsFixed(1)}ms
   Max Frame Time: ${_maxFrameTime.toStringAsFixed(1)}ms
   Dropped Frames: $_droppedFrames
   Critical Frames: $_criticalFrames
''');
  }

  /// Get current performance metrics
  Map<String, dynamic> getMetrics() {
    final duration = DateTime.now().difference(_startTime);
    final fps = duration.inSeconds > 0 ? _frameCount / duration.inSeconds : 0.0;

    return {
      'fps': fps,
      'frameCount': _frameCount,
      'droppedFrames': _droppedFrames,
      'criticalFrames': _criticalFrames,
      'averageFrameTime': _averageFrameTime,
      'maxFrameTime': _maxFrameTime,
      'uptime': duration.inSeconds,
    };
  }

  /// Check if performance is good
  bool isPerformanceGood() {
    return _averageFrameTime < _warningFrameTime && _criticalFrames == 0;
  }

  /// Track a custom event timing
  Future<T> trackOperation<T>(String name, Future<T> Function() operation) async {
    final stopwatch = Stopwatch()..start();

    try {
      final result = await operation();
      stopwatch.stop();

      if (kDebugMode && stopwatch.elapsedMilliseconds > 100) {
        print('⏱️ $name took ${stopwatch.elapsedMilliseconds}ms');
      }

      return result;
    } catch (e) {
      stopwatch.stop();
      if (kDebugMode) {
        print('❌ $name failed after ${stopwatch.elapsedMilliseconds}ms: $e');
      }
      rethrow;
    }
  }

  /// Track widget build time
  void trackWidgetBuild(String widgetName, void Function() buildFunction) {
    if (!kDebugMode) return;

    final stopwatch = Stopwatch()..start();
    buildFunction();
    stopwatch.stop();

    if (stopwatch.elapsedMicroseconds > 1000) {
      print('🏗️ $widgetName build: ${stopwatch.elapsedMicroseconds / 1000}ms');
    }
  }
}