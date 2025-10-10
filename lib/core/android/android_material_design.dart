import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;

/// Android Material Design 3 Implementation for MindfulLiving Wellness App
///
/// Provides comprehensive Material Design 3 theming and components optimized for:
/// - Wellness and mindfulness user experiences
/// - Android platform-specific design patterns
/// - Material You dynamic color support
/// - Accessibility and inclusive design
/// - Smooth animations and micro-interactions
class AndroidMaterialDesign {
  static const String _logTag = 'AndroidMaterialDesign';

  /// Material 3 Color Schemes for Wellness
  static class WellnessColorSchemes {
    /// Light color scheme optimized for wellness content
    static const ColorScheme lightWellness = ColorScheme.light(
      // Primary colors - calming blue for mindfulness
      primary: Color(0xFF4A90E2),
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFFD1E7FF),
      onPrimaryContainer: Color(0xFF001A33),

      // Secondary colors - growth green for progress
      secondary: Color(0xFF7ED321),
      onSecondary: Color(0xFF000000),
      secondaryContainer: Color(0xFFE8F5D1),
      onSecondaryContainer: Color(0xFF0F2E00),

      // Tertiary colors - mindful orange for warmth
      tertiary: Color(0xFFF5A623),
      onTertiary: Color(0xFF000000),
      tertiaryContainer: Color(0xFFFFF2D1),
      onTertiaryContainer: Color(0xFF331A00),

      // Surface colors for cards and backgrounds
      surface: Color(0xFFFFFBFE),
      onSurface: Color(0xFF1C1B1F),
      surfaceContainerLowest: Color(0xFFFFFFFF),
      surfaceContainerLow: Color(0xFFF7F2FA),
      surfaceContainer: Color(0xFFF1ECF4),
      surfaceContainerHigh: Color(0xFFECE6F0),
      surfaceContainerHighest: Color(0xFFE6E0E9),
      onSurfaceVariant: Color(0xFF49454F),

      // Background colors
      background: Color(0xFFFFFBFE),
      onBackground: Color(0xFF1C1B1F),

      // Error colors
      error: Color(0xFFBA1A1A),
      onError: Color(0xFFFFFFFF),
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF410002),

      // Outline colors
      outline: Color(0xFF79747E),
      outlineVariant: Color(0xFFCAC4D0),

