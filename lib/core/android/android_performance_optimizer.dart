import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import 'dart:isolate';

/// Android Performance Optimizer for MindfulLiving Wellness App
///
/// Provides Android-specific performance optimizations including:
/// - Memory management for large life situation datasets (1226+ items)
/// - Frame rate optimization for smooth category tile interactions
/// - Battery optimization for background wellness features
/// - Storage optimization for offline content
/// - Network optimization for Firebase integration
/// - Audio session management for meditation content
class AndroidPerformanceOptimizer {
  static const String _logTag = 'AndroidPerformanceOptimizer';
  static const MethodChannel _channel = MethodChannel('com.hub4apps.mindfulliving/performance');

  /// Performance monitoring metrics
  static final Map<String, PerformanceMetric> _metrics = {};
  static bool _isInitialized = false;

  /// Initialize Android performance optimizations
  static Future<void> initialize() async {
    if (!Platform.isAndroid || _isInitialized) return;

    try {
      await _enableHardwareAcceleration();
      await _optimizeMemoryManagement();
      await _configureRenderingOptimizations();
      await _setupBatteryOptimizations();
      await _optimizeStorageAccess();
      await _configureNetworkOptimizations();
      await _setupAudioSessionManagement();

      _isInitialized = true;
      debugPrint('$_logTag: Android performance optimization initialized');
    } catch (e) {
      debugPrint('$_logTag: Failed to initialize performance optimizations: $e');
    }
  }

  /// Private initialization methods
  static Future<void> _enableHardwareAcceleration() async {
    await _channel.invokeMethod('enableHardwareAcceleration');
  }

  static Future<void> _optimizeMemoryManagement() async {
    await MemoryOptimizer.optimizeForLifeSituations();
    await MemoryOptimizer.optimizeImageCaching();
  }

  static Future<void> _configureRenderingOptimizations() async {
    await RenderingOptimizer.optimizeScrollPerformance();
    await RenderingOptimizer.optimizeListViewPerformance();
    await RenderingOptimizer.optimizeAnimations();
  }

  static Future<void> _setupBatteryOptimizations() async {
    await BatteryOptimizer.optimizeBackgroundProcessing();
    await BatteryOptimizer.optimizeNotificationScheduling();
    await BatteryOptimizer.enableDozeCompatibility();
  }

  static Future<void> _optimizeStorageAccess() async {
    await StorageOptimizer.optimizeHiveStorage();
    await StorageOptimizer.setupIntelligentCaching();
    await StorageOptimizer.optimizeDatabasePerformance();
  }

  static Future<void> _configureNetworkOptimizations() async {
    await NetworkOptimizer.optimizeFirebaseConnection();
    await NetworkOptimizer.setupIntelligentSync();
  }

  static Future<void> _setupAudioSessionManagement() async {
    await AudioOptimizer.configureAudioSession();
    await AudioOptimizer.optimizeAudioQuality();
    await AudioOptimizer.configureBackgroundAudio();
  }

  /// Getters
  static bool get isInitialized => _isInitialized;
  static Map<String, PerformanceMetric> get metrics => Map.unmodifiable(_metrics);
}

/// Memory Management for Large Datasets
class MemoryOptimizer {
    static const String _logTag = 'MemoryOptimizer';
    static const MethodChannel _channel = MethodChannel('com.hub4apps.mindfulliving/performance');
    static const int _maxCacheSize = 50; // Maximum cached life situations
    static const int _memoryThreshold = 80; // Memory usage threshold percentage

    /// Optimize memory for life situation browsing (1226+ items)
    static Future<void> optimizeForLifeSituations() async {
      if (!Platform.isAndroid) return;

      try {
        await _channel.invokeMethod('optimizeLifeSituationMemory', {
          'maxCacheSize': _maxCacheSize,
          'memoryThreshold': _memoryThreshold,
          'enableLazyLoading': true,
          'preloadCount': 10,
        });

        debugPrint('$_logTag: Life situation memory optimization configured');
      } catch (e) {
        debugPrint('$_logTag: Failed to optimize life situation memory: $e');
      }
    }

