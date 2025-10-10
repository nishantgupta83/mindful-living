// iOS Audio Session Manager for MindfulLiving Wellness App
// Handles iOS-specific audio session configuration for meditation and wellness content

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// iOS Audio Session Manager
/// Manages iOS-specific audio session configuration for optimal wellness experience
class IOSAudioSessionManager {
  static IOSAudioSessionManager? _instance;
  static IOSAudioSessionManager get instance => _instance ??= IOSAudioSessionManager._();
  IOSAudioSessionManager._();

  static const MethodChannel _channel = MethodChannel('mindful_living/ios_audio');

  bool _isInitialized = false;
  IOSAudioSessionState _currentState = IOSAudioSessionState.inactive;
  IOSAudioCategory _currentCategory = IOSAudioCategory.playback;

  /// Initialize the iOS Audio Session Manager
  Future<void> initialize() async {
    if (_isInitialized || !Platform.isIOS) return;

    try {
      // Register method call handler for iOS callbacks
      _channel.setMethodCallHandler(_handleMethodCall);

      // Initialize native iOS audio session
      await _channel.invokeMethod('initialize');

      _isInitialized = true;

      if (kDebugMode) {
        print('🎵 iOS Audio Session Manager initialized');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to initialize iOS Audio Session Manager: $e');
      }
    }
  }

