import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/intelligent_search_service.dart';
import '../../../../shared/widgets/category_filter_chips.dart';
import '../../../../shared/widgets/situation_card.dart';
import '../../../../shared/utils/life_area_utils.dart';

/// Explore page with AI-powered search, filters, and infinite scroll
class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<DocumentSnapshot> _situations = [];
  final IntelligentSearchService _searchService = IntelligentSearchService();

  String? _selectedCategory;
  String _searchQuery = '';
  bool _isLoading = false;
  bool _hasMore = true;
  bool _isSearching = false;
  bool _isIndexing = false;
  DocumentSnapshot? _lastDocument;
  Timer? _debounce;
  List<Map<String, dynamic>> _searchResults = [];

  static const int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _loadInitialSituations();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      _loadMoreSituations();
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    setState(() {
      _isSearching = true;
      _searchQuery = query;
    });

    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      _refreshSituations();
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      await _performIntelligentSearch(query);
    });
  }

  Future<void> _performIntelligentSearch(String query) async {
    try {
      setState(() {
        _isSearching = true;
      });

      // Perform AI-powered search with TF-IDF ranking
      final results = await _searchService.search(
        query,
        maxResults: 50, // Get more results for better relevance
      );

      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      print('Search error: $e');
      if (mounted) {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
      }
    }
  }

  Future<void> _loadInitialSituations() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _situations.clear();
      _lastDocument = null;
      _hasMore = true;
    });

    try {
      final query = _buildQuery().limit(_pageSize);
      final snapshot = await query.get();

      if (mounted) {
        setState(() {
          _situations.addAll(snapshot.docs);
          _lastDocument = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
          _hasMore = snapshot.docs.length == _pageSize;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadMoreSituations() async {
    if (_isLoading || !_hasMore || _lastDocument == null) return;

    setState(() => _isLoading = true);

    try {
      final query = _buildQuery()
          .startAfterDocument(_lastDocument!)
          .limit(_pageSize);

      final snapshot = await query.get();

      if (mounted) {
        setState(() {
          _situations.addAll(snapshot.docs);
          _lastDocument = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
          _hasMore = snapshot.docs.length == _pageSize;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Query<Map<String, dynamic>> _buildQuery() {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('life_situations')
        .where('isActive', isEqualTo: true);

    // Category filter
    if (_selectedCategory != null) {
      query = query.where('lifeArea', isEqualTo: _selectedCategory);
    }

    // Search filter (basic - for full-text search, use Algolia or similar)
    // For now, we'll load all and filter client-side for search

    return query;
  }

  // Returns either AI search results or regular Firestore results
  bool get _usingAISearch => _searchQuery.isNotEmpty && _searchResults.isNotEmpty;

  int get _resultsCount {
    if (_searchQuery.isNotEmpty) {
      return _searchResults.length;
    }
    return _situations.length;
  }

  Future<void> _refreshSituations() async {
    HapticFeedback.lightImpact();
    await _loadInitialSituations();
  }

  void _onCategorySelected(String? category) {
    setState(() {
      _selectedCategory = category;
    });
    _refreshSituations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshSituations,
        color: AppColors.deepLavender,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            // App Bar with Search
            _buildSearchAppBar(),

            // Category Filters (hide during search)
            if (_searchQuery.isEmpty)
              SliverToBoxAdapter(
                child: _buildCategoryFilters(),
              ),

            // Results Count
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    if (_usingAISearch)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.lavender.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              size: 14,
                              color: AppColors.deepLavender,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'AI Search',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.deepLavender,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (_usingAISearch) const SizedBox(width: 12),
                    Text(
                      '$_resultsCount situation${_resultsCount != 1 ? 's' : ''}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.softCharcoal,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (_searchQuery.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'for "$_searchQuery"',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.softCharcoal,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Situations List
            if (_resultsCount == 0 && !_isLoading && !_isSearching)
              _buildEmptyState()
            else if (_usingAISearch)
              _buildSearchResultsList()
            else
              _buildRegularSituationsList(),

            const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResultsList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final result = _searchResults[index];
          final id = result['id'] as String;
          final relevanceScore = result['relevanceScore'] as double?;

          return Hero(
            tag: 'situation_$id',
            child: SituationCard(
              key: ValueKey(id),
              title: result['title'] ?? 'Untitled',
              description: result['description'] ?? '',
              lifeArea: result['lifeArea'],
              difficulty: result['difficulty'],
              readTime: result['estimatedReadTime'],
              tags: (result['tags'] as List?)?.cast<String>(),
              onTap: () {
                HapticFeedback.lightImpact();
                // Navigate to detail
              },
            ),
          );
        },
        childCount: _searchResults.length,
      ),
    );
  }

  Widget _buildRegularSituationsList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index >= _situations.length) {
            return _buildLoadingIndicator();
          }

          final doc = _situations[index];
          final data = doc.data() as Map<String, dynamic>;

          return Hero(
            tag: 'situation_${doc.id}',
            child: SituationCard(
              key: ValueKey(doc.id),
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
        childCount: _situations.length + (_hasMore && !_usingAISearch ? 1 : 0),
      ),
    );
  }

  Widget _buildSearchAppBar() {
    return SliverAppBar(
      expandedHeight: 140,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.cream,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.lavender.withValues(alpha: 0.1),
                AppColors.cream,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Search bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadowLight,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: 'Search situations...',
                        hintStyle: TextStyle(
                          color: AppColors.softCharcoal.withValues(alpha: 0.5),
                        ),
                        prefixIcon: _isSearching
                            ? Padding(
                                padding: const EdgeInsets.all(14),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(
                                      AppColors.deepLavender,
                                    ),
                                  ),
                                ),
                              )
                            : const Icon(Icons.search, color: AppColors.deepLavender),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  _onSearchChanged('');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
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

  Widget _buildCategoryFilters() {
    return CategoryFilterChipList(
      categories: const [
        CategoryFilterOption(label: 'Wellness', icon: Icons.spa_outlined, count: 0),
        CategoryFilterOption(label: 'Relationships', icon: Icons.favorite_border, count: 0),
        CategoryFilterOption(label: 'Career', icon: Icons.work_outline, count: 0),
        CategoryFilterOption(label: 'Growth', icon: Icons.trending_up, count: 0),
        CategoryFilterOption(label: 'Family', icon: Icons.people_outline, count: 0),
        CategoryFilterOption(label: 'Health', icon: Icons.health_and_safety_outlined, count: 0),
        CategoryFilterOption(label: 'Mindfulness', icon: Icons.self_improvement, count: 0),
        CategoryFilterOption(label: 'Stress', icon: Icons.psychology_outlined, count: 0),
        CategoryFilterOption(label: 'Finance', icon: Icons.account_balance_wallet_outlined, count: 0),
        CategoryFilterOption(label: 'Communication', icon: Icons.chat_bubble_outline, count: 0),
        CategoryFilterOption(label: 'Life Balance', icon: Icons.balance, count: 0),
      ],
      selectedCategory: _selectedCategory,
      onCategorySelected: _onCategorySelected,
    );
  }

  Widget _buildEmptyState() {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _searchQuery.isNotEmpty ? Icons.search_off : Icons.explore_off,
              size: 64,
              color: AppColors.softCharcoal.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No situations found'
                  : 'No situations available',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.softCharcoal,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Try different keywords'
                  : 'Check back later',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.softCharcoal.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(AppColors.deepLavender),
        ),
      ),
    );
  }
}