      // Additional wellness-specific colors
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: Color(0xFF313033),
      onInverseSurface: Color(0xFFF4EFF4),
      inversePrimary: Color(0xFF9ECAFF),
    );

    /// Dark color scheme optimized for evening meditation
    static const ColorScheme darkWellness = ColorScheme.dark(
      // Primary colors - softer blue for night time
      primary: Color(0xFF9ECAFF),
      onPrimary: Color(0xFF001A33),
      primaryContainer: Color(0xFF2D5AA0),
      onPrimaryContainer: Color(0xFFD1E7FF),

      // Secondary colors - muted green for calm
      secondary: Color(0xFFB8E6A0),
      onSecondary: Color(0xFF0F2E00),
      secondaryContainer: Color(0xFF2A5515),
      onSecondaryContainer: Color(0xFFE8F5D1),

      // Tertiary colors - warm amber for comfort
      tertiary: Color(0xFFFFD595),
      onTertiary: Color(0xFF331A00),
      tertiaryContainer: Color(0xFF7A4F0A),
      onTertiaryContainer: Color(0xFFFFF2D1),

      // Surface colors for dark mode
      surface: Color(0xFF1C1B1F),
      onSurface: Color(0xFFE6E1E5),
      surfaceContainerLowest: Color(0xFF0F0D13),
      surfaceContainerLow: Color(0xFF201F23),
      surfaceContainer: Color(0xFF24232A),
      surfaceContainerHigh: Color(0xFF2F2E35),
      surfaceContainerHighest: Color(0xFF3A3940),
      onSurfaceVariant: Color(0xFFCAC4D0),

      // Background colors
      background: Color(0xFF1C1B1F),
      onBackground: Color(0xFFE6E1E5),

      // Error colors
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
      errorContainer: Color(0xFF93000A),
      onErrorContainer: Color(0xFFFFDAD6),

      // Outline colors
      outline: Color(0xFF938F99),
      outlineVariant: Color(0xFF49454F),

      // Additional wellness-specific colors
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: Color(0xFFE6E1E5),
      onInverseSurface: Color(0xFF313033),
      inversePrimary: Color(0xFF4A90E2),
    );

    /// Get dynamic color scheme for Material You support
    static Future<ColorScheme?> getDynamicColorScheme({bool dark = false}) async {
      if (!Platform.isAndroid) return null;

      try {
        // Implementation would use dynamic_color package
        // For now, return wellness-optimized schemes
        return dark ? darkWellness : lightWellness;
      } catch (e) {
        debugPrint('$_logTag: Failed to get dynamic color scheme: $e');
        return dark ? darkWellness : lightWellness;
      }
    }
  }

  /// Material 3 Typography for Wellness Content
  static class WellnessTypography {
    /// Typography scale optimized for wellness content readability
    static TextTheme buildWellnessTextTheme(ColorScheme colorScheme) {
      return TextTheme(
        // Display styles for hero content
        displayLarge: TextStyle(
          fontSize: 57,
          fontWeight: FontWeight.w400,
          color: colorScheme.onSurface,
          height: 1.12,
          letterSpacing: -0.25,
        ),
        displayMedium: TextStyle(
          fontSize: 45,
          fontWeight: FontWeight.w400,
          color: colorScheme.onSurface,
          height: 1.16,
          letterSpacing: 0,
        ),
        displaySmall: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w400,
          color: colorScheme.onSurface,
          height: 1.22,
          letterSpacing: 0,
        ),

        // Headline styles for section headers
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w400,
          color: colorScheme.onSurface,
          height: 1.25,
          letterSpacing: 0,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
          height: 1.29,
          letterSpacing: 0,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
          height: 1.33,
          letterSpacing: 0,
        ),

        // Title styles for life situations and content
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
          height: 1.27,
          letterSpacing: 0,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
          height: 1.5,
          letterSpacing: 0.15,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
          height: 1.43,
          letterSpacing: 0.1,
        ),

        // Label styles for buttons and tags
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
          height: 1.43,
          letterSpacing: 0.1,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
          height: 1.33,
          letterSpacing: 0.5,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
          height: 1.45,
          letterSpacing: 0.5,
        ),

        // Body styles for reading content
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: colorScheme.onSurface,
          height: 1.5,
          letterSpacing: 0.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: colorScheme.onSurface,
          height: 1.43,
          letterSpacing: 0.25,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: colorScheme.onSurface,
          height: 1.33,
          letterSpacing: 0.4,
        ),
      );
    }
  }

  /// Material 3 Component Themes for Wellness UI
  static class WellnessComponentThemes {
    /// Navigation bar theme for wellness categories
    static NavigationBarThemeData buildNavigationBarTheme(ColorScheme colorScheme) {
      return NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.secondaryContainer,
        elevation: 0,
        height: 80,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(
              color: colorScheme.onSecondaryContainer,
              size: 24,
            );
          }
          return IconThemeData(
            color: colorScheme.onSurfaceVariant,
            size: 24,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              color: colorScheme.onSurface,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            );
          }
          return TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 12,
            fontWeight: FontWeight.w400,
          );
        }),
      );
    }

    /// Card theme for life situation content
    static CardTheme buildCardTheme(ColorScheme colorScheme) {
      return CardTheme(
        color: colorScheme.surfaceContainer,
        shadowColor: colorScheme.shadow,
        surfaceTintColor: colorScheme.surfaceTint,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      );
    }

    /// App bar theme for meditation sessions
    static AppBarTheme buildAppBarTheme(ColorScheme colorScheme) {
      return AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: colorScheme.surfaceTint,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 16,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
        iconTheme: IconThemeData(
          color: colorScheme.onSurface,
          size: 24,
        ),
        actionsIconTheme: IconThemeData(
          color: colorScheme.onSurface,
          size: 24,
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness:
              colorScheme.brightness == Brightness.light
                  ? Brightness.dark
                  : Brightness.light,
        ),
      );
    }

    /// Floating action button theme for quick actions
    static FloatingActionButtonThemeData buildFABTheme(ColorScheme colorScheme) {
      return FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation: 3,
        focusElevation: 4,
        hoverElevation: 4,
        highlightElevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      );
    }

    /// Chip theme for wellness tags and categories
    static ChipThemeData buildChipTheme(ColorScheme colorScheme) {
      return ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        selectedColor: colorScheme.secondaryContainer,
        deleteIconColor: colorScheme.onSurface,
        disabledColor: colorScheme.surfaceContainer,
        labelStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
        pressElevation: 1,
      );
    }

    /// Progress indicator theme for meditation sessions
    static ProgressIndicatorThemeData buildProgressIndicatorTheme(ColorScheme colorScheme) {
      return ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.surfaceContainerHighest,
        circularTrackColor: colorScheme.surfaceContainerHighest,
        refreshBackgroundColor: colorScheme.surface,
      );
    }

    /// Bottom sheet theme for wellness content
    static BottomSheetThemeData buildBottomSheetTheme(ColorScheme colorScheme) {
      return BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: colorScheme.surfaceTint,
        elevation: 3,
        modalElevation: 5,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        clipBehavior: Clip.antiAlias,
        constraints: const BoxConstraints(
          maxWidth: double.infinity,
        ),
      );
    }

    /// Input decoration theme for forms
    static InputDecorationTheme buildInputDecorationTheme(ColorScheme colorScheme) {
      return InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.outline,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.outline,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.error,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.error,
            width: 2,
          ),
        ),
        labelStyle: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: 16,
        ),
        hintStyle: TextStyle(
          color: colorScheme.onSurfaceVariant.withOpacity(0.6),
          fontSize: 16,
        ),
        errorStyle: TextStyle(
          color: colorScheme.error,
          fontSize: 12,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      );
    }

    /// Switch theme for settings
    static SwitchThemeData buildSwitchTheme(ColorScheme colorScheme) {
      return SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.onPrimary;
          }
          return colorScheme.outline;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return colorScheme.surfaceContainerHighest;
        }),
      );
    }

    /// List tile theme for settings and navigation
    static ListTileThemeData buildListTileTheme(ColorScheme colorScheme) {
      return ListTileThemeData(
        tileColor: colorScheme.surface,
        selectedTileColor: colorScheme.secondaryContainer,
        iconColor: colorScheme.onSurface,
        textColor: colorScheme.onSurface,
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        subtitleTextStyle: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      );
    }
  }

  /// Build complete Material 3 theme for wellness app
  static ThemeData buildWellnessTheme({
    required ColorScheme colorScheme,
    bool useMaterial3 = true,
  }) {
    final textTheme = WellnessTypography.buildWellnessTextTheme(colorScheme);

    return ThemeData(
      useMaterial3: useMaterial3,
      colorScheme: colorScheme,
      textTheme: textTheme,

      // Component themes
      navigationBarTheme: WellnessComponentThemes.buildNavigationBarTheme(colorScheme),
      cardTheme: WellnessComponentThemes.buildCardTheme(colorScheme),
      appBarTheme: WellnessComponentThemes.buildAppBarTheme(colorScheme),
      floatingActionButtonTheme: WellnessComponentThemes.buildFABTheme(colorScheme),
      chipTheme: WellnessComponentThemes.buildChipTheme(colorScheme),
      progressIndicatorTheme: WellnessComponentThemes.buildProgressIndicatorTheme(colorScheme),
      bottomSheetTheme: WellnessComponentThemes.buildBottomSheetTheme(colorScheme),
      inputDecorationTheme: WellnessComponentThemes.buildInputDecorationTheme(colorScheme),
      switchTheme: WellnessComponentThemes.buildSwitchTheme(colorScheme),
      listTileTheme: WellnessComponentThemes.buildListTileTheme(colorScheme),

      // Additional component themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),

      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: colorScheme.onSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      iconTheme: IconThemeData(
        color: colorScheme.onSurface,
        size: 24,
      ),

      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      // Material 3 motion and easing
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
        },
      ),

      // Visual density for Android
      visualDensity: VisualDensity.standard,

      // Material 3 focus and hover
      focusColor: colorScheme.primary.withOpacity(0.12),
      hoverColor: colorScheme.onSurface.withOpacity(0.08),
      highlightColor: colorScheme.primary.withOpacity(0.12),
      splashColor: colorScheme.primary.withOpacity(0.12),

      // Accessibility
      materialTapTargetSize: MaterialTapTargetSize.standard,
    );
  }

  /// Get light wellness theme
  static ThemeData get lightWellnessTheme {
    return buildWellnessTheme(
      colorScheme: WellnessColorSchemes.lightWellness,
    );
  }

  /// Get dark wellness theme
  static ThemeData get darkWellnessTheme {
    return buildWellnessTheme(
      colorScheme: WellnessColorSchemes.darkWellness,
    );
  }

  /// Get dynamic wellness theme (Material You support)
  static Future<ThemeData?> getDynamicWellnessTheme({bool dark = false}) async {
    final dynamicColorScheme = await WellnessColorSchemes.getDynamicColorScheme(dark: dark);

    if (dynamicColorScheme != null) {
      return buildWellnessTheme(colorScheme: dynamicColorScheme);
    }

    return dark ? darkWellnessTheme : lightWellnessTheme;
  }

  /// Material 3 wellness-specific animations
  static class WellnessAnimations {
    static const Duration standardDuration = Duration(milliseconds: 300);
    static const Duration longDuration = Duration(milliseconds: 500);
    static const Duration shortDuration = Duration(milliseconds: 150);

    static const Curve standardCurve = Curves.easeInOut;
    static const Curve emphasizedCurve = Curves.easeOutCubic;
    static const Curve deceleratedCurve = Curves.easeOut;
    static const Curve acceleratedCurve = Curves.easeIn;

    /// Meditation progress animation
    static AnimationController createMeditationProgressController(TickerProvider vsync) {
      return AnimationController(
        duration: const Duration(seconds: 1),
        vsync: vsync,
      );
    }

    /// Life situation card entrance animation
    static Animation<Offset> createCardSlideAnimation(AnimationController controller) {
      return Tween<Offset>(
        begin: const Offset(0, 0.5),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: emphasizedCurve,
      ));
    }

    /// Wellness score fade animation
    static Animation<double> createFadeAnimation(AnimationController controller) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: standardCurve,
      ));
    }
  }

  /// Material 3 micro-interactions for wellness
  static class WellnessMicroInteractions {
    /// Haptic feedback for meditation interactions
    static void meditationFeedback() {
      if (Platform.isAndroid) {
        HapticFeedback.lightImpact();
      }
    }

    /// Success feedback for completed actions
    static void successFeedback() {
      if (Platform.isAndroid) {
        HapticFeedback.selectionClick();
      }
    }

    /// Error feedback for invalid actions
    static void errorFeedback() {
      if (Platform.isAndroid) {
        HapticFeedback.vibrate();
      }
    }

    /// Gentle feedback for wellness interactions
    static void gentleFeedback() {
      if (Platform.isAndroid) {
        HapticFeedback.selectionClick();
      }
    }
  }
}