  /// Handle method calls from iOS native side
  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'audioSessionInterrupted':
        await _handleAudioInterruption(call.arguments);
        break;
      case 'audioSessionResumed':
        await _handleAudioResumption(call.arguments);
        break;
      case 'audioRouteChanged':
        await _handleAudioRouteChange(call.arguments);
        break;
      default:
        if (kDebugMode) {
          print('Unhandled iOS audio method: ${call.method}');
        }
    }
  }

  /// Configure audio session for meditation content
  Future<void> configureMeditationAudio({
    bool allowBackground = true,
    bool mixWithOthers = false,
    bool enableNoiseReduction = true,
  }) async {
    if (!Platform.isIOS || !_isInitialized) return;

    try {
      await _channel.invokeMethod('configureMeditationAudio', {
        'allowBackground': allowBackground,
        'mixWithOthers': mixWithOthers,
        'enableNoiseReduction': enableNoiseReduction,
      });

      _currentCategory = IOSAudioCategory.playback;
      _currentState = IOSAudioSessionState.active;

      if (kDebugMode) {
        print('🧘 iOS audio configured for meditation');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to configure meditation audio: $e');
      }
    }
  }

  /// Configure audio session for breathing exercises
  Future<void> configureBreathingAudio({
    bool allowBackground = false,
    bool enableSpatialAudio = true,
  }) async {
    if (!Platform.isIOS || !_isInitialized) return;

    try {
      await _channel.invokeMethod('configureBreathingAudio', {
        'allowBackground': allowBackground,
        'enableSpatialAudio': enableSpatialAudio,
      });

      _currentCategory = IOSAudioCategory.playAndRecord;
      _currentState = IOSAudioSessionState.active;

      if (kDebugMode) {
        print('🫁 iOS audio configured for breathing exercises');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to configure breathing audio: $e');
      }
    }
  }

  /// Configure audio session for ambient sounds
  Future<void> configureAmbientAudio({
    bool allowBackground = true,
    bool mixWithOthers = true,
    double volume = 0.5,
  }) async {
    if (!Platform.isIOS || !_isInitialized) return;

    try {
      await _channel.invokeMethod('configureAmbientAudio', {
        'allowBackground': allowBackground,
        'mixWithOthers': mixWithOthers,
        'volume': volume,
      });

      _currentCategory = IOSAudioCategory.ambient;
      _currentState = IOSAudioSessionState.active;

      if (kDebugMode) {
        print('🌊 iOS audio configured for ambient sounds');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to configure ambient audio: $e');
      }
    }
  }

  /// Configure audio session for voice recording (journal entries)
  Future<void> configureVoiceRecording({
    bool enableNoiseReduction = true,
    bool enableEchoCancellation = true,
  }) async {
    if (!Platform.isIOS || !_isInitialized) return;

    try {
      await _channel.invokeMethod('configureVoiceRecording', {
        'enableNoiseReduction': enableNoiseReduction,
        'enableEchoCancellation': enableEchoCancellation,
      });

      _currentCategory = IOSAudioCategory.record;
      _currentState = IOSAudioSessionState.active;

      if (kDebugMode) {
        print('🎙️ iOS audio configured for voice recording');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to configure voice recording: $e');
      }
    }
  }

  /// Configure audio session for notifications and chimes
  Future<void> configureNotificationAudio({
    bool respectSilentMode = true,
    double volume = 0.7,
  }) async {
    if (!Platform.isIOS || !_isInitialized) return;

    try {
      await _channel.invokeMethod('configureNotificationAudio', {
        'respectSilentMode': respectSilentMode,
        'volume': volume,
      });

      _currentCategory = IOSAudioCategory.soloAmbient;

      if (kDebugMode) {
        print('🔔 iOS audio configured for notifications');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to configure notification audio: $e');
      }
    }
  }

  /// Activate audio session
  Future<void> activateSession() async {
    if (!Platform.isIOS || !_isInitialized) return;

    try {
      await _channel.invokeMethod('activateSession');
      _currentState = IOSAudioSessionState.active;

      if (kDebugMode) {
        print('▶️ iOS audio session activated');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to activate audio session: $e');
      }
    }
  }

  /// Deactivate audio session
  Future<void> deactivateSession({bool notifyOthersOnDeactivation = true}) async {
    if (!Platform.isIOS || !_isInitialized) return;

    try {
      await _channel.invokeMethod('deactivateSession', {
        'notifyOthersOnDeactivation': notifyOthersOnDeactivation,
      });
      _currentState = IOSAudioSessionState.inactive;

      if (kDebugMode) {
        print('⏹️ iOS audio session deactivated');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to deactivate audio session: $e');
      }
    }
  }

  /// Handle audio interruptions (calls, alarms, etc.)
  Future<void> _handleAudioInterruption(Map<dynamic, dynamic> args) async {
    final type = args['type'] as String?;
    final option = args['option'] as String?;

    if (kDebugMode) {
      print('🚨 Audio interruption: $type (option: $option)');
    }

    switch (type) {
      case 'began':
        _currentState = IOSAudioSessionState.interrupted;
        // Pause any ongoing meditation or breathing exercises
        break;
      case 'ended':
        if (option == 'shouldResume') {
          await _resumeAfterInterruption();
        }
        break;
    }
  }

  /// Handle audio session resumption after interruption
  Future<void> _handleAudioResumption(Map<dynamic, dynamic> args) async {
    if (kDebugMode) {
      print('▶️ Audio session resumed');
    }

    _currentState = IOSAudioSessionState.active;
    // Resume any paused meditation or breathing exercises
  }

  /// Handle audio route changes (headphones plugged/unplugged)
  Future<void> _handleAudioRouteChange(Map<dynamic, dynamic> args) async {
    final reason = args['reason'] as String?;
    final previousRoute = args['previousRoute'] as String?;
    final newRoute = args['newRoute'] as String?;

    if (kDebugMode) {
      print('🎧 Audio route changed: $reason ($previousRoute → $newRoute)');
    }

    switch (reason) {
      case 'oldDeviceUnavailable':
        // Headphones were unplugged - pause meditation
        await _pauseForRouteChange();
        break;
      case 'newDeviceAvailable':
        // Headphones were plugged in - offer to resume
        await _offerResumeForRouteChange();
        break;
    }
  }

  /// Resume audio after interruption
  Future<void> _resumeAfterInterruption() async {
    try {
      await activateSession();
      // Notify app to resume meditation/breathing exercises
      if (kDebugMode) {
        print('🔄 Audio resumed after interruption');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to resume after interruption: $e');
      }
    }
  }

  /// Pause audio for route change
  Future<void> _pauseForRouteChange() async {
    // This would be handled by the meditation/breathing widgets
    if (kDebugMode) {
      print('⏸️ Pausing audio for route change');
    }
  }

  /// Offer to resume after favorable route change
  Future<void> _offerResumeForRouteChange() async {
    // This would show a user prompt to resume
    if (kDebugMode) {
      print('🎧 Offering to resume audio with new route');
    }
  }

  /// Get current audio output route
  Future<String?> getCurrentAudioRoute() async {
    if (!Platform.isIOS || !_isInitialized) return null;

    try {
      final route = await _channel.invokeMethod('getCurrentAudioRoute');
      return route as String?;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to get audio route: $e');
      }
      return null;
    }
  }

  /// Check if headphones are connected
  Future<bool> areHeadphonesConnected() async {
    if (!Platform.isIOS || !_isInitialized) return false;

    try {
      final connected = await _channel.invokeMethod('areHeadphonesConnected');
      return connected as bool? ?? false;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to check headphone connection: $e');
      }
      return false;
    }
  }

  /// Set preferred sample rate for high-quality audio
  Future<void> setPreferredSampleRate(double sampleRate) async {
    if (!Platform.isIOS || !_isInitialized) return;

    try {
      await _channel.invokeMethod('setPreferredSampleRate', {
        'sampleRate': sampleRate,
      });

      if (kDebugMode) {
        print('🎵 Set preferred sample rate: ${sampleRate}Hz');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to set sample rate: $e');
      }
    }
  }

  /// Request recording permission
  Future<bool> requestRecordingPermission() async {
    if (!Platform.isIOS || !_isInitialized) return false;

    try {
      final granted = await _channel.invokeMethod('requestRecordingPermission');
      return granted as bool? ?? false;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to request recording permission: $e');
      }
      return false;
    }
  }

  /// Dispose and cleanup
  void dispose() {
    if (Platform.isIOS && _isInitialized) {
      deactivateSession();
    }
  }

  // Getters
  bool get isInitialized => _isInitialized;
  IOSAudioSessionState get currentState => _currentState;
  IOSAudioCategory get currentCategory => _currentCategory;
}

// MARK: - Enums

enum IOSAudioSessionState {
  inactive,
  active,
  interrupted,
}

enum IOSAudioCategory {
  ambient,
  soloAmbient,
  playback,
  record,
  playAndRecord,
  multiRoute,
}

/// Usage Example:
///
/// ```dart
/// // Initialize
/// await IOSAudioSessionManager.instance.initialize();
///
/// // Configure for meditation
/// await IOSAudioSessionManager.instance.configureMeditationAudio(
///   allowBackground: true,
///   enableNoiseReduction: true,
/// );
///
/// // Activate session
/// await IOSAudioSessionManager.instance.activateSession();
///
/// // Check for headphones
/// final hasHeadphones = await IOSAudioSessionManager.instance.areHeadphonesConnected();
/// ```
///
/// Note: This requires corresponding iOS native implementation in the iOS project
/// with proper AVAudioSession configuration and method channel handling.