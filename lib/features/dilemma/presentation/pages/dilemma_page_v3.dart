import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/services/optimized_firebase_service.dart';
import '../../../../core/utils/gradient_cache.dart';
import '../../../../core/utils/performance_monitor.dart';
import '../widgets/optimized_category_tile.dart';
import '../widgets/optimized_dilemma_card.dart';
import '../widgets/chat_assistant_widget.dart';

/// Optimized Dilemma Page with performance improvements
class DilemmaPageV3 extends StatefulWidget {
  const DilemmaPageV3({super.key});

  @override
  State<DilemmaPageV3> createState() => _DilemmaPageV3State();
}

class _DilemmaPageV3State extends State<DilemmaPageV3>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  // Services
  final OptimizedFirebaseService _firebaseService = OptimizedFirebaseService();
  final GradientCache _gradientCache = GradientCache();
  final PerformanceMonitor _performanceMonitor = PerformanceMonitor();

  // State
  List<Map<String, dynamic>> _dilemmas = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String _selectedCategory = '';
  int _currentPage = 0;

  // Controllers
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Constants
  static const Map<String, String> _categoryEmojis = const {
    'relationships': '💝',
    'career': '🚀',
    'finance': '💰',
    'mental health': '🧠',
    'family': '🏠',
    'health': '❤️',
    'all': '✨',
  };

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeScrollListener();
    _loadInitialData();
    _performanceMonitor.startMonitoring();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300), // Reduced from 600ms
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  void _initializeScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _loadMoreDilemmas();
      }
    });
  }

  Future<void> _loadInitialData() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final dilemmas = await _performanceMonitor.trackOperation(
        'LoadInitialDilemmas',
        () => _firebaseService.getDilemmasPaginated(
          page: 0,
          category: _selectedCategory.isEmpty ? null : _selectedCategory,
        ),
      );

      if (mounted) {
        setState(() {
          _dilemmas = dilemmas;
          _currentPage = 0;
          _isLoading = false;
        });
      }

      _firebaseService.logEvent('dilemma_page_v3_loaded', {
        'count': dilemmas.length,
        'category': _selectedCategory,
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading content: $e')),
        );
      }
    }
  }

  Future<void> _loadMoreDilemmas() async {
    if (_isLoadingMore || _isLoading) return;

    setState(() => _isLoadingMore = true);

    try {
      final nextPage = _currentPage + 1;
      final moreDilemmas = await _firebaseService.getDilemmasPaginated(
        page: nextPage,
        category: _selectedCategory.isEmpty ? null : _selectedCategory,
      );

      if (mounted && moreDilemmas.isNotEmpty) {
        setState(() {
          _dilemmas.addAll(moreDilemmas);
          _currentPage = nextPage;
          _isLoadingMore = false;
        });
      } else {
        setState(() => _isLoadingMore = false);
      }
    } catch (e) {
      setState(() => _isLoadingMore = false);
    }
  }

  void _onCategorySelected(String category) {
    if (category == _selectedCategory) {
      setState(() => _selectedCategory = '');
    } else {
      setState(() => _selectedCategory = category);
    }

    _currentPage = 0;
    _loadInitialData();
    _firebaseService.logEvent('category_selected_v3', {'category': category});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final gradientColors = _gradientCache.getCategoryColors(
      _selectedCategory.isEmpty ? 'all' : _selectedCategory,
    );

    return Scaffold(
      body: RepaintBoundary(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                gradientColors[0].withOpacity(0.1),
                gradientColors[1].withOpacity(0.05),
                Colors.white,
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(gradientColors),
                _buildSearchBar(gradientColors),
                _buildCategoryGrid(),
                _buildDilemmasList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(List<Color> gradientColors) {
    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.assistant,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Life Guide AI',
                    style: AppTypography.headlineSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Ask me about any life situation',
                    style: AppTypography.bodySmall.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            _buildChatButton(gradientColors),
          ],
        ),
      ),
    );
  }

  Widget _buildChatButton(List<Color> gradientColors) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showChatDialog(gradientColors),
          borderRadius: BorderRadius.circular(20),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.chat_bubble_outline, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'Chat',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(List<Color> gradientColors) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: _performSearch,
          style: AppTypography.bodyMedium,
          decoration: InputDecoration(
            hintText: 'Search life situations...',
            hintStyle: TextStyle(color: Colors.grey[400]),
            prefixIcon: Icon(Icons.search, color: gradientColors[0]),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      _searchController.clear();
                      _loadInitialData();
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryGrid() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Categories',
              style: AppTypography.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            RepaintBoundary(
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.1,
                ),
                itemCount: _firebaseService.getCategories().length,
                itemBuilder: (context, index) {
                  final category = _firebaseService.getCategories()[index];
                  final isSelected = category.toLowerCase() == _selectedCategory.toLowerCase();
                  final emoji = _categoryEmojis[category.toLowerCase()] ?? '✨';

                  return OptimizedCategoryTile(
                    category: category,
                    emoji: emoji,
                    isSelected: isSelected,
                    onTap: () => _onCategorySelected(category),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDilemmasList() {
    return Expanded(
      child: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(AppColors.primaryBlue),
              ),
            )
          : _dilemmas.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadInitialData,
                  color: AppColors.primaryBlue,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    itemCount: _dilemmas.length + (_isLoadingMore ? 1 : 0),
                    itemExtent: 140, // Fixed height for better performance
                    cacheExtent: 500, // Pre-cache for smooth scrolling
                    addAutomaticKeepAlives: false,
                    addRepaintBoundaries: true,
                    itemBuilder: (context, index) {
                      if (index == _dilemmas.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final dilemma = _dilemmas[index];
                      return OptimizedDilemmaCard(
                        dilemma: dilemma,
                        onTap: () => _showDilemmaDetails(dilemma),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No situations found',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different search or category',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      _loadInitialData();
      return;
    }

    _performanceMonitor.trackOperation(
      'Search',
      () async {
        final results = await _firebaseService.searchDilemmasOptimized(query);
        setState(() => _dilemmas = results);
      },
    );
  }

  void _showChatDialog(List<Color> gradientColors) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ChatAssistantWidget(
        gradientColors: gradientColors,
        onDilemmaSelected: _showDilemmaDetails,
      ),
    );
  }

  void _showDilemmaDetails(Map<String, dynamic> dilemma) {
    _firebaseService.logEvent('dilemma_opened_v3', {
      'dilemma_id': dilemma['id'],
      'category': dilemma['category'],
    });

    // Navigate to detail page or show modal
    // Implementation depends on your navigation setup
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    _performanceMonitor.stopMonitoring();
    _firebaseService.clearCache();
    super.dispose();
  }
}