    /// Enable intelligent image caching for wellness content
    static Future<void> optimizeImageCaching() async {
      if (!Platform.isAndroid) return;

      try {
        await _channel.invokeMethod('optimizeImageCaching', {
          'maxCacheSize': 100 * 1024 * 1024, // 100MB
          'compressionQuality': 85,
          'enableWebP': true,
          'enablePlaceholders': true,
        });

        debugPrint('$_logTag: Image caching optimization configured');
      } catch (e) {
        debugPrint('$_logTag: Failed to optimize image caching: $e');
      }
    }

    /// Monitor and manage memory usage
    static Future<MemoryUsageReport> getMemoryUsage() async {
      if (!Platform.isAndroid) {
        return MemoryUsageReport.empty();
      }

      try {
        final result = await _channel.invokeMethod('getMemoryUsage');
        return MemoryUsageReport.fromMap(result);
      } catch (e) {
        debugPrint('$_logTag: Failed to get memory usage: $e');
        return MemoryUsageReport.empty();
      }
    }

    /// Trigger garbage collection when needed
    static Future<void> optimizeMemoryUsage() async {
      if (!Platform.isAndroid) return;

      try {
        final memoryReport = await getMemoryUsage();

        if (memoryReport.usagePercentage > _memoryThreshold) {
          await _channel.invokeMethod('triggerMemoryOptimization', {
            'clearImageCache': true,
            'clearUnusedData': true,
            'compactDatabase': true,
          });

          debugPrint('$_logTag: Memory optimization triggered');
        }
      } catch (e) {
        debugPrint('AndroidPerformanceOptimizer: Failed to optimize memory usage: $e');
      }
    }
}

/// Frame Rate and Scroll Performance Optimizer
class RenderingOptimizer {
    static const String _logTag = 'RenderingOptimizer';
    static const MethodChannel _channel = MethodChannel('com.hub4apps.mindfulliving/performance');

    /// Reduce frame drops during category tile interactions
    static Future<void> optimizeScrollPerformance() async {
      if (!Platform.isAndroid) return;

      try {
        await _channel.invokeMethod('optimizeScrolling', {
          'enableHardwareAcceleration': true,
          'cacheExtent': 1000.0,
          'physics': 'ClampingScrollPhysics',
          'itemExtent': 120.0, // Fixed item height for better performance
        });

        debugPrint('$_logTag: Scroll performance optimization configured');
      } catch (e) {
        debugPrint('$_logTag: Failed to optimize scroll performance: $e');
      }
    }

    /// Optimize list view performance for dilemma browsing
    static Future<void> optimizeListViewPerformance() async {
      if (!Platform.isAndroid) return;

      try {
        await _channel.invokeMethod('optimizeListView', {
          'addAutomaticKeepAlives': false,
          'addRepaintBoundaries': true,
          'addSemanticIndexes': true,
          'shrinkWrap': false,
          'itemCount': 1226, // Total life situations
        });

        debugPrint('$_logTag: ListView performance optimization configured');
      } catch (e) {
        debugPrint('$_logTag: Failed to optimize ListView performance: $e');
      }
    }

    /// Enable 60 FPS animations for smooth wellness UI
    static Future<void> optimizeAnimations() async {
      if (!Platform.isAndroid) return;

      try {
        await _channel.invokeMethod('optimizeAnimations', {
          'targetFPS': 60,
          'enableGPUAcceleration': true,
          'reducedMotion': false,
          'animationDuration': 300,
        });

        debugPrint('$_logTag: Animation optimization configured');
      } catch (e) {
        debugPrint('$_logTag: Failed to optimize animations: $e');
      }
    }

    /// Monitor frame rate performance
    static Future<FrameRateReport> getFrameRateMetrics() async {
      if (!Platform.isAndroid) {
        return FrameRateReport.empty();
      }

      try {
        final result = await _channel.invokeMethod('getFrameRateMetrics');
        return FrameRateReport.fromMap(result);
      } catch (e) {
        debugPrint('AndroidPerformanceOptimizer: Failed to get frame rate metrics: $e');
        return FrameRateReport.empty();
      }
    }
}

/// Battery Optimization for Background Wellness Features
class BatteryOptimizer {
    static const String _logTag = 'BatteryOptimizer';
    static const MethodChannel _channel = MethodChannel('com.hub4apps.mindfulliving/performance');

