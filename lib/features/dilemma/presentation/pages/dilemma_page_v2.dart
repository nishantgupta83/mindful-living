import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/services/firebase_service.dart';
import '../widgets/chat_assistant_widget.dart';

class DilemmaPageV2 extends StatefulWidget {
  const DilemmaPageV2({super.key});

  @override
  State<DilemmaPageV2> createState() => _DilemmaPageV2State();
}

class _DilemmaPageV2State extends State<DilemmaPageV2> with SingleTickerProviderStateMixin {
  final FirebaseService _firebaseService = FirebaseService();
  List<Map<String, dynamic>> _dilemmas = [];
  List<Map<String, dynamic>> _filteredDilemmas = [];
  bool _isLoading = true;
  String _selectedCategory = '';
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Category color mapping
  final Map<String, List<Color>> categoryColors = {
    'relationships': [const Color(0xFF9C27B0), const Color(0xFFBA68C8)],
    'career': [const Color(0xFF00897B), const Color(0xFF26A69A)],
    'finance': [const Color(0xFF2E7D32), const Color(0xFF43A047)],
    'mental health': [const Color(0xFF1976D2), const Color(0xFF42A5F5)],
    'family': [const Color(0xFFFB8C00), const Color(0xFFFFA726)],
    'health': [const Color(0xFFE91E63), const Color(0xFFEC407A)],
    'all': [const Color(0xFF5E35B1), const Color(0xFF7E57C2)],
  };

  // Category emoji icons (more visual and friendly)
  final Map<String, String> categoryEmojis = {
    'relationships': '💝',
    'career': '🚀',
    'finance': '💰',
    'mental health': '🧠',
    'family': '🏠',
    'health': '❤️',
    'all': '✨',
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
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
    _loadDilemmas();
  }

