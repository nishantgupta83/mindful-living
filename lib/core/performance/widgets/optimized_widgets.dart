/// Optimized widgets specifically designed for MindfulLiving app performance
///
/// This file contains high-performance widgets that address specific performance
/// issues found in the wellness app, including optimized list items, cached
/// gradients, and efficient animation widgets.

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_typography.dart';

/// Optimized version of the dilemma card with performance improvements
class OptimizedDilemmaCard extends StatelessWidget {
  final Map<String, dynamic> dilemma;
  final VoidCallback onTap;

  const OptimizedDilemmaCard({
    super.key,
    required this.dilemma,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: OptimizedPastelCard(
        onTap: onTap,
        gradientColors: _getCachedCategoryGradient(dilemma['category']),
        child: _buildCardContent(),
      ),
    );
  }

  Widget _buildCardContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 16),
        _buildDescription(),
        const SizedBox(height: 16),
        _buildFooter(),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        _CachedIconContainer(
          icon: Icons.psychology,
          color: AppColors.deepLavender,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dilemma['title'],
                style: AppTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.deepLavender,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                dilemma['category'],
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.softCharcoal,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        _CachedDifficultyBadge(difficulty: dilemma['difficulty']),
      ],
    );
  }

  Widget _buildDescription() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.withOpacity(AppColors.mistyWhite, 0.6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        dilemma['description'],
        style: AppTypography.bodyMedium.copyWith(
          color: AppColors.deepCharcoal,
          height: 1.4,
        ),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        _CachedWellnessBadge(wellnessFocus: dilemma['wellnessFocus']),
        const Spacer(),
        Row(
          children: [
            const Icon(
              Icons.visibility,
              size: 14,
              color: AppColors.lightGray,
            ),
            const SizedBox(width: 4),
            Text(
              '${dilemma['views']}',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.lightGray,
              ),
            ),
            const SizedBox(width: 12),
            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: AppColors.deepLavender,
            ),
          ],
        ),
      ],
    );
  }
}

/// Cached gradient provider for better performance
class _GradientCache {
  static final Map<String, List<Color>> _cache = {};

  static List<Color> getCategoryGradient(String category) {
    return _cache.putIfAbsent(category, () => _computeGradient(category));
  }

  static List<Color> _computeGradient(String category) {
    switch (category.toLowerCase()) {
      case 'relationship':
        return AppColors.dreamGradient;
      case 'career':
        return AppColors.oceanGradient;
      case 'family':
        return AppColors.primaryGradient;
      case 'personal':
        return AppColors.sunsetGradient;
      default:
        return AppColors.dreamGradient;
    }
  }
}

List<Color> _getCachedCategoryGradient(String category) {
  return _GradientCache.getCategoryGradient(category);
}

/// Optimized pastel card with cached decorations
class OptimizedPastelCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final List<Color> gradientColors;
  final EdgeInsets? margin;

  const OptimizedPastelCard({
    super.key,
    required this.child,
    this.onTap,
    required this.gradientColors,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: _getCachedDecoration(),
            child: child,
          ),
        ),
      ),
    );
  }

  BoxDecoration _getCachedDecoration() {
    return BoxDecoration(
      gradient: AppColors.createGradient(gradientColors),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: AppColors.withOpacity(AppColors.mistyWhite, 0.5),
        width: 1,
      ),
      boxShadow: const [
        BoxShadow(
          color: AppColors.shadowLight,
          blurRadius: 15,
          offset: Offset(0, 8),
        ),
      ],
    );
  }
}

/// Cached icon container to avoid rebuilding decorations
class _CachedIconContainer extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _CachedIconContainer({
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _cachedDecoration,
      child: Icon(
        icon,
        color: color,
        size: 20,
      ),
    );
  }

  static final BoxDecoration _cachedDecoration = BoxDecoration(
    color: AppColors.withOpacity(AppColors.mistyWhite, 0.8),
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: AppColors.withOpacity(AppColors.deepLavender, 0.1),
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ],
  );
}

/// Cached difficulty badge to avoid repeated color calculations
class _CachedDifficultyBadge extends StatelessWidget {
  final String difficulty;

  const _CachedDifficultyBadge({required this.difficulty});

  @override
  Widget build(BuildContext context) {
    final difficultyColor = _getDifficultyColor(difficulty);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.withOpacity(difficultyColor, 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.withOpacity(difficultyColor, 0.3),
        ),
      ),
      child: Text(
        difficulty,
        style: AppTypography.labelSmall.copyWith(
          color: difficultyColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static final Map<String, Color> _difficultyColors = {
    'low': AppColors.mintGreen,
    'medium': AppColors.peach,
    'high': AppColors.softPurple,
  };

  Color _getDifficultyColor(String difficulty) {
    return _difficultyColors[difficulty.toLowerCase()] ?? AppColors.deepLavender;
  }
}

/// Cached wellness badge with pre-computed styles
class _CachedWellnessBadge extends StatelessWidget {
  final String wellnessFocus;

  const _CachedWellnessBadge({required this.wellnessFocus});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: _cachedDecoration,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.spa,
            size: 14,
            color: AppColors.deepLavender,
          ),
          const SizedBox(width: 4),
          Text(
            wellnessFocus,
            style: _cachedTextStyle,
          ),
        ],
      ),
    );
  }

  static final BoxDecoration _cachedDecoration = BoxDecoration(
    color: AppColors.withOpacity(AppColors.mintGreen, 0.2),
    borderRadius: BorderRadius.circular(8),
  );

  static final TextStyle _cachedTextStyle = AppTypography.labelSmall.copyWith(
    color: AppColors.deepLavender,
    fontWeight: FontWeight.w600,
  );
}

