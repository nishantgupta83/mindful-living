import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';

/// Emoji-based rating widget inspired by GitaWisdom2 journal rating
/// Uses 5 emojis instead of traditional star rating
class EmojiRating extends StatefulWidget {
  final int? initialRating;
  final ValueChanged<int>? onRatingChanged;
  final bool showLabel;
  final double emojiSize;
  final bool hapticFeedback;
  final bool enabled;

  const EmojiRating({
    super.key,
    this.initialRating,
    this.onRatingChanged,
    this.showLabel = true,
    this.emojiSize = 40,
    this.hapticFeedback = true,
    this.enabled = true,
  });

  @override
  State<EmojiRating> createState() => _EmojiRatingState();
}

class _EmojiRatingState extends State<EmojiRating> {
  int? _selectedRating;

  @override
  void initState() {
    super.initState();
    _selectedRating = widget.initialRating;
  }

  @override
  void didUpdateWidget(EmojiRating oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialRating != oldWidget.initialRating) {
      setState(() {
        _selectedRating = widget.initialRating;
      });
    }
  }

  void _handleRatingTap(int rating) {
    if (!widget.enabled) return;

    if (widget.hapticFeedback) {
      HapticFeedback.mediumImpact();
    }

    setState(() {
      _selectedRating = rating;
    });

    widget.onRatingChanged?.call(rating);
  }

  String _getRatingLabel(int rating) {
    switch (rating) {
      case 1:
        return 'Challenging Day';
      case 2:
        return 'Okay Day';
      case 3:
        return 'Good Day';
      case 4:
        return 'Great Day';
      case 5:
        return 'Amazing Day';
      default:
        return 'Rate your day';
    }
  }

  String _getEmojiForRating(int rating) {
    switch (rating) {
      case 1:
        return '😞';
      case 2:
        return '😐';
      case 3:
        return '🙂';
      case 4:
        return '😃';
      case 5:
        return '🤩';
      default:
        return '😐';
    }
  }

  Color _getHighlightColor(int rating) {
    // Use existing pastel colors based on rating
    switch (rating) {
      case 1:
        return AppColors.peach; // Challenging - warm orange
      case 2:
        return AppColors.lavender.withValues(alpha: 0.3); // Okay - light lavender
      case 3:
        return AppColors.skyBlue; // Good - calm blue
      case 4:
        return AppColors.mintGreen; // Great - fresh green
      case 5:
        return AppColors.softPurple; // Amazing - vibrant purple
      default:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Emoji selector row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(5, (index) {
            final rating = index + 1;
            final isSelected = _selectedRating == rating;

            return Semantics(
              key: ValueKey('emoji_$rating'),  // Performance: Unique key for efficient rebuilds
              label: _getRatingLabel(rating),
              button: true,
              enabled: widget.enabled,
              selected: isSelected,  // Accessibility: Announce selection state
              hint: 'Double tap to rate',
              child: GestureDetector(
                onTap: () => _handleRatingTap(rating),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _getHighlightColor(rating)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: AnimatedScale(
                    scale: isSelected ? 1.2 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    child: Text(
                      _getEmojiForRating(rating),
                      style: TextStyle(
                        fontSize: widget.emojiSize,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),

        // Label text
        if (widget.showLabel) ...[
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.3),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: Text(
              _getRatingLabel(_selectedRating ?? 0),
              key: ValueKey<int?>(_selectedRating),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _selectedRating != null
                    ? AppColors.deepLavender
                    : AppColors.softGray,
                letterSpacing: 0.3,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ],
    );
  }
}

/// Compact emoji rating for list items (no label)
class CompactEmojiRating extends StatelessWidget {
  final int rating;
  final double size;

  const CompactEmojiRating({
    super.key,
    required this.rating,
    this.size = 24,
  });

  String _getEmojiForRating(int rating) {
    switch (rating) {
      case 1:
        return '😞';
      case 2:
        return '😐';
      case 3:
        return '🙂';
      case 4:
        return '😃';
      case 5:
        return '🤩';
      default:
        return '😐';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Rating: ${_getRatingLabel(rating)}',
      readOnly: true,
      child: ExcludeSemantics(
        child: Text(
          _getEmojiForRating(rating),
          style: TextStyle(fontSize: size),
        ),
      ),
    );
  }

  String _getRatingLabel(int rating) {
    switch (rating) {
      case 1:
        return 'Challenging Day';
      case 2:
        return 'Okay Day';
      case 3:
        return 'Good Day';
      case 4:
        return 'Great Day';
      case 5:
        return 'Amazing Day';
      default:
        return 'Not rated';
    }
  }
}
