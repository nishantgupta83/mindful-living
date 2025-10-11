// iOS Experience Expert Agent for MindfulLiving Wellness App
// Specialized agent focusing on iOS platform excellence and native iOS wellness features

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';

/// iOS Experience Expert Agent
/// Provides iOS-specific optimizations, native feel, and wellness-focused features
class IOSExperienceAgent {
  static IOSExperienceAgent? _instance;
  static IOSExperienceAgent get instance => _instance ??= IOSExperienceAgent._();
  IOSExperienceAgent._();

  // Device capabilities
  bool _isInitialized = false;
  bool _isProMotionDevice = false;
  bool _hasNotchOrDynamicIsland = false;
  bool _supportsHaptics = false;
  double _refreshRate = 60.0;

  // iOS Wellness Framework Integration
  bool _healthKitAvailable = false;
  bool _siriShortcutsAvailable = false;

  /// Initialize iOS Experience Agent
  Future<void> initialize() async {
    if (_isInitialized || !Platform.isIOS) return;

    await _detectIOSCapabilities();
    await _setupIOSSpecificFeatures();
    _isInitialized = true;

    if (kDebugMode) {
      print('🍎 iOS Experience Agent initialized');
      print('📱 ProMotion: $_isProMotionDevice (${_refreshRate}Hz)');
      print('🔄 Haptics: $_supportsHaptics');
      print('🏥 HealthKit: $_healthKitAvailable');
      print('🗣️ Siri Shortcuts: $_siriShortcutsAvailable');
    }
  }

  Future<void> _detectIOSCapabilities() async {
    try {
      final display = WidgetsBinding.instance.platformDispatcher.displays.first;
      _refreshRate = display.refreshRate;
      _isProMotionDevice = _refreshRate >= 120;
      _supportsHaptics = Platform.isIOS; // iOS 7+ supports basic haptics

      // Detect notch/Dynamic Island (approximate based on screen size)
      final size = display.size / display.devicePixelRatio;
      _hasNotchOrDynamicIsland = size.height >= 812; // iPhone X and newer

      // Check for iOS wellness frameworks (would need platform channels in production)
      _healthKitAvailable = Platform.isIOS; // iOS 8+
      _siriShortcutsAvailable = Platform.isIOS; // iOS 12+
    } catch (e) {
      if (kDebugMode) print('iOS capability detection error: $e');
    }
  }