/// Optimized action card with efficient animations
class OptimizedActionCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const OptimizedActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  State<OptimizedActionCard> createState() => _OptimizedActionCardState();
}

class _OptimizedActionCardState extends State<OptimizedActionCard>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _rotateController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 0.02,
    ).animate(CurvedAnimation(
      parent: _rotateController,
      curve: Curves.easeInOut,
    ));

    _pulseController.repeat(reverse: true);
    _rotateController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: OptimizedPastelCard(
        onTap: widget.onTap,
        gradientColors: widget.gradientColors,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAnimatedIcon(),
            const SizedBox(height: 12),
            _buildTitle(),
            const SizedBox(height: 4),
            _buildSubtitle(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedIcon() {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseController, _rotateController]),
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Transform.rotate(
            angle: _rotateAnimation.value,
            child: _CachedIconContainer(
              icon: widget.icon,
              color: AppColors.deepLavender,
            ),
          ),
        );
      },
    );
  }

  Widget _buildTitle() {
    return Text(
      widget.title,
      style: AppTypography.labelLarge.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.deepLavender,
      ),
    );
  }

  Widget _buildSubtitle() {
    return Text(
      widget.subtitle,
      style: AppTypography.bodySmall.copyWith(
        color: AppColors.softCharcoal,
      ),
    );
  }
}

/// Optimized list view for scenarios with virtualization
class OptimizedScenarioList extends StatelessWidget {
  final List<Map<String, dynamic>> scenarios;
  final Function(Map<String, dynamic>) onScenarioTap;
  final ScrollController? scrollController;

  const OptimizedScenarioList({
    super.key,
    required this.scenarios,
    required this.onScenarioTap,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
      itemCount: scenarios.length,
      cacheExtent: 500, // Cache 500 pixels ahead
      itemExtent: 200, // Fixed height for better performance
      itemBuilder: (context, index) {
        return _OptimizedListItem(
          scenario: scenarios[index],
          onTap: () => onScenarioTap(scenarios[index]),
        );
      },
    );
  }
}

/// Optimized list item with AutomaticKeepAliveClientMixin
class _OptimizedListItem extends StatefulWidget {
  final Map<String, dynamic> scenario;
  final VoidCallback onTap;

  const _OptimizedListItem({
    required this.scenario,
    required this.onTap,
  });

  @override
  State<_OptimizedListItem> createState() => _OptimizedListItemState();
}

class _OptimizedListItemState extends State<_OptimizedListItem>
    with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return RepaintBoundary(
      child: OptimizedDilemmaCard(
        dilemma: widget.scenario,
        onTap: widget.onTap,
      ),
    );
  }
}

/// High-performance search widget with debouncing
class OptimizedSearchBar extends StatefulWidget {
  final Function(String) onSearchChanged;
  final String hintText;

  const OptimizedSearchBar({
    super.key,
    required this.onSearchChanged,
    this.hintText = 'Search...',
  });

  @override
  State<OptimizedSearchBar> createState() => _OptimizedSearchBarState();
}

class _OptimizedSearchBarState extends State<OptimizedSearchBar> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounceTimer;

  @override
  void dispose() {
    _controller.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      widget.onSearchChanged(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cachedDecoration,
      child: TextField(
        controller: _controller,
        onChanged: _onSearchChanged,
        style: AppTypography.bodyMedium.copyWith(
          color: AppColors.deepCharcoal,
        ),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.lightGray,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.deepLavender,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  static final BoxDecoration _cachedDecoration = BoxDecoration(
    color: AppColors.withOpacity(AppColors.mistyWhite, 0.9),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: AppColors.withOpacity(AppColors.paleGray, 0.3),
      width: 1,
    ),
    boxShadow: const [
      BoxShadow(
        color: AppColors.shadowLight,
        blurRadius: 8,
        offset: Offset(0, 4),
      ),
    ],
  );
}

/// Optimized category filter with cached widgets
class OptimizedCategoryFilter extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const OptimizedCategoryFilter({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selectedCategory;

          return RepaintBoundary(
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _CategoryChip(
                category: category,
                isSelected: isSelected,
                onTap: () => onCategorySelected(category),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: _getDecoration(),
        child: Text(
          category,
          style: _getTextStyle(),
        ),
      ),
    );
  }

  BoxDecoration _getDecoration() {
    if (isSelected) {
      return _selectedDecoration;
    } else {
      return _unselectedDecoration;
    }
  }

  TextStyle _getTextStyle() {
    return AppTypography.labelMedium.copyWith(
      color: isSelected ? AppColors.mistyWhite : AppColors.deepLavender,
      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
    );
  }

  static final BoxDecoration _selectedDecoration = BoxDecoration(
    gradient: AppColors.createGradient(AppColors.primaryGradient),
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: AppColors.withOpacity(AppColors.deepLavender, 0.2),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static final BoxDecoration _unselectedDecoration = BoxDecoration(
    color: AppColors.withOpacity(AppColors.mistyWhite, 0.7),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: AppColors.withOpacity(AppColors.paleGray, 0.3),
    ),
  );
}