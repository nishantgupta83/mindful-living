import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Base class for all reusable components in the app
/// Provides common functionality and consistent styling
abstract class BaseComponent extends StatelessWidget {
  const BaseComponent({super.key});
  
  /// Common padding used throughout the app
  static const EdgeInsets defaultPadding = EdgeInsets.all(16.0);
  static const EdgeInsets smallPadding = EdgeInsets.all(8.0);
  static const EdgeInsets largePadding = EdgeInsets.all(24.0);
  
  /// Common border radius values
  static const BorderRadius defaultBorderRadius = BorderRadius.all(Radius.circular(12.0));
  static const BorderRadius smallBorderRadius = BorderRadius.all(Radius.circular(8.0));
  static const BorderRadius largeBorderRadius = BorderRadius.all(Radius.circular(16.0));
  
  /// Common shadow configurations
  static const List<BoxShadow> softShadow = [
    BoxShadow(
      color: AppColors.shadowLight,
      blurRadius: 8.0,
      offset: Offset(0, 2),
    ),
  ];
  
  static const List<BoxShadow> mediumShadow = [
    BoxShadow(
      color: AppColors.shadowMedium,
      blurRadius: 12.0,
      offset: Offset(0, 4),
    ),
  ];
  
  /// Standard spacing values
  static const double spacingXs = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXl = 32.0;
  
  /// Get theme data from context
  ThemeData getTheme(BuildContext context) => Theme.of(context);
  
  /// Get color scheme from context
  ColorScheme getColorScheme(BuildContext context) => Theme.of(context).colorScheme;
  
  /// Get text theme from context
  TextTheme getTextTheme(BuildContext context) => Theme.of(context).textTheme;
  
  /// Check if dark mode is active
  bool isDarkMode(BuildContext context) => Theme.of(context).brightness == Brightness.dark;
  
  /// Get media query data
  MediaQueryData getMediaQuery(BuildContext context) => MediaQuery.of(context);
  
  /// Get screen size
  Size getScreenSize(BuildContext context) => MediaQuery.of(context).size;
  
  /// Check if device is in landscape mode
  bool isLandscape(BuildContext context) => MediaQuery.of(context).orientation == Orientation.landscape;
  
  /// Get safe area padding
  EdgeInsets getSafeAreaPadding(BuildContext context) => MediaQuery.of(context).padding;
}

/// Mixin for components that need loading states
mixin LoadingStateMixin {
  bool get isLoading;
  
  Widget buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.primaryBlue,
      ),
    );
  }
  
  Widget buildLoadingOverlay({required Widget child}) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: AppColors.black.withValues(alpha: 0.3),
            child: buildLoadingIndicator(),
          ),
      ],
    );
  }
}

/// Mixin for components that can show error states
mixin ErrorStateMixin {
  String? get errorMessage;
  VoidCallback? get onRetry;
  
  Widget buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: AppColors.error,
          ),
          const SizedBox(height: BaseComponent.spacingM),
          Text(
            errorMessage ?? 'Something went wrong',
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: BaseComponent.spacingL),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }
}

/// Mixin for components that support empty states
mixin EmptyStateMixin {
  String get emptyStateMessage;
  IconData get emptyStateIcon;
  VoidCallback? get onEmptyStateAction;
  String? get emptyStateActionText;
  
  Widget buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            emptyStateIcon,
            size: 64,
            color: AppColors.textLight,
          ),
          const SizedBox(height: BaseComponent.spacingL),
          Text(
            emptyStateMessage,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          if (onEmptyStateAction != null && emptyStateActionText != null) ...[
            const SizedBox(height: BaseComponent.spacingL),
            ElevatedButton(
              onPressed: onEmptyStateAction,
              child: Text(emptyStateActionText!),
            ),
          ],
        ],
      ),
    );
  }
}