import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/situation_card.dart';
import '../../../../shared/widgets/radial_gradient_background.dart';
import '../../../wellness/presentation/pages/breathing_exercise_page.dart';

/// Home screen with GitaWisdom2-inspired patterns
/// Features: Dynamic greeting, wellness dashboard, quick actions, recommendations
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  int _currentStreak = 3;
  int _situationsExplored = 12;
  int _journalEntries = 5;
  bool _isRefreshing = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    if (hour < 21) return 'Good Evening';
    return 'Good Night';
  }

  String _getGreetingMessage() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Start your day with mindfulness';
    if (hour < 17) return 'Take a moment to reflect';
    if (hour < 21) return 'Wind down with intention';
    return 'Prepare for restful sleep';
  }

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);

    // Simulate data refresh
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() => _isRefreshing = false);
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: AppColors.deepLavender,
        backgroundColor: AppColors.cream,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            // Gradient App Bar
            _buildGradientAppBar(),

            // Wellness Summary Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _buildWellnessSummaryCard(),
              ),
            ),

            // Quick Actions
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.deepLavender,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildQuickActions(),
                ],
              ),
            ),

            // For You Today
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'For You Today',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.deepLavender,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Navigate to explore
                      },
                      child: const Text('See All'),
                    ),
                  ],
                ),
              ),
            ),

            // Recommended Situations
            _buildRecommendedSituations(),

            const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientAppBar() {
    return SliverAppBar(
      expandedHeight: 180,
      floating: true,
      pinned: true,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          _getGreeting(),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black26,
                offset: Offset(0, 1),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: AppColors.dreamGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    _getGreetingMessage(),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.9),
                      shadows: const [
                        Shadow(
                          color: Colors.black12,
                          offset: Offset(0, 1),
                          blurRadius: 2,
                        ),
                      ],
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

  Widget _buildWellnessSummaryCard() {
    return Hero(
      tag: 'wellness_summary',
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: RadialGradientPresets.wellness(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Your Wellness Journey',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.deepLavender,
                      ),
                    ),
                    // Streak badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: AppColors.mintGradient,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.mintGreen.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            '🔥',
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$_currentStreak-day streak',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildWellnessMetric(
                        'Situations',
                        _situationsExplored.toString(),
                        Icons.book_outlined,
                        AppColors.skyBlue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildWellnessMetric(
                        'Journal',
                        _journalEntries.toString(),
                        Icons.edit_note,
                        AppColors.peach,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWellnessMetric(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.deepLavender,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.softCharcoal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return SizedBox(
      height: 140,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        children: [
          _buildQuickActionCard(
            'Breathing',
            Icons.air,
            AppColors.skyGradient,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BreathingExercisePage(),
                ),
              );
            },
          ),
          _buildQuickActionCard(
            'Meditation',
            Icons.self_improvement,
            AppColors.dreamGradient,
            () {
              // Navigate to meditation
            },
          ),
          _buildQuickActionCard(
            'Journal',
            Icons.edit_note,
            AppColors.peachGradient,
            () {
              // Navigate to journal
            },
          ),
          _buildQuickActionCard(
            'Explore',
            Icons.explore_outlined,
            AppColors.mintGradient,
            () {
              // Navigate to explore
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    String title,
    IconData icon,
    List<Color> gradient,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: SizedBox(
        width: 120,
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              onTap();
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendedSituations() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('life_situations')
          .where('isActive', isEqualTo: true)
          .limit(10)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Error loading situations',
                  style: TextStyle(color: AppColors.softCharcoal),
                ),
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(AppColors.deepLavender),
                ),
              ),
            ),
          );
        }

        final situations = snapshot.data!.docs;

        if (situations.isEmpty) {
          return SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No situations available',
                  style: TextStyle(color: AppColors.softCharcoal),
                ),
              ),
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final data = situations[index].data() as Map<String, dynamic>;

              return Hero(
                tag: 'situation_${situations[index].id}',
                child: SituationCard(
                  title: data['title'] ?? 'Untitled',
                  description: data['description'] ?? '',
                  lifeArea: data['lifeArea'],
                  difficulty: data['difficulty'],
                  readTime: data['estimatedReadTime'],
                  tags: (data['tags'] as List?)?.cast<String>(),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    // Navigate to detail
                  },
                ),
              );
            },
            childCount: situations.length,
          ),
        );
      },
    );
  }
}
