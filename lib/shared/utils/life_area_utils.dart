import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Utility class for consistent life area styling across the app
/// Centralizes color, icon, and gradient mapping for all life areas
class LifeAreaUtils {
  LifeAreaUtils._();

  /// Map of life areas to their primary colors
  static const Map<String, Color> _areaColors = {
    'wellness': AppColors.mintGreen,
    'health': AppColors.mintGreen,
    'relationships': AppColors.peach,
    'family': AppColors.peach,
    'career': AppColors.skyBlue,
    'work': AppColors.skyBlue,
    'growth': AppColors.softPurple,
    'personal': AppColors.softPurple,
    'mindfulness': AppColors.lavender,
    'meditation': AppColors.lavender,
    'stress': AppColors.peach,
    'finance': AppColors.lemon,
    'communication': AppColors.skyBlue,
    'life balance': AppColors.lavender,
  };

  /// Map of life areas to their icons
  static const Map<String, IconData> _areaIcons = {
    'wellness': Icons.spa_outlined,
    'health': Icons.health_and_safety_outlined,
    'relationships': Icons.favorite_border,
    'family': Icons.people_outline,
    'career': Icons.work_outline,
    'work': Icons.work_outline,
    'growth': Icons.trending_up,
    'personal': Icons.trending_up,
    'mindfulness': Icons.self_improvement,
    'meditation': Icons.self_improvement,
    'stress': Icons.psychology_outlined,
    'finance': Icons.account_balance_wallet_outlined,
    'communication': Icons.chat_bubble_outline,
    'life balance': Icons.balance,
  };

  /// Map of life areas to their gradient colors
  static const Map<String, List<Color>> _areaGradients = {
    'wellness': AppColors.mintGradient,
    'health': AppColors.mintGradient,
    'relationships': AppColors.peachGradient,
    'family': AppColors.peachGradient,
    'career': AppColors.skyGradient,
    'work': AppColors.skyGradient,
    'growth': AppColors.dreamGradient,
    'personal': AppColors.dreamGradient,
    'mindfulness': AppColors.primaryGradient,
    'meditation': AppColors.primaryGradient,
    'stress': AppColors.peachGradient,
    'finance': AppColors.sunsetGradient,
    'communication': AppColors.oceanGradient,
    'life balance': AppColors.primaryGradient,
  };

  /// Get color for a life area
  /// Returns lavender as fallback for unknown areas
  static Color getColorForArea(String? area) {
    if (area == null) return AppColors.lavender;
    return _areaColors[area.toLowerCase()] ?? AppColors.lavender;
  }

  /// Get icon for a life area
  /// Returns lightbulb as fallback for unknown areas
  static IconData getIconForArea(String? area) {
    if (area == null) return Icons.lightbulb_outline;
    return _areaIcons[area.toLowerCase()] ?? Icons.lightbulb_outline;
  }

  /// Get gradient colors for a life area
  /// Returns primary gradient as fallback for unknown areas
  static List<Color> getGradientForArea(String? area) {
    if (area == null) return AppColors.primaryGradient;
    return _areaGradients[area.toLowerCase()] ?? AppColors.primaryGradient;
  }

  /// Get all available life areas
  static List<String> getAllAreas() {
    return _areaColors.keys.toSet().toList()..sort();
  }

  /// Check if a life area is valid
  static bool isValidArea(String? area) {
    if (area == null) return false;
    return _areaColors.containsKey(area.toLowerCase());
  }

  /// Get a readable label for a life area (capitalize first letter)
  static String getDisplayLabel(String area) {
    return area[0].toUpperCase() + area.substring(1).toLowerCase();
  }
}
