import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import '../base/base_component.dart';
import '../adaptive/adaptive_components.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/managers/localization_manager.dart';

/// Main navigation component that adapts to platform-specific patterns
/// iOS: CupertinoTabBar with bottom tabs
/// Android: Material 3 NavigationBar with elevated design
class AdaptiveMainNavigation extends BaseComponent {
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavigationDestination> destinations;

  const AdaptiveMainNavigation({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.destinations,
  });

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return _buildIosNavigation(context);
    } else {
      return _buildAndroidNavigation(context);
    }
  }

  Widget _buildIosNavigation(BuildContext context) {
    return CupertinoTabBar(
      currentIndex: currentIndex,
      onTap: (index) {
        AdaptiveComponents.provideFeedback(type: HapticFeedbackType.selection);
        onDestinationSelected(index);
      },
      backgroundColor: AppColors.backgroundPrimary.withValues(alpha: 0.9),
      activeColor: AppColors.primaryBlue,
      inactiveColor: AppColors.textLight,
      iconSize: 24.0,
      border: const Border(
        top: BorderSide(
          color: AppColors.shadowLight,
          width: 0.5,
        ),
      ),
      items: destinations.map((destination) => BottomNavigationBarItem(
        icon: Padding(
          padding: const EdgeInsets.only(bottom: 2.0),
          child: Icon(destination.icon),
        ),
        activeIcon: Padding(
          padding: const EdgeInsets.only(bottom: 2.0),
          child: Icon(destination.selectedIcon ?? destination.icon),
        ),
        label: destination.label,
      )).toList(),
    );
  }

  Widget _buildAndroidNavigation(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) {
        AdaptiveComponents.provideFeedback(type: HapticFeedbackType.selection);
        onDestinationSelected(index);
      },
      backgroundColor: AppColors.backgroundPrimary,
      surfaceTintColor: AppColors.primaryBlue,
      indicatorColor: AppColors.primaryBlue.withValues(alpha: 0.1),
      height: 80,
      destinations: destinations.map((destination) => NavigationDestination(
        icon: destination.icon,
        selectedIcon: destination.selectedIcon ?? destination.icon,
        label: destination.label,
      )).toList(),
    );
  }
}

/// Navigation destination model for main navigation
class NavigationDestination {
  final IconData icon;
  final IconData? selectedIcon;
  final String label;
  final String? tooltip;

  const NavigationDestination({
    required this.icon,
    this.selectedIcon,
    required this.label,
    this.tooltip,
  });
}

/// Navigation configuration provider
class NavigationConfig {
  static List<NavigationDestination> getMainDestinations(BuildContext context) {
    final l10n = context.l10n;
    
    return [
      NavigationDestination(
        icon: Icons.dashboard_outlined,
        selectedIcon: Icons.dashboard,
        label: l10n.dashboardTitle,
        tooltip: l10n.dashboardTitle,
      ),
      NavigationDestination(
        icon: Icons.psychology_outlined,
        selectedIcon: Icons.psychology,
        label: l10n.lifeSituations,
        tooltip: l10n.lifeSituations,
      ),
      NavigationDestination(
        icon: Icons.book_outlined,
        selectedIcon: Icons.book,
        label: l10n.journalEntry,
        tooltip: l10n.journalEntry,
      ),
      NavigationDestination(
        icon: Icons.self_improvement_outlined,
        selectedIcon: Icons.self_improvement,
        label: l10n.wellnessPractices,
        tooltip: l10n.wellnessPractices,
      ),
      NavigationDestination(
        icon: Icons.person_outline,
        selectedIcon: Icons.person,
        label: l10n.profile,
        tooltip: l10n.profile,
      ),
    ];
  }
}

/// Main navigation scaffold that handles navigation state
class AdaptiveNavigationScaffold extends StatefulWidget {
  final List<Widget> pages;
  final int initialIndex;
  final List<NavigationDestination>? customDestinations;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final PreferredSizeWidget? appBar;

  const AdaptiveNavigationScaffold({
    super.key,
    required this.pages,
    this.initialIndex = 0,
    this.customDestinations,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.appBar,
  });

  @override
  State<AdaptiveNavigationScaffold> createState() => _AdaptiveNavigationScaffoldState();
}

