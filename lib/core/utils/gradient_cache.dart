import 'package:flutter/material.dart';

/// Singleton gradient cache to prevent recalculation of gradients
class GradientCache {
  static final GradientCache _instance = GradientCache._internal();
  factory GradientCache() => _instance;
  GradientCache._internal() {
    _initializeGradients();
  }

  // Cache for linear gradients
  final Map<String, LinearGradient> _linearGradients = {};

  // Cache for box decorations
  final Map<String, BoxDecoration> _decorations = {};

  // Cache for box shadows
  final Map<String, List<BoxShadow>> _shadows = {};

  // Category colors (pre-calculated)
  static const Map<String, List<Color>> categoryColors = {
    'relationships': [Color(0xFF9C27B0), Color(0xFFBA68C8)],
    'career': [Color(0xFF00897B), Color(0xFF26A69A)],
    'finance': [Color(0xFF2E7D32), Color(0xFF43A047)],
    'mental health': [Color(0xFF1976D2), Color(0xFF42A5F5)],
    'family': [Color(0xFFFB8C00), Color(0xFFFFA726)],
    'health': [Color(0xFFE91E63), Color(0xFFEC407A)],
    'all': [Color(0xFF5E35B1), Color(0xFF7E57C2)],
  };

  void _initializeGradients() {
    // Pre-calculate all category gradients
    categoryColors.forEach((key, colors) {
      // Full gradient
      _linearGradients['${key}_full'] = LinearGradient(
        colors: colors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

      // Light gradient (for unselected state)
      _linearGradients['${key}_light'] = LinearGradient(
        colors: [
          colors[0].withValues(alpha: 0.1),
          colors[1].withValues(alpha: 0.05),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

      // Create cached decorations
      _decorations['${key}_selected'] = BoxDecoration(
        gradient: _linearGradients['${key}_full'],
        borderRadius: BorderRadius.circular(20),
        boxShadow: getCachedShadow('${key}_selected'),
      );

      _decorations['${key}_unselected'] = BoxDecoration(
        gradient: _linearGradients['${key}_light'],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors[0].withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: getCachedShadow('${key}_unselected'),
      );

      // Cache shadows
      _shadows['${key}_selected'] = [
        BoxShadow(
          color: colors[0].withValues(alpha: 0.4),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

      _shadows['${key}_unselected'] = [
        BoxShadow(
          color: colors[0].withValues(alpha: 0.15),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ];
    });

    // Add background gradients
    _linearGradients['background_light'] = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white,
        Colors.grey[50]!,
      ],
    );
  }

  // Get cached gradient
  LinearGradient getGradient(String key) {
    return _linearGradients[key] ??
           _linearGradients['all_full']!;
  }

  // Get cached decoration
  BoxDecoration getDecoration(String category, bool isSelected) {
    final key = '${category.toLowerCase()}_${isSelected ? 'selected' : 'unselected'}';
    return _decorations[key] ??
           _decorations['all_${isSelected ? 'selected' : 'unselected'}']!;
  }

  // Get cached shadow
  List<BoxShadow> getCachedShadow(String key) {
    return _shadows[key] ?? const [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 5,
        offset: Offset(0, 2),
      ),
    ];
  }

  // Get category colors
  List<Color> getCategoryColors(String category) {
    return categoryColors[category.toLowerCase()] ?? categoryColors['all']!;
  }

  // Create optimized container decoration
  static BoxDecoration createOptimizedDecoration({
    required String category,
    required bool isSelected,
    BorderRadius? borderRadius,
  }) {
    final cache = GradientCache();
    final baseDecoration = cache.getDecoration(category, isSelected);

    if (borderRadius != null) {
      return BoxDecoration(
        gradient: baseDecoration.gradient,
        borderRadius: borderRadius,
        border: baseDecoration.border,
        boxShadow: baseDecoration.boxShadow,
      );
    }

    return baseDecoration;
  }

  // Clear cache (if needed for memory management)
  void clearCache() {
    _linearGradients.clear();
    _decorations.clear();
    _shadows.clear();
    _initializeGradients();
  }
}