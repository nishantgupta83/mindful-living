// iOS Design System for MindfulLiving Wellness App
// Implements Human Interface Guidelines with wellness-focused design patterns

import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';

/// iOS Design System
/// Provides Human Interface Guidelines-compliant components for wellness apps
class IOSDesignSystem {
  static IOSDesignSystem? _instance;
  static IOSDesignSystem get instance => _instance ??= IOSDesignSystem._();
  IOSDesignSystem._();

  // System colors based on iOS dynamic colors
  static const Color _systemBlue = Color(0xFF007AFF);
  static const Color _systemGreen = Color(0xFF34C759);
  static const Color _systemIndigo = Color(0xFF5856D6);
  static const Color _systemOrange = Color(0xFFFF9500);
  static const Color _systemPink = Color(0xFFFF2D92);
  static const Color _systemPurple = Color(0xFFAF52DE);
  static const Color _systemRed = Color(0xFFFF3B30);
  static const Color _systemTeal = Color(0xFF5AC8FA);
  static const Color _systemYellow = Color(0xFFFFCC00);

  // Wellness-specific color palette
  static const Color meditationBlue = Color(0xFF4A90E2);
  static const Color breathingGreen = Color(0xFF7ED321);
  static const Color mindfulOrange = Color(0xFFF5A623);
  static const Color calmPurple = Color(0xFF9013FE);
  static const Color peacefulTeal = Color(0xFF00BCD4);

  // MARK: - Typography (San Francisco Font System)

