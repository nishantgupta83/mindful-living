import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  // Primary Font: Inter
  static TextStyle get _baseInter => GoogleFonts.inter();
  
  // Secondary Font: Poppins
  static TextStyle get _basePoppins => GoogleFonts.poppins();

  // Headings (using Poppins for friendly approach)
  static TextStyle get h1 => _basePoppins.copyWith(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static TextStyle get h2 => _basePoppins.copyWith(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static TextStyle get h3 => _basePoppins.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static TextStyle get h4 => _basePoppins.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static TextStyle get h5 => _basePoppins.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static TextStyle get h6 => _basePoppins.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  // Body Text (using Inter for clean readability)
  static TextStyle get bodyLarge => _baseInter.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static TextStyle get bodyMedium => _baseInter.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static TextStyle get bodySmall => _baseInter.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  // Labels
  static TextStyle get labelLarge => _baseInter.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static TextStyle get labelMedium => _baseInter.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static TextStyle get labelSmall => _baseInter.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textLight,
    height: 1.3,
  );

  // Special Styles
  static TextStyle get caption => _baseInter.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textLight,
    height: 1.3,
  );

  static TextStyle get overline => _baseInter.copyWith(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.textLight,
    letterSpacing: 1.5,
    height: 1.6,
  );

  // Button Text
  static TextStyle get buttonLarge => _baseInter.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static TextStyle get buttonMedium => _baseInter.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static TextStyle get buttonSmall => _baseInter.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );
  
  // Material 3 Style Headlines
  static TextStyle get headlineLarge => _basePoppins.copyWith(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.25,
  );
  
  static TextStyle get headlineMedium => _basePoppins.copyWith(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );
  
  static TextStyle get headlineSmall => _basePoppins.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );
}