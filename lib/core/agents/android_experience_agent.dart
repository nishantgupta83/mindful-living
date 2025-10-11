import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;

/// Android Experience Expert Agent for MindfulLiving Wellness App
///
/// This agent specializes in Android platform excellence, focusing on:
/// - Material Design 3 implementation and theming
/// - Android-specific performance optimizations
/// - Platform integration and system services
/// - Wellness category optimization for Google Play
///
/// Author: Android Experience Agent
/// Version: 1.0.0
/// Target: Android API 28+ (Android 9.0 Pie)
class AndroidExperienceAgent {
  static const String _agentName = 'Android Experience Expert';
  static const String _version = '1.0.0';
  static const int _minAndroidSdk = 28;
  static const int _targetAndroidSdk = 34;

  /// Core Android platform detection and validation
  static bool get isAndroidPlatform => Platform.isAndroid;

  /// Android version compatibility check
  static Future<bool> validateAndroidCompatibility() async {
    if (!isAndroidPlatform) return false;

    // Check if running on supported Android version
    try {
      final androidInfo = await _getAndroidInfo();
      return androidInfo['sdkInt'] >= _minAndroidSdk;
    } catch (e) {
      debugPrint('$_agentName: Android compatibility check failed: $e');
      return false;
    }
  }

  /// Material Design 3 Theme Configuration for Wellness Apps
  static ThemeData buildMaterial3WellnessTheme({
    required ColorScheme colorScheme,
    bool isDarkMode = false,
  }) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,

      // Material 3 Typography optimized for wellness content
      textTheme: _buildWellnessTextTheme(colorScheme),

      // Android-specific navigation
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primaryContainer,
        elevation: 0,
        height: 80,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),

      // Material 3 Card design for life situations
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: colorScheme.surfaceContainerLow,
      ),

      // App Bar theme for meditation sessions
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
      ),

      // Floating Action Button for quick wellness actions
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // Chip theme for wellness tags and categories
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        selectedColor: colorScheme.secondaryContainer,
        labelStyle: TextStyle(color: colorScheme.onSurface),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),

      // Progress indicators for meditation progress
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.surfaceContainerHighest,
        circularTrackColor: colorScheme.surfaceContainerHighest,
      ),

      // Bottom sheet theme for wellness content
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        elevation: 8,
      ),
    );
  }

  /// Dynamic Color Scheme for Material You support
  static Future<ColorScheme?> getDynamicColorScheme({bool dark = false}) async {
    if (!isAndroidPlatform) return null;

    try {
      // Implementation would use dynamic_color package
      // For now, return wellness-optimized color scheme
      return _buildWellnessColorScheme(dark: dark);
    } catch (e) {
      debugPrint('$_agentName: Dynamic color extraction failed: $e');
      return _buildWellnessColorScheme(dark: dark);
    }
  }

  /// Android System UI Configuration for Wellness Apps
  static void configureSystemUI({
    required bool isDarkMode,
    Color? statusBarColor,
    Color? navigationBarColor,
  }) {
    if (!isAndroidPlatform) return;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: statusBarColor ?? Colors.transparent,
        statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: navigationBarColor ??
          (isDarkMode ? const Color(0xFF1C1B1F) : Colors.white),
        systemNavigationBarIconBrightness:
          isDarkMode ? Brightness.light : Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );

    // Configure edge-to-edge display for meditation sessions
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: [SystemUiOverlay.top],
    );
  }

  // TODO: Performance optimization methods moved to android_performance_optimizer.dart
  // TODO: Integration services moved to android_system_integration.dart
  // TODO: Accessibility services moved to android_system_integration.dart
  // TODO: Notification management moved to android_system_integration.dart
  // TODO: Storage optimization moved to android_performance_optimizer.dart

  /// Private helper methods
  static Future<Map<String, dynamic>> _getAndroidInfo() async {
    // Implementation would use device_info_plus package
    return {
      'sdkInt': 30, // Example value
      'release': '11',
      'brand': 'Google',
      'model': 'Pixel',
    };
  }

  static TextTheme _buildWellnessTextTheme(ColorScheme colorScheme) {
    return TextTheme(
      // Headlines for wellness categories
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface,
        height: 1.25,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface,
        height: 1.29,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
        height: 1.33,
      ),

      // Titles for life situations
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
        height: 1.27,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
        height: 1.5,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
        height: 1.43,
      ),

      // Body text for wellness content
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface,
        height: 1.43,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface,
        height: 1.33,
      ),

      // Labels for wellness tags and buttons
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
        height: 1.43,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
        height: 1.33,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
        height: 1.45,
      ),
    );
  }

  static ColorScheme _buildWellnessColorScheme({bool dark = false}) {
    if (dark) {
      return const ColorScheme.dark(
        primary: Color(0xFF7ED321), // Growth Green
        primaryContainer: Color(0xFF2A4A1A),
        secondary: Color(0xFF4A90E2), // Primary Blue
        secondaryContainer: Color(0xFF1A2A3A),
        tertiary: Color(0xFFF5A623), // Mindful Orange
        tertiaryContainer: Color(0xFF3A2A1A),
        surface: Color(0xFF1C1B1F),
        surfaceContainerLow: Color(0xFF26252A),
        surfaceContainerHighest: Color(0xFF3A3940),
        error: Color(0xFFBA1A1A),
        onPrimary: Color(0xFF000000),
        onSecondary: Color(0xFFFFFFFF),
        onSurface: Color(0xFFE6E1E5),
        onError: Color(0xFFFFFFFF),
      );
    } else {
      return const ColorScheme.light(
        primary: Color(0xFF4A90E2), // Primary Blue
        primaryContainer: Color(0xFFD1E7FF),
        secondary: Color(0xFF7ED321), // Growth Green
        secondaryContainer: Color(0xFFE8F5D1),
        tertiary: Color(0xFFF5A623), // Mindful Orange
        tertiaryContainer: Color(0xFFFFF2D1),
        surface: Color(0xFFFFFBFE),
        surfaceContainerLow: Color(0xFFF7F2FA),
        surfaceContainerHighest: Color(0xFFE7E0E8),
        error: Color(0xFFBA1A1A),
        onPrimary: Color(0xFFFFFFFF),
        onSecondary: Color(0xFF000000),
        onSurface: Color(0xFF1C1B1F),
        onError: Color(0xFFFFFFFF),
      );
    }
  }

  /// Agent Information and Status
  static Map<String, dynamic> getAgentInfo() {
    return {
      'name': _agentName,
      'version': _version,
      'platform': 'Android',
      'minSdk': _minAndroidSdk,
      'targetSdk': _targetAndroidSdk,
      'capabilities': [
        'Material Design 3 Implementation',
        'Android Performance Optimization',
        'System Integration (Google Fit, Assistant, Auto)',
        'Accessibility Services',
        'Notification Management',
        'Storage Optimization',
        'Memory Management',
        'Battery Optimization',
        'Hardware Acceleration',
        'Dynamic Color Support',
      ],
      'wellness_features': [
        'Meditation Session Optimization',
        'Life Situation Performance',
        'Journal Interface Enhancement',
        'Mindful Reminder System',
        'Voice Integration Support',
        'Offline Content Caching',
        'Progress Tracking',
        'Wellness Widget',
      ],
    };
  }
}

