import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../utils/life_area_utils.dart';
import 'tappable_scale.dart';

/// Situation card for displaying life situation items in lists
/// Inspired by GitaWisdom2's scenario cards with gradient accent
class SituationCard extends StatelessWidget {
  final String title;
  final String description;
  final String? lifeArea;
  final String? difficulty;
  final int? readTime;
  final List<String>? tags;
  final VoidCallback? onTap;
  final bool showGradientAccent;
  final bool hapticFeedback;
  final Widget? trailing;

  const SituationCard({
    super.key,
    required this.title,
    required this.description,
    this.lifeArea,
    this.difficulty,
    this.readTime,
    this.tags,
    this.onTap,
    this.showGradientAccent = true,
    this.hapticFeedback = true,
    this.trailing,
  });

  void _handleTap() {
    if (hapticFeedback) {
      HapticFeedback.lightImpact();
    }
    onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final areaColor = LifeAreaUtils.getColorForArea(lifeArea);
    final areaIcon = LifeAreaUtils.getIconForArea(lifeArea);

    return Semantics(
      button: true,
      label: '$title, ${lifeArea ?? 'general'} category${readTime != null ? ', $readTime minute read' : ''}',
      hint: 'Double tap to view full guidance',
      enabled: onTap != null,
      child: TappableScale(
        onTap: onTap != null ? _handleTap : null,
        enableHaptic: false, // We handle haptic in _handleTap
        child: Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shadowColor: AppColors.shadowMedium,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: areaColor.withValues(alpha: 0.3),
          width: 2.5, // Thick border
        ),
      ),
      child: InkWell(
        onTap: onTap != null ? _handleTap : null,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: showGradientAccent
                ? LinearGradient(
                    colors: [
                      areaColor.withValues(alpha: 0.15),
                      Colors.white,
                      Colors.white,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: const [0.0, 0.3, 1.0],
                  )
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row with icon and title
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Life area icon
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: areaColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        areaIcon,
                        color: areaColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Title and metadata
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.deepLavender,
                              letterSpacing: 0.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (readTime != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.schedule,
                                  size: 14,
                                  color: AppColors.lightGray,  // Icon - lighter is OK
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '$readTime min read',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.lightGray,  // Metadata - lighter is OK for small text
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (trailing != null) trailing!,
                  ],
                ),

                const SizedBox(height: 12),

                // Description
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.softCharcoal,  // Fixed: High contrast text color
                    height: 1.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

                // Tags and metadata
                if ((lifeArea != null || difficulty != null || (tags != null && tags!.isNotEmpty))) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (lifeArea != null)
                        _buildChip(
                          lifeArea!,
                          areaColor,
                          Icons.category_outlined,
                        ),
                      if (difficulty != null)
                        _buildChip(
                          difficulty!,
                          AppColors.softGray.withValues(alpha: 0.6),
                          Icons.signal_cellular_alt,
                        ),
                      if (tags != null && tags!.isNotEmpty)
                        ...tags!.take(2).map((tag) => _buildChip(
                              tag,
                              AppColors.lavender.withValues(alpha: 0.6),
                              Icons.label_outline,
                            )),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      ),
      ),
    );
  }

  Widget _buildChip(String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact situation card for smaller lists or horizontal scrolling
class CompactSituationCard extends StatelessWidget {
  final String title;
  final String? lifeArea;
  final VoidCallback? onTap;
  final double width;
  final bool hapticFeedback;

  const CompactSituationCard({
    super.key,
    required this.title,
    this.lifeArea,
    this.onTap,
    this.width = 200,
    this.hapticFeedback = true,
  });

  void _handleTap() {
    if (hapticFeedback) {
      HapticFeedback.lightImpact();
    }
    onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final areaColor = LifeAreaUtils.getColorForArea(lifeArea);

    return TappableScale(
      onTap: onTap != null ? _handleTap : null,
      enableHaptic: false, // We handle haptic in _handleTap
      child: SizedBox(
      width: width,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: onTap != null ? _handleTap : null,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  areaColor.withValues(alpha: 0.2),
                  Colors.white,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.deepLavender,
                    letterSpacing: 0.3,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                if (lifeArea != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: areaColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      lifeArea!,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: areaColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}
