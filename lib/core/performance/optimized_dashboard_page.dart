/// High-performance optimized dashboard page for MindfulLiving
///
/// This optimized version addresses performance issues in the main dashboard:
/// - Eliminates gradient rendering bottlenecks
/// - Optimizes animation performance
/// - Reduces widget rebuilds with cached components
/// - Implements efficient state management
/// - Minimizes main thread blocking during rendering

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_typography.dart';
import '../../../shared/widgets/pastel_card.dart';
import '../../../shared/widgets/pastel_button.dart';
import 'widgets/optimized_widgets.dart';
import 'performance_optimization_agent.dart';

class OptimizedDashboardPage extends StatefulWidget {
  const OptimizedDashboardPage({super.key});

  @override
  State<OptimizedDashboardPage> createState() => _OptimizedDashboardPageState();
}

class _OptimizedDashboardPageState extends State<OptimizedDashboardPage>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {

  final PerformanceOptimizationAgent _performanceAgent = PerformanceOptimizationAgent();

  // Cached data to prevent rebuilds
  late String _greeting;
  late String _greetingMessage;
  late int _wellnessScore;

  // Animation controllers - properly managed
  late AnimationController _pulseController;
  late AnimationController _wellnessController;
  late Animation<double> _wellnessAnimation;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeOptimizedDashboard();
  }

  /// Initialize dashboard with performance optimizations
  void _initializeOptimizedDashboard() {
    // Cache computed values
    _computeCachedValues();

    // Initialize animations efficiently
    _initializeAnimations();

    // Initialize performance monitoring
    _performanceAgent.initialize();

    // Log dashboard initialization
    _performanceAgent.logEvent('dashboard_initialized', {
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Compute values once and cache them
  void _computeCachedValues() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      _greeting = 'Good Morning';
      _greetingMessage = 'Start your day with mindful intention';
    } else if (hour < 17) {
      _greeting = 'Good Afternoon';
      _greetingMessage = 'Take a moment to breathe and reflect';
    } else {
      _greeting = 'Good Evening';
      _greetingMessage = 'Unwind and find your inner peace';
    }

    _wellnessScore = 87; // This would come from user data
  }

  /// Initialize animations with optimized settings
  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _wellnessController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _wellnessAnimation = Tween<double>(
      begin: 0.0,
      end: _wellnessScore / 100.0,
    ).animate(CurvedAnimation(
      parent: _wellnessController,
      curve: Curves.easeInOutCubic,
    ));

    // Start animations
    _pulseController.repeat(reverse: true);
    _wellnessController.forward();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return Scaffold(
      body: _buildOptimizedBody(),
    );
  }

  /// Build optimized body with RepaintBoundary
  Widget _buildOptimizedBody() {
    return RepaintBoundary(
      child: Container(
        decoration: _getCachedBackgroundDecoration(),
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(24.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildOptimizedHeader(),
                    const SizedBox(height: 32),
                    _buildOptimizedWellnessCard(),
                    const SizedBox(height: 32),
                    _buildQuickStartSection(),
                    const SizedBox(height: 32),
                    _buildDailyReflectionSection(),
                    const SizedBox(height: 100), // Space for navigation
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Cached background decoration to avoid rebuilding gradients
  static final BoxDecoration _cachedBackgroundDecoration = BoxDecoration(
    gradient: AppColors.createGradient(AppColors.dreamGradient),
  );

  BoxDecoration _getCachedBackgroundDecoration() => _cachedBackgroundDecoration;

  /// Build optimized header with cached widgets
  Widget _buildOptimizedHeader() {
    return RepaintBoundary(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _CachedGreetingSection(
            greeting: _greeting,
            message: _greetingMessage,
          ),
          _CachedNotificationButton(),
        ],
      ),
    );
  }

  /// Build optimized wellness card with efficient animations
  Widget _buildOptimizedWellnessCard() {
    return RepaintBoundary(
      child: OptimizedPastelCard(
        gradientColors: AppColors.oceanGradient,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWellnessHeader(),
            const SizedBox(height: 20),
            _buildWellnessProgressBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildWellnessHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today\'s Wellness',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.deepLavender,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'You\'re doing great!',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.softCharcoal,
              ),
            ),
          ],
        ),
        _CachedWellnessScore(score: _wellnessScore),
      ],
    );
  }

  Widget _buildWellnessProgressBar() {
    return RepaintBoundary(
      child: Container(
        height: 8,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: AppColors.withOpacity(AppColors.mistyWhite, 0.3),
        ),
        child: AnimatedBuilder(
          animation: _wellnessAnimation,
          builder: (context, child) {
            return FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: _wellnessAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  gradient: AppColors.createGradient(AppColors.primaryGradient),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Build quick start section with optimized action cards
  Widget _buildQuickStartSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Start',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.deepLavender,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 20),
        _buildActionCardsGrid(),
      ],
    );
  }

  Widget _buildActionCardsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OptimizedActionCard(
                icon: Icons.lightbulb_outline,
                title: 'Life Dilemma',
                subtitle: 'Get wise guidance',
                gradientColors: AppColors.oceanGradient,
                onTap: () => _handleQuickAction('dilemma'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OptimizedActionCard(
                icon: Icons.edit_note,
                title: 'Journal Entry',
                subtitle: 'Reflect & grow',
                gradientColors: AppColors.sunsetGradient,
                onTap: () => _handleQuickAction('journal'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OptimizedActionCard(
                icon: Icons.bubble_chart,
                title: 'Breathing',
                subtitle: '5-min practice',
                gradientColors: AppColors.primaryGradient,
                onTap: () => _handleQuickAction('breathing'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OptimizedActionCard(
                icon: Icons.sentiment_satisfied_alt,
                title: 'Mood Check',
                subtitle: 'How are you?',
                gradientColors: [AppColors.peach, AppColors.softPurple],
                onTap: () => _showOptimizedMoodDialog(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build daily reflection section
  Widget _buildDailyReflectionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daily Reflection',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.deepLavender,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 20),
        _buildReflectionCard(),
      ],
    );
  }

  Widget _buildReflectionCard() {
    return RepaintBoundary(
      child: OptimizedPastelCard(
        gradientColors: AppColors.dreamGradient,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CachedReflectionPrompt(),
            const SizedBox(height: 20),
            PastelButton.gradient(
              text: 'Start Reflection',
              onPressed: () => _handleQuickAction('reflection'),
              gradientColors: AppColors.primaryGradient,
              size: PastelButtonSize.large,
              icon: Icons.edit_outlined,
            ),
          ],
        ),
      ),
    );
  }

  /// Handle quick action taps
  void _handleQuickAction(String action) {
    _performanceAgent.logEvent('quick_action_tapped', {
      'action': action,
      'timestamp': DateTime.now().toIso8601String(),
    });

    // Provide haptic feedback
    HapticFeedback.lightImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigate to $action!'),
        backgroundColor: AppColors.deepLavender,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Show optimized mood dialog
  void _showOptimizedMoodDialog() {
    _performanceAgent.logEvent('mood_dialog_opened', {
      'timestamp': DateTime.now().toIso8601String(),
    });

    showDialog(
      context: context,
      builder: (context) => _OptimizedMoodDialog(),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _wellnessController.dispose();
    super.dispose();
  }
}

/// Cached greeting section to prevent rebuilds
class _CachedGreetingSection extends StatelessWidget {
  final String greeting;
  final String message;

  const _CachedGreetingSection({
    required this.greeting,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: AppTypography.headlineMedium.copyWith(
            color: AppColors.deepLavender,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          message,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.softCharcoal,
          ),
        ),
      ],
    );
  }
}

/// Cached notification button
class _CachedNotificationButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cachedDecoration,
      child: IconButton(
        icon: const Icon(
          Icons.notifications_outlined,
          color: AppColors.deepLavender,
        ),
        onPressed: () {
          HapticFeedback.lightImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Notifications coming soon!')),
          );
        },
      ),
    );
  }

  static final BoxDecoration _cachedDecoration = BoxDecoration(
    color: AppColors.withOpacity(AppColors.mistyWhite, 0.7),
    borderRadius: BorderRadius.circular(20),
    boxShadow: const [
      BoxShadow(
        color: AppColors.shadowLight,
        blurRadius: 10,
        offset: Offset(0, 4),
      ),
    ],
  );
}

