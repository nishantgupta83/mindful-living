import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;
import 'dart:math' as math;

/// Android-optimized Wellness Widgets for MindfulLiving App
///
/// Provides Android-specific widget implementations with:
/// - Material Design 3 compliance
/// - Android gesture recognition
/// - Performance optimizations for large datasets
/// - Accessibility features
/// - Platform-specific animations
class AndroidWellnessWidgets {
  static const String _logTag = 'AndroidWellnessWidgets';

  /// Life Situation Card optimized for Android scrolling performance
  static Widget buildLifeSituationCard({
    required String title,
    required String description,
    required String category,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
    List<String>? tags,
    String? difficulty,
    int? estimatedReadTime,
    bool? isFavorite,
    VoidCallback? onFavoriteToggle,
  }) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: () {
          _triggerHapticFeedback();
          onTap();
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with title and favorite button
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (onFavoriteToggle != null) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () {
                        _triggerHapticFeedback();
                        onFavoriteToggle();
                      },
                      icon: Icon(
                        isFavorite == true
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: isFavorite == true
                            ? colorScheme.error
                            : colorScheme.onSurfaceVariant,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 8),

              // Category indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Description
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

              if (tags != null || difficulty != null || estimatedReadTime != null) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    if (difficulty != null)
                      _buildInfoChip(
                        label: difficulty,
                        icon: Icons.signal_cellular_alt,
                        color: _getDifficultyColor(difficulty, colorScheme),
                        colorScheme: colorScheme,
                      ),
                    if (estimatedReadTime != null)
                      _buildInfoChip(
                        label: '${estimatedReadTime}min read',
                        icon: Icons.schedule,
                        color: colorScheme.tertiaryContainer,
                        colorScheme: colorScheme,
                      ),
                    if (tags != null)
                      ...tags.take(2).map((tag) => _buildInfoChip(
                        label: tag,
                        color: colorScheme.surfaceContainerHighest,
                        colorScheme: colorScheme,
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

  /// Meditation Progress Circle with Android-specific animations
  static Widget buildMeditationProgressCircle({
    required double progress,
    required Duration totalDuration,
    required Duration currentDuration,
    required ColorScheme colorScheme,
    double size = 200,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap != null ? () {
        _triggerHapticFeedback();
        onTap();
      } : null,
      child: Container(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background circle
            SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                value: 1.0,
                strokeWidth: 8,
                backgroundColor: colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  colorScheme.surfaceContainerHighest,
                ),
              ),
            ),

            // Progress circle
            SizedBox(
              width: size,
              height: size,
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 300),
                tween: Tween<double>(begin: 0, end: progress),
                builder: (context, animatedProgress, child) {
                  return CircularProgressIndicator(
                    value: animatedProgress,
                    strokeWidth: 8,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                    strokeCap: StrokeCap.round,
                  );
                },
              ),
            ),

            // Center content
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatDuration(currentDuration),
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w300,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'of ${_formatDuration(totalDuration)}',
                  style: TextStyle(
                    fontSize: 16,
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                  minHeight: 4,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Wellness Dashboard Card with Android Material 3 styling
  static Widget buildWellnessDashboardCard({
    required String title,
    required String value,
    required IconData icon,
    required ColorScheme colorScheme,
    VoidCallback? onTap,
    String? subtitle,
    String? trend,
    Color? accentColor,
    Widget? customContent,
  }) {
    final cardColor = accentColor ?? colorScheme.primary;

    return Card(
      elevation: 1,
      child: InkWell(
        onTap: onTap != null ? () {
          _triggerHapticFeedback();
          onTap();
        } : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon and trend
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cardColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: cardColor,
                      size: 24,
                    ),
                  ),
                  const Spacer(),
                  if (trend != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getTrendColor(trend, colorScheme).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getTrendIcon(trend),
                            size: 12,
                            color: _getTrendColor(trend, colorScheme),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            trend,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: _getTrendColor(trend, colorScheme),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (onTap != null) ...[
                    const SizedBox(width: 8),
                    Icon(
                      Icons.chevron_right,
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                      size: 20,
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 16),

              // Main value
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),

              const SizedBox(height: 4),

              // Title
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

              if (customContent != null) ...[
                const SizedBox(height: 12),
                customContent,
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Category Grid Tile optimized for Android touch targets
  static Widget buildCategoryGridTile({
    required String title,
    required String description,
    required IconData icon,
    required int itemCount,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
    Color? backgroundColor,
    String? imagePath,
  }) {
    final bgColor = backgroundColor ?? colorScheme.primaryContainer;

    return Card(
      elevation: 1,
      child: InkWell(
        onTap: () {
          _triggerHapticFeedback();
          onTap();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                bgColor,
                bgColor.withValues(alpha: 0.8),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon or image
              if (imagePath != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    imagePath,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.surface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: colorScheme.onPrimaryContainer,
                    size: 24,
                  ),
                ),

              const SizedBox(height: 12),

              // Title
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onPrimaryContainer,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 4),

              // Description
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const Spacer(),

              // Item count
              Row(
                children: [
                  Icon(
                    Icons.article_outlined,
                    size: 16,
                    color: colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$itemCount situations',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Android-optimized Search Bar with Material 3 styling
  static Widget buildSearchBar({
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
    required ColorScheme colorScheme,
    String? hintText,
    VoidCallback? onClear,
    List<String>? suggestions,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          TextField(
            controller: controller,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hintText ?? 'Search life situations...',
              prefixIcon: Icon(
                Icons.search,
                color: colorScheme.onSurfaceVariant,
              ),
              suffixIcon: controller.text.isNotEmpty && onClear != null
                  ? IconButton(
                      onPressed: () {
                        _triggerHapticFeedback();
                        onClear();
                      },
                      icon: Icon(
                        Icons.clear,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    )
                  : null,
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),

          if (suggestions != null && suggestions.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: suggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = suggestions[index];
                  return ListTile(
                    leading: Icon(
                      Icons.search,
                      color: colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                    title: Text(
                      suggestion,
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    onTap: () {
                      _triggerHapticFeedback();
                      controller.text = suggestion;
                      onChanged(suggestion);
                    },
                    dense: true,
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Mood Check-in Widget with Android touch feedback
  static Widget buildMoodCheckIn({
    required List<MoodOption> moodOptions,
    required ValueChanged<MoodOption> onMoodSelected,
    required ColorScheme colorScheme,
    MoodOption? selectedMood,
  }) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How are you feeling?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemCount: moodOptions.length,
              itemBuilder: (context, index) {
                final mood = moodOptions[index];
                final isSelected = selectedMood?.emoji == mood.emoji;

                return GestureDetector(
                  onTap: () {
                    _triggerMoodFeedback();
                    onMoodSelected(mood);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorScheme.primaryContainer
                          : colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? colorScheme.primary
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          mood.emoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          mood.label,
                          style: TextStyle(
                            fontSize: 10,
                            color: isSelected
                                ? colorScheme.onPrimaryContainer
                                : colorScheme.onSurfaceVariant,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Quick Action Button optimized for Android
  static Widget buildQuickActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
    Color? backgroundColor,
  }) {
    final bgColor = backgroundColor ?? colorScheme.secondaryContainer;

    return InkWell(
      onTap: () {
        _triggerHapticFeedback();
        onTap();
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: colorScheme.onSecondaryContainer,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: colorScheme.onSecondaryContainer,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper methods
  static Widget _buildInfoChip({
    required String label,
    required ColorScheme colorScheme,
    IconData? icon,
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color ?? colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 12,
              color: colorScheme.onSurface,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  static Color _getDifficultyColor(String difficulty, ColorScheme colorScheme) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return colorScheme.secondaryContainer;
      case 'medium':
        return colorScheme.tertiaryContainer;
      case 'hard':
        return colorScheme.errorContainer;
      default:
        return colorScheme.surfaceContainerHighest;
    }
  }

  static Color _getTrendColor(String trend, ColorScheme colorScheme) {
    if (trend.startsWith('+') || trend.toLowerCase().contains('up')) {
      return Colors.green;
    } else if (trend.startsWith('-') || trend.toLowerCase().contains('down')) {
      return colorScheme.error;
    }
    return colorScheme.onSurfaceVariant;
  }

  static IconData _getTrendIcon(String trend) {
    if (trend.startsWith('+') || trend.toLowerCase().contains('up')) {
      return Icons.trending_up;
    } else if (trend.startsWith('-') || trend.toLowerCase().contains('down')) {
      return Icons.trending_down;
    }
    return Icons.trending_flat;
  }

  static String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  static void _triggerHapticFeedback() {
    if (Platform.isAndroid) {
      HapticFeedback.lightImpact();
    }
  }

  static void _triggerMoodFeedback() {
    if (Platform.isAndroid) {
      HapticFeedback.selectionClick();
    }
  }
}

/// Data models for Android wellness widgets
class MoodOption {
  final String emoji;
  final String label;
  final int value;

  const MoodOption({
    required this.emoji,
    required this.label,
    required this.value,
  });

  static const List<MoodOption> defaultMoods = [
    MoodOption(emoji: '😢', label: 'Sad', value: 1),
    MoodOption(emoji: '😕', label: 'Down', value: 2),
    MoodOption(emoji: '😐', label: 'Okay', value: 3),
    MoodOption(emoji: '😊', label: 'Good', value: 4),
    MoodOption(emoji: '😄', label: 'Great', value: 5),
  ];
}

/// Android-specific layout builders
class AndroidLayoutBuilder {
  /// Build responsive grid for different screen sizes
  static int getGridCrossAxisCount(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 600) {
      return 2; // Phone
    } else if (screenWidth < 900) {
      return 3; // Small tablet
    } else {
      return 4; // Large tablet
    }
  }

  /// Get optimal card width for current screen
  static double getOptimalCardWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const minCardWidth = 300.0;
    const maxCardWidth = 400.0;
    const padding = 32.0;

    final availableWidth = screenWidth - padding;
    return math.min(maxCardWidth, math.max(minCardWidth, availableWidth));
  }

  /// Check if device is in landscape mode
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Get safe area padding for Android
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }
}