import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/gradient_cache.dart';

/// Optimized category tile with cached gradients and reduced rebuilds
class OptimizedCategoryTile extends StatefulWidget {
  final String category;
  final String emoji;
  final bool isSelected;
  final VoidCallback onTap;

  const OptimizedCategoryTile({
    super.key,
    required this.category,
    required this.emoji,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<OptimizedCategoryTile> createState() => _OptimizedCategoryTileState();
}

class _OptimizedCategoryTileState extends State<OptimizedCategoryTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  final GradientCache _gradientCache = GradientCache();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
    HapticFeedback.lightImpact();
    widget.onTap();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    // Use RepaintBoundary to prevent unnecessary repaints
    return RepaintBoundary(
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            );
          },
          child: _buildTileContent(),
        ),
      ),
    );
  }

  Widget _buildTileContent() {
    // Get cached decoration - no recalculation
    final decoration = _gradientCache.getDecoration(
      widget.category,
      widget.isSelected,
    );

    return Container(
      decoration: decoration,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildEmojiContainer(),
          const SizedBox(height: 8),
          _buildCategoryText(),
        ],
      ),
    );
  }

  Widget _buildEmojiContainer() {
    // Use const where possible
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: widget.isSelected
            ? Colors.white.withValues(alpha: 0.2)
            : _gradientCache.getCategoryColors(widget.category)[0].withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        widget.emoji,
        style: const TextStyle(fontSize: 28),
      ),
    );
  }

  Widget _buildCategoryText() {
    final colors = _gradientCache.getCategoryColors(widget.category);

    return Text(
      widget.category,
      style: AppTypography.labelSmall.copyWith(
        color: widget.isSelected ? Colors.white : colors[0],
        fontWeight: FontWeight.w600,
      ),
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}