/// Cached wellness score badge
class _CachedWellnessScore extends StatelessWidget {
  final int score;

  const _CachedWellnessScore({required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: _cachedDecoration,
      child: Text(
        '$score%',
        style: AppTypography.labelLarge.copyWith(
          color: AppColors.deepLavender,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  static final BoxDecoration _cachedDecoration = BoxDecoration(
    gradient: AppColors.createGradient(AppColors.sunsetGradient),
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: AppColors.withOpacity(AppColors.peach, 0.3),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  );
}

/// Cached reflection prompt
class _CachedReflectionPrompt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cachedDecoration,
      child: Row(
        children: [
          const Icon(
            Icons.lightbulb_outline,
            color: AppColors.deepLavender,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '"What small step can I take today to improve my well-being?"',
              style: AppTypography.bodyLarge.copyWith(
                fontStyle: FontStyle.italic,
                color: AppColors.deepLavender,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static final BoxDecoration _cachedDecoration = BoxDecoration(
    color: AppColors.withOpacity(AppColors.mistyWhite, 0.7),
    borderRadius: BorderRadius.circular(16),
  );
}

/// Optimized mood dialog with performance improvements
class _OptimizedMoodDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: AppColors.createGradient(AppColors.dreamGradient),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'How are you feeling?',
                style: AppTypography.headlineSmall.copyWith(
                  color: AppColors.deepLavender,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _OptimizedMoodIcon('😊', 'Great', AppColors.mintGreen),
                  _OptimizedMoodIcon('😌', 'Good', AppColors.skyBlue),
                  _OptimizedMoodIcon('😐', 'Okay', AppColors.lemon),
                  _OptimizedMoodIcon('😔', 'Low', AppColors.peach),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Optimized mood icon with cached styles
class _OptimizedMoodIcon extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;

  const _OptimizedMoodIcon(this.emoji, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Mood recorded: $label'),
              backgroundColor: AppColors.deepLavender,
            ),
          );

          // Log mood selection
          final performanceAgent = PerformanceOptimizationAgent();
          performanceAgent.logEvent('mood_selected', {
            'mood': label,
            'timestamp': DateTime.now().toIso8601String(),
          });
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.withOpacity(color, 0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.withOpacity(color, 0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(height: 8),
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.deepLavender,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}