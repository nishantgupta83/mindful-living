import 'package:flutter/services.dart';
import 'dart:io';

/// Centralized haptic feedback system
/// iOS: Uses UIImpactFeedbackGenerator, UINotificationFeedbackGenerator
/// Android: Uses HapticFeedback
class HapticService {
  /// Light impact (button tap, toggle switch)
  static Future<void> light() async {
    if (Platform.isIOS || Platform.isAndroid) {
      await HapticFeedback.lightImpact();
    }
  }

  /// Medium impact (card tap, list selection)
  static Future<void> medium() async {
    if (Platform.isIOS || Platform.isAndroid) {
      await HapticFeedback.mediumImpact();
    }
  }

  /// Heavy impact (important action, confirmation)
  static Future<void> heavy() async {
    if (Platform.isIOS || Platform.isAndroid) {
      await HapticFeedback.heavyImpact();
    }
  }

  /// Selection changed (scrolling through picker, slider)
  static Future<void> selectionClick() async {
    if (Platform.isIOS || Platform.isAndroid) {
      await HapticFeedback.selectionClick();
    }
  }

  /// Success notification (task completed, data saved)
  static Future<void> success() async {
    if (Platform.isIOS) {
      await HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      await HapticFeedback.lightImpact();
    } else {
      await HapticFeedback.mediumImpact();
    }
  }

  /// Warning notification (invalid input, error prevented)
  static Future<void> warning() async {
    if (Platform.isIOS) {
      await HapticFeedback.heavyImpact();
    } else {
      await HapticFeedback.heavyImpact();
    }
  }

  /// Error notification (action failed, critical error)
  static Future<void> error() async {
    if (Platform.isIOS) {
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      await HapticFeedback.heavyImpact();
    } else {
      await HapticFeedback.vibrate();
    }
  }

  /// Long press (context menu, drag start)
  static Future<void> longPress() async {
    await heavy();
  }

  /// Vibrate (Android-style vibration)
  static Future<void> vibrate() async {
    if (Platform.isAndroid) {
      await HapticFeedback.vibrate();
    } else {
      await heavy();
    }
  }

  /// Disable all haptics
  static bool _enabled = true;

  static void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  static bool get isEnabled => _enabled;
}

/// Extension for easy widget integration
extension HapticGesture on Widget {
  Widget withHaptic({HapticType type = HapticType.light}) {
    return GestureDetector(
      onTap: () {
        switch (type) {
          case HapticType.light:
            HapticService.light();
            break;
          case HapticType.medium:
            HapticService.medium();
            break;
          case HapticType.heavy:
            HapticService.heavy();
            break;
          case HapticType.selection:
            HapticService.selectionClick();
            break;
        }
      },
      child: this,
    );
  }
}

enum HapticType {
  light,
  medium,
  heavy,
  selection,
}