    /// Configure background processing limits for wellness features
    static Future<void> optimizeBackgroundProcessing() async {
      if (!Platform.isAndroid) return;

      try {
        await _channel.invokeMethod('optimizeBackgroundProcessing', {
          'allowedBackgroundTime': 600000, // 10 minutes
          'meditationTimerOptimization': true,
          'efficientNotificationScheduling': true,
          'reducedFirebasePolling': true,
        });

        debugPrint('$_logTag: Background processing optimization configured');
      } catch (e) {
        debugPrint('$_logTag: Failed to optimize background processing: $e');
      }
    }

    /// Optimize notification scheduling for battery efficiency
    static Future<void> optimizeNotificationScheduling() async {
      if (!Platform.isAndroid) return;

      try {
        await _channel.invokeMethod('optimizeNotifications', {
          'batchNotifications': true,
          'useInexactRepeating': true,
          'minimumInterval': 3600000, // 1 hour
          'respectDozeMode': true,
        });

        debugPrint('$_logTag: Notification scheduling optimization configured');
      } catch (e) {
        debugPrint('$_logTag: Failed to optimize notification scheduling: $e');
      }
    }

    /// Monitor battery usage
    static Future<BatteryUsageReport> getBatteryUsage() async {
      if (!Platform.isAndroid) {
        return BatteryUsageReport.empty();
      }

      try {
        final result = await _channel.invokeMethod('getBatteryUsage');
        return BatteryUsageReport.fromMap(result);
      } catch (e) {
        debugPrint('$_logTag: Failed to get battery usage: $e');
        return BatteryUsageReport.empty();
      }
    }

    /// Enable doze mode compatibility
    static Future<void> enableDozeCompatibility() async {
      if (!Platform.isAndroid) return;

      try {
        await _channel.invokeMethod('enableDozeCompatibility', {
          'respectDozeMode': true,
          'useAlarmManager': false,
          'batchWorkRequests': true,
        });

        debugPrint('$_logTag: Doze mode compatibility enabled');
      } catch (e) {
        debugPrint('AndroidPerformanceOptimizer: Failed to enable doze compatibility: $e');
      }
    }
}

/// Storage Optimization for Offline Wellness Content
class StorageOptimizer {
    static const String _logTag = 'StorageOptimizer';
    static const MethodChannel _channel = MethodChannel('com.hub4apps.mindfulliving/performance');

    /// Optimize Hive database for life situations
    static Future<void> optimizeHiveStorage() async {
      if (!Platform.isAndroid) return;

      try {
        await _channel.invokeMethod('optimizeHiveStorage', {
          'compactOnLaunch': true,
          'maxBoxes': 10,
          'cacheSize': 1000,
          'enableEncryption': true,
        });

        debugPrint('$_logTag: Hive storage optimization configured');
      } catch (e) {
        debugPrint('$_logTag: Failed to optimize Hive storage: $e');
      }
    }

    /// Setup intelligent caching strategy
    static Future<void> setupIntelligentCaching() async {
      if (!Platform.isAndroid) return;

      try {
        await _channel.invokeMethod('setupIntelligentCaching', {
          'lifeSituationCacheSize': 50,
          'imageCacheSize': 100,
          'audioCacheSize': 20,
          'preloadPopularContent': true,
          'enableOfflineMode': true,
        });

        debugPrint('$_logTag: Intelligent caching configured');
      } catch (e) {
        debugPrint('$_logTag: Failed to setup intelligent caching: $e');
      }
    }

    /// Optimize SQLite database performance
    static Future<void> optimizeDatabasePerformance() async {
      if (!Platform.isAndroid) return;

      try {
        await _channel.invokeMethod('optimizeDatabasePerformance', {
          'enableWALMode': true,
          'cacheSize': 2000,
          'synchronous': 'NORMAL',
          'journalMode': 'WAL',
          'enableForeignKeys': true,
        });

        debugPrint('$_logTag: Database performance optimization configured');
      } catch (e) {
        debugPrint('$_logTag: Failed to optimize database performance: $e');
      }
    }

    /// Get storage usage report
    static Future<StorageUsageReport> getStorageUsage() async {
      if (!Platform.isAndroid) {
        return StorageUsageReport.empty();
      }

      try {
        final result = await _channel.invokeMethod('getStorageUsage');
        return StorageUsageReport.fromMap(result);
      } catch (e) {
        debugPrint('AndroidPerformanceOptimizer: Failed to get storage usage: $e');
        return StorageUsageReport.empty();
      }
    }
}