  Future<void> _setupIOSSpecificFeatures() async {
    if (!Platform.isIOS) return;

    // Configure iOS-specific system UI
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarAnimation: StatusBarAnimation.fade,
      ),
    );
  }

  // MARK: - iOS Performance Optimizations

  /// Get optimal animation duration for iOS devices
  Duration getIOSAnimationDuration({
    required IOSAnimationType type,
    bool isUserInteraction = false,
  }) {
    if (!Platform.isIOS) return const Duration(milliseconds: 300);

    switch (type) {
      case IOSAnimationType.interactive:
        return _isProMotionDevice
            ? const Duration(milliseconds: 200)
            : const Duration(milliseconds: 250);
      case IOSAnimationType.navigation:
        return const Duration(milliseconds: 350);
      case IOSAnimationType.meditation:
        return const Duration(milliseconds: 500); // Slower for wellness
      case IOSAnimationType.breathing:
        return const Duration(seconds: 4); // Breathing exercise timing
    }
  }

  /// Get iOS-native curves for different wellness interactions
  Curve getIOSAnimationCurve({required IOSAnimationType type}) {
    if (!Platform.isIOS) return Curves.easeInOut;

    switch (type) {
      case IOSAnimationType.interactive:
        return _isProMotionDevice
            ? Curves.easeInOutCubicEmphasized
            : Curves.easeInOut;
      case IOSAnimationType.navigation:
        return Curves.fastEaseInToSlowEaseOut;
      case IOSAnimationType.meditation:
        return Curves.easeInOutSine; // Gentle for wellness
      case IOSAnimationType.breathing:
        return Curves.easeInOutQuart; // Smooth breathing rhythm
    }
  }

  // MARK: - iOS Audio Session Management

  /// Configure iOS audio session for wellness content
  Future<void> configureAudioSessionForWellness({
    required WellnessAudioType audioType,
  }) async {
    if (!Platform.isIOS) return;

    // In production, this would use platform channels to configure AVAudioSession
    if (kDebugMode) {
      print('🎵 Configuring iOS audio session for: $audioType');
    }
  }

  /// Handle iOS background audio for meditation
  Future<void> enableBackgroundAudio() async {
    if (!Platform.isIOS) return;

    // Configure for background audio playback
    if (kDebugMode) {
      print('🎵 Enabling iOS background audio for meditation');
    }
  }

  // MARK: - iOS Haptic Feedback

  /// Provide iOS-native haptic feedback for wellness interactions
  Future<void> provideWellnessHaptic({required IOSHapticType type}) async {
    if (!Platform.isIOS || !_supportsHaptics) return;

    switch (type) {
      case IOSHapticType.breathingStart:
        await HapticFeedback.lightImpact();
        break;
      case IOSHapticType.breathingPeak:
        await HapticFeedback.mediumImpact();
        break;
      case IOSHapticType.meditationChime:
        await HapticFeedback.heavyImpact();
        break;
      case IOSHapticType.goalAchievement:
        // Success feedback pattern
        await HapticFeedback.mediumImpact();
        await Future.delayed(const Duration(milliseconds: 100));
        await HapticFeedback.lightImpact();
        break;
      case IOSHapticType.gentleNotification:
        await HapticFeedback.selectionClick();
        break;
    }
  }

  // MARK: - iOS Widgets and UI Components

  /// Create iOS-native styled card for wellness content
  Widget createIOSWellnessCard({
    required Widget child,
    Color? backgroundColor,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    bool elevated = true,
    VoidCallback? onTap,
  }) {
    final card = Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(12), // iOS rounded corners
        boxShadow: elevated ? [
          BoxShadow(
            color: CupertinoColors.systemGrey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ] : null,
      ),
      child: child,
    );

    if (onTap != null) {
      return CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onTap,
        child: card,
      );
    }

    return Platform.isIOS ? RepaintBoundary(child: card) : card;
  }

  /// Create iOS-optimized list for wellness content
  Widget createIOSWellnessList({
    required Widget Function(BuildContext, int) itemBuilder,
    required int itemCount,
    ScrollController? controller,
    EdgeInsets? padding,
    bool useIOSPhysics = true,
  }) {
    return ListView.builder(
      controller: controller,
      padding: padding ?? EdgeInsets.only(
        top: _hasNotchOrDynamicIsland ? 20 : 8,
        bottom: 34, // iOS home indicator space
      ),
      physics: useIOSPhysics && Platform.isIOS
          ? const BouncingScrollPhysics()
          : const ClampingScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return RepaintBoundary(
          child: itemBuilder(context, index),
        );
      },
      cacheExtent: _isProMotionDevice ? 800.0 : 400.0,
    );
  }

  /// Create iOS-style navigation bar for wellness sections
  Widget createIOSWellnessNavBar({
    required String title,
    Widget? leading,
    List<Widget>? trailing,
    bool useLargeTitle = true,
  }) {
    if (!Platform.isIOS) {
      return AppBar(
        title: Text(title),
        leading: leading,
        actions: trailing,
      );
    }

    return CupertinoNavigationBar(
      middle: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
      leading: leading,
      trailing: trailing?.isNotEmpty == true
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: trailing!,
            )
          : null,
      backgroundColor: CupertinoColors.systemBackground.withValues(alpha: 0.9),
      border: null,
    );
  }

  // MARK: - iOS Wellness-Specific Features

  /// Create breathing exercise widget with iOS optimizations
  Widget createIOSBreathingExercise({
    required AnimationController controller,
    required VoidCallback onStart,
    required VoidCallback onStop,
    Color? primaryColor,
  }) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final scale = 1.0 + (controller.value * 0.3);
        final opacity = 0.7 + (controller.value * 0.3);

        return Transform.scale(
          scale: scale,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  (primaryColor ?? AppColors.deepLavender).withValues(alpha: opacity),
                  (primaryColor ?? AppColors.deepLavender).withValues(alpha: 0.1),
                ],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    controller.isAnimating ? Icons.pause : Icons.play_arrow,
                    size: 40,
                    color: CupertinoColors.white,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    controller.isAnimating ? 'Breathe' : 'Start',
                    style: const TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Create iOS-optimized meditation timer
  Widget createIOSMeditationTimer({
    required Duration duration,
    required Duration elapsed,
    required VoidCallback onStart,
    required VoidCallback onPause,
    required VoidCallback onStop,
    bool isRunning = false,
  }) {
    final progress = elapsed.inMilliseconds / duration.inMilliseconds;

    return Column(
      children: [
        // Circular progress indicator with iOS styling
        SizedBox(
          width: 200,
          height: 200,
          child: CircularProgressIndicator.adaptive(
            value: progress.clamp(0.0, 1.0),
            strokeWidth: 8,
            backgroundColor: CupertinoColors.systemGrey5,
            valueColor: AlwaysStoppedAnimation(AppColors.deepLavender),
          ),
        ),

        const SizedBox(height: 24),

        // Time display
        Text(
          _formatDuration(elapsed),
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w200,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'of ${_formatDuration(duration)}',
          style: TextStyle(
            fontSize: 16,
            color: CupertinoColors.systemGrey,
          ),
        ),

        const SizedBox(height: 32),

        // iOS-style control buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CupertinoButton(
              onPressed: onStop,
              child: const Icon(
                CupertinoIcons.stop_fill,
                size: 24,
                color: CupertinoColors.systemRed,
              ),
            ),
            CupertinoButton(
              onPressed: isRunning ? onPause : onStart,
              child: Icon(
                isRunning ? CupertinoIcons.pause_fill : CupertinoIcons.play_fill,
                size: 32,
                color: AppColors.deepLavender,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // MARK: - Helper Methods

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // MARK: - Getters

  bool get isInitialized => _isInitialized;
  bool get isProMotionDevice => _isProMotionDevice;
  bool get hasNotchOrDynamicIsland => _hasNotchOrDynamicIsland;
  bool get supportsHaptics => _supportsHaptics;
  double get refreshRate => _refreshRate;
  bool get healthKitAvailable => _healthKitAvailable;
  bool get siriShortcutsAvailable => _siriShortcutsAvailable;
}

// MARK: - Enums

enum IOSAnimationType {
  interactive,
  navigation,
  meditation,
  breathing,
}

enum WellnessAudioType {
  meditation,
  breathingExercise,
  guidedPractice,
  backgroundAmbient,
  notification,
}

enum IOSHapticType {
  breathingStart,
  breathingPeak,
  meditationChime,
  goalAchievement,
  gentleNotification,
}

// MARK: - Extensions

extension IOSWellnessOptimized on Widget {
  /// Apply iOS wellness optimizations to any widget
  Widget optimizeForIOSWellness() {
    if (!Platform.isIOS) return this;

    return RepaintBoundary(
      child: ClipRect(child: this),
    );
  }
}

/// Usage Example:
///
/// 1. Initialize in main():
/// ```dart
/// await IOSExperienceAgent.instance.initialize();
/// ```
///
/// 2. Use iOS-optimized widgets:
/// ```dart
/// IOSExperienceAgent.instance.createIOSWellnessCard(
///   child: MeditationContent(),
/// )
/// ```
///
/// 3. Configure audio for meditation:
/// ```dart
/// await IOSExperienceAgent.instance.configureAudioSessionForWellness(
///   audioType: WellnessAudioType.meditation,
/// );
/// ```
///
/// 4. Provide haptic feedback:
/// ```dart
/// await IOSExperienceAgent.instance.provideWellnessHaptic(
///   type: IOSHapticType.breathingStart,
/// );
/// ```