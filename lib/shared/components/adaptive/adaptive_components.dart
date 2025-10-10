import 'dart:io';
import 'package:flutter/material.dart' as material;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../base/base_component.dart';
import '../../../core/constants/app_colors.dart';

/// Platform-adaptive components that provide native feel on each platform
class AdaptiveComponents {
  AdaptiveComponents._();

  /// Platform-specific navigation bar
  static Widget buildNavigationBar({
    required int currentIndex,
    required ValueChanged<int> onTap,
    required List<NavigationItem> items,
  }) {
    if (Platform.isIOS) {
      return CupertinoTabBar(
        currentIndex: currentIndex,
        onTap: onTap,
        backgroundColor: AppColors.backgroundPrimary,
        activeColor: AppColors.primaryBlue,
        inactiveColor: AppColors.textLight,
        items: items.map((item) => BottomNavigationBarItem(
          icon: Icon(item.icon),
          activeIcon: Icon(item.activeIcon ?? item.icon),
          label: item.label,
        )).toList(),
      );
    } else {
      return NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onTap,
        backgroundColor: AppColors.backgroundPrimary,
        destinations: items.map((item) => NavigationDestination(
          icon: Icon(item.icon),
          selectedIcon: Icon(item.activeIcon ?? item.icon),
          label: item.label,
        )).toList(),
      );
    }
  }

  /// Platform-specific scroll physics
  static ScrollPhysics getScrollPhysics() {
    return Platform.isIOS
        ? const BouncingScrollPhysics()
        : const ClampingScrollPhysics();
  }

  /// Platform-specific haptic feedback
  static void provideFeedback({
    HapticFeedbackType type = HapticFeedbackType.light,
  }) {
    if (Platform.isIOS) {
      switch (type) {
        case HapticFeedbackType.light:
          HapticFeedback.lightImpact();
          break;
        case HapticFeedbackType.medium:
          HapticFeedback.mediumImpact();
          break;
        case HapticFeedbackType.heavy:
          HapticFeedback.heavyImpact();
          break;
        case HapticFeedbackType.selection:
          HapticFeedback.selectionClick();
          break;
      }
    } else {
      HapticFeedback.vibrate();
    }
  }

  /// Platform-specific date picker
  static Future<DateTime?> showDatePicker({
    required BuildContext context,
    required DateTime initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) {
    final firstDateValue = firstDate ?? DateTime(1900);
    final lastDateValue = lastDate ?? DateTime.now().add(const Duration(days: 365 * 10));

    if (Platform.isIOS) {
      return showCupertinoDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: firstDateValue,
        lastDate: lastDateValue,
      );
    } else {
      return showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: firstDateValue,
        lastDate: lastDateValue,
      );
    }
  }

  /// Platform-specific time picker
  static Future<TimeOfDay?> showTimePicker({
    required BuildContext context,
    required TimeOfDay initialTime,
  }) {
    if (Platform.isIOS) {
      return showCupertinoTimePicker(
        context: context,
        initialTime: initialTime,
      );
    } else {
      return material.showTimePicker(
        context: context,
        initialTime: initialTime,
      );
    }
  }

  /// Platform-specific alert dialog
  static Widget buildAlertDialog({
    required String title,
    required String content,
    List<AlertAction> actions = const [],
  }) {
    if (Platform.isIOS) {
      return CupertinoAlertDialog(
        title: Text(title),
        content: Text(content),
        actions: actions.map((action) => CupertinoDialogAction(
          onPressed: action.onPressed,
          isDefaultAction: action.isDefault,
          isDestructiveAction: action.isDestructive,
          child: Text(action.label),
        )).toList(),
      );
    } else {
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: actions.map((action) => TextButton(
          onPressed: action.onPressed,
          style: action.isDestructive 
              ? TextButton.styleFrom(foregroundColor: AppColors.error)
              : null,
          child: Text(action.label),
        )).toList(),
      );
    }
  }

  /// Platform-specific loading indicator
  static Widget buildLoadingIndicator({
    Color? color,
    double? size,
  }) {
    final indicatorColor = color ?? AppColors.primaryBlue;
    
    if (Platform.isIOS) {
      return CupertinoActivityIndicator(
        color: indicatorColor,
        radius: size ?? 10.0,
      );
    } else {
      return SizedBox(
        width: size ?? 20.0,
        height: size ?? 20.0,
        child: CircularProgressIndicator(
          color: indicatorColor,
          strokeWidth: 2.0,
        ),
      );
    }
  }

  /// Platform-specific switch
  static Widget buildSwitch({
    required bool value,
    required ValueChanged<bool> onChanged,
    Color? activeColor,
  }) {
    final switchColor = activeColor ?? AppColors.primaryBlue;
    
    if (Platform.isIOS) {
      return CupertinoSwitch(
        value: value,
        onChanged: onChanged,
        activeColor: switchColor,
      );
    } else {
      return Switch(
        value: value,
        onChanged: onChanged,
        activeColor: switchColor,
      );
    }
  }

  /// Platform-specific slider
  static Widget buildSlider({
    required double value,
    required ValueChanged<double> onChanged,
    double min = 0.0,
    double max = 1.0,
    int? divisions,
    Color? activeColor,
  }) {
    final sliderColor = activeColor ?? AppColors.primaryBlue;
    
    if (Platform.isIOS) {
      return CupertinoSlider(
        value: value,
        onChanged: onChanged,
        min: min,
        max: max,
        divisions: divisions,
        activeColor: sliderColor,
      );
    } else {
      return Slider(
        value: value,
        onChanged: onChanged,
        min: min,
        max: max,
        divisions: divisions,
        activeColor: sliderColor,
      );
    }
  }
}