class _AdaptiveNavigationScaffoldState extends State<AdaptiveNavigationScaffold> {
  late int _currentIndex;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onDestinationSelected(int index) {
    if (index == _currentIndex) return;
    
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
    final destinations = widget.customDestinations ?? 
                       NavigationConfig.getMainDestinations(context);

    return Scaffold(
      appBar: widget.appBar,
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Disable swipe navigation
        children: widget.pages,
      ),
      bottomNavigationBar: AdaptiveMainNavigation(
        currentIndex: _currentIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: destinations,
      ),
      floatingActionButton: widget.floatingActionButton,
      floatingActionButtonLocation: widget.floatingActionButtonLocation,
    );
  }
}

/// Voice assistant floating action button with platform-specific design
class VoiceAssistantFAB extends BaseComponent {
  final VoidCallback onPressed;
  final bool isListening;
  final bool isPulsing;

  const VoiceAssistantFAB({
    super.key,
    required this.onPressed,
    this.isListening = false,
    this.isPulsing = false,
  });

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return _buildIosFAB(context);
    } else {
      return _buildAndroidFAB(context);
    }
  }

  Widget _buildIosFAB(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AdaptiveComponents.provideFeedback(type: HapticFeedbackType.medium);
        onPressed();
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: isListening ? AppColors.error : AppColors.primaryBlue,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (isListening ? AppColors.error : AppColors.primaryBlue).withValues(alpha: 0.3),
              blurRadius: isPulsing ? 20 : 8,
              spreadRadius: isPulsing ? 4 : 0,
            ),
          ],
        ),
        child: Icon(
          isListening ? Icons.mic : Icons.mic_none,
          color: AppColors.white,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildAndroidFAB(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        AdaptiveComponents.provideFeedback(type: HapticFeedbackType.medium);
        onPressed();
      },
      backgroundColor: isListening ? AppColors.error : AppColors.primaryBlue,
      foregroundColor: AppColors.white,
      elevation: isPulsing ? 12 : 6,
      child: Icon(
        isListening ? Icons.mic : Icons.mic_none,
        size: 28,
      ),
    );
  }
}

/// Adaptive app bar with platform-specific styling
class AdaptiveAppBar extends BaseComponent implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final Color? backgroundColor;
  final bool showBackButton;

  const AdaptiveAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.backgroundColor,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return _buildIosAppBar(context);
    } else {
      return _buildAndroidAppBar(context);
    }
  }

  Widget _buildIosAppBar(BuildContext context) {
    return CupertinoNavigationBar(
      middle: Text(
        title,
        style: getTextTheme(context).titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      backgroundColor: backgroundColor ?? AppColors.backgroundPrimary.withValues(alpha: 0.9),
      border: const Border(
        bottom: BorderSide(
          color: AppColors.shadowLight,
          width: 0.5,
        ),
      ),
      leading: showBackButton ? const CupertinoNavigationBarBackButton() : leading,
      trailing: actions != null ? Row(
        mainAxisSize: MainAxisSize.min,
        children: actions!,
      ) : null,
    );
  }

  Widget _buildAndroidAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: getTextTheme(context).titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? AppColors.backgroundPrimary,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 2,
      leading: leading,
      actions: actions,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  Size get preferredSize => Platform.isIOS 
      ? const Size.fromHeight(44.0)
      : const Size.fromHeight(56.0);
}

/// Secondary navigation for sub-sections (horizontal scrolling tabs)
class AdaptiveSecondaryNavigation extends BaseComponent {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final List<String> tabs;
  final ScrollController? scrollController;

  const AdaptiveSecondaryNavigation({
    super.key,
    required this.selectedIndex,
    required this.onTap,
    required this.tabs,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: scrollController,
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = index == selectedIndex;
          
          return GestureDetector(
            onTap: () {
              AdaptiveComponents.provideFeedback(type: HapticFeedbackType.selection);
              onTap(index);
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8.0),
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              decoration: BoxDecoration(
                color: isSelected 
                    ? AppColors.primaryBlue 
                    : AppColors.softGray,
                borderRadius: BorderRadius.circular(20),
                border: isSelected ? null : Border.all(
                  color: AppColors.shadowLight,
                  width: 1,
                ),
              ),
              child: Text(
                tabs[index],
                style: getTextTheme(context).bodyMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected 
                      ? AppColors.white 
                      : AppColors.textSecondary,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}