  Future<void> _loadDilemmas() async {
    setState(() => _isLoading = true);
    try {
      final dilemmas = await _firebaseService.getDilemmas();
      setState(() {
        _dilemmas = dilemmas;
        _filteredDilemmas = dilemmas;
        _isLoading = false;
      });
      _firebaseService.logEvent('dilemma_page_v2_viewed', null);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading dilemmas: $e')),
        );
      }
    }
  }

  void _filterDilemmas() {
    setState(() {
      _filteredDilemmas = _dilemmas.where((dilemma) {
        final matchesCategory = _selectedCategory.isEmpty ||
            _selectedCategory.toLowerCase() == 'all' ||
            dilemma['category'].toString().toLowerCase() == _selectedCategory.toLowerCase();
        final matchesSearch = _searchController.text.isEmpty ||
            dilemma['title'].toString().toLowerCase().contains(_searchController.text.toLowerCase()) ||
            dilemma['description'].toString().toLowerCase().contains(_searchController.text.toLowerCase());
        return matchesCategory && matchesSearch;
      }).toList();
    });
  }

  List<Color> _getCurrentGradientColors() {
    if (_selectedCategory.isEmpty) {
      return categoryColors['all']!;
    }
    return categoryColors[_selectedCategory.toLowerCase()] ?? categoryColors['all']!;
  }

  @override
  Widget build(BuildContext context) {
    final gradientColors = _getCurrentGradientColors();

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              gradientColors[0].withValues(alpha: 0.1),
              gradientColors[1].withValues(alpha: 0.05),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with Chatbot
              Container(
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
                  boxShadow: [
                    BoxShadow(
                      color: gradientColors[0].withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
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
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            _showChatDialog();
                            HapticFeedback.lightImpact();
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.chat_bubble_outline,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Chat',
                                  style: AppTypography.labelMedium.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => _filterDilemmas(),
                    style: AppTypography.bodyMedium,
                    decoration: InputDecoration(
                      hintText: 'Search life situations...',
                      hintStyle: AppTypography.bodyMedium.copyWith(
                        color: Colors.grey[400],
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: gradientColors[0],
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                _searchController.clear();
                                _filterDilemmas();
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
              ),

              // Category Tiles
              FadeTransition(
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
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 3,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.1,
                        children: _firebaseService.getCategories().map((category) {
                          final isSelected = category.toLowerCase() == _selectedCategory.toLowerCase();
                          final colors = categoryColors[category.toLowerCase()] ?? categoryColors['all']!;
                          final emoji = categoryEmojis[category.toLowerCase()] ?? '✨';

                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              setState(() {
                                _selectedCategory = isSelected ? '' : category;
                                _filterDilemmas();
                              });
                              _firebaseService.logEvent('category_tile_selected', {'category': category});
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isSelected
                                      ? colors
                                      : [
                                          colors[0].withValues(alpha: 0.1),
                                          colors[1].withValues(alpha: 0.05),
                                        ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.transparent
                                      : colors[0].withValues(alpha: 0.3),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: isSelected
                                        ? colors[0].withValues(alpha: 0.4)
                                        : colors[0].withValues(alpha: 0.15),
                                    blurRadius: isSelected ? 20 : 8,
                                    offset: Offset(0, isSelected ? 8 : 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.white.withValues(alpha: 0.2)
                                          : colors[0].withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      emoji,
                                      style: const TextStyle(
                                        fontSize: 28,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    category,
                                    style: AppTypography.labelSmall.copyWith(
                                      color: isSelected ? Colors.white : colors[0],
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Dilemmas List
              Expanded(
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(gradientColors[0]),
                        ),
                      )
                    : _filteredDilemmas.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: Colors.grey[300],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No situations found',
                                  style: AppTypography.headlineSmall.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Try a different category or search term',
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadDilemmas,
                            color: gradientColors[0],
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                              itemCount: _filteredDilemmas.length,
                              itemBuilder: (context, index) {
                                final dilemma = _filteredDilemmas[index];
                                final colors = categoryColors[dilemma['category'].toString().toLowerCase()] ??
                                               categoryColors['all']!;

                                return _DilemmaCard(
                                  dilemma: dilemma,
                                  colors: colors,
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    _firebaseService.logEvent('dilemma_card_tapped', {
                                      'dilemma_id': dilemma['id'],
                                      'category': dilemma['category'],
                                    });
                                    _showDilemmaDetails(dilemma, colors);
                                  },
                                );
                              },
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showChatDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ChatAssistantWidget(
        gradientColors: _getCurrentGradientColors(),
        onDilemmaSelected: (dilemma) {
          _showDilemmaDetails(
            dilemma,
            categoryColors[dilemma['category'].toString().toLowerCase()] ?? categoryColors['all']!,
          );
        },
      ),
    );
  }

  void _showDilemmaDetails(Map<String, dynamic> dilemma, List<Color> colors) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: colors[0].withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: colors),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  categoryEmojis[dilemma['category'].toString().toLowerCase()] ?? '✨',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  dilemma['category'],
                                  style: AppTypography.labelMedium.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _getDifficultyColor(dilemma['difficulty']).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: _getDifficultyColor(dilemma['difficulty']).withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              dilemma['difficulty'],
                              style: AppTypography.labelSmall.copyWith(
                                color: _getDifficultyColor(dilemma['difficulty']),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        dilemma['title'],
                        style: AppTypography.headlineMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        dilemma['description'],
                        style: AppTypography.bodyLarge.copyWith(
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Mindful Approach
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              colors[0].withValues(alpha: 0.05),
                              colors[1].withValues(alpha: 0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: colors[0].withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.spa, color: colors[0], size: 24),
                                const SizedBox(width: 8),
                                Text(
                                  'Mindful Approach',
                                  style: AppTypography.headlineSmall.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colors[0],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              dilemma['mindfulApproach'],
                              style: AppTypography.bodyMedium.copyWith(
                                fontStyle: FontStyle.italic,
                                height: 1.5,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Practical Steps
                      Text(
                        'Practical Steps',
                        style: AppTypography.headlineSmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...List.generate(
                        (dilemma['practicalSteps'] as List).length,
                        (index) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 2),
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: colors),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  dilemma['practicalSteps'][index],
                                  style: AppTypography.bodyMedium.copyWith(
                                    height: 1.5,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                HapticFeedback.mediumImpact();
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Added to your saved wisdom!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                _firebaseService.logEvent('dilemma_saved', {
                                  'dilemma_id': dilemma['id'],
                                });
                              },
                              icon: const Icon(Icons.bookmark_outline, color: Colors.white),
                              label: const Text('Save', style: TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colors[0],
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                _firebaseService.logEvent('dilemma_shared', {
                                  'dilemma_id': dilemma['id'],
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Sharing options coming soon!'),
                                  ),
                                );
                              },
                              icon: Icon(Icons.share, color: colors[0]),
                              label: Text('Share', style: TextStyle(color: colors[0])),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: colors[0], width: 2),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}

class _DilemmaCard extends StatelessWidget {
  final Map<String, dynamic> dilemma;
  final List<Color> colors;
  final VoidCallback onTap;

  const _DilemmaCard({
    required this.dilemma,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: colors[0].withValues(alpha: 0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: colors[0].withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: colors,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.psychology,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dilemma['title'],
                            style: AppTypography.h5.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Icons.category,
                                size: 14,
                                color: colors[0],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                dilemma['category'],
                                style: AppTypography.labelSmall.copyWith(
                                  color: colors[0],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.grey[400],
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                dilemma['wellnessFocus'],
                                style: AppTypography.labelSmall.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: colors[0],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  dilemma['description'],
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getDifficultyColor(dilemma['difficulty']).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        dilemma['difficulty'],
                        style: AppTypography.labelSmall.copyWith(
                          color: _getDifficultyColor(dilemma['difficulty']),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.visibility,
                      size: 14,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${dilemma['views']}',
                      style: AppTypography.labelSmall.copyWith(
                        color: Colors.grey[500],
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

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}