  /// iOS-native text styles for wellness content
  static TextStyle get largeTitle => const TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.41,
    fontFamily: '.SF UI Display', // iOS system font
  );

  static TextStyle get title1 => const TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.36,
    fontFamily: '.SF UI Display',
  );

  static TextStyle get title2 => const TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.35,
    fontFamily: '.SF UI Display',
  );

  static TextStyle get title3 => const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.38,
    fontFamily: '.SF UI Display',
  );

  static TextStyle get headline => const TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.41,
    fontFamily: '.SF UI Text',
  );

  static TextStyle get body => const TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.41,
    fontFamily: '.SF UI Text',
  );

  static TextStyle get callout => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.32,
    fontFamily: '.SF UI Text',
  );

  static TextStyle get subheadline => const TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.24,
    fontFamily: '.SF UI Text',
  );

  static TextStyle get footnote => const TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.08,
    fontFamily: '.SF UI Text',
  );

  static TextStyle get caption1 => const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.0,
    fontFamily: '.SF UI Text',
  );

  static TextStyle get caption2 => const TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.07,
    fontFamily: '.SF UI Text',
  );

  // MARK: - Spacing System (Based on iOS 8-point grid)

  static const double spacing1 = 2.0;  // Micro
  static const double spacing2 = 4.0;  // Tiny
  static const double spacing3 = 8.0;  // Small
  static const double spacing4 = 12.0; // Medium
  static const double spacing5 = 16.0; // Large
  static const double spacing6 = 20.0; // XLarge
  static const double spacing7 = 24.0; // XXLarge
  static const double spacing8 = 32.0; // Huge
  static const double spacing9 = 40.0; // Massive

  // MARK: - Corner Radius (iOS-native values)

  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 20.0;
  static const double radiusRound = 50.0;

  // MARK: - iOS-Native Buttons

  /// Primary CTA button for meditation/wellness actions
  static Widget createPrimaryButton({
    required String text,
    required VoidCallback onPressed,
    bool isLoading = false,
    bool isEnabled = true,
    Color? backgroundColor,
    Color? textColor,
    double? width,
  }) {
    if (!Platform.isIOS) {
      return ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(text),
      );
    }

    return SizedBox(
      width: width,
      child: CupertinoButton.filled(
        onPressed: isEnabled ? onPressed : null,
        borderRadius: BorderRadius.circular(radiusMedium),
        child: isLoading
            ? const CupertinoActivityIndicator(color: CupertinoColors.white)
            : Text(
                text,
                style: headline.copyWith(
                  color: textColor ?? CupertinoColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  /// Secondary button for non-primary actions
  static Widget createSecondaryButton({
    required String text,
    required VoidCallback onPressed,
    bool isEnabled = true,
    Color? borderColor,
    Color? textColor,
    double? width,
  }) {
    if (!Platform.isIOS) {
      return OutlinedButton(
        onPressed: isEnabled ? onPressed : null,
        child: Text(text),
      );
    }

    return SizedBox(
      width: width,
      child: CupertinoButton(
        onPressed: isEnabled ? onPressed : null,
        padding: const EdgeInsets.symmetric(vertical: 14),
        borderRadius: BorderRadius.circular(radiusMedium),
        color: CupertinoColors.systemBackground,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: borderColor ?? CupertinoColors.systemBlue,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Text(
            text,
            style: headline.copyWith(
              color: textColor ?? CupertinoColors.systemBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  /// Ghost button for subtle actions
  static Widget createGhostButton({
    required String text,
    required VoidCallback onPressed,
    bool isEnabled = true,
    Color? textColor,
  }) {
    return CupertinoButton(
      onPressed: isEnabled ? onPressed : null,
      padding: const EdgeInsets.symmetric(horizontal: spacing5, vertical: spacing3),
      child: Text(
        text,
        style: headline.copyWith(
          color: textColor ?? CupertinoColors.systemBlue,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  // MARK: - iOS-Native Cards

  /// Wellness content card with iOS styling
  static Widget createWellnessCard({
    required Widget child,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    Color? backgroundColor,
    VoidCallback? onTap,
    bool elevated = true,
  }) {
    Widget card = Container(
      margin: margin ?? const EdgeInsets.symmetric(
        horizontal: spacing5,
        vertical: spacing3,
      ),
      padding: padding ?? const EdgeInsets.all(spacing5),
      decoration: BoxDecoration(
        color: backgroundColor ?? CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(radiusMedium),
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

    return card;
  }

  /// Category tile for wellness sections
  static Widget createCategoryTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    Color? backgroundColor,
    Color? iconColor,
    Color? textColor,
  }) {
    return createWellnessCard(
      onTap: onTap,
      backgroundColor: backgroundColor ?? meditationBlue.withValues(alpha: 0.1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 32,
            color: iconColor ?? meditationBlue,
          ),
          const SizedBox(height: spacing3),
          Text(
            title,
            style: headline.copyWith(
              color: textColor ?? CupertinoColors.label,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: spacing2),
          Text(
            subtitle,
            style: caption1.copyWith(
              color: CupertinoColors.secondaryLabel,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // MARK: - iOS-Native Lists

  /// Settings-style list for wellness preferences
  static Widget createSettingsList({
    required List<Widget> children,
    EdgeInsetsGeometry? padding,
  }) {
    if (!Platform.isIOS) {
      return ListView(
        padding: padding,
        children: children,
      );
    }

    return CupertinoListSection.insetGrouped(
      margin: padding ?? const EdgeInsets.all(spacing5),
      children: children,
    );
  }

  /// List tile for settings or menu items
  static Widget createListTile({
    required String title,
    String? subtitle,
    Widget? leading,
    Widget? trailing,
    VoidCallback? onTap,
    Color? backgroundColor,
  }) {
    if (!Platform.isIOS) {
      return ListTile(
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle) : null,
        leading: leading,
        trailing: trailing,
        onTap: onTap,
        tileColor: backgroundColor,
      );
    }

    return CupertinoListTile(
      title: Text(
        title,
        style: body.copyWith(color: CupertinoColors.label),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: footnote.copyWith(color: CupertinoColors.secondaryLabel),
            )
          : null,
      leading: leading,
      trailing: trailing ?? const CupertinoListTileChevron(),
      onTap: onTap,
      backgroundColor: backgroundColor,
    );
  }

  // MARK: - iOS-Native Navigation

  /// Wellness app navigation bar
  static PreferredSizeWidget createNavigationBar({
    required String title,
    Widget? leading,
    List<Widget>? trailing,
    bool useLargeTitle = false,
    Color? backgroundColor,
  }) {
    if (!Platform.isIOS) {
      return AppBar(
        title: Text(title),
        leading: leading,
        actions: trailing,
        backgroundColor: backgroundColor,
      );
    }

    return CupertinoNavigationBar(
      middle: Text(
        title,
        style: headline.copyWith(
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
      backgroundColor: backgroundColor?.withValues(alpha: 0.9) ??
          CupertinoColors.systemBackground.withValues(alpha: 0.9),
      border: null,
    );
  }

  /// Tab bar for main navigation
  static Widget createTabBar({
    required List<BottomNavigationBarItem> items,
    required int currentIndex,
    required Function(int) onTap,
    Color? backgroundColor,
  }) {
    if (!Platform.isIOS) {
      return BottomNavigationBar(
        items: items,
        currentIndex: currentIndex,
        onTap: onTap,
        backgroundColor: backgroundColor,
        type: BottomNavigationBarType.fixed,
      );
    }

    return CupertinoTabBar(
      items: items,
      currentIndex: currentIndex,
      onTap: onTap,
      backgroundColor: backgroundColor,
      activeColor: _systemBlue,
      inactiveColor: CupertinoColors.systemGrey,
    );
  }

  // MARK: - iOS-Native Input Controls

  /// Search bar for wellness content
  static Widget createSearchBar({
    required String placeholder,
    required Function(String) onChanged,
    TextEditingController? controller,
    VoidCallback? onTap,
  }) {
    if (!Platform.isIOS) {
      return TextField(
        controller: controller,
        onChanged: onChanged,
        onTap: onTap,
        decoration: InputDecoration(
          hintText: placeholder,
          prefixIcon: const Icon(Icons.search),
        ),
      );
    }

    return CupertinoSearchTextField(
      controller: controller,
      placeholder: placeholder,
      onChanged: onChanged,
      onTap: onTap,
      backgroundColor: CupertinoColors.systemGrey6,
      borderRadius: BorderRadius.circular(radiusMedium),
    );
  }

  /// Segmented control for meditation types
  static Widget createSegmentedControl<T>({
    required Map<T, Widget> children,
    required T selectedValue,
    required Function(T) onValueChanged,
  }) {
    if (!Platform.isIOS) {
      // Fallback for non-iOS platforms
      return Row(
        children: children.entries
            .map((entry) => Expanded(
                  child: GestureDetector(
                    onTap: () => onValueChanged(entry.key),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: selectedValue == entry.key
                            ? _systemBlue
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(child: entry.value),
                    ),
                  ),
                ))
            .toList(),
      );
    }

    return CupertinoSlidingSegmentedControl<T>(
      children: children,
      groupValue: selectedValue,
      onValueChanged: (value) {
        if (value != null) onValueChanged(value);
      },
      backgroundColor: CupertinoColors.systemGrey6,
      thumbColor: CupertinoColors.systemBackground,
    );
  }

  // MARK: - iOS-Native Progress Indicators

  /// Meditation progress ring
  static Widget createProgressRing({
    required double progress,
    required Color color,
    double size = 100,
    double strokeWidth = 8,
    Widget? child,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator.adaptive(
            value: progress,
            strokeWidth: strokeWidth,
            backgroundColor: CupertinoColors.systemGrey5,
            valueColor: AlwaysStoppedAnimation(color),
          ),
          if (child != null) child,
        ],
      ),
    );
  }

  // MARK: - iOS-Native Modals and Sheets

  /// Action sheet for wellness options
  static void showActionSheet({
    required BuildContext context,
    required String title,
    String? message,
    required List<CupertinoActionSheetAction> actions,
    CupertinoActionSheetAction? cancelAction,
  }) {
    if (!Platform.isIOS) {
      showModalBottomSheet(
        context: context,
        builder: (context) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: Text(title)),
            if (message != null) ListTile(subtitle: Text(message)),
            ...actions.map((action) => ListTile(
                  title: action.child,
                  onTap: () {
                    Navigator.pop(context);
                    action.onPressed();
                  },
                )),
          ],
        ),
      );
      return;
    }

    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(title, style: headline),
        message: message != null
            ? Text(message, style: footnote)
            : null,
        actions: actions,
        cancelButton: cancelAction,
      ),
    );
  }

  /// Modal sheet for detailed content
  static void showModalSheet({
    required BuildContext context,
    required Widget child,
    bool isScrollControlled = true,
  }) {
    if (!Platform.isIOS) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: isScrollControlled,
        builder: (context) => child,
      );
      return;
    }

    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: CupertinoColors.systemBackground,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(radiusLarge),
          ),
        ),
        child: child,
      ),
    );
  }

  // MARK: - Haptic Feedback

  /// Provide appropriate haptic feedback for wellness interactions
  static Future<void> provideHapticFeedback(IOSHapticStyle style) async {
    if (!Platform.isIOS) return;

    switch (style) {
      case IOSHapticStyle.light:
        await HapticFeedback.lightImpact();
        break;
      case IOSHapticStyle.medium:
        await HapticFeedback.mediumImpact();
        break;
      case IOSHapticStyle.heavy:
        await HapticFeedback.heavyImpact();
        break;
      case IOSHapticStyle.selection:
        await HapticFeedback.selectionClick();
        break;
    }
  }
}

// MARK: - Enums

enum IOSHapticStyle {
  light,
  medium,
  heavy,
  selection,
}

// MARK: - Extensions

extension IOSDesignSystemWidget on Widget {
  /// Apply iOS-specific design optimizations
  Widget withIOSDesign() {
    if (!Platform.isIOS) return this;

    return ClipRRect(
      borderRadius: BorderRadius.circular(IOSDesignSystem.radiusMedium),
      child: this,
    );
  }
}

/// Usage Example:
///
/// ```dart
/// // Create primary button
/// IOSDesignSystem.createPrimaryButton(
///   text: 'Start Meditation',
///   onPressed: () => startMeditation(),
/// );
///
/// // Create wellness card
/// IOSDesignSystem.createWellnessCard(
///   child: MeditationContent(),
///   onTap: () => openMeditation(),
/// );
///
/// // Show action sheet
/// IOSDesignSystem.showActionSheet(
///   context: context,
///   title: 'Choose Meditation',
///   actions: [
///     CupertinoActionSheetAction(
///       child: Text('5 Minutes'),
///       onPressed: () => startMeditation(5),
///     ),
///   ],
/// );
/// ```