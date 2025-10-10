import 'package:flutter/material.dart';
import '../base/base_component.dart';
import '../adaptive/adaptive_components.dart';
import '../../../core/constants/app_colors.dart';

/// Signature card component for life situations and content
/// Features swipe gestures, AI personalization, and adaptive feedback
class MindfulCard extends BaseComponent {
  final String title;
  final String description;
  final String category;
  final List<String> tags;
  final VoidCallback? onTap;
  final VoidCallback? onSwipeLeft;
  final VoidCallback? onSwipeRight;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onShare;
  final bool isFavorited;
  final bool showAiInsight;
  final String? aiInsightText;
  final Color? accentColor;
  final Widget? customIcon;
  final EdgeInsets? customPadding;
  
  const MindfulCard({
    super.key,
    required this.title,
    required this.description,
    required this.category,
    this.tags = const [],
    this.onTap,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.onFavoriteToggle,
    this.onShare,
    this.isFavorited = false,
    this.showAiInsight = false,
    this.aiInsightText,
    this.accentColor,
    this.customIcon,
    this.customPadding,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = accentColor ?? _getCategoryColor();
    
    return GestureDetector(
      onTap: () {
        AdaptiveComponents.provideFeedback(type: HapticFeedbackType.light);
        onTap?.call();
      },
      onHorizontalDragEnd: _handleSwipeGesture,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        padding: customPadding ?? BaseComponent.defaultPadding,
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BaseComponent.defaultBorderRadius,
          boxShadow: BaseComponent.softShadow,
          border: Border.all(
            color: cardColor.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardHeader(context, cardColor),
            const SizedBox(height: 8.0),
            _buildCardContent(context),
            if (tags.isNotEmpty) ...[
              const SizedBox(height: 16.0),
              _buildTagsRow(),
            ],
            if (showAiInsight && aiInsightText != null) ...[
              const SizedBox(height: 16.0),
              _buildAiInsight(context),
            ],
            const SizedBox(height: 8.0),
            _buildCardActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCardHeader(BuildContext context, Color cardColor) {
    return Row(
      children: [
        // Category icon or custom icon
        Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: cardColor.withValues(alpha: 0.1),
            borderRadius: BaseComponent.smallBorderRadius,
          ),
          child: customIcon ?? Icon(
            _getCategoryIcon(),
            color: cardColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 16.0),
        // Category and title
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category.toUpperCase(),
                style: getTextTheme(context).labelSmall?.copyWith(
                  color: cardColor,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                title,
                style: getTextTheme(context).titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        // Favorite button
        IconButton(
          onPressed: () {
            AdaptiveComponents.provideFeedback(type: HapticFeedbackType.selection);
            onFavoriteToggle?.call();
          },
          icon: Icon(
            isFavorited ? Icons.favorite : Icons.favorite_border,
            color: isFavorited ? AppColors.error : AppColors.textLight,
          ),
        ),
      ],
    );
  }

  Widget _buildCardContent(BuildContext context) {
    return Text(
      description,
      style: getTextTheme(context).bodyMedium?.copyWith(
        color: AppColors.textSecondary,
        height: 1.4,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildTagsRow() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: tags.take(3).map((tag) => Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8.0,
          vertical: 4.0,
        ),
        decoration: BoxDecoration(
          color: AppColors.softGray,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          tag,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildAiInsight(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withValues(alpha: 0.05),
        borderRadius: BaseComponent.smallBorderRadius,
        border: Border.all(
          color: AppColors.primaryBlue.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.psychology,
            color: AppColors.primaryBlue,
            size: 16,
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              aiInsightText!,
              style: getTextTheme(context).bodySmall?.copyWith(
                color: AppColors.primaryBlue,
                fontStyle: FontStyle.italic,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardActions(BuildContext context) {
    return Row(
      children: [
        // Read time estimate
        Icon(
          Icons.schedule,
          size: 14,
          color: AppColors.textLight,
        ),
        const SizedBox(width: 4.0),
        Text(
          '3 min read',
          style: getTextTheme(context).labelSmall?.copyWith(
            color: AppColors.textLight,
          ),
        ),
        const Spacer(),
        // Share button
        IconButton(
          onPressed: () {
            AdaptiveComponents.provideFeedback(type: HapticFeedbackType.light);
            onShare?.call();
          },
          icon: const Icon(
            Icons.share_outlined,
            size: 18,
            color: AppColors.textLight,
          ),
        ),
        // Action indicator
        Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: AppColors.textLight,
        ),
      ],
    );
  }

  void _handleSwipeGesture(DragEndDetails details) {
    if (details.velocity.pixelsPerSecond.dx > 300) {
      // Swipe right - like/favorite
      AdaptiveComponents.provideFeedback(type: HapticFeedbackType.medium);
      onSwipeRight?.call();
    } else if (details.velocity.pixelsPerSecond.dx < -300) {
      // Swipe left - dismiss/next
      AdaptiveComponents.provideFeedback(type: HapticFeedbackType.light);
      onSwipeLeft?.call();
    }
  }

  Color _getCategoryColor() {
    switch (category.toLowerCase()) {
      case 'career':
        return AppColors.primaryBlue;
      case 'relationships':
        return AppColors.error;
      case 'family':
        return AppColors.mindfulOrange;
      case 'health':
        return AppColors.growthGreen;
      case 'personal growth':
        return AppColors.mindfulOrange;
      case 'financial':
        return AppColors.primaryBlue;
      default:
        return AppColors.primaryBlue;
    }
  }

  IconData _getCategoryIcon() {
    switch (category.toLowerCase()) {
      case 'career':
        return Icons.work_outline;
      case 'relationships':
        return Icons.favorite_outline;
      case 'family':
        return Icons.family_restroom;
      case 'health':
        return Icons.health_and_safety_outlined;
      case 'personal growth':
        return Icons.psychology_outlined;
      case 'financial':
        return Icons.account_balance_wallet_outlined;
      default:
        return Icons.lightbulb_outline;
    }
  }
}

/// Compact version of MindfulCard for lists
class MindfulCardCompact extends BaseComponent {
  final String title;
  final String category;
  final VoidCallback? onTap;
  final bool isFavorited;
  final Color? accentColor;

  const MindfulCardCompact({
    super.key,
    required this.title,
    required this.category,
    this.onTap,
    this.isFavorited = false,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = accentColor ?? _getCategoryColor();
    
    return GestureDetector(
      onTap: () {
        AdaptiveComponents.provideFeedback(type: HapticFeedbackType.light);
        onTap?.call();
      },
      child: Container(
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BaseComponent.smallBorderRadius,
          border: Border.all(
            color: cardColor.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              _getCategoryIcon(),
              color: cardColor,
              size: 20,
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.toUpperCase(),
                    style: getTextTheme(context).labelSmall?.copyWith(
                      color: cardColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    title,
                    style: getTextTheme(context).bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (isFavorited)
              Icon(
                Icons.favorite,
                color: AppColors.error,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor() {
    switch (category.toLowerCase()) {
      case 'career':
        return AppColors.primaryBlue;
      case 'relationships':
        return AppColors.error;
      case 'family':
        return AppColors.mindfulOrange;
      case 'health':
        return AppColors.growthGreen;
      case 'personal growth':
        return AppColors.mindfulOrange;
      case 'financial':
        return AppColors.primaryBlue;
      default:
        return AppColors.primaryBlue;
    }
  }

  IconData _getCategoryIcon() {
    switch (category.toLowerCase()) {
      case 'career':
        return Icons.work_outline;
      case 'relationships':
        return Icons.favorite_outline;
      case 'family':
        return Icons.family_restroom;
      case 'health':
        return Icons.health_and_safety_outlined;
      case 'personal growth':
        return Icons.psychology_outlined;
      case 'financial':
        return Icons.account_balance_wallet_outlined;
      default:
        return Icons.lightbulb_outline;
    }
  }
}