import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../utils/life_area_utils.dart';

/// Category filter chip for explore/scenarios screen
/// Inspired by GitaWisdom2's category filters with counts and icons
class CategoryFilterChip extends StatelessWidget {
  final String label;
  final int count;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final List<Color>? gradientColors;
  final bool hapticFeedback;

  const CategoryFilterChip({
    super.key,
    required this.label,
    required this.count,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.gradientColors,
    this.hapticFeedback = true,
  });

  void _handleTap() {
    if (hapticFeedback) {
      HapticFeedback.lightImpact();
    }
    onTap();
  }

  @override
  Widget build(BuildContext context) {
    final colors = gradientColors ?? AppColors.primaryGradient;

    return Semantics(
      button: true,
      selected: isSelected,
      label: '$label category, $count items',
      child: GestureDetector(
        onTap: _handleTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: colors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isSelected ? null : AppColors.mistyWhite,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? colors.first
                  : AppColors.softGray.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: colors.first.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? AppColors.deepLavender : AppColors.softCharcoal,  // Fixed: High contrast
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? AppColors.deepLavender : AppColors.softCharcoal,  // Fixed: High contrast
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.deepLavender.withValues(alpha: 0.15)
                      : AppColors.lightGray.withValues(alpha: 0.2),  // Fixed: Better contrast
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? AppColors.deepLavender : AppColors.softCharcoal,  // Fixed: High contrast
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Horizontal scrollable list of category filter chips
class CategoryFilterChipList extends StatefulWidget {
  final List<CategoryFilterOption> categories;
  final String? selectedCategory;
  final ValueChanged<String?> onCategorySelected;
  final bool showAllOption;
  final EdgeInsets padding;

  const CategoryFilterChipList({
    super.key,
    required this.categories,
    this.selectedCategory,
    required this.onCategorySelected,
    this.showAllOption = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  });

  @override
  State<CategoryFilterChipList> createState() => _CategoryFilterChipListState();
}

class _CategoryFilterChipListState extends State<CategoryFilterChipList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<Color> _getGradientForCategory(String category) {
    // Use LifeAreaUtils for consistent gradient mapping
    return LifeAreaUtils.getGradientForArea(category);
  }

  @override
  Widget build(BuildContext context) {
    final allCategories = widget.showAllOption
        ? [
            CategoryFilterOption(
              label: 'All',
              icon: Icons.grid_view_rounded,
              count: widget.categories.fold(0, (sum, cat) => sum + cat.count),
            ),
            ...widget.categories,
          ]
        : widget.categories;

    return Semantics(
      container: true,
      label: 'Category filters',
      hint: 'Swipe to see more categories',
      child: SizedBox(
      height: 50,
      child: ListView.separated(
        controller: _scrollController,
        padding: widget.padding,
        scrollDirection: Axis.horizontal,
        itemCount: allCategories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = allCategories[index];
          final isAll = widget.showAllOption && index == 0;
          final categoryValue = isAll ? null : category.label;
          final isSelected = widget.selectedCategory == categoryValue;

          return CategoryFilterChip(
            key: ValueKey('category_${category.label}'),  // Performance: Unique key
            label: category.label,
            count: category.count,
            icon: category.icon,
            isSelected: isSelected,
            gradientColors: _getGradientForCategory(category.label),
            onTap: () => widget.onCategorySelected(categoryValue),
          );
        },
      ),
    ),
    );
  }
}

/// Data model for category filter option
class CategoryFilterOption {
  final String label;
  final IconData icon;
  final int count;

  const CategoryFilterOption({
    required this.label,
    required this.icon,
    required this.count,
  });
}

/// Predefined category options for life situations
class LifeAreaCategories {
  static const List<CategoryFilterOption> defaultCategories = [
    CategoryFilterOption(
      label: 'Wellness',
      icon: Icons.spa_outlined,
      count: 0,
    ),
    CategoryFilterOption(
      label: 'Relationships',
      icon: Icons.favorite_border,
      count: 0,
    ),
    CategoryFilterOption(
      label: 'Career',
      icon: Icons.work_outline,
      count: 0,
    ),
    CategoryFilterOption(
      label: 'Growth',
      icon: Icons.trending_up,
      count: 0,
    ),
    CategoryFilterOption(
      label: 'Family',
      icon: Icons.people_outline,
      count: 0,
    ),
    CategoryFilterOption(
      label: 'Health',
      icon: Icons.health_and_safety_outlined,
      count: 0,
    ),
    CategoryFilterOption(
      label: 'Mindfulness',
      icon: Icons.self_improvement,
      count: 0,
    ),
    CategoryFilterOption(
      label: 'Stress',
      icon: Icons.psychology_outlined,
      count: 0,
    ),
    CategoryFilterOption(
      label: 'Finance',
      icon: Icons.account_balance_wallet_outlined,
      count: 0,
    ),
    CategoryFilterOption(
      label: 'Communication',
      icon: Icons.chat_bubble_outline,
      count: 0,
    ),
    CategoryFilterOption(
      label: 'Life Balance',
      icon: Icons.balance,
      count: 0,
    ),
  ];
}
