import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';

/// Platform-adaptive widgets that use native design patterns
class PlatformAdaptive {
  static bool get isIOS => Platform.isIOS;
  static bool get isAndroid => Platform.isAndroid;

  /// Platform-adaptive button
  static Widget button({
    required VoidCallback? onPressed,
    required Widget child,
    Color? color,
    EdgeInsets? padding,
  }) {
    if (isIOS) {
      return CupertinoButton(
        onPressed: onPressed,
        color: color,
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: child,
      );
    }
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: color,
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      child: child,
    );
  }

  /// Platform-adaptive loading indicator
  static Widget loading({Color? color, double? value}) {
    if (isIOS) {
      return CupertinoActivityIndicator(color: color ?? CupertinoColors.activeBlue);
    }
    return CircularProgressIndicator(color: color, value: value);
  }

  /// Platform-adaptive switch
  static Widget switchWidget({
    required bool value,
    required ValueChanged<bool> onChanged,
    Color? activeColor,
  }) {
    if (isIOS) {
      return CupertinoSwitch(
        value: value,
        onChanged: onChanged,
        activeColor: activeColor ?? CupertinoColors.activeBlue,
      );
    }
    return Switch(
      value: value,
      onChanged: onChanged,
      activeColor: activeColor,
    );
  }

  /// Platform-adaptive slider
  static Widget slider({
    required double value,
    required ValueChanged<double> onChanged,
    double min = 0.0,
    double max = 1.0,
    Color? activeColor,
  }) {
    if (isIOS) {
      return CupertinoSlider(
        value: value,
        onChanged: onChanged,
        min: min,
        max: max,
        activeColor: activeColor ?? CupertinoColors.activeBlue,
      );
    }
    return Slider(
      value: value,
      onChanged: onChanged,
      min: min,
      max: max,
      activeColor: activeColor,
    );
  }

  /// Platform-adaptive alert dialog
  static Future<T?> showAlertDialog<T>({
    required BuildContext context,
    required String title,
    required String content,
    String? confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
  }) {
    if (isIOS) {
      return showCupertinoDialog<T>(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            if (cancelText != null)
              CupertinoDialogAction(
                onPressed: () => Navigator.pop(context),
                child: Text(cancelText),
              ),
            CupertinoDialogAction(
              onPressed: () {
                onConfirm?.call();
                Navigator.pop(context);
              },
              isDefaultAction: true,
              child: Text(confirmText ?? 'OK'),
            ),
          ],
        ),
      );
    }
    return showDialog<T>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          if (cancelText != null)
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(cancelText),
            ),
          FilledButton(
            onPressed: () {
              onConfirm?.call();
              Navigator.pop(context);
            },
            child: Text(confirmText ?? 'OK'),
          ),
        ],
      ),
    );
  }

  /// Platform-adaptive navigation bar
  static PreferredSizeWidget appBar({
    required String title,
    List<Widget>? actions,
    Widget? leading,
    Color? backgroundColor,
  }) {
    if (isIOS) {
      return CupertinoNavigationBar(
        middle: Text(title),
        trailing: actions != null ? Row(
          mainAxisSize: MainAxisSize.min,
          children: actions,
        ) : null,
        leading: leading,
        backgroundColor: backgroundColor,
      ) as PreferredSizeWidget;
    }
    return AppBar(
      title: Text(title),
      actions: actions,
      leading: leading,
      backgroundColor: backgroundColor,
    );
  }

  /// Platform-adaptive page route
  static Route<T> pageRoute<T>(WidgetBuilder builder) {
    if (isIOS) {
      return CupertinoPageRoute<T>(builder: builder);
    }
    return MaterialPageRoute<T>(builder: builder);
  }

  /// Platform-adaptive scaffold
  static Widget scaffold({
    PreferredSizeWidget? appBar,
    required Widget body,
    Widget? bottomNavigationBar,
    Color? backgroundColor,
  }) {
    if (isIOS) {
      return CupertinoPageScaffold(
        navigationBar: appBar as ObstructingPreferredSizeWidget?,
        backgroundColor: backgroundColor ?? CupertinoColors.systemBackground,
        child: body,
      );
    }
    return Scaffold(
      appBar: appBar,
      body: body,
      bottomNavigationBar: bottomNavigationBar,
      backgroundColor: backgroundColor,
    );
  }
}
