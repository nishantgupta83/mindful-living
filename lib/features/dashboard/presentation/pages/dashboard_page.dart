import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/pastel_card.dart';
import '../../../../shared/widgets/pastel_button.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _getGreetingMessage() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Start your day with mindful intention';
    if (hour < 17) return 'Take a moment to breathe and reflect';
    return 'Unwind and find your inner peace';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.createGradient(AppColors.dreamGradient),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getGreeting(),
                          style: AppTypography.headlineMedium.copyWith(
                            color: AppColors.deepLavender,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getGreetingMessage(),
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.softCharcoal,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.withOpacity(AppColors.mistyWhite, 0.7),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadowLight,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.notifications_outlined,
                          color: AppColors.deepLavender,
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Notifications coming soon!'),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Wellness Score Card
                PastelCard.gradient(
                  gradientColors: AppColors.oceanGradient,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
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
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: AppColors.createGradient(AppColors.sunsetGradient),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.withOpacity(AppColors.peach, 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Text(
                              '87%',
                              style: AppTypography.labelLarge.copyWith(
                                color: AppColors.deepLavender,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: AppColors.withOpacity(AppColors.mistyWhite, 0.3),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: 0.87,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              gradient: AppColors.createGradient(AppColors.primaryGradient),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Quick Actions
                Text(
                  'Quick Start',
                  style: AppTypography.headlineSmall.copyWith(
                    color: AppColors.deepLavender,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                
                Row(
                  children: [
                    Expanded(
                      child: _PastelActionCard(
                        icon: Icons.lightbulb_outline,
                        title: 'Life Dilemma',
                        subtitle: 'Get wise guidance',
                        gradientColors: AppColors.oceanGradient,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Navigate to Dilemma tab!'),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _PastelActionCard(
                        icon: Icons.edit_note,
                        title: 'Journal Entry',
                        subtitle: 'Reflect & grow',
                        gradientColors: AppColors.sunsetGradient,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Navigate to Journal tab!'),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: _PastelActionCard(
                        icon: Icons.bubble_chart,
                        title: 'Breathing',
                        subtitle: '5-min practice',
                        gradientColors: AppColors.primaryGradient,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Navigate to Practices tab!'),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _PastelActionCard(
                        icon: Icons.sentiment_satisfied_alt,
                        title: 'Mood Check',
                        subtitle: 'How are you?',
                        gradientColors: [AppColors.peach, AppColors.softPurple],
                        onTap: () => _showMoodDialog(context),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Daily Reflection
                Text(
                  'Daily Reflection',
                  style: AppTypography.headlineSmall.copyWith(
                    color: AppColors.deepLavender,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                
                PastelCard.gradient(
                  gradientColors: AppColors.dreamGradient,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.withOpacity(AppColors.mistyWhite, 0.7),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Icon(
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
                      ),
                      const SizedBox(height: 20),
                      PastelButton.gradient(
                        text: 'Start Reflection',
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Navigate to Journal for reflection!'),
                            ),
                          );
                        },
                        gradientColors: AppColors.primaryGradient,
                        size: PastelButtonSize.large,
                        icon: Icons.edit_outlined,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 100), // Extra space for floating nav
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showMoodDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
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
                  _MoodIcon('😊', 'Great', AppColors.mintGreen),
                  _MoodIcon('😌', 'Good', AppColors.skyBlue),
                  _MoodIcon('😐', 'Okay', AppColors.lemon),
                  _MoodIcon('😔', 'Low', AppColors.peach),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoodIcon extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;

  const _MoodIcon(this.emoji, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Mood recorded: $label'),
            backgroundColor: AppColors.deepLavender,
          ),
        );
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
    );
  }
}

class _PastelActionCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _PastelActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  State<_PastelActionCard> createState() => _PastelActionCardState();
}

class _PastelActionCardState extends State<_PastelActionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 0.02,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PastelCard.interactive(
      onTap: widget.onTap,
      gradientColors: widget.gradientColors,
      style: PastelCardStyle.gradient,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Transform.rotate(
                  angle: _rotateAnimation.value,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.withOpacity(AppColors.mistyWhite, 0.8),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.withOpacity(AppColors.deepLavender, 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      widget.icon,
                      color: AppColors.deepLavender,
                      size: 24,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Text(
            widget.title,
            style: AppTypography.labelLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.deepLavender,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.subtitle,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.softCharcoal,
            ),
          ),
        ],
      ),
    );
  }
}