/// Custom cupertino date picker for iOS
Future<DateTime?> showCupertinoDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
}) {
  DateTime selectedDate = initialDate;
  
  return showCupertinoModalPopup<DateTime>(
    context: context,
    builder: (context) => Container(
      height: 300,
      color: CupertinoColors.systemBackground.resolveFrom(context),
      child: Column(
        children: [
          Container(
            height: 50,
            color: CupertinoColors.systemGrey6.resolveFrom(context),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                CupertinoButton(
                  child: const Text('Done'),
                  onPressed: () => Navigator.of(context).pop(selectedDate),
                ),
              ],
            ),
          ),
          Expanded(
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.date,
              initialDateTime: initialDate,
              minimumDate: firstDate,
              maximumDate: lastDate,
              onDateTimeChanged: (date) => selectedDate = date,
            ),
          ),
        ],
      ),
    ),
  );
}

/// Custom cupertino time picker for iOS
Future<TimeOfDay?> showCupertinoTimePicker({
  required BuildContext context,
  required TimeOfDay initialTime,
}) {
  DateTime selectedDateTime = DateTime.now().copyWith(
    hour: initialTime.hour,
    minute: initialTime.minute,
  );
  
  return showCupertinoModalPopup<TimeOfDay>(
    context: context,
    builder: (context) => Container(
      height: 300,
      color: CupertinoColors.systemBackground.resolveFrom(context),
      child: Column(
        children: [
          Container(
            height: 50,
            color: CupertinoColors.systemGrey6.resolveFrom(context),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                CupertinoButton(
                  child: const Text('Done'),
                  onPressed: () => Navigator.of(context).pop(
                    TimeOfDay.fromDateTime(selectedDateTime),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.time,
              initialDateTime: selectedDateTime,
              onDateTimeChanged: (dateTime) => selectedDateTime = dateTime,
            ),
          ),
        ],
      ),
    ),
  );
}

/// Model classes for adaptive components
class NavigationItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;

  const NavigationItem({
    required this.icon,
    this.activeIcon,
    required this.label,
  });
}

class AlertAction {
  final String label;
  final VoidCallback onPressed;
  final bool isDefault;
  final bool isDestructive;

  const AlertAction({
    required this.label,
    required this.onPressed,
    this.isDefault = false,
    this.isDestructive = false,
  });
}

enum HapticFeedbackType {
  light,
  medium,
  heavy,
  selection,
}