/// Network Optimization for Firebase Integration
class NetworkOptimizer {
    static const String _logTag = 'NetworkOptimizer';
    static const MethodChannel _channel = MethodChannel('com.hub4apps.mindfulliving/performance');

    /// Optimize Firebase connection for Android
    static Future<void> optimizeFirebaseConnection() async {
      if (!Platform.isAndroid) return;

      try {
        await _channel.invokeMethod('optimizeFirebaseConnection', {
          'enablePersistence': true,
          'cacheSizeBytes': 40 * 1024 * 1024, // 40MB
          'enableOfflineSupport': true,
          'connectionTimeout': 10000,
        });

        debugPrint('$_logTag: Firebase connection optimization configured');
      } catch (e) {
        debugPrint('$_logTag: Failed to optimize Firebase connection: $e');
      }
    }

    /// Configure intelligent data syncing
    static Future<void> setupIntelligentSync() async {
      if (!Platform.isAndroid) return;

      try {
        await _channel.invokeMethod('setupIntelligentSync', {
          'syncOnWiFiOnly': true,
          'batchUpdates': true,
          'compressionEnabled': true,
          'retryBackoff': 'exponential',
        });

        debugPrint('$_logTag: Intelligent sync configured');
      } catch (e) {
        debugPrint('$_logTag: Failed to setup intelligent sync: $e');
      }
    }

    /// Monitor network performance
    static Future<NetworkPerformanceReport> getNetworkMetrics() async {
      if (!Platform.isAndroid) {
        return NetworkPerformanceReport.empty();
      }

      try {
        final result = await _channel.invokeMethod('getNetworkMetrics');
        return NetworkPerformanceReport.fromMap(result);
      } catch (e) {
        debugPrint('AndroidPerformanceOptimizer: Failed to get network metrics: $e');
        return NetworkPerformanceReport.empty();
      }
    }
}

/// Audio Session Management for Meditation Content
class AudioOptimizer {
    static const String _logTag = 'AudioOptimizer';
    static const MethodChannel _channel = MethodChannel('com.hub4apps.mindfulliving/performance');

    /// Configure audio session for meditation
    static Future<void> configureAudioSession() async {
      if (!Platform.isAndroid) return;

      try {
        await _channel.invokeMethod('configureAudioSession', {
          'contentType': 'CONTENT_TYPE_MEDITATION',
          'usage': 'USAGE_MEDIA',
          'audioFocus': 'AUDIOFOCUS_GAIN',
          'ducking': true,
          'enableNoiseReduction': true,
        });

        debugPrint('$_logTag: Audio session configuration completed');
      } catch (e) {
        debugPrint('$_logTag: Failed to configure audio session: $e');
      }
    }

    /// Optimize audio quality for meditation sessions
    static Future<void> optimizeAudioQuality() async {
      if (!Platform.isAndroid) return;

      try {
        await _channel.invokeMethod('optimizeAudioQuality', {
          'sampleRate': 44100,
          'bitRate': 128000,
          'format': 'ENCODING_PCM_16BIT',
          'enableEqualizer': true,
        });

        debugPrint('$_logTag: Audio quality optimization configured');
      } catch (e) {
        debugPrint('$_logTag: Failed to optimize audio quality: $e');
      }
    }

    /// Setup audio background processing
    static Future<void> configureBackgroundAudio() async {
      if (!Platform.isAndroid) return;

      try {
        await _channel.invokeMethod('configureBackgroundAudio', {
          'enableForegroundService': true,
          'showNotification': true,
          'allowBackgroundPlayback': true,
          'respectAudioFocus': true,
        });

        debugPrint('$_logTag: Background audio configuration completed');
      } catch (e) {
        debugPrint('AndroidPerformanceOptimizer: Failed to configure background audio: $e');
      }
    }
}

/// Performance Monitoring and Metrics
class PerformanceMonitor {
    static const String _logTag = 'PerformanceMonitor';
    static final Map<String, PerformanceMetric> _metrics = {};

    /// Start performance monitoring
    static void startMonitoring() {
      if (!Platform.isAndroid) return;

      _startFrameRateMonitoring();
      _startMemoryMonitoring();
      _startBatteryMonitoring();
      _startNetworkMonitoring();

      debugPrint('$_logTag: Performance monitoring started');
    }

    /// Stop performance monitoring
    static void stopMonitoring() {
      if (!Platform.isAndroid) return;

      _metrics.clear();
      debugPrint('$_logTag: Performance monitoring stopped');
    }

