import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/dilemma/presentation/pages/dilemma_page.dart';
import '../../features/dilemma/presentation/pages/dilemma_page_v2.dart';
import '../../features/dilemma/presentation/pages/dilemma_page_v3.dart';
import '../../features/journal/presentation/pages/journal_page.dart';
import '../../features/practices/presentation/pages/practices_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';

class MainNavigation extends StatefulWidget {
  final int initialIndex;
  
  const MainNavigation({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation>
    with TickerProviderStateMixin {
  late int _currentIndex;
  late PageController _pageController;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
      page: const DashboardPage(),
    ),
    NavigationItem(
      icon: Icons.psychology_outlined,
      activeIcon: Icons.psychology,
      label: 'Dilemma',
      // page: const DilemmaPage(), // V1 - Original design
      // page: const DilemmaPageV2(), // V2 - New design with tiles & chat
      page: const DilemmaPageV3(), // V3 - Optimized performance with pagination & caching
    ),
    NavigationItem(
      icon: Icons.book_outlined,
      activeIcon: Icons.book,
      label: 'Journal',
      page: const JournalPage(),
    ),
    NavigationItem(
      icon: Icons.self_improvement_outlined,
      activeIcon: Icons.self_improvement,
      label: 'Practices',
      page: const PracticesPage(),
    ),
    NavigationItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Profile',
      page: const ProfilePage(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeOut,
    ));
    
    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: PageView(
        controller: _pageController,
        children: _navigationItems.map((item) => item.page).toList(),
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      bottomNavigationBar: _buildModernBottomNavigation(),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildModernBottomNavigation() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.withOpacity(AppColors.mistyWhite, 0.85),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: AppColors.withOpacity(AppColors.paleGray, 0.5),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.withOpacity(AppColors.shadowLight, 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: AppColors.withOpacity(AppColors.shadowMedium, 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ..._navigationItems.asMap().entries.where((entry) => entry.key != 2).map(
                  (entry) => _buildNavigationItem(entry.key, entry.value),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationItem(int index, NavigationItem item) {
    final isActive = index == _currentIndex;
    
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isActive 
              ? AppColors.withOpacity(AppColors.deepLavender, 0.1)
              : Colors.transparent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isActive ? item.activeIcon : item.icon,
                key: ValueKey(isActive),
                size: 24,
                color: isActive ? AppColors.deepLavender : AppColors.lightGray,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: AppTypography.labelSmall.copyWith(
                color: isActive ? AppColors.deepLavender : AppColors.lightGray,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    final isJournalActive = _currentIndex == 2;
    
    return ScaleTransition(
      scale: _fabAnimation,
      child: GestureDetector(
        onTap: () => _onItemTapped(2),
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: AppColors.createGradient(
              isJournalActive ? AppColors.primaryGradient : AppColors.oceanGradient,
            ),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: AppColors.withOpacity(
                  isJournalActive ? AppColors.deepLavender : AppColors.skyBlue,
                  0.3,
                ),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              isJournalActive 
                  ? _navigationItems[2].activeIcon 
                  : _navigationItems[2].icon,
              key: ValueKey(isJournalActive),
              size: 28,
              color: AppColors.mistyWhite,
            ),
          ),
        ),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Widget page;

  NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.page,
  });
}