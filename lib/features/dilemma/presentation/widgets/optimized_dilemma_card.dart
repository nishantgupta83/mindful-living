import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/gradient_cache.dart';

/// Optimized dilemma card with cached decorations and minimal rebuilds
class OptimizedDilemmaCard extends StatelessWidget {
  final Map<String, dynamic> dilemma;
  final VoidCallback onTap;
  final GradientCache _gradientCache = GradientCache();

  OptimizedDilemmaCard({
    super.key,
    required this.dilemma,
    required this.onTap,
  });

  // Pre-calculated colors for difficulty levels
  static const Map<String, Color> _difficultyColors = {
    'low': Colors.green,
    'medium': Colors.orange,
    'high': Colors.red,
  };

  @override
  Widget build(BuildContext context) {
    // Wrap in RepaintBoundary to prevent parent rebuilds affecting this card
    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              onTap();
            },
            borderRadius: BorderRadius.circular(20),
            child: _buildCardContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildCardContent() {
    final category = dilemma['category'].toString().toLowerCase();
    final colors = _gradientCache.getCategoryColors(category);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _getCardDecoration(colors),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(colors),
          const SizedBox(height: 12),
          _buildDescription(),
          const SizedBox(height: 12),
          _buildFooter(),
        ],
      ),
    );
  }

  BoxDecoration _getCardDecoration(List<Color> colors) {
    // Use pre-calculated decoration
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: colors[0].withOpacity(0.2),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: colors[0].withOpacity(0.1),
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }

  Widget _buildHeader(List<Color> colors) {
    return Row(
      children: [
        // Icon container with cached gradient
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: colors),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.psychology,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        // Title and category
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dilemma['title'],
                style: AppTypography.h5.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              _buildCategoryChip(colors),
            ],
          ),
        ),
        // Arrow icon
        Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: colors[0],
        ),
      ],
    );
  }

  Widget _buildCategoryChip(List<Color> colors) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.category, size: 14, color: colors[0]),
        const SizedBox(width: 4),
        Text(
          dilemma['category'],
          style: AppTypography.labelSmall.copyWith(
            color: colors[0],
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey[400],
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          dilemma['wellnessFocus'],
          style: AppTypography.labelSmall.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Text(
      dilemma['description'],
      style: AppTypography.bodySmall.copyWith(
        color: Colors.grey[600],
        height: 1.4,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildFooter() {
    final difficulty = dilemma['difficulty'].toString().toLowerCase();
    final difficultyColor = _difficultyColors[difficulty] ?? Colors.grey;

    return Row(
      children: [
        // Difficulty badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: difficultyColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            dilemma['difficulty'],
            style: AppTypography.labelSmall.copyWith(
              color: difficultyColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Spacer(),
        // Views counter
        Row(
          children: [
            Icon(Icons.visibility, size: 14, color: Colors.grey[400]),
            const SizedBox(width: 4),
            Text(
              '${dilemma['views']}',
              style: AppTypography.labelSmall.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ],
    );
  }
}