/// Custom Android Widgets for Wellness Features
class AndroidWellnessWidgets {
  /// Material 3 Card for Life Situations with Android-specific optimizations
  static Widget buildLifeSituationCard({
    required String title,
    required String description,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
    List<String>? tags,
    String? difficulty,
    int? readTime,
  }) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              if (tags != null || difficulty != null || readTime != null) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    if (difficulty != null)
                      Chip(
                        label: Text(difficulty),
                        backgroundColor: colorScheme.secondaryContainer,
                        labelStyle: TextStyle(color: colorScheme.onSecondaryContainer),
                      ),
                    if (readTime != null)
                      Chip(
                        label: Text('${readTime}min read'),
                        backgroundColor: colorScheme.tertiaryContainer,
                        labelStyle: TextStyle(color: colorScheme.onTertiaryContainer),
                      ),
                    if (tags != null)
                      ...tags.take(2).map((tag) => Chip(
                        label: Text(tag),
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        labelStyle: TextStyle(color: colorScheme.onSurface),
                      )),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Android-optimized Meditation Progress Indicator
  static Widget buildMeditationProgressIndicator({
    required double progress,
    required Duration totalDuration,
    required Duration currentDuration,
    required ColorScheme colorScheme,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 200,
                height: 200,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${currentDuration.inMinutes}:${(currentDuration.inSeconds % 60).toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w300,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    'of ${totalDuration.inMinutes}:${(totalDuration.inSeconds % 60).toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 16,
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
          ),
        ],
      ),
    );
  }

  /// Android-style Wellness Dashboard Card
  static Widget buildWellnessDashboardCard({
    required String title,
    required String value,
    required IconData icon,
    required ColorScheme colorScheme,
    VoidCallback? onTap,
    String? subtitle,
    Color? accentColor,
  }) {
    return Card(
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (accentColor ?? colorScheme.primary).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: accentColor ?? colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const Spacer(),
                  if (onTap != null)
                    Icon(
                      Icons.chevron_right,
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}