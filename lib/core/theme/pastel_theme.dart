import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';

class PastelTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Color Scheme with Pastels
      colorScheme: ColorScheme.light(
        primary: AppColors.lavender,
        onPrimary: AppColors.deepLavender,
        secondary: AppColors.mintGreen,
        onSecondary: AppColors.softCharcoal,
        tertiary: AppColors.peach,
        onTertiary: AppColors.softCharcoal,
        surface: AppColors.mistyWhite,
        onSurface: AppColors.softCharcoal,
        surfaceContainerHighest: AppColors.softGray,
        background: AppColors.cream,
        onBackground: AppColors.softCharcoal,
        error: AppColors.error,
        onError: AppColors.softCharcoal,
        outline: AppColors.paleGray,
        outlineVariant: AppColors.mutedGray,
      ),
      
      // App Bar Theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.cream,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.deepLavender,
        titleTextStyle: AppTypography.h4.copyWith(
          color: AppColors.deepLavender,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.deepLavender,
          size: 24,
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: AppColors.cream,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.mistyWhite,
        surfaceTintColor: Colors.transparent,
        shadowColor: AppColors.shadowLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: const EdgeInsets.all(0),
      ),
      
      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.lavender,
          foregroundColor: AppColors.deepLavender,
          surfaceTintColor: Colors.transparent,
          shadowColor: AppColors.shadowPastel,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: AppTypography.labelLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.deepLavender,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTypography.labelMedium.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.deepLavender,
          side: const BorderSide(color: AppColors.paleGray, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: AppTypography.labelLarge.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.softGray,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.paleGray, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.lavender, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.all(20),
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.mutedGray,
        ),
        labelStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.lightGray,
        ),
        floatingLabelStyle: AppTypography.labelMedium.copyWith(
          color: AppColors.deepLavender,
        ),
      ),
      
      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.softGray,
        selectedColor: AppColors.lavender,
        disabledColor: AppColors.mutedGray,
        labelStyle: AppTypography.labelSmall.copyWith(
          color: AppColors.softCharcoal,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
        pressElevation: 0,
      ),
      
      // FloatingActionButton Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.lavender,
        foregroundColor: AppColors.deepLavender,
        elevation: 8,
        focusElevation: 8,
        hoverElevation: 12,
        highlightElevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.mistyWhite,
        selectedItemColor: AppColors.deepLavender,
        unselectedItemColor: AppColors.lightGray,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: AppTypography.labelSmall.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTypography.labelSmall,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
      
      // Scaffold Background
      scaffoldBackgroundColor: AppColors.cream,
      
      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.paleGray,
        thickness: 1,
        space: 1,
      ),
      
      // Icon Theme
      iconTheme: const IconThemeData(
        color: AppColors.lightGray,
        size: 24,
      ),
      
      primaryIconTheme: const IconThemeData(
        color: AppColors.deepLavender,
        size: 24,
      ),
      
      // Text Theme with Pastel Colors
      textTheme: TextTheme(
        displayLarge: AppTypography.h1.copyWith(color: AppColors.deepLavender),
        displayMedium: AppTypography.h2.copyWith(color: AppColors.deepLavender),
        displaySmall: AppTypography.h3.copyWith(color: AppColors.deepLavender),
        headlineLarge: AppTypography.h4.copyWith(color: AppColors.deepLavender),
        headlineMedium: AppTypography.h5.copyWith(color: AppColors.deepLavender),
        headlineSmall: AppTypography.h6.copyWith(color: AppColors.deepLavender),
        titleLarge: AppTypography.h6.copyWith(color: AppColors.softCharcoal),
        titleMedium: AppTypography.bodyLarge.copyWith(color: AppColors.softCharcoal),
        titleSmall: AppTypography.bodyMedium.copyWith(color: AppColors.softCharcoal),
        bodyLarge: AppTypography.bodyLarge.copyWith(color: AppColors.softCharcoal),
        bodyMedium: AppTypography.bodyMedium.copyWith(color: AppColors.softCharcoal),
        bodySmall: AppTypography.bodySmall.copyWith(color: AppColors.lightGray),
        labelLarge: AppTypography.labelLarge.copyWith(color: AppColors.softCharcoal),
        labelMedium: AppTypography.labelMedium.copyWith(color: AppColors.lightGray),
        labelSmall: AppTypography.labelSmall.copyWith(color: AppColors.lightGray),
      ),
      
      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.lavender,
        linearTrackColor: AppColors.softGray,
        circularTrackColor: AppColors.softGray,
      ),
      
      // Slider Theme
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.lavender,
        inactiveTrackColor: AppColors.softGray,
        thumbColor: AppColors.deepLavender,
        overlayColor: AppColors.withOpacity(AppColors.lavender, 0.2),
        valueIndicatorColor: AppColors.deepLavender,
        valueIndicatorTextStyle: AppTypography.labelSmall.copyWith(
          color: AppColors.mistyWhite,
        ),
      ),
    );
  }
  
  // Dark theme could be added later if needed
  static ThemeData get darkTheme {
    // For now, return light theme
    // Could be implemented with darker pastels in the future
    return lightTheme;
  }
}