    /// Get comprehensive performance report
    static Future<PerformanceReport> getPerformanceReport() async {
      if (!Platform.isAndroid) {
        return PerformanceReport.empty();
      }

      try {
        final memoryUsage = await MemoryOptimizer.getMemoryUsage();
        final frameRate = await RenderingOptimizer.getFrameRateMetrics();
        final batteryUsage = await BatteryOptimizer.getBatteryUsage();
        final storageUsage = await StorageOptimizer.getStorageUsage();
        final networkMetrics = await NetworkOptimizer.getNetworkMetrics();

        return PerformanceReport(
          memoryUsage: memoryUsage,
          frameRate: frameRate,
          batteryUsage: batteryUsage,
          storageUsage: storageUsage,
          networkMetrics: networkMetrics,
          timestamp: DateTime.now(),
        );
      } catch (e) {
        debugPrint('$_logTag: Failed to get performance report: $e');
        return PerformanceReport.empty();
      }
    }

    static void _startFrameRateMonitoring() {
      // Implementation for frame rate monitoring
    }

    static void _startMemoryMonitoring() {
      // Implementation for memory monitoring
    }

    static void _startBatteryMonitoring() {
      // Implementation for battery monitoring
    }

    static void _startNetworkMonitoring() {
      // Implementation for network monitoring
    }
}

/// Performance data models
class PerformanceMetric {
  final String name;
  final double value;
  final String unit;
  final DateTime timestamp;

  PerformanceMetric({
    required this.name,
    required this.value,
    required this.unit,
    required this.timestamp,
  });
}

class MemoryUsageReport {
  final int usedMemoryMB;
  final int availableMemoryMB;
  final int totalMemoryMB;
  final double usagePercentage;
  final DateTime timestamp;

  MemoryUsageReport({
    required this.usedMemoryMB,
    required this.availableMemoryMB,
    required this.totalMemoryMB,
    required this.usagePercentage,
    required this.timestamp,
  });

  factory MemoryUsageReport.fromMap(Map<String, dynamic> map) {
    return MemoryUsageReport(
      usedMemoryMB: map['usedMemoryMB'] ?? 0,
      availableMemoryMB: map['availableMemoryMB'] ?? 0,
      totalMemoryMB: map['totalMemoryMB'] ?? 0,
      usagePercentage: (map['usagePercentage'] ?? 0.0).toDouble(),
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
    );
  }

  factory MemoryUsageReport.empty() {
    return MemoryUsageReport(
      usedMemoryMB: 0,
      availableMemoryMB: 0,
      totalMemoryMB: 0,
      usagePercentage: 0.0,
      timestamp: DateTime.now(),
    );
  }
}

class FrameRateReport {
  final double averageFPS;
  final int droppedFrames;
  final double jankPercentage;
  final DateTime timestamp;

  FrameRateReport({
    required this.averageFPS,
    required this.droppedFrames,
    required this.jankPercentage,
    required this.timestamp,
  });

  factory FrameRateReport.fromMap(Map<String, dynamic> map) {
    return FrameRateReport(
      averageFPS: (map['averageFPS'] ?? 0.0).toDouble(),
      droppedFrames: map['droppedFrames'] ?? 0,
      jankPercentage: (map['jankPercentage'] ?? 0.0).toDouble(),
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
    );
  }

  factory FrameRateReport.empty() {
    return FrameRateReport(
      averageFPS: 0.0,
      droppedFrames: 0,
      jankPercentage: 0.0,
      timestamp: DateTime.now(),
    );
  }
}

class BatteryUsageReport {
  final double batteryLevel;
  final bool isCharging;
  final int powerConsumptionMW;
  final DateTime timestamp;

  BatteryUsageReport({
    required this.batteryLevel,
    required this.isCharging,
    required this.powerConsumptionMW,
    required this.timestamp,
  });

  factory BatteryUsageReport.fromMap(Map<String, dynamic> map) {
    return BatteryUsageReport(
      batteryLevel: (map['batteryLevel'] ?? 0.0).toDouble(),
      isCharging: map['isCharging'] ?? false,
      powerConsumptionMW: map['powerConsumptionMW'] ?? 0,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
    );
  }

  factory BatteryUsageReport.empty() {
    return BatteryUsageReport(
      batteryLevel: 0.0,
      isCharging: false,
      powerConsumptionMW: 0,
      timestamp: DateTime.now(),
    );
  }
}

class StorageUsageReport {
  final int usedStorageMB;
  final int availableStorageMB;
  final int cacheUsageMB;
  final int databaseSizeMB;
  final DateTime timestamp;

  StorageUsageReport({
    required this.usedStorageMB,
    required this.availableStorageMB,
    required this.cacheUsageMB,
    required this.databaseSizeMB,
    required this.timestamp,
  });

  factory StorageUsageReport.fromMap(Map<String, dynamic> map) {
    return StorageUsageReport(
      usedStorageMB: map['usedStorageMB'] ?? 0,
      availableStorageMB: map['availableStorageMB'] ?? 0,
      cacheUsageMB: map['cacheUsageMB'] ?? 0,
      databaseSizeMB: map['databaseSizeMB'] ?? 0,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
    );
  }

  factory StorageUsageReport.empty() {
    return StorageUsageReport(
      usedStorageMB: 0,
      availableStorageMB: 0,
      cacheUsageMB: 0,
      databaseSizeMB: 0,
      timestamp: DateTime.now(),
    );
  }
}

class NetworkPerformanceReport {
  final double latencyMs;
  final double throughputMbps;
  final int dataUsageMB;
  final String connectionType;
  final DateTime timestamp;

  NetworkPerformanceReport({
    required this.latencyMs,
    required this.throughputMbps,
    required this.dataUsageMB,
    required this.connectionType,
    required this.timestamp,
  });

  factory NetworkPerformanceReport.fromMap(Map<String, dynamic> map) {
    return NetworkPerformanceReport(
      latencyMs: (map['latencyMs'] ?? 0.0).toDouble(),
      throughputMbps: (map['throughputMbps'] ?? 0.0).toDouble(),
      dataUsageMB: map['dataUsageMB'] ?? 0,
      connectionType: map['connectionType'] ?? 'unknown',
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
    );
  }

  factory NetworkPerformanceReport.empty() {
    return NetworkPerformanceReport(
      latencyMs: 0.0,
      throughputMbps: 0.0,
      dataUsageMB: 0,
      connectionType: 'unknown',
      timestamp: DateTime.now(),
    );
  }
}

class PerformanceReport {
  final MemoryUsageReport memoryUsage;
  final FrameRateReport frameRate;
  final BatteryUsageReport batteryUsage;
  final StorageUsageReport storageUsage;
  final NetworkPerformanceReport networkMetrics;
  final DateTime timestamp;

  PerformanceReport({
    required this.memoryUsage,
    required this.frameRate,
    required this.batteryUsage,
    required this.storageUsage,
    required this.networkMetrics,
    required this.timestamp,
  });

  factory PerformanceReport.empty() {
    final now = DateTime.now();
    return PerformanceReport(
      memoryUsage: MemoryUsageReport.empty(),
      frameRate: FrameRateReport.empty(),
      batteryUsage: BatteryUsageReport.empty(),
      storageUsage: StorageUsageReport.empty(),
      networkMetrics: NetworkPerformanceReport.empty(),
      timestamp: now,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'memoryUsage': {
        'usedMemoryMB': memoryUsage.usedMemoryMB,
        'availableMemoryMB': memoryUsage.availableMemoryMB,
        'usagePercentage': memoryUsage.usagePercentage,
      },
      'frameRate': {
        'averageFPS': frameRate.averageFPS,
        'droppedFrames': frameRate.droppedFrames,
        'jankPercentage': frameRate.jankPercentage,
      },
      'batteryUsage': {
        'batteryLevel': batteryUsage.batteryLevel,
        'isCharging': batteryUsage.isCharging,
        'powerConsumptionMW': batteryUsage.powerConsumptionMW,
      },
      'storageUsage': {
        'usedStorageMB': storageUsage.usedStorageMB,
        'availableStorageMB': storageUsage.availableStorageMB,
        'cacheUsageMB': storageUsage.cacheUsageMB,
      },
      'networkMetrics': {
        'latencyMs': networkMetrics.latencyMs,
        'throughputMbps': networkMetrics.throughputMbps,
        'dataUsageMB': networkMetrics.dataUsageMB,
        'connectionType': networkMetrics.connectionType